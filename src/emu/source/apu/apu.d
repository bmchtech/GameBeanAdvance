module apu.apu;

import apu;
import memory;
import util;

import std.stdio;

enum DirectSound {
    A = 0,
    B = 1
}

class APU {
    this(Memory memory, void delegate(DirectSound) on_fifo_empty) {
        dma_sounds = [
            DMASound(0, false, false, 0, new Fifo!ubyte(FIFO_SIZE, 0)),
            DMASound(0, false, false, 0, new Fifo!ubyte(FIFO_SIZE, 0))
        ];
    }

public:

    void on_timer_overflow(int timer_id) {
        for (int i = 0; i < dma_sounds.length; i++) {
            if (dma_sounds[i].timer_select == timer_id) {
                push_one_sample_to_buffer(cast(DirectSound) i);
            }
        }
    }

private:

    struct DMASound {
        int  volume; // (0=50%, 1=100%)
        bool enabled_right;
        bool enabled_left;
        bool timer_select;

        Fifo!ubyte fifo;
    }

    enum FIFO_SIZE           = 20;
    enum FIFO_FULL_THRESHOLD = 4;

    void delegate(DirectSound) on_fifo_empty;

    void push_one_sample_to_buffer(DirectSound fifo_type) {
        if (dma_sounds[fifo_type].fifo.size != 0) {
            ubyte value = dma_sounds[fifo_type].fifo.pop();
            push_to_buffer([value]);
        }

        if (dma_sounds[fifo_type].fifo.size <= FIFO_FULL_THRESHOLD) {
            on_fifo_empty(fifo_type);
        }
    }

    DMASound[2] dma_sounds;

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

public:
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
        writefln("Received FIFO data: %x", data);
        dma_sounds[fifo_type].fifo.push(data);
    }
}