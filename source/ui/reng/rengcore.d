module ui.reng.rengcore;

import ui.reng;

import re;
import re.math;

class RengCore : Core {
    int width;
    int height;
    int screen_scale;

    this(int screen_scale) {
        this.width  = 240 * screen_scale;
        this.height = 160 * screen_scale;
        this.screen_scale = screen_scale;

        super(width, height, "GameBeanAdvance");
    }

    override void initialize() {
		// use custom console
		this.inspector_overlay.enabled = true;
		this.inspector_overlay.console.reset();

        default_resolution = Vector2(width, height);
        content.paths ~= ["../content/", "content/"];

        load_scenes([new EmuScene(screen_scale)]);
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