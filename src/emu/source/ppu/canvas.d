module ppu.canvas;

import ppu;
import util;
import memory;

import std.stdio;

import core.stdc.string;

// okay so the rules here go like this:
// an empty pixel is invalid. renders the background pixel.
// a single pixel contains one valid pixel in indices_a. 
// a double pixel contains two valid pixels. a, and b. (blending)

// now here's where things get interesting. a pixel that has been assigned
// as single cannot change its type again until reset() is called. a pixel
// can become a single type if it started off as empty. this is because
// set_pixel() is called in decreasing priority order. so if the first pixel
// it sees is a single pixel, then that's the one it goes with. additionally,
// a pixel can become a single type if it started off as a double_a, and 
// set_pixel is then called with type single. then, the pixel type is changed
// to single without changing the value of indices_a itself. this is because
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
    int      [SCREEN_HEIGHT][SCREEN_WIDTH] indices_a;
    int      [SCREEN_HEIGHT][SCREEN_WIDTH] indices_b;
    PixelType[SCREEN_HEIGHT][SCREEN_WIDTH] pixel_types;

    Pixel    [SCREEN_HEIGHT][SCREEN_WIDTH] pixels_output;

    Memory memory;

    this(Memory memory) {
        this.indices_a     = new int  [SCREEN_HEIGHT][SCREEN_WIDTH];
        this.indices_b     = new int  [SCREEN_HEIGHT][SCREEN_WIDTH];
        this.pixels_output = new Pixel[SCREEN_HEIGHT][SCREEN_WIDTH];
        this.memory        = memory;

        reset();
    }

    void reset() {
        memset(&pixel_types, PixelType.EMPTY, SCREEN_HEIGHT * SCREEN_WIDTH * PixelType.sizeof);
    }


    void draw(uint x, uint y, int index, Layer layer) {
        switch (layer | pixel_types[x][y]) {
            case Layer.NONE     | PixelType.EMPTY:
                pixel_types[x][y] = PixelType.SINGLE;
                indices_a   [x][y] = index;
                break;

            case Layer.A        | PixelType.EMPTY: 
                pixel_types[x][y] = PixelType.DOUBLE_A;
                indices_a   [x][y] = index;
                break;
            
            case Layer.B        | PixelType.EMPTY:
                pixel_types[x][y] = PixelType.SINGLE;
                indices_a   [x][y] = index;
                break;
            
            case Layer.BACKDROP | PixelType.EMPTY:
                pixel_types[x][y] = PixelType.SINGLE;
                indices_a   [x][y] = index;
                break;

            case Layer.NONE | PixelType.DOUBLE_A:
                pixel_types[x][y] = PixelType.SINGLE;
                break;
            
            case Layer.B    | PixelType.DOUBLE_A:
                pixel_types[x][y] = PixelType.DOUBLE_AB;
                indices_b   [x][y] = index;
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
                    pixels_output[x][y] = index_to_pixel(indices_a[x][y]); break;
                case PixelType.DOUBLE_A:
                    pixels_output[x][y] = index_to_pixel(indices_a[x][y]); break;
                case PixelType.DOUBLE_AB: {
                    Pixel a = index_to_pixel(indices_a[x][y]);
                    Pixel b = index_to_pixel(indices_b[x][y]);

                    pixels_output[x][y].r = (blend_a * a.r + blend_b * b.r) >> 6;
                    pixels_output[x][y].g = (blend_a * a.g + blend_b * b.g) >> 6;
                    pixels_output[x][y].b = (blend_a * a.b + blend_b * b.b) >> 6;
                }
            }
        }
        }
    }

    Pixel index_to_pixel(uint index) {
        return get_pixel_from_color(memory.read_halfword(index));
    }
}
