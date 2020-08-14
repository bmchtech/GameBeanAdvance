#ifndef UTIL_H
#define UTIL_H

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

#endif