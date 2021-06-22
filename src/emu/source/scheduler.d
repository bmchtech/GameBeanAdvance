module scheduler;

import std.container : DList;

struct ScheduleItem {
    void delegate() callback();
    int             num_cycles;
}

class Scheduler {
    DList!(ScheduleItem) schedule;

    this() {
        schedule = new DList!(ScheduleItem);
    }

    void add_schedule_item(void delegate() callback, int num_cycles) {
        ScheduleItem current_item = schedule.front();

        while (current_item != null) {
            if (num_cycles >= current_item.num_cycles) {
                num_cycles -= current_item(num_cycles);
            } else {
                break;
            }
        }

        ScheduleItem new_item = ScheduleItem(callback, num_cycles);

        if (current_item == null) {
            schedule.insertAfter(schedule.back(), new_item);
        } else {
            schedule.insertBefore(current_item, new_item);
        }
    }

    ScheduleItem remove_schedule_item() {
        return schedule.removeFront();
    }
}