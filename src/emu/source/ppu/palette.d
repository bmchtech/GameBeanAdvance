module ppu.palette;

import ppu;

import std.stdio;

Pixel[] color_palette = new Pixel[0x200];

pragma(inline, true) void set_color(int index, ushort value) {
    color_palette[index] = get_pixel_from_color(value);
}

pragma(inline, true) Pixel get_color(int index) {
    return color_palette[index];
}