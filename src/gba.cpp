
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
#include "jumptable/jumptable-thumb.h"
#include "jumptable/jumptable-arm.h"

extern Memory memory;

void run(std::string rom_name) {
    setup_memory();
    
    get_rom_as_bytes(rom_name, memory.rom_1, SIZE_ROM_1);

    // extract the game name
    char game_name[GAME_TITLE_SIZE]; 
    for (int i = 0; i < GAME_TITLE_SIZE; i++) {
        game_name[i] = memory.rom_1[GAME_TITLE_OFFSET + i];
    }
    std::cout << game_name << std::endl;
}

void get_rom_as_bytes(std::string rom_name, uint8_t* out, int out_length) {
    // open file
    std::ifstream infile;
    infile.open(rom_name, std::ios::binary);

    // check if file exists
    if (!infile.good()) {
        error("ROM not found, are you sure you gave the right file name?");
    }

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

// note that prefetches might not even be needed, if i just subtract the proper amount
// when running the opcode.
int fetch() {
    if (get_bit_T()) {
        uint16_t opcode = *((uint16_t*)(memory.main + (*memory.pc & 0xFFFFFFFE)));
        *memory.pc += 2;
        return opcode;
    } else {
        uint32_t opcode = *((uint32_t*)(memory.main + (*memory.pc & 0xFFFFFFFE)));
        *memory.pc += 4;
        return opcode;
    }
}

// determines whether or not this function should execute based on COND (the high 4 bits of the opcode)
// note that this only applies to ARM instructions.
bool should_execute(int cond) {
    if (cond == 0b1110) [[likely]] {
        return true;
    }

    switch (cond) {
        case 0b0000: return  get_flag_Z(); break;
        case 0b0001: return !get_flag_Z(); break;
        case 0b0010: return  get_flag_C(); break;
        case 0b0011: return !get_flag_C(); break;
        case 0b0100: return  get_flag_N(); break;
        case 0b0101: return !get_flag_N(); break;
        case 0b0110: return  get_flag_V(); break;
        case 0b0111: return !get_flag_V(); break;
        case 0b1000: return  get_flag_C() && !get_flag_Z(); break;
        case 0b1001: return !get_flag_C() ||  get_flag_Z(); break;
        case 0b1010: return  get_flag_N() ==  get_flag_V(); break;
        case 0b1011: return  get_flag_N() !=  get_flag_V(); break;
        case 0b1100: return !get_flag_Z() &&  (get_flag_N() == get_flag_V()); break;
        case 0b1101: return  get_flag_Z() &&  (get_flag_N() != get_flag_V()); break;
        default:     return false;
    }
}

void execute(int opcode) {
    if (get_bit_T()) {
        jumptable_thumb[opcode >> 8](opcode);
    } else {
        if (should_execute(opcode & 0xF0000000 >> 28)) {
            jumptable_arm[opcode >> 20](opcode);
        }
    }
}