module hw.ppu.canvas;

import hw.ppu;
import hw.memory;

import util;

import std.stdio;
import std.algorithm;

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

struct PixelData {
    bool   transparent;
    ushort index;
    uint   priority;
}

enum WindowType {
    ZERO    = 0,
    ONE     = 1,
    OBJ     = 2,
    OUTSIDE = 3,
    NONE    = 4
}

enum Layer {
    A = 0,
    B = 1
}

enum Blending {
    NONE = 0,
    ALPHA = 1,
    BRIGHTNESS_INCREASE = 2,
    BRIGHTNESS_DECREASE = 3
}

struct Window {
    int left;
    int right;
    int top;
    int bottom;

    bool enabled;
    bool blended;

    // bg_enable is 4 bits
    int  bg_enable;
    bool obj_enable;
}

class Canvas {
    
    public:
        PixelData[SCREEN_WIDTH][4] bg_scanline;
        PixelData[SCREEN_WIDTH]    obj_scanline;
        Pixel    [SCREEN_WIDTH]    pixels_output;

        // fields for windowing
        Window[2] windows;
        int outside_window_bg_enable;
        bool outside_window_obj_enable;

        bool[SCREEN_WIDTH] obj_window;
        int  obj_window_bg_enable;
        bool obj_window_obj_enable;
        bool obj_window_enable;

        // fields for blending
        Blending blending_type;
        uint evy_coeff;
        uint blend_a;
        uint blend_b;

        bool obj_window_blended;
        bool outside_window_blended;

        bool[SCREEN_WIDTH] obj_semitransparent;

        // accessed as bg_target_pixel[layer][bg_id]. tells you if
        // the bg is a target pixel on that layer
        bool[4][2] bg_target_pixel;

        // these are the same as bg_target_pixel, just without the need for a bg_id
        bool[2]    obj_target_pixel;
        bool[2]    backdrop_target_pixel;

    private:
        PPU ppu;
        Background[4] sorted_backgrounds;

    public this(PPU ppu) {
        this.ppu = ppu;

        this.bg_scanline   = new PixelData[SCREEN_WIDTH][4];
        this.obj_scanline  = new PixelData[SCREEN_WIDTH];
        this.pixels_output = new Pixel    [SCREEN_WIDTH];

        reset();
    }

    public void reset() {
        for (int x = 0; x < SCREEN_WIDTH; x++) {
            for (int bg = 0; bg < 4; bg++) {
                bg_scanline[bg][x].transparent = true;
            }

            obj_scanline       [x].transparent = true;
            obj_scanline       [x].priority    = 4;
            obj_window         [x]             = false;
            obj_semitransparent[x]             = false;
        }
    }

    public pragma(inline, true) void set_obj_window(uint x) {
        if (x >= SCREEN_WIDTH) return;
        obj_window[x] = true;
    }

    public pragma(inline, true) void draw_bg_pixel(uint x, int bg, ushort index, int priority, bool transparent) {
        if (x >= SCREEN_WIDTH) return;

        bg_scanline[bg][x].transparent = transparent;
        bg_scanline[bg][x].index       = index;
        bg_scanline[bg][x].priority    = priority;
    }

    public pragma(inline, true) void draw_obj_pixel(uint x, ushort index, int priority, bool transparent, bool semi_transparent) {
        if (x >= SCREEN_WIDTH) return;
        
        // obj rendeWindowTypering on the gba has a weird bug where if there are two overlapping obj pixels
        // that have differing priorities as specified in oam, and the one with lower priority is
        // nontransparent while the one with higher priority is transparent, the pixel with lower
        // priority is overwritten anyway. which is why we don't care if this obj pixel is transparent
        // or not, we just care about its priority

        if (obj_scanline[x].transparent ||
            priority < obj_scanline[x].priority) {
            obj_scanline[x].transparent = transparent;
            obj_scanline[x].index       = index;
            obj_scanline[x].priority    = priority;
            obj_semitransparent[x]      = semi_transparent;
        }
    }

