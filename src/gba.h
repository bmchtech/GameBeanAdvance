#ifndef GBA_H
#define GBA_H

#include "memory.h"
#include "arm7tdmi.h"
#include "ppu.h"
#include "gui/main.h"
#include <string>

#ifndef WX_PRECOMP
       #include <wx/wx.h>
#endif

#define CART_SIZE                0x1000000

#define ROM_ENTRY_POINT          0x000
#define GAME_TITLE_OFFSET        0x0A0
#define GAME_TITLE_SIZE          12

class GBA {

    public:
        // Allocates the memory and sets the mode to System.
        GBA(MyFrame* frame);

        // Frees the memory - classic destructor.
        ~GBA();

        // TODO: run the GBA. probably going to be one of the last things that is actually implemented, since manually cycling
        // the emulator is a lot easier to test. heck, this method might not even exist, idk. but, it's here for now.
        void run(std::string rom_name);

        // cycles the GBA CPU once, executing one instruction to completion.
        // maybe this method belongs in an ARM7TDMI class. nobody knows. i don't see the reason for having such a class, so
        // this is staying here for now.
        void cycle();

        bool enabled;

        ARM7TDMI* cpu;
        PPU*      ppu;
    
    private:
        Memory*   memory;
};

#endif