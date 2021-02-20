#ifndef UTIL_H
#define UTIL_H

#include <math.h>
#include <string>

class GBA;

// the color for message output
#define YELLOW  "\033[33m"
#define RED     "\033[31m" 
#define RESET   "\033[0m"

// a warning will not terminate the program
void warning(std::string message);

// an error terminates the program and calls exit(EXIT_FAILURE);
void error  (std::string message);

// converts uint32_t to hex string
std::string to_hex_string(uint32_t val);

// get nth bits from value as so: [start, end)
inline uint32_t get_nth_bits(uint32_t val, uint8_t start, uint8_t end) {
    return (val >> start) & (uint32_t)(pow(2, end - start) - 1);
}

// get nth bit from value
inline bool get_nth_bit(uint32_t val, uint8_t n) {
    return (val >> n) & 1;
}

// sign extend the given value
inline uint32_t sign_extend(uint32_t val, uint8_t num_bits) {
    return (val ^ (1U << (num_bits - 1))) - (1U << (num_bits - 1));
}

// reads the ROM as bytes (given the file name). stores the result into out. any data after out_length will be truncated
// off the ROM.
void get_rom_as_bytes(std::string rom_name, uint8_t* out, size_t out_length);

// set this to enable gba logging
GBA* logger_gba;

#endif