    public void apply_horizontal_mosaic(int bg_mosaic, int obj_mosaic) {
        int mosaic_counter = 1;
        int mosaic_x       = 0;

        // mosaic is not applied often at all. lets check if its even applied in this scanline
        if (bg_mosaic != 1) {
            for (int x = 0; x < 240; x++) {
                mosaic_counter--;

                if (mosaic_counter == 0) {
                    mosaic_counter = bg_mosaic;
                    mosaic_x = x;
                }

                for (int bg = 0; bg < 4; bg++) {
                    if (backgrounds[bg].is_mosaic) bg_scanline[bg][x] = bg_scanline[bg][mosaic_x];
                }
            }
        } 

        mosaic_counter = 1;
        mosaic_x       = 0;

        if (obj_mosaic != 1) {
            for (int x = 0; x < 240; x++) {
                mosaic_counter--;

                if (mosaic_counter == 0) {
                    mosaic_counter = obj_mosaic;
                    mosaic_x = x;
                }

                obj_scanline[x] = obj_scanline[mosaic_x];
            }
        }
    }

    public void composite() {
        // step 1: sort the backgrounds by priority
        sorted_backgrounds = backgrounds;

        // insertion sort
        // the important part of insertion sort is that we need two backgrounds of the same priority
        // to be *also* sorted by index. i.e. if bg0 and bg1 had the same priorities, bg0 must appear
        // in sorted_backgrounds before bg1. insertion sort guarantees this.

        // https://www.geeksforgeeks.org/insertion-sort/
        for (int i = 1; i < 4; i++) {
            Background temp = sorted_backgrounds[i];
            int key = temp.priority;
            int j = i - 1;

            while (j >= 0 && sorted_backgrounds[j].priority > key) {
                sorted_backgrounds[j + 1] = sorted_backgrounds[j];
                j--;
            }
            sorted_backgrounds[j + 1] = temp;
        }


        // step 2: loop through the backgrounds, and get the first non transparent pixel
        WindowType default_window_type = (obj_window_enable || windows[0].enabled || windows[1].enabled) ? WindowType.OUTSIDE : WindowType.NONE;

        for (int x = 0; x < SCREEN_WIDTH; x++) {
            // which window are we in?
            WindowType current_window_type = default_window_type;
            if (obj_window[x]) current_window_type = WindowType.OBJ;

            for (int i = 0; i < 2; i++) {
                if (windows[i].enabled) {
                    if (windows[i].left <= x            && x            < windows[i].right  && 
                        windows[i].top  <= ppu.scanline && ppu.scanline < windows[i].bottom) {
                        current_window_type = cast(WindowType) i;
                        break;
                    }
                }
            }

            // now that we know which window type we're in, let's calculate the color index for this pixel

            int[2] index    = [0, 0]; // 0 is the backdrop index
            int    priority = 4;

            int blendable_pixels = 0;
            int total_pixels     = 0;
            bool processed_obj   = false;

            // i hate it here
            int current_bg_id;
            for (int i = 0; i < 4; i++) {
                if (total_pixels == 2) break;

                if (!processed_obj && !obj_scanline[x].transparent && is_obj_pixel_visible(current_window_type) &&
                        sorted_backgrounds[i].priority >= obj_scanline[x].priority) {
                    index[total_pixels] = obj_scanline[x].index;

                    if (obj_target_pixel[total_pixels] || obj_semitransparent[x]) {
                        blendable_pixels++;
                        total_pixels++;
                        continue;
                    }
                    total_pixels++;

                    processed_obj = true;
                }

                if (total_pixels == 2) break;

                current_bg_id = sorted_backgrounds[i].id;
                if (!bg_scanline[current_bg_id][x].transparent) {
                    if (is_bg_pixel_visible(current_bg_id, current_window_type)) {
                        index[total_pixels] = bg_scanline[current_bg_id][x].index;
                        priority = sorted_backgrounds[i].priority;

                        if (bg_target_pixel[total_pixels][current_bg_id]) {
                            blendable_pixels++;
                            total_pixels++;
                            continue;
                        }
                        total_pixels++;
                        break; 
                    }
                }

                if (total_pixels == 2) break;
            }

            if (total_pixels < 2 && !processed_obj && !obj_scanline[x].transparent && is_obj_pixel_visible(current_window_type)) {
                index[total_pixels] = obj_scanline[x].index;

                if (obj_target_pixel[total_pixels] || obj_semitransparent[x]) {
                    blendable_pixels++;
                }
                total_pixels++;
            }
            
            Blending effective_blending_type = is_blended(current_window_type) ? blending_type : Blending.NONE;

            // now to blend the two values together
            pixels_output[x] = blend(index, blendable_pixels, effective_blending_type);
        }
    }

