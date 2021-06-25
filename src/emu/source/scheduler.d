module scheduler;

import util;

import std.stdio;

struct Event {
    void delegate() callback;
    int             num_cycles;

    Event*          next;
}

class Scheduler {
    Event* head;

    this() {
        head = null;
    }

    void add_event(void delegate() callback, int num_cycles) {
        // writefln("Adding an event %d cycles away", num_cycles);

        Event* event = new Event(callback, num_cycles, null);
        if (head == null) {
            head = event;

            print_schedule();
            return;
        }

        Event* ptr  = head;
        Event* after = null;

        while (ptr != null) {
            if (event.num_cycles > ptr.num_cycles) {
                event.num_cycles -= ptr.num_cycles;
                after = ptr;
            } else {
                break;
            }

            ptr = ptr.next;
        }

        if (after == null) {
            insert_before_head(event);
        } else {
            insert_after(after, event);
        }

        // print_schedule();
    }

    void print_schedule() {
        writefln("Schedule:");
        Event* ptr = head;
        while (ptr != null) {
            writefln("%d", ptr.num_cycles);
            ptr = ptr.next;
        }
    }

    void insert_before_head(Event* event) {
        head.num_cycles -= event.num_cycles;

        event.next = head;
        head = event;
    }

    void insert_after(Event* after, Event* event) {
        if (after.next == null) {
            after.next = event;
        } else {
            event.next = after.next;
            after.next = event;

            event.next.num_cycles -= event.num_cycles;
        }
    }

    Event remove_schedule_item() {
        if (head == null) error("Scheduler ran dry.");

        Event* ret = head;
        head = head.next;

        return *ret;
    }
}