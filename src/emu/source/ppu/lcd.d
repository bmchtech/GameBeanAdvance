module ppu.lcd;

import memory;
import util;
import ppu;
import interrupts;
import scheduler;

import std.stdio;
import std.typecons;

enum SCREEN_WIDTH  = 240;
enum SCREEN_HEIGHT = 160;

struct FixedPoint {
    int   integer;
    ubyte fraction;
}

class PPU {
    // General information:
    // - Contains 227 scanlines, 160+ is VBLANK. VBLANK is not set on scanline 227.
    // - HBLANK is constantly toggled
    // - Although the drawing time is only 960 cycles (240*4), the H-Blank flag is "0" for a total of 1006 cycles.

public:
    void delegate(uint) interrupt_cpu;
    void delegate()     on_hblank_callback;
    
    enum Pixel RESET_PIXEL = Pixel(0, 0, 0);

    Canvas canvas;

    Pixel[SCREEN_WIDTH][SCREEN_HEIGHT] screen;

    Scheduler scheduler;

    this(Memory memory, Scheduler scheduler, void delegate(uint) interrupt_cpu, void delegate() on_hblank_callback) {
        this.memory             = memory;
        this.interrupt_cpu      = interrupt_cpu;
        this.on_hblank_callback = on_hblank_callback;
        dot                     = 0;
        scanline                = 0;

        canvas = new Canvas(memory);

        this.scheduler = scheduler;
        scheduler.add_event(&on_hblank_start, 240 * 4);
        scheduler.add_event(&on_vblank_start, 308 * 160 * 4);

        // background_init(memory);
    }

    void on_hblank_start() {
        hblank = true;
        if (hblank_irq_enabled) interrupt_cpu(Interrupt.LCD_HBLANK);
        if (scanline < 160) render();

        if (!vblank) on_hblank_callback();

        scheduler.add_event(&on_hblank_end, 68 * 4);
    }

    void on_hblank_end() {
        if (vcounter_irq_enabled && scanline == vcount_lyc) {
            interrupt_cpu(Interrupt.LCD_VCOUNTER_MATCH);
        }

        hblank = false;
        writefln("Hblank????");
        scanline++;

        scheduler.add_event(&on_hblank_start, 240 * 4);
    }

    void on_vblank_start() {
        vblank = true;
        if (vblank_irq_enabled) interrupt_cpu(Interrupt.LCD_VBLANK);

        canvas.consolidate(31, 0);
        render_canvas();
        
        scheduler.add_event(&on_vblank_end, 308 * 68 * 4);
    }

    void on_vblank_end() {
        scanline = 0;
        vblank = false;
        
        canvas.reset();

        scheduler.add_event(&on_vblank_start, 308 * 160 * 4);
    }

    void calculate_backdrop() {
        for (int x = 0; x < 240; x++) canvas.draw(x, scanline, memory.OFFSET_PALETTE_RAM, Layer.BACKDROP);
    }

