module hw.apu.apu;

import hw.apu;
import hw.memory;
import hw.gba;

import hw.apu.channels.noise_channel;
import hw.apu.channels.wave_channel;
import hw.apu.channels.tone_channel;

import util;
import scheduler;

import std.stdio;

enum DirectSound {
    A = 0,
    B = 1
}

class APU {

public:

    Scheduler scheduler;

    this(Memory memory, Scheduler scheduler, void delegate(DirectSound) on_fifo_empty) {
        dma_sounds = [
            DMASound(0, false, false, 0, 0, new Fifo!ubyte(FIFO_SIZE, 0)),
            DMASound(0, false, false, 0, 0, new Fifo!ubyte(FIFO_SIZE, 0))
        ];

        this.on_fifo_empty           = on_fifo_empty;
        this.sample_rate             = 0;
        this.cycles_till_next_sample = 0;

        // should be big enough
        // this.audio_buffer            = new ubyte[sample_size * 8];
        this.audio_buffer_size       = 0;
        this.bias                    = 0x100;

        this.scheduler = scheduler;

        noise_channel = new NoiseChannel(scheduler);
        wave_channel  = new WaveChannel ();
        tone_channel  = new ToneChannel ();
    }

    void on_timer_overflow(int timer_id) {
        for (int i = 0; i < dma_sounds.length; i++) {
            // writefln("%x %x", i, dma_sounds[i].timer_select);
            if (dma_sounds[i].timer_select == timer_id && (dma_sounds[i].enabled_left || dma_sounds[i].enabled_right)) {
                pop_one_sample(cast(DirectSound) i);
            }
        }
    }

    void set_internal_sample_rate(uint sample_rate) {
        this.sample_rate = sample_rate;
        scheduler.add_event_relative_to_self(&sample, sample_rate);
    }

private:

    DMASound[2]  dma_sounds;
    NoiseChannel noise_channel;
    WaveChannel  wave_channel;
    ToneChannel  tone_channel; // todo: there are two, not one

    uint sample_rate;
    uint cycles_till_next_sample;

    ubyte[] audio_buffer;
    uint    audio_buffer_size;

    struct DMASound {
        int  volume; // (0=50%, 1=100%)
        bool enabled_right;
        bool enabled_left;
        bool timer_select;
        ubyte popped_sample;

        Fifo!ubyte fifo;
    }

    enum FIFO_SIZE           = 0x20;
    enum FIFO_FULL_THRESHOLD = 16;

    void delegate(DirectSound) on_fifo_empty;

    void pop_one_sample(DirectSound fifo_type) {
        if (dma_sounds[fifo_type].fifo.size != 0) {
            dma_sounds[fifo_type].popped_sample = dma_sounds[fifo_type].fifo.pop();
            // writefln("%x", dma_sounds[fifo_type].popped_sample);
            // push_to_buffer([value]);
        } else {
            dma_sounds[fifo_type].popped_sample = 0;
        }

        if (dma_sounds[fifo_type].fifo.size <= FIFO_FULL_THRESHOLD) {
            on_fifo_empty(fifo_type);
        }
    }

