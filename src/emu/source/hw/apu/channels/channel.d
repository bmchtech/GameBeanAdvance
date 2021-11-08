module hw.apu.channels.channel;

alias Sample = short;

struct PannedSample {
    Sample L;
    Sample R;
}

immutable PannedSample EMPTY_SAMPLE = PannedSample(0, 0);

abstract class Channel {
    public int volume_L; // max value is 8
    public int volume_R; // max value is 8

    this() {
        
    }

    public PannedSample sample() {
        if (!enabled) return EMPTY_SAMPLE;
        return apply_volume(calculate_sample());
    }
    
    private PannedSample apply_volume(Sample sample) {
        Sample shifted_sample = (sample >> 3);
        return Sample(
            shifted_sample * volume_L,
            shifted_sample * volume_R
        );
    }

    abstract private Sample calculate_sample();
}