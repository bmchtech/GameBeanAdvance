module scheduler;

import util;

import std.stdio;

struct Event {
    void delegate() callback;
    int             num_cycles;
	ulong           id;
    bool            completed;
}

class Scheduler {
    enum TOTAL_NUMBER_OF_EVENTS = 0x100;
    Event*[TOTAL_NUMBER_OF_EVENTS] events;
    int events_in_queue = 0;
    ulong id_counter = 0;

    this() {
        for (int i = 0; i < TOTAL_NUMBER_OF_EVENTS; i++) {
        	events[i] = new Event(null, 0, 0, false);
        }
        
        events_in_queue = 0;
    }

    ulong add_event(void delegate() callback, int num_cycles) {
        int insert_at = 0;
        for (; insert_at < events_in_queue; insert_at++) {
            if (num_cycles > events[insert_at].num_cycles) {
            	num_cycles -= events[insert_at].num_cycles;
            } else {
                events[insert_at].num_cycles -= num_cycles;
                break;
            }
        }
        
        for (int i = events_in_queue; i > insert_at; i--) {
            *events[i] = *events[i - 1];
        }
        
        id_counter++;
        events_in_queue++;
        *events[insert_at] = Event(callback, num_cycles, id_counter, false);
        
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
        
        events[remove_at + 1].num_cycles += events[remove_at].num_cycles;
        
        for (int i = remove_at; i < events_in_queue; i++) {
            *events[i] = *events[i + 1];
        }
        
        events_in_queue--;
    }

    Event remove_schedule_item() {
        Event return_val = *events[0];
        
        for (int i = 0; i < events_in_queue; i++) {
            *events[i] = *events[i + 1];
        }
        
        events_in_queue--;
        return return_val;
    }

    void print_schedule() {
        writefln("Schedule:");
        for (int i = 0; i < events_in_queue; i++) {
            writefln("%d", events[i].num_cycles);
        }
    }
}