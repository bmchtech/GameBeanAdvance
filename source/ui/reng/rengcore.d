module ui.reng.rengcore;

import hw.gba;

import ui.reng;

import re;
import re.math;

class RengCore : Core {
    GBA gba;
    int width;
    int height;
    int screen_scale;

    this(GBA gba, int screen_scale) {
        this.gba = gba;
        this.width  = 240 * screen_scale;
        this.height = 160 * screen_scale;
        this.screen_scale = screen_scale;

        super(width, height, "GameBeanAdvance");
    }

    override void initialize() {
        // store gba in jar
        Core.jar.register(gba);

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