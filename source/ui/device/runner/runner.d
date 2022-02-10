module ui.device.runner.runner;

import ui.device.device;
import ui.device.event;

import hw.gba;

import core.sync.mutex;

class Runner : Observer {
    GBA gba;
    bool fast_forward = true;

    Mutex should_cycle_gba_mutex;
    bool should_cycle_gba;
    uint cycles_per_batch;

    this(GBA gba, uint cycles_per_batch) {
        this.gba = gba;
        this.cycles_per_batch = cycles_per_batch;
    }

    void run() {
        while (true) {
            if (gba.enabled) {
                while (fast_forward) {
                    gba.cycle_at_least_n_times(cycles_per_batch);
                    notify_observers(Event.POLL_INPUT);
                }
                
                should_cycle_gba_mutex.lock_nothrow();
                while (should_cycle_gba) {
                    gba.cycle_at_least_n_times(cycles_per_batch);
                    notify_observers(Event.POLL_INPUT);
                }
                should_cycle_gba_mutex.unlock_nothrow();
            }

	long clockfor_log = 0;
	ulong cycles_since_last_log = 0;

	ulong cycle_timestamp = 0;

	ulong start_timestamp = SDL_GetTicks();

	// while (running) {
	// 	ulong end_timestamp = SDL_GetTicks();
	// 	ulong elapsed = end_timestamp - start_timestamp;
	// 	start_timestamp = end_timestamp;

            // if (clockfor_log > msec_per_log) {
            //     SDL_SetWindowTitle(window, cast(char*) ("FPS: " ~ format("%d", fps)));
            //     clockfor_log = 0;
            //     cycles_since_last_log = 0;
            //     fps = 0;
            // }
        }
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

    }
}