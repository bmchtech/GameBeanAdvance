module apu.channels.wave_channel;

class WaveChannel {
    
    bool is_double_banked;
    int  playback_bank; // theres two banks - 0 and 1
    int  modify_bank;
    int  playback_bank__cache;
    bool enabled;
    
    int[4] sound_volume_lut = [0, 4, 2, 1]; // where 4 is 100% volume
    int    sound_volume;
    bool   force_volume; // force volume to 75%
    int    volume;

    uint   interval;

    ubyte[32][2] wave_ram;
    int wave_ram_index;
    int wave_ram_index_mask;

    uint cycles_elapsed;
    int  cycles_remaining;

    bool length_flag;

    this() {
        enabled          = false;
        cycles_elapsed   = 0;
        cycles_remaining = 0;
        length_flag      = false;
        interval         = 8 * 2048;
    }

    short sample(int delta_cycles) {
        if (!enabled) return 0;
        import std.stdio;

        cycles_elapsed += delta_cycles;
        while (cycles_elapsed > interval) {
            // writefln("%x %x", cycles_elapsed, interval);
            wave_ram_index++;
            cycles_elapsed -= interval;
        }

        if (length_flag) {
            cycles_remaining -= delta_cycles;
            if (cycles_remaining < 0) enabled = false;
        }

        wave_ram_index &= 31;
        return cast(short) (wave_ram[playback_bank][wave_ram_index] * 2 * volume);
    }

    void set_double_banked(bool is_double_banked) {
        if (is_double_banked) {
            this.playback_bank       = playback_bank__cache;
            this.modify_bank         = (playback_bank) == 1 ? 0 : 1;
        } else {
            this.playback_bank       = 0;
            this.modify_bank         = 0;
        }
    }

    void set_playback_bank(int playback_bank) {
        this.playback_bank = playback_bank;
        this.modify_bank   = (playback_bank == 1) ? 0 : 1;

        this.playback_bank__cache = playback_bank;
    }

    void set_enabled(bool enabled) {
        if (!this.enabled && enabled) {
            restart();
        }

        this.enabled = enabled;
    }

    void set_length(uint n) {
        import std.stdio;
        // writefln("set set to %x", n);
        this.cycles_remaining = 65547 * (256 - n);
    }

    void set_length_flag(bool length_flag) {
        import std.stdio;
        // writefln("set length to %x", length_flag);
        this.length_flag = length_flag;
    }

    void restart() {
        wave_ram_index   = 0;
        cycles_remaining = 0;
        length_flag      = false;
    }

    void set_sound_volume(int sound_volume) {
        this.sound_volume = sound_volume;
        update_volume();
    }

    void set_force_volume(bool force_volume) {
        this.force_volume = force_volume;
        update_volume();
    }

    void set_sample_rate(int n) {
        this.interval = 16 * (2048 - n);
    }

    void update_volume() {
        if (force_volume) {
            volume = 3;
        } else {
            volume = sound_volume_lut[sound_volume];
        }
    }

    void write_wave_ram(int index, ubyte value) {
        import std.stdio;
        // writefln("%x %x", modify_bank, index);
        wave_ram[modify_bank][2 * index    ] = value >> 4;
        wave_ram[modify_bank][2 * index + 1] = value & 0xF;
    }

    ubyte read_wave_ram(int index) {
        return wave_ram[modify_bank][index];
    }
}