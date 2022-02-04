module scheduler;

import util;
import hw.cpu.arm7tdmi;
import hw.memory;

import std.stdio;

import diag.log;

struct Event {
    void delegate() callback;
    ulong           timestamp;
	ulong           id;
    bool            completed;
    bool            can_be_interleaved;
}

final class Scheduler {
    enum TOTAL_NUMBER_OF_EVENTS = 0x100;
    Event*[TOTAL_NUMBER_OF_EVENTS] events;
    int events_in_queue = 0;
    int unprocessed_head = 0;
    ulong id_counter = 0;

    ulong current_timestamp;

    Memory memory;

    this(Memory memory) {
        for (int i = 0; i < TOTAL_NUMBER_OF_EVENTS; i++) {
        	events[i] = new Event(null, 0, 0, false);
        }
        
        events_in_queue   = 0;
        current_timestamp = 0;
        
        this.memory = memory;
    }

    ulong add_event_relative_to_clock(void delegate() callback, int delta_cycles, bool can_be_interleaved = false) {
        return add_event(callback, current_timestamp + delta_cycles, can_be_interleaved);
    }

    ulong add_event_relative_to_self(void delegate() callback, int delta_cycles, bool can_be_interleaved = false) {
        return add_event(callback, events[num_events_being_processed - 1].timestamp + delta_cycles, can_be_interleaved);
    }

    private ulong add_event(void delegate() callback, ulong timestamp, bool can_be_interleaved) {

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
        *events[insert_at] = Event(callback, timestamp, id_counter, false, can_be_interleaved);
        
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

    pragma(inline, true) void fast_forward() {
        // if (!is_processing_event) {
        //     current_timestamp = events[0].timestamp;
        //     process_event();
        // }
    }

    pragma(inline, true) void tick(ulong num_cycles) {
        import ui.sdl;
        if (_g_num_log > 0) log!(LogSource.DEBUG)("Scheduler ticking for %d cycles", num_cycles);
        current_timestamp += num_cycles;
    }

    pragma(inline, true) void tick_to_next_event() {
        current_timestamp = events[0].timestamp;
    }

    void maybe_run_event(ulong event_id) {
        for (int i = num_events_being_processed; i < events_in_queue; i++) {
            if (!events[i].timestamp == current_timestamp) return;

            if (events[i].id == event_id) {
                num_events_being_processed++;
                // writefln("%x", events[i].timestamp);
                events[i].callback();
                remove_event(event_id);
                num_events_being_processed--;
            }
        }
    }

    pragma(inline, true) void process_events() {
        bool can_interleave = (num_events_being_processed > 0) ?  events[num_events_being_processed - 1].can_be_interleaved : false;
        while ((can_interleave || num_events_being_processed == 0) && current_timestamp >= events[num_events_being_processed].timestamp) process_event();
    }

    // pragma(inline, true) bool should_cycle() {
    //     return current_timestamp < events[0].timestamp;
    // }

    pragma(inline, true) ulong get_current_time() {
        return current_timestamp;
    }

    pragma(inline, true) ulong get_current_time_relative_to_cpu() {
        return current_timestamp;
    }

    pragma(inline, true) ulong get_current_time_relative_to_self() {
        return events[num_events_being_processed - 1].timestamp;
    }

    uint num_events_being_processed = 0;
    pragma(inline, true) void process_event() {
        bool can_interleave = (num_events_being_processed > 0) ? events[num_events_being_processed - 1].can_be_interleaved : true;
        if (!can_interleave) return;
        // if (num_events_being_processed > 0) error("sex");
        // print_schedule();

        num_events_being_processed++;
                // writefln("%x", events[num_events_being_processed - 1].timestamp);
        events[num_events_being_processed - 1].callback();

        for (int i = num_events_being_processed - 1; i < events_in_queue; i++) {
            *events[i] = *events[i + 1];
        }
        
        
        events_in_queue--;

        num_events_being_processed--;
    }
}