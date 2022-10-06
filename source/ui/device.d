module ui.device;

import hw.gba;
import hw.keyinput;

alias SetKey = void delegate(GBAKeyVanilla key, bool value);
alias UpdateTouchscreenPosition = void delegate(int x_position, int y_position);

struct Sample {
    short L;
    short R;
}

struct Pixel {
    int r;
    int g;
    int b;
}

abstract class MultiMediaDevice {
    SetKey update_key;
    UpdateTouchscreenPosition update_touchscreen_position;

    final void set_update_key_callback(SetKey update_key) {
        this.update_key = update_key;
    }

    final void set_update_touchscreen_position(UpdateTouchscreenPosition update_touchscreen_position) {
        this.update_touchscreen_position = update_touchscreen_position;
    }

    abstract {
        void update();
        void draw();
        bool should_cycle_gba();
        void update_rom_title(string title);

        // video stuffs
        void present_videobuffers(Pixel[160][240] buffer);
        void set_fps(int fps);
        void update_icon(Pixel[32][32] texture);

        // audio stuffs
        void push_sample(Sample s);

        // input stuffs
        void handle_input();
    }

    bool should_fast_forward();
}