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

    this(int screen_scale) {
        this.screen_scale = screen_scale;
        render_target = RenderExt.create_render_target(
            GBA_WIDTH,
            GBA_HEIGHT
        );
    }

    override void setup() {

    }

    void update() {

    }

    void render() {
        UpdateTexture(render_target.texture, cast(const void*) frame_buffer);

        raylib.DrawTexturePro(
            render_target.texture,
            Rectangle(0, 0, GBA_WIDTH, GBA_HEIGHT),
            Rectangle(0, 0, GBA_WIDTH * screen_scale, GBA_HEIGHT * screen_scale),
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