    // blends the two colors together based on blending type
    private pragma(inline, true) Pixel blend(int[] index, int blendable_pixels, Blending effective_blending_type) {
        final switch (effective_blending_type) {
            case Blending.NONE:
                return hw.ppu.palette.get_color(index[0]);

            case Blending.BRIGHTNESS_INCREASE:
                if (blendable_pixels < 1) goto case Blending.NONE;

                Pixel output = hw.ppu.palette.get_color(index[0]);

                output.r += cast(ubyte) (((31 - output.r) * evy_coeff) >> 4);
                output.g += cast(ubyte) (((31 - output.g) * evy_coeff) >> 4);
                output.b += cast(ubyte) (((31 - output.b) * evy_coeff) >> 4);
                return output;

            case Blending.BRIGHTNESS_DECREASE:
                if (blendable_pixels < 1) goto case Blending.NONE;

                Pixel output = hw.ppu.palette.get_color(index[0]);

                output.r -= cast(ubyte) (((output.r) * evy_coeff) >> 4);
                output.g -= cast(ubyte) (((output.g) * evy_coeff) >> 4);
                output.b -= cast(ubyte) (((output.b) * evy_coeff) >> 4);
                return output;

            case Blending.ALPHA:
                if (blendable_pixels < 2) goto case Blending.NONE;

                Pixel input_A = hw.ppu.palette.get_color(index[0]);
                Pixel input_B = hw.ppu.palette.get_color(index[1]);
                Pixel output;

                output.r = min(31, (blend_a * input_A.r + blend_b * input_B.r) >> 4);
                output.g = min(31, (blend_a * input_A.g + blend_b * input_B.g) >> 4);
                output.b = min(31, (blend_a * input_A.b + blend_b * input_B.b) >> 4);
                return output;
        }
    }

    private pragma(inline, true) bool is_blended(WindowType window_type) {
        final switch (window_type) {
            case WindowType.ZERO:    return windows[0].blended;
            case WindowType.ONE:     return windows[1].blended;
            case WindowType.OBJ:     return obj_window_blended;
            case WindowType.OUTSIDE: return outside_window_blended;
            case WindowType.NONE:    return true;
        }
    }
    
    // calculates if the bg pixel is visible under the effects of windowing
    private pragma(inline, true) bool is_bg_pixel_visible(int bg_id, WindowType window_type) {
        final switch (window_type) {
            case WindowType.ZERO:    return get_nth_bit(windows[0].bg_enable,     bg_id);
            case WindowType.ONE:     return get_nth_bit(windows[1].bg_enable,     bg_id);
            case WindowType.OBJ:     return get_nth_bit(obj_window_bg_enable,     bg_id);
            case WindowType.OUTSIDE: return get_nth_bit(outside_window_bg_enable, bg_id);
            case WindowType.NONE:    return true;
        }
    }
    
    // calculates if the obj pixel is visible under the effects of windowing
    private pragma(inline, true) bool is_obj_pixel_visible(WindowType window_type) {
        final switch (window_type) {
            case WindowType.ZERO:    return windows[0].obj_enable;
            case WindowType.ONE:     return windows[1].obj_enable;
            case WindowType.OBJ:     return obj_window_obj_enable;
            case WindowType.OUTSIDE: return outside_window_obj_enable;
            case WindowType.NONE:    return true;
        }
    }
}