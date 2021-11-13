module hw.memory.memory;

import hw.apu;
import hw.memory;
import hw.cpu;
import hw.ppu;
import save;
import scheduler;

import abstracthw.memory;

import util;

import std.stdio;

enum SIZE_BIOS        = 0x4000;
enum SIZE_WRAM_BOARD  = 0x40000;
enum SIZE_WRAM_CHIP   = 0x8000;
enum SIZE_PALETTE_RAM = 0x400;
enum SIZE_VRAM        = 0x18000 + 0x8000;
// note: in reality, VRAM's size is 0x18000. But, the sizes are used for mirroring purposes.
// accesses are and'd by (size - 1) to handle mirroring. VRAM mirrors weirdly because it isn't
// a power of 2 - it mirrors as if its size was 0x20000. Additionally, the empty 0x8000 bytes
// are mirrors of the last 0x8000 bytes.

enum SIZE_OAM         = 0x400;
enum SIZE_ROM         = 0x2000000;

enum OFFSET_BIOS         = 0x0000000;
enum OFFSET_WRAM_BOARD   = 0x2000000;
enum OFFSET_WRAM_CHIP    = 0x3000000;
enum OFFSET_IO_REGISTERS = 0x4000000;
enum OFFSET_PALETTE_RAM  = 0x5000000;
enum OFFSET_VRAM         = 0x6000000;
enum OFFSET_OAM          = 0x7000000;
enum OFFSET_ROM_1        = 0x8000000;
enum OFFSET_ROM_2        = 0xA000000;
enum OFFSET_ROM_3        = 0xC000000;
enum OFFSET_SRAM         = 0xE000000;

Memory memory;

// assume abbreviation "ws" = "waitstate" because these lines are getting long
// N and S stand for nonsequential and sequential look, i love using verbose 
// variable names, but in this case the lines will simply be too long to understand

class Memory : IMemory {
    bool has_updated = false;

    ubyte[] pixels;
    /** video buffer in RGBA8888 */
    uint[][] video_buffer;

    // audio fifos
    Fifo!ubyte fifo_a;
    Fifo!ubyte fifo_b;

    MMIO mmio;

    uint[2]* cpu_pipeline;
    uint*    pipeline_size;

    PrefetchBuffer prefetch_buffer;
    Scheduler scheduler;

    ubyte[] bios;
    ubyte[] wram_board;
    ubyte[] wram_chip;
    ubyte[] palette_ram;
    ubyte[] vram;
    ubyte[] oam;

    ROM rom;

    @property uint cycles()            { return m_cycles; };
    @property uint cycles(uint cycles) { return m_cycles = cycles; };
    uint m_cycles = 0;

    // the number of cycles to idle on a given memory access is given by
    // waitstates[memory region][access type][byte = 0 | halfword = 1 | word = 2]

    int[3][2][16] waitstates = [
        [[1, 1, 1], [1, 1, 1]], // BIOS
        [[1, 1, 1], [1, 1, 1]], // Invalid
        [[3, 3, 6], [3, 3, 6]], // Work Ram Board
        [[1, 1, 1], [1, 1, 1]], // Work Ram Chip
        [[1, 1, 1], [1, 1, 1]], // IO Registers
        [[1, 1, 2], [1, 1, 2]], // Palette Ram
        [[1, 1, 2], [1, 1, 2]], // VRAM
        [[1, 1, 1], [1, 1, 1]], // OAM

        [[5, 5, 8], [3, 3, 6]], // ROM Wait State 0
        [[5, 5, 8], [3, 3, 6]], // ROM Wait State 0
        [[5, 5, 8], [3, 3, 6]], // ROM Wait State 1
        [[5, 5, 8], [3, 3, 6]], // ROM Wait State 1
        [[5, 5, 8], [3, 3, 6]], // ROM Wait State 2
        [[5, 5, 8], [3, 3, 6]], // ROM Wait State 2
        [[5, 5, 8], [3, 3, 6]], // ROM SRAM
        [[5, 5, 8], [3, 3, 6]]  // ROM SRAM
    ];

    bool can_read_from_bios = false;
    OpenBusBiosState open_bus_bios_state = OpenBusBiosState.STARTUP;

