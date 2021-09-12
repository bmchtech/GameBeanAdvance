module hw.memory.memory;

import hw.apu;
import hw.memory;
import hw.cpu;
import hw.ppu;

import util;

import std.stdio;

Memory memory;

// assume abbreviation "ws" = "waitstate" because these lines are getting long
// N and S stand for nonsequential and sequential look, i love using verbose 
// variable names, but in this case the lines will simply be too long to understand

class Memory {
    bool has_updated = false;

    ubyte[] pixels;
    /** video buffer in RGBA8888 */
    uint[][] video_buffer;

    // audio fifos
    Fifo!ubyte fifo_a;
    Fifo!ubyte fifo_b;

    MMIO mmio;

    ubyte[] bios;
    ubyte[] wram_board;
    ubyte[] wram_chip;
    ubyte[] palette_ram;
    ubyte[] vram;
    ubyte[] oam;
    ubyte[] rom;

    enum Region {
        BIOS              = 0x0,
        WRAM_BOARD        = 0x2,
        WRAM_CHIP         = 0x3,
        IO_REGISTERS      = 0x4,
        PALETTE_RAM       = 0x5,
        VRAM              = 0x6,
        OAM               = 0x7,

        ROM_WAITSTATE_0_L = 0x8,
        ROM_WAITSTATE_0_H = 0x9,
        ROM_WAITSTATE_1_L = 0xA,
        ROM_WAITSTATE_1_H = 0xB,
        ROM_WAITSTATE_2_L = 0xC,
        ROM_WAITSTATE_2_H = 0xD,
        ROM_SRAM_L        = 0xE,
        ROM_SRAM_H        = 0xF,
    }

    enum SIZE_BIOS           = 0x4000;
    enum SIZE_WRAM_BOARD     = 0x40000;
    enum SIZE_WRAM_CHIP      = 0x8000;
    enum SIZE_PALETTE_RAM    = 0x400;
    enum SIZE_VRAM           = 0x20000; // its actually 0x18000, but this tiny change makes it easy to bitmask for mirroring
    enum SIZE_OAM            = 0x400;
    enum SIZE_ROM            = 0x2000000;

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

    bool can_read_from_bios = false;

    enum OpenBusBiosState {
        STARTUP,
        SOFT_RESET,
        DURING_IRQ,
        AFTER_IRQ,
        AFTER_SWI
    }
    OpenBusBiosState open_bus_bios_state = OpenBusBiosState.STARTUP;

    enum AccessType {
        NONSEQUENTIAL = 0,
        SEQUENTIAL    = 1
    }

    enum AccessSize {
        BYTE     = 0,
        HALFWORD = 1,
        WORD     = 2
    }

    // the number of cycles to idle on a given memory access is given by
    // waitstates[memory region][access type][byte = 0 | halfword = 1 | word = 2]

