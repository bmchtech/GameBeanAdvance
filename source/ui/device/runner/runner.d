module ui.device.runner.runner;

import ui.device.device;
import ui.device.event;

import hw.gba;

import ui.device.video.device;
import ui.device.audio.device;
import ui.device.input.device;

import ui.device.frontend.rengfrontend;

import bindbc.sdl;

import core.sync.mutex;

class Runner : Observer {
    GBA gba;
    bool fast_forward = false;

    Mutex should_cycle_gba_mutex;
    bool should_cycle_gba = true;
    uint cycles_per_batch;

    VideoDevice video_device;
    AudioDevice audio_device;
    InputDevice input_device;
    RengFrontend frontend;

    size_t sync_to_audio_lower;
    size_t sync_to_audio_upper;

    ulong start_timestamp;

    bool running = true;

    this(GBA gba, uint cycles_per_batch, VideoDevice video_device, AudioDevice audio_device, InputDevice input_device) {
        this.gba = gba;
        this.cycles_per_batch = cycles_per_batch;

        this.video_device = video_device;
        this.audio_device = audio_device;
        this.input_device = input_device;

        frontend = new RengFrontend();
        frontend.init();

        this.should_cycle_gba_mutex = new Mutex();

        this.sync_to_audio_lower = audio_device.get_samples_per_callback() / 2;
        this.sync_to_audio_upper = audio_device.get_samples_per_callback();
    }

    void tick() {
        input_device.handle_input();

        auto buffer_size = audio_device.get_buffer_size();
        if (buffer_size > sync_to_audio_upper) set_should_cycle_gba(false);
        if (buffer_size < sync_to_audio_lower) set_should_cycle_gba(true);
        
		ulong end_timestamp = SDL_GetTicks();
		ulong elapsed = end_timestamp - start_timestamp;
        if (elapsed > 1000) {
            video_device.reset_fps();
            start_timestamp = end_timestamp;
        }

        frontend.update();
    }

    void run() {
        start_timestamp = SDL_GetTicks();

        while (running) {
            if (gba.enabled) {
                // i separated the ifs so fast fowarding doesn't
                // incur a mutex call from get_should_cycle_gba
                if (fast_forward) {
                    gba.cycle_at_least_n_times(cycles_per_batch);
                } else {
                    if (get_should_cycle_gba()) {
                        gba.cycle_at_least_n_times(cycles_per_batch);
                    }
                }

                tick();
            }
        }
    }

    bool get_should_cycle_gba() {
        should_cycle_gba_mutex.lock_nothrow();
        bool temp = should_cycle_gba;
        should_cycle_gba_mutex.unlock_nothrow();
        return temp;
    }

    override void notify(Event e) {
        final switch (e) {
            case Event.FAST_FORWARD:           fast_forward = true;  break;
            case Event.UNFAST_FORWARD:         fast_forward = false; break;
            case Event.STOP:                   stop(); break;
            case Event.AUDIO_BUFFER_LOW:       set_should_cycle_gba(true); break;
            case Event.AUDIO_BUFFER_SATURATED: set_should_cycle_gba(false); break;
            case Event.POLL_INPUT:             break;
        }
    }

    void set_should_cycle_gba(bool value) {
        should_cycle_gba_mutex.lock_nothrow();
        should_cycle_gba = value;
        should_cycle_gba_mutex.unlock_nothrow();
    }

    void stop() {
        running = false;
    }
}