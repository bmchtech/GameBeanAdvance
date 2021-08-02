module memory;

import std.stdio;

import util;
import apu;
import mmio;
import cpu;

Memory memory;

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

    enum SIZE_BIOS           = 0x4000;
    enum SIZE_WRAM_BOARD     = 0x40000;
    enum SIZE_WRAM_CHIP      = 0x8000;
    enum SIZE_PALETTE_RAM    = 0x400;
    enum SIZE_VRAM           = 0x20000; // its actually 0x18000, but this tiny change makes it easy to bitmask for mirroring
    enum SIZE_OAM            = 0x400;
    enum SIZE_ROM            = 0x2000000;

    enum REGION_BIOS         = 0x0;
    enum REGION_WRAM_BOARD   = 0x2;
    enum REGION_WRAM_CHIP    = 0x3;
    enum REGION_IO_REGISTERS = 0x4;
    enum REGION_PALETTE_RAM  = 0x5;
    enum REGION_VRAM         = 0x6;
    enum REGION_OAM          = 0x7;

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

    ubyte read_byte(uint address) {
        return Aligned!(ubyte).read(address);
    }

    ushort read_halfword(uint address) {    
        return Aligned!(ushort).read(address);
    }

    uint read_word(uint address) {
        return Aligned!(uint).read(address);
    }

    void write_byte(uint address, ubyte value) {
        return Aligned!(ubyte).write(address, value);
    }

    void write_halfword(uint address, ushort value) {
        return Aligned!(ushort).write(address, value);
    }

    void write_word(uint address, uint value) {
        return Aligned!(uint).write(address, value);
    }

    // trying a templated style of read/write, see how it goes.
    // things can be faster if theyre mem aligned, because you know the address falls into one region only
    // don't use for mmio yet
    template Aligned(T) {
        T read(uint address) {
            switch ((address >> 24) & 0xF) {
                case REGION_BIOS:         return *((cast(T*) (&bios[0]        + (address & (SIZE_BIOS        - 1))))); // incorrect - implement properly later
                case 0x1:                 return 0x0; // nothing is mapped here
                case REGION_WRAM_BOARD:   return *((cast(T*) (&wram_board[0]  + (address & (SIZE_WRAM_BOARD  - 1)))));
                case REGION_WRAM_CHIP:    return *((cast(T*) (&wram_chip[0]   + (address & (SIZE_WRAM_CHIP   - 1)))));
                case REGION_PALETTE_RAM:  return *((cast(T*) (&palette_ram[0] + (address & (SIZE_PALETTE_RAM - 1)))));
                case REGION_VRAM:         return *((cast(T*) (&vram[0]        + (address & (SIZE_VRAM        - 1)))));
                case REGION_OAM:          return *((cast(T*) (&oam[0]         + (address & (SIZE_OAM         - 1)))));

                case REGION_IO_REGISTERS:
                    static if (is(T == uint)) return 
                        (cast(uint) mmio.read(address + 0) << 0)  |
                        (cast(uint) mmio.read(address + 1) << 8)  |
                        (cast(uint) mmio.read(address + 2) << 16) | 
                        (cast(uint) mmio.read(address + 3) << 24);
                    static if (is(T == ushort)) return 
                        (cast(ushort) mmio.read(address + 0) << 0)  |
                        (cast(ushort) mmio.read(address + 1) << 8);
                    static if (is(T == ubyte))  return mmio.read(address);

                default:
                    // this is on its own because when waitstates are implemented, this is going
                    // to get a lot more complicated
                    return *((cast(T*) (&rom[0] + (address & (SIZE_ROM - 1)))));
            }
        }

        void write(uint address, T value) {
            if ((address & 0xFFFF0000) == 0x06000000) { writefln("Wrote %x to %x", value, address); }
            switch ((address >> 24) & 0xF) {
                case REGION_BIOS:         break; // incorrect - implement properly later
                case 0x1:                 break; // nothing is mapped here
                case REGION_WRAM_BOARD:   *(cast(T*) (&wram_board[0]  + (address & (SIZE_WRAM_BOARD  - 1)))) = value; break;
                case REGION_WRAM_CHIP:    *(cast(T*) (&wram_chip[0]   + (address & (SIZE_WRAM_CHIP   - 1)))) = value; break;
                case REGION_PALETTE_RAM:  *(cast(T*) (&palette_ram[0] + (address & (SIZE_PALETTE_RAM - 1)))) = value; break;
                case REGION_VRAM:         *(cast(T*) (&vram[0]        + (address & (SIZE_VRAM        - 1)))) = value; break;
                case REGION_OAM:          *(cast(T*) (&oam[0]         + (address & (SIZE_OAM         - 1)))) = value; break;

                case REGION_IO_REGISTERS: 
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
        auto p = (r << 24) | (g << 16) | (b << 8) | (0xff);
        mixin(VERBOSE_LOG!(`4`,
                `format("SETRGB (%s,%s) = [%s, %s, %s] = %00000000x", x, y, r, g, b, p)`));
        video_buffer[x][y] = p;
    }

    void set_key(ubyte code, bool pressed) {
        // assert(code >= 0 && code < 10, "invalid gba key code");
        // mixin(VERBOSE_LOG!(`2`, `format("KEY (%s) = %s", code, pressed)`));

        // if (pressed) {
        //     *KEYINPUT &= ~(0b1 << code);
        // } else {
        //     *KEYINPUT |= (0b1 << code);
        // }
    }
}