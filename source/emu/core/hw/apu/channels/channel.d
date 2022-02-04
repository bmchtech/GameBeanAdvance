module hw.apu.channels.channel;

alias Sample = short;

struct PannedSample {
    Sample L;
    Sample R;
}

immutable PannedSample EMPTY_SAMPLE = PannedSample(0, 0);

abstract class AudioChannel {
    public int volume_L; // max value is 8
    public int volume_R; // max value is 8
    public bool enabled;

    this() {
        
    }

    public PannedSample sample() {
        if (!enabled) return EMPTY_SAMPLE;
        return apply_volume(calculate_sample());
    }
    
    private PannedSample apply_volume(Sample sample) {
        Sample shifted_sample = (sample >> 3);
        return PannedSample(
            cast(Sample) (shifted_sample * volume_L),
            cast(Sample) (shifted_sample * volume_R)
        );
    }

    abstract protected Sample calculate_sample();
}