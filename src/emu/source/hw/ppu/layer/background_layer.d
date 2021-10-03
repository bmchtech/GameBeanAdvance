module hw.ppu.layer.background_layer;

// import ppu;
// import memory;
// import util;

// import std.stdio;

// class BackgroundLayer : Layer {
//     public int background_id;

//     // the pos at which we will draw at
//     DrawPos draw_pos;

//     // this will be added to the draw_pos to get the actual pos we will draw at.
//     Point draw_delta;

//     // the point on the background where we'll get the pixel which we should draw
//     Point texture_point;

//     // the coordinates of the tile in tile-space that we are rendering.
//     Point tile_point;

//     int screen_base_address;
//     int tile_base_address;

//     this(Memory memory, int background_id) {
//         super(memory);
//         this.background_id = background_id;
//         draw_pos.full_pos = 0;
//     }
    
//     static int[][] BG_TEXT_SCREENS_DIMENSIONS = [
//         [1, 1],
//         [1, 2],
//         [2, 1],
//         [2, 2]
//     ];

//     int get_tile_address__text(int tile_x, int tile_y, int screens_per_row) {
//         // each screen is 32 x 32 tiles. so to get the tile offset within its screen
//         // we can get the low 5 bits
//         int tile_x_within_screen = tile_x & 0x1F;
//         int tile_y_within_screen = tile_y & 0x1F;

//         // similarly we can find out which screen this tile is located in
//         // by getting its high bit
//         int screen_x             = (tile_x >> 5) & 1;
//         int screen_y             = (tile_y >> 5) & 1;
//         int screen               = screen_x + screen_y * screens_per_row;

//         int tile_address_offset_within_screen = ((tile_y_within_screen * 32) + tile_x_within_screen) * 2;
//         return tile_address_offset_within_screen + screen * 0x800; 
//     }

//     override Pixel calculate_row() {
//         if (!backgrounds[background_id].enabled) return Pixel(0, 0, 0, true);

//         // are we rendering the first pixel in a scanline? cache these values. they won't change much.
//         if (draw_pos.pos.x == 0) {
//             screen_base_address = memory.OFFSET_VRAM + backgrounds[background_id].screen_base_block    * 0x800;
//             tile_base_address   = memory.OFFSET_VRAM + backgrounds[background_id].character_base_block * 0x4000;
//             texture_point.x     = backgrounds[background_id].x_offset + 0;
//             texture_point.y     = backgrounds[background_id].y_offset + draw_pos.pos.y;
//         }

//         Point draw_delta = Point(texture_point.x & 0b111, 
//                                  texture_point.y & 0b111);
//         Point tile_point = Point(texture_point.x >> 3, 
//                                  texture_point.y >> 3);

//         int tile_address = get_tile_address__text(tile_point.x, tile_point.y, BG_TEXT_SCREENS_DIMENSIONS[backgrounds[background_id].screen_size][0]);
//         int tile = memory.read_halfword(screen_base_address + tile_address);

//         ubyte index = 0;
//         if (backgrounds[background_id].doesnt_use_color_palettes) {
//             // writefln("Reading from %x %x", tile_base_address, ((tile & 0x3ff) * 64) + draw_delta.y * 8 + draw_delta.x);
//             index = memory.read_byte(tile_base_address + ((tile & 0x3ff) * 64) + draw_delta.y * 8 + draw_delta.x);
//         } else {
//             index = memory.read_byte(tile_base_address + ((tile & 0x3ff) * 32) + draw_delta.y * 4 + (draw_delta.x / 2));

//             index = (draw_delta.x % 2 == 0) ? index & 0xF : index >> 4;

//             immutable int palette = get_nth_bits(tile, 12, 16);
//             index += palette * 16;
//         }
        
//         texture_point.x++;
//         draw_pos.full_pos++;
        
//         if (index == 0) return Pixel(0, 0, 0, true);
//         return get_pixel_from_color(memory.read_halfword(memory.OFFSET_PALETTE_RAM + index * 2), false);

//         // for (int tile_x_offset = 0; tile_x_offset < 32 + 1; tile_x_offset++) {

//         //     // get the tile address and read it from memory
//         //     int tile_address = get_tile_address__text(topleft_tile_x + tile_x_offset, topleft_tile_y, BG_TEXT_SCREENS_DIMENSIONS[background.screen_size][0]);
//         //     int tile = memory.read_halfword(screen_base_address + tile_address);

//         //     int draw_x = tile_x_offset * 8 - tile_dx;
//         //     int draw_y = scanline;

//         //     bool flipped_x = (tile >> 10) & 1;
//         //     bool flipped_y = (tile >> 11) & 1;
            
//         //     for (int tile_x = 0; tile_x < 8; tile_x++) {
//         //         int draw_x = left_x + tile_x;
//         //         int draw_y = scanline;

//         //         int x = left_x - tile_x;

//         //         int tile_dx = flipped_x ? (7 - tile_x) : tile_x;
//         //         int tile_dy = flipped_y ? (7 - y)      : y;
                

//         //         static if (bpp8) {
//         //             ubyte index = memory.read_byte(tile_base_address + ((tile & 0x3ff) * 64) + tile_dy * 8 + tile_dx);
                
//         //             return index_to_pixel(index);
//         //         } else {
//         //             ubyte index = memory.read_byte(tile_base_address + ((tile & 0x3ff) * 32) + tile_dy * 4 + (tile_dx / 2));

//         //             index = (tile_dx % 2 == 0) ? index & 0xF : index >> 4;
//         //             index += palette * 16;
//         //             return index_to_pixel(index);
//         //         }
//         //     }
//         //     // yes this looks stupid. and it is.
//         //     if (background.doesnt_use_color_palettes) {
//         //         Render!(true).tile(
//         //                 Layer.A, tile, tile_base_address, 0, 
//         //                 draw_x, tile_dy, 
//         //                 0, 0, PMatrix(0, 0, 0, 0), false,
//         //                 flipped_x, flipped_y, 
//         //                 get_nth_bits(tile, 12, 16));
//         //     } else {
//         //         Render!(false).tile(
//         //                 Layer.A, tile, tile_base_address, 0, 
//         //                 draw_x, tile_dy, 
//         //                 0, 0, PMatrix(0, 0, 0, 0), false,
//         //                 flipped_x, flipped_y, 
//         //                 get_nth_bits(tile, 12, 16));
//         //     }
//         // }

//     }

//     // void tile(Layer layer, int tile, int tile_base_address, int palette_base_address, int left_x, int y, ref_x, ref_y, PMatrix p_matrix, bool scaled, bool flipped_x, bool flipped_y, int palette) {
             
//     //     }

//     override void on_vblank() {
//         draw_pos.full_pos = 0;
//     }

//     override void skip_pixel() {
//         if (draw_pos.pos.x == 0) {
//             screen_base_address = memory.OFFSET_VRAM + backgrounds[background_id].screen_base_block    * 0x800;
//             tile_base_address   = memory.OFFSET_VRAM + backgrounds[background_id].character_base_block * 0x4000;
//             texture_point.x     = backgrounds[background_id].x_offset + 0;
//             texture_point.y     = backgrounds[background_id].y_offset + draw_pos.pos.y;
//         }
        
//         texture_point.x++;
//         draw_pos.full_pos++;
//     }
// }