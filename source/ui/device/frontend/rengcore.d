module ui.device.frontend.rengcore;

import re;
import re.math;

import ui.device.device;
import ui.device.frontend.emuscene;

class RengCore : Core {
    int width;
    int height;

    this(int screen_scale) {
        this.width  = SCREEN_WIDTH  * screen_scale;
        this.height = SCREEN_HEIGHT * screen_scale;

        super(width, height, "GameBean Advance");
    }

    override void initialize() {
        default_resolution = Vector2(width, height);
        content.paths ~= ["../content/", "content/"];

        load_scenes([new EmuScene()]);
    }

    pragma(inline, true) {
        void update_pub() {
            update();
        }

        void draw_pub() {
            draw();
        }
    }
}
