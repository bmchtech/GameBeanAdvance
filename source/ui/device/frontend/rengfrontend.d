module ui.device.frontend.rengfrontend;

import ui.device.frontend.rengcore;
import ui.device.device;
import ui.device.event;
import ui.device.frontend.gbavideo;

class RengFrontend : MultiMediaDevice {
    RengCore reng_core;

    this() {
        reng_core = new RengCore();
    }

    override {
        // video stuffs
        void receive_videobuffer(Pixel[SCREEN_HEIGHT][SCREEN_WIDTH] buffer) {
            // reng_core.draw_pub();
            auto gbavid = Core.jar.resolve!GbaVideo();
            assert(gbavid, "gba video renderer was null");

            // do stuff here
            // gbavid.frame_buffer
            for (int i = 0; i < SCREEN_HEIGHT; i++) {
                for (int j = 0; j < SCREEN_WIDTH; j++) {
                    gbavid.frame_buffer[i * SCREEN_WIDTH + j] = buffer[i][j];
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
            reng_core.update_pub();
        }

        void draw() {
            // do sussy stuff
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
        }

        void notify(Event e) {
        }

    }
}
