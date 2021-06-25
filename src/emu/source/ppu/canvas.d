module ppu.canvas;

import ppu;
import util;

import std.stdio;

import core.stdc.string;

// okay so the rules here go like this:
// an empty pixel is invalid. renders the background pixel.
// a single pixel contains one valid pixel in pixels_a. 
// a double pixel contains two valid pixels. a, and b. (blending)

// now here's where things get interesting. a pixel that has been assigned
// as single cannot change its type again until reset() is called. a pixel
// can become a single type if it started off as empty. this is because
// set_pixel() is called in decreasing priority order. so if the first pixel
// it sees is a single pixel, then that's the one it goes with. additionally,
// a pixel can become a single type if it started off as a double_a, and 
// set_pixel is then called with type single. then, the pixel type is changed
// to single without changing the value of pixels_a itself. this is because
// if we see this ordering, then layer b isn't visible in that pixel, and so
// blending should not occur. 

// now for more details about blending (aka double pixels). if a pixel is empty,
// and is assigned type double_a, then it is set to double_a. if a pixel
// is double_a and a layer b pixel comes in, then we set the pixel type to
// DOUBLE_AB.

enum PixelType {
    EMPTY     = 0b000,
    SINGLE    = 0b001,

    DOUBLE_A  = 0b101,
    DOUBLE_AB = 0b111
}

enum Layer {
    BACKDROP  = 0b00000,
    A         = 0b01000,
    B         = 0b10000,
    NONE      = 0b11000
}

class Canvas {

public:
    Pixel    [SCREEN_HEIGHT][SCREEN_WIDTH] pixels_a;
    Pixel    [SCREEN_HEIGHT][SCREEN_WIDTH] pixels_b;
    PixelType[SCREEN_HEIGHT][SCREEN_WIDTH] pixel_types;

    Pixel    [SCREEN_HEIGHT][SCREEN_WIDTH] pixels_output;

    this() {
        this.pixels_a      = new Pixel[SCREEN_HEIGHT][SCREEN_WIDTH];
        this.pixels_b      = new Pixel[SCREEN_HEIGHT][SCREEN_WIDTH];
        this.pixels_output = new Pixel[SCREEN_HEIGHT][SCREEN_WIDTH];

        reset();
    }

    void reset() {
        memset(&pixel_types, PixelType.EMPTY, SCREEN_HEIGHT * SCREEN_WIDTH * PixelType.sizeof);
    }


    void set_pixel(uint x, uint y, Pixel pixel, Layer layer) {
        switch (layer | pixel_types[x][y]) {
            case Layer.NONE     | PixelType.EMPTY:
                pixel_types[x][y] = PixelType.SINGLE;
                pixels_a   [x][y] = pixel;
                break;

            case Layer.A        | PixelType.EMPTY: 
                pixel_types[x][y] = PixelType.DOUBLE_A;
                pixels_a   [x][y] = pixel;
                break;
            
            case Layer.B        | PixelType.EMPTY:
                pixel_types[x][y] = PixelType.SINGLE;
                pixels_a   [x][y] = pixel;
                break;
            
            case Layer.BACKDROP | PixelType.EMPTY:
                pixel_types[x][y] = PixelType.SINGLE;
                pixels_a   [x][y] = pixel;
                break;

            case Layer.NONE | PixelType.DOUBLE_A:
                pixel_types[x][y] = PixelType.SINGLE;
                break;
            
            case Layer.B    | PixelType.DOUBLE_A:
                pixel_types[x][y] = PixelType.DOUBLE_AB;
                pixels_b   [x][y] = pixel;
                break;

            default: break;
        }
    }

    void consolidate(uint blend_a, uint blend_b) {
        for (int x = 0; x < SCREEN_WIDTH;  x++) {
        for (int y = 0; y < SCREEN_HEIGHT; y++) {
            final switch (pixel_types[x][y]) {
                case PixelType.EMPTY:
                    break;
                case PixelType.SINGLE:
                    pixels_output[x][y] = pixels_a[x][y]; break;
                case PixelType.DOUBLE_A:
                    pixels_output[x][y] = pixels_a[x][y]; break;
                case PixelType.DOUBLE_AB:
                    pixels_output[x][y].r = (blend_a * pixels_a[x][y].r + blend_b * pixels_b[x][y].r) >> 6;
                    pixels_output[x][y].g = (blend_a * pixels_a[x][y].g + blend_b * pixels_b[x][y].g) >> 6;
                    pixels_output[x][y].b = (blend_a * pixels_a[x][y].b + blend_b * pixels_b[x][y].b) >> 6;
            }
        }
        }
    }
}