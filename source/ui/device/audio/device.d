module ui.device.audio.device;

import ui.device.device;

struct Sample {
    short L;
    short R;
}

abstract class AudioDevice : Observer {
    uint saturation_point;
    uint low_point;
    
    this(uint saturation_point, uint low_point) {
        this.saturation_point = saturation_point;
        this.low_point        = low_point;
    }

    void push_sample(Sample);
    void pause();
    void play();
    uint get_sample_rate();
    uint get_samples_per_callback();
}