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