    int[3][2][16] waitstates = [
        [[1, 1, 1], [1, 1, 1]], // BIOS
        [[0, 0, 0], [0, 0, 0]], // Invalid
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
                break;
            
            case 0b1:
                int ws_2_N  = (cast(int[]) [4, 3, 2, 8])[get_nth_bits(data, 0, 2)];
                int ws_2_S  = (cast(int[]) [8, 1])      [get_nth_bit (data, 2)];

                set_waitstate_ROM(2, ws_2_N, ws_2_S);
                break;
        }
    }

    // waitstate_region is one of: 0, 1, 2
    void set_waitstate_ROM(int ws_region, int ws_N, int ws_S) {
        int rom_region = Region.ROM_WAITSTATE_0_L + ws_region * 2;

        waitstates[rom_region][AccessType.NONSEQUENTIAL][AccessSize.BYTE    ] = ws_N + 1;
        waitstates[rom_region][AccessType.NONSEQUENTIAL][AccessSize.HALFWORD] = ws_N + 1;
        waitstates[rom_region][AccessType.NONSEQUENTIAL][AccessSize.WORD    ] = ws_N + 1 + ws_S + 1;

        waitstates[rom_region][AccessType.SEQUENTIAL   ][AccessSize.BYTE    ] = ws_S + 1;
        waitstates[rom_region][AccessType.SEQUENTIAL   ][AccessSize.HALFWORD] = ws_S + 1;
        waitstates[rom_region][AccessType.SEQUENTIAL   ][AccessSize.WORD    ] = ws_S + 1 + ws_S + 1;
    }

    uint bios_open_bus_latch;

    import std.conv;

    uint read_bios_open_bus() {
        writefln("Reading from BIOS as state %s", std.conv.to!string(open_bus_bios_state));

        final switch (open_bus_bios_state) {
            case OpenBusBiosState.STARTUP:    return 0;
            case OpenBusBiosState.SOFT_RESET: return 0;

            case OpenBusBiosState.DURING_IRQ: return 0xE25EF004;
            case OpenBusBiosState.AFTER_IRQ:  return 0xE55EC002;
            case OpenBusBiosState.AFTER_SWI:  return 0xE3A02004;
        }
    }

    this() {
        video_buffer = new uint[][](240, 160);
        fifo_a = new Fifo!ubyte(0x20, 0x00);
        fifo_b = new Fifo!ubyte(0x20, 0x00);

        this.mmio = null;

        this.bios        = new ubyte[SIZE_BIOS];
        this.wram_board  = new ubyte[SIZE_WRAM_BOARD];
        this.wram_chip   = new ubyte[SIZE_WRAM_CHIP];
        this.palette_ram = new ubyte[SIZE_PALETTE_RAM];
        this.vram        = new ubyte[SIZE_VRAM];
        this.oam         = new ubyte[SIZE_OAM];
        this.rom         = new ubyte[SIZE_ROM];

        memory = this;
    }

    // MUST BE CALLED BEFORE READ/WRITE TO 0x0400_0000 ARE ACCESSED!
    void set_mmio(MMIO mmio) {
        this.mmio = mmio;
    }

    pragma(inline, true) ubyte read_byte(uint address, AccessType access_type = AccessType.SEQUENTIAL) {
        return read!ubyte(address, access_type);
    }

    pragma(inline, true) ushort read_halfword(uint address, AccessType access_type = AccessType.SEQUENTIAL) {    
        return read!ushort(address, access_type);
    }

    pragma(inline, true) uint read_word(uint address, AccessType access_type = AccessType.SEQUENTIAL) {
        return read!uint(address, access_type);
    }

    pragma(inline, true) void write_byte(uint address, ubyte value, AccessType access_type = AccessType.SEQUENTIAL) {
        write!ubyte(address, value, access_type);
    }

    pragma(inline, true) void write_halfword(uint address, ushort value, AccessType access_type = AccessType.SEQUENTIAL) {
        write!ushort(address, value, access_type);
    }

    pragma(inline, true) void write_word(uint address, uint value, AccessType access_type = AccessType.SEQUENTIAL) {
        write!uint(address, value, access_type);
    }

    uint bios_open_bus_latch = 0;

    private template read(T) {
        pragma(inline, true) T read(uint address, AccessType access_type = AccessType.SEQUENTIAL) {
            uint region = (address >> 24) & 0xF;

            // handle waitstates
            static if (is(T == uint  )) _g_cpu_cycles_remaining += waitstates[region][access_type][AccessSize.WORD];
            static if (is(T == ushort)) _g_cpu_cycles_remaining += waitstates[region][access_type][AccessSize.HALFWORD];
            static if (is(T == ubyte )) _g_cpu_cycles_remaining += waitstates[region][access_type][AccessSize.BYTE];

            switch (region) {
                case 0x1:                 return 0x0; // nothing is mapped here
                case Region.WRAM_BOARD:   return *((cast(T*) (&wram_board[0]  + (address & (SIZE_WRAM_BOARD  - 1)))));
                case Region.WRAM_CHIP:    return *((cast(T*) (&wram_chip[0]   + (address & (SIZE_WRAM_CHIP   - 1)))));
                case Region.PALETTE_RAM:  return *((cast(T*) (&palette_ram[0] + (address & (SIZE_PALETTE_RAM - 1)))));
                case Region.VRAM:         return *((cast(T*) (&vram[0]        + (address % SIZE_VRAM))));
                case Region.OAM:          return *((cast(T*) (&oam[0]         + (address & (SIZE_OAM         - 1)))));

                case Region.IO_REGISTERS:
                    static if (is(T == uint)) return 
                        (cast(uint) mmio.read(address + 0) << 0)  |
                        (cast(uint) mmio.read(address + 1) << 8)  |
                        (cast(uint) mmio.read(address + 2) << 16) | 
                        (cast(uint) mmio.read(address + 3) << 24);
                    static if (is(T == ushort)) return 
                        (cast(ushort) mmio.read(address + 0) << 0)  |
                        (cast(ushort) mmio.read(address + 1) << 8);
                    static if (is(T == ubyte))  return mmio.read(address);

                case Region.BIOS: 
                    if (can_read_from_bios) {
                        uint word_aligned_address = address & ~3;

                        bios_open_bus_latch = *((cast(uint*) (&bios[0] + (word_aligned_address & ~3 & (SIZE_BIOS - 1)))));

                        static if (is(T == uint))   return (bios_open_bus_latch);
                        static if (is(T == ushort)) return (bios_open_bus_latch >> (16 * ((address >> 1) & 1))) & 0xFFFF;
                        static if (is(T == ubyte))  return (bios_open_bus_latch >> (8  * ((address >> 1) & 3))) & 0xFF;
                    } else {
                    
                        // writefln("OPEN BUS: %x", bios_open_bus_latch);
                        static if (is(T == uint  )) return bios_open_bus_latch;
                        static if (is(T == ushort)) return bios_open_bus_latch & 0xFFFF;
                        static if (is(T == ubyte )) return bios_open_bus_latch & 0xFF;
                    }

                default:
                    return *((cast(T*) (&rom[0] + (address & (SIZE_ROM - 1)))));
            }
        }
    }

    private template write(T) {
        pragma(inline, true) void write(uint address, T value, AccessType access_type = AccessType.SEQUENTIAL) {
            uint region = (address >> 24) & 0xF;

            // handle waitstates
            static if (is(T == uint  )) _g_cpu_cycles_remaining += waitstates[region][access_type][AccessSize.WORD];
            static if (is(T == ushort)) _g_cpu_cycles_remaining += waitstates[region][access_type][AccessSize.HALFWORD];
            static if (is(T == ubyte )) _g_cpu_cycles_remaining += waitstates[region][access_type][AccessSize.BYTE];

            switch ((address >> 24) & 0xF) {
                case Region.BIOS:         break; // incorrect - implement properly later
                case 0x1:                 break; // nothing is mapped here
                case Region.WRAM_BOARD:   *(cast(T*) (&wram_board[0]  + (address & (SIZE_WRAM_BOARD  - 1)))) = value; break;
                case Region.WRAM_CHIP:    *(cast(T*) (&wram_chip[0]   + (address & (SIZE_WRAM_CHIP   - 1)))) = value; break;
                case Region.PALETTE_RAM:  
                    *(cast(T*) (&palette_ram[0] + (address & (SIZE_PALETTE_RAM - 1)))) = value; 
                    uint index = (address & (SIZE_PALETTE_RAM - 1)) >> 1;

                    static if (is(T == uint)) {
                        hw.ppu.palette.set_color(index,     cast(ushort) (value & 0xFFFF));
                        hw.ppu.palette.set_color(index + 1, cast(ushort) (value >> 16));
                    } else static if (is(T == ushort)) {
                        hw.ppu.palette.set_color(index, value);
                    } else static if (is(T == ubyte)) {
                        hw.ppu.palette.set_color(index, value | (value << 8));
                    }
                    break;

                case Region.VRAM:         *(cast(T*) (&vram[0]        + (address % SIZE_VRAM)))              = value; break;
                case Region.OAM:          *(cast(T*) (&oam[0]         + (address & (SIZE_OAM         - 1)))) = value; break;

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

                default:
                    break;
            }
        }
    }

    void set_rgb(uint x, uint y, ubyte r, ubyte g, ubyte b) {
        video_buffer[x][y] = (r << 24) | (g << 16) | (b << 8) | (0xff);
    }
}