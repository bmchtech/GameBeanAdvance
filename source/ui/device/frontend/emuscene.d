module ui.device.frontend.emuscene;

import re;
import ui.device.frontend.gbavideo;

class EmuScene : Scene2D {
    override void on_start() {
        auto gba_screen = create_entity("gba_display");
        gba_screen.add_component(new GbaVideo());
    }

    override void update() {
        super.update();
    }
}
