module timers;

import memory;
import util;

class TimerManager {
public:
    this(Memory memory) {
        this.memory = memory;

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
            if (!timers[i].enabled && get_nth_bit(*timers[i].cnt_h, 15)) {
                timers[i].timer_value = timers[i].reload_value;
                timers[i].enabled     = true;
                timers[i].cycles_till_increment = increments[get_nth_bits(*timers[i].cnt_h, 0, 2)];
            }
        }

        // cycle the enabled timers
        for (int i = 0; i < 4; i++) {
            if (timers[i].enabled) {
                if (timers[i].cycles_till_increment == 0) {
                    if (timers[i].timer_value == 0xFFFF) {
                        timers[i].timer_value = timers[i].reload_value;
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