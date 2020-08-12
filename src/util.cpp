#include <iostream>
#include <stdlib.h>

#include "util.h"

void warning(std::string message) {
    std::cerr << YELLOW << "WARNING: " << RESET << message << std::endl;
}

void error(std::string message) {
    std::cerr << RED << "ERROR: " << RESET << message << std::endl;
    exit(EXIT_FAILURE);
}