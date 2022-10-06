module ui.reng.emuscene;

import ui.reng;

import re;
import re.gfx;
import re.gfx.effects.frag;
import re.util.hotreload;

class EmuScene : Scene2D {
    int screen_scale;

    this(int screen_scale) {
        this.screen_scale = screen_scale;
        super();
    }

    override void on_start() {
        auto gba_screen = create_entity("gba_display");
        auto gba_video = gba_screen.add_component(new GBAVideo(screen_scale));
        Core.jar.register(gba_video);

        auto draw_shd_path = "source/emu/core/shaders/colorcorrection.frag";
        auto shd_draw = new FragEffect(this, new ReloadableShader(null, draw_shd_path));
        auto draw_p = new PostProcessor(resolution, shd_draw);
        postprocessors ~= draw_p;
    }

    override void update() {
        super.update();
    }
}