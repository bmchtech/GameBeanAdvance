import memory;
class PPU {
    // General information:
    // - Contains 227 scanlines, 160+ is VBLANK. VBLANK is not set on scanline 227.
    // - HBLANK is constantly toggled
    // - Although the drawing time is only 960 cycles (240*4), the H-Blank flag is "0" for a total of 1006 cycles.

public:
    PPU(Memory * memory) void cycle() {

    }

private:
    Memory* memory;
    ushort dot; // the horizontal counterpart to scanlines.

    void render_background_mode0(uint16_t bgcnt, uint16_t bghofs, uint16_t bgvofs) {

    }
}
