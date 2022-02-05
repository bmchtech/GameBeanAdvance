module hw.ppu.pixel;

import hw.ppu;

Pixel get_pixel_from_color(ushort color) {
    return Pixel((color >>  0) & 0x1F, 
                 (color >>  5) & 0x1F, 
                 (color >> 10) & 0x1F);
}