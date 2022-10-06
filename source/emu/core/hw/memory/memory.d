module hw.memory.memory;

import hw.apu;
import hw.memory;
import hw.cpu;
import hw.ppu;
import save;
import scheduler;

import diag.log;

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

final class Memory : IMemory {
    bool has_updated = false;

    ubyte[] pixels;
    /** video buffer in RGBA8888 */
    uint[][] video_buffer;

    // audio fifos
    Fifo!ubyte fifo_a;
    Fifo!ubyte fifo_b;

    MMIO mmio;

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

    uint dma_open_bus = 0;
    bool dma_recently = false;

    // the number of cycles to idle on a given memory access is given by
    // waitstates[memory region][access type][byte = 0 | half = 1 | word = 2]

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
        log!(LogSource.DEBUG)("Write to WAITCNT: %x %x", target_byte, data);
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
    uint iwram_latch = 0;
    
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

    // MUST BE CALLED BEFORE ANY MEMORY ACCESS / IDLE CYCLE WHATSOEVER
    void set_scheduler(Scheduler scheduler) {
        this.scheduler = scheduler;
    }

    // MUST BE CALLED BEFORE ROM IS ACCESSED!
    void load_rom(ubyte[] rom_data) {
        rom = new ROM(rom_data);
    }

    ARM7TDMI cpu;
    void set_cpu(ARM7TDMI cpu) {
        this.cpu = cpu;
    }

    PPU ppu;
    void set_ppu(PPU ppu) {
        this.ppu = ppu;
    }

    void idle() {
        if (dma_cycle_accumulation_state == DMACycleAccumulationState.REIMBURSE && accumulated_dma_cycles > 0) {
            accumulated_dma_cycles--;
        } else {
            scheduler.tick(1);
            prefetch_buffer.run(1);
            scheduler.process_events();
        }
    }

    pragma(inline, true) uint get_region(uint address) {
        return (address >> 24) & 0xF;
    }

    pragma(inline, true) ubyte read_byte(uint address, AccessType access_type = AccessType.SEQUENTIAL, bool instruction_access = false) {
        return read!ubyte(address, access_type, instruction_access);
    }

    pragma(inline, true) ushort read_half(uint address, AccessType access_type = AccessType.SEQUENTIAL, bool instruction_access = false) {    
        return read!ushort(address, access_type, instruction_access);
    }

    pragma(inline, true) uint read_word(uint address, AccessType access_type = AccessType.SEQUENTIAL, bool instruction_access = false) {
        return read!uint(address, access_type, instruction_access);
    }

    pragma(inline, true) void write_byte(uint address, ubyte value, AccessType access_type = AccessType.SEQUENTIAL, bool instruction_access = false) {
        write!ubyte(address, value, access_type, instruction_access);
    }

    pragma(inline, true) void write_half(uint address, ushort value, AccessType access_type = AccessType.SEQUENTIAL, bool instruction_access = false) {
        write!ushort(address, value, access_type, instruction_access);
    }

    pragma(inline, true) void write_word(uint address, uint value, AccessType access_type = AccessType.SEQUENTIAL, bool instruction_access = false) {
        write!uint(address, value, access_type, instruction_access);
    }

    int fuck = 0;

