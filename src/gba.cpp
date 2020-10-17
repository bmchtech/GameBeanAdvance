
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

#include "gba.h"
#include "memory.h"
#include "util.h"
#include "arm7tdmi.h"

extern Memory memory;

GBA::GBA() {
    memory = new Memory();
    cpu    = new ARM7TDMI(memory);

    cpu->set_mode(MODE_SYSTEM);
}

GBA::~GBA() {
    delete memory;
    delete cpu;
}

void GBA::run(std::string rom_name) {
    get_rom_as_bytes(rom_name, memory->rom_1, SIZE_ROM_1);
    // extract the game name
    char game_name[GAME_TITLE_SIZE]; 
    for (int i = 0; i < GAME_TITLE_SIZE; i++) {
        game_name[i] = memory->rom_1[GAME_TITLE_OFFSET + i];
    }
    std::cout << game_name << std::endl;
}