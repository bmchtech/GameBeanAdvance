module hw.ppu.lcd;

import hw.memory;
import hw.ppu;
import hw.interrupts;

import util;
import scheduler;

import std.stdio;
import std.typecons;
import std.algorithm;

enum SCREEN_WIDTH  = 240;
enum SCREEN_HEIGHT = 160;

enum AffineParameter {
    A = 0,
    B = 1,
    C = 2,
    D = 3
}

class PPU {
    // General information:
    // - Contains 227 scanlines, 160+ is VBLANK. VBLANK is not set on scanline 227.
    // - HBLANK is constantly toggled
    // - Although the drawing time is only 960 cycles (240*4), the H-Blank flag is "0" for a total of 1006 cycles.

public:
    void delegate(uint) interrupt_cpu;
    void delegate()     on_hblank_callback;
    void delegate()     frontend_vblank_callback;
    
    enum Pixel RESET_PIXEL = Pixel(0, 0, 0);

    ushort scanline;

    Canvas canvas;

    Pixel[SCREEN_WIDTH][SCREEN_HEIGHT] screen;

    Scheduler scheduler;

    this(Memory memory, Scheduler scheduler, void delegate(uint) interrupt_cpu, void delegate() on_hblank_callback) {
        this.memory             = memory;
        this.interrupt_cpu      = interrupt_cpu;
        this.on_hblank_callback = on_hblank_callback;
        dot                     = 0;
        scanline                = 0;

        canvas = new Canvas(this);

        this.scheduler = scheduler;
        scheduler.add_event_relative_to_self(&on_hblank_start, 240 * 4);
        scheduler.add_event_relative_to_self(&on_vblank_start, 308 * 160 * 4);

        // background_init(memory);
    }

    void set_frontend_vblank_callback(void delegate() frontend_vblank_callback) {
        this.frontend_vblank_callback = frontend_vblank_callback;
    }

    void on_hblank_start() {
        if (vcounter_irq_enabled && scanline == vcount_lyc) {
            interrupt_cpu(Interrupt.LCD_VCOUNTER_MATCH);
        }
        
        hblank = true;
        if (hblank_irq_enabled) interrupt_cpu(Interrupt.LCD_HBLANK);


        if (!vblank) {
            canvas.reset();

            // horizontal mosaic is a post processing effect done on the canvas
            // whereas vertical mosaic is a pre processing effect done on the
            // lcd itself.
            apply_vertical_mosaic();

            render();

            canvas.apply_horizontal_mosaic(bg_mosaic_h, obj_mosaic_h);

            if (bg_mode != 3) canvas.composite();

            display_scanline();

            backgrounds[2].internal_reference_x += backgrounds[2].p[AffineParameter.B];
            backgrounds[2].internal_reference_y += backgrounds[2].p[AffineParameter.D];
            backgrounds[3].internal_reference_x += backgrounds[3].p[AffineParameter.B];
            backgrounds[3].internal_reference_y += backgrounds[3].p[AffineParameter.D];
        }

        if (!vblank) on_hblank_callback();

        scheduler.add_event_relative_to_self(&on_hblank_end, 68 * 4);

        // writefln("%x %x", backgrounds[2].internal_reference_x, backgrounds[2].internal_reference_y);
    }

    void on_hblank_end() {
        hblank = false;
        scanline++;

        scheduler.add_event_relative_to_self(&on_hblank_start, 240 * 4);
    }

    void on_vblank_start() {
        vblank = true;
        if (vblank_irq_enabled) interrupt_cpu(Interrupt.LCD_VBLANK);

        scheduler.add_event_relative_to_self(&on_vblank_end, 308 * 68 * 4);

        reload_background_internal_affine_registers(2);
        reload_background_internal_affine_registers(3);
    }

    void on_vblank_end() {
        scanline = 0;
        vblank = false;
        frontend_vblank_callback();

        scheduler.add_event_relative_to_self(&on_vblank_start, 308 * 160 * 4);
    }

