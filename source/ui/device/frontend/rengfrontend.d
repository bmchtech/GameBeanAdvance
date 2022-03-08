module ui.device.frontend.rengfrontend;

import ui.device.frontend.rengcore;
import ui.device.device;
import ui.device.event;
import ui.device.frontend.gbavideo;

import re;

import hw.gba;

class RengFrontend : MultiMediaDevice {
    RengCore reng_core;
    GbaVideo gba_video;

    this(int screen_scale) {
        Core.target_fps = 999_999;
        reng_core = new RengCore(screen_scale);
    }

    override {
        // video stuffs
        void receive_videobuffer(Pixel[SCREEN_HEIGHT][SCREEN_WIDTH] buffer) {
            // reng_core.draw_pub();
            gba_video = Core.jar.resolve!GbaVideo().get; 

            for (int y = 0; y < SCREEN_HEIGHT; y++) {
            for (int x = 0; x < SCREEN_WIDTH;  x++) {
                    gba_video.frame_buffer[y * SCREEN_WIDTH + x] = 
                        (buffer[x][y].r << 3 <<  0) |
                        (buffer[x][y].g << 3 <<  8) |
                        (buffer[x][y].b << 3 << 16) |
                        0xFF000000;
            }
            }
        }

        void reset_fps() {
            // AAAAAA
        }

        // audio stuffs
        void push_sample(Sample s) {

        }

        void update() {
            handle_input();
            reng_core.update_pub();
        }

        void draw() {
            reng_core.draw_pub();
        }

        void pause() {
        }

        void play() {
        }

        uint get_sample_rate() {
            return 100;
        }

        uint get_samples_per_callback() {
            return 44100;
        }

        size_t get_buffer_size() {
            return 500;
        }

        // input stuffs
        void handle_input() {
            static foreach (re_key, gba_key; keys) {
                set_vanilla_key(gba_key, Input.is_key_down(re_key));
            }
        }

        void notify(Event e) {
        }

    }

    enum keys = [
        Keys.KEY_Z     : GBAKeyVanilla.A,
        Keys.KEY_X     : GBAKeyVanilla.B,
        Keys.KEY_SPACE : GBAKeyVanilla.SELECT,
        Keys.KEY_ENTER : GBAKeyVanilla.START,
        Keys.KEY_RIGHT : GBAKeyVanilla.RIGHT,
        Keys.KEY_LEFT  : GBAKeyVanilla.LEFT,
        Keys.KEY_UP    : GBAKeyVanilla.UP,
        Keys.KEY_DOWN  : GBAKeyVanilla.DOWN,
        Keys.KEY_S     : GBAKeyVanilla.R,
        Keys.KEY_A     : GBAKeyVanilla.L
    ];
}
