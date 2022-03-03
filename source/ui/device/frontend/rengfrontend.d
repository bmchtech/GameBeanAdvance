module ui.device.frontend.rengfrontend;

import ui.device.frontend.rengcore;
import ui.device.device;
import ui.device.event;

class RengFrontend : MultiMediaDevice {
    RengCore reng_core;

    this() {
        reng_core = new RengCore();
    }

    override {
        // video stuffs
        void receive_videobuffer(Pixel[SCREEN_HEIGHT][SCREEN_WIDTH] buffer) {
            
            reng_core.draw_pub();
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
        }


        void pause() {}
        void play() {}
        uint get_sample_rate() { return 100; }
        uint get_samples_per_callback() { return 44100; }
        size_t get_buffer_size() { return 500; }

        // input stuffs
        void handle_input() {}
        
        void notify(Event e) {}

    }
}
