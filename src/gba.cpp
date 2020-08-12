#include <fstream>
#include <iterator>
#include <vector>
#include <iostream>
#include <cstring>

#include "gba.h"
#include "memory.h"

extern Memory memory;

int main(int argc, char *argv[]) {
    if (argc == 1) {
        // some kind of error formatting
        std::cerr << "Usage: ./gba <rom_name>" << std::endl;
        exit(-1);
    }
    
    setup_memory();
    
    char* rom_name = argv[1];
    get_rom_as_bytes(rom_name, memory.rom_1, SIZE_ROM_1);

    // extract the game name
    char game_name[GAME_TITLE_SIZE];
    for (int i = 0; i < GAME_TITLE_SIZE; i++) {
        game_name[i] = memory.rom_1[GAME_TITLE_OFFSET + i];
    }
    std::cout << game_name << std::endl;

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

    int smaller_length = out_length < length ? out_length : length;
    for (int i = 0; i < smaller_length; i++) {
        out[i] = buffer[i];
    }
}