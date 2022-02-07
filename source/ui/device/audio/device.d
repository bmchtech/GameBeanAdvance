module ui.device.audio.device;

struct Sample {
    short L;
    short R;
}

abstract class AudioDevice : Device {
    uint saturation_point;
    uint low_point;
    
    this(uint saturation_point, uint low_point) {
        this.saturation_point = saturation_point;
        this.low_point        = low_point;
    }

    void push_sample(Sample);
    void pause();
    void play();
}