module ui.reng.gbavideo;

import re;
import re.math;
import re.gfx;

import std.format;
import std.string;

import raylib;

enum SCREEN_SEPARATION_HEIGHT = 0;

class GBAVideo : Component, Updatable, Renderable2D {
    int screen_scale;

    RenderTarget render_target_top;

    uint[240 * 160] videobuffer;

    this(int screen_scale) {
        this.screen_scale = screen_scale;

        render_target_top = RenderExt.create_render_target(
            240,
            160
        );
    }

    override void setup() {

    }

    void update() {

    }

    void update_icon(uint[32 * 32] icon_bitmap) {

    }
    
    void update_title(string title) {
        SetWindowTitle(toStringz(title));
    }

    void render() {
        UpdateTexture(render_target_top.texture, cast(const void*) videobuffer);

        raylib.DrawTexturePro(
            render_target_top.texture,
            Rectangle(0, 0, 256, 192),
            Rectangle(0, 0, 256 * screen_scale, 192 * screen_scale),
            Vector2(0, 0),
            0,
            Colors.WHITE
        );
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