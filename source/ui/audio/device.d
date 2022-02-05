module ui.audio.device;

struct Sample {
    short L;
    short R;
}

interface AudioDevice {
    void push_sample(Sample);
    void pause();
    void play();
}