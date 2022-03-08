module ui.device.frontend.emuscene;

import re;
import ui.device.frontend.gbavideo;

class EmuScene : Scene2D {
    override void on_start() {
        auto gba_screen = create_entity("gba_display");
        auto gba_video = gba_screen.add_component(new GbaVideo(2));
        Core.jar.register(gba_video);
    }

    override void update() {
        super.update();
    }
}
