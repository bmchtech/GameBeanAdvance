#include <cstdlib>
#include <iostream>

#include "memory.h"

Memory memory;

// allocates the data for the memory struct
void setup_memory() {
    memory.main         = new uint8_t [SIZE_MAIN_MEMORY];
    memory.regs         = new uint32_t[NUM_REGISTERS];

    // map a bunch of shortcut pointers
    memory.sp           = &memory.regs[0xD]; // stack pointer
    memory.lr           = &memory.regs[0xE]; // link register (branch with link instruction)
    memory.pc           = &memory.regs[0xF]; // program counter

    memory.bios         = &memory.main[OFFSET_BIOS];
    memory.wram_board   = &memory.main[OFFSET_WRAM_BOARD];
    memory.wram_chip    = &memory.main[OFFSET_WRAM_CHIP];
    memory.io_registers = &memory.main[OFFSET_IO_REGISTERS];
    memory.palette_ram  = &memory.main[OFFSET_PALETTE_RAM];
    memory.vram         = &memory.main[OFFSET_VRAM];
    memory.oam          = &memory.main[OFFSET_OAM];
    memory.rom_1        = &memory.main[OFFSET_ROM_1];
    memory.rom_2        = &memory.main[OFFSET_ROM_2];
    memory.rom_3        = &memory.main[OFFSET_ROM_3];
    memory.sram         = &memory.main[OFFSET_SRAM];

    // the program status register
    memory.psr          = 0x00000000;
}

void cleanup_memory() {
    delete[] memory.main;
    delete[] memory.regs;
}