module ppu;

import memory;
import util;
import background;

class PPU {
    // General information:
    // - Contains 227 scanlines, 160+ is VBLANK. VBLANK is not set on scanline 227.
    // - HBLANK is constantly toggled
    // - Although the drawing time is only 960 cycles (240*4), the H-Blank flag is "0" for a total of 1006 cycles.

public:
    this(Memory memory) {
        this.memory = memory;
        dot         = 0;

        background_init(memory);
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
        ushort scanline = *memory.VCOUNT;
        if (dot >= 240 || scanline >= 160) {
            return;
        }


        // only begin rendering if we are on the first cycle
        if (dot != 0) return;

        // check the mode and run the appropriate function
        ubyte mode = cast(ubyte) get_nth_bits(*memory.DISPCNT, 0, 3);
        switch (mode) {
            case 0: {
                // DISPCNT bits 8-11 tell us which backgrounds should be rendered.
                render_background_mode0(background_0, scanline);
                render_background_mode0(background_1, scanline);
                render_background_mode0(background_2, scanline);
                render_background_mode0(background_3, scanline);
                render_sprites(scanline);
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

    void render_background_mode0(Background background, int scanline) {
        // do we even render?
        if (!get_nth_bit(*memory.DISPCNT, background.enabled_bit)) return;

        for (ushort x_ofs = 0; x_ofs < 240; x_ofs++) {
            ushort x = cast(ushort) (dot      + *background.x_offset + x_ofs);
            ushort y = cast(ushort) (scanline + *background.y_offset);

            // the tile base address is where we will find out tilemap.
            uint tile_base_address   = memory.OFFSET_VRAM + get_nth_bits(*background.control, 2,  4) * 0x4000;

            // the screen base address is where we will find the indices that point to the tilemap.
            uint screen_base_address = memory.OFFSET_VRAM + get_nth_bits(*background.control, 8, 13) * 0x800;

            // x and y point to somewhere within the 240x180 screen. tiles are 8x8. we can figure out
            // which tile we are looking at by getting the high five bits (sc_x and sc_y), and we can
            // figure out the offset we are at within the tile by grabbing the low 3 bits (tile_x and
            // tile_y).
            ushort sc_x   = (x >> 3) & 0x1f;
            ushort sc_y   = (y >> 3) & 0x1f;
            ushort tile_x = x & 0b111;
            ushort tile_y = y & 0b111;

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
            memory.set_rgb(dot + x_ofs, *memory.VCOUNT, cast(ubyte) (get_nth_bits(color,  0,  5) * 255 / 31),
                                                        cast(ubyte) (get_nth_bits(color,  5, 10) * 255 / 31),
                                                        cast(ubyte) (get_nth_bits(color, 10, 15) * 255 / 31));
        }
    }

    // sprite_sizes[size][shape] = (width, height)
    const static ubyte[2][4][3] sprite_sizes = [
        [
            [8,  8],
            [16, 16],
            [32, 32],
            [64, 64]
        ],

        [
            [16, 8],
            [32, 8],
            [32, 16],
            [64, 32]
        ],

        [
            [ 8, 16],
            [ 8, 32],
            [16, 32],
            [32, 64]
        ]
    ];

    void render_sprites(ushort scanline) {
        for (int sprite = 0; sprite < 128; sprite++) {
            // collect info that we need to figure out if this sprite is rendered or not.
            ushort attribute_0 = memory.read_halfword(memory.OFFSET_OAM + sprite * 8 + 0);

            // first of all is this sprite even enabled
            if (get_nth_bits(attribute_0, 8, 9) == 0b01) return;

            // yes? ok get attribute 1 and check if this sprite is rendered
            ushort attribute_1 = memory.read_halfword(memory.OFFSET_OAM + sprite * 8 + 2);

            ubyte size   = cast(ubyte) get_nth_bits(attribute_1, 14, 16);
            ubyte shape  = cast(ubyte) get_nth_bits(attribute_0, 14, 16);

            ubyte y      = cast(ubyte) get_nth_bits(attribute_1,  0,  8);
            ubyte height = sprite_sizes[size][shape][1];

            // is this sprite rendered or not in this scanline
            if (scanline < y || scanline >= y + height) return;

            // collect the rest of the information we need for rendering
            ushort attribute_2 = memory.read_halfword(memory.OFFSET_OAM + sprite * 8 + 4);

            ubyte x      = cast(ubyte) get_nth_bits(attribute_0,  0,  8);
            ubyte width  = sprite_sizes[size][shape][0];

            ushort tile_number = cast(ushort) get_nth_bits(attribute_2, 0, 10);

            // colors / palettes
            if (get_nth_bit(attribute_0, 13)) { // 16 / 16
                // ubyte palette = get_nth_bits(attribute_2, 12, 16);
            } else { // 256 / 1
                for (ubyte draw_x = x; draw_x < x + width; draw_x++) {
                    // TODO: REPEATED CODE

                    uint tile_base_address = memory.OFFSET_VRAM; // probably wrong lol

                    // only the upper 9 bits of current_tile are relevant. we use these to get the index into the palette ram
                    // for the particular pixel are are interested in (determined by tile_x and tile_y).
                    ubyte index = memory.read_byte(tile_base_address + ((tile_number & 0x1ff) * 64) + (scanline - y) * 8 + (draw_x - x));

                    // and we grab that pixel from palette ram and interpret it as 15bit highcolor.
                    uint color = memory.read_halfword(memory.OFFSET_PALETTE_RAM + index * 2);
                    memory.set_rgb(dot + draw_x, *memory.VCOUNT, cast(ubyte) (get_nth_bits(color,  0,  5) * 255 / 31),
                                                                 cast(ubyte) (get_nth_bits(color,  5, 10) * 255 / 31),
                                                                 cast(ubyte) (get_nth_bits(color, 10, 15) * 255 / 31));
                }
            }
        }
    }
}
