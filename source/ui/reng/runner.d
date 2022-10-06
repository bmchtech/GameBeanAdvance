module ui.reng.runner;

import ui.device;
import ui.reng;

import hw.gba;

import std.datetime.stopwatch;

import core.sync.mutex;

final class Runner {
    GBA gba;
    bool fast_forward;

    Mutex should_cycle_gba_mutex;
    bool should_cycle_gba;

    MultiMediaDevice frontend;

    size_t sync_to_audio_lower;
    size_t sync_to_audio_upper;

    StopWatch stopwatch;

    bool running;

    int fps = 0;

    this(GBA gba, MultiMediaDevice frontend) {
        this.gba = gba;

        this.should_cycle_gba_mutex = new Mutex();

        this.frontend = frontend;

        this.should_cycle_gba = true;
        this.running          = true;
    }

    void tick() {
        if (stopwatch.peek.total!"msecs" > 1000) {
            frontend.set_fps(fps);
            stopwatch.reset();
            fps = 0;
        }

        frontend.update();
        frontend.draw();
    }

    void run() {
        stopwatch = StopWatch(AutoStart.yes);

        while (running) {
            if (frontend.should_cycle_gba() || frontend.should_fast_forward()) {
                if (gba.enabled) {
                    gba.cycle_at_least_n_times(16_780_000 / 60);
                }
                
                fps++;
            }
            
            tick();
        }
    }
}