    void render() {
        switch (bg_mode) {
            case 0: 
            case 1:
            case 2:
                render_sprites(0);
                render_background(0);
                render_sprites(1);
                render_background(1);
                render_sprites(2);
                render_background(2);
                render_sprites(3);
                render_background(3);
                break;

            case 3: {
                // in mode 3, the dot and scanline (x and y) simply tell us where to read from in VRAM. The colors
                // are stored directly, so we just read from VRAM and interpret as a 15bit highcolor
                uint bg_scanline = backgrounds[2].is_mosaic ? apparent_bg_scanline : scanline;

                for (uint x = 0; x < 240; x++) {
                    canvas.pixels_output[x] = get_pixel_from_color(read_VRAM!ushort(OFFSET_VRAM + (x + bg_scanline * 240) * 2));
                }
                break;
            }

            case 4:
            case 5: {
                // modes 4 and 5 are a step up from mode 3. the address of where the colors are stored can
                // be found using DISPCNT.
                uint base_frame_address = OFFSET_VRAM + disp_frame_select * 0xA000;

                uint bg_scanline = backgrounds[2].is_mosaic ? apparent_bg_scanline : scanline;

                for (uint x = 0; x < 240; x++) {
                    // the index in palette ram that we need to lookinto  is then found in the base frame.
                    ubyte index = read_VRAM!ubyte(base_frame_address + (x + bg_scanline * 240));
                    canvas.draw_bg_pixel(x, 2, index, 0, false);
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
    // uint[][] pixel_priorities; // the associated priorities with each pixel.

    // some basic ways to access VRAM easier
    

    static int[][] BG_TEXT_SCREENS_DIMENSIONS = [
        [1, 1],
        [2, 1],
        [1, 2],
        [2, 2]
    ];

    static int[] BG_ROTATION_SCALING_TILE_DIMENSIONS = [
        16, 32, 64, 128
    ];

    static int[] BG_ROTATION_SCALING_TILE_DIMENSIONS_MASKS = [
        0xF, 0x1F, 0x3F, 0x7F      
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

    ushort apparent_bg_scanline;
    ushort apparent_obj_scanline;
    void apply_vertical_mosaic() {
        apparent_bg_scanline  = cast(ushort) (scanline - (scanline % bg_mosaic_v));
        apparent_obj_scanline = cast(ushort) (scanline - (scanline % obj_mosaic_v));
    }

    pragma(inline, true) int get_tile_address__text(int tile_x, int tile_y, int screens_per_row, int screens_per_col) {
        // each screen is 32 x 32 tiles. so to get the tile offset within its screen
        // we can get the low 5 bits
        int tile_x_within_screen = tile_x & 0x1F;
        int tile_y_within_screen = tile_y & 0x1F;

        // similarly we can find out which screen this tile is located in
        // by getting its high bit
        int screen_x             = min((tile_x >> 5) & 1, screens_per_row - 1);
        int screen_y             = min((tile_y >> 5) & 1, screens_per_col - 1);
        int screen               = screen_x + screen_y * screens_per_row;

        int tile_address_offset_within_screen = ((tile_y_within_screen * 32) + tile_x_within_screen) * 2;
        return tile_address_offset_within_screen + screen * 0x800; 
    }

    pragma(inline, true) int get_tile_address__rotation_scaling(int tile_x, int tile_y, int tiles_per_row) {
        return ((tile_y * tiles_per_row) + tile_x);
    }

    template Render(bool bpp8, bool flipped_x, bool flipped_y) {

        void tile(int bg, int priority, int tile, int tile_base_address, int palette_base_address, int left_x, int y, int palette) {
            // Point reference_point = Point(ref_x, ref_y);
            static if (bpp8) {
                static if (flipped_y) uint tile_address = tile_base_address + (tile & 0x3ff) * 64 + (7 - y) * 8;    
                else                  uint tile_address = tile_base_address + (tile & 0x3ff) * 64 + (y)     * 8;
            } else {
                static if (flipped_y) uint tile_address = tile_base_address + (tile & 0x3ff) * 32 + (7 - y) * 4;    
                else                  uint tile_address = tile_base_address + (tile & 0x3ff) * 32 + (y)     * 4;
            }
            
            ubyte[8] tile_data = memory.vram[tile_address .. tile_address + 8];

            // hi. i hate this. but ive profiled it and it makes the code miles faster.
            static if (flipped_x) {
                int draw_dx = 0;

                static if (bpp8) {
                    for (int tile_dx = 7; tile_dx >= 0; tile_dx--) {
                        ubyte index = tile_data[tile_dx];
                        canvas.draw_bg_pixel(left_x + draw_dx, bg, index, priority, index == 0);
                        draw_dx++;
                    }
                } else {
                    for (int tile_dx = 3; tile_dx >= 0; tile_dx--) {
                        ubyte index = tile_data[tile_dx];
                        canvas.draw_bg_pixel(left_x + draw_dx * 2 + 1, bg, cast(ubyte) ((index & 0xF) + (palette * 16)), priority, (index & 0xF) == 0);
                        canvas.draw_bg_pixel(left_x + draw_dx * 2,     bg, cast(ubyte) ((index >> 4)  + (palette * 16)), priority, (index >> 4)  == 0);
                        draw_dx++;
                    }
                }
            } else {
                static if (bpp8) {
                    for (int tile_dx = 0; tile_dx < 8; tile_dx++) {
                        ubyte index = tile_data[tile_dx];
                        canvas.draw_bg_pixel(left_x + tile_dx, bg, index, priority, index == 0);
                    }
                } else {
                    for (int tile_dx = 0; tile_dx < 4; tile_dx++) {
                        ubyte index = tile_data[tile_dx];
                        canvas.draw_bg_pixel(left_x + tile_dx * 2,     bg, cast(ubyte) ((index & 0xF) + (palette * 16)), priority, (index & 0xF) == 0);
                        canvas.draw_bg_pixel(left_x + tile_dx * 2 + 1, bg, cast(ubyte) ((index >> 4)  + (palette * 16)), priority, (index >> 4)  == 0);
                    }
                }
            } 
        }

        void texture(int priority, Texture texture, Point topleft_texture_pos, Point topleft_draw_pos, OBJMode obj_mode) {
            int texture_bound_x_upper = texture.double_sized ? texture.width  >> 1 : texture.width;
            int texture_bound_y_upper = texture.double_sized ? texture.height >> 1 : texture.height;
            int texture_bound_x_lower = 0;
            int texture_bound_y_lower = 0;
            
            if (obj_character_vram_mapping && bpp8) texture.base_tile_number >>= 1;

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

                int tile_number;
                if (!obj_character_vram_mapping) {
                    if (bpp8) tile_number = (2 * tile_x + texture.increment_per_row * tile_y + texture.base_tile_number) >> 1;
                    else tile_number = tile_x + texture.increment_per_row * tile_y + texture.base_tile_number;

                } else {
                    tile_number = tile_x + texture.increment_per_row * tile_y + texture.base_tile_number;
                }
                    

                static if (bpp8) {
                    // writefln("%x", texture.tile_base_address + ((tile_number & 0x3ff) * 64) );

                    ubyte index = read_VRAM!ubyte(texture.tile_base_address + ((tile_number & 0x3ff) * 64) + ofs_y * 8 + ofs_x);
                    
                    if (obj_mode != OBJMode.OBJ_WINDOW) {
                        canvas.draw_obj_pixel(draw_pos.x, index + 256, priority, index == 0, obj_mode == OBJMode.SEMI_TRANSPARENT);
                    } else {
                        if (index != 0) canvas.set_obj_window(draw_pos.x);
                    }

                } else {
                    ubyte index = read_VRAM!ubyte(texture.tile_base_address + ((tile_number & 0x3ff) * 32) + ofs_y * 4 + (ofs_x / 2));

                    index = !(ofs_x % 2) ? index & 0xF : index >> 4;
                    index += texture.palette * 16;

                    if (obj_mode != OBJMode.OBJ_WINDOW) {
                        canvas.draw_obj_pixel(draw_pos.x, index + 256, priority, (index & 0xF) == 0, obj_mode == OBJMode.SEMI_TRANSPARENT);
                    } else {
                        if ((index & 0xF) != 0) canvas.set_obj_window(draw_pos.x);
                    }
                }
            }
        }
    }

    void render_background(uint i) {
        Background background = backgrounds[i];
        final switch (background.mode) {
            case BackgroundMode.TEXT:             render_background__text(i);             break;
            case BackgroundMode.ROTATION_SCALING: render_background__rotation_scaling(i); break;
            case BackgroundMode.NONE:             break;
        }
    }
    
    void render_background__text(uint background_id) {
        // do we even render?
        Background background = backgrounds[background_id];
        if (!background.enabled) return;

        uint bg_scanline = background.is_mosaic ? apparent_bg_scanline : scanline;

        // relevant addresses for the background's tilemap and screen
        int screen_base_address = OFFSET_VRAM + background.screen_base_block    * 0x800;
        int tile_base_address   = background.character_base_block * 0x4000;

        // the coordinates at the topleft of the background that we are drawing
        int topleft_x      = background.x_offset;
        int topleft_y      = background.y_offset + bg_scanline;

        // the tile number at the topleft of the background that we are drawing
        int topleft_tile_x = topleft_x >> 3;
        int topleft_tile_y = topleft_y >> 3;

        // how far back do we have to render the tile? because the topleft of the screen
        // usually doesn't mark the start of the tile, so these are the offsets we can
        // subtract to handle the mislignment
        int tile_dx        = topleft_x & 0b111;
        int tile_dy        = topleft_y & 0b111;

        // to understand this, go to the switch down below
        // im just precalculating this one bit since it stays the same
        int template_args  = background.doesnt_use_color_palettes << 2;

        // tile_x_offset and tile_y_offset are offsets from the topleft tile. we use this to iterate through
        // each tile.
        for (int tile_x_offset = 0; tile_x_offset < 32 + 1; tile_x_offset++) {

            // get the tile address and read it from memory
            int tile_address = get_tile_address__text(topleft_tile_x + tile_x_offset, topleft_tile_y, 
                                                      BG_TEXT_SCREENS_DIMENSIONS[background.screen_size][0],
                                                      BG_TEXT_SCREENS_DIMENSIONS[background.screen_size][1]);
            int tile = read_VRAM!ushort(screen_base_address + tile_address);

            int draw_x = tile_x_offset * 8 - tile_dx;
            int draw_y = bg_scanline;

            bool flipped_x = (tile >> 10) & 1;
            bool flipped_y = (tile >> 11) & 1;

            // i hate how silly this looks, but i've checked and having the render tile function templated makes the code run a lot faster
            final switch (template_args | (flipped_x << 1) | flipped_y) {
                case 0b000: Render!(false, false, false).tile(background_id, backgrounds[background_id].priority, tile, tile_base_address, 0, draw_x, tile_dy, get_nth_bits(tile, 12, 16)); break;
                case 0b001: Render!(false, false,  true).tile(background_id, backgrounds[background_id].priority, tile, tile_base_address, 0, draw_x, tile_dy, get_nth_bits(tile, 12, 16)); break;
                case 0b010: Render!(false,  true, false).tile(background_id, backgrounds[background_id].priority, tile, tile_base_address, 0, draw_x, tile_dy, get_nth_bits(tile, 12, 16)); break;
                case 0b011: Render!(false,  true,  true).tile(background_id, backgrounds[background_id].priority, tile, tile_base_address, 0, draw_x, tile_dy, get_nth_bits(tile, 12, 16)); break;
                case 0b100: Render!( true, false, false).tile(background_id, backgrounds[background_id].priority, tile, tile_base_address, 0, draw_x, tile_dy, get_nth_bits(tile, 12, 16)); break;
                case 0b101: Render!( true, false,  true).tile(background_id, backgrounds[background_id].priority, tile, tile_base_address, 0, draw_x, tile_dy, get_nth_bits(tile, 12, 16)); break;
                case 0b110: Render!( true,  true, false).tile(background_id, backgrounds[background_id].priority, tile, tile_base_address, 0, draw_x, tile_dy, get_nth_bits(tile, 12, 16)); break;
                case 0b111: Render!( true,  true,  true).tile(background_id, backgrounds[background_id].priority, tile, tile_base_address, 0, draw_x, tile_dy, get_nth_bits(tile, 12, 16)); break;
            }
        }
    }

    void render_background__rotation_scaling(uint background_id) {
        // do we even render?
        Background background = backgrounds[background_id];
        if (!background.enabled) return;

        uint bg_scanline = background.is_mosaic ? apparent_bg_scanline : scanline;

        // relevant addresses for the background's tilemap and screen
        int screen_base_address = OFFSET_VRAM + background.screen_base_block * 0x800;
        int tile_base_address   = background.character_base_block * 0x4000;

        // the coordinates at the topleft of the background that we are drawing
        long texture_point_x = background.internal_reference_x;
        long texture_point_y = background.internal_reference_y;
        // writefln("%x, %x", background.internal_reference_x, background.internal_reference_y);
        // writefln("%x, %x", background.x_offset_rotation, background.y_offset_rotation + (bg_scanline << 8));
        // rotation/scaling backgrounds are squares
        int tiles_per_row = BG_ROTATION_SCALING_TILE_DIMENSIONS      [background.screen_size];
        int tile_mask     = BG_ROTATION_SCALING_TILE_DIMENSIONS_MASKS[background.screen_size];

        for (int x = 0; x < 240; x++) {
            // truncate the decimal because texture_point is 8-bit fixed point
            Point truncated_texture_point = Point(cast(int) texture_point_x >> 8,
                                                  cast(int) texture_point_y >> 8);
            int tile_x = truncated_texture_point.x >> 3;
            int tile_y = truncated_texture_point.y >> 3;
            int fine_x = truncated_texture_point.x & 0b111;
            int fine_y = truncated_texture_point.y & 0b111;

            if (background.does_display_area_overflow ||
                ((0 <= tile_x && tile_x < tiles_per_row) &&
                 (0 <= tile_y && tile_y < tiles_per_row))) {
                tile_x &= tile_mask;
                tile_y &= tile_mask;
                
                int tile_address = get_tile_address__rotation_scaling(tile_x, tile_y, tiles_per_row);
                int tile = read_VRAM!ubyte(screen_base_address + tile_address);

                ubyte color_index = memory.vram[tile_base_address + (tile & 0x3FF) * 64 + fine_y * 8 + fine_x];
                canvas.draw_bg_pixel(x, background_id, color_index, background.priority, color_index == 0);
            }

            texture_point_x += background.p[AffineParameter.A];
            texture_point_y += background.p[AffineParameter.C];
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

    enum OBJMode {
        NORMAL           = 0,
        SEMI_TRANSPARENT = 1,
        OBJ_WINDOW       = 2,
        PROHIBITED       = 3
    }

    void render_sprites(int given_priority) {
        if (!sprites_enabled) return;

        // Very useful guide for attributes! https://problemkaputt.de/gbatek.htm#lcdobjoamattributes
        for (int sprite = 0; sprite < 128; sprite++) {

            if (get_nth_bits(read_OAM!ushort(OFFSET_OAM + sprite * 8 + 4), 10, 12) != given_priority) continue;

            // first of all, we need to figure out if we render this sprite in the first place.
            // so, we collect a bunch of info that'll help us figure that out.
            ushort attribute_0 = read_OAM!ushort(OFFSET_OAM + sprite * 8 + 0);

            // is this sprite even enabled
            if (get_nth_bits(attribute_0, 8, 10) == 0b10) continue;

            // it is enabled? great. let's get the other two attributes and collect some
            // relevant information.
            int attribute_1 = read_OAM!ushort(OFFSET_OAM + sprite * 8 + 2);
            int attribute_2 = read_OAM!ushort(OFFSET_OAM + sprite * 8 + 4);

            int size   = get_nth_bits(attribute_1, 14, 16);
            int shape  = get_nth_bits(attribute_0, 14, 16);

            ubyte width  = sprite_sizes[shape][size][0] >> 3;
            ubyte height = sprite_sizes[shape][size][1] >> 3;

            if (get_nth_bit(attribute_0, 9)) width  *= 2;
            if (get_nth_bit(attribute_0, 9)) height *= 2;

            int topleft_x = sign_extend(cast(ushort) get_nth_bits(attribute_1,  0,  9), 9);
            int topleft_y = get_nth_bits(attribute_0,  0,  8);
            if (topleft_y > 160) topleft_y -= 256; 

            int middle_x = topleft_x + width  * 4;
            int middle_y = topleft_y + height * 4;

            if (apparent_obj_scanline < topleft_y || apparent_obj_scanline >= topleft_y + (height << 3)) continue;

            OBJMode obj_mode = cast(OBJMode) get_nth_bits(attribute_0, 10, 12);

            uint base_tile_number = cast(ushort) get_nth_bits(attribute_2, 0, 10);
            int tile_number_increment_per_row = obj_character_vram_mapping ? (get_nth_bit(attribute_0, 9) ? width >> 1 : width) : 32;

            bool doesnt_use_color_palettes = get_nth_bit(attribute_0, 13);
            bool scaled    = get_nth_bit(attribute_0, 8);
            bool flipped_x = !scaled && get_nth_bit(attribute_1, 12);
            bool flipped_y = !scaled && get_nth_bit(attribute_1, 13);

            int scaling_number = get_nth_bits(attribute_1, 9, 14);
            // if (!obj_character_vram_mapping && doesnt_use_color_palettes) base_tile_number >>= 1;

            PMatrix p_matrix = PMatrix(
                convert_from_8_8f_to_double(read_OAM!ushort(OFFSET_OAM + 0x06 + 0x20 * scaling_number)),
                convert_from_8_8f_to_double(read_OAM!ushort(OFFSET_OAM + 0x0E + 0x20 * scaling_number)),
                convert_from_8_8f_to_double(read_OAM!ushort(OFFSET_OAM + 0x16 + 0x20 * scaling_number)),
                convert_from_8_8f_to_double(read_OAM!ushort(OFFSET_OAM + 0x1E + 0x20 * scaling_number))
            );

            // for (int tile_x_offset = 0; tile_x_offset < width; tile_x_offset++) {

            //     // get the tile address and read it from memory
            //     // int tile_address = get_tile_address(topleft_tile_x + tile_x_offset, topleft_tile_y + tile_y_offset, tile_number_increment_per_row);
            //     int tile = base_tile_number + (((scanline - topleft_y) >> 3) * tile_number_increment_per_row) + tile_x_offset;

            //     int draw_x = flipped_x ? (width  - tile_x_offset - 1) * 8 + topleft_x : tile_x_offset * 8 + topleft_x;
            //     int draw_y = flipped_y ? (height * 8 - (scanline - topleft_y) - 1) + topleft_y: scanline;
         
            Texture texture = Texture(base_tile_number, width << 3, height << 3, tile_number_increment_per_row, 
                                        scaled, p_matrix, Point(middle_x, middle_y),
                                        OFFSET_VRAM + 0x10000, 0x200,
                                        get_nth_bits(attribute_2, 12, 16),
                                        flipped_x, flipped_y, get_nth_bit(attribute_0, 9));

            if (doesnt_use_color_palettes) Render!(true,  false, false).texture(given_priority, texture, Point(topleft_x, topleft_y), Point(topleft_x, apparent_obj_scanline), obj_mode);
            else                           Render!(false, false, false).texture(given_priority, texture, Point(topleft_x, topleft_y), Point(topleft_x, apparent_obj_scanline), obj_mode);
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

    void display_scanline() {
        for (int x = 0; x < SCREEN_WIDTH;  x++) {
            memory.set_rgb(x, scanline, cast(ubyte) (canvas.pixels_output[x].r << 3), 
                                        cast(ubyte) (canvas.pixels_output[x].g << 3), 
                                        cast(ubyte) (canvas.pixels_output[x].b << 3));
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
                backgrounds[3].mode = BackgroundMode.NONE;
                break;

            case 2:
                backgrounds[0].mode = BackgroundMode.NONE;
                backgrounds[1].mode = BackgroundMode.NONE;
                backgrounds[2].mode = BackgroundMode.ROTATION_SCALING;
                backgrounds[3].mode = BackgroundMode.ROTATION_SCALING;
                break;
        
            default:
                break;
        }
    }

    void reload_background_internal_affine_registers(uint bg_id) {
        backgrounds[bg_id].internal_reference_x = backgrounds[bg_id].x_offset_rotation;
        backgrounds[bg_id].internal_reference_y = backgrounds[bg_id].y_offset_rotation;
    }

    pragma(inline, true) T read_VRAM(T)(uint address) {
        static if (is(T == ubyte )) uint shift = 0;
        static if (is(T == ushort)) uint shift = 1;
        static if (is(T == uint  )) uint shift = 2;

        uint wrapped_address = address & (SIZE_VRAM - 1);
        if (wrapped_address >= 0x18000) wrapped_address -= 0x8000;
        return (cast(T*) memory.vram)[wrapped_address >> shift];
    }

    pragma(inline, true) T read_OAM(T)(uint address) {
        static if (is(T == ubyte )) uint shift = 0;
        static if (is(T == ushort)) uint shift = 1;
        static if (is(T == uint  )) uint shift = 2;
        return (cast(T*) memory.oam)[(address & (SIZE_OAM - 1)) >> shift]; 
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
    public int bg_mode;                             // 0 - 5
    int  disp_frame_select;                         // 0 - 1
    bool hblank_interval_free;                      // 1 = OAM can be accessed during h-blank
    bool is_character_vram_mapping_one_dimensional; // 2 = 2-dimensional
    bool obj_character_vram_mapping;
    bool forced_blank;
    bool sprites_enabled;

    // DISPSTAT
    public bool  vblank;
    bool  hblank;
    bool  vblank_irq_enabled;
    bool  hblank_irq_enabled;
    bool  vcounter_irq_enabled;
    ubyte vcount_lyc;

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
            sprites_enabled            = get_nth_bit (data, 4);
            canvas.windows[0].enabled  = get_nth_bit (data, 5);
            canvas.windows[1].enabled  = get_nth_bit (data, 6);
            canvas.obj_window_enable   = get_nth_bit (data, 7);
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
            backgrounds[x].bgcnt_bits_4_and_5         = get_nth_bits(data, 4, 6);
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

    void write_WINxH(int target_byte, ubyte data, int x) {
        // writefln("SCANLINE %x", scanline);
        // writefln("Window %x [%x : %x] [%x : %x]", x, canvas.windows[x].left, canvas.windows[x].right, canvas.windows[x].top, canvas.windows[x].bottom);
        if (target_byte == 0) {
            canvas.windows[x].right = data;
        } else { // target_byte == 1
            canvas.windows[x].left = data;
        }
    }

    void write_WINxV(int target_byte, ubyte data, int x) {
        // writefln("Window %x %x %x", target_byte, data, x);
        if (target_byte == 0) {
            canvas.windows[x].bottom = data;
        } else { // target_byte == 1
            canvas.windows[x].top = data;
        }
    }

    void write_WININ(int target_byte, ubyte data) {
        // the target_byte happens to specify the window here
        canvas.windows[target_byte].bg_enable  = get_nth_bits(data, 0, 4);
        canvas.windows[target_byte].obj_enable = get_nth_bit (data, 4);
        canvas.windows[target_byte].blended    = get_nth_bit (data, 5);
    }

    void write_WINOUT(int target_byte, ubyte data) {
        final switch (target_byte) {
            case 0b0:
                canvas.outside_window_bg_enable  = get_nth_bits(data, 0, 4);
                canvas.outside_window_obj_enable = get_nth_bit (data, 4);
                canvas.outside_window_blended    = get_nth_bit (data, 5);
                break;

            case 0b1:
                canvas.obj_window_bg_enable      = get_nth_bits(data, 0, 4);
                canvas.obj_window_obj_enable     = get_nth_bit (data, 4);
                canvas.obj_window_blended        = get_nth_bit (data, 5);
                break;
        }
    }

    int bg_mosaic_h  = 1;
    int bg_mosaic_v  = 1;
    int obj_mosaic_h = 1;
    int obj_mosaic_v = 1;
    void write_MOSAIC(int target_byte, ubyte data) {
        final switch (target_byte) {
            case 0b0:
                bg_mosaic_h = (data & 0xF) + 1;
                bg_mosaic_v = (data >> 4)  + 1;
                break;

            case 0b1:
                obj_mosaic_h = (data & 0xF) + 1;
                obj_mosaic_v = (data >> 4)  + 1;
                break;
        }
    }

    void write_BGxX(int target_byte, ubyte data, int x) {
        final switch (target_byte) {
            case 0b00:
                backgrounds[x].x_offset_rotation &= 0xFFFFFF00;
                backgrounds[x].x_offset_rotation |= data;
                break;
            case 0b01:
                backgrounds[x].x_offset_rotation &= 0xFFFF00FF;
                backgrounds[x].x_offset_rotation |= data << 8;
                break;
            case 0b10:
                backgrounds[x].x_offset_rotation &= 0xFF00FFFF;
                backgrounds[x].x_offset_rotation |= data << 16;
                break;
            case 0b11:
                backgrounds[x].x_offset_rotation &= 0x00FFFFFF;
                backgrounds[x].x_offset_rotation |= data << 24;
                backgrounds[x].x_offset_rotation &= 0x0FFFFFFF;

                // sign extension. bit 27 is the sign bit.
                backgrounds[x].x_offset_rotation |= (((data >> 3) & 1) ? 0xF000_0000 : 0x0000_0000);
                break;
        }
    }

    void write_BGxY(int target_byte, ubyte data, int x) {
        final switch (target_byte) {
            case 0b00:
                backgrounds[x].y_offset_rotation &= 0xFFFFFF00;
                backgrounds[x].y_offset_rotation |= data;
                break;
            case 0b01:
                backgrounds[x].y_offset_rotation &= 0xFFFF00FF;
                backgrounds[x].y_offset_rotation |= data << 8;
                break;
            case 0b10:
                backgrounds[x].y_offset_rotation &= 0xFF00FFFF;
                backgrounds[x].y_offset_rotation |= data << 16;
                break;
            case 0b11:
                backgrounds[x].y_offset_rotation &= 0x00FFFFFF;
                backgrounds[x].y_offset_rotation |= data << 24;
                backgrounds[x].y_offset_rotation &= 0x0FFFFFFF;

                // sign extension. bit 27 is the sign bit.
                backgrounds[x].y_offset_rotation |= (((data >> 3) & 1) ? 0xF000_0000 : 0x0000_0000);
                break;
        }

        reload_background_internal_affine_registers(x);
    }

    void write_BGxPy(int target_byte, ubyte data, int x, AffineParameter y) {
        final switch (target_byte) {
            case 0b0:
                backgrounds[x].p[cast(int) y] &= 0xFF00;
                backgrounds[x].p[cast(int) y] |= data;
                break;
            case 0b1:
                backgrounds[x].p[cast(int) y] &= 0x00FF;
                backgrounds[x].p[cast(int) y] |= data << 8;
                break;
        }


        // writefln("[%04x] %x %x %x", scanline, data, target_byte, y);
    }

    void write_BLDCNT(int target_byte, ubyte data) {
        final switch (target_byte) {
            case 0b0:
                for (int bg = 0; bg < 4; bg++)
                    canvas.bg_target_pixel[Layer.A][bg] = get_nth_bit(data, bg);
                canvas.obj_target_pixel[Layer.A] = get_nth_bit(data, 4);
                canvas.backdrop_target_pixel[Layer.A] = get_nth_bit(data, 5);

                canvas.blending_type = cast(Blending) get_nth_bits(data, 6, 8);

                break;
            case 0b1:
                for (int bg = 0; bg < 4; bg++)
                    canvas.bg_target_pixel[Layer.B][bg] = get_nth_bit(data, bg);
                canvas.obj_target_pixel[Layer.B] = get_nth_bit(data, 4);
                canvas.backdrop_target_pixel[Layer.B] = get_nth_bit(data, 5);

                break;
        }
    }

    // raw blend values will be set directly during writes to BLDALPHA. these differ
    // from the canvas blend value because the canvas blend values cap at 16 while
    // the raw blend values cap at 31. we need to store the raw values so we can
    // return them on reads from BLDALPHA
    uint raw_blend_a;
    uint raw_blend_b;
    void write_BLDALPHA(int target_byte, ubyte data) {
        final switch (target_byte) {
            case 0b0:
                raw_blend_a = get_nth_bits(data, 0, 5);
                canvas.blend_a = min(raw_blend_a, 16);
                break;
            case 0b1:
                raw_blend_b = get_nth_bits(data, 0, 5);
                canvas.blend_b = min(raw_blend_b, 16);
                break;
        }
    }

    void write_BLDY(int target_byte, ubyte data) {
        final switch (target_byte) {
            case 0b0:
                canvas.evy_coeff = get_nth_bits(data, 0, 5);
                if (canvas.evy_coeff > 16) canvas.evy_coeff = 16;
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
                   (backgrounds[3].enabled << 3) |
                   (sprites_enabled        << 4);
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
            ubyte result = 0x00;
            result |= backgrounds[x].priority                  << 0;
            result |= backgrounds[x].character_base_block      << 2;
            result |= backgrounds[x].bgcnt_bits_4_and_5        << 4;
            result |= backgrounds[x].is_mosaic                 << 6;
            result |= backgrounds[x].doesnt_use_color_palettes << 7;
            return result;

        } else { // target_byte == 1
            // i think this method of handling register reads is cleaner than the cast(ubyte)
            // one-line method. but i dont want to change all mmio registers. maybe a task
            // for the future?
            ubyte result = 0x00;
            result |= backgrounds[x].screen_base_block          << 0;
            result |= backgrounds[x].screen_size                << 6;

            // this bit is only used in bg 2/3
            if (x == 2 || x == 3) result |= backgrounds[x].does_display_area_overflow << 5;
            return result;
        }
    }

    ubyte read_BLDCNT(int target_byte) {
        final switch (target_byte) {
            case 0b0:
                ubyte return_value;
                for (int bg = 0; bg < 4; bg++)
                    return_value |= (canvas.bg_target_pixel[Layer.A][bg] << bg);
                return_value |= canvas.obj_target_pixel[Layer.A] << 4;
                return_value |= (canvas.backdrop_target_pixel[Layer.A] << 5);
                return_value |= (cast(ubyte) canvas.blending_type) << 6;

                return return_value;

            case 0b1:
                ubyte return_value;
                for (int bg = 0; bg < 4; bg++)
                    return_value |= (canvas.bg_target_pixel[Layer.B][bg] << bg);
                return_value |= (canvas.obj_target_pixel[Layer.B] << 4);
                return_value |= (canvas.backdrop_target_pixel[Layer.B] << 5);

                return return_value;
        }
    }

    ubyte read_BLDALPHA(int target_byte) {
        final switch (target_byte) {
            case 0b0:
                return cast(ubyte) raw_blend_a;
            case 0b1:
                return cast(ubyte) raw_blend_b;
        }
    }

    ubyte read_WININ(int target_byte) {
        // target_byte here is conveniently the window index
        return cast(ubyte) ((canvas.windows[target_byte].bg_enable) |
                            (canvas.windows[target_byte].obj_enable << 4) |
                            (canvas.windows[target_byte].blended    << 5));
    }

    ubyte read_WINOUT(int target_byte) {
        final switch (target_byte) {
            case 0b0:
                return cast(ubyte) ((canvas.outside_window_bg_enable) |
                                    (canvas.outside_window_obj_enable << 4) |
                                    (canvas.outside_window_blended    << 5));
            case 0b1:
                return cast(ubyte) ((canvas.obj_window_bg_enable) |
                                    (canvas.obj_window_obj_enable << 4) |
                                    (canvas.obj_window_blended    << 5));
        }
    }
}