#ifndef GBA_H
#define GBA_H

#include "memory.h"
#include "arm7tdmi.h"
#include "ppu.h"
#include <string>

#define CART_SIZE                0x1000000

#define ROM_ENTRY_POINT          0x000
#define GAME_TITLE_OFFSET        0x0A0
#define GAME_TITLE_SIZE          12

class GBA {
    friend void error(std::string message);

    public:
        // Allocates the memory and sets the mode to System.
        GBA(Memory* memory);

        // Frees the memory - classic destructor.
        ~GBA();

        // TODO: run the GBA. probably going to be one of the last things that is actually implemented, since manually cycling
        // the emulator is a lot easier to test. heck, this method might not even exist, idk. but, it's here for now.
        void run(std::string rom_name);

        // cycles the GBA CPU once, executing one instruction to completion.
        // maybe this method belongs in an ARM7TDMI class. nobody knows. i don't see the reason for having such a class, so
        // this is staying here for now.
        void cycle();

        // returns true if a DMA transfer occurred this cycle.
        bool handle_dma();

        bool enabled;

    private:
        ARM7TDMI* cpu;
        PPU*      ppu;
        Memory*   memory;

        typedef struct DMAChannel {
            uint32_t* source;
            uint32_t* dest;
            uint16_t* cnt_l;
            uint16_t* cnt_h;

            uint32_t  source_buf;
            uint32_t  dest_buf;
            uint16_t  size_buf;
            bool      enabled;
        } DMAChannel_t;

        DMAChannel_t dma_channels[4];
        bool dma_cycle = false;
};

#endif