    ushort waitcnt;
    void write_WAITCNT(uint target_byte, ubyte data) {
        
        final switch (target_byte) {
            case 0b0:
                int ws_sram = (cast(int[]) [4, 3, 2, 8])[get_nth_bits(data, 0, 2)];
                int ws_0_N  = (cast(int[]) [4, 3, 2, 8])[get_nth_bits(data, 2, 4)];
                int ws_0_S  = (cast(int[]) [2, 1])      [get_nth_bit (data, 4)];
                int ws_1_N  = (cast(int[]) [4, 3, 2, 8])[get_nth_bits(data, 5, 7)];
                int ws_1_S  = (cast(int[]) [4, 1])      [get_nth_bit (data, 7)];

                waitstates[Region.ROM_SRAM_L][AccessType.SEQUENTIAL]    = [ws_sram, ws_sram, ws_sram];
                waitstates[Region.ROM_SRAM_H][AccessType.SEQUENTIAL]    = [ws_sram, ws_sram, ws_sram];
                waitstates[Region.ROM_SRAM_L][AccessType.NONSEQUENTIAL] = [ws_sram, ws_sram, ws_sram];
                waitstates[Region.ROM_SRAM_H][AccessType.NONSEQUENTIAL] = [ws_sram, ws_sram, ws_sram];

                set_waitstate_ROM(0, ws_0_N, ws_0_S);
                set_waitstate_ROM(1, ws_1_N, ws_1_S);

                waitcnt &= 0xFF00;
                waitcnt |= data;
                break;
            
            case 0b1:
                int ws_2_N  = (cast(int[]) [4, 3, 2, 8])[get_nth_bits(data, 0, 2)];
                int ws_2_S  = (cast(int[]) [8, 1])      [get_nth_bit (data, 2)];

                prefetch_buffer.set_enabled(get_nth_bit(data, 6));

                set_waitstate_ROM(2, ws_2_N, ws_2_S);

                waitcnt &= 0x00FF;
                waitcnt |= data << 8;
                break;
        }
    }
    
    ubyte read_WAITCNT(uint target_byte) {
        final switch (target_byte) {
            case 0b0:
                return waitcnt & 0xFF;
            
            case 0b1:
                return waitcnt >> 8;
        }
    }

    // ws_region is one of: 0, 1, 2
    void set_waitstate_ROM(int ws_region, int ws_N, int ws_S) {
        int rom_region = Region.ROM_WAITSTATE_0_L + ws_region * 2;

        // waitstate regions have a size of 2
        for (int i = 0; i < 2; i++) {
            waitstates[rom_region + i][AccessType.NONSEQUENTIAL][AccessSize.BYTE    ] = ws_N + 1;
            waitstates[rom_region + i][AccessType.NONSEQUENTIAL][AccessSize.HALFWORD] = ws_N + 1;
            waitstates[rom_region + i][AccessType.NONSEQUENTIAL][AccessSize.WORD    ] = ws_N + 1 + ws_S + 1;

            waitstates[rom_region + i][AccessType.SEQUENTIAL   ][AccessSize.BYTE    ] = ws_S + 1;
            waitstates[rom_region + i][AccessType.SEQUENTIAL   ][AccessSize.HALFWORD] = ws_S + 1;
            waitstates[rom_region + i][AccessType.SEQUENTIAL   ][AccessSize.WORD    ] = ws_S + 1 + ws_S + 1;
        }
    }

    uint bios_open_bus_latch = 0;
    
    this() {
        video_buffer = new uint[][](240, 160);
        fifo_a = new Fifo!ubyte(0x20, 0x00);
        fifo_b = new Fifo!ubyte(0x20, 0x00);

        this.mmio = null;
        this.ppu  = ppu;

        this.bios        = new ubyte[SIZE_BIOS];
        this.wram_board  = new ubyte[SIZE_WRAM_BOARD];
        this.wram_chip   = new ubyte[SIZE_WRAM_CHIP];
        this.palette_ram = new ubyte[SIZE_PALETTE_RAM];
        this.vram        = new ubyte[SIZE_VRAM];
        this.oam         = new ubyte[SIZE_OAM];

        memory = this;
        prefetch_buffer = new PrefetchBuffer(memory);

        write_WAITCNT(0, 0);
        write_WAITCNT(1, 0);
    }

    // MUST BE CALLED BEFORE READ/WRITE TO 0x0400_0000 ARE ACCESSED!
    void set_mmio(MMIO mmio) {
        this.mmio = mmio;
    }

    // MUST BE CALLED BEFORE "REGULAR" OPEN BUS IS ACCESSED!
    void set_cpu_pipeline(uint[2]* cpu_pipeline, uint* pipeline_size) {
        this.cpu_pipeline  = cpu_pipeline;
        this.pipeline_size = pipeline_size;
    }

