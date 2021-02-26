#include <cstdlib>
#include <iostream>

#include "memory.h"

// allocates the data for the memory struct
Memory::Memory() {
    main         = new uint8_t[SIZE_MAIN_MEMORY](); 
    bios         = &main[OFFSET_BIOS];
    wram_board   = &main[OFFSET_WRAM_BOARD];
    wram_chip    = &main[OFFSET_WRAM_CHIP];
    io_registers = &main[OFFSET_IO_REGISTERS];
    palette_ram  = &main[OFFSET_PALETTE_RAM];
    vram         = &main[OFFSET_VRAM];
    oam          = &main[OFFSET_OAM];
    rom_1        = &main[OFFSET_ROM_1];
    rom_2        = &main[OFFSET_ROM_2];
    rom_3        = &main[OFFSET_ROM_3];
    sram         = &main[OFFSET_SRAM];
    
    DISPCNT      = (uint16_t*) &main[0x4000000];
    DISPSTAT     = (uint16_t*) &main[0x4000004];
    VCOUNT       = (uint16_t*) &main[0x4000006];
    BG0CNT       = (uint16_t*) &main[0x4000008];
    BG1CNT       = (uint16_t*) &main[0x400000A];
    BG2CNT       = (uint16_t*) &main[0x400000C];
    BG3CNT       = (uint16_t*) &main[0x400000E];
    BG0HOFS      = (uint16_t*) &main[0x4000010];
    BG0VOFS      = (uint16_t*) &main[0x4000012];
    BG1HOFS      = (uint16_t*) &main[0x4000014];
    BG1VOFS      = (uint16_t*) &main[0x4000016];
    BG2HOFS      = (uint16_t*) &main[0x4000018];
    BG2VOFS      = (uint16_t*) &main[0x400001A];
    BG3HOFS      = (uint16_t*) &main[0x400001C];
    BG3VOFS      = (uint16_t*) &main[0x400001E];
    BG2PA        = (uint16_t*) &main[0x4000020];
    BG2PB        = (uint16_t*) &main[0x4000022];
    BG2PC        = (uint16_t*) &main[0x4000024];
    BG2PD        = (uint16_t*) &main[0x4000026];
    BG2X         = (uint32_t*) &main[0x4000028];
    BG2Y         = (uint32_t*) &main[0x400002C];
    BG3PA        = (uint16_t*) &main[0x4000030];
    BG3PB        = (uint16_t*) &main[0x4000032];
    BG3PC        = (uint16_t*) &main[0x4000034];
    BG3PD        = (uint16_t*) &main[0x4000036];
    BG3X         = (uint32_t*) &main[0x4000038];
    BG3Y         = (uint32_t*) &main[0x400003C];
    WIN0H        = (uint16_t*) &main[0x4000040];
    WIN1H        = (uint16_t*) &main[0x4000042];
    WIN0V        = (uint16_t*) &main[0x4000044];
    WIN1V        = (uint16_t*) &main[0x4000046];
    WININ        = (uint16_t*) &main[0x4000048];
    WINOUT       = (uint16_t*) &main[0x400004A];
    MOSAIC       = (uint16_t*) &main[0x400004C];
    BLDCNT       = (uint16_t*) &main[0x4000050];
    BLDALPHA     = (uint16_t*) &main[0x4000052];
    BLDY         = (uint16_t*) &main[0x4000054];

    KEYINPUT     = (uint16_t*) &main[0x4000130];
    KEYCNT       = (uint16_t*) &main[0x4000132];

    // manual overrides: TEMPORARY
    // TODO: remove when properly implemented
    *DISPCNT  = 6;
    write_halfword(0x4000130, 0x03FF);

    pixels       = new uint8_t[240 * 160 * 3]();
}

Memory::~Memory() {
    delete[] main;
    delete[] pixels;
}

void Memory::SetRGB(int x, int y, uint8_t r, uint8_t g, uint8_t b) {
    // std::cout << std::to_string(x) << " , " << std::to_string(y) << std::endl;
    pixels[((x * 160) + y) * 3 + 0] = r;
    pixels[((x * 160) + y) * 3 + 1] = g;
    pixels[((x * 160) + y) * 3 + 2] = b;
}