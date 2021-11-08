module hw.apu.channels.noise_channel;

// import apu.channels.noise_lut;
import scheduler;

import std.stdio;

class NoiseChannel {
    private int shift_register         = 0;
    private int reload_value           = 0;
    private int shifter_xor_value      = 0;

    public  int dividing_ratio         = 0;
    public  int shift_clock_frequency  = 0;
    private int volume               = 0;

    private int  cycles_elapsed         = 0;
    private long length;
    public  bool enabled = false;
    // private int  sound_length;
    // private bool stop_on_expire;

    private int interval = 1;

    private int current_shifter_out = -1;

    private Scheduler scheduler;
    private ulong     shifter_event;

    this(Scheduler scheduler) {
        this.scheduler = scheduler;
        reload();
    }

    void reload() {
        shift_register = reload_value;
        cycles_elapsed = 0;

        if (shifter_event) scheduler.remove_event(shifter_event);
        if (enabled)       shifter_event = scheduler.add_event_relative_to_self(&shift, interval);
    }

    short sample(int delta_cycles) {
        if (!enabled) return 0;

        cycles_elapsed += delta_cycles;
        // if (cycles_elapsed > length) enabled = false;
        return cast(short) (current_shifter_out * 8);
    }

    void shift() {
        bool carry = shift_register & 1;
        shift_register >>= 1;

        if (carry) {
            current_shifter_out = 1;
            shift_register ^= shifter_xor_value;
        } else {
            current_shifter_out = -1;
        }

        shifter_event = scheduler.add_event_relative_to_self(&shift, interval);
    }

    void set_counter_width(int counter_width) {
        this.reload_value      = counter_width == 1 ? 0x40 : 0x4000;
        this.shifter_xor_value = counter_width == 1 ? 0x60 : 0x6000;
        reload();
        enabled = true;
    }

    void set_dividing_ratio(int dividing_ratio) {
        this.dividing_ratio = dividing_ratio == 0 ? 8 : dividing_ratio;
        recalculate_interval();
    }

    void set_shift_clock_frequency(int shift_clock_frequency) {
        this.shift_clock_frequency = shift_clock_frequency;
        recalculate_interval();
    }

    void recalculate_interval() {
        interval = (dividing_ratio * 64) << shift_clock_frequency;
    }

    // where n is bits 0-5 of SOUND4CNT_L
    void set_length(int n) {
        length = 65546 * (64 - n);
    }

    void set_volume(int volume) {
        this.volume = cast(short) volume;
        enabled = volume != 0;
    }
}