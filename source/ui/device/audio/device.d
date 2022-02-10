module ui.device.audio.device;

import ui.device.device;

struct Sample {
    short L;
    short R;
}

abstract class AudioDevice : Observer {
    void push_sample(Sample);
    void pause();
    void play();
    uint get_sample_rate();
    uint get_samples_per_callback();
    size_t get_buffer_size();
}