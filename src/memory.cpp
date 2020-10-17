#include <cstdlib>
#include <iostream>

#include "memory.h"

// allocates the data for the memory struct
Memory::Memory() {
    main         = new uint8_t [SIZE_MAIN_MEMORY];
    regs         = new uint32_t[NUM_REGISTERS];

    // map a bunch of shortcut pointers
    sp           = &regs[0xD]; // stack pointer
    lr           = &regs[0xE]; // link register (branch with link instruction)
    pc           = &regs[0xF]; // program counter

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

    // the program status register
    cpsr          = 0x00000000;
    spsr          = 0x00000000;
}

Memory::~Memory() {
    delete[] main;
    delete[] regs;
}