#include "ppu.h"
#include "io-map.h"
#include "util.h"

#include <string.h>
#include <iostream>

PPU::PPU(Memory* memory, MyFrame* frame) {
    this->memory = memory;
    this->frame  = frame;
    dot          = 0;
}

void PPU::cycle() {
    // get current scanline
    uint16_t scanline = memory->read_halfword(VCOUNT);

    // update dot and scanline
    dot++;
    if (dot > 960) { // 960 = 240 * 4 = screen_width * cycles_per_pixel
        dot = 0;
        scanline++;

        if (scanline > 227) {
            scanline = 0;
        }
    }
    memory->write_halfword(VCOUNT, scanline);

    // set vblank or hblank accordingly
    if (scanline == 160) { // are we in vblank?
        memory->write_halfword(DISPSTAT, memory->read_halfword(DISPSTAT) | 1);
    }

    bool in_hblank = get_nth_bit(memory->read_halfword(DISPSTAT), 1);
    if ((dot == 1006 - 960 && !in_hblank) || (dot == 0 && in_hblank)) { // should we toggle hblank?
        memory->write_halfword(DISPSTAT, memory->read_halfword(DISPSTAT) ^ 2);
    }
    
    // check the mode and run the appropriate function
    uint8_t mode = get_nth_bits(memory->read_byte(DISPCNT), 0, 2);
    switch (mode) {
        case 3:
            if (dot == 0) {
                for (int x = 0; x < 240; x++) {
                for (int y = 0; y < 160; y++) {
                    uint16_t color = memory->read_halfword(OFFSET_VRAM + 2 * (x + y * 240));
                    frame->SetRGB(x, y, get_nth_bits(color,  0,  5) * 255 / 31,
                                        get_nth_bits(color,  5, 10) * 255 / 31,
                                        get_nth_bits(color, 10, 15) * 255 / 31);
                }
                }
            }
        default:
            // warning("Mode " + std::to_string(mode) + " not supported");
            int x = 2; // stop complaining lol
    }
}