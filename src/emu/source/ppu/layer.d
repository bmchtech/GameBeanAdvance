module ppu.layer;

import ppu;

import std.stdio;

import core.stdc.string;

class Layer {

public:
    Pixel[SCREEN_HEIGHT][SCREEN_WIDTH] pixels;

    SpecialEffectLayer special_effect_layer;

    this() {
        this.pixels = new Pixel[SCREEN_HEIGHT][SCREEN_WIDTH];
        special_effect_layer = SpecialEffectLayer.None;
    }

    void reset() {
        memset(&pixels, true, SCREEN_HEIGHT * SCREEN_WIDTH * 20);
        // for (int i = 0; i < SCREEN_WIDTH; i++) {
        //     for (int j = 0; j < SCREEN_HEIGHT; j++) {
        //         pixels[i][j] = Pixel(0xFF, 0xFF, 0xFF, 0xFF, 0);
        //     }
        // }
    }

    void set_pixel(uint x, uint y, Pixel pixel) {
        this.pixels[x][y] = pixel;
    }
}