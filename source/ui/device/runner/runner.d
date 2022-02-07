module ui.device.runner.runner;

class Runner : Observer {
    GBA gba;
    bool fast_forward;

    Mutex should_cycle_gba_mutex;
    bool should_cycle_gba;

    this(GBA gba) {
        this.gba = gba;
    }

    void run() {
        ulong end_timestamp = SDL_GetTicks();
		ulong elapsed = end_timestamp - start_timestamp;
		start_timestamp = end_timestamp;

		clockfor_log   += elapsed;
		clockfor_frame += elapsed;
        

		if (gba.enabled) {
            while (fast_forward) {
				gba.cycle_at_least_n_times(cycles_per_batch);
            }
            
            should_cycle_gba_mutex.lock_nothrow();
            while (should_cycle_gba) {
				gba.cycle_at_least_n_times(cycles_per_batch);
            }
            should_cycle_gba_mutex.unlock_nothrow();
		}

		notify_observers(Event.POLL_INPUT);
    }

    override void notify(Event e) {
        final switch (e) {
            case Event.FAST_FORWARD:           fast_forward = true;  break;
            case Event.UNFAST_FORWARD:         fast_forward = false; break;
            case Event.STOP:                   stop(); break;
            case Event.AUDIO_BUFFER_LOW:       set_should_cycle_gba(true);
            case Event.AUDIO_BUFFER_SATURATED: set_should_cycle_gba(false);
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