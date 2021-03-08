module ppu;

import memory;

class PPU {
    // General information:
    // - Contains 227 scanlines, 160+ is VBLANK. VBLANK is not set on scanline 227.
    // - HBLANK is constantly toggled
    // - Although the drawing time is only 960 cycles (240*4), the H-Blank flag is "0" for a total of 1006 cycles.

public:
    this(Memory* memory) {
        this.memory = memory;
        dot         = 0;
    }

    void cycle() {
        // get current scanline
        ushort scanline = *memory.VCOUNT;

        // update dot and scanline
        dot++;
        if (dot > 960) { // 960 = 240 * 4 = screen_width * cycles_per_pixel
            dot = 0;
            scanline++;

            if (scanline > 227) {
                scanline = 0;
                memory.has_updated = true;
            }
        }
        *memory.VCOUNT = scanline;

        // set vblank or hblank accordingly
        if (scanline == 160) { // are we in vblank?
            *memory.DISPSTAT |= 1;
        }

        bool in_hblank = get_nth_bit(*memory.DISPSTAT, 1);
        if ((dot == 1006 - 960 && !in_hblank) || (dot == 0 && in_hblank)) { // should we toggle hblank?
            *memory.DISPSTAT ^= 2;
        }
        
        // if we are hblank or vblank then we do not draw anything
        if (dot >= 240 || scanline >= 160) {
            return;
        }

        // check the mode and run the appropriate function
        ubyte mode = get_nth_bits(*memory.DISPCNT, 0, 3);
        // std::cout << to_hex_string(*memory.DISPCNT) << std::endl;

        switch (mode) {
            case 0: {
                if (get_nth_bit(*memory.DISPCNT,  8)) render_background_mode0(*memory.BG0CNT, *memory.BG0HOFS, *memory.BG0VOFS);
                if (get_nth_bit(*memory.DISPCNT,  9)) render_background_mode0(*memory.BG1CNT, *memory.BG1HOFS, *memory.BG1VOFS);
                if (get_nth_bit(*memory.DISPCNT, 10)) render_background_mode0(*memory.BG2CNT, *memory.BG2HOFS, *memory.BG2VOFS);
                if (get_nth_bit(*memory.DISPCNT, 11)) render_background_mode0(*memory.BG3CNT, *memory.BG3HOFS, *memory.BG3VOFS);
                break;
            }

            case 3: {
                ushort color = memory.read_halfword(OFFSET_VRAM + 2 * (dot + scanline * 240));
                memory.SetRGB(dot, scanline, get_nth_bits(color,  0,  5) * 255 / 31,
                                            get_nth_bits(color,  5, 10) * 255 / 31,
                                            get_nth_bits(color, 10, 15) * 255 / 31);

                break;
            }

            case 4:
            case 5: {
                uint32_t base_frame_address = OFFSET_VRAM + get_nth_bit(*memory.DISPCNT, 4) * 0xA000;
                uint32_t index = memory.read_byte(base_frame_address + (dot + scanline * 240));
                uint16_t color = memory.read_halfword(OFFSET_PALETTE_RAM + index);
                memory.SetRGB(dot, scanline, get_nth_bits(color,  0,  5) * 255 / 31,
                                            get_nth_bits(color,  5, 10) * 255 / 31,
                                            get_nth_bits(color, 10, 15) * 255 / 31);

                break;
            }
                
            default:
                // warning("Mode " + std::to_string(mode) + " not supported");
                int x = 2; // stop complaining lol
        }
    }

private:
    Memory* memory;
    ushort dot; // the horizontal counterpart to scanlines.

    void render_background_mode0(ushort bgcnt, ushort bghofs, ushort bgvofs) {
        ushort x            = dot             + bghofs;
        ushort y            = *memory.VCOUNT + bgvofs;

        uint   tile_base_address   = OFFSET_VRAM + get_nth_bits(bgcnt, 2,  4) * 0x4000;
        uint   screen_base_address = OFFSET_VRAM + get_nth_bits(bgcnt, 8, 13) * 0x800;
        ushort tile_x       = x & 0b111;
        ushort tile_y       = y & 0b111;
        ushort sc_x         = (x >> 3) & 0x1f;
        ushort sc_y         = (y >> 3) & 0x1f;

        // TODO: the following line of code assumes screen size is 3
        ubyte  screen       = ((x >> 8) & 1) + (((y >> 8) & 1) << 1);
        // std::cout << std::to_string(screen) << std::endl;
        screen_base_address  += screen * 0x800;

        ushort current_tile = memory.read_halfword(screen_base_address + (sc_x + (sc_y * 32)) * 2);
        ubyte  index        = memory.read_byte(tile_base_address + ((current_tile & 0x1ff) * 64) + tile_y * 8 + tile_x);

        /*
        uint8_t  tile_x       = (dot      % 8);
        uint8_t  tile_y       = (scanline % 8);
        uint8_t  current_tile = ((dot / 8) + (scanline / 8) * 32);

        uint32_t screen_base_address = OFFSET_VRAM + get_nth_bits(*memory.BG3CNT, 2, 4) * 0x4000;
        // TODO: bit depth
        uint8_t  index = memory.read_byte(screen_base_address + current_tile * 64 + tile_y * 8 + tile_x);//*/
        uint color = memory.read_halfword(OFFSET_PALETTE_RAM + index * 2);
        memory.SetRGB(dot, *memory.VCOUNT, get_nth_bits(color,  0,  5) * 255 / 31,
                                            get_nth_bits(color,  5, 10) * 255 / 31,
                                            get_nth_bits(color, 10, 15) * 255 / 31);
    }
}
