module ui.device.frontend.gbavideo;

import re;
import re.math;
import re.gfx;

import raylib;

class GbaVideo : Component, Updatable, Renderable2D {
    int screen_scale;
    enum GBA_HEIGHT = 160;
    enum GBA_WIDTH  = 240;

    RenderTarget render_target;

    uint[GBA_HEIGHT * GBA_WIDTH] frame_buffer;

    this(int screen_scale = 1) {
        this.screen_scale = screen_scale;
        render_target = RenderExt.create_render_target(
            GBA_WIDTH,
            GBA_HEIGHT
        );

        for (int x = 0; x < GBA_WIDTH; x++) {
        for (int y = 0; y < GBA_HEIGHT; y++) {
            frame_buffer[x * GBA_HEIGHT+y] = x * 282 + y * 3;
        }
        }
    }

    override void setup() {

    }

    void update() {
        
    }

    void render() {
        // TODO: ill help u set up a framebuffer here
        UpdateTexture(render_target.texture, cast(const void*) frame_buffer);

        // raylib.DrawTexturePro(
        //     render_target.texture,
        //     Rectangle(0, 0, GBA_WIDTH, -GBA_HEIGHT), 
        //     Rectangle(0, 0, GBA_WIDTH * screen_scale, GBA_HEIGHT * screen_scale),
        //     Vector2(0, 0), 
        //     0, 
        //     Colors.WHITE
        // );

        raylib.DrawRectangle(0, 0, 100, 100, Colors.RED);

        import std.stdio;
        writefln("sussy baka");
    }

    void debug_render() {
        // leave this blank
    }

    @property Rectangle bounds() {
        // if we're not using culling who cares
        // problem solved lol
        return Rectangle(0, 0, 1000, 1080);
    }
}
