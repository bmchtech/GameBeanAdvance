module memory;

import std.stdio;

import util;

// for more details on the GBA memory map: https://problemkaputt.de/gbatek.htm#gbamemorymap
// i'm going to probably have to split this struct into more specific values later,
// but for now ill just do the ones i can see myself easily using.

class Memory {
    bool has_updated = false;

    ubyte[] pixels;
    ubyte[] main;
    /** video buffer in RGBA8888 */
    uint[][] video_buffer;

    enum SIZE_MAIN_MEMORY = 0x10000000;
    enum SIZE_BIOS = 0x0003FFF - 0x0000000;
    enum SIZE_WRAM_BOARD = 0x203FFFF - 0x2000000;
    enum SIZE_WRAM_CHIP = 0x3007FFF - 0x3000000;
    enum SIZE_IO_REGISTERS = 0x40003FE - 0x4000000;
    enum SIZE_PALETTE_RAM = 0x50003FF - 0x5000000;
    enum SIZE_VRAM = 0x6017FFF - 0x6000000;
    enum SIZE_OAM = 0x70003FF - 0x7000000;
    enum SIZE_ROM_1 = 0x9FFFFFF - 0x8000000;
    enum SIZE_ROM_2 = 0xBFFFFFF - 0xA000000;
    enum SIZE_ROM_3 = 0xDFFFFFF - 0xC000000;
    enum SIZE_SRAM = 0xE00FFFF - 0xE000000;

    enum OFFSET_BIOS = 0x0000000;
    enum OFFSET_WRAM_BOARD = 0x2000000;
    enum OFFSET_WRAM_CHIP = 0x3000000;
    enum OFFSET_IO_REGISTERS = 0x4000000;
    enum OFFSET_PALETTE_RAM = 0x5000000;
    enum OFFSET_VRAM = 0x6000000;
    enum OFFSET_OAM = 0x7000000;
    enum OFFSET_ROM_1 = 0x8000000;
    enum OFFSET_ROM_2 = 0xA000000;
    enum OFFSET_ROM_3 = 0xC000000;
    enum OFFSET_SRAM = 0xE000000;

    //  IO Registers
    //        NAME           R/W   DESCRIPTION

    ushort* DISPCNT; // R/W   LCD Control
    ushort* DISPSTAT; // R/W   General LCD Status (STAT,LYC)
    ushort* VCOUNT; // R     Vertical Counter (LY)
    ushort* BG0CNT; // R/W   BG0 Control
    ushort* BG1CNT; // R/W   BG1 Control
    ushort* BG2CNT; // R/W   BG2 Control
    ushort* BG3CNT; // R/W   BG3 Control
    ushort* BG0HOFS; // W     BG0 X-Offset
    ushort* BG0VOFS; // W     BG0 Y-Offset
    ushort* BG1HOFS; // W     BG1 X-Offset
    ushort* BG1VOFS; // W     BG1 Y-Offset
    ushort* BG2HOFS; // W     BG2 X-Offset
    ushort* BG2VOFS; // W     BG2 Y-Offset
    ushort* BG3HOFS; // W     BG3 X-Offset
    ushort* BG3VOFS; // W     BG3 Y-Offset
    ushort* BG2PA; // W     BG2 Rotation/Scaling Parameter A (dx)
    ushort* BG2PB; // W     BG2 Rotation/Scaling Parameter B (dmx)
    ushort* BG2PC; // W     BG2 Rotation/Scaling Parameter C (dy)
    ushort* BG2PD; // W     BG2 Rotation/Scaling Parameter D (dmy)
    uint* BG2X; // W     BG2 Reference Point X-Coordinate
    uint* BG2Y; // W     BG2 Reference Point Y-Coordinate
    ushort* BG3PA; // W     BG3 Rotation/Scaling Parameter A (dx)
    ushort* BG3PB; // W     BG3 Rotation/Scaling Parameter B (dmx)
    ushort* BG3PC; // W     BG3 Rotation/Scaling Parameter C (dy)
    ushort* BG3PD; // W     BG3 Rotation/Scaling Parameter D (dmy)
    uint* BG3X; // W     BG3 Reference Point X-Coordinate
    uint* BG3Y; // W     BG3 Reference Point Y-Coordinate
    ushort* WIN0H; // W     Window 0 Horizontal Dimensions
    ushort* WIN1H; // W     Window 1 Horizontal Dimensions
    ushort* WIN0V; // W     Window 0 Vertical Dimensions
    ushort* WIN1V; // W     Window 1 Vertical Dimensions
    ushort* WININ; // R/W   Inside of Window 0 and 1
    ushort* WINOUT; // R/W   Inside of OBJ Window & Outside of Windows
    ushort* MOSAIC; // W     Mosaic Size
    ushort* BLDCNT; // R/W   Color Special Effects Selection
    ushort* BLDALPHA; // R/W   Alpha Blending Coefficients
    ushort* BLDY; // W     Brightness (Fade-In/Out) Coefficient

