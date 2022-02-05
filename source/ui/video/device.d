module ui.video.device;

enum SCREEN_WIDTH  = 240;
enum SCREEN_HEIGHT = 160;

struct Pixel {
    uint r;
    uint g;
    uint b;
}

interface VideoDevice {
    void render(Pixel[SCREEN_HEIGHT][SCREEN_WIDTH] buffer);
}