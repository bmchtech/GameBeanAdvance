#include <iostream>
#include <stdlib.h>
#include <sstream>
#include <fstream>

#include "util.h"

void warning(std::string message) {
    std::cerr << YELLOW << "WARNING: " << RESET << message << std::endl;
}

void error(std::string message) {
    std::cerr << RED << "ERROR: " << RESET << message << std::endl;
    exit(EXIT_FAILURE);
}

std::string to_hex_string(uint32_t val) {
    std::stringstream ss;
    ss << std::hex << (int)val;
    return ss.str();
}

void get_rom_as_bytes(std::string rom_name, uint8_t* out, size_t out_length) {
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

    delete[] buffer;
}