    uint* DMA0SAD; // W     DMA 0 Source Address
    uint* DMA0DAD; // W     DMA 0 Destination Address
    ushort* DMA0CNT_L; // W     DMA 0 Word Count
    ushort* DMA0CNT_H; // R/W   DMA 0 Control
    uint* DMA1SAD; // W     DMA 1 Source Address
    uint* DMA1DAD; // W     DMA 1 Destination Address
    ushort* DMA1CNT_L; // W     DMA 1 Word Count
    ushort* DMA1CNT_H; // R/W   DMA 1 Control
    uint* DMA2SAD; // W     DMA 2 Source Address
    uint* DMA2DAD; // W     DMA 2 Destination Address
    ushort* DMA2CNT_L; // W     DMA 2 Word Count
    ushort* DMA2CNT_H; // R/W   DMA 2 Control
    uint* DMA3SAD; // W     DMA 3 Source Address
    uint* DMA3DAD; // W     DMA 3 Destination Address
    ushort* DMA3CNT_L; // W     DMA 3 Word Count
    ushort* DMA3CNT_H; // R/W   DMA 3 Control

    ushort* KEYINPUT; // R     Key Status
    ushort* KEYCNT; // R/W   Key Interrupt Control

    this() {
        main = new ubyte[SIZE_MAIN_MEMORY];

        DISPCNT = cast(ushort*)&main[0x4000000];
        DISPSTAT = cast(ushort*)&main[0x4000004];
        VCOUNT = cast(ushort*)&main[0x4000006];
        BG0CNT = cast(ushort*)&main[0x4000008];
        BG1CNT = cast(ushort*)&main[0x400000A];
        BG2CNT = cast(ushort*)&main[0x400000C];
        BG3CNT = cast(ushort*)&main[0x400000E];
        BG0HOFS = cast(ushort*)&main[0x4000010];
        BG0VOFS = cast(ushort*)&main[0x4000012];
        BG1HOFS = cast(ushort*)&main[0x4000014];
        BG1VOFS = cast(ushort*)&main[0x4000016];
        BG2HOFS = cast(ushort*)&main[0x4000018];
        BG2VOFS = cast(ushort*)&main[0x400001A];
        BG3HOFS = cast(ushort*)&main[0x400001C];
        BG3VOFS = cast(ushort*)&main[0x400001E];
        BG2PA = cast(ushort*)&main[0x4000020];
        BG2PB = cast(ushort*)&main[0x4000022];
        BG2PC = cast(ushort*)&main[0x4000024];
        BG2PD = cast(ushort*)&main[0x4000026];
        BG2X = cast(uint*)&main[0x4000028];
        BG2Y = cast(uint*)&main[0x400002C];
        BG3PA = cast(ushort*)&main[0x4000030];
        BG3PB = cast(ushort*)&main[0x4000032];
        BG3PC = cast(ushort*)&main[0x4000034];
        BG3PD = cast(ushort*)&main[0x4000036];
        BG3X = cast(uint*)&main[0x4000038];
        BG3Y = cast(uint*)&main[0x400003C];
        WIN0H = cast(ushort*)&main[0x4000040];
        WIN1H = cast(ushort*)&main[0x4000042];
        WIN0V = cast(ushort*)&main[0x4000044];
        WIN1V = cast(ushort*)&main[0x4000046];
        WININ = cast(ushort*)&main[0x4000048];
        WINOUT = cast(ushort*)&main[0x400004A];
        MOSAIC = cast(ushort*)&main[0x400004C];
        BLDCNT = cast(ushort*)&main[0x4000050];
        BLDALPHA = cast(ushort*)&main[0x4000052];
        BLDY = cast(ushort*)&main[0x4000054];

        DMA0SAD = cast(uint*)&main[0x40000B0];
        DMA0DAD = cast(uint*)&main[0x40000B4];
        DMA0CNT_L = cast(ushort*)&main[0x40000B8];
        DMA0CNT_H = cast(ushort*)&main[0x40000BA];
        DMA1SAD = cast(uint*)&main[0x40000BC];
        DMA1DAD = cast(uint*)&main[0x40000C0];
        DMA1CNT_L = cast(ushort*)&main[0x40000C4];
        DMA1CNT_H = cast(ushort*)&main[0x40000C6];
        DMA2SAD = cast(uint*)&main[0x40000C8];
        DMA2DAD = cast(uint*)&main[0x40000CC];
        DMA2CNT_L = cast(ushort*)&main[0x40000D0];
        DMA2CNT_H = cast(ushort*)&main[0x40000D2];
        DMA3SAD = cast(uint*)&main[0x40000D4];
        DMA3DAD = cast(uint*)&main[0x40000D8];
        DMA3CNT_L = cast(ushort*)&main[0x40000DC];
        DMA3CNT_H = cast(ushort*)&main[0x40000DE];

        KEYINPUT = cast(ushort*)&main[0x4000130];
        KEYCNT = cast(ushort*)&main[0x4000132];

        video_buffer = new uint[][](240, 160);

        // manual overrides: TEMPORARY
        // TODO: remove when properly implemented
        *DISPCNT = 6;
        write_halfword(0x4000130, 0x03FF);
    }

