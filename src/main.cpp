#include "gba.h"
#include "util.h"

int main(int argc, char** argv) {
    if (argc == 1) {
        error("Usage: ./gba <rom_name>");
    }
    
    GBA* gba = new GBA();
    gba->run(argv[1]);

    return 0;
}