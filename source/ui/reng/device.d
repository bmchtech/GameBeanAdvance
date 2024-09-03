module ui.reng.device;

import hw.gba;
import hw.keyinput;

import ui.device;
import ui.reng;

import std.format;
import std.string;

import raylib;
import re;

class RengMultimediaDevice : MultiMediaDevice {
    enum SAMPLE_RATE            = 48000;
    enum SAMPLES_PER_UPDATE     = 4096;
    enum BUFFER_SIZE_MULTIPLIER = 1.5;
    enum NUM_CHANNELS           = 2;

    enum FAST_FOWARD_KEY        = Keys.KEY_TAB;

    GBA gba;
    RengCore reng_core;
    GBAVideo  gba_video;
    AudioStream stream;

    bool fast_forward;

    string rom_title;
    int fps;

    this(GBA gba, int screen_scale) {
        this.gba = gba;

        Core.target_fps = 60;
        reng_core = new RengCore(gba, screen_scale);

        InitAudioDevice();
        SetAudioStreamBufferSizeDefault(SAMPLES_PER_UPDATE);
        stream = LoadAudioStream(SAMPLE_RATE, 16, NUM_CHANNELS);
        PlayAudioStream(stream);
        
        gba_video = Core.jar.resolve!GBAVideo().get; 
    }

    override {
        // video stuffs
        void present_videobuffers(Pixel[160][240] buffer) {
            for (int y = 0; y < 160; y++) {
            for (int x = 0; x < 240;  x++) {
                    gba_video.videobuffer[y * 240 + x] = 
                        (buffer[x][y].r << 3 <<  0) |
                        (buffer[x][y].g << 3 <<  8) |
                        (buffer[x][y].b << 3 << 16) |
                        0xFF000000;
            }
            }
        }

        void set_fps(int fps) {
            this.fps = fps;
            redraw_title();
        }

        void update_rom_title(string rom_title) {
            import std.string;
            this.rom_title = rom_title.splitLines[0].strip;
            redraw_title();
        }

        void update_icon(Pixel[32][32] buffer_texture) {

        }

        // 2 cuz stereo
        short[cast(ulong) (NUM_CHANNELS * SAMPLES_PER_UPDATE * BUFFER_SIZE_MULTIPLIER)] buffer;
        int buffer_cursor = 0;

        void push_sample(Sample s) {
            if (fast_forward) buffer_cursor = 0;

            buffer[buffer_cursor + 0] = s.L;
            buffer[buffer_cursor + 1] = s.R;
            buffer_cursor += 2;
        }

        void update() {
            handle_input();
            handle_audio();
            reng_core.update_pub();
        }

        void draw() {
            reng_core.draw_pub();
        }

        bool should_cycle_gba() {
            return buffer_cursor < cast(ulong) (NUM_CHANNELS * BUFFER_SIZE_MULTIPLIER * SAMPLES_PER_UPDATE - (SAMPLE_RATE / 60) * 2);
        }

        void handle_input() {
            // ignore input if console is open
            if (Core.inspector_overlay.console.open) return;
            
            static foreach (re_key, gba_key; keys) {
                update_key(gba_key, Input.is_key_down(re_key));
            }

            fast_forward = Input.is_key_down(FAST_FOWARD_KEY);
        }

        bool should_fast_forward() {
            return fast_forward;
        }
    }

    void redraw_title() {
        import std.format;
        gba_video.update_title("%s [FPS: %d]".format(rom_title, fps));
    }

    void handle_audio() {
        if (IsAudioStreamProcessed(stream)) {
            UpdateAudioStream(stream, cast(void*) buffer, SAMPLES_PER_UPDATE);
            
            for (int i = 0; i < NUM_CHANNELS * SAMPLES_PER_UPDATE * (BUFFER_SIZE_MULTIPLIER - 1); i++) {
                buffer[i] = buffer[i + NUM_CHANNELS * SAMPLES_PER_UPDATE];
            }

            buffer_cursor -= NUM_CHANNELS * SAMPLES_PER_UPDATE;
            if (buffer_cursor < 0) buffer_cursor = 0;

            if (fast_forward) buffer_cursor = 0;
        }
    }

    enum keys = [
        Keys.KEY_Z     : GBAKeyVanilla.A,
        Keys.KEY_X     : GBAKeyVanilla.B,
        Keys.KEY_ENTER : GBAKeyVanilla.SELECT,
        Keys.KEY_SPACE : GBAKeyVanilla.START,
        Keys.KEY_RIGHT : GBAKeyVanilla.RIGHT,
        Keys.KEY_LEFT  : GBAKeyVanilla.LEFT,
        Keys.KEY_UP    : GBAKeyVanilla.UP,
        Keys.KEY_DOWN  : GBAKeyVanilla.DOWN,
        Keys.KEY_S     : GBAKeyVanilla.R,
        Keys.KEY_A     : GBAKeyVanilla.L
    ];
}