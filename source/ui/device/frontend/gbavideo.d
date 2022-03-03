module ui.device.frontend.gbavideo;

import re;
import re.math;
import re.gfx;

import raylib;

class GbaVideo : Component, Updatable, Renderable2D {
    int screen_scale;
    enum GBA_HEIGHT = 160;
    enum GBA_WIDTH = 240;

    RenderTarget render_target;
    Texture2D rp1_texture;

    uint[GBA_HEIGHT * GBA_WIDTH] frame_buffer;

    this(int screen_scale = 1) {
        this.screen_scale = screen_scale;
        render_target = RenderExt.create_render_target(
            GBA_WIDTH,
            GBA_HEIGHT
        );
        auto im = raylib.GenImageColor(GBA_WIDTH, GBA_HEIGHT, Colors.BLUE);
        rp1_texture = raylib.LoadTextureFromImage(im);
        raylib.UnloadImage(im);

        for (int x = 0; x < GBA_WIDTH; x++) {
            for (int y = 0; y < GBA_HEIGHT; y++) {
                // frame_buffer[x * GBA_HEIGHT + y] = x * 282 + y * 3;
                // frame_buffer[x * GBA_HEIGHT + y] = 0x000000ff | (x * 282 << 8) | (y * 3 << 16);
                // frame_buffer[x * GBA_HEIGHT + y] = Color(cast(ubyte) x, cast(ubyte) y, cast(ubyte) 255, cast(
                // ubyte) 255);
                // set RGBA Color buffer
                frame_buffer[x * GBA_HEIGHT + y] = (x << 0) | (y << 8) | (255 << 16) | (255 << 24);
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

        raylib.DrawTexturePro(
            render_target.texture,
            Rectangle(0, 0, GBA_WIDTH, -GBA_HEIGHT),
            Rectangle(0, 0, GBA_WIDTH * screen_scale, GBA_HEIGHT * screen_scale),
            Vector2(0, 0),
            0,
            Colors.WHITE
        );

        // raylib.DrawTexturePro(
        //     rp1_texture,
        //     Rectangle(0, 0, GBA_WIDTH, -GBA_HEIGHT), 
        //     Rectangle(0, 0, GBA_WIDTH * screen_scale, GBA_HEIGHT * screen_scale),
        //     Vector2(0, 0), 
        //     0, 
        //     Colors.WHITE
        // );

        raylib.DrawRectangle(0, 0, 10, 10, Colors.RED);

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