    private template read(T) {
        T read(uint address, AccessType access_type = AccessType.SEQUENTIAL, bool instruction_access = false) {
            if (dma_cycle_accumulation_state == DMACycleAccumulationState.REIMBURSE) accumulated_dma_cycles = 0;
            uint region = get_region(address);
            T read_value;

            uint stalls = calculate_stalls_for_access!T(region, access_type);
            
            if (region < 0x8) {
                clock(stalls);
            }

            if (unlikely(address >> 28 > 0)) {                
                read_value = read_open_bus!T(address);
                scheduler.process_events();
                dma_recently = false;
                return read_value;
            }

            uint shift;
            static if (is(T == uint  )) shift = 2;
            static if (is(T == ushort)) shift = 1;
            static if (is(T == ubyte )) shift = 0;

            switch (region) {
                case 0x1: read_value = read_open_bus!T(address); break;// nothing is mapped here
                case Region.WRAM_BOARD:   read_value = (cast(T*) wram_board) [(address & (SIZE_WRAM_BOARD  - 1)) >> shift]; break;

                case Region.WRAM_CHIP:
                    read_value = (cast(T*) wram_chip)  [(address & (SIZE_WRAM_CHIP   - 1)) >> shift]; 
                    
                    static if (is(T == uint)) { 
                        iwram_latch = read_value;
                    }

                    static if (is(T == ushort)) {
                        iwram_latch &= ~(0xFFFF     << (((address & 2) >> 1) * 16));
                        iwram_latch |=   read_value << (((address & 2) >> 1) * 16);
                    }

                    static if (is(T == ubyte))  {
                        iwram_latch &= ~(0xFF       << ((address & 3) * 8));
                        iwram_latch |=   read_value << ((address & 3) * 8);
                    }

                    break;

                case Region.PALETTE_RAM:  read_value = (cast(T*) palette_ram)[(address & (SIZE_PALETTE_RAM - 1)) >> shift]; break;
                
                case Region.VRAM:
                    // if (address == 0x0600_0000 && is(T == ubyte)) {
                        
                    //     import std.stdio;
                    //     if (fuck < 3) {
                    //          writefln("incr + %x", scheduler.get_current_time_relative_to_cpu());
                    //     }
                    //     if (fuck == 3) {                           
                    //         writefln("fuck + %x", scheduler.get_current_time_relative_to_cpu());

                    //         scheduler.tick(1);
                    //     }

                    //     fuck++;
                    // }
                    uint wrapped_address = address & (SIZE_VRAM - 1);
                    if (wrapped_address >= 0x18000) wrapped_address -= 0x8000;
                    read_value = (cast(T*) vram)[wrapped_address >> shift]; break;

                case Region.OAM:          read_value = (cast(T*) oam)        [(address & (SIZE_OAM         - 1)) >> shift];  break;

                case Region.IO_REGISTERS:

                    static if (is(T == uint)) read_value = 
                        (cast(uint) mmio.read(address + 0) << 0)  |
                        (cast(uint) mmio.read(address + 1) << 8)  |
                        (cast(uint) mmio.read(address + 2) << 16) | 
                        (cast(uint) mmio.read(address + 3) << 24);
                    static if (is(T == ushort)) {
                        ushort x =
                        (cast(ushort) mmio.read(address + 0) << 0)  |
                        (cast(ushort) mmio.read(address + 1) << 8);
                        read_value = x;}
                    static if (is(T == ubyte))  read_value = mmio.read(address); 
                    
                    dma_recently = false;
                    return read_value;

                case Region.BIOS: 
                    if (cpu.regs[pc] >> 24 == 0) { // are we in the BIOS range
                        uint word_aligned_address = address & ~3;

                        bios_open_bus_latch = *((cast(uint*) (&bios[0] + (word_aligned_address & ~3 & (SIZE_BIOS - 1)))));

                        static if (is(T == uint))   read_value = (bios_open_bus_latch);
                        static if (is(T == ushort)) read_value = (bios_open_bus_latch >> (16 * ((address >> 1) & 1))) & 0xFFFF;
                        static if (is(T == ubyte))  read_value = (bios_open_bus_latch >> (8  * ((address >> 0) & 3))) & 0xFF;
                    } else {
                        read_value = read_open_bus!T(address);
                    } 
                    
                    break;

                case Region.ROM_SRAM_L:
                case Region.ROM_SRAM_H:
                    if (backup_enabled) {
                        clock(stalls);
                        static if (is(T == uint  )) read_value = backup.read_word(address);
                        static if (is(T == ushort)) read_value = backup.read_half(address);
                        static if (is(T == ubyte )) read_value = backup.read_byte(address); 
                        break;
                    }
                    goto default;
                
                case Region.ROM_WAITSTATE_2_H:
                    if (backup.get_backup_type() == BackupType.EEPROM) {
                        read_value = backup.read_byte(address);
                    } else {
                        goto case Region.ROM_WAITSTATE_0_L;
                    }
                    break;

                case Region.ROM_WAITSTATE_0_L:
                case Region.ROM_WAITSTATE_0_H:
                case Region.ROM_WAITSTATE_1_L:
                case Region.ROM_WAITSTATE_1_H:
                case Region.ROM_WAITSTATE_2_L:
                    static if (is(T == uint  )) {
                        uint aligned_address = (address & ~3) >> 1;
                        read_value = prefetch_buffer.request_data_from_rom!T(aligned_address, access_type, instruction_access);
                    }

                    static if (is(T == ushort  )) {
                        read_value = prefetch_buffer.request_data_from_rom!T(address >> 1, access_type, instruction_access);
                    }

                    static if (is(T == ubyte )) {
                        read_value = cast(ubyte) (prefetch_buffer.request_data_from_rom!ushort(address >> 1, access_type, instruction_access) >> (8 * (address & 1)));
                    }
                    break;
                
                default: error("not possible");
            }
            
            dma_recently = false;
            scheduler.process_events();
            return read_value;
        }
    }