    void render() {
        writefln("Rendering scanline %x w/ mode %x", scanline, bg_mode);
        switch (bg_mode) {
            case 0: 
                render_sprites(0);
                render_background(0);
                render_sprites(1);
                render_background(1);
                render_sprites(2);
                render_background(2);
                render_sprites(3);
                render_background(3);
                calculate_backdrop();
                break;

            case 1:
                render_sprites(0);
                render_background(0);
                render_sprites(1);
                render_background(1);
                render_sprites(2);
                render_background(2);
                render_sprites(3);
                render_background(3);
                calculate_backdrop();
                break;

            case 3: {
                // in mode 3, the dot and scanline (x and y) simply tell us where to read from in VRAM. The colors
                // are stored directly, so we just read from VRAM and interpret as a 15bit highcolor
                for (uint x = 0; x < 240; x++) {
                    ushort color = memory.read_halfword(memory.OFFSET_VRAM + (x + scanline * 240) * 2);
                    canvas.draw(x, scanline, memory.OFFSET_VRAM + (x + scanline * 240), Layer.BACKDROP);
                }
                    // writefln("%x", memory.read_halfword(memory.OFFSET_VRAM + (0 + 200 * 240) * 2));
                // writefln("%x %x %x", memory.read_halfword(memory.OFFSET_VRAM + (0 + scanline * 240) * 2), memory.read_halfword(memory.OFFSET_VRAM + (120 * 230 * 2)), memory.vram[120 * 230 * 2]);

                // writefln("c: %x", layer_backgrounds[0][0][0].r);
                break;
            }

            case 4:
            case 5: {
                // modes 4 and 5 are a step up from mode 3. the address of where the colors are stored can
                // be found using DISPCNT.
                uint base_frame_address = memory.OFFSET_VRAM + disp_frame_select * 0xA000;


                for (uint x = 0; x < 240; x++) {
                    // the index in palette ram that we need to lookinto  is then found in the base frame.
                    uint index = memory.read_byte(base_frame_address + (x + scanline * 240));
                    draw_pixel(Layer.BACKDROP, 0, index, 0, x, scanline, false);
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

    // a texture is a width x height set of tiles
    struct Texture {
        int base_tile_number;   // the tile number of the topleft tile
        int width;              // the amount of tiles this texture has in its width
        int height;             // the amount of tiles this texture has in its height
        int increment_per_row;  // how much to add to the tile_number per row.
    
        bool scaled;
        PMatrix p_matrix;
        Point reference_point;

        int tile_base_address;
        int palette_base_address;
        int palette;

        bool flipped_x;
        bool flipped_y;
        bool double_sized;
    }

    struct Window {
        uint top;
        uint bottom;
        uint left;
        uint right;
    }

    double get_double_from_fixed_point(FixedPoint fp) {
        return (cast(double) fp.integer) + ((cast(double) fp.fraction) / 256);
    }

    Window[2] windows;

    // void render_texture_256_1(Layer layer, Texture texture, Point topleft_draw_pos) {
    //     for (int draw_x_offset = 0; draw_x_offset < texture.width << 3; draw_x_offset++) {
    //         Point draw_pos = Point(topleft_draw_pos.x + draw_x_offset, topleft_draw_pos.y);
    //         if (texture.scaled) {
    //             draw_pos = multiply_P_matrix(texture.reference_point, draw_pos, texture.p_matrix);
    //         }

    //         int tile_number = ((draw_pos.x - topleft_draw_pos.x) >> 3) + texture.increment_per_row * ((draw_pos.y - topleft_draw_pos.y) >> 3);

    //         ubyte index = memory.read_byte(texture.tile_base_address + ((tile_number & 0x3ff) * 64) + draw_pos.y * 8 + draw_pos.x);
    //         maybe_draw_pixel_on_layer(layer, texture.palette_base_address, index, 0, draw_pos.x, draw_pos.y, index == 0);
    //     }
    // }

    int get_tile_address__text(int tile_x, int tile_y, int screens_per_row) {
        // each screen is 32 x 32 tiles. so to get the tile offset within its screen
        // we can get the low 5 bits
        int tile_x_within_screen = tile_x & 0x1F;
        int tile_y_within_screen = tile_y & 0x1F;

        // similarly we can find out which screen this tile is located in
        // by getting its high bit
        int screen_x             = (tile_x >> 5) & 1;
        int screen_y             = (tile_y >> 5) & 1;
        int screen               = screen_x + screen_y * screens_per_row;

        int tile_address_offset_within_screen = ((tile_y_within_screen * 32) + tile_x_within_screen) * 2;
        return tile_address_offset_within_screen + screen * 0x800; 
    }

    int get_tile_address__rotation_scaling(int tile_x, int tile_y, int tiles_per_row) {
        return ((tile_y * tiles_per_row) + tile_x);
    }

    template Render(bool bpp8, bool flipped_x, bool flipped_y) {

        void tile(Layer layer, int tile, int tile_base_address, int palette_base_address, int left_x, int y, int ref_x, int ref_y, PMatrix p_matrix, bool scaled, int palette) {
            // Point reference_point = Point(ref_x, ref_y);
            static if (bpp8) {
                static if (flipped_y) uint tile_address = tile_base_address + (tile & 0x3ff) * 64 + (7 - y) * 8;    
                else                  uint tile_address = tile_base_address + (tile & 0x3ff) * 64 + (y)     * 8;
            } else {
                static if (flipped_y) uint tile_address = tile_base_address + (tile & 0x3ff) * 32 + (7 - y) * 4;    
                else                  uint tile_address = tile_base_address + (tile & 0x3ff) * 32 + (y)     * 4;
            }
            
            ubyte[8] tile_data = memory.vram[tile_address .. tile_address + 8];

            static if (flipped_x) {

            } else {
                static if (bpp8) {
                    for (int tile_dx = 0; tile_dx < 8; tile_dx++) {
                        ubyte index = tile_data[tile_dx];
                        maybe_draw_pixel_on_layer(layer, palette_base_address, index, 0, left_x + tile_dx, scanline, index == 0);
                    }
                } else {
                    for (int tile_dx = 0; tile_dx < 4; tile_dx++) {
                        ubyte index = tile_data[tile_dx];
                        maybe_draw_pixel_on_layer(layer, palette_base_address, (index & 0xF) + (palette * 16), 0, left_x + tile_dx * 2,     scanline, (index & 0xF) == 0);
                        maybe_draw_pixel_on_layer(layer, palette_base_address, (index >> 4)  + (palette * 16), 0, left_x + tile_dx * 2 + 1, scanline, (index >>  4) == 0);
                    }
                }
            }

            // for (int tile_x = 0; tile_x < 8; tile_x++) {
            //     int x = left_x - tile_x;

            //     int draw_x = flipped_x ? left_x    + (7 - tile_x) : left_x + tile_x;
            //     int draw_y = flipped_y ? (scanline - y) + (7 - y) : scanline;

            //     static if (bpp8) {
            //         ubyte index = memory.read_byte(tile_base_address + ((tile & 0x3ff) * 64) + y * 8 + tile_x);
                
            //         maybe_draw_pixel_on_layer(layer, palette_base_address, index, 0, draw_x, draw_y, index == 0);
            //     } else {
            //         ubyte index = memory.read_byte(tile_base_address + ((tile & 0x3ff) * 32) + y * 4 + (tile_x / 2));

            //         index = (tile_x % 2 == 0) ? index & 0xF : index >> 4;
            //         index += palette * 16;
            //         maybe_draw_pixel_on_layer(layer, palette_base_address, index, 0, draw_x, draw_y, (index & 0xF) == 0);
            //     }
            // } 
        }

        void texture(Layer layer, Texture texture, Point topleft_texture_pos, Point topleft_draw_pos) {
            int texture_bound_x_upper = texture.double_sized ? texture.width  >> 1 : texture.width;
            int texture_bound_y_upper = texture.double_sized ? texture.height >> 1 : texture.height;
            int texture_bound_x_lower = 0;
            int texture_bound_y_lower = 0;

            if (texture.double_sized) {
                topleft_texture_pos.x += texture.width  >> 2;
                topleft_texture_pos.y += texture.height >> 2;
            }
            for (int draw_x_offset = 0; draw_x_offset < texture.width; draw_x_offset++) {
                Point draw_pos = Point(topleft_draw_pos.x + draw_x_offset, topleft_draw_pos.y);
                Point texture_pos = draw_pos;

                if (texture.scaled) {
                    texture_pos = multiply_P_matrix(texture.reference_point, draw_pos, texture.p_matrix);
                    if ((texture_pos.x - topleft_texture_pos.x) < texture_bound_x_lower || (texture_pos.x - topleft_texture_pos.x) >= texture_bound_x_upper ||
                        (texture_pos.y - topleft_texture_pos.y) < texture_bound_y_lower || (texture_pos.y - topleft_texture_pos.y) >= texture_bound_y_upper)
                        continue;
                }

                if (texture.flipped_x) texture_pos.x = (topleft_texture_pos.x + texture.width  - 1) - (texture_pos.x - topleft_texture_pos.x);
                if (texture.flipped_y) texture_pos.y = (topleft_texture_pos.y + texture.height - 1) - (texture_pos.y - topleft_texture_pos.y);

                int tile_x = ((texture_pos.x - topleft_texture_pos.x) >> 3);
                int tile_y = ((texture_pos.y - topleft_texture_pos.y) >> 3);
                int ofs_x  = ((texture_pos.x - topleft_texture_pos.x) & 0b111);
                int ofs_y  = ((texture_pos.y - topleft_texture_pos.y) & 0b111);

                int tile_number = tile_x + texture.increment_per_row * tile_y + texture.base_tile_number;

                static if (bpp8) {
                    ubyte index = memory.read_byte(texture.tile_base_address + ((tile_number & 0x3ff) * 64) + ofs_y * 8 + ofs_x);
                    
                    maybe_draw_pixel_on_layer(layer, texture.palette_base_address, index, 0, draw_pos.x, draw_pos.y, index == 0);
                } else {
                    ubyte index = memory.read_byte(texture.tile_base_address + ((tile_number & 0x3ff) * 32) + ofs_y * 4 + (ofs_x / 2));

                    index = !(ofs_x % 2) ? index & 0xF : index >> 4;
                    index += texture.palette * 16;
                    maybe_draw_pixel_on_layer(layer, texture.palette_base_address, index, 0, draw_pos.x, draw_pos.y, (index & 0xF) == 0);
                }
            }
        }
    }

    void render_background(uint priority) {
        for (int i = 0; i < 4; i++) {
            Background background = backgrounds[i];
            if (background.priority != priority || !background.enabled) continue;

            final switch (background.mode) {
                case BackgroundMode.TEXT:             render_background__text(i);             break;
                case BackgroundMode.ROTATION_SCALING: render_background__rotation_scaling(i); break;
            }
        }
    }
    void render_background__text(uint background_id) {
        // do we even render?
        Background background = backgrounds[background_id];
        if (!background.enabled) return;

        // relevant addresses for the background's tilemap and screen
        int screen_base_address = memory.OFFSET_VRAM + background.screen_base_block    * 0x800;
        int tile_base_address   = background.character_base_block * 0x4000;

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
            int tile = memory.read_halfword(screen_base_address + tile_address);

            int draw_x = tile_x_offset * 8 - tile_dx;
            int draw_y = scanline;

            bool flipped_x = (tile >> 10) & 1;
            bool flipped_y = (tile >> 11) & 1;

            // yes this looks stupid. and it is.
            if (background.doesnt_use_color_palettes) {
                Render!(true, false, false).tile(
                        Layer.A, tile, tile_base_address, 0, 
                        draw_x, tile_dy, 
                        0, 0, PMatrix(0, 0, 0, 0), false,
                        get_nth_bits(tile, 12, 16));
            } else {
                Render!(false, false, false).tile(
                        Layer.A, tile, tile_base_address, 0, 
                        draw_x, tile_dy, 
                        0, 0, PMatrix(0, 0, 0, 0), false,
                        get_nth_bits(tile, 12, 16));
            }
        }
    }

    void render_background__rotation_scaling(uint background_id) {
        // do we even render?
        Background background = backgrounds[background_id];
        if (!background.enabled) return;

        // relevant addresses for the background's tilemap and screen
        int screen_base_address = memory.OFFSET_VRAM + background.screen_base_block    * 0x800;
        int tile_base_address   = background.character_base_block * 0x4000;

        // the coordinates at the topleft of the background that we are drawing
        int topleft_x      = 0;//cast(int) (get_double_from_fixed_point(background.x_offset_rotation));
        int topleft_y      = scanline;//cast(int) (get_double_from_fixed_point(background.y_offset_rotation) + scanline);

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
            int tile = memory.read_byte(screen_base_address + tile_address);

            int draw_x = tile_x_offset * 8 - tile_dx;
            int draw_y = scanline;

            Render!(true, false, false).tile(Layer.A, tile, tile_base_address, 0, 
                               draw_x, tile_dy, 
                               0, 0, PMatrix(0, 0, 0, 0), false, 
                               get_nth_bits(tile, 12, 16));
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

    void render_sprites(int given_priority) {
        // Very useful guide for attributes! https://problemkaputt.de/gbatek.htm#lcdobjoamattributes
        for (int sprite = 0; sprite <= 127; sprite++) {
            if (get_nth_bits(memory.read_halfword(memory.OFFSET_OAM + sprite * 8 + 4), 10, 11) != given_priority) continue;

            // first of all, we need to figure out if we render this sprite in the first place.
            // so, we collect a bunch of info that'll help us figure that out.
            ushort attribute_0 = memory.read_halfword(memory.OFFSET_OAM + sprite * 8 + 0);

            // is this sprite even enabled
            if (get_nth_bits(attribute_0, 8, 10) == 0b10) continue;

            // it is enabled? great. let's get the other two attributes and collect some
            // relevant information.
            int attribute_1 = memory.read_halfword(memory.OFFSET_OAM + sprite * 8 + 2);
            int attribute_2 = memory.read_halfword(memory.OFFSET_OAM + sprite * 8 + 4);

            int size   = get_nth_bits(attribute_1, 14, 16);
            int shape  = get_nth_bits(attribute_0, 14, 16);

            ubyte width  = sprite_sizes[shape][size][0] >> 3;
            ubyte height = sprite_sizes[shape][size][1] >> 3;

            if (get_nth_bit(attribute_0, 9)) width  *= 2;
            if (get_nth_bit(attribute_0, 9)) height *= 2;

            int topleft_x = sign_extend(cast(ubyte) get_nth_bits(attribute_1,  0,  9), 9);
            int topleft_y = get_nth_bits(attribute_0,  0,  8);

            int middle_x = topleft_x + width  * 4;
            int middle_y = topleft_y + height * 4;

            if (scanline < topleft_y || scanline >= topleft_y + (height << 3)) continue;

            uint base_tile_number = cast(ushort) get_nth_bits(attribute_2, 0, 10);
            uint priority = get_nth_bits(attribute_2, 10, 11);

            int tile_number_increment_per_row = obj_character_vram_mapping ? (get_nth_bit(attribute_0, 9) ? width >> 1: width) : 32;

            bool doesnt_use_color_palettes = get_nth_bit(attribute_0, 13);

            bool flipped_x = get_nth_bit(attribute_1, 12);
            bool flipped_y = get_nth_bit(attribute_1, 13);

            bool scaled        = get_nth_bit(attribute_0, 8);
            int scaling_number = get_nth_bits(attribute_1, 9, 14);

            PMatrix p_matrix = PMatrix(
                convert_from_8_8f_to_double(memory.read_halfword(memory.OFFSET_OAM + 0x06 + 0x20 * scaling_number)),
                convert_from_8_8f_to_double(memory.read_halfword(memory.OFFSET_OAM + 0x0E + 0x20 * scaling_number)),
                convert_from_8_8f_to_double(memory.read_halfword(memory.OFFSET_OAM + 0x16 + 0x20 * scaling_number)),
                convert_from_8_8f_to_double(memory.read_halfword(memory.OFFSET_OAM + 0x1E + 0x20 * scaling_number))
            );

            // for (int tile_x_offset = 0; tile_x_offset < width; tile_x_offset++) {

            //     // get the tile address and read it from memory
            //     // int tile_address = get_tile_address(topleft_tile_x + tile_x_offset, topleft_tile_y + tile_y_offset, tile_number_increment_per_row);
            //     int tile = base_tile_number + (((scanline - topleft_y) >> 3) * tile_number_increment_per_row) + tile_x_offset;

            //     int draw_x = flipped_x ? (width  - tile_x_offset - 1) * 8 + topleft_x : tile_x_offset * 8 + topleft_x;
            //     int draw_y = flipped_y ? (height * 8 - (scanline - topleft_y) - 1) + topleft_y: scanline;
         
            Texture texture = Texture(base_tile_number, width << 3, height << 3, tile_number_increment_per_row, 
                                        scaled, p_matrix, Point(middle_x, middle_y),
                                        memory.OFFSET_VRAM + 0x10000, 0x200,
                                        get_nth_bits(attribute_2, 12, 16),
                                        flipped_x, flipped_y, get_nth_bit(attribute_0, 9));

            if (doesnt_use_color_palettes) Render!(true,  false, false).texture(Layer.A, texture, Point(topleft_x, topleft_y), Point(topleft_x, scanline));
            else                           Render!(false, false, false).texture(Layer.A, texture, Point(topleft_x, topleft_y), Point(topleft_x, scanline));
        }
    }

    struct PMatrix {
        double pA;
        double pB;
        double pC;
        double pD;
    }

    Point multiply_P_matrix(Point reference_point, Point original_point, PMatrix p_matrix) {
        return Point(
            cast(int) (p_matrix.pA * (original_point.x - reference_point.x) + p_matrix.pB * (original_point.y - reference_point.y)) + reference_point.x,
            cast(int) (p_matrix.pC * (original_point.x - reference_point.x) + p_matrix.pD * (original_point.y - reference_point.y)) + reference_point.y
        );
    }

    void maybe_draw_pixel_on_layer(Layer layer, uint palette_offset, uint palette_index, uint priority, uint x, uint y, bool transparent) {
        if (!transparent) {
            // pixel_priorities[x][y] = priority;
            draw_pixel(layer, palette_offset, palette_index, priority, x, y, transparent);
        }
    }

    void draw_pixel(Layer layer, uint palette_offset, uint palette_index, uint priority, uint x, uint y, bool transparent) {
        // warning(format("%x", palette_offset));
        if (x >= SCREEN_WIDTH || y >= SCREEN_HEIGHT) return;

        canvas.draw(x, y, memory.OFFSET_PALETTE_RAM + palette_offset + palette_index * 2, layer);
    }
    void render_canvas() {
        for (int x = 0; x < SCREEN_WIDTH;  x++) {
        for (int y = 0; y < SCREEN_HEIGHT; y++) {
            memory.set_rgb(x, y, cast(ubyte) (canvas.pixels_output[x][y].r << 3), 
                                 cast(ubyte) (canvas.pixels_output[x][y].g << 3), 
                                 cast(ubyte) (canvas.pixels_output[x][y].b << 3));
        }
        }
    }

    void update_bg_mode() {
        switch (bg_mode) {
            case 0:
                backgrounds[0].mode = BackgroundMode.TEXT;
                backgrounds[1].mode = BackgroundMode.TEXT;
                backgrounds[2].mode = BackgroundMode.TEXT;
                backgrounds[3].mode = BackgroundMode.TEXT;
                break;

            case 1:
                backgrounds[0].mode = BackgroundMode.TEXT;
                backgrounds[1].mode = BackgroundMode.TEXT;
                backgrounds[2].mode = BackgroundMode.ROTATION_SCALING;
                backgrounds[3].mode = BackgroundMode.ROTATION_SCALING;
                break;

            case 2:
                backgrounds[0].mode = BackgroundMode.ROTATION_SCALING;
                backgrounds[1].mode = BackgroundMode.ROTATION_SCALING;
                backgrounds[2].mode = BackgroundMode.ROTATION_SCALING;
                backgrounds[3].mode = BackgroundMode.ROTATION_SCALING;
                break;
        
            default:
                break;
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
    public bool  vblank;
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
            update_bg_mode();
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

    void write_WINXH(int target_byte, ubyte data, int x) {
        if (target_byte == 0) {
            windows[x].right = data;
        } else { // target_byte == 1
            windows[x].left = data;
        }
    }

    void write_WINXV(int target_byte, ubyte data, int x) {
        if (target_byte == 0) {
            windows[x].bottom = data;
        } else { // target_byte == 1
            windows[x].top = data;
        }
    }

    void write_BGxX(int target_byte, ubyte data, int x) {
        final switch (target_byte) {
            case 0b00:
                backgrounds[x].x_offset_rotation.fraction = data;
                break;
            case 0b01:
                backgrounds[x].x_offset_rotation.integer &= 0xFFFFFF00;
                backgrounds[x].x_offset_rotation.integer |= data;
                break;
            case 0b10:
                backgrounds[x].x_offset_rotation.integer &= 0xFFFF00FF;
                backgrounds[x].x_offset_rotation.integer |= data << 8;
                break;
            case 0b11:
                backgrounds[x].x_offset_rotation.integer &= 0xFFF8FFFF;
                backgrounds[x].x_offset_rotation.integer |= (data & 0b111) << 16;

                if ((data >> 3) ^ (backgrounds[x].x_offset_rotation.integer < 0)) {
                    backgrounds[x].x_offset_rotation.integer *= -1;
                } 
                break;
        }
    }

    void write_BGxY(int target_byte, ubyte data, int x) {
        final switch (target_byte) {
            case 0b00:
                backgrounds[x].y_offset_rotation.fraction = data;
                break;
            case 0b01:
                backgrounds[x].y_offset_rotation.integer &= 0xFFFFFF00;
                backgrounds[x].y_offset_rotation.integer |= data;
                break;
            case 0b10:
                backgrounds[x].y_offset_rotation.integer &= 0xFFFF00FF;
                backgrounds[x].y_offset_rotation.integer |= data << 8;
                break;
            case 0b11:
                backgrounds[x].y_offset_rotation.integer &= 0xFFF8FFFF;
                backgrounds[x].y_offset_rotation.integer |= (data & 0b111) << 16;

                if ((data >> 3) ^ (backgrounds[x].y_offset_rotation.integer < 0)) {
                    backgrounds[x].y_offset_rotation.integer *= -1;
                } 
                break;
        }
    }


    void write_WININ(int target_byte, ubyte data) {

    }

    void write_WINOUT(int target_byte, ubyte data) {
        
    }

    void write_BLDCNT(int target_byte, ubyte data) {
    //     void maybe_set_special_effect_layer(Layer layer, SpecialEffectLayer special_effect_layer, bool condition) {
    //         if (layer.special_effect_layer == special_effect_layer || layer.special_effect_layer == SpecialEffectLayer.None) {
    //             layer.special_effect_layer = condition ? special_effect_layer : SpecialEffectLayer.None;
    //         }
    //     }
        
    //     final switch (target_byte) {
    //         case 0b0:
    //             maybe_set_special_effect_layer(layer_backgrounds[0], SpecialEffectLayer.A, get_nth_bit(data, 0));
    //             maybe_set_special_effect_layer(layer_backgrounds[1], SpecialEffectLayer.A, get_nth_bit(data, 1));
    //             maybe_set_special_effect_layer(layer_backgrounds[2], SpecialEffectLayer.A, get_nth_bit(data, 2));
    //             maybe_set_special_effect_layer(layer_backgrounds[3], SpecialEffectLayer.A, get_nth_bit(data, 3));
    //             // TODO: OBJ BLENDING
    //             maybe_set_special_effect_layer(layer_backdrop      , SpecialEffectLayer.A, get_nth_bit(data, 5));
    //             special_effect = cast(SpecialEffect) get_nth_bits(data, 6, 8);

    //             break;
    //         case 0b1:
    //             maybe_set_special_effect_layer(layer_backgrounds[0], SpecialEffectLayer.B, get_nth_bit(data, 0));
    //             maybe_set_special_effect_layer(layer_backgrounds[1], SpecialEffectLayer.B, get_nth_bit(data, 1));
    //             maybe_set_special_effect_layer(layer_backgrounds[2], SpecialEffectLayer.B, get_nth_bit(data, 2));
    //             maybe_set_special_effect_layer(layer_backgrounds[3], SpecialEffectLayer.B, get_nth_bit(data, 3));
    //             // TODO: OBJ BLENDING
    //             maybe_set_special_effect_layer(layer_backdrop      , SpecialEffectLayer.B, get_nth_bit(data, 5));
    //             break;
    //     }
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
    //     final switch (target_byte) {
    //         case 0b0:
    //             return ((layer_backgrounds[0].special_effect_layer == SpecialEffectLayer.A) << 0) |
    //                    ((layer_backgrounds[1].special_effect_layer == SpecialEffectLayer.A) << 1) |
    //                    ((layer_backgrounds[2].special_effect_layer == SpecialEffectLayer.A) << 2) |
    //                    ((layer_backgrounds[3].special_effect_layer == SpecialEffectLayer.A) << 3) |
    //                    (((cast(int) special_effect) & 0b11)                                 << 4);
                       
    //         case 0b1:
    //             return ((layer_backgrounds[0].special_effect_layer == SpecialEffectLayer.B) << 0) |
    //                    ((layer_backgrounds[1].special_effect_layer == SpecialEffectLayer.B) << 1) |
    //                    ((layer_backgrounds[2].special_effect_layer == SpecialEffectLayer.B) << 2) |
    //                    ((layer_backgrounds[3].special_effect_layer == SpecialEffectLayer.B) << 3);
    //     }
        return 0x0;
    }

    ubyte read_WININ(int target_byte) {
        return 0;
    }

    ubyte read_WINOUT(int target_byte) {
        return 0;
    }
}