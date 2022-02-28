module ui.device.frontend.rengcore;

import re;
import re.math;
import ui.device.frontend.emuscene;

class RengCore : Core {
    enum WIDTH = 1920;
    enum HEIGHT = 1080;

    this() {
        super(WIDTH, HEIGHT, "GameBean Advance");
    }

    override void initialize() {
        default_resolution = Vector2(WIDTH, HEIGHT);
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
