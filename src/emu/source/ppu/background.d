module ppu.background;

import memory;
import ppu;

struct Background {
    // all backgrounds have the following:
    int   priority;                   // 0 - 3
    int   character_base_block;       // 0 - 3 (units of 16 KBytes)
    bool  is_mosaic;
    bool  doesnt_use_color_palettes;  // 0 = 16/16, 1 = 256/1
    int   screen_base_block;          // 0 - 31 (units of 2 KBytes)
    bool  does_display_area_overflow;
    int   screen_size;                // 0 - 3

    ushort x_offset;
    ushort y_offset;
    bool   enabled;

    // only backgrounds 2 and 3 have the following:
    ushort transformation_dx;
    ushort transformation_dmx;
    ushort transformation_dy;
    ushort transformation_dmy;
    uint   reference_x;
    uint   reference_y;

    FixedPoint x_offset_rotation;
    FixedPoint y_offset_rotation; 

    BackgroundMode mode;

    Layer layer;
}

enum BackgroundMode {
    TEXT,
    ROTATION_SCALING
}

static Background[] backgrounds = [
        Background(),
        Background(),
        Background(),
        Background()
    ];