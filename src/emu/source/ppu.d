module ppu;

import memory;
import util;

class PPU {
    // General information:
    // - Contains 227 scanlines, 160+ is VBLANK. VBLANK is not set on scanline 227.
    // - HBLANK is constantly toggled
    // - Although the drawing time is only 960 cycles (240*4), the H-Blank flag is "0" for a total of 1006 cycles.

public:
    this(Memory memory) {
        this.memory = memory;
        dot         = 0;
    }

    void update_dot_and_scanline() {
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
    }
    
    void cycle() {
        update_dot_and_scanline();
        
        // if we are hblank or vblank then we do not draw anything
        if (dot >= 240 || scanline >= 160) {
            return;
        }

        // check the mode and run the appropriate function
        ubyte mode = cast(ubyte) get_nth_bits(*memory.DISPCNT, 0, 3);
        // std::cout << to_hex_string(*memory.DISPCNT) << std::endl;

        switch (mode) {
            case 0: {
                // DISPCNT bits 8-11 tell us which backgrounds should be rendered.
                if (get_nth_bit(*memory.DISPCNT,  8)) render_background_mode0(*memory.BG0CNT, *memory.BG0HOFS, *memory.BG0VOFS);
                if (get_nth_bit(*memory.DISPCNT,  9)) render_background_mode0(*memory.BG1CNT, *memory.BG1HOFS, *memory.BG1VOFS);
                if (get_nth_bit(*memory.DISPCNT, 10)) render_background_mode0(*memory.BG2CNT, *memory.BG2HOFS, *memory.BG2VOFS);
                if (get_nth_bit(*memory.DISPCNT, 11)) render_background_mode0(*memory.BG3CNT, *memory.BG3HOFS, *memory.BG3VOFS);
                break;
            }

            case 3: {
                // in mode 3, the dot and scanline (x and y) simply tell us where to read from in VRAM. The colors
                // are stored directly, so we just read from VRAM and interpret as a 15bit highcolor
                ushort color = memory.read_halfword(memory.OFFSET_VRAM + 2 * (dot + scanline * 240));
                memory.set_rgb(dot, scanline, cast(ubyte) (get_nth_bits(color,  0,  5) * 255 / 31),
                                             cast(ubyte) (get_nth_bits(color,  5, 10) * 255 / 31),
                                             cast(ubyte) (get_nth_bits(color, 10, 15) * 255 / 31));

                break;
            }

            case 4:
            case 5: {
                // modes 4 and 5 are a step up from mode 3. the address of where the colors are stored can
                // be found using DISPCNT.
                uint   base_frame_address = memory.OFFSET_VRAM + get_nth_bit(*memory.DISPCNT, 4) * 0xA000;

                // the index in palette ram that we need to look into is then found in the base frame.
                uint   index = memory.read_byte(base_frame_address + (dot + scanline * 240));

                // we grab the color, interpret it as 15bit highcolor and render it.
                ushort color = memory.read_halfword(memory.OFFSET_PALETTE_RAM + index);
                memory.set_rgb(dot, scanline, cast(ubyte) (get_nth_bits(color,  0,  5) * 255 / 31),
                                             cast(ubyte) (get_nth_bits(color,  5, 10) * 255 / 31),
                                             cast(ubyte) (get_nth_bits(color, 10, 15) * 255 / 31));

                break;
            }
                
            default:
                // warning("Mode " + std::to_string(mode) + " not supported");
                int x = 2; // stop complaining lol
        }
    }

private:
    Memory memory;
    ushort dot; // the horizontal counterpart to scanlines.

    void render_background_mode0(ushort bgcnt, ushort bghofs, ushort bgvofs) {
        // dot and VCOUNT are normally x and y respectively. we add bghofs and bgvofs which are
        // registers used for scrolling. this allows the CPU to scroll x and y.
        ushort x            = cast(ushort) (dot            + bghofs);
        ushort y            = cast(ushort) (*memory.VCOUNT + bgvofs);

        // the tile base address is where we will find out tilemap.
        uint   tile_base_address   = memory.OFFSET_VRAM + get_nth_bits(bgcnt, 2,  4) * 0x4000;

        // the screen base address is where we will find the indices that point to the tilemap.
        uint   screen_base_address = memory.OFFSET_VRAM + get_nth_bits(bgcnt, 8, 13) * 0x800;

        // x and y point to somewhere within the 240x180 screen. tiles are 8x8. we can figure out
        // which tile we are looking at by getting the high five bits (sc_x and sc_y), and we can
        // figure out the offset we are at within the tile by grabbing the low 3 bits (tile_x and
        // tile_y).
        ushort sc_x         = (x >> 3) & 0x1f;
        ushort sc_y         = (y >> 3) & 0x1f;
        ushort tile_x       = x & 0b111;
        ushort tile_y       = y & 0b111;

        // TODO: the following line of code assumes screen size is 3
        // the PPU can have up to 4 screens. graphically, the screens are laid out like this:
        // -----------------------------------------------------------
        // |                            |                            |
        // |                            |                            |
        // |          SCREEN 0          |         SCREEN 1           |
        // |          +0x0000           |         +0x0800            |
        // |                            |                            |
        // |                            |                            |
        // -----------------------------------------------------------
        // |                            |                            |
        // |                            |                            |
        // |          SCREEN 2          |         SCREEN 3           |
        // |          +0x1000           |         +0x1800            |
        // |                            |                            |
        // |                            |                            |
        // -----------------------------------------------------------
        //
        // in order to read from the right place in memory, we need to know what screen we are at.
        // since each screen is 32x32 tiles (256x256 pixels), we can get the screen by taking the
        // 9th bits in x and y and combining them together.

        ubyte  screen       = ((x >> 8) & 1) + (((y >> 8) & 1) << 1);
        // std::cout << std::to_string(screen) << std::endl;
        screen_base_address  += screen * 0x800;

        // we use sc_x and sc_y from earlier to get the current tile. each tile is a halfword, so we
        // multiply (sc_x + (sc_y * 32)) by 2.
        ushort current_tile = memory.read_halfword(screen_base_address + (sc_x + (sc_y * 32)) * 2);

        // only the upper 9 bits of current_tile are relevant. we use these to get the index into the palette ram
        // for the particular pixel are are interested in (determined by tile_x and tile_y).
        ubyte  index        = memory.read_byte(tile_base_address + ((current_tile & 0x1ff) * 64) + tile_y * 8 + tile_x);

        // and we grab that pixel from palette ram and interpret it as 15bit highcolor.
        uint color = memory.read_halfword(memory.OFFSET_PALETTE_RAM + index * 2);
        memory.set_rgb(dot, *memory.VCOUNT, cast(ubyte) (get_nth_bits(color,  0,  5) * 255 / 31),
                                           cast(ubyte) (get_nth_bits(color,  5, 10) * 255 / 31),
                                           cast(ubyte) (get_nth_bits(color, 10, 15) * 255 / 31));
    }
}
