
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
#include "jumptable/jumptable.h"

extern Memory memory;

int main(int argc, char *argv[]) {
    if (argc == 1) {
        error("Usage: ./gba <rom_name>");
    }
    
    setup_memory();
    
    char* rom_name = argv[1];
    get_rom_as_bytes(rom_name, memory.rom_1, SIZE_ROM_1);

    // extract the game name
    char game_name[GAME_TITLE_SIZE];
    for (int i = 0; i < GAME_TITLE_SIZE; i++) {
        game_name[i] = memory.rom_1[GAME_TITLE_OFFSET + i];
    }
    //std::cout << game_name << std::endl;

    test_thumb();
    return 0;
}

void get_rom_as_bytes(char* rom_name, uint8_t* out, int out_length) {
    // open file
    std::ifstream infile;
    infile.open(rom_name, std::ios::binary);

    // get length of file
    infile.seekg(0, std::ios::end);
    size_t length = infile.tellg();
    infile.seekg(0, std::ios::beg);

    // read file
    char* buffer = new char[length];
    infile.read(buffer, length);

    length = infile.gcount();
    if (out_length < length) {
        warning("ROM file too large, truncating.");
        length = out_length;
    }

    for (int i = 0; i < length; i++) {
        out[i] = buffer[i];
    }
}

/*
    anyway, as stated in the header of the file. all this is PLANNED TO CHANGE.
    in fact, theres probably no way much of the following lines of code end up
    in the final product. but, it'll help me figure out the THUMB, so
*/

// where we should start testing from
#define TEST_PC 0x800010A - 2

// note that prefetches might not even be needed, if i just subtract the proper amount
// when running the opcode.
int fetch() {
    uint16_t opcode = *((uint16_t*)(memory.main + *memory.pc));
    *memory.pc += 2;
    return opcode;
}

void execute(int opcode) {
    jumptable[opcode >> 8](opcode);
}

void test_thumb() {
    *memory.pc = TEST_PC;
    
    // lets see if you can actually fetch anything
    execute(fetch());
    execute(fetch());
    execute(fetch());

    std::cout << "everythings going well so far" << std::endl;
}