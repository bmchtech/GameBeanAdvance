module ppu.layer;

import ppu;

import std.stdio;

class Layer {

public:
    Pixel[SCREEN_HEIGHT][SCREEN_WIDTH] pixels;

    SpecialEffectLayer special_effect_layer;

    this() {
        this.pixels       = new Pixel[SCREEN_HEIGHT][SCREEN_WIDTH];
        special_effect_layer = SpecialEffectLayer.None;
    }

    void fill(Pixel pixel) {
        for (int x = 0; x < SCREEN_WIDTH;  x++) {
        for (int y = 0; y < SCREEN_HEIGHT; y++) {
            pixels[x][y] = pixel;
        }
        }
    }

    void fill_and_reset(Pixel pixel) {
        fill(pixel);
    }

    void set_pixel(uint x, uint y, Pixel pixel) {
        if (!(pixel.r == pixels[x][y].r && 
              pixel.g == pixels[x][y].g && 
              pixel.b == pixels[x][y].b)) {
            set_changed_pixel(Point(x, y));
        }

        this.pixels[x][y] = pixel;
    }
}