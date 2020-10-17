#ifndef GBA_H
#define GBA_H

#include "memory.h"
#include "arm7tdmi.h"
#include <string>

#define CART_SIZE         0x1000000

#define ROM_ENTRY_POINT   0x000
#define GAME_TITLE_OFFSET 0x0A0
#define GAME_TITLE_SIZE   12

#define MODE_USER       0b10000
#define MODE_FIQ        0b10001
#define MODE_IRQ        0b10010
#define MODE_SUPERVISOR 0b10011
#define MODE_ABORT      0b10111
#define MODE_UNDEFINED  0b11011
#define MODE_SYSTEM     0b11111


class GBA {

    public:
        // Allocates the memory and sets the mode to System.
        GBA();

        // Frees the memory - classic destructor.
        ~GBA();

        // TODO: run the GBA. probably going to be one of the last things that is actually implemented, since manually cycling
        // the emulator is a lot easier to test. heck, this method might not even exist, idk. but, it's here for now.
        void run(std::string rom_name);

        // cycles the GBA CPU once, executing one instruction to completion.
        // maybe this method belongs in an ARM7TDMI class. nobody knows. i don't see the reason for having such a class, so
        // this is staying here for now.
        void cycle();
    
    private:
        ARM7TDMI* cpu;
        Memory*   memory;
};

#endif