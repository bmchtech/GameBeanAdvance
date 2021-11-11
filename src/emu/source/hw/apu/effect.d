module hw.apu.effect;

import hw.apu;

import std.stdio;

abstract class Effect {
    void apply(Sample* s);
}

class VolumeEffect(uint max) : Effect {
    public  uint volume;
    private uint shift;

    this() {
        assert((max & (max - 1)) == 0); // Max must be a power of 2
        this.volume = 0;
        this.shift  = 0;

        // take the log base 2 of max, set it to shift.
        // e.g. a max volume of 16 would have a shift of 4.
        uint max_copy = max;
        while (max_copy != 1) {
            max_copy >>= 1;
            shift++;
        }
    }

    override pragma(inline, true) void apply(Sample* s) {
        *s = cast(Sample) ((*s >> shift) * volume);
    }
}