    // MUST BE CALLED BEFORE ANY MEMORY ACCESS / IDLE CYCLE WHATSOEVER
    void set_scheduler(Scheduler scheduler) {
        this.scheduler = scheduler;
    }

    // MUST BE CALLED BEFORE ROM IS ACCESSED!
    void load_rom(ubyte[] rom_data) {
        rom = new ROM(rom_data);
    }

    PPU ppu;
    void set_ppu(PPU ppu) {
        this.ppu = ppu;
    }

    pragma(inline, true) uint get_region(uint address) {
        return (address >> 24) & 0xF;
    }

    pragma(inline, true) ubyte read_byte(uint address, AccessType access_type = AccessType.SEQUENTIAL, bool instruction_access = false) {
        return read!ubyte(address, access_type, instruction_access);
    }

    pragma(inline, true) ushort read_halfword(uint address, AccessType access_type = AccessType.SEQUENTIAL, bool instruction_access = false) {    
        return read!ushort(address, access_type, instruction_access);
    }

    pragma(inline, true) uint read_word(uint address, AccessType access_type = AccessType.SEQUENTIAL, bool instruction_access = false) {
        return read!uint(address, access_type, instruction_access);
    }

    pragma(inline, true) void write_byte(uint address, ubyte value, AccessType access_type = AccessType.SEQUENTIAL, bool instruction_access = false) {
        write!ubyte(address, value, access_type, instruction_access);
    }

    pragma(inline, true) void write_halfword(uint address, ushort value, AccessType access_type = AccessType.SEQUENTIAL, bool instruction_access = false) {
        write!ushort(address, value, access_type, instruction_access);
    }

    pragma(inline, true) void write_word(uint address, uint value, AccessType access_type = AccessType.SEQUENTIAL, bool instruction_access = false) {
        write!uint(address, value, access_type, instruction_access);
    }

    private template read(T) {
        pragma(inline, true) T read(uint address, AccessType access_type = AccessType.SEQUENTIAL, bool instruction_access = false) {
            uint region = get_region(address);

            // handle waitstates
            if (region < 0x8) {
                uint stalls = calculate_stalls_for_access!T(region, access_type);
                prefetch_buffer.run(stalls);
                scheduler.tick(stalls);
            }

            if (address >> 28) {
                // writeln(format("OPEN BUS. %x %x", cast(T) (*cpu_pipeline)[1], read_word(0x0300686c)));
                return read_open_bus!T(address);
            }

            uint shift;
            static if (is(T == uint  )) shift = 2;
            static if (is(T == ushort)) shift = 1;
            static if (is(T == ubyte )) shift = 0;

            switch (region) {
                case 0x1: return read_open_bus!T(address); // nothing is mapped here
                case Region.WRAM_BOARD:   return (cast(T*) wram_board) [(address & (SIZE_WRAM_BOARD  - 1)) >> shift]; 
                case Region.WRAM_CHIP:    return (cast(T*) wram_chip)  [(address & (SIZE_WRAM_CHIP   - 1)) >> shift];
                case Region.PALETTE_RAM:  return (cast(T*) palette_ram)[(address & (SIZE_PALETTE_RAM - 1)) >> shift];
                
                case Region.VRAM:
                    uint wrapped_address = address & (SIZE_VRAM - 1);
                    if (wrapped_address >= 0x18000) wrapped_address -= 0x8000;
                    return (cast(T*) vram)[wrapped_address >> shift];

                case Region.OAM:          return (cast(T*) oam)        [(address & (SIZE_OAM         - 1)) >> shift]; 

                case Region.IO_REGISTERS:
                    static if (is(T == uint)) return 
                        (cast(uint) mmio.read(address + 0) << 0)  |
                        (cast(uint) mmio.read(address + 1) << 8)  |
                        (cast(uint) mmio.read(address + 2) << 16) | 
                        (cast(uint) mmio.read(address + 3) << 24);
                    static if (is(T == ushort)) {
                        ushort x =
                        (cast(ushort) mmio.read(address + 0) << 0)  |
                        (cast(ushort) mmio.read(address + 1) << 8);
                        return x;}
                    static if (is(T == ubyte))  return mmio.read(address);

                case Region.BIOS: 
                    if (can_read_from_bios) {
                        uint word_aligned_address = address & ~3;

                        bios_open_bus_latch = *((cast(uint*) (&bios[0] + (word_aligned_address & ~3 & (SIZE_BIOS - 1)))));

                        static if (is(T == uint))   return (bios_open_bus_latch);
                        static if (is(T == ushort)) return (bios_open_bus_latch >> (16 * ((address >> 1) & 1))) & 0xFFFF;
                        static if (is(T == ubyte))  return (bios_open_bus_latch >> (8  * ((address >> 0) & 3))) & 0xFF;
                    } else {
                        return read_open_bus!T(address);
                    }

                case Region.ROM_SRAM_L:
                case Region.ROM_SRAM_H:
                    uint stalls = calculate_stalls_for_access!T(region, access_type);
                    prefetch_buffer.run(stalls);
                    scheduler.tick(stalls);

                    // writefln("attempting backup read at %x", address);
                    if (backup_enabled) {
                        static if (is(T == uint  )) return backup.read_word    (address);
                        static if (is(T == ushort)) return backup.read_halfword(address);
                        static if (is(T == ubyte )) return backup.read_byte    (address);
                    }
                    goto default;

                default:
                    static if (is(T == uint  )) {
                        uint aligned_address = (address & ~3) >> 1;
                        return prefetch_buffer.request_data_from_rom!T(aligned_address, access_type, instruction_access);
                    }

                    static if (is(T == ushort  )) {
                        return prefetch_buffer.request_data_from_rom!T(address >> 1, access_type, instruction_access);
                    }

                    static if (is(T == ubyte )) {
                        return cast(ubyte) (prefetch_buffer.request_data_from_rom!ushort(address >> 1, access_type, instruction_access) >> (8 * (address & 1)));
                    }
            }
        }
    }


