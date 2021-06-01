module ppu.delta_optimization;

import ppu;

import std.stdio;

private bool[SCREEN_HEIGHT][SCREEN_WIDTH] changed_pixels = new bool[SCREEN_HEIGHT][SCREEN_WIDTH];

void set_changed_pixel(Point p) {
    changed_pixels[p.x][p.y] = true;
}

Point[] get_changed_pixels() {
    Point[] return_value;

    for (int x = 0; x < SCREEN_WIDTH;  x++) {
    for (int y = 0; y < SCREEN_HEIGHT; y++) {
        if (changed_pixels[x][y]) return_value ~= Point(x, y);
    }
    }

    return return_value;
}

void reset_changed_pixels() {
    for (int x = 0; x < SCREEN_WIDTH;  x++) {
    for (int y = 0; y < SCREEN_HEIGHT; y++) {
        changed_pixels[x][y] = false;
    }
    }
}