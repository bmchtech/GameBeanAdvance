
/* 
    so, the general idea behind the GBA is this:
    at least now, while im testing the THUMB. we're gonna skip all the ARM instructions
    and just set the PC straight to the beginnings of THUMB. then, we're gonna see what
    we can do from there by editing test-jumptable.cpp
*/

#include <fstream>
#include <iterator>
#include <vector>
#include <iostream>
#include <cstring>
#include <chrono>
#include <thread>
#include <functional>

#include "gba.h"
#include "memory.h"
#include "util.h"
#include "arm7tdmi.h"

extern Memory memory;

GBA::GBA(Memory* memory) {
    cpu          = new ARM7TDMI(memory);
    ppu          = new PPU(memory);
    enabled      = false;

    cpu->set_mode(ARM7TDMI::MODE_SYSTEM);
}

GBA::~GBA() {
    delete memory;
    delete cpu;
}

void gba_thread(GBA* gba) {
    uint64_t instruction_count = 0;

    while (gba->enabled) {
        auto s = std::chrono::steady_clock::now() + std::chrono::milliseconds(1000);
        uint16_t count = 0;

        while (count < 1000) {
            auto x = std::chrono::steady_clock::now() + std::chrono::milliseconds(1);
            
            for (int i = 0; i < 16000; i++) {
                count++;
                gba->cycle();

                instruction_count++;
                std::cout << std::to_string(instruction_count) << std::endl;
            }

            std::this_thread::sleep_until(x);
        }

        if (std::chrono::steady_clock::now() > s) {
            warning("Emulator running too slow!");
        }
    }
}

void GBA::run(std::string rom_name) {
    get_rom_as_bytes(rom_name, memory->rom_1, SIZE_ROM_1);

    // extract the game name
    char game_name[GAME_TITLE_SIZE]; 
    for (int i = 0; i < GAME_TITLE_SIZE; i++) {
        game_name[i] = memory->rom_1[GAME_TITLE_OFFSET + i];
    }
    std::cout << game_name << std::endl;
    *cpu->pc = OFFSET_ROM_1;

    enabled = true;
    std::thread t(gba_thread, this);
    t.detach();
}

void GBA::cycle() {
    cpu->cycle();
    ppu->cycle();
}