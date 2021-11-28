module hw.timers;

import hw.memory;
import hw.apu;
import hw.gba;
import hw.cpu;
import hw.interrupts;

import util;
import scheduler;

import std.stdio;
class TimerManager {
public:
    void delegate(int)  on_timer_overflow;
    void delegate(uint) interrupt_cpu;

    Scheduler scheduler;
    GBA gba;

    this(Memory memory, Scheduler scheduler, GBA gba, void delegate(uint) interrupt_cpu, void delegate(int) on_timer_overflow) {
        this.memory            = memory;
        this.interrupt_cpu     = interrupt_cpu;
        this.on_timer_overflow = on_timer_overflow;

        timers = [
            Timer(),
            Timer(),
            Timer(),
            Timer()
        ];

        this.scheduler = scheduler;
        this.gba       = gba;
    }

    void reload_timer(int timer_id) {
        // check for cancellation
        if (!timers[timer_id].enabled || timers[timer_id].countup) return;

        timers[timer_id].enabled_for_first_time = false;
        timers[timer_id].value = timers[timer_id].reload_value;
        ulong timestamp = scheduler.get_current_time_relative_to_self();
        // writeln(format("%x TS: %x. Scheduling another at %x", timer_id, timestamp, timestamp + ((0x10000 - timers[timer_id].reload_value) << timers[timer_id].increment)));
        timers[timer_id].timer_event = scheduler.add_event_relative_to_self(() => timer_overflow(timer_id), (0x10000 - timers[timer_id].reload_value) << timers[timer_id].increment);

        timers[timer_id].timestamp = scheduler.get_current_time_relative_to_self();
    }


    void reload_timer_for_the_first_time(int timer_id) {
        if (timers[timer_id].countup) return;

        timers[timer_id].enabled_for_first_time = true;
        timers[timer_id].value = timers[timer_id].reload_value;
        writefln("Set timer at %x %x", scheduler.get_current_time_relative_to_cpu(), scheduler.get_current_time_relative_to_cpu());
        timers[timer_id].timer_event = scheduler.add_event_relative_to_clock(() => timer_overflow(timer_id), 2 + ((0x10000 - timers[timer_id].reload_value) << timers[timer_id].increment));
        timers[timer_id].timestamp = scheduler.get_current_time_relative_to_cpu() + 2;
    }

    void timer_overflow(int x) {
        reload_timer(x);
        on_timer_overflow(x);
                    // writefln("[%x] youre interrupted", scheduler.get_current_time_relative_to_cpu());
        if (timers[x].irq_enable) interrupt_cpu(get_interrupt_from_timer_id(x));

        // if the next timer is a slave (countup), then increment it
        if (x < 3 && timers[x + 1].countup) {
            if (timers[x + 1].value == 0xFFFF) timer_overflow(x + 1);
            else timers[x + 1].value++;
        }
    }

    Interrupt get_interrupt_from_timer_id(int x) {
        final switch (x) {
            case 0: return Interrupt.TIMER_0_OVERFLOW;
            case 1: return Interrupt.TIMER_1_OVERFLOW;
            case 2: return Interrupt.TIMER_2_OVERFLOW;
            case 3: return Interrupt.TIMER_3_OVERFLOW;
        }
    }

    ushort calculate_timer_value(int x) {
        // am i enabled? if not just return without calculation
        // also, if i'm countup, then im a slave timer. timers[x - 1] will
        // control my value instead
        
        if (!timers[x].enabled || timers[x].countup) return timers[x].value;

        // how many clock cycles has it been since we've been enabled?
        ulong cycles_elapsed = scheduler.get_current_time_relative_to_cpu() - timers[x].timestamp;
        // writefln("Subtracting: %x %x %x", cycles_elapsed, scheduler.get_current_time_relative_to_cpu(), timers[x].timestamp);

        // use timer increments to get the relevant bits, and mod by the reload value
        return cast(ushort) (cycles_elapsed >> timers[x].increment);
    }
    
private:
    Memory memory;
    Timer[4] timers;

    uint[4] increment_shifts = [0, 6, 8, 10];

    struct Timer {
        ushort  reload_value;
        ushort  value;
        int     increment;
        int     increment_index;
        bool    enabled;
        bool    countup;
        bool    irq_enable;
        bool    enabled_for_first_time;

        ulong   timestamp;

        ulong   timer_event;
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
                timers[x].increment_index = get_nth_bits(data, 0, 2);
                timers[x].increment  = increment_shifts[get_nth_bits(data, 0, 2)];
                timers[x].countup    = get_nth_bit (data, 2);
                timers[x].irq_enable = get_nth_bit (data, 6);

                // are we enabling the timer?
                if (!timers[x].enabled && get_nth_bit(data, 7)) {
                    writefln("[%x] youre disabled %x", scheduler.get_current_time_relative_to_cpu(), timers[x].reload_value);
                    timers[x].enabled = true;

                    if (timers[x].timer_event != 0) scheduler.remove_event(timers[x].timer_event);

                    timers[x].value = timers[x].reload_value;
                    reload_timer_for_the_first_time(x);
                }

                if (!get_nth_bit(data, 7)) {
                    timers[x].enabled = false;
                    scheduler.remove_event(timers[x].timer_event);
                }

                break;
            case 0b1: 
                break;
        }
    }

    ubyte read_TMXCNT_L(int target_byte, int x) {
        timers[x].value = calculate_timer_value(x);
        
        final switch (target_byte) {
            case 0b0: return (timers[x].value >> 0) & 0xFF;
            case 0b1: return (timers[x].value >> 8) & 0xFF;
        }
    }

    ubyte read_TMXCNT_H(int target_byte, int x) {
        final switch (target_byte) {
            case 0b0: 
                return cast(ubyte) ((timers[x].increment_index  << 0) | 
                                    (timers[x].countup          << 2) |
                                    (timers[x].irq_enable       << 6) |
                                    (timers[x].enabled          << 7));
            case 0b1: 
                return 0;
        }
    }
}