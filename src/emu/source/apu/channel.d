module apu.channel;

enum EnvelopeDirection {
    DECREASING,
    INCREASING
}

struct Envelope {
    EnvelopeDirection direction;
    int initial_volume;
    int step_time;
}