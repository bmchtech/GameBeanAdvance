module ppu.pixel;

struct Pixel {
    uint r;
    uint g;
    uint b;
    uint priority;
    bool transparent;
}

Pixel get_pixel_from_color(ushort color, uint priority, bool transparent) {
    return Pixel((color >>  0) & 0x1F, 
                 (color >>  5) & 0x1F, 
                 (color >> 10) & 0x1F,
                 priority, transparent);
}