    void sample() {
        short mixed_sample_L = 0;
        short mixed_sample_R = 0;

        if (audio_master_enable) {
            if (get_nth_bit(analog_channels_enable_L, 1)) mixed_sample_L += tone_channel .sample(sample_rate);
            if (get_nth_bit(analog_channels_enable_R, 1)) mixed_sample_R += tone_channel .sample(sample_rate);
            if (get_nth_bit(analog_channels_enable_L, 2)) mixed_sample_L += wave_channel .sample(sample_rate);
            if (get_nth_bit(analog_channels_enable_R, 2)) mixed_sample_R += wave_channel .sample(sample_rate);
            if (get_nth_bit(analog_channels_enable_L, 3)) mixed_sample_L += noise_channel.sample(sample_rate);
            if (get_nth_bit(analog_channels_enable_R, 3)) mixed_sample_R += noise_channel.sample(sample_rate);

            mixed_sample_L = cast(short) ((mixed_sample_L >> 1) * sound_1_4_volume);
            mixed_sample_R = cast(short) ((mixed_sample_R >> 1) * sound_1_4_volume);
            mixed_sample_L = cast(short) ((mixed_sample_L >> 3) * analog_channels_volume_L);
            mixed_sample_R = cast(short) ((mixed_sample_R >> 3) * analog_channels_volume_R);

            if (dma_sounds[DirectSound.A].volume != 0) {
                if (dma_sounds[DirectSound.A].enabled_left ) mixed_sample_L += (cast(byte) dma_sounds[DirectSound.A].popped_sample);
                if (dma_sounds[DirectSound.A].enabled_right) mixed_sample_R += (cast(byte) dma_sounds[DirectSound.A].popped_sample);
            }

            if (dma_sounds[DirectSound.B].volume != 0) {
                if (dma_sounds[DirectSound.B].enabled_left ) mixed_sample_L += (cast(byte) dma_sounds[DirectSound.B].popped_sample);
                if (dma_sounds[DirectSound.B].enabled_right) mixed_sample_R += (cast(byte) dma_sounds[DirectSound.B].popped_sample);
            }

            // todo: make this code less repetitive

            mixed_sample_L += bias * 2;
            mixed_sample_R += bias * 2;
        }
        
        // short mixed_sample = cast(short) (dma_sample_A + dma_sample_B + bias * 2);
        // writefln("Mixing: %x %x", mixed_sample_L, mixed_sample_R);
        _audio_data.mutex.lock_nothrow();
        push_to_buffer(Channel.L, [mixed_sample_L]);
        push_to_buffer(Channel.R, [mixed_sample_R]);
        _audio_data.mutex.unlock_nothrow();
        
        scheduler.add_event_relative_to_self(&sample, sample_rate);
    }

// .......................................................................................................................
// .RRRRRRRRRRR...EEEEEEEEEEEE....GGGGGGGGG....IIII...SSSSSSSSS...TTTTTTTTTTTTT.EEEEEEEEEEEE..RRRRRRRRRRR....SSSSSSSSS....
// .RRRRRRRRRRRR..EEEEEEEEEEEE...GGGGGGGGGGG...IIII..SSSSSSSSSSS..TTTTTTTTTTTTT.EEEEEEEEEEEE..RRRRRRRRRRRR..SSSSSSSSSSS...
// .RRRRRRRRRRRRR.EEEEEEEEEEEE..GGGGGGGGGGGGG..IIII..SSSSSSSSSSSS.TTTTTTTTTTTTT.EEEEEEEEEEEE..RRRRRRRRRRRR..SSSSSSSSSSSS..
// .RRRR.....RRRR.EEEE..........GGGGG....GGGG..IIII..SSSS....SSSS.....TTTT......EEEE..........RRR.....RRRRR.SSSS....SSSS..
// .RRRR.....RRRR.EEEE.........GGGGG......GGG..IIII..SSSS.............TTTT......EEEE..........RRR......RRRR.SSSSS.........
// .RRRR....RRRRR.EEEEEEEEEEEE.GGGG............IIII..SSSSSSSS.........TTTT......EEEEEEEEEEEE..RRR.....RRRR..SSSSSSSS......
// .RRRRRRRRRRRR..EEEEEEEEEEEE.GGGG....GGGGGGG.IIII..SSSSSSSSSSS......TTTT......EEEEEEEEEEEE..RRRRRRRRRRRR...SSSSSSSSSS...
// .RRRRRRRRRRRR..EEEEEEEEEEEE.GGGG....GGGGGGG.IIII....SSSSSSSSS......TTTT......EEEEEEEEEEEE..RRRRRRRRRRRR....SSSSSSSSSS..
// .RRRRRRRRRRR...EEEE.........GGGG....GGGGGGG.IIII........SSSSSS.....TTTT......EEEE..........RRRRRRRRRR..........SSSSSS..
// .RRRR..RRRRR...EEEE.........GGGGG......GGGG.IIII...SS.....SSSS.....TTTT......EEEE..........RRR...RRRRR....SS.....SSSS..
// .RRRR...RRRR...EEEE..........GGGGG....GGGGG.IIII.ISSSS....SSSS.....TTTT......EEEE..........RRR....RRRR...SSSS....SSSS..
// .RRRR...RRRRR..EEEEEEEEEEEEE.GGGGGGGGGGGGGG.IIII.ISSSSSSSSSSSS.....TTTT......EEEEEEEEEEEEE.RRR....RRRRR..SSSSSSSSSSSS..
// .RRRR....RRRRR.EEEEEEEEEEEEE..GGGGGGGGGGGG..IIII..SSSSSSSSSSS......TTTT......EEEEEEEEEEEEE.RRR.....RRRRR.SSSSSSSSSSSS..
// .RRRR.....RRRR.EEEEEEEEEEEEE...GGGGGGGGG....IIII...SSSSSSSSS.......TTTT......EEEEEEEEEEEEE.RRR.....RRRRR..SSSSSSSSSS...

private:
    // SOUNDCNT_H
    int sound_1_4_volume;   // (0=25%, 1=50%, 2=100%, 3=Prohibited)

