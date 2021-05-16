module memory;

import std.stdio;

import util;

import apu;

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

    //  IO Registers
    //        NAME         R/W   DESCRIPTION

    ushort* DISPCNT;     // R/W   LCD Control
    ushort* DISPSTAT;    // R/W   General LCD Status (STAT,LYC)
    ushort* VCOUNT;      // R     Vertical Counter (LY)
    ushort* BG0CNT;      // R/W   BG0 Control
    ushort* BG1CNT;      // R/W   BG1 Control
    ushort* BG2CNT;      // R/W   BG2 Control
    ushort* BG3CNT;      // R/W   BG3 Control
    ushort* BG0HOFS;     // W     BG0 X-Offset
    ushort* BG0VOFS;     // W     BG0 Y-Offset
    ushort* BG1HOFS;     // W     BG1 X-Offset
    ushort* BG1VOFS;     // W     BG1 Y-Offset
    ushort* BG2HOFS;     // W     BG2 X-Offset
    ushort* BG2VOFS;     // W     BG2 Y-Offset
    ushort* BG3HOFS;     // W     BG3 X-Offset
    ushort* BG3VOFS;     // W     BG3 Y-Offset
    ushort* BG2PA;       // W     BG2 Rotation/Scaling Parameter A (dx)
    ushort* BG2PB;       // W     BG2 Rotation/Scaling Parameter B (dmx)
    ushort* BG2PC;       // W     BG2 Rotation/Scaling Parameter C (dy)
    ushort* BG2PD;       // W     BG2 Rotation/Scaling Parameter D (dmy)
    uint*   BG2X;        // W     BG2 Reference Point X-Coordinate
    uint*   BG2Y;        // W     BG2 Reference Point Y-Coordinate
    ushort* BG3PA;       // W     BG3 Rotation/Scaling Parameter A (dx)
    ushort* BG3PB;       // W     BG3 Rotation/Scaling Parameter B (dmx)
    ushort* BG3PC;       // W     BG3 Rotation/Scaling Parameter C (dy)
    ushort* BG3PD;       // W     BG3 Rotation/Scaling Parameter D (dmy)
    uint*   BG3X;        // W     BG3 Reference Point X-Coordinate
    uint*   BG3Y;        // W     BG3 Reference Point Y-Coordinate
    ushort* WIN0H;       // W     Window 0 Horizontal Dimensions
    ushort* WIN1H;       // W     Window 1 Horizontal Dimensions
    ushort* WIN0V;       // W     Window 0 Vertical Dimensions
    ushort* WIN1V;       // W     Window 1 Vertical Dimensions
    ushort* WININ;       // R/W   Inside of Window 0 and 1
    ushort* WINOUT;      // R/W   Inside of OBJ Window & Outside of Windows
    ushort* MOSAIC;      // W     Mosaic Size
    ushort* BLDCNT;      // R/W   Color Special Effects Selection
    ushort* BLDALPHA;    // R/W   Alpha Blending Coefficients
    ushort* BLDY;        // W     Brightness (Fade-In/Out) Coefficient

    ushort* SOUND1CNT_L; // R/W   Channel 1 Sweep Register       (NR10)
    ushort* SOUND1CNT_H; // R/W   Channel 1 Duty/Length/Envelope (NR11, NR12)
    ushort* SOUND1CNT_X; // R/W   Channel 1 Frequency/Control    (NR13, NR14)
    ushort* SOUND2CNT_L; // R/W   Channel 2 Duty/Length/Envelope (NR21, NR22)
    ushort* SOUND2CNT_H; // R/W   Channel 2 Frequency/Control    (NR23, NR24)
    ushort* SOUND3CNT_L; // R/W   Channel 3 Stop/Wave RAM select (NR30)
    ushort* SOUND3CNT_H; // R/W   Channel 3 Length/Volume        (NR31, NR32)
    ushort* SOUND3CNT_X; // R/W   Channel 3 Frequency/Control    (NR33, NR34)
    ushort* SOUND4CNT_L; // R/W   Channel 4 Length/Envelope      (NR41, NR42)
    ushort* SOUND4CNT_H; // R/W   Channel 4 Frequency/Control    (NR43, NR44)
    ushort* SOUNDCNT_L;  // R/W   Control Stereo/Volume/Enable   (NR50, NR51)
    ushort* SOUNDCNT_H;  // R/W   Control Mixing/DMA Control
    ushort* SOUNDCNT_X;  // R/W   Control Sound on/off           (NR52)
    ushort* SOUNDBIAS;   // BIOS  Sound PWM Control
    uint*   FIFO_A;      // W     Channel A FIFO, Data 0-3
    uint*   FIFO_B;      // W     Channel B FIFO, Data 0-3    

    uint*   DMA0SAD;     // W     DMA 0 Source Address
    uint*   DMA0DAD;     // W     DMA 0 Destination Address
    ushort* DMA0CNT_L;   // W     DMA 0 Word Count
    ushort* DMA0CNT_H;   // R/W   DMA 0 Control
    uint*   DMA1SAD;     // W     DMA 1 Source Address
    uint*   DMA1DAD;     // W     DMA 1 Destination Address
    ushort* DMA1CNT_L;   // W     DMA 1 Word Count
    ushort* DMA1CNT_H;   // R/W   DMA 1 Control
    uint*   DMA2SAD;     // W     DMA 2 Source Address
    uint*   DMA2DAD;     // W     DMA 2 Destination Address
    ushort* DMA2CNT_L;   // W     DMA 2 Word Count
    ushort* DMA2CNT_H;   // R/W   DMA 2 Control
    uint*   DMA3SAD;     // W     DMA 3 Source Address
    uint*   DMA3DAD;     // W     DMA 3 Destination Address
    ushort* DMA3CNT_L;   // W     DMA 3 Word Count
    ushort* DMA3CNT_H;   // R/W   DMA 3 Control

    ushort* TM0CNT_L;    // R/W   Timer 0 Counter/Reload
    ushort* TM0CNT_H;    // R/W   Timer 0 Control
    ushort* TM1CNT_L;    // R/W   Timer 1 Counter/Reload
    ushort* TM1CNT_H;    // R/W   Timer 1 Control
    ushort* TM2CNT_L;    // R/W   Timer 2 Counter/Reload
    ushort* TM2CNT_H;    // R/W   Timer 2 Control
    ushort* TM3CNT_L;   // R/W   Timer 3 Counter/Reload
    ushort* TM3CNT_H;   // R/W   Timer 3 Control

    ushort* KEYINPUT;   // R     Key Status
    ushort* KEYCNT;     // R/W   Key Interrupt Control

    ushort* IE;         // R/W   Interrupt Enable Register
    ushort* IF;         // R/W   Interrupt Request Flags / IRQ Acknowledge
    ushort* IME;        // R/W   Interrupt Master Enable Register

    this() {
        main = new ubyte[SIZE_MAIN_MEMORY];

        DISPCNT      = cast(ushort*) &main[0x4000000];
        DISPSTAT     = cast(ushort*) &main[0x4000004];
        VCOUNT       = cast(ushort*) &main[0x4000006];
        BG0CNT       = cast(ushort*) &main[0x4000008];
        BG1CNT       = cast(ushort*) &main[0x400000A];
        BG2CNT       = cast(ushort*) &main[0x400000C];
        BG3CNT       = cast(ushort*) &main[0x400000E];
        BG0HOFS      = cast(ushort*) &main[0x4000010];
        BG0VOFS      = cast(ushort*) &main[0x4000012];
        BG1HOFS      = cast(ushort*) &main[0x4000014];
        BG1VOFS      = cast(ushort*) &main[0x4000016];
        BG2HOFS      = cast(ushort*) &main[0x4000018];
        BG2VOFS      = cast(ushort*) &main[0x400001A];
        BG3HOFS      = cast(ushort*) &main[0x400001C];
        BG3VOFS      = cast(ushort*) &main[0x400001E];
        BG2PA        = cast(ushort*) &main[0x4000020];
        BG2PB        = cast(ushort*) &main[0x4000022];
        BG2PC        = cast(ushort*) &main[0x4000024];
        BG2PD        = cast(ushort*) &main[0x4000026];
        BG2X         = cast(uint*  ) &main[0x4000028];
        BG2Y         = cast(uint*  ) &main[0x400002C];
        BG3PA        = cast(ushort*) &main[0x4000030];
        BG3PB        = cast(ushort*) &main[0x4000032];
        BG3PC        = cast(ushort*) &main[0x4000034];
        BG3PD        = cast(ushort*) &main[0x4000036];
        BG3X         = cast(uint*  ) &main[0x4000038];
        BG3Y         = cast(uint*  ) &main[0x400003C];
        WIN0H        = cast(ushort*) &main[0x4000040];
        WIN1H        = cast(ushort*) &main[0x4000042];
        WIN0V        = cast(ushort*) &main[0x4000044];
        WIN1V        = cast(ushort*) &main[0x4000046];
        WININ        = cast(ushort*) &main[0x4000048];
        WINOUT       = cast(ushort*) &main[0x400004A];
        MOSAIC       = cast(ushort*) &main[0x400004C];
        BLDCNT       = cast(ushort*) &main[0x4000050];
        BLDALPHA     = cast(ushort*) &main[0x4000052];
        BLDY         = cast(ushort*) &main[0x4000054];

        SOUND1CNT_L  = cast(ushort*) &main[0x4000060];
        SOUND1CNT_H  = cast(ushort*) &main[0x4000062];
        SOUND1CNT_X  = cast(ushort*) &main[0x4000064];
        SOUND2CNT_L  = cast(ushort*) &main[0x4000068];
        SOUND2CNT_H  = cast(ushort*) &main[0x400006C];
        SOUND3CNT_L  = cast(ushort*) &main[0x4000070];
        SOUND3CNT_H  = cast(ushort*) &main[0x4000072];
        SOUND3CNT_X  = cast(ushort*) &main[0x4000074];
        SOUND4CNT_L  = cast(ushort*) &main[0x4000078];
        SOUND4CNT_H  = cast(ushort*) &main[0x400007C];
        SOUNDCNT_L   = cast(ushort*) &main[0x4000080];
        SOUNDCNT_H   = cast(ushort*) &main[0x4000082];
        SOUNDCNT_X   = cast(ushort*) &main[0x4000084];
        SOUNDBIAS    = cast(ushort*) &main[0x4000088];
        FIFO_A       = cast(uint*)   &main[0x40000A0];
        FIFO_B       = cast(uint*)   &main[0x40000A4];

        DMA0SAD      = cast(uint*  ) &main[0x40000B0];
        DMA0DAD      = cast(uint*  ) &main[0x40000B4];
        DMA0CNT_L    = cast(ushort*) &main[0x40000B8];
        DMA0CNT_H    = cast(ushort*) &main[0x40000BA];
        DMA1SAD      = cast(uint*  ) &main[0x40000BC];
        DMA1DAD      = cast(uint*  ) &main[0x40000C0];
        DMA1CNT_L    = cast(ushort*) &main[0x40000C4];
        DMA1CNT_H    = cast(ushort*) &main[0x40000C6];
        DMA2SAD      = cast(uint*  ) &main[0x40000C8];
        DMA2DAD      = cast(uint*  ) &main[0x40000CC];
        DMA2CNT_L    = cast(ushort*) &main[0x40000D0];
        DMA2CNT_H    = cast(ushort*) &main[0x40000D2];
        DMA3SAD      = cast(uint*  ) &main[0x40000D4];
        DMA3DAD      = cast(uint*  ) &main[0x40000D8];
        DMA3CNT_L    = cast(ushort*) &main[0x40000DC];
        DMA3CNT_H    = cast(ushort*) &main[0x40000DE];

        TM0CNT_L     = cast(ushort*) &main[0x4000100];
        TM0CNT_H     = cast(ushort*) &main[0x4000102];
        TM1CNT_L     = cast(ushort*) &main[0x4000104];
        TM1CNT_H     = cast(ushort*) &main[0x4000106];
        TM2CNT_L     = cast(ushort*) &main[0x4000108];
        TM2CNT_H     = cast(ushort*) &main[0x400010A];
        TM3CNT_L     = cast(ushort*) &main[0x400010C];
        TM3CNT_H     = cast(ushort*) &main[0x400010E];

        KEYINPUT     = cast(ushort*) &main[0x4000130];
        KEYCNT       = cast(ushort*) &main[0x4000132];

        IE           = cast(ushort*) &main[0x4000200];
        IF           = cast(ushort*) &main[0x4000202];
        IME          = cast(ushort*) &main[0x4000208];

        video_buffer = new uint[][](240, 160);
        fifo_a = new Fifo!ubyte(0x20, 0x00);
        fifo_b = new Fifo!ubyte(0x20, 0x00);

        // manual overrides: TEMPORARY
        // TODO: remove when properly implemented
        *DISPCNT = 6;
        *SOUNDBIAS = 0x200;
        write_halfword(0x4000130, 0x03FF);

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
                if (get_nth_bits(*DISPCNT, 0, 3) <= 2) {
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
        if (address == 0x030014d0) writefln("Read byte from %08x", address);
        return main[address];
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
        if (address == 0x030014d0) writefln("Read halfword from %08x", address);
        return (cast(ushort) main[address + 0] << 0) | (cast(ushort) main[address + 1] << 8);
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
        if (address == 0x030014d0) writefln("Read word from %08x", address);
        return (cast(uint) main[address + 0] << 0) | (
                cast(uint) main[address + 1] << 8) | (cast(
                uint) main[address + 2] << 16) | (cast(uint) main[address + 3] << 24);
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
            if (get_nth_bits(*DISPCNT, 0, 3) <= 2) {
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
        set_memory(address + 0, cast(ubyte)((value >> 0) & 0xff));
        // if ((address & 0xFFFFF000) == 0x4000000) writefln("Wrote byte %02x to %x", value, address);
        // if (address == 0x0821dbb8) writefln("Wrote byte %08x to %x", value, address);
        // if ((address & 0xFF000000) == 0x0000000) error("ATTEMPT TO OVERWRITE BIOS!!!");
        if ((address & 0xFF000000) == 0x6000000) writefln("Wrote byte %02x to %x", value, address);
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
        set_memory(address + 0, cast(ubyte)((value >> 0) & 0xff));
        set_memory(address + 1, cast(ubyte)((value >> 8) & 0xff));
        // if ((address & 0xFFFFF000) == 0x4 000000) writefln("Wrote halfword %04x to %x", value, address);
        // if (address == 0x0821dbb8) writefln("Wrote halfword %08x to %x", value, address);
        // if ((address & 0xFF000000) == 0x0000000) error("ATTEMPT TO OVERWRITE BIOS!!!");
        if ((address & 0xFF000000) == 0x6000000) writefln("Wrote halfword %04x to %x", value, address);
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
        set_memory(address + 0, cast(ubyte)((value >> 0)  & 0xff));
        set_memory(address + 1, cast(ubyte)((value >> 8)  & 0xff));
        set_memory(address + 2, cast(ubyte)((value >> 16) & 0xff));
        set_memory(address + 3, cast(ubyte)((value >> 24) & 0xff));
        // if ((address & 0xFFFFF000) == 0x4000000) if (address != 0x040000a0) writefln("Wrote word %08x to %x", value, address);
        // if (address == 0x0821dbb8) writefln("Wrote word %08x to %x", value, address);
        // if ((address & 0xFF000000) == 0x0000000) error("ATTEMPT TO OVERWRITE BIOS!!!");
        if ((address & 0xFF000000) == 0x6000000) writefln("Wrote word %08x to %x", value, address);
        // writefln("Wrote word %08x to %x", value, address);
    }

    void set_rgb(uint x, uint y, ubyte r, ubyte g, ubyte b) {
        auto p = (r << 24) | (g << 16) | (b << 8) | (0xff);
        mixin(VERBOSE_LOG!(`4`,
                `format("SETRGB (%s,%s) = [%s, %s, %s] = %00000000x", x, y, r, g, b, p)`));
        video_buffer[x][y] = p;
    }

    void set_key(ubyte code, bool pressed) {
        assert(code >= 0 && code < 10, "invalid gba key code");
        mixin(VERBOSE_LOG!(`2`, `format("KEY (%s) = %s", code, pressed)`));

        if (pressed) {
            *KEYINPUT &= ~(0b1 << code);
        } else {
            *KEYINPUT |= (0b1 << code);
        }
    }

private:
    void set_memory(uint address, ubyte value) {
        // trying to set a bit in register IF will actually clear that bit.
        if        (address == 0x4000202 || address == 0x4000203) { // are we register IF?
            main[address] &= ~cast(uint)value; 
        } else if ((address & 0xFFFFFFC) == 0x40000A0) { // are we FIFO A?
            fifo_a.push(value);
            main[address] = value;
            // writefln("Pushed to FIFO A. Value: %x", value);
        } else if ((address & 0xFFFFFFC) == 0x40000A4) { // are we FIFO B?
            fifo_b.push(value);
            main[address] = value;
        } else {
            main[address] = value;
        }
    }
}