    T read_open_bus(T)(uint address) {
        if (address < SIZE_BIOS) {
            return cast(T) bios_open_bus_latch;
        }
        
        // "regular" open bus
        uint open_bus_value;
        if (*pipeline_size == 4) {
            open_bus_value = (*cpu_pipeline)[1];
        } else {
            switch ((address >> 24) & 0xF) {
                case Region.WRAM_BOARD:
                case Region.PALETTE_RAM:
                case Region.VRAM:
                case Region.ROM_WAITSTATE_0_L:
                case Region.ROM_WAITSTATE_0_H:
                case Region.ROM_WAITSTATE_1_L:
                case Region.ROM_WAITSTATE_1_H:
                case Region.ROM_WAITSTATE_2_L:
                case Region.ROM_WAITSTATE_2_H:
                case Region.ROM_SRAM_L:
                case Region.ROM_SRAM_H:
                    open_bus_value = (*cpu_pipeline)[1] << 16 | (*cpu_pipeline)[1];
                    break;

                // TODO: misaligned addresses behave differently, see GBATEK "unpredictable things" section
                case Region.BIOS:
                case 0x1: // unmapped
                case Region.OAM:
                    open_bus_value = (*cpu_pipeline)[1] << 16 | (*cpu_pipeline)[0];
                    break;

                // TODO: latch this to emulate properly, see GBATEK "unpredictable things" section
                case Region.WRAM_CHIP:
                case Region.IO_REGISTERS:
                    open_bus_value = ((*cpu_pipeline)[1] << 16) | 
                                     ((*cpu_pipeline)[1] & 0xFFFF);
                    break;

                default:
                    // this physically can't happen but ok
                    open_bus_value = 0;
            }
        }

        return (cast(T) open_bus_value >> (8 * (address & 3)));
    }
    private template write(T) {
        pragma(inline, true) void write(uint address, T value, AccessType access_type = AccessType.SEQUENTIAL, bool instruction_access = false) {
            uint region = get_region(address);

            uint shift;
            static if (is(T == uint  )) shift = 2;
            static if (is(T == ushort)) shift = 1;
            static if (is(T == ubyte )) shift = 0;

            // handle waitstates
            uint stalls = calculate_stalls_for_access!T(region, access_type);
            prefetch_buffer.run(stalls);
            scheduler.tick(stalls);

            switch ((address >> 24) & 0xF) {
                case Region.BIOS:         break; // incorrect - implement properly later
                case 0x1:                 break; // nothing is mapped here
                case Region.WRAM_BOARD:   (cast(T*) wram_board) [(address & (SIZE_WRAM_BOARD  - 1)) >> shift] = value; break;
                case Region.WRAM_CHIP:    (cast(T*) wram_chip)  [(address & (SIZE_WRAM_CHIP   - 1)) >> shift] = value; break;
                case Region.PALETTE_RAM:  
                    uint palette_ram_address = (address & (SIZE_PALETTE_RAM - 1)) >> shift;

                    uint index = (address & (SIZE_PALETTE_RAM - 1)) >> 1;

                    static if (is(T == uint)) {
                        index &= ~1;
                        hw.ppu.palette.set_color(index,     cast(ushort) (value & 0xFFFF));
                        hw.ppu.palette.set_color(index + 1, cast(ushort) (value >> 16));
                        (cast(T*) palette_ram) [palette_ram_address] = value; 
                    } else static if (is(T == ushort)) {
                        hw.ppu.palette.set_color(index, value);
                        (cast(T*) palette_ram) [palette_ram_address] = value; 
                    } else static if (is(T == ubyte)) {
                        hw.ppu.palette.set_color(index, value | (value << 8));
                        (cast(T*) palette_ram) [(palette_ram_address & ~1)] = value; 
                        (cast(T*) palette_ram) [(palette_ram_address & ~1) + 1] = value; 
                    }
                    break;

                case Region.VRAM:
                    uint wrapped_address = address & (SIZE_VRAM - 1);
                    if (wrapped_address >= 0x18000) wrapped_address -= 0x8000;

                    static if (is(T == ubyte)) { // byte writes are ignored if writing to OBJ memory

                        bool writing_to_obj = (ppu.bg_mode >= 3) ? wrapped_address >= 0x14000 : wrapped_address >= 0x10000;
                        
                        if (!writing_to_obj) {
                            uint wrapped_masked_address = wrapped_address & ~1;
                            vram[wrapped_masked_address + 0] = value;
                            vram[wrapped_masked_address + 1] = value;
                        }
                        return;
                    } else {
                        (cast(T*) vram)[wrapped_address >> shift] = value; break;
                    }

                case Region.OAM:
                    static if (is(T == ubyte)) return; // byte writes are ignored
                    else {
                        (cast(T*) oam) [(address & (SIZE_OAM - 1)) >> shift] = value; break;
                    }

                case Region.IO_REGISTERS: 
                    static if (is(T == uint)) {
                        // writefln("%x", value);
                        mmio.write(address + 0, (value >>  0) & 0xFF);
                        mmio.write(address + 1, (value >>  8) & 0xFF);
                        mmio.write(address + 2, (value >> 16) & 0xFF); 
                        mmio.write(address + 3, (value >> 24) & 0xFF);
                    } else static if (is(T == ushort)) { 
                        mmio.write(address + 0, (value >>  0) & 0xFF);
                        mmio.write(address + 1, (value >>  8) & 0xFF);
                    } else static if (is(T == ubyte))  {
                        mmio.write(address, value);
                    }

                    break;

                case Region.ROM_SRAM_L:
                case Region.ROM_SRAM_H:
                    if (backup_enabled) {
                        static if (is(T == uint  )) return backup.write_word    (address, value);
                        static if (is(T == ushort)) return backup.write_halfword(address, value);
                        static if (is(T == ubyte )) return backup.write_byte    (address, value);
                    }
                    break;

                default:
                    break;
            }
        }
    }

    bool backup_enabled = false;
    Backup backup;

    void add_backup(Backup backup) {
        this.backup = backup;
        backup_enabled = backup.get_backup_type() != BackupType.NONE;
        writefln("Savetype found? %x", backup_enabled);
    }
    
    pragma(inline, true) void set_rgb(uint x, uint y, ubyte r, ubyte g, ubyte b) {
        video_buffer[x][y] = (r << 24) | (g << 16) | (b << 8) | (0xff);
    }

    pragma(inline, true) uint calculate_stalls_for_access(T)(uint region, AccessType access_type) {
        static if (is(T == uint  )) return waitstates[region][access_type][AccessSize.WORD];
        static if (is(T == ushort)) return waitstates[region][access_type][AccessSize.HALFWORD];
        static if (is(T == ubyte )) return waitstates[region][access_type][AccessSize.BYTE];
    }

    pragma(inline, true) void start_new_prefetch(uint address, AccessSize access_size) {
        prefetch_buffer.start_new_prefetch(address, access_size);
    }

    pragma(inline, true) void run_prefetcher(int number_of_times) {
        prefetch_buffer.run(number_of_times);
    }

    pragma(inline, true) void invalidate_prefetch_buffer() {
        prefetch_buffer.invalidate();
    }
}