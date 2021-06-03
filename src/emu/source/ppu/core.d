module ppu.core;

import memory;
import util;
import ppu;
import interrupts;

import std.stdio;
import std.typecons;

enum SCREEN_WIDTH  = 240;
enum SCREEN_HEIGHT = 160;

class PPU {
    // General information:
    // - Contains 227 scanlines, 160+ is VBLANK. VBLANK is not set on scanline 227.
    // - HBLANK is constantly toggled
    // - Although the drawing time is only 960 cycles (240*4), the H-Blank flag is "0" for a total of 1006 cycles.

public:
    void delegate(uint) interrupt_cpu;
    void delegate()     on_hblank;
    
    enum Pixel RESET_PIXEL = Pixel(0, 0, 0, 0, true);

    // alias Layer = Typedef!(Pixel[SCREEN_WIDTH][SCREEN_HEIGHT]);

    Layer[9] layers; // for iteration

    Layer     layer_backdrop;
    Layer[4]  layer_backgrounds;
    Layer[4]  layer_sprites;
    Layer     layer_result;

    Pixel[SCREEN_WIDTH][SCREEN_HEIGHT] screen;

    this(Memory memory, void delegate(uint) interrupt_cpu, void delegate() on_hblank) {
        this.memory        = memory;
        this.interrupt_cpu = interrupt_cpu;
        this.on_hblank     = on_hblank;
        dot                = 0;
        scanline           = 0;

        layer_backdrop       = new Layer();
        layer_backgrounds[0] = new Layer();
        layer_backgrounds[1] = new Layer();
        layer_backgrounds[2] = new Layer();
        layer_backgrounds[3] = new Layer();
        layer_sprites    [0] = new Layer();
        layer_sprites    [1] = new Layer();
        layer_sprites    [2] = new Layer();
        layer_sprites    [3] = new Layer();
        layer_result         = new Layer();

        layers[0] = layer_backdrop;
        layers[1] = layer_backgrounds[0];
        layers[2] = layer_backgrounds[1];
        layers[3] = layer_backgrounds[2];
        layers[4] = layer_backgrounds[3];
        layers[5] = layer_sprites[0];
        layers[6] = layer_sprites[1];
        layers[7] = layer_sprites[2];
        layers[8] = layer_sprites[3];

        background_init(memory);
        reset_changed_pixels();
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
                // for (int x = 0; x < 240; x++)
                // for (int y = 0; y < 160; y++)
                    // pixel_priorities[x][y] = 100;
                
                ushort backdrop_color = memory.force_read_halfword(memory.OFFSET_PALETTE_RAM);
                Pixel p = get_pixel_from_color(backdrop_color, 0, false);
                if (!(p.r == layer_backdrop.pixels[0][0].r && 
                      p.g == layer_backdrop.pixels[0][0].g && 
                      p.b == layer_backdrop.pixels[0][0].b)) {
                    layer_backdrop.fill(p);
                }
                
            }
        }

        // set vblank or hblank accordingly
        if (scanline == 160 && dot == 0) { // are we in vblank?
            vblank = true;
            if (vblank_irq_enabled) interrupt_cpu(INTERRUPT.LCD_VBLANK);

            apply_special_effects();
            overlay_all_layers();
            render_layer_result();

            layer_backdrop      .fill_and_reset(RESET_PIXEL);
            layer_backgrounds[0].fill_and_reset(RESET_PIXEL);
            layer_backgrounds[1].fill_and_reset(RESET_PIXEL);
            layer_backgrounds[2].fill_and_reset(RESET_PIXEL);
            layer_backgrounds[3].fill_and_reset(RESET_PIXEL);
            layer_sprites[0]    .fill_and_reset(RESET_PIXEL);
            layer_sprites[1]    .fill_and_reset(RESET_PIXEL);
            layer_sprites[2]    .fill_and_reset(RESET_PIXEL);
            layer_sprites[3]    .fill_and_reset(RESET_PIXEL);
            layer_result        .fill_and_reset(RESET_PIXEL);
            reset_changed_pixels();
        }

        if (dot == 240 && !vblank) {
            hblank = true;
            if (hblank_irq_enabled) interrupt_cpu(INTERRUPT.LCD_HBLANK);
            on_hblank();
        }
        
        if (dot == 0) {
            hblank = false;
        }
    }

    void cycle() {
        update_dot_and_scanline();
        
        // if we are hblank or vblank then we do not draw anything
        if (vblank || hblank) {
            return;
        }

        // only begin rendering if we are on the first cycle
        if (dot != 0) return;
        render();
    }

    void render() {
        switch (bg_mode) {
            case 0: 
                render_background__text(0);
                render_background__text(1);
                render_background__text(2);
                render_background__text(3);
                render_sprites();
                break;

            case 1:
                render_background__text(0);
                render_background__text(1);
                render_background__rotation_scaling(2);
                render_sprites();
                break;

            case 3: {
                // in mode 3, the dot and scanline (x and y) simply tell us where to read from in VRAM. The colors
                // are stored directly, so we just read from VRAM and interpret as a 15bit highcolor
                for (uint x = 0; x < 240; x++) 
                    draw_pixel(layer_backgrounds[3], memory.OFFSET_VRAM, x + scanline * 240, 0, x, scanline, false);

                // writefln("c: %x", layer_backgrounds[0][0][0].r);
                break;
            }

            case 4:
            case 5: {
                // modes 4 and 5 are a step up from mode 3. the address of where the colors are stored can
                // be found using DISPCNT.
                uint base_frame_address = memory.OFFSET_VRAM + disp_frame_select * 0xA000;


                for (uint x = 0; x < 240; x++) {
                    // the index in palette ram that we need to look into is then found in the base frame.
                    uint index = memory.force_read_byte(base_frame_address + (x + scanline * 240));
                    draw_pixel(layer_backgrounds[0], memory.OFFSET_PALETTE_RAM, index, 0, x, scanline, false);
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
    // uint[][] pixel_priorities; // the associated priorities with each pixel.

    static int[][] BG_TEXT_SCREENS_DIMENSIONS = [
        [1, 1],
        [1, 2],
        [2, 1],
        [2, 2]
    ];

    static int[] BG_ROTATION_SCALING_TILE_DIMENSIONS = [
        16, 32, 64, 128
    ];

    int get_tile_address__text(int tile_x, int tile_y, int screens_per_row) {
        // each screen is 32 x 32 tiles. so to get the tile offset within its screen
        // we can get the low 5 bits
        int tile_x_within_screen = tile_x & 0x1F;
        int tile_y_within_screen = tile_y & 0x1F;

        // similarly we can find out which screen this tile is located in
        // by getting its high bit
        int screen_x             = (tile_x >> 5) & 1;
        int screen_y             = (tile_y >> 5) & 1;
        int screen               = screen_x * screens_per_row + screen_y;

        int tile_address_offset_within_screen = ((tile_y_within_screen * 32) + tile_x_within_screen) * 2;
        return tile_address_offset_within_screen + screen * 0x800; 
    }

    int get_tile_address__rotation_scaling(int tile_x, int tile_y, int tiles_per_row) {
        return ((tile_y * tiles_per_row) + tile_x);
    }

    void render_tile_256_1(Layer layer, int tile, int tile_base_address, int palette_base_address, int left_x, int y, bool flipped_x, bool flipped_y) {
        for (int tile_x = 0; tile_x < 8; tile_x++) {
            ubyte index = memory.force_read_byte(tile_base_address + ((tile & 0x3ff) * 64) + y * 8 + tile_x);

            int draw_x = flipped_x ? left_x   + (7 - tile_x) : left_x + tile_x;
            int draw_y = flipped_y ? scanline + (7 -      y) : scanline;
            maybe_draw_pixel_on_layer(layer, palette_base_address, index, 0, draw_x, draw_y, index == 0);
        }
    }

    void render_tile_16_16(Layer layer, int tile, int tile_base_address, int palette_base_address, int left_x, int y, bool flipped_x, bool flipped_y, int palette) {
        for (int tile_x = 0; tile_x < 8; tile_x++) {
            ubyte index = memory.force_read_byte(tile_base_address + ((tile & 0x3ff) * 32) + y * 4 + (tile_x / 2));

            int draw_x = flipped_x ? left_x   + (7 - tile_x) : left_x + tile_x;
            int draw_y = flipped_y ? scanline + (7 -      y) : scanline;

            index = (tile_x % 2 == 0) ? index & 0xF : index >> 4;
            index += palette * 16;
            maybe_draw_pixel_on_layer(layer, palette_base_address, index, 0, draw_x, draw_y, index == 0);
        } 
    }

    void render_background__text(uint background_id) {
        // do we even render?
        Background background = backgrounds[background_id];
        if (!background.enabled) return;

        // relevant addresses for the background's tilemap and screen
        int screen_base_address = memory.OFFSET_VRAM + background.screen_base_block    * 0x800;
        int tile_base_address   = memory.OFFSET_VRAM + background.character_base_block * 0x4000;

        // the coordinates at the topleft of the background that we are drawing
        int topleft_x      = background.x_offset;
        int topleft_y      = background.y_offset + scanline;

        // the tile number at the topleft of the background that we are drawing
        int topleft_tile_x = topleft_x >> 3;
        int topleft_tile_y = topleft_y >> 3;

        // how far back do we have to render the tile? because the topleft of the screen
        // usually doesn't mark the start of the tile, so these are the offsets we can
        // subtract to handle the mislignment
        int tile_dx        = topleft_x & 0b111;
        int tile_dy        = topleft_y & 0b111;

        // tile_x_offset and tile_y_offset are offsets from the topleft tile. we use this to iterate through
        // each tile.
        for (int tile_x_offset = 0; tile_x_offset < 32 + 1; tile_x_offset++) {

            // get the tile address and read it from memory
            int tile_address = get_tile_address__text(topleft_tile_x + tile_x_offset, topleft_tile_y, BG_TEXT_SCREENS_DIMENSIONS[background.screen_size][0]);
            int tile = memory.force_read_halfword(screen_base_address + tile_address);

            int draw_x = tile_x_offset * 8 - tile_dx;
            int draw_y = scanline;

            bool flipped_x = (tile >> 10) & 1;
            bool flipped_y = (tile >> 11) & 1;

            if (background.doesnt_use_color_palettes) 
                render_tile_256_1(layer_backgrounds[background_id], tile, tile_base_address, memory.OFFSET_PALETTE_RAM, draw_x, tile_dy, flipped_x, flipped_y);
            else                                      
                render_tile_16_16(layer_backgrounds[background_id], tile, tile_base_address, memory.OFFSET_PALETTE_RAM, draw_x, tile_dy, flipped_x, flipped_y, get_nth_bits(tile, 12, 16));
        }
    }

    void render_background__rotation_scaling(uint background_id) {
        // do we even render?
        Background background = backgrounds[background_id];
        if (!background.enabled) return;

        // relevant addresses for the background's tilemap and screen
        int screen_base_address = memory.OFFSET_VRAM + background.screen_base_block    * 0x800;
        int tile_base_address   = memory.OFFSET_VRAM + background.character_base_block * 0x4000;

        // the coordinates at the topleft of the background that we are drawing
        int topleft_x      = background.x_offset;
        int topleft_y      = background.y_offset + scanline;

        // the tile number at the topleft of the background that we are drawing
        int topleft_tile_x = topleft_x >> 3;
        int topleft_tile_y = topleft_y >> 3;

        // how far back do we have to render the tile? because the topleft of the screen
        // usually doesn't mark the start of the tile, so these are the offsets we can
        // subtract to handle the mislignment
        int tile_dx        = topleft_x & 0b111;
        int tile_dy        = topleft_y & 0b111;

        int tiles_per_row  = BG_ROTATION_SCALING_TILE_DIMENSIONS[background.screen_size];

        // tile_x_offset and tile_y_offset are offsets from the topleft tile. we use this to iterate through
        // each tile.
        for (int tile_x_offset = 0; tile_x_offset < 32 + 1; tile_x_offset++) {

            // get the tile address and read it from memory
            int tile_address = get_tile_address__rotation_scaling(topleft_tile_x + tile_x_offset, topleft_tile_y, tiles_per_row);
            int tile = memory.force_read_byte(screen_base_address + tile_address);

            int draw_x = tile_x_offset * 8 - tile_dx;
            int draw_y = scanline;

            render_tile_256_1(layer_backgrounds[background_id], tile, tile_base_address, memory.OFFSET_PALETTE_RAM, draw_x, tile_dy, false, false);
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
        for (int sprite = 127; sprite >= 0; sprite--) {
            // first of all, we need to figure out if we render this sprite in the first place.
            // so, we collect a bunch of info that'll help us figure that out.
            ushort attribute_0 = memory.force_read_halfword(memory.OFFSET_OAM + sprite * 8 + 0);

            // is this sprite even enabled
            if (get_nth_bits(attribute_0, 8, 10) == 0b10) continue;

            // it is enabled? great. let's get the other two attributes and collect some
            // relevant information.
            int attribute_1 = memory.force_read_halfword(memory.OFFSET_OAM + sprite * 8 + 2);
            int attribute_2 = memory.force_read_halfword(memory.OFFSET_OAM + sprite * 8 + 4);

            int size   = get_nth_bits(attribute_1, 14, 16);
            int shape  = get_nth_bits(attribute_0, 14, 16);

            ubyte width  = sprite_sizes[shape][size][0] >> 3;
            ubyte height = sprite_sizes[shape][size][1] >> 3;

            int topleft_x = sign_extend(cast(ubyte) get_nth_bits(attribute_1,  0,  9), 9);
            int topleft_y = get_nth_bits(attribute_0,  0,  8);

            uint base_tile_number = cast(ushort) get_nth_bits(attribute_2, 0, 10);
            uint priority = get_nth_bits(attribute_2, 10, 11);

            int tile_number_increment_per_row = obj_character_vram_mapping ? width : 32;

            bool doesnt_use_color_palettes = get_nth_bit(attribute_0, 13);

            bool flipped_x = get_nth_bit(attribute_1, 12);
            bool flipped_y = get_nth_bit(attribute_1, 13);

            for (int tile_x_offset = 0; tile_x_offset < width;  tile_x_offset++) {
            for (int tile_y_offset = 0; tile_y_offset < height; tile_y_offset++) {

                // get the tile address and read it from memory
                // int tile_address = get_tile_address(topleft_tile_x + tile_x_offset, topleft_tile_y + tile_y_offset, tile_number_increment_per_row);
                int tile = base_tile_number + (tile_y_offset * tile_number_increment_per_row) + tile_x_offset;

                int draw_x = flipped_x ? (width  - tile_x_offset - 1) * 8 + topleft_x : tile_x_offset * 8 + topleft_x;
                int draw_y = flipped_y ? (height - tile_y_offset - 1) * 8 + topleft_y : tile_y_offset * 8 + topleft_y;

                if (doesnt_use_color_palettes) 
                    render_tile_256_1(layer_sprites[priority], tile, memory.OFFSET_VRAM + 0x10000, memory.OFFSET_PALETTE_RAM + 0x200, draw_x, draw_y, flipped_x, flipped_y);
                else                                      
                    render_tile_16_16(layer_sprites[priority], tile, memory.OFFSET_VRAM + 0x10000, memory.OFFSET_PALETTE_RAM + 0x200, draw_x, draw_y, flipped_x, flipped_y, get_nth_bits(attribute_2, 12, 16));
            }
            }
        }
    }

    int scale_x_sprites(int reference_point_x, int reference_point_y, uint original_x, uint original_y, int scaling_number) {
        double pA = convert_from_8_8f_to_double(memory.force_read_halfword(memory.OFFSET_OAM + 0x06 + 0x20 * scaling_number));
        double pB = convert_from_8_8f_to_double(memory.force_read_halfword(memory.OFFSET_OAM + 0x0E + 0x20 * scaling_number));
        
        return cast(int) (pA * (original_x - reference_point_x) + pB * (reference_point_y - original_y)) + original_x;
    }

    int scale_y_sprites(int reference_point_x, int reference_point_y, uint original_x, uint original_y, int scaling_number) {
        double pC = convert_from_8_8f_to_double(memory.force_read_halfword(memory.OFFSET_OAM + 0x16 + 0x20 * scaling_number));
        double pD = convert_from_8_8f_to_double(memory.force_read_halfword(memory.OFFSET_OAM + 0x1E + 0x20 * scaling_number));
        
        return cast(int) (pC * (original_x - reference_point_x) + pD * (reference_point_y - original_y)) + original_x;
    }

    void test_render_sprites() {
        int palette = 0;
        int tile_base_address = memory.OFFSET_VRAM + 0x4000;
        for (int tile_number = 0; tile_number < 10; tile_number++) {
            int col = tile_number / 10;
            int row = tile_number % 10;

            for (int x = 0; x < 8; x++) {
            for (int y = 0; y < 8; y++) {
                // 16 / 16
                ubyte index = memory.force_read_byte(tile_base_address + (tile_number * 32) + (y * 4) + (x / 2));
                index += palette * 32;
                if (x % 2 == 0) {
                    index &= 0xF;
                } else {
                    index >>= 4;
                }

                // 256 / 256
                // ubyte index = memory.force_read_byte(tile_base_address + (tile_number * 64) + y * 8 + x);

                // // and we grab two pixels from palette ram and interpret them as 15bit highcolor.
                maybe_draw_pixel_on_layer(layer_sprites[0], memory.OFFSET_PALETTE_RAM + 0x200, index & 0xF, 0, col * 8 + x, row * 8 + y, false);
            }    
            }
        }
    }

    // void test_render_palette() {
    //     for (int i = 0; i < 256; i++) {
    //         for (int x = 0; x < 4; x++) {
    //         for (int y = 0; y < 4; y++) {
    //             draw_pixel(memory.OFFSET_PALETTE_RAM, i, (i % 16) * 4 + x, (i / 16) * 4 + y);
    //         }
    //         }
    //     }
    // }

    void maybe_draw_pixel_on_layer(Layer layer, uint palette_offset, uint palette_index, uint priority, uint x, uint y, bool transparent) {
        if ((palette_index & 0xF) != 0) {
            // pixel_priorities[x][y] = priority;
            draw_pixel(layer, palette_offset, palette_index, priority, x, y, transparent);
        }
    }

    void draw_pixel(Layer layer, uint palette_offset, uint palette_index, uint priority, uint x, uint y, bool transparent) {
        ushort color = memory.force_read_halfword(palette_offset + palette_index * 2);
        // warning(format("%x", palette_offset));
        if (x >= SCREEN_WIDTH || y >= SCREEN_HEIGHT) return;

        layer.set_pixel(x, y, get_pixel_from_color(color, priority, transparent));
        // writefln("c: %x", (*layer)[0][0].r);
        // writefln("d: %x", (*layer_backgrounds[0])[0][0].r);
    }

    void apply_special_effects() {
        final switch (special_effect) {
            case SpecialEffect.None:
                return;

            case SpecialEffect.Alpha:
                warning("Alpha blending not implemented yet.");
                break;
            
            case SpecialEffect.BrightnessIncrease:
                for (int layer = 0; layer < layers.length; layer++) {
                    if (layers[layer].special_effect_layer == SpecialEffectLayer.A) {
                        for (int x = 0; x < SCREEN_WIDTH;  x++) {
                        for (int y = 0; y < SCREEN_HEIGHT; y++) {
                            Pixel target_pixel = layers[layer].pixels[x][y];
                            target_pixel.r += cast(ubyte) (((31 - target_pixel.r) * evy_coeff) >> 4);
                            target_pixel.g += cast(ubyte) (((31 - target_pixel.g) * evy_coeff) >> 4);
                            target_pixel.b += cast(ubyte) (((31 - target_pixel.b) * evy_coeff) >> 4);
                            layers[layer].pixels[x][y] = target_pixel;
                        }
                        }
                    }
                }
                break;
            
            case SpecialEffect.BrightnessDecrease:
                for (int layer = 0; layer < layers.length; layer++) {
                    if (layers[layer].special_effect_layer == SpecialEffectLayer.A) {
                        for (int x = 0; x < SCREEN_WIDTH;  x++) {
                        for (int y = 0; y < SCREEN_HEIGHT; y++) {
                            Pixel target_pixel = layers[layer].pixels[x][y];
                            target_pixel.r -= cast(ubyte) (((target_pixel.r) * evy_coeff) >> 4);
                            target_pixel.g -= cast(ubyte) (((target_pixel.g) * evy_coeff) >> 4);
                            target_pixel.b -= cast(ubyte) (((target_pixel.b) * evy_coeff) >> 4);
                            layers[layer].pixels[x][y] = target_pixel;
                        }
                        }
                    }
                }
                break;

        }
    }

    void overlay_all_layers() {
        // layer_result = layer_backgrounds[1];
        Point[] changed_pixels = get_changed_pixels();

        overlay_layer(layer_backdrop, layer_result, changed_pixels);

        for (int target_priority = 3; target_priority >= 0; target_priority--) {
            for (int background_id = 3; background_id >= 0; background_id--) {
                if (backgrounds[background_id].priority == target_priority) {
                    overlay_layer(layer_result, layer_backgrounds[background_id], changed_pixels);
                    overlay_layer(layer_result, layer_sprites    [background_id], changed_pixels);
                }
            }
        }
    }

    void overlay_layer(Layer target_layer, Layer overlaying_layer, Point[] changed_pixels) {
        for (int i = 0; i < changed_pixels.length; i++) {
            Point p = changed_pixels[i];
            if (!overlaying_layer.pixels[p.x][p.y].transparent) {
                target_layer.pixels[p.x][p.y] = overlaying_layer.pixels[p.x][p.y];
            }
        }
    }

    void render_layer_result() {
        for (int x = 0; x < SCREEN_WIDTH;  x++) {
        for (int y = 0; y < SCREEN_HEIGHT; y++) {
            memory.set_rgb(x, y, cast(ubyte) (layer_result.pixels[x][y].r << 3), 
                                 cast(ubyte) (layer_result.pixels[x][y].g << 3), 
                                 cast(ubyte) (layer_result.pixels[x][y].b << 3));
        }
        }
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

    // BLDCNT
    SpecialEffect special_effect;

    // BLDY
    int evy_coeff;

public:
    void write_DISPCNT(int target_byte, ubyte data) {
        if (target_byte == 0) {
            bg_mode                    = get_nth_bits(data, 0, 3);
            disp_frame_select          = get_nth_bit (data, 4);
            hblank_interval_free       = get_nth_bit (data, 5);
            obj_character_vram_mapping = get_nth_bit (data, 6);
            forced_blank               = get_nth_bit (data, 7);
        } else { // target_byte == 1
            backgrounds[0].enabled     = get_nth_bit (data, 0);
            backgrounds[1].enabled     = get_nth_bit (data, 1);
            backgrounds[2].enabled     = get_nth_bit (data, 2);
            backgrounds[3].enabled     = get_nth_bit (data, 3);
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
            backgrounds[x].y_offset = (backgrounds[x].y_offset & 0xFF00) | data;
        } else { // target_byte == 1
            backgrounds[x].y_offset = (backgrounds[x].y_offset & 0x00FF) | (data << 8);
        }
    }
    void write_BLDCNT(int target_byte, ubyte data) {
        void maybe_set_special_effect_layer(Layer layer, SpecialEffectLayer special_effect_layer, bool condition) {
            if (layer.special_effect_layer == special_effect_layer || layer.special_effect_layer == SpecialEffectLayer.None) {
                layer.special_effect_layer = condition ? special_effect_layer : SpecialEffectLayer.None;
            }
        }
        
        final switch (target_byte) {
            case 0b0:
                maybe_set_special_effect_layer(layer_backgrounds[0], SpecialEffectLayer.A, get_nth_bit(data, 0));
                maybe_set_special_effect_layer(layer_backgrounds[1], SpecialEffectLayer.A, get_nth_bit(data, 1));
                maybe_set_special_effect_layer(layer_backgrounds[2], SpecialEffectLayer.A, get_nth_bit(data, 2));
                maybe_set_special_effect_layer(layer_backgrounds[3], SpecialEffectLayer.A, get_nth_bit(data, 3));
                // TODO: OBJ BLENDING
                maybe_set_special_effect_layer(layer_backdrop      , SpecialEffectLayer.A, get_nth_bit(data, 5));
                special_effect = cast(SpecialEffect) get_nth_bits(data, 6, 8);

                break;
            case 0b1:
                maybe_set_special_effect_layer(layer_backgrounds[0], SpecialEffectLayer.B, get_nth_bit(data, 0));
                maybe_set_special_effect_layer(layer_backgrounds[1], SpecialEffectLayer.B, get_nth_bit(data, 1));
                maybe_set_special_effect_layer(layer_backgrounds[2], SpecialEffectLayer.B, get_nth_bit(data, 2));
                maybe_set_special_effect_layer(layer_backgrounds[3], SpecialEffectLayer.B, get_nth_bit(data, 3));
                // TODO: OBJ BLENDING
                maybe_set_special_effect_layer(layer_backdrop      , SpecialEffectLayer.B, get_nth_bit(data, 5));
                break;
        }
    }

    void write_BLDY(int target_byte, ubyte data) {
        final switch (target_byte) {
            case 0b0:
                evy_coeff = get_nth_bits(data, 0, 5);
                if (evy_coeff > 16) evy_coeff = 16;
                break;
            case 0b1:
                break;
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

    ubyte read_BLDCNT(int target_byte) {
        final switch (target_byte) {
            case 0b0:
                return ((layer_backgrounds[0].special_effect_layer == SpecialEffectLayer.A) << 0) |
                       ((layer_backgrounds[1].special_effect_layer == SpecialEffectLayer.A) << 1) |
                       ((layer_backgrounds[2].special_effect_layer == SpecialEffectLayer.A) << 2) |
                       ((layer_backgrounds[3].special_effect_layer == SpecialEffectLayer.A) << 3) |
                       (((cast(int) special_effect) & 0b11)                                 << 4);
                       
            case 0b1:
                return ((layer_backgrounds[0].special_effect_layer == SpecialEffectLayer.B) << 0) |
                       ((layer_backgrounds[1].special_effect_layer == SpecialEffectLayer.B) << 1) |
                       ((layer_backgrounds[2].special_effect_layer == SpecialEffectLayer.B) << 2) |
                       ((layer_backgrounds[3].special_effect_layer == SpecialEffectLayer.B) << 3);
        }
    }
}