    ubyte read_byte(uint address) {
        // if ((address & 0xFFFF0000) == 0x4000000) writeln("Reading byte from address " ~ to_hex_string(address) ~ "\n");
        if (address >= SIZE_MAIN_MEMORY)
            error("Address out of range on read byte (" ~ to_hex_string(address) ~ ")");
        return main[address];
    }

    ushort read_halfword(uint address) {
        // if ((address & 0xFFFF0000) == 0x4000000) std::cout << "Reading halfword from address " << to_hex_string(address) << std::endl;
        if (address + 2 >= SIZE_MAIN_MEMORY)
            error("Address out of range on read halfword (" ~ to_hex_string(address) ~ ")");
        return (cast(ushort) main[address + 0] << 0) | (cast(ushort) main[address + 1] << 8);
    }

    uint read_word(uint address) {
        // if ((address & 0xFFFF0000) == 0x4000000) std::cout << "Reading word from address " << to_hex_string(address) << std::endl;
        if (address + 4 >= SIZE_MAIN_MEMORY)
            error("Address out of range on read word (" ~ to_hex_string(address) ~ ")");
        return (cast(uint) main[address + 0] << 0) | (
                cast(uint) main[address + 1] << 8) | (cast(
                uint) main[address + 2] << 16) | (cast(uint) main[address + 3] << 24);
    }

    void write_byte(uint address, ubyte value) {
        // if (address > 0x08000000) error("Attempt to read from ROM!" + to_hex_string(address));
        // if ((address & 0xFFFF0000) == 0x4000000) std::cout << "Writing byte " << to_hex_string(value) << " at address " << to_hex_string(address) << std::endl;
        if (address >= SIZE_MAIN_MEMORY)
            error("Address out of range on write byte (" ~ to_hex_string(address) ~ ")");
        // main[address] = value;
        main[address + 0] = cast(ubyte)((value >> 0) & 0xff);
    }

    void write_halfword(uint address, ushort value) {
        // if (address > 0x08000000) error("Attempt to read from ROM!" + to_hex_string(address));
        // if ((address & 0xFFFF0000) == 0x4000000) std::cout << "Writing halfword " << to_hex_string(value) << " at address " << to_hex_string(address) << std::endl;
        if (address + 2 >= SIZE_MAIN_MEMORY)
            error("Address out of range on write halfword (" ~ to_hex_string(address) ~ ")");
        // *(cast(ushort*) (main[0] + address)) = value;
        main[address + 0] = cast(ubyte)((value >> 0) & 0xff);
        main[address + 1] = cast(ubyte)((value >> 8) & 0xff);
    }

    void write_word(uint address, uint value) {
        // if (address > 0x08000000) error("Attempt to read from ROM!" + to_hex_string(address));
        // if ((address & 0xFFFF0000) == 0x4000000) std::cout << "Writing word " << to_hex_string(value) << " at address " << to_hex_string(address) << std::endl;
        if (address + 4 >= SIZE_MAIN_MEMORY)
            error("Address out of range on write word (" ~ to_hex_string(address) ~ ")");
        // *(cast(uint*) (main[0] + address)) = value;
        main[address + 0] = cast(ubyte)((value >> 0) & 0xff);
        main[address + 1] = cast(ubyte)((value >> 8) & 0xff);
        main[address + 2] = cast(ubyte)((value >> 16) & 0xff);
        main[address + 3] = cast(ubyte)((value >> 24) & 0xff);
    }

    void SetRGB(uint x, uint y, ubyte r, ubyte g, ubyte b) {
        video_buffer[x][y] = (r << 24) & (g << 16) & (b << 8) & (0xff);
    }
}