    T read_open_bus(T)(uint address) {

        uint open_bus_value;
        if (address < SIZE_BIOS) {
            static if (is(T == uint  )) open_bus_value = cast(T) bios_open_bus_latch;
            static if (is(T == ushort)) open_bus_value = cast(T) (bios_open_bus_latch >> 16 * ((address >> 1) & 1));
            static if (is(T == ubyte )) open_bus_value = cast(T) (bios_open_bus_latch >> 8  * (address & 3));
        } else {
            // "regular" open bus
            if (cpu.instruction_set == InstructionSet.THUMB) { // THUMB mode
                uint[2] open_bus_reserve = dma_recently ? [dma_open_bus >> 16, dma_open_bus & 0xFFFF] : [cpu.get_pipeline_entry(0), cpu.get_pipeline_entry(1)];

                switch ((cpu.get_reg(pc) >> 24) & 0xF) {
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
                        open_bus_value = open_bus_reserve[1] << 16 | open_bus_reserve[1];
                        break;

                    case Region.BIOS:
                    case 0x1: // unmapped
                    case Region.OAM:
                        open_bus_value = open_bus_reserve[1] << 16 | open_bus_reserve[0];
                        break;

                    case Region.WRAM_CHIP:
                        open_bus_value = iwram_latch;
                        break;

                    case Region.IO_REGISTERS:
                        if ((cpu.get_reg(pc) & 3) == 0) {
                            open_bus_value = (open_bus_reserve[1] << 16) | (open_bus_reserve[0] & 0xFFFF);
                        } else {
                            open_bus_value = (open_bus_reserve[0] << 16) | (open_bus_reserve[1] & 0xFFFF);
                        }
                        break;

                    default:
                        // this physically can't happen but ok
                        error(format("how did this happen"));
                }
            } else { // arm mode
                open_bus_value = cpu.get_pipeline_entry(1);
            }
        }

        {
            import std.conv;
            static if (is(T == uint))   string size = "word";
            static if (is(T == ushort)) string size = "half";
            static if (is(T == ubyte))  string size = "byte";
            log!(LogSource.MEMORY)("Attempted to read a %s from an invalid region of memory: [0x%08x] = 0x%" ~ to!string(T.sizeof) ~ "x", size, address, cast(T) open_bus_value);
        }

        static if (is(T == uint  )) return cast(T) open_bus_value;
        static if (is(T == ushort)) return cast(T) (open_bus_value >> 16 * ((address >> 1) & 1));
        static if (is(T == ubyte )) return cast(T) (open_bus_value >> 8  * (address & 3));
    }

    enum DMACycleAccumulationState {
        ACCUMULATE, // accumulate cycles that the DMA is using that the CPU can later use to run idle cycles for "free"
        PAUSE,      // DMA is still running, but don't accumulate any more cycles. however, don't flush the accumulated cycles on memory access yet either
        REIMBURSE,  // DMA is no longer running. all idle cycles will decrement "accumulated_dma_cycles" and be spent for "free". flush accumulated cycles on mem access.
    }

