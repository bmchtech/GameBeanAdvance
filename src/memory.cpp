#include <cstdlib>
#include <iostream>

#include "memory.h"

Memory memory;

// allocates the data for the memory struct
void setup_memory() {
    memory.bios         = (uint8_t*) malloc(SIZE_BIOS);
    memory.wram_board   = (uint8_t*) malloc(SIZE_WRAM_BOARD);
    memory.wram_chip    = (uint8_t*) malloc(SIZE_WRAM_CHIP);
    memory.io_registers = (uint8_t*) malloc(SIZE_IO_REGISTERS);
    memory.palette_ram  = (uint8_t*) malloc(SIZE_PALETTE_RAM);
    memory.vram         = (uint8_t*) malloc(SIZE_VRAM);
    memory.oam          = (uint8_t*) malloc(SIZE_OAM);
    memory.rom_1        = (uint8_t*) malloc(SIZE_ROM_1);
    memory.rom_2        = (uint8_t*) malloc(SIZE_ROM_2);
    memory.rom_3        = (uint8_t*) malloc(SIZE_ROM_3);
    memory.sram         = (uint8_t*) malloc(SIZE_SRAM);
}