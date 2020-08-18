#include "gba.h"
#include "util.h"

int main(int argc, char** argv) {
    if (argc == 1) {
        error("Usage: ./gba <rom_name>");
    }
    
    run(argv[1]);
}