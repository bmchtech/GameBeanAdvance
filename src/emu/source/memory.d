module memory;

import std.stdio;

import util;
import apu;
import mmio;

// for more details on the GBA memory map: https://problemkaputt.de/gbatek.htm#gbamemorymap
// i'm going to probably have to split this struct into more specific values later,
// but for now ill just do the ones i can see myself easily using.

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

        // manual overrides: TEMPORARY
        // TODO: remove when properly implemented
        // *DISPCNT = 6;
        // *SOUNDBIAS = 0x200;
        // write_halfword(0x4000130, 0x03FF);
    }

    // MUST BE CALLED BEFORE READ/WRITE TO 0x0400_0000 ARE ACCESSED!
    void set_mmio(MMIO mmio) {
        this.mmio = mmio;
    }

    // pragma(inline) uint mirror_to(uint original_address, uint mirror_location, uint mirror_size) {
    //     // modulo is oddly a lot slower. so we do this instead.

    //     while (original_address >= mirror_location + mirror_size) {
    //         original_address -= mirror_size;
    //     }

    //     while (original_address < mirror_location) {
    //         original_address += mirror_size;
    //     }

    //     return original_address;
    // }

    // pragma(inline) uint calculate_mirrors(uint address) {
    //     switch ((address & 0x0F00_0000) >> 24) { // which area in memory are we indexing from?
    //         case 0x2: return mirror_to(address, OFFSET_WRAM_BOARD,  0x40000);
    //         case 0x3: return mirror_to(address, OFFSET_WRAM_CHIP,   0x8000);
    //         case 0x5: return mirror_to(address, OFFSET_PALETTE_RAM, 0x400);
    //         case 0x6: 
    //             if (get_nth_bits(read_halfword(0x0400_0000), 0, 3) <= 2) {
    //                 if (address & 0x00FF0000) return mirror_to(address, OFFSET_VRAM + 0x10000, 0x8000);
    //             } else {
    //                 return mirror_to(address, OFFSET_VRAM, 0x20000);
    //             }

    //             return address;

    //         case 0x7: return mirror_to(address, OFFSET_OAM,         0x400);
    //         case 0xA: return mirror_to(address, OFFSET_ROM_1,       0x02000000);
    //         case 0xB: return mirror_to(address, OFFSET_ROM_1,       0x02000000);
    //         case 0xC: return mirror_to(address, OFFSET_ROM_1,       0x02000000);
    //         case 0xD: return mirror_to(address, OFFSET_ROM_1,       0x02000000);
    //         default:  return address;
    //     }
    // }

    ubyte read_byte(uint address) {
        return read_memory(address);
    }

    ushort read_halfword(uint address) {    
        return (cast(ushort) read_memory(address + 0) << 0) | 
               (cast(ushort) read_memory(address + 1) << 8);
    }

    uint read_word(uint address) {
        return (cast(uint) read_memory(address + 0) << 0)  |
               (cast(uint) read_memory(address + 1) << 8)  |
               (cast(uint) read_memory(address + 2) << 16) | 
               (cast(uint) read_memory(address + 3) << 24);
    }

    void write_byte(uint address, ubyte value) {
        write_memory(address, value);
    }

    void write_halfword(uint address, ushort value) {
        write_memory(address + 0, cast(ubyte)((value >> 0) & 0xff));
        write_memory(address + 1, cast(ubyte)((value >> 8) & 0xff));
    }

    void write_word(uint address, uint value) {
        write_memory(address + 0, cast(ubyte)((value >> 0)  & 0xff));
        write_memory(address + 1, cast(ubyte)((value >> 8)  & 0xff));
        write_memory(address + 2, cast(ubyte)((value >> 16) & 0xff));
        write_memory(address + 3, cast(ubyte)((value >> 24) & 0xff));
    }

    ubyte read_memory(uint address) {
        switch ((address >> 24) & 0xF) {
            case REGION_BIOS:         return bios       [address & (SIZE_BIOS        - 1)]; // incorrect - implement properly later
            case 0x1:                 return 0x0; // nothing is mapped here
            case REGION_WRAM_BOARD:   return wram_board [address & (SIZE_WRAM_BOARD  - 1)];
            case REGION_WRAM_CHIP:    return wram_chip  [address & (SIZE_WRAM_CHIP   - 1)];
            case REGION_IO_REGISTERS: return mmio.read(address);
            case REGION_PALETTE_RAM:  return palette_ram[address & (SIZE_PALETTE_RAM - 1)];
            case REGION_VRAM:         return vram       [address & (SIZE_VRAM        - 1)];
            case REGION_OAM:          return oam        [address & (SIZE_OAM         - 1)];

            default:
                // this is on its own because when waitstates are implemented, this is going
                // to get a lot more complicated
                return rom[address & (SIZE_ROM - 1)];
        }
    }

    void write_memory(uint address, ubyte value) {
        switch ((address >> 24) & 0xF) {
            case REGION_BIOS:         break; // cannot write to bios
            case 0x1:                 break; // nothing is mapped here
            case REGION_WRAM_BOARD:   wram_board [address & (SIZE_WRAM_BOARD  - 1)] = value; break;
            case REGION_WRAM_CHIP:    wram_chip  [address & (SIZE_WRAM_CHIP   - 1)] = value; break;
            case REGION_IO_REGISTERS: mmio.write(address, value); break;
            case REGION_PALETTE_RAM:  palette_ram[address & (SIZE_PALETTE_RAM - 1)] = value; break;
            case REGION_VRAM:         vram       [address & (SIZE_VRAM        - 1)] = value; break;
            case REGION_OAM:          oam        [address & (SIZE_OAM         - 1)] = value; break;

            default:
                // rom is read-only
                break;
        }
    }

    // trying a templated style of read/write, see how it goes.
    // things can be faster if theyre mem aligned, because you know the address falls into one region only
    // don't use for mmio yet
    template Aligned(T) {
        T read(uint address) {
                 static if (is(T == uint))   uint shift = 2;
            else static if (is(T == ushort)) uint shift = 1;
            else static if (is(T == ubyte))  uint shift = 0;
            else static assert(0, "Invalid read type given: expected uint, ushort, or ubyte");

            switch ((address >> 24) & 0xF) {
                case REGION_BIOS:         return ((cast(T*) bios       ) [(address & (SIZE_BIOS        - 1)) >> shift]); // incorrect - implement properly later
                case 0x1:                 return 0x0; // nothing is mapped here
                case REGION_WRAM_BOARD:   return ((cast(T*) wram_board ) [(address & (SIZE_WRAM_BOARD  - 1)) >> shift]);
                case REGION_WRAM_CHIP:    return ((cast(T*) wram_chip  ) [(address & (SIZE_WRAM_CHIP   - 1)) >> shift]);
                case REGION_PALETTE_RAM:  return ((cast(T*) palette_ram) [(address & (SIZE_PALETTE_RAM - 1)) >> shift]);
                case REGION_VRAM:         return ((cast(T*) vram       ) [(address & (SIZE_VRAM        - 1)) >> shift]);
                case REGION_OAM:          return ((cast(T*) oam        ) [(address & (SIZE_OAM         - 1)) >> shift]);

                case REGION_IO_REGISTERS: 
                    // static if (is(T == uint)) return 
                    //     (cast(uint) mmio.read(address + 0) << 0)  |
                    //     (cast(uint) mmio.read(address + 1) << 8)  |
                    //     (cast(uint) mmio.read(address + 2) << 16) | 
                    //     (cast(uint) mmio.read(address + 3) << 24);
                    // static if (is(T == ushort)) return 
                    //     (cast(ushort) mmio.read(address + 0) << 0)  |
                    //     (cast(ushort) mmio.read(address + 1) << 8);
                    // static if (is(T == ubyte))  return mmio.read(address);

                default:
                    // this is on its own because when waitstates are implemented, this is going
                    // to get a lot more complicated
                    return (cast(T*) rom) [(address & (SIZE_ROM - 1)) >> shift];
            }
        }

        void write(uint address, T value) {
                 static if (is(T == uint))   uint shift = 2;
            else static if (is(T == ushort)) uint shift = 1;
            else static if (is(T == ubyte))  uint shift = 0;
            else static assert(0, "Invalid read type given: expected uint, ushort, or ubyte");

            switch ((address >> 24) & 0xF) {
                case REGION_BIOS:         break; // incorrect - implement properly later
                case 0x1:                 break; // nothing is mapped here
                case REGION_WRAM_BOARD:   ((cast(T*) wram_board ) [(address & (SIZE_WRAM_BOARD  - 1)) >> shift]) = value; break;
                case REGION_WRAM_CHIP:    ((cast(T*) wram_chip  ) [(address & (SIZE_WRAM_CHIP   - 1)) >> shift]) = value; break;
                case REGION_PALETTE_RAM:  ((cast(T*) palette_ram) [(address & (SIZE_PALETTE_RAM - 1)) >> shift]) = value; break;
                case REGION_VRAM:         ((cast(T*) vram       ) [(address & (SIZE_VRAM        - 1)) >> shift]) = value; break;
                case REGION_OAM:          ((cast(T*) oam        ) [(address & (SIZE_OAM         - 1)) >> shift]) = value; break;

                case REGION_IO_REGISTERS:
                    // static if (is(T == uint)) {  
                    //     mmio.write(address | 0, (value >>  0) & 0xFF);
                    //     mmio.write(address | 1, (value >>  8) & 0xFF);
                    //     mmio.write(address | 2, (value >> 16) & 0xFF); 
                    //     mmio.write(address | 3, (value >> 24) & 0xFF);
                    // } else static if (is(T == ushort)) { 
                    //     mmio.write(address | 0, (value >>  0) & 0xFF);
                    //     mmio.write(address | 1, (value >>  8) & 0xFF);
                    // } else static if (is(T == ubyte))  {
                    //     mmio.write(address, value);
                    // }

                    break;

                default:
                    break;
            }
        }
    }
    // ubyte read_byte(uint address) {
    //     address = calculate_mirrors(address);

    //     if ((address & 0xFFFF0000) == 0x4000000)
    //         mixin(VERBOSE_LOG!(`2`,
    //                 `format("Reading byte from address %s", to_hex_string(address))`));
    //     if (cast(ulong)address >= SIZE_MAIN_MEMORY) {
    //         error(format("Address out of range on read byte %s", to_hex_string(address) ~ ")"));
    //         return 0;
    //     }
    //     // if (address == 0x030014d0) writefln("Read byte from %08x", address);
    //     return read_memory(address);
    // }

    // ushort read_halfword(uint address) {
    //     address = calculate_mirrors(address);

    //     if ((address & 0xFFFF0000) == 0x4000000)
    //         mixin(VERBOSE_LOG!(`2`,
    //                 `format("Reading halfword from address %s", to_hex_string(address))`));
    //     if (cast(ulong)address + 2 >= SIZE_MAIN_MEMORY) {
    //         error(format("Address out of range on read halfword %s", to_hex_string(address) ~ ")"));
    //         return 0;
    //     }
    //     // if (address == 0x030014d0) writefln("Read halfword from %08x", address);
    //     return (cast(ushort) read_memory(address + 0) << 0) | 
    //            (cast(ushort) read_memory(address + 1) << 8);
    // }

    // uint read_word(uint address) {
    //     address = calculate_mirrors(address);

    //     if ((address & 0xFFFF0000) == 0x4000000)
    //         mixin(VERBOSE_LOG!(`2`,
    //                 `format("Reading word from address %s", to_hex_string(address))`));
    //     if (cast(ulong)address + 4 >= SIZE_MAIN_MEMORY) {
    //         error(format("Address out of range on read word %s", to_hex_string(address) ~ ")"));
    //         return 0;
    //     }
    //     // if (address == 0x030014d0) writefln("Read word from %08x", address);
    //     return (cast(uint) read_memory(address + 0) << 0)  |
    //            (cast(uint) read_memory(address + 1) << 8)  |
    //            (cast(uint) read_memory(address + 2) << 16) | 
    //            (cast(uint) read_memory(address + 3) << 24);
    // }

    // void write_byte(uint address, ubyte value) {
    //     address = calculate_mirrors(address);

    //     if (((address & 0x0F00_0000) >> 24) == 0x7) return; // we ignore write bytes to OAM.

    //     if (((address & 0x0F00_0000) >> 24) == 0x5) {
    //         // writes to palette as byte are treated as halfword. look, i don't make the rules, nintendo did.
    //         // (so like, writing 0x3 to palette[0x10] would write 0x3 to palette[0x10] and palette[0x11])
    //         write_halfword(address, ((cast(ushort) value) << 8) | (cast(ushort) value));
    //     }

    //     if (((address & 0x0F00_0000) >> 24) == 0x6) {
    //         if (get_nth_bits(read_halfword(0x0400_0000), 0, 3) <= 2) {
    //             if (get_nth_bit(address, 16) && !get_nth_bits(address, 14, 16)) // if address > 0x0601_4000
    //                 return; // we ignore write bytes to VRAM OBJ data when we're not in a BITMAP MODE.
    //         } else {
    //             // again, writes to VRAM as byte are treated as halfword. (scroll up a few lines for explanation)
    //             write_halfword(address, ((cast(ushort) value) << 8) | (cast(ushort) value));
    //         }
    //     }


    //     // if (address > 0x08000000) error("Attempt to write to ROM! " ~ to_hex_string(address));
    //     // if ((address & 0xFFFF0000) == 0x6000000)
    //     //     mixin(VERBOSE_LOG!(`2`, `format("Writing byte %s to address %s",
    //     //             to_hex_string(value), to_hex_string(address))`));
    //     if (cast(ulong)address >= SIZE_MAIN_MEMORY)
    //         error(format("Address out of range on write byte %s", to_hex_string(address) ~ ")"));
    //     // main[address] = value;
    //     write_memory(address + 0, cast(ubyte)((value >> 0) & 0xff));
    //     // if ((address & 0xFFFFF000) == 0x4000000) writefln("Wrote byte %02x to %x", value, address);
    //     // if (address == 0x0821dbb8) writefln("Wrote byte %08x to %x", value, address);
    //     // if ((address & 0xFF000000) == 0x0000000) warning("ATTEMPT TO OVERWRITE BIOS!!!");
    //     // if ((address & 0xFF000000) == 0x6000000) writefln("Wrote byte %02x to %x", value, address);
    //     // writefln("Wrote byte %08x to %x", value, address);
    // }

    // void write_halfword(uint address, ushort value) {
    //     address = calculate_mirrors(address);

    //     // if (address > 0x08000000) error("Attempt to write to ROM! " ~ to_hex_string(address));
    //     // if ((address & 0xFFFF0000) == 0x6000000)
    //     //     mixin(VERBOSE_LOG!(`2`, `format("Writing halfword %s to address %s",
    //     //             to_hex_string(value), to_hex_string(address))`));
    //     if (cast(ulong)address + 2 >= SIZE_MAIN_MEMORY)
    //         error(format("Address out of range on write halfword %s", to_hex_string(address) ~ ")"));
    //     // *(cast(ushort*) (main[0] + address)) = value;
    //     write_memory(address + 0, cast(ubyte)((value >> 0) & 0xff));
    //     write_memory(address + 1, cast(ubyte)((value >> 8) & 0xff));
    //     // if ((address & 0xFFFFF000) == 0x4 000000) writefln("Wrote halfword %04x to %x", value, address);
    //     // if (address == 0x0821dbb8) writefln("Wrote halfword %08x to %x", value, address);
    //     // if ((address & 0xFF000000) == 0x0000000) warning("ATTEMPT TO OVERWRITE BIOS!!!");
    //     // if ((address & 0xFF000000) == 0x6000000) writefln("Wrote halfword %04x to %x", value, address);
    //     // writefln("Wrote halfword %08x to %x", value, address);

    //     // if (address == 0x0500_0000) writefln("%x", value);
    // }

    // void write_word(uint address, uint value) {
    //     address = calculate_mirrors(address);

    //     // if (address > 0x08000000) error("Attempt to write to ROM! " ~ to_hex_string(address));
    //     // if ((address & 0xFFFF0000) == 0x6000000)
    //     //     mixin(VERBOSE_LOG!(`2`, `format("Writing word %s to address %s",
    //     //             to_hex_string(value), to_hex_string(address))`));
    //     if (cast(ulong)address + 4 >= SIZE_MAIN_MEMORY)
    //         error(format("Address out of range on write word %s", to_hex_string(address) ~ ")"));
    //     // *(cast(uint*) (main[0] + address)) = value;
    //     write_memory(address + 0, cast(ubyte)((value >> 0)  & 0xff));
    //     write_memory(address + 1, cast(ubyte)((value >> 8)  & 0xff));
    //     write_memory(address + 2, cast(ubyte)((value >> 16) & 0xff));
    //     write_memory(address + 3, cast(ubyte)((value >> 24) & 0xff));
    //     // if ((address & 0xFFFFF000) == 0x4000000) if (address != 0x040000a0) writefln("Wrote word %08x to %x", value, address);
    //     // if (address == 0x0821dbb8) writefln("Wrote word %08x to %x", value, address);
    //     // if ((address & 0xFF000000) == 0x0000000) warning("ATTEMPT TO OVERWRITE BIOS!!!");
    //     // if ((address & 0xFF000000) == 0x6000000) writefln("Wrote word %08x to %x", value, address);
    //     // writefln("Wrote word %08x to %x", value, address);
    // }

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