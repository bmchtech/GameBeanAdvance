module hw.ppu.pixel;

struct Pixel {
    uint r;
    uint g;
    uint b;
}

Pixel get_pixel_from_color(ushort color) {
    return Pixel((color >>  0) & 0x1F, 
                 (color >>  5) & 0x1F, 
                 (color >> 10) & 0x1F);
}