    // SOUNDBIAS
    short bias;

public:

    void write_SOUND2CNT_L(int target_byte, ubyte data) {
        final switch (target_byte) {
            case 0b0:
                tone_channel.set_length(get_nth_bits(data, 0, 6));
                tone_channel.set_duty  (get_nth_bits(data, 6, 8));
                break;

            case 0b1:
                // tone_channel.envelope           = (cast(float) (get_nth_bits(data, 0, 3))) / 64.0;
                // tone_channel.envelope_direction = get_nth_bit(data, 3) ? EnvelopeDirection.DECREASING : EnvelopeDirection.INCREASING;
                // tone_channel.initial_volume     = get_nth_bits(data, 4, 8);
                break;
        }
    }

    uint frequency_raw;
    void write_SOUND2CNT_H(int target_byte, ubyte data) {
        final switch (target_byte) {
            case 0b0:
                frequency_raw = (frequency_raw & ~0xFF) | data;
                tone_channel.set_frequency(frequency_raw);
                break;
            
            case 0b1:
                frequency_raw = (frequency_raw & 0xFF) | ((data & 3) << 2);
                tone_channel.set_frequency(frequency_raw);
                tone_channel.set_length_flag(get_nth_bit(data, 6));
                if (get_nth_bit(data, 7)) tone_channel.restart();
        }
    }

    void write_SOUND3CNT_L(ubyte data) {
        wave_channel.set_double_banked(get_nth_bit(data, 5));
        wave_channel.set_playback_bank(get_nth_bit(data, 6));
        wave_channel.set_enabled      (get_nth_bit(data, 7));
    }

    void write_SOUND3CNT_H(int target_byte, ubyte data) {
        // writefln("H %x %x", target_byte, data);
        final switch (target_byte) {
            case 0b0:
                wave_channel.set_length(data);
                break;
            case 0b1:
                wave_channel.set_sound_volume(get_nth_bits(data, 5, 7));
                wave_channel.set_force_volume(get_nth_bit (data, 7));
                break;
        }
    }

    // used to hold the current sample rate because
    // the full value is spread across bits [0-10],
    // which will happen in two separate function calls
    uint SOUND3CNT_X_sample_rate;
    void write_SOUND3CNT_X(int target_byte, ubyte data) {
        // writefln("X %x %x", target_byte, data);
        final switch (target_byte) {
            case 0b0:
                SOUND3CNT_X_sample_rate = (SOUND3CNT_X_sample_rate & 0x700) | data;
                wave_channel.set_sample_rate(SOUND3CNT_X_sample_rate);
                break;
            case 0b1:
                SOUND3CNT_X_sample_rate = (SOUND3CNT_X_sample_rate & 0xFF) | (get_nth_bits(data, 0, 3) << 8);
                wave_channel.set_sample_rate(SOUND3CNT_X_sample_rate);
                wave_channel.set_length_flag(get_nth_bit(data, 6));
                if (get_nth_bit(data, 7)) wave_channel.restart();
                break;
        }
    }

    pragma(inline, true) void write_WAVE_RAM(int index, ubyte data) {
        wave_channel.write_wave_ram(index, data);
    }

    void write_SOUND4CNT_L(int target_byte, ubyte data) {
        final switch (target_byte) {
            case 0b0:
                noise_channel.set_length(get_nth_bits(data, 0, 6));
                break;
            case 0b1:
                noise_channel.set_volume(get_nth_bits(data, 4, 8));
                break;
        }
    }
    
    void write_SOUND4CNT_H(int target_byte, ubyte data) {
        // writefln("Written to %x %x", target_byte, data);
        final switch (target_byte) {
            case 0b0:
                noise_channel.set_dividing_ratio       (get_nth_bits(data, 0, 3));
                noise_channel.set_counter_width        (get_nth_bit (data, 3));
                noise_channel.set_shift_clock_frequency(get_nth_bits(data, 4, 8));
                break;

            case 0b1:
                noise_channel.set_envelope_length   (get_nth_bits(data, 0, 3));
                noise_channel.set_envelope_direction(get_nth_bit (data, 3));
                noise_channel.set_volume            (get_nth_bits(data, 4, 8));
                break;
        }
    }
    
