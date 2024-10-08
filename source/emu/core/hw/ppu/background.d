module hw.ppu.background;

import hw.ppu;

struct Background {
    int   id;
    int   priority;                   // 0 - 3
    int   character_base_block;       // 0 - 3 (units of 16 KBytes)
    bool  is_mosaic;
    bool  doesnt_use_color_palettes;  // 0 = 16/16, 1 = 256/1
    int   screen_base_block;          // 0 - 31 (units of 2 KBytes)
    bool  does_display_area_overflow;
    int   screen_size;                // 0 - 3

    // these aren't used (except in NDS mode, according to GBATek)
    // yet, the GBA still saves their value and returns them. therefore
    // my emulator must do so too.
    uint  bgcnt_bits_4_and_5;

    ushort x_offset;
    ushort y_offset;
    bool   enabled;

    ushort transformation_dx;
    ushort transformation_dmx;
    ushort transformation_dy;
    ushort transformation_dmy;
    uint   reference_x;
    uint   reference_y;

    int x_offset_rotation;
    int y_offset_rotation; 

    long internal_reference_x;
    long internal_reference_y;

    BackgroundMode mode;

    Layer layer;
    
    short[4] p;
}

enum BackgroundMode {
    TEXT,
    ROTATION_SCALING,
    NONE
}

static __gshared Background[] backgrounds = [
    Background(),
    Background(),
    Background(),
    Background()
];


// the backgrounds may get sorted by priority at some point
static this() {
    for (int i = 0; i < 4; i++) {
        backgrounds[i].id = i;
        backgrounds[i].p[0] = 0x100; 
        backgrounds[i].p[3] = 0x100; 
    }
}