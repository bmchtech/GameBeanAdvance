module scheduler;

import util;

import std.stdio;

struct Event {
    void delegate() callback;
    int             num_cycles;

    Event*          next;
    Event*          prev;
}

class Scheduler {
    Event* head;

    this() {
        head = null;
    }

    Event* add_event(void delegate() callback, int num_cycles) {
        // writefln("Adding an event %d cycles away", num_cycles);

        Event* event = new Event(callback, num_cycles, null, null);
        if (head == null) {
            head = event;
            return event;
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

        return event;
    }

    void remove_event(Event* event) {
        if (event.prev != null) {
            event.prev.next = event.next;
        } else {
            head = event.next;
        }

        if (event.next != null) {
            event.next.prev = event.prev;
        }

        event.destroy();
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
        head.prev = event;
        head = event;
    }

    void insert_after(Event* after, Event* event) {
        if (after.next == null) {
            after.next = event;
            event.prev = after;

        } else {
            event.next = after.next;
            after.next.prev = event;
            after.next = event;
            event.prev = after;

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