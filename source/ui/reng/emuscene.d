module ui.reng.emuscene;

import ui.reng;
import ui.reng.console;

import re;
import re.gfx;
import re.gfx.effects.frag;
import re.util.hotreload;

class EmuScene : Scene2D {
    int screen_scale;
    EmuConsole console;

    this(int screen_scale) {
        this.screen_scale = screen_scale;
        super();

        console = new EmuConsole();
    }

    override void on_start() {
        auto gba_screen = create_entity("gba_display");
        auto gba_video = gba_screen.add_component(new GBAVideo(screen_scale));
        Core.jar.register(gba_video);

        auto draw_shd_path = "source/emu/core/shaders/colorcorrection.frag";
        auto shd_draw = new FragEffect(this, new ReloadableShader(null, draw_shd_path));
        auto draw_p = new PostProcessor(resolution, shd_draw);
        postprocessors ~= draw_p;

        // set up console
        console.register();
    }

    override void on_unload() {
        console.unregister();
    }

    override void update() {
        super.update();
    }
}