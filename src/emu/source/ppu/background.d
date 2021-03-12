module background;

import memory;

struct Background {
    // all backgrounds have the following:
    ushort* control;
    ushort* x_offset;
    ushort* y_offset;

    // NOTE: This bit does not say whether or not the background is enabled!
    // this bit tells us which bit inside memory.DISPCNT tells us whether the
    // background is enabled or not. so, get_nth_bit(memory.DISPCNT, enabled_bit)
    // is the proper way to check if the background is enabled.
    ubyte enabled_bit;

    // only backgrounds 2 and 3 have the following:
    ushort* transformation_dx;
    ushort* transformation_dmx;
    ushort* transformation_dy;
    ushort* transformation_dmy;
    uint*   reference_x;
    uint*   reference_y;

}

static Background background_0;
static Background background_1;
static Background background_2;
static Background background_3;

void background_init(Memory memory) {
    background_0 = Background(
        memory.BG0CNT,
        memory.BG0HOFS,
        memory.BG0VOFS,
        8,

        null, null, null, null, null, null
    );
    
    background_1 = Background(
        memory.BG1CNT,
        memory.BG1HOFS,
        memory.BG1VOFS,
        9,

        null, null, null, null, null, null
    );

    background_2 = Background(
        memory.BG2CNT,
        memory.BG2HOFS,
        memory.BG2VOFS,
        10,

        memory.BG2PA,
        memory.BG2PB,
        memory.BG2PC,
        memory.BG2PD,
        memory.BG2X,
        memory.BG2Y
    );

    background_3 = Background(
        memory.BG3CNT,
        memory.BG3HOFS,
        memory.BG3VOFS,
        11,

        memory.BG3PA,
        memory.BG3PB,
        memory.BG3PC,
        memory.BG3PD,
        memory.BG3X,
        memory.BG3Y
    );
}