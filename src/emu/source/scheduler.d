module scheduler;

import util;

import std.stdio;

struct Event {
    void delegate() callback;
    ulong           timestamp;
	ulong           id;
    bool            completed;
}

class Scheduler {
    enum TOTAL_NUMBER_OF_EVENTS = 0x100;
    Event*[TOTAL_NUMBER_OF_EVENTS] events;
    int events_in_queue = 0;
    ulong id_counter = 0;

    ulong current_timestamp;

    this() {
        for (int i = 0; i < TOTAL_NUMBER_OF_EVENTS; i++) {
        	events[i] = new Event(null, 0, 0, false);
        }
        
        events_in_queue      = 0;
        current_timestamp = 0;
    }

    ulong add_event_relative_to_clock(void delegate() callback, int delta_cycles) {
        return add_event(callback, current_timestamp + delta_cycles);
    }

    ulong add_event_relative_to_self(void delegate() callback, int delta_cycles) {
        return add_event(callback, events[0].timestamp + delta_cycles);
    }

    private ulong add_event(void delegate() callback, ulong timestamp) {
        // writefln("Inserting event at %x + %x", events[0].timestamp, current_timestamp);

        int insert_at;
        // TODO: use binary search
        for (; insert_at < events_in_queue; insert_at++) {
            if (timestamp < events[insert_at].timestamp) {
            	break;
            }
        }
        
        for (int i = events_in_queue; i > insert_at; i--) {
            *events[i] = *events[i - 1];
        }
        
        id_counter++;
        events_in_queue++;
        *events[insert_at] = Event(callback, timestamp, id_counter, false);
        
        return id_counter;
    }

    void remove_event(ulong event_id) {
        int remove_at = -1;
        for (int i = 0; i < events_in_queue; i++) {
            if (events[i].id == event_id) {
            	remove_at = i;
                break;
            }
        }

        if (remove_at == -1) return;
        
        for (int i = remove_at; i < events_in_queue; i++) {
            *events[i] = *events[i + 1];
        }
        
        events_in_queue--;
    }

    void print_schedule() {
        writefln("Schedule:");
        for (int i = 0; i < events_in_queue; i++) {
            writefln("%d", events[i].timestamp);
        }
    }

    pragma(inline, true) void tick(ulong num_cycles) {
        current_timestamp += num_cycles;
    }

    pragma(inline, true) bool should_cycle() {
        return current_timestamp < events[0].timestamp;
    }

    pragma(inline, true) ulong get_current_time() {
        return events[0].timestamp;
    }

    pragma(inline, true) void process_event() {
        events[0].callback();

        for (int i = 0; i < events_in_queue; i++) {
            *events[i] = *events[i + 1];
        }
        
        events_in_queue--;
    }
}