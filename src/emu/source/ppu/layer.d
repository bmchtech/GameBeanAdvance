module ppu.layer;

import ppu;

import std.stdio;

class Layer {

public:
    Pixel[SCREEN_HEIGHT][SCREEN_WIDTH] pixels;

    SpecialEffectLayer special_effect_layer;

    this() {
        this.pixels = new Pixel[SCREEN_HEIGHT][SCREEN_WIDTH];
        special_effect_layer = SpecialEffectLayer.None;
    }

    void fill(Pixel pixel) {
        for (int x = 0; x < SCREEN_WIDTH;  x++) {
        for (int y = 0; y < SCREEN_HEIGHT; y++) {
            pixels[x][y] = pixel;
        }
        }
    }
}