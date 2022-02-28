module ui.device.frontend.gbavideo;

import re;
import re.math;

class GbaVideo : Component, Updatable, Renderable2D {
    int screen_scale;
    enum gba_height = 160;
    enum gba_width = 240;

    this(int screen_scale = 1) {
        this.screen_scale = screen_scale;
    }

    override void setup() {

    }

    void update() {

    }

    void render() {
        // TODO: ill help u set up a framebuffer here
    }

    void debug_render() {
        // leave this blank
    }

    @property Rectangle bounds() {
        // if we're not using culling who cares
        // problem solved lol
        return Rectangle(0, 0, 1920, 1080);
    }
}
