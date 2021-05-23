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
    void delegate(uint) interrupt_cpu;

    this(Memory memory, void delegate(uint) interrupt_cpu) {
        this.memory        = memory;
        this.interrupt_cpu = interrupt_cpu;
        dot                = 0;
        scanline           = 0;
        pixel_priorities   = new uint[][](240, 160);

        background_init(memory);
    }

    void update_dot_and_scanline() {
        // update dot and scanline
        dot++;
        if (dot > 307) { // 960 = 240 * 4 = screen_width * cycles_per_pixel
            dot = 0;
            scanline++;

            if (scanline > 227) {
                scanline = 0;
                vblank = false;
                memory.has_updated = true;

                // 100 should be more than big enough
                for (int x = 0; x < 240; x++)
                for (int y = 0; y < 160; y++)
                    pixel_priorities[x][y] = 100;
            }
        }

        // set vblank or hblank accordingly
        if (scanline == 160 && dot == 0) { // are we in vblank?
            vblank = true;
            if (vblank_irq_enabled) interrupt_cpu(1);
        }

        if ((dot == 1006 - 960 && hblank) || (dot == 0 && hblank)) { // should we toggle hblank?
            hblank = !hblank;
        }
    }

    void cycle() {
        update_dot_and_scanline();
        
        // if we are hblank or vblank then we do not draw anything
        if (hblank) {
            return;
        }

        // only begin rendering if we are on the first cycle
        if (dot != 0) return;

        switch (bg_mode) {
            case 0: {
                // DISPCNT bits 8-11 tell us which backgrounds should be rendered.
                render_background_mode0(backgrounds[0]);
                render_background_mode0(backgrounds[1]);
                render_background_mode0(backgrounds[2]);
                render_background_mode0(backgrounds[3]);
                render_sprites();
                test_render_sprites();
                // test_render_palette();
                break;
            }

            case 3: {
                // in mode 3, the dot and scanline (x and y) simply tell us where to read from in VRAM. The colors
                // are stored directly, so we just read from VRAM and interpret as a 15bit highcolor
                for (uint x = 0; x < 240; x++) 
                    draw_pixel(memory.OFFSET_VRAM, x + scanline * 240, x, scanline);

                break;
            }

            case 4:
            case 5: {
                // modes 4 and 5 are a step up from mode 3. the address of where the colors are stored can
                // be found using DISPCNT.
                uint base_frame_address = memory.OFFSET_VRAM + disp_frame_select * 0xA000;


                for (uint x = 0; x < 240; x++) {
                    // the index in palette ram that we need to look into is then found in the base frame.
                    uint index = memory.read_byte(base_frame_address + (x + scanline * 240));
                    draw_pixel(memory.OFFSET_PALETTE_RAM, index, x, scanline);
                }

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
    ushort scanline;
    uint[][] pixel_priorities; // the associated priorities with each pixel.

    void render_background_mode0(Background background) {
        // do we even render?
        if (!background.enabled) return;

        for (ushort x_ofs = 0; x_ofs < 240; x_ofs++) {
            ushort x = cast(ushort) (dot      + background.x_offset + x_ofs);
            ushort y = cast(ushort) (scanline + background.y_offset);

            // the tile base address is where we will find out tilemap.
            uint tile_base_address   = memory.OFFSET_VRAM + background.character_base_block * 0x4000;

            // the screen base address is where we will find the indices that point to the tilemap.
            uint screen_base_address = memory.OFFSET_VRAM + background.screen_base_block    * 0x800;

            // x and y point to somewhere within the 240x180 screen. tiles are 8x8. we can figure out
            // which tile we are looking at by getting the high five bits (sc_x and sc_y), and we can
            // figure out the offset we are at within the tile by grabbing the low 3 bits (tile_x and
            // tile_y).
            // 1000_0000
            // 0, 10
            // 0, 0
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
            // if ((sc_x + (sc_y * 32)) * 2 == 0x400) warning(format("tile: %x %x", (sc_x + (sc_y * 32)) * 2, current_tile));

            uint priority = background.priority * 2 + 1;

            // palettes / colors ratio?
            if (background.doesnt_use_color_palettes) { // 256 / 1
                // only the upper 10 bits of current_tile are relevant. we use these to get the index into the palette ram
                // for the particular pixel are are interested in (determined by tile_x and tile_y).
                ubyte index = memory.read_byte(tile_base_address + ((current_tile & 0x3ff) * 64) + tile_y * 8 + tile_x);

                // and we grab that pixel from palette ram and interpret it as 15bit highcolor.
                uint color = memory.read_halfword(memory.OFFSET_PALETTE_RAM + index * 2);
                maybe_draw_pixel(memory.OFFSET_PALETTE_RAM, index, priority, x_ofs, scanline);
            } else { // 16 / 16
                // same as above, but the upper 4 bits of current_tile specify a color palette. there are 16 color palettes,
                // each of which is 16 bytes long.
                ubyte index = memory.read_byte(tile_base_address + ((current_tile & 0x3ff) * 32) + tile_y * 4 + (tile_x / 2));
                if (tile_x % 2 == 0) {
                    index &= 0xF;
                } else {
                    index >>= 4;
                }

                index += get_nth_bits(current_tile, 12, 16) * 16;
                maybe_draw_pixel(memory.OFFSET_PALETTE_RAM, index, priority, x_ofs, scanline);
            }
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

    void render_sprites() {
        // Very useful guide for attributes! https://problemkaputt.de/gbatek.htm#lcdobjoamattributes
        for (int sprite = 0; sprite < 128; sprite++) {
            // first of all, we need to figure out if we render this sprite in the first place.
            // so, we collect a bunch of info that'll help us figure that out.
            ushort attribute_0 = memory.read_halfword(memory.OFFSET_OAM + sprite * 8 + 0);

            // is this sprite even enabled
            if (get_nth_bits(attribute_0, 8, 10) == 0b10) continue;
            // it is enabled? great. now, we need to check which if the sprite appears in the
            // current scanline. for that, we need attribute 1.
            ushort attribute_1 = memory.read_halfword(memory.OFFSET_OAM + sprite * 8 + 2);

            // get the size and shape of the sprite so we know its height
            ubyte size   = cast(ubyte) get_nth_bits(attribute_1, 14, 16);
            ubyte shape  = cast(ubyte) get_nth_bits(attribute_0, 14, 16);

            // get y and height from attribute_0 and the sprite_sizezs lookup table.
            byte y       = cast(byte) get_nth_bits(attribute_0,  0,  8);
            ubyte height = sprite_sizes[shape][size][1];

            // is this sprite rendered or not in this scanline
            if (scanline < y || scanline >= y + height) continue;

            // now we need to get attribute 2, as well as the x position and the sprite width.
            ushort attribute_2 = memory.read_halfword(memory.OFFSET_OAM + sprite * 8 + 4);

            int x        = sign_extend(cast(ubyte) get_nth_bits(attribute_1,  0,  9), 9);
            ubyte width  = sprite_sizes[shape][size][0];

            // if (sprite == 0) 

            // base_tile_number is going to be the tile number of the left-most tile that makes
            // up the sprite in the current scanline. to calculate this, we first get the topleft 
            // tile. then, we add (width / 8) * ((scanline - y) / 8). note that (scanline - y) / 8
            // tells us the current tile row we are rendering, and (width / 8) is the width of the
            // sprite in tiles.
            ushort base_tile_number = cast(ushort) get_nth_bits(attribute_2, 0, 10);
            uint priority = 2 * get_nth_bits(attribute_2, 10, 11);

            // colors / palettes
            if (get_nth_bit(attribute_0, 13)) { // 256 / 1
                if (obj_character_vram_mapping) {
                    base_tile_number += (width / 8) * ((scanline - y) / 8) * 2;
                } else {
                    base_tile_number += 32 * ((scanline - y) / 8) * 2;
                }
                // ubyte palette = get_nth_bits(attribute_2, 12, 16);
                for (int draw_x = x; draw_x < x + width; draw_x++) {
                    uint tile_base_address = memory.OFFSET_VRAM + 0x10000; // probably wrong lol

                    uint shifted_tile_number = base_tile_number + ((draw_x - x) / 8) * 2;
                    // only the upper 10 bits of current_tile are relevant. we use these to get the index into the palette ram
                    // for the particular pixel we are interested in (determined by tile_x and tile_y).
                    ubyte index = memory.read_byte(tile_base_address + (((shifted_tile_number & 0x3ff) >> 1) * 64) + 
                                                                       ((scanline - y) % 8) * 8 +
                                                                       ((draw_x   - x) % 8));

                    // and we grab the pixel from palette ram and interpret it as 15bit highcolor.

                    maybe_draw_pixel(memory.OFFSET_PALETTE_RAM + 0x200, index, priority, draw_x, scanline);
                }
            } else { // 16 / 16
                if (obj_character_vram_mapping) {
                    base_tile_number += (width / 8) * ((scanline - y) / 8);
                } else {
                    base_tile_number += 32 * ((scanline - y) / 8);
                }

                for (int draw_x = x; draw_x < x + width; draw_x += 2) {
                    // TODO: REPEATED CODE

                    // tile_base_address is just the base address of the tiles for sprites
                    uint tile_base_address = memory.OFFSET_VRAM + 0x10000; // probably wrong lol

                    // shifted_tile_number tells us the exact tile we will be rendering. note that (draw_x - x)/ 8
                    // tells us the current tile column we are rendering.
                    uint shifted_tile_number = base_tile_number + ((draw_x - x) / 8);

                    // only the upper 10 bits of current_tile are relevant. we use these to get the index into the palette ram
                    // for the particular pixel we are interested in (determined by tile_x and tile_y). we multiply
                    // shifted_tile_number by 32 because each tile is 32 bytes long. (scanline - y) % 8 and (draw_x - x) % 8
                    // are the current pixel x y offsets within the tile. since each pixel is half of a byte, we multiply
                    // the x y offsets by (8 / 2) and (1 / 2) respectively.
                    ubyte index = memory.read_byte(tile_base_address + ((shifted_tile_number & 0x3ff) * 32) + 
                                                                       ((scanline - y) % 8) * 4 +
                                                                       ((draw_x   - x) % 8) / 2);

                    uint index_L = (index & 0xF) + get_nth_bits(attribute_2, 12, 16) * 16;
                    uint index_H = (index >> 4)  + get_nth_bits(attribute_2, 12, 16) * 16;
                                        // warning(format("SHAPE: %x %x %x %x %x %x", attribute_0, attribute_1, size, shape, width, height));

                    // and we grab two pixels from palette ram and interpret them as 15bit highcolor.
                    maybe_draw_pixel(memory.OFFSET_PALETTE_RAM + 0x200, index_L, priority, draw_x,     scanline);
                    maybe_draw_pixel(memory.OFFSET_PALETTE_RAM + 0x200, index_H, priority, draw_x + 1, scanline);
                }
            }
        }
    }

    void test_render_sprites() {
        int palette = 0;
        int tile_base_address = memory.OFFSET_VRAM;
        for (int tile_number = 0; tile_number < 10; tile_number++) {
            int col = tile_number / 10;
            int row = tile_number % 10;

            for (int x = 0; x < 8; x++) {
            for (int y = 0; y < 8; y++) {
                // 16 / 16
                ubyte index = memory.read_byte(tile_base_address + (tile_number * 32) + (y * 4) + (x / 2));
                index += palette * 32;
                if (x % 2 == 0) {
                    index &= 0xF;
                } else {
                    index >>= 4;
                }

                // 256 / 256
                // ubyte index = memory.read_byte(tile_base_address + (tile_number * 64) + y * 8 + x);

                // // and we grab two pixels from palette ram and interpret them as 15bit highcolor.
                draw_pixel(memory.OFFSET_PALETTE_RAM + 0x200, index & 0xF, col * 8 + x, row * 8 + y);
            }    
            }
        }
    }

    void test_render_palette() {
        for (int i = 0; i < 256; i++) {
            for (int x = 0; x < 4; x++) {
            for (int y = 0; y < 4; y++) {
                draw_pixel(memory.OFFSET_PALETTE_RAM, i, (i % 16) * 4 + x, (i / 16) * 4 + y);
            }
            }
        }
    }

    void maybe_draw_pixel(uint palette_offset, uint palette_index, uint priority, uint x, uint y) {
        // if (priority >= pixel_priorities[x][y]) {
        //     return;
        // }

        // if ((palette_index & 0xF) != 0) {
            pixel_priorities[x][y] = priority;
            draw_pixel(palette_offset, palette_index, x, y);
        // }
    }

    void draw_pixel(uint palette_offset, uint palette_index, uint x, uint y) {
        uint color = memory.read_halfword(palette_offset + palette_index * 2);
        // warning(format("%x", palette_offset));
        if (x >= 240 || y >= 160) return;

        memory.set_rgb(x, y, cast(ubyte) (get_nth_bits(color,  0,  5) * 255 / 31),
                             cast(ubyte) (get_nth_bits(color,  5, 10) * 255 / 31),
                             cast(ubyte) (get_nth_bits(color, 10, 15) * 255 / 31));
    }

// .......................................................................................................................
// .RRRRRRRRRRR...EEEEEEEEEEEE....GGGGGGGGG....IIII...SSSSSSSSS...TTTTTTTTTTTTT.EEEEEEEEEEEE..RRRRRRRRRRR....SSSSSSSSS....
// .RRRRRRRRRRRR..EEEEEEEEEEEE...GGGGGGGGGGG...IIII..SSSSSSSSSSS..TTTTTTTTTTTTT.EEEEEEEEEEEE..RRRRRRRRRRRR..SSSSSSSSSSS...
// .RRRRRRRRRRRRR.EEEEEEEEEEEE..GGGGGGGGGGGGG..IIII..SSSSSSSSSSSS.TTTTTTTTTTTTT.EEEEEEEEEEEE..RRRRRRRRRRRR..SSSSSSSSSSSS..
// .RRRR.....RRRR.EEEE..........GGGGG....GGGG..IIII..SSSS....SSSS.....TTTT......EEEE..........RRR.....RRRRR.SSSS....SSSS..
// .RRRR.....RRRR.EEEE.........GGGGG......GGG..IIII..SSSS.............TTTT......EEEE..........RRR......RRRR.SSSSS.........
// .RRRR....RRRRR.EEEEEEEEEEEE.GGGG............IIII..SSSSSSSS.........TTTT......EEEEEEEEEEEE..RRR.....RRRR..SSSSSSSS......
// .RRRRRRRRRRRR..EEEEEEEEEEEE.GGGG....GGGGGGG.IIII..SSSSSSSSSSS......TTTT......EEEEEEEEEEEE..RRRRRRRRRRRR...SSSSSSSSSS...
// .RRRRRRRRRRRR..EEEEEEEEEEEE.GGGG....GGGGGGG.IIII....SSSSSSSSS......TTTT......EEEEEEEEEEEE..RRRRRRRRRRRR....SSSSSSSSSS..
// .RRRRRRRRRRR...EEEE.........GGGG....GGGGGGG.IIII........SSSSSS.....TTTT......EEEE..........RRRRRRRRRR..........SSSSSS..
// .RRRR..RRRRR...EEEE.........GGGGG......GGGG.IIII...SS.....SSSS.....TTTT......EEEE..........RRR...RRRRR....SS.....SSSS..
// .RRRR...RRRR...EEEE..........GGGGG....GGGGG.IIII.ISSSS....SSSS.....TTTT......EEEE..........RRR....RRRR...SSSS....SSSS..
// .RRRR...RRRRR..EEEEEEEEEEEEE.GGGGGGGGGGGGGG.IIII.ISSSSSSSSSSSS.....TTTT......EEEEEEEEEEEEE.RRR....RRRRR..SSSSSSSSSSSS..
// .RRRR....RRRRR.EEEEEEEEEEEEE..GGGGGGGGGGGG..IIII..SSSSSSSSSSS......TTTT......EEEEEEEEEEEEE.RRR.....RRRRR.SSSSSSSSSSSS..
// .RRRR.....RRRR.EEEEEEEEEEEEE...GGGGGGGGG....IIII...SSSSSSSSS.......TTTT......EEEEEEEEEEEEE.RRR.....RRRRR..SSSSSSSSSS...

private:
    // DISPCNT
    int  bg_mode;                                   // 0 - 5
    int  disp_frame_select;                         // 0 - 1
    bool hblank_interval_free;                      // 1 = OAM can be accessed during h-blank
    bool is_character_vram_mapping_one_dimensional; // 2 = 2-dimensional
    bool obj_character_vram_mapping;
    bool forced_blank;

    // DISPSTAT
    bool  vblank;
    bool  hblank;
    bool  vblank_irq_enabled;
    bool  hblank_irq_enabled;
    bool  vcounter_irq_enabled;
    ubyte vcount_lyc;

public:
    void write_DISPCNT(int target_byte, ubyte data) {
        import std.stdio;
        writefln("%x ,%x", target_byte, data);
        if (target_byte == 0) {
            bg_mode                    = get_nth_bits(data, 0, 3);
            disp_frame_select          = get_nth_bit (data, 4);
            hblank_interval_free       = get_nth_bit (data, 5);
            obj_character_vram_mapping = get_nth_bit (data, 6);
            forced_blank               = get_nth_bit (data, 7);
        } else { // target_byte == 1
            backgrounds[0].enabled       = get_nth_bit (data, 0);
            backgrounds[1].enabled       = get_nth_bit (data, 1);
            backgrounds[2].enabled       = get_nth_bit (data, 2);
            backgrounds[3].enabled       = get_nth_bit (data, 3);
            // TODO: WINDOW 0
            // TODO: WINDOW 1
            // TODO: OBJ WINDOW
        }
    }

    void write_DISPSTAT(int target_byte, ubyte data) {
        if (target_byte == 0) {
            vblank_irq_enabled   = get_nth_bit(data, 3);
            hblank_irq_enabled   = get_nth_bit(data, 4);
            vcounter_irq_enabled = get_nth_bit(data, 5);
        } else { // target_byte == 1
            vcount_lyc           = data;
        }
    }

    void write_BGXCNT(int target_byte, ubyte data, int x) {
        if (target_byte == 0) {
            backgrounds[x].priority                   = get_nth_bits(data, 0, 2);
            backgrounds[x].character_base_block       = get_nth_bits(data, 2, 4);
            backgrounds[x].is_mosaic                  = get_nth_bit (data, 6);
            backgrounds[x].doesnt_use_color_palettes  = get_nth_bit (data, 7);
        } else { // target_byte == 1
            backgrounds[x].screen_base_block          = get_nth_bits(data, 0, 5);
            backgrounds[x].does_display_area_overflow = get_nth_bit (data, 5);
            backgrounds[x].screen_size                = get_nth_bits(data, 6, 8);
        }
    }

    void write_BGXHOFS(int target_byte, ubyte data, int x) {
        if (target_byte == 0) {
            backgrounds[x].x_offset = (backgrounds[x].x_offset & 0xFF00) | data;
        } else { // target_byte == 1
            backgrounds[x].x_offset = (backgrounds[x].x_offset & 0x00FF) | (data << 8);
        }
    }

    void write_BGXVOFS(int target_byte, ubyte data, int x) {
        if (target_byte == 0) {
            backgrounds[x].y_offset = (backgrounds[x].x_offset & 0xFF00) | data;
        } else { // target_byte == 1
            backgrounds[x].y_offset = (backgrounds[x].x_offset & 0x00FF) | (data << 8);
        }
    }

    ubyte read_DISPCNT(int target_byte) {
        if (target_byte == 0) {
            return cast(ubyte) ((bg_mode                    << 0) |
                                (disp_frame_select          << 4) |
                                (hblank_interval_free       << 5) |
                                (obj_character_vram_mapping << 6) |
                                (forced_blank               << 7));
        } else { // target_byte == 1
            return (backgrounds[0].enabled << 0) |
                   (backgrounds[1].enabled << 1) |
                   (backgrounds[2].enabled << 2) |
                   (backgrounds[3].enabled << 3);
        }
    }

    ubyte read_DISPSTAT(int target_byte) {
        if (target_byte == 0) {
            return (vblank                   << 0) |
                   (hblank                   << 1) | 
                   ((scanline == vcount_lyc) << 2) |
                   (vblank_irq_enabled       << 3) |
                   (hblank_irq_enabled       << 4) |
                   (vcounter_irq_enabled     << 5);
        } else { // target_byte == 1
            return vcount_lyc;
        }
    }

    ubyte read_VCOUNT(int target_byte) {
        if (target_byte == 0) {
            return (scanline & 0x00FF) >> 0;
        } else {
            return (scanline & 0xFF00) >> 8;
        }
    }

    ubyte read_BGXCNT(int target_byte, int x) {
        if (target_byte == 0) {
            return cast(ubyte) ((backgrounds[x].priority                  << 0) |
                                (backgrounds[x].character_base_block      << 2) |
                                (backgrounds[x].is_mosaic                 << 6) |
                                (backgrounds[x].doesnt_use_color_palettes << 7));
        } else { // target_byte == 1
            return cast(ubyte) ((backgrounds[x].screen_base_block          << 0) |
                                (backgrounds[x].does_display_area_overflow << 5) |
                                (backgrounds[x].screen_size                << 6));
        }
    }
}
