module ui.device.video.device;

enum SCREEN_WIDTH  = 240;
enum SCREEN_HEIGHT = 160;

struct Pixel {
    uint r;
    uint g;
    uint b;
}

abstract class VideoDevice : Device {
    void render(Pixel[SCREEN_HEIGHT][SCREEN_WIDTH] buffer);
}