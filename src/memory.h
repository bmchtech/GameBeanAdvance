#ifndef MEMORY_H
#define MEMORY_H

#include <cstdint>
#include <iostream>
#include "util.h"

// for more details on the GBA memory map: https://problemkaputt.de/gbatek.htm#gbamemorymap
// i'm going to probably have to split this struct into more specific values later,
// but for now ill just do the ones i can see myself easily using.

class Memory {
    public:
        Memory();
        ~Memory();

        // the main memory
        uint8_t* main;

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

        // deal with this
        bool has_updated = false;
        uint8_t* pixels;

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

        //  IO Registers
        //        NAME           R/W   DESCRIPTION
        
        uint16_t* DISPCNT;    // R/W   LCD Control
        uint16_t* DISPSTAT;   // R/W   General LCD Status (STAT,LYC)
        uint16_t* VCOUNT;     // R     Vertical Counter (LY)
        uint16_t* BG0CNT;     // R/W   BG0 Control
        uint16_t* BG1CNT;     // R/W   BG1 Control
        uint16_t* BG2CNT;     // R/W   BG2 Control
        uint16_t* BG3CNT;     // R/W   BG3 Control
        uint16_t* BG0HOFS;    // W     BG0 X-Offset
        uint16_t* BG0VOFS;    // W     BG0 Y-Offset
        uint16_t* BG1HOFS;    // W     BG1 X-Offset
        uint16_t* BG1VOFS;    // W     BG1 Y-Offset
        uint16_t* BG2HOFS;    // W     BG2 X-Offset
        uint16_t* BG2VOFS;    // W     BG2 Y-Offset
        uint16_t* BG3HOFS;    // W     BG3 X-Offset
        uint16_t* BG3VOFS;    // W     BG3 Y-Offset
        uint16_t* BG2PA;      // W     BG2 Rotation/Scaling Parameter A (dx)
        uint16_t* BG2PB;      // W     BG2 Rotation/Scaling Parameter B (dmx)
        uint16_t* BG2PC;      // W     BG2 Rotation/Scaling Parameter C (dy)
        uint16_t* BG2PD;      // W     BG2 Rotation/Scaling Parameter D (dmy)
        uint32_t* BG2X;       // W     BG2 Reference Point X-Coordinate
        uint32_t* BG2Y;       // W     BG2 Reference Point Y-Coordinate
        uint16_t* BG3PA;      // W     BG3 Rotation/Scaling Parameter A (dx)
        uint16_t* BG3PB;      // W     BG3 Rotation/Scaling Parameter B (dmx)
        uint16_t* BG3PC;      // W     BG3 Rotation/Scaling Parameter C (dy)
        uint16_t* BG3PD;      // W     BG3 Rotation/Scaling Parameter D (dmy)
        uint32_t* BG3X;       // W     BG3 Reference Point X-Coordinate
        uint32_t* BG3Y;       // W     BG3 Reference Point Y-Coordinate
        uint16_t* WIN0H;      // W     Window 0 Horizontal Dimensions
        uint16_t* WIN1H;      // W     Window 1 Horizontal Dimensions
        uint16_t* WIN0V;      // W     Window 0 Vertical Dimensions
        uint16_t* WIN1V;      // W     Window 1 Vertical Dimensions
        uint16_t* WININ;      // R/W   Inside of Window 0 and 1
        uint16_t* WINOUT;     // R/W   Inside of OBJ Window & Outside of Windows
        uint16_t* MOSAIC;     // W     Mosaic Size
        uint16_t* BLDCNT;     // R/W   Color Special Effects Selection
        uint16_t* BLDALPHA;   // R/W   Alpha Blending Coefficients
        uint16_t* BLDY;       // W     Brightness (Fade-In/Out) Coefficient

        uint16_t* KEYINPUT;   // R     Key Status
        uint16_t* KEYCNT;     // R/W   Key Interrupt Control

        inline uint8_t read_byte(uint32_t address) {
            // if ((address & 0xFFFF0000) == 0x4000000) std::cout << "Reading byte from address " << to_hex_string(address) << std::endl;
            // if (address >= SIZE_MAIN_MEMORY) error("Address out of range on read byte (" + to_hex_string(address) + ")");
            return main[address];
        }

        inline uint16_t read_halfword(uint32_t address) {
            // if ((address & 0xFFFF0000) == 0x4000000) std::cout << "Reading halfword from address " << to_hex_string(address) << std::endl;
            // if (address + 2 >= SIZE_MAIN_MEMORY) error("Address out of range on read halfword (" + to_hex_string(address) + ")");
            return *((uint16_t*) (main + address));
        }

        inline uint32_t read_word(uint32_t address) {
            // if ((address & 0xFFFF0000) == 0x4000000) std::cout << "Reading word from address " << to_hex_string(address) << std::endl;
            // if (address + 4 >= SIZE_MAIN_MEMORY) error("Address out of range on read word (" + to_hex_string(address) + ")");
            return *((uint32_t*) (main + address));
        }

        inline void write_byte(uint32_t address, uint8_t value) {
            // if (address > 0x08000000) error("Attempt to read from ROM!" + to_hex_string(address));
            // if ((address & 0xFFFF0000) == 0x4000000) std::cout << "Writing byte " << to_hex_string(value) << " at address " << to_hex_string(address) << std::endl;
            // if (address >= SIZE_MAIN_MEMORY) error("Address out of range on write byte (" + to_hex_string(address) + ")");
            main[address] = value;
        }

        inline void write_halfword(uint32_t address, uint16_t value) {
            // if (address > 0x08000000) error("Attempt to read from ROM!" + to_hex_string(address));
            // if ((address & 0xFFFF0000) == 0x4000000) std::cout << "Writing halfword " << to_hex_string(value) << " at address " << to_hex_string(address) << std::endl;
            // if (address + 2 >= SIZE_MAIN_MEMORY) error("Address out of range on write halfword (" + to_hex_string(address) + ")");
            *((uint16_t*) (main + address)) = value;
        }

        inline void write_word(uint32_t address, uint32_t value) {
            // if (address > 0x08000000) error("Attempt to read from ROM!" + to_hex_string(address));
            // if ((address & 0xFFFF0000) == 0x4000000) std::cout << "Writing word " << to_hex_string(value) << " at address " << to_hex_string(address) << std::endl;
            // if (address + 4 >= SIZE_MAIN_MEMORY) error("Address out of range on write word (" + to_hex_string(address) + ")");
            *((uint32_t*) (main + address)) = value;
        }
        
        void SetRGB(int x, int y, uint8_t r, uint8_t g, uint8_t b);
};
#endif