module timers;

import memory;
import util;

import std.stdio;

import apu;
import gba;
import scheduler;

class TimerManager {
public:
    void delegate(int) on_timer_overflow;

    Scheduler scheduler;
    GBA gba;

    this(Memory memory, Scheduler scheduler, GBA gba, void delegate(int) on_timer_overflow) {
        this.memory            = memory;
        this.on_timer_overflow = on_timer_overflow;

        timers = [
            Timer(0, 0, 0, 0, false),
            Timer(0, 0, 0, 0, false),
            Timer(0, 0, 0, 0, false),
            Timer(0, 0, 0, 0, false)
        ];

        this.scheduler = scheduler;
        this.gba       = gba;
    }

    void reload_timer(int timer_id) {
        if (!timers[timer_id].enabled) return;

        timers[timer_id].value = timers[timer_id].reload_value;
        scheduler.add_event(() => timer_overflow(timer_id), (0x10000 - timers[timer_id].reload_value) << timers[timer_id].increment);

        timers[timer_id].timestamp = gba.num_cycles;
    }

    void timer_overflow(int x) {
        reload_timer(x);
        on_timer_overflow(x);  
    }

    ushort calculate_timer_value(int x) {
        // am i enabled? if not just return without calculation
        if (!timers[x].enabled) return timers[x].value;

        // how many clock cycles has it been since we've been enabled?
        ulong cycles_elapsed = timers[x].timestamp - gba.num_cycles;

        // use timer increments to get the relevant bits, and mod by the reload value
        return cast(ushort) (cycles_elapsed >> timers[x].increment);
    }
    
private:
    Memory memory;
    Timer[4] timers;

    uint[4] increment_shifts = [1, 6, 8, 10];

    struct Timer {
        ushort  reload_value;
        ushort  value;
        int     increment;
        bool    enabled;
        bool    countup;
        bool    irq_enable;

        ulong   timestamp;
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
                timers[x].increment  = increment_shifts[get_nth_bits(data, 0, 2)];
                timers[x].countup    = get_nth_bit (data, 2);
                timers[x].irq_enable = get_nth_bit (data, 6);

                // are we enabling the timer?
                if (!timers[x].enabled && get_nth_bit(data, 7)) {
                    writefln("Enabled timer %x", x);
                    timers[x].enabled = true;
                    reload_timer(x);
                }

                if (!get_nth_bit(data, 7)) {
                    writefln("Disabled timer %x", x);
                    timers[x].enabled = false;
                    timers[x].value   = calculate_timer_value(x);
                }

                break;
            case 0b1: 
                break;
        }
    }

    ubyte read_TMXCNT_L(int target_byte, int x) {
        timers[x].value = calculate_timer_value(x);
        
        final switch (target_byte) {
            case 0b0: return             (timers[x].value & 0x00FF) >> 0;
            case 0b1: return cast(ubyte) (timers[x].value & 0xFF00) >> 4;
        }
    }

    ubyte read_TMXCNT_H(int target_byte, int x) {
        final switch (target_byte) {
            case 0b0: 
                return cast(ubyte) ((timers[x].increment  << 0) | 
                                    (timers[x].countup    << 2) |
                                    (timers[x].irq_enable << 6) |
                                    (timers[x].enabled    << 7));
            case 0b1: 
                return 0;
        }
    }
}