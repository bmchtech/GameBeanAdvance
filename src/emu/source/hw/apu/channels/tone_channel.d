module hw.apu.channels.tone_channel;

class ToneChannel {
    
    bool enabled;
    int  volume;
    uint interval;

    uint cycles_elapsed;
    int  cycles_remaining;

    bool length_flag;

    uint lut_index;
    uint duty;

    immutable bool[8][4] wave_duty_lut = [
        [1, 0, 0, 0, 0, 0, 0, 0],
        [1, 1, 0, 0, 0, 0, 0, 0],
        [1, 1, 1, 1, 0, 0, 0, 0],
        [1, 1, 1, 1, 1, 1, 0, 0]
    ];

    this() {
        enabled          = false;
        cycles_elapsed   = 0;
        cycles_remaining = 0;
        length_flag      = false;
        interval         = 8 * 2048;
    }

    short sample(int delta_cycles) {
        if (!enabled) return 0;
        
        cycles_elapsed += delta_cycles;
        while (cycles_elapsed > interval) {
            lut_index++;
            cycles_elapsed -= interval;
        }
        lut_index &= 7;

        if (length_flag) {
            cycles_remaining -= delta_cycles;
            if (cycles_remaining < 0) enabled = false;
        }

        return cast(short) wave_duty_lut[duty][lut_index];
    }

    void set_duty(int duty) {
        this.duty = duty;
    }

    void set_enabled(bool enabled) {
        if (!this.enabled && enabled) {
            restart();
        }

        this.enabled = enabled;
    }

    void set_length(uint n) {
        this.cycles_remaining = 65547 * (64 - n);
    }//

    void set_length_flag(bool length_flag) {
        this.length_flag = length_flag;
    }//

    void restart() {
        cycles_remaining = 0;
        length_flag      = false;
    }//

    void set_frequency(int n) {
        this.interval = 32 * (2048 - n);
    }//
}