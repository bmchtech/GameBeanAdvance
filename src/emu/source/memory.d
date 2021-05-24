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
    ubyte[] main;
    /** video buffer in RGBA8888 */
    uint[][] video_buffer;

    // audio fifos
    Fifo!ubyte fifo_a;
    Fifo!ubyte fifo_b;

    MMIO mmio;

    enum SIZE_MAIN_MEMORY    = 0x10000000;
    enum SIZE_BIOS           = 0x0003FFF - 0x0000000;
    enum SIZE_WRAM_BOARD     = 0x203FFFF - 0x2000000;
    enum SIZE_WRAM_CHIP      = 0x3007FFF - 0x3000000;
    enum SIZE_IO_REGISTERS   = 0x40003FE - 0x4000000;
    enum SIZE_PALETTE_RAM    = 0x50003FF - 0x5000000;
    enum SIZE_VRAM           = 0x6017FFF - 0x6000000;
    enum SIZE_OAM            = 0x70003FF - 0x7000000;
    enum SIZE_ROM_1          = 0x9FFFFFF - 0x8000000;
    enum SIZE_ROM_2          = 0xBFFFFFF - 0xA000000;
    enum SIZE_ROM_3          = 0xDFFFFFF - 0xC000000;
    enum SIZE_SRAM           = 0xE00FFFF - 0xE000000;

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
        main = new ubyte[SIZE_MAIN_MEMORY];
        video_buffer = new uint[][](240, 160);
        fifo_a = new Fifo!ubyte(0x20, 0x00);
        fifo_b = new Fifo!ubyte(0x20, 0x00);

        this.mmio = null;

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

    pragma(inline) uint mirror_to(uint original_address, uint mirror_location, uint mirror_size) {
        // modulo is oddly a lot slower. so we do this instead.

        while (original_address >= mirror_location + mirror_size) {
            original_address -= mirror_size;
        }

        while (original_address < mirror_location) {
            original_address += mirror_size;
        }

        return original_address;
    }

    pragma(inline) uint calculate_mirrors(uint address) {
        switch ((address & 0x0F00_0000) >> 24) { // which area in memory are we indexing from?
            case 0x2: return mirror_to(address, OFFSET_WRAM_BOARD,  0x40000);
            case 0x3: return mirror_to(address, OFFSET_WRAM_CHIP,   0x8000);
            case 0x5: return mirror_to(address, OFFSET_PALETTE_RAM, 0x400);
            case 0x6: 
                if (get_nth_bits(read_halfword(0x0400_0000), 0, 3) <= 2) {
                    if (address & 0x00FF0000) return mirror_to(address, OFFSET_VRAM + 0x10000, 0x8000);
                } else {
                    return mirror_to(address, OFFSET_VRAM, 0x20000);
                }

                return address;

            case 0x7: return mirror_to(address, OFFSET_OAM,         0x400);
            case 0xA: return mirror_to(address, OFFSET_ROM_1,       0x02000000);
            case 0xB: return mirror_to(address, OFFSET_ROM_1,       0x02000000);
            case 0xC: return mirror_to(address, OFFSET_ROM_1,       0x02000000);
            case 0xD: return mirror_to(address, OFFSET_ROM_1,       0x02000000);
            default:  return address;
        }
    }

    ubyte read_byte(uint address) {
        address = calculate_mirrors(address);

        if ((address & 0xFFFF0000) == 0x4000000)
            mixin(VERBOSE_LOG!(`2`,
                    `format("Reading byte from address %s", to_hex_string(address))`));
        if (cast(ulong)address >= SIZE_MAIN_MEMORY) {
            warning(format("Address out of range on read byte %s", to_hex_string(address) ~ ")"));
            return 0;
        }
        // if (address == 0x030014d0) writefln("Read byte from %08x", address);
        return read_memory(address);
    }

    ushort read_halfword(uint address) {
        address = calculate_mirrors(address);

        if ((address & 0xFFFF0000) == 0x4000000)
            mixin(VERBOSE_LOG!(`2`,
                    `format("Reading halfword from address %s", to_hex_string(address))`));
        if (cast(ulong)address + 2 >= SIZE_MAIN_MEMORY) {
            warning(format("Address out of range on read halfword %s", to_hex_string(address) ~ ")"));
            return 0;
        }
        // if (address == 0x030014d0) writefln("Read halfword from %08x", address);
        return (cast(ushort) read_memory(address + 0) << 0) | 
               (cast(ushort) read_memory(address + 1) << 8);
    }

    uint read_word(uint address) {
        address = calculate_mirrors(address);

        if ((address & 0xFFFF0000) == 0x4000000)
            mixin(VERBOSE_LOG!(`2`,
                    `format("Reading word from address %s", to_hex_string(address))`));
        if (cast(ulong)address + 4 >= SIZE_MAIN_MEMORY) {
            warning(format("Address out of range on read word %s", to_hex_string(address) ~ ")"));
            return 0;
        }
        // if (address == 0x030014d0) writefln("Read word from %08x", address);
        return (cast(uint) read_memory(address + 0) << 0)  |
               (cast(uint) read_memory(address + 1) << 8)  |
               (cast(uint) read_memory(address + 2) << 16) | 
               (cast(uint) read_memory(address + 3) << 24);
    }

    void write_byte(uint address, ubyte value) {
        address = calculate_mirrors(address);

        if (((address & 0x0F00_0000) >> 24) == 0x7) return; // we ignore write bytes to OAM.

        if (((address & 0x0F00_0000) >> 24) == 0x5) {
            // writes to palette as byte are treated as halfword. look, i don't make the rules, nintendo did.
            // (so like, writing 0x3 to palette[0x10] would write 0x3 to palette[0x10] and palette[0x11])
            write_halfword(address, ((cast(ushort) value) << 8) | (cast(ushort) value));
        }

        if (((address & 0x0F00_0000) >> 24) == 0x6) {
            if (get_nth_bits(read_halfword(0x0400_0000), 0, 3) <= 2) {
                if (get_nth_bit(address, 16) && !get_nth_bits(address, 14, 16)) // if address > 0x0601_4000
                    return; // we ignore write bytes to VRAM OBJ data when we're not in a BITMAP MODE.
            } else {
                // again, writes to VRAM as byte are treated as halfword. (scroll up a few lines for explanation)
                write_halfword(address, ((cast(ushort) value) << 8) | (cast(ushort) value));
            }
        }


        // if (address > 0x08000000) warning("Attempt to write to ROM!" ~ to_hex_string(address));
        // if ((address & 0xFFFF0000) == 0x6000000)
        //     mixin(VERBOSE_LOG!(`2`, `format("Writing byte %s to address %s",
        //             to_hex_string(value), to_hex_string(address))`));
        if (cast(ulong)address >= SIZE_MAIN_MEMORY)
            warning(format("Address out of range on write byte %s", to_hex_string(address) ~ ")"));
        // main[address] = value;
        write_memory(address + 0, cast(ubyte)((value >> 0) & 0xff));
        // if ((address & 0xFFFFF000) == 0x4000000) writefln("Wrote byte %02x to %x", value, address);
        // if (address == 0x0821dbb8) writefln("Wrote byte %08x to %x", value, address);
        // if ((address & 0xFF000000) == 0x0000000) error("ATTEMPT TO OVERWRITE BIOS!!!");
        // if ((address & 0xFF000000) == 0x6000000) writefln("Wrote byte %02x to %x", value, address);
        // writefln("Wrote byte %08x to %x", value, address);
    }

    void write_halfword(uint address, ushort value) {
        address = calculate_mirrors(address);

        // if (address > 0x08000000) warning("Attempt to write to ROM!" ~ to_hex_string(address));
        // if ((address & 0xFFFF0000) == 0x6000000)
        //     mixin(VERBOSE_LOG!(`2`, `format("Writing halfword %s to address %s",
        //             to_hex_string(value), to_hex_string(address))`));
        if (cast(ulong)address + 2 >= SIZE_MAIN_MEMORY)
            warning(format("Address out of range on write halfword %s", to_hex_string(address) ~ ")"));
        // *(cast(ushort*) (main[0] + address)) = value;
        write_memory(address + 0, cast(ubyte)((value >> 0) & 0xff));
        write_memory(address + 1, cast(ubyte)((value >> 8) & 0xff));
        // if ((address & 0xFFFFF000) == 0x4 000000) writefln("Wrote halfword %04x to %x", value, address);
        // if (address == 0x0821dbb8) writefln("Wrote halfword %08x to %x", value, address);
        // if ((address & 0xFF000000) == 0x0000000) error("ATTEMPT TO OVERWRITE BIOS!!!");
        // if ((address & 0xFF000000) == 0x6000000) writefln("Wrote halfword %04x to %x", value, address);
        // writefln("Wrote halfword %08x to %x", value, address);
    }

    void write_word(uint address, uint value) {
        address = calculate_mirrors(address);

        // if (address > 0x08000000) warning("Attempt to write to ROM!" ~ to_hex_string(address));
        // if ((address & 0xFFFF0000) == 0x6000000)
        //     mixin(VERBOSE_LOG!(`2`, `format("Writing word %s to address %s",
        //             to_hex_string(value), to_hex_string(address))`));
        if (cast(ulong)address + 4 >= SIZE_MAIN_MEMORY)
            warning(format("Address out of range on write word %s", to_hex_string(address) ~ ")"));
        // *(cast(uint*) (main[0] + address)) = value;
        write_memory(address + 0, cast(ubyte)((value >> 0)  & 0xff));
        write_memory(address + 1, cast(ubyte)((value >> 8)  & 0xff));
        write_memory(address + 2, cast(ubyte)((value >> 16) & 0xff));
        write_memory(address + 3, cast(ubyte)((value >> 24) & 0xff));
        // if ((address & 0xFFFFF000) == 0x4000000) if (address != 0x040000a0) writefln("Wrote word %08x to %x", value, address);
        // if (address == 0x0821dbb8) writefln("Wrote word %08x to %x", value, address);
        // if ((address & 0xFF000000) == 0x0000000) error("ATTEMPT TO OVERWRITE BIOS!!!");
        // if ((address & 0xFF000000) == 0x6000000) writefln("Wrote word %08x to %x", value, address);
        // writefln("Wrote word %08x to %x", value, address);
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

private:
    ubyte read_memory(uint address) {
        if ((address & 0x0F000000) == 0x4000000) {
            return mmio.read(address);
        } else {
            return main[address];
        }
    }

    void write_memory(uint address, ubyte value) {
        if ((address & 0x0F000000) == 0x4000000) {
            mmio.write(address, value);
        } else {
            main[address] = value;
        }
    }
}