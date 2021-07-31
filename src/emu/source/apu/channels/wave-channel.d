module apu.channels.wave_channel;

class WaveChannel {
    
    bool is_double_banked;
    int  bank_number; // theres two banks - 0 and 1
    bool enabled;
    
    int[4] sound_volume_lut = [0, 4, 2, 1]; // where 4 is 100% volume
    int    sound_volume;
    bool   force_volume; // force volume to 75%
    int    volume;

    int  interval;

    this() {

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
        this.interval = 8 * (2048 - n);
    }

    void update_volume() {
        if (force_volume) {
            volume = 3;
        } else {
            volume = sound_volume_lut[sound_volume];
        }
    }
}