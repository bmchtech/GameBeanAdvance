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
            Timer(
                memory.TM0CNT_L,
                memory.TM0CNT_H,
                0, 0, 0, false
            ),
            Timer(
                memory.TM1CNT_L,
                memory.TM1CNT_H,
                0, 0, 0, false
            ),
            Timer(
                memory.TM2CNT_L,
                memory.TM2CNT_H,
                0, 0, 0, false
            ),
            Timer(
                memory.TM3CNT_L,
                memory.TM3CNT_H,
                0, 0, 0, false
            )
        ];
    }

    void cycle() {
        // sync the reload values
        for (int i = 0; i < 4; i++) {
            timers[i].reload_value = *timers[i].cnt_l;
        }

        // were any timers enabled?
        for (int i = 0; i < 4; i++) {
            if (!timers[i].enabled && timers[i].reload_value != 0) {
                timers[i].timer_value = timers[i].reload_value;
                timers[i].enabled     = true;
                timers[i].cycles_till_increment = increments[get_nth_bits(*timers[i].cnt_h, 0, 2)];

                writefln("Timer %x enabled.", i);
            }
        }

        // cycle the enabled timers
        for (int i = 0; i < 4; i++) {
            if (timers[i].enabled) {
                if (timers[i].cycles_till_increment == 0) {
                    if (timers[i].timer_value == 0xFFFF) {
                        timers[i].timer_value = timers[i].reload_value;

                        on_timer_overflow(i);
                    } else {
                        timers[i].timer_value++;
                    }
                    timers[i].cycles_till_increment = increments[get_nth_bits(*timers[i].cnt_h, 0, 2)];
                } else {
                    timers[i].cycles_till_increment--;
                }
            }
        }

        // overwrite the reload values
        for (int i = 0; i < 4; i++) {
            *timers[i].cnt_l = timers[i].timer_value;
        }
    }
private:
    Memory memory;
    Timer[4] timers;

    uint[4] increments = [1, 64, 256, 1024];
}

struct Timer {
    ushort* cnt_l;
    ushort* cnt_h;

    ushort  reload_value;
    ushort  timer_value;
    uint    cycles_till_increment;
    bool    enabled;
}