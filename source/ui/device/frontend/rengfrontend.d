module ui.device.frontend.rengfrontend;

import ui.device.frontend.rengcore;

interface IFrontend {
    void init();
    void update();
    void render();
}

class RengFrontend : IFrontend {
    RengCore reng_core;

    public void init() {
        reng_core = new RengCore();
    }

    public void update() {
        reng_core.update_pub();
    }

    public void render() {
        reng_core.draw_pub();
    }
}