    DMACycleAccumulationState dma_cycle_accumulation_state = DMACycleAccumulationState.REIMBURSE;
    uint accumulated_dma_cycles = 0;

    private template write(T) {
        void write(uint address, T value, AccessType access_type = AccessType.SEQUENTIAL, bool instruction_access = false) {
            if (dma_cycle_accumulation_state == DMACycleAccumulationState.REIMBURSE) accumulated_dma_cycles = 0;

            uint region = get_region(address);

            uint shift;
            static if (is(T == uint  )) shift = 2;
            static if (is(T == ushort)) shift = 1;
            static if (is(T == ubyte )) shift = 0;

            if (unlikely(address >> 28 > 0)) { // invalid write
                clock(1); // TODO: is this proper??
                scheduler.process_events();
                return;
            }

            // handle waitstates
            uint stalls = calculate_stalls_for_access!T(region, access_type);
            if (((address >> 24) & 0xF) < 8) clock(stalls);

            switch ((address >> 24) & 0xF) {
                case Region.BIOS:         break; // incorrect - implement properly later
                case 0x1:                 break; // nothing is mapped here
                case Region.WRAM_BOARD:   
                    (cast(T*) wram_board) [(address & (SIZE_WRAM_BOARD  - 1)) >> shift] = value; 
                    break;
                case Region.WRAM_CHIP:    
                    (cast(T*) wram_chip)  [(address & (SIZE_WRAM_CHIP   - 1)) >> shift] = value; 
                    
                    static if (is(T == uint)) { 
                        iwram_latch = value;
                    }

                    static if (is(T == ushort)) {
                        iwram_latch &= ~(0xFFFF     << (((address & 2) >> 1) * 16));
                        iwram_latch |=   value << (((address & 2) >> 1) * 16);
                    }

                    static if (is(T == ubyte))  {
                        iwram_latch &= ~(0xFF       << ((address & 3) * 8));
                        iwram_latch |=   value << ((address & 3) * 8);
                    }

                    break;
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

                    return;
                
                case Region.ROM_WAITSTATE_2_H:
                    writefln("Writing %x to ROM_WAITSTATE_2_H at %x", value, address);
                    if (backup.get_backup_type() == BackupType.EEPROM) {
                        backup.write_byte(address, value & 1);
                    }
                    break;

                case Region.ROM_SRAM_L:
                case Region.ROM_SRAM_H:
                    if (backup_enabled) {
                        static if (is(T == uint  )) return backup.write_word(address, value);
                        static if (is(T == ushort)) return backup.write_half(address, value);
                        static if (is(T == ubyte )) return backup.write_byte(address, value);
                    }
                    break;

                default:
                    uint aligned_address = (address & ~3); // TODO: check this???
                    static if (is(T == uint  )) prefetch_buffer.write!Word(aligned_address >> 1, value, access_type);
                    static if (is(T == ushort)) prefetch_buffer.write!Half(address         >> 1, value, access_type);
                    static if (is(T == ubyte )) break; // TODO: this too???????
            }

            scheduler.process_events();
        }
    }

    void clock(uint cycles) {
        prefetch_buffer.run(cycles);
        scheduler.tick(cycles);
        maybe_accumulate_dma_cycles(cycles);
    }

    void maybe_accumulate_dma_cycles(uint cycles) {
        if (dma_cycle_accumulation_state == DMACycleAccumulationState.ACCUMULATE) 
            accumulated_dma_cycles += cycles;
    }

    bool backup_enabled = false;
    Backup backup;

    void add_backup(Backup backup) {
        this.backup = backup;
        backup_enabled = backup.get_backup_type() != BackupType.NONE;
    }
    
    void finish_current_prefetch() {
        scheduler.tick(prefetch_buffer.cycles_till_access_complete);
        prefetch_buffer.finish_current_prefetch();
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

    pragma(inline, true) bool can_start_new_prefetch() {
        return prefetch_buffer.can_start_new_prefetch;
    }
}