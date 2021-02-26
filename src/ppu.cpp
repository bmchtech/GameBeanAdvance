#include "ppu.h"
#include "util.h"

#include <string.h>
#include <iostream>

PPU::PPU(Memory* memory) {
    this->memory = memory;
    dot          = 0;
}

void PPU::cycle() {
    // get current scanline
    uint16_t scanline = *memory->VCOUNT;

    // update dot and scanline
    dot++;
    if (dot > 960) { // 960 = 240 * 4 = screen_width * cycles_per_pixel
        dot = 0;
        scanline++;

        if (scanline > 227) {
            scanline = 0;
            memory->has_updated = true;
        }
    }
    *memory->VCOUNT = scanline;

    // set vblank or hblank accordingly
    if (scanline == 160) { // are we in vblank?
        *memory->DISPSTAT |= 1;
    }

    bool in_hblank = get_nth_bit(*memory->DISPSTAT, 1);
    if ((dot == 1006 - 960 && !in_hblank) || (dot == 0 && in_hblank)) { // should we toggle hblank?
        *memory->DISPSTAT ^= 2;
    }
    
    // if we are hblank or vblank then we do not draw anything
    if (dot >= 240 || scanline >= 160) {
        return;
    }

    // check the mode and run the appropriate function
    uint8_t mode = get_nth_bits(*memory->DISPCNT, 0, 3);

    switch (mode) {
        case 0: {
            uint16_t x            = dot      + *memory->BG0HOFS;
            uint16_t y            = scanline + *memory->BG0VOFS;

            uint32_t tile_base_address   = OFFSET_VRAM + get_nth_bits(*memory->BG0CNT, 2,  4) * 0x4000;
            uint32_t screen_base_address = OFFSET_VRAM + get_nth_bits(*memory->BG0CNT, 8, 13) * 0x800;
            uint16_t tile_x       = x & 0b111;
            uint16_t tile_y       = y & 0b111;
            uint16_t sc_x         = (x >> 3) & 0x1f;
            uint16_t sc_y         = (y >> 3) & 0x1f;

            // TODO: the following line of code assumes screen size is 3
            uint8_t  screen       = ((x >> 8) & 1) + (((y >> 8) & 1) << 1);
            // std::cout << std::to_string(screen) << std::endl;
            screen_base_address  += screen * 0x800;

            uint16_t current_tile = memory->read_halfword(screen_base_address + (sc_x + (sc_y * 32)) * 2);
            uint8_t  index        = memory->read_byte(tile_base_address + ((current_tile & 0x1ff) * 64) + tile_y * 8 + tile_x);

            /*
            uint8_t  tile_x       = (dot      % 8);
            uint8_t  tile_y       = (scanline % 8);
            uint8_t  current_tile = ((dot / 8) + (scanline / 8) * 32);

            uint32_t screen_base_address = OFFSET_VRAM + get_nth_bits(*memory->BG3CNT, 2, 4) * 0x4000;
            // TODO: bit depth
            uint8_t  index = memory->read_byte(screen_base_address + current_tile * 64 + tile_y * 8 + tile_x);//*/
            uint16_t color = memory->read_halfword(OFFSET_PALETTE_RAM + index * 2);
            memory->SetRGB(dot, scanline, get_nth_bits(color,  0,  5) * 255 / 31,
                                          get_nth_bits(color,  5, 10) * 255 / 31,
                                          get_nth_bits(color, 10, 15) * 255 / 31);
            break;
        }

        case 3: {
            uint16_t color = memory->read_halfword(OFFSET_VRAM + 2 * (dot + scanline * 240));
            memory->SetRGB(dot, scanline, get_nth_bits(color,  0,  5) * 255 / 31,
                                          get_nth_bits(color,  5, 10) * 255 / 31,
                                          get_nth_bits(color, 10, 15) * 255 / 31);

            break;
        }

        case 4:
        case 5: {
            uint32_t base_frame_address = OFFSET_VRAM + get_nth_bit(*memory->DISPCNT, 4) * 0xA000;
            uint32_t index = memory->read_byte(base_frame_address + (dot + scanline * 240));
            uint16_t color = memory->read_halfword(OFFSET_PALETTE_RAM + index);
            memory->SetRGB(dot, scanline, get_nth_bits(color,  0,  5) * 255 / 31,
                                          get_nth_bits(color,  5, 10) * 255 / 31,
                                          get_nth_bits(color, 10, 15) * 255 / 31);

            break;
        }
            
        default:
            // warning("Mode " + std::to_string(mode) + " not supported");
            int x = 2; // stop complaining lol
    }
}