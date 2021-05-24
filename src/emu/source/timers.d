module timers;

import memory;
import util;

import std.stdio;

import apu;

class TimerManager {
public:
    void delegate(int) on_timer_overflow;

    this(Memory memory, void delegate(int) on_timer_overflow) {
        this.memory            = memory;
        this.on_timer_overflow = on_timer_overflow;

        timers = [
            Timer(0, 0, 0, 0, false),
            Timer(0, 0, 0, 0, false),
            Timer(0, 0, 0, 0, false),
            Timer(0, 0, 0, 0, false)
        ];
    }

    int cycle() {
        // cycle the enabled timers
        for (int i = 0; i < 4; i++) {
            if (timers[i].enabled) {
                if (timers[i].cycles_till_increment == 1) {
                    if (timers[i].timer_value == 0xFFFF) {
                        timers[i].timer_value = timers[i].reload_value;
                        // writefln("Reset Timer %x to %x", i, timers[i].timer_value);

                        on_timer_overflow(i);
                    } else {
                        timers[i].timer_value++;
                    }
                    timers[i].cycles_till_increment = timers[i].cycles_till_increment_buffer;
                } else {
                    timers[i].cycles_till_increment--;
                }
            }
        }

        // // overwrite the reload values
        // for (int i = 0; i < 4; i++) {
        //     *timers[i].cnt_l = timers[i].timer_value;
        // }

        return 0;
    }

    void reload_timer(int timer_id) {
        timers[timer_id].timer_value                  = timers[timer_id].reload_value;
        timers[timer_id].cycles_till_increment_buffer = timers[timer_id].cycles_till_increment_buffer;
    }
private:
    Memory memory;
    Timer[4] timers;

    uint[4] increments = [1, 64, 256, 1024];

    struct Timer {
        ushort  reload_value;
        ushort  timer_value;
        uint    cycles_till_increment;
        uint    cycles_till_increment_buffer;
        uint    cycles_till_increment_buffer_index;
        bool    enabled;
        bool    countup;
        bool    irq_enable;
    }

    //.......................................................................................................................
    //.RRRRRRRRRRR...EEEEEEEEEEEE....GGGGGGGGG....IIII...SSSSSSSSS...TTTTTTTTTTTTT.EEEEEEEEEEEE..RRRRRRRRRRR....SSSSSSSSS....
    //.RRRRRRRRRRRR..EEEEEEEEEEEE...GGGGGGGGGGG...IIII..SSSSSSSSSSS..TTTTTTTTTTTTT.EEEEEEEEEEEE..RRRRRRRRRRRR..SSSSSSSSSSS...
    //.RRRRRRRRRRRRR.EEEEEEEEEEEE..GGGGGGGGGGGGG..IIII..SSSSSSSSSSSS.TTTTTTTTTTTTT.EEEEEEEEEEEE..RRRRRRRRRRRR..SSSSSSSSSSSS..
    //.RRRR.....RRRR.EEEE..........GGGGG....GGGG..IIII..SSSS....SSSS.....TTTT......EEEE..........RRR.....RRRRR.SSSS....SSSS..
    //.RRRR.....RRRR.EEEE.........GGGGG......GGG..IIII..SSSS.............TTTT......EEEE..........RRR......RRRR.SSSSS.........
    //.RRRR....RRRRR.EEEEEEEEEEEE.GGGG............IIII..SSSSSSSS.........TTTT......EEEEEEEEEEEE..RRR.....RRRR..SSSSSSSS......
    //.RRRRRRRRRRRR..EEEEEEEEEEEE.GGGG....GGGGGGG.IIII..SSSSSSSSSSS......TTTT......EEEEEEEEEEEE..RRRRRRRRRRRR...SSSSSSSSSS...
    //.RRRRRRRRRRRR..EEEEEEEEEEEE.GGGG....GGGGGGG.IIII....SSSSSSSSS......TTTT......EEEEEEEEEEEE..RRRRRRRRRRRR....SSSSSSSSSS..
    //.RRRRRRRRRRR...EEEE.........GGGG....GGGGGGG.IIII........SSSSSS.....TTTT......EEEE..........RRRRRRRRRR..........SSSSSS..
    //.RRRR..RRRRR...EEEE.........GGGGG......GGGG.IIII...SS.....SSSS.....TTTT......EEEE..........RRR...RRRRR....SS.....SSSS..
    //.RRRR...RRRR...EEEE..........GGGGG....GGGGG.IIII.ISSSS....SSSS.....TTTT......EEEE..........RRR....RRRR...SSSS....SSSS..
    //.RRRR...RRRRR..EEEEEEEEEEEEE.GGGGGGGGGGGGGG.IIII.ISSSSSSSSSSSS.....TTTT......EEEEEEEEEEEEE.RRR....RRRRR..SSSSSSSSSSSS..
    //.RRRR....RRRRR.EEEEEEEEEEEEE..GGGGGGGGGGGG..IIII..SSSSSSSSSSS......TTTT......EEEEEEEEEEEEE.RRR.....RRRRR.SSSSSSSSSSSS..
    //.RRRR.....RRRR.EEEEEEEEEEEEE...GGGGGGGGG....IIII...SSSSSSSSS.......TTTT......EEEEEEEEEEEEE.RRR.....RRRRR..SSSSSSSSSS...

public:
    void write_TMXCNT_L(int target_byte, ubyte data, int x) {
        final switch (target_byte) {
            case 0b0: timers[x].reload_value = (timers[x].reload_value & 0xFF00) | (data << 0); break;
            case 0b1: timers[x].reload_value = (timers[x].reload_value & 0x00FF) | (data << 8); break;
        }
    }

    void write_TMXCNT_H(int target_byte, ubyte data, int x) {
        final switch (target_byte) {
            case 0b0: 
                timers[x].cycles_till_increment_buffer       = increments[get_nth_bits(data, 0, 2)];
                timers[x].cycles_till_increment_buffer_index = get_nth_bits(data, 0, 2);
                timers[x].countup                            = get_nth_bit (data, 2);
                timers[x].irq_enable                         = get_nth_bit (data, 6);

                // are we enabling the timer?
                if (!timers[x].enabled && get_nth_bit(data, 7)) {
                    reload_timer(x);
                    timers[x].enabled = true;
                }

                break;
            case 0b1: 
                break;
        }
    }

    ubyte read_TMXCNT_L(int target_byte, int x) {
        final switch (target_byte) {
            case 0b0: return             (timers[x].timer_value & 0x00FF) >> 0;
            case 0b1: return cast(ubyte) (timers[x].timer_value & 0xFF00) >> 4;
        }
    }

    ubyte read_TMXCNT_H(int target_byte, int x) {
        final switch (target_byte) {
            case 0b0: 
                return cast(ubyte) ((timers[x].cycles_till_increment_buffer_index << 0) | 
                                    (timers[x].countup                            << 2) |
                                    (timers[x].irq_enable                         << 6) |
                                    (timers[x].enabled                            << 7));
            case 0b1: 
                return 0;
        }
    }
}