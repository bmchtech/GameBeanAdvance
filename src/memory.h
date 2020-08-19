#ifndef MEMORY_H
#define MEMORY_H

#include <cstdint>

struct Memory;
extern Memory memory;

// for more details on the GBA memory map: https://problemkaputt.de/gbatek.htm#gbamemorymap
// i'm going to probably have to split this struct into more specific values later,
// but for now ill just do the ones i can see myself easily using.

typedef struct Memory {
    // the main memory
    uint8_t* main;

    // registers. id name it "register" but thats a keyword apparently...
    // note that register 8 is the stack pointer
    //           register 9 is the... (TODO) whatever LR means
    //           register A is the program counter
    uint32_t* regs;

    // because doing things like register[0xF] to access the program counter 
    // is unreadable, here's a lot of shortcuts.
    uint32_t* pc;  // program counter
    uint32_t* lr;  // link register
    uint32_t* sp;  // stack pointer
    uint8_t*  all; // maps to the beginning of memory

    // general internal memory
    uint8_t* bios;         // 0x0000000 - 0x0003FFF
    uint8_t* wram_board;   // 0x2000000 - 0x203FFFF
    uint8_t* wram_chip;    // 0x3000000 - 0x3007FFF
    uint8_t* io_registers; // 0x4000000 - 0x40003FE

    // internal display memory
    uint8_t* palette_ram;  // 0x5000000 - 0x50003FF
    uint8_t* vram;         // 0x6000000 - 0x6017FFF
    uint8_t* oam;          // 0x7000000 - 0x70003FF

    // external memory (gamepak)
    uint8_t* rom_1;        // 0x8000000 - 0x9FFFFFF
    uint8_t* rom_2;        // 0xA000000 - 0xBFFFFFF
    uint8_t* rom_3;        // 0xC000000 - 0xDFFFFFF
    uint8_t* sram;         // 0xE000000 - 0xE00FFFF

    // program status register
    // NZCV--------------------IFT43210
    uint32_t* psr;
} Memory;

// words are 4 bytes, halfwords are 2 bytes
typedef uint32_t word;
typedef uint16_t halfword;

// heres a bunch of constants that summarize the information above
// unsure if much of the size constants will be used, but ill keep them here for now
#define SIZE_MAIN_MEMORY    0x10000000
#define SIZE_BIOS           0x0003FFF - 0x0000000
#define SIZE_WRAM_BOARD     0x203FFFF - 0x2000000
#define SIZE_WRAM_CHIP      0x3007FFF - 0x3000000
#define SIZE_IO_REGISTERS   0x40003FE - 0x4000000
#define SIZE_PALETTE_RAM    0x50003FF - 0x5000000
#define SIZE_VRAM           0x6017FFF - 0x6000000
#define SIZE_OAM            0x70003FF - 0x7000000
#define SIZE_ROM_1          0x9FFFFFF - 0x8000000
#define SIZE_ROM_2          0xBFFFFFF - 0xA000000
#define SIZE_ROM_3          0xDFFFFFF - 0xC000000
#define SIZE_SRAM           0xE00FFFF - 0xE000000

#define OFFSET_BIOS         0x0000000
#define OFFSET_WRAM_BOARD   0x2000000
#define OFFSET_WRAM_CHIP    0x3000000
#define OFFSET_IO_REGISTERS 0x4000000
#define OFFSET_PALETTE_RAM  0x5000000
#define OFFSET_VRAM         0x6000000
#define OFFSET_OAM          0x7000000
#define OFFSET_ROM_1        0x8000000
#define OFFSET_ROM_2        0xA000000
#define OFFSET_ROM_3        0xC000000
#define OFFSET_SRAM         0xE000000

#define NUM_REGISTERS       16

// shortcuts for psr
#define flag_N memory.psr[31]
#define flag_Z memory.psr[30]
#define flag_C memory.psr[29]
#define flag_V memory.psr[28]

// and for some functions
void setup_memory();

#endif