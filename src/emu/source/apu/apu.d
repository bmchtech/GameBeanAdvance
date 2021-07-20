module apu.apu;

import apu;
import memory;
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
        scheduler.add_event(&sample, sample_rate);
    }

private:

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

    DMASound[2] dma_sounds;

    void sample() {
        short mixed_sample_L;
        short mixed_sample_R;

        if (dma_sounds[DirectSound.A].enabled_left ) mixed_sample_L += (cast(byte) dma_sounds[DirectSound.A].popped_sample);
        if (dma_sounds[DirectSound.A].enabled_right) mixed_sample_R += (cast(byte) dma_sounds[DirectSound.A].popped_sample);
        if (dma_sounds[DirectSound.B].enabled_left ) mixed_sample_L += (cast(byte) dma_sounds[DirectSound.B].popped_sample);
        if (dma_sounds[DirectSound.B].enabled_right) mixed_sample_R += (cast(byte) dma_sounds[DirectSound.B].popped_sample);

        mixed_sample_L += bias * 2;
        mixed_sample_R += bias * 2;
        
        // short mixed_sample = cast(short) (dma_sample_A + dma_sample_B + bias * 2);
        // writefln("Mixing: %x %x", mixed_sample_L, mixed_sample_R);
        push_to_buffer(Channel.L, [mixed_sample_L]);
        push_to_buffer(Channel.R, [mixed_sample_R]);

        scheduler.add_event(&sample, sample_rate);
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

    // void write_SOUND2CNT_L(int target_byte, ubyte data) {
    //     final switch (target_byte) {
    //         case 0b0:
    //             channel_tone.length             = (cast(float) (64 - get_nth_bits(data, 0, 6))) / 256.0;
    //             channel_tone.duty               = tone_duty_table[get_nth_bits(data, 6, 8)];
    //             break;

    //         case 0b1:
    //             channel_tone.envelope           = (cast(float) (get_nth_bits(data, 0, 3))) / 64.0;
    //             channel_tone.envelope_direction = get_nth_bit(data, 3) ? EnvelopeDirection.DECREASING : EnvelopeDirection.INCREASING;
    //             channel_tone.initial_volume     = get_nth_bits(data, 4, 8);
    //             break;
    //     }
    // }

    // void write_SOUND2CNT_H(int target_byte, ubyte data) {
    //     final switch (target_byte) {
    //         case 0b0:
    //             channel_tone.frequency_raw        = get_nth_bits(data, 0, 8) | channel_tone.frequency_raw & ~0xFF;
    //             break;
            
    //         case 0b1:
    //             channel_tone.frequency_raw        = (get_nth_bits(data, 0, 2) << 8) | (channel_tone.frequency_raw & 0xFF);
    //             channel_tone.stop_upon_completion = get_nth_bit(data, 14);   
                
    //             if (get_nth_bit(data, 15)) restart_channel_tone();
    //     }
        
    //     channel_tone.frequency = 131072 / (2048 - channel_tone.frequency_raw);
    // }
    
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
        final switch (target_byte) {
            case 0b0:
                bias = cast(short) ((bias & 0x180) | get_nth_bits(data, 1, 8));
                break;

            case 0b1:
                bias = cast(short) ((bias & 0x7F) | (get_nth_bits(data, 0, 2) << 7));
                break; // TODO
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
                return (bias & 0x00FF) >> 0;
            case 0b1:
                return (bias & 0xFF00) >> 8;
        }
    }
}