    void write_SOUNDCNT_H(int target_byte, ubyte data) {
        final switch (target_byte) {
            case 0b0:
                sound_1_4_volume                 = get_nth_bits(data, 0, 2);
                dma_sounds[DirectSound.A].volume = get_nth_bit (data, 2);
                dma_sounds[DirectSound.B].volume = get_nth_bit (data, 3);
                break;
                
            case 0b1:
                dma_sounds[DirectSound.A].enabled_right = get_nth_bit(data, 0);
                dma_sounds[DirectSound.A].enabled_left  = get_nth_bit(data, 1);
                dma_sounds[DirectSound.A].timer_select  = get_nth_bit(data, 2);
                dma_sounds[DirectSound.B].enabled_right = get_nth_bit(data, 4);
                dma_sounds[DirectSound.B].enabled_left  = get_nth_bit(data, 5);
                dma_sounds[DirectSound.B].timer_select  = get_nth_bit(data, 6);

                if (get_nth_bit(data, 3)) {
                    dma_sounds[DirectSound.A].fifo.reset();
                }

                if (get_nth_bit(data, 7)) {
                    dma_sounds[DirectSound.B].fifo.reset();
                }

                break;
        }
    }

    void write_FIFO(ubyte data, DirectSound fifo_type) {
        // writefln("Received FIFO data: %x", data);
        dma_sounds[fifo_type].fifo.push(data);
    }

    void write_SOUNDBIAS(int target_byte, ubyte data) {
        // writefln("BIAS: %x", bias);
        final switch (target_byte) {
            case 0b0:
                bias = cast(short) ((bias & 0x180) | get_nth_bits(data, 1, 8));
                break;

            case 0b1:
                bias = cast(short) ((bias & 0x7F) | (get_nth_bits(data, 0, 2) << 7));
                break; // TODO
        }
    }

    ushort analog_channels_volume_L = 0b111;
    ushort analog_channels_volume_R = 0b111;
    uint analog_channels_enable_L   = 0b1111;
    uint analog_channels_enable_R   = 0b1111;
    void write_SOUNDCNT_L(int target_byte, ubyte data) {
        final switch (target_byte) {
            case 0b0:
                analog_channels_volume_R = cast(ushort) get_nth_bits(data, 0, 3);
                analog_channels_volume_L = cast(ushort) get_nth_bits(data, 4, 7);
                break;

            case 0b1:
                analog_channels_enable_R = get_nth_bits(data, 0, 4); 
                analog_channels_enable_L = get_nth_bits(data, 4, 8); 
                break;
        }
    }

    bool audio_master_enable = false;
    void write_SOUNDCNT_X(int target_byte, ubyte data) {
        final switch (target_byte) {
            case 0b00:
                audio_master_enable = get_nth_bit(data, 7);
                break;

            case 0b01:
            case 0b10:
            case 0b11:
                break;
        }
    }

    ubyte read_SOUNDCNT_H(int target_byte) {
        final switch (target_byte) {
            case 0b0:
                return cast(ubyte) ((sound_1_4_volume                 << 0) |
                                    (dma_sounds[DirectSound.A].volume << 2) |
                                    (dma_sounds[DirectSound.B].volume << 3));
                
            case 0b1:
                return cast(ubyte) ((dma_sounds[DirectSound.A].enabled_right << 0) |
                                    (dma_sounds[DirectSound.A].enabled_left  << 1) |
                                    (dma_sounds[DirectSound.A].timer_select  << 3) |
                                    (dma_sounds[DirectSound.B].enabled_right << 4) |
                                    (dma_sounds[DirectSound.B].enabled_left  << 5) |
                                    (dma_sounds[DirectSound.B].timer_select  << 6));
        } 
    }

    ubyte read_SOUNDBIAS(int target_byte) {
        final switch (target_byte) {
            case 0b0:
                return (bias & 0x007F) << 1;
            case 0b1:
                return (bias & 0x0180) >> 7;
        }
    }

    ubyte read_SOUNDCNT_L(ubyte target_byte) {
        final switch (target_byte) {
            case 0b0:
                return cast(ubyte) ((analog_channels_volume_R) |
                                    (analog_channels_volume_L << 4));
            case 0b1:
                return cast(ubyte) ((analog_channels_enable_R) |
                                    (analog_channels_enable_L << 4));
        }
    }

    ubyte read_SOUNDCNT_X(ubyte target_byte) {
        final switch (target_byte) {
            case 0b0:
                return (false                 << 0) |
                       (tone_channel.enabled  << 1) |
                       (wave_channel.enabled  << 2) |
                       (noise_channel.enabled << 3);

            case 0b01:
            case 0b10:
            case 0b11:
                // TODO: it's invalid, but what does this actually return?
                return 0;
        }
    }
}