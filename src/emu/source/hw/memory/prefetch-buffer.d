module hw.memory.prefetch_buffer;

import util;
import hw.memory;
import abstracthw.memory;

        import hw.cpu;
import std.stdio;

class PrefetchBuffer {
    private uint       current_buffer_size;
    private Memory     memory;
    private uint       current_address;
    public  uint       cycles_till_access_complete;
    public  bool       currently_prefetching;
    private bool       enabled;
    private bool       paused;
    private AccessSize prefetch_access_size;
    private bool       new_prefetch;
    private uint       halfway_marker;
    private bool       bubble_exists;
    public  bool       can_start_new_prefetch;
    public  bool       prefetch_buffer_has_run = false;
    

    this(Memory memory) {
        this.memory                      = memory;
        this.current_buffer_size         = 0;
        this.current_address             = 0;
        this.cycles_till_access_complete = 0;
        this.currently_prefetching       = false;
        this.enabled                     = false;
        this.new_prefetch                = false;
        this.can_start_new_prefetch      = false;
        this.bubble_exists               = false;
    }


    pragma(inline, true) void run(uint num_cycles) {
        if (!this.enabled || !this.currently_prefetching || this.paused) return;
        prefetch_buffer_has_run = true;
        if (_g_num_log > 0 ) writefln("has just run");
        // writefln("running for %d, %d remaining", num_cycles, cycles_till_access_complete);
        
        while (this.current_buffer_size < 8 && num_cycles >= cycles_till_access_complete) {
            num_cycles -= cycles_till_access_complete;
        
            uint increment = this.prefetch_access_size == AccessSize.HALFWORD ? 1 : 2;
            this.current_buffer_size += increment;
            start_new_prefetch(current_address + increment, this.prefetch_access_size);
        }

        if (this.current_buffer_size < 8) {
            cycles_till_access_complete -= num_cycles;
            new_prefetch = num_cycles == 0;
        }

        // the bubble seems to exist if:
        //     THUMB: the prefetcher is ticked once, and after the tick, there is one cycle left for
        //            the prefetch to complete.
        //     ARM:   the prefetcher is ticked once, and after the tick, there is one cycle left for
        //            the prefetch of either halfword of the full word to complete. this is what the
        //            variable halfway_marker is used for.
        
        bubble_exists = (num_cycles == 1) && 
            (this.prefetch_access_size == AccessSize.HALFWORD && (cycles_till_access_complete == 1)) || 
            (this.prefetch_access_size == AccessSize.WORD     && (cycles_till_access_complete == 1 || cycles_till_access_complete == halfway_marker + 1));
    }

    pragma(inline, true) void finish_current_prefetch() {
        run(cycles_till_access_complete);
    }

    pragma(inline, true) void invalidate() {
        if (this.paused) return;
            if (_g_num_log > 0 )writefln("INVALID %d", cycles_till_access_complete);

        this.current_buffer_size   = 0;
        this.currently_prefetching = false;
    }
    
    pragma(inline, true) void start_new_prefetch(uint address, AccessSize prefetch_access_size) {
        if (!enabled || paused) return;

        this.currently_prefetching = true;
        this.new_prefetch = true;

        uint current_region       = memory.get_region(address << 1);
        this.current_address      = address;
        this.prefetch_access_size = prefetch_access_size;

        this.cycles_till_access_complete = memory.waitstates[current_region][AccessType.SEQUENTIAL][prefetch_access_size];
        this.halfway_marker              = this.cycles_till_access_complete >> 1;
        // writefln("%x %x", address << 1, this.cycles_till_access_complete);
    }

    pragma(inline, true) T request_data_from_rom(T)(uint address, AccessType access_type, bool instruction_access) {
        uint masked_address = address & 0xFF_FFFF;
        prefetch_buffer_has_run = false;
        if (_g_num_log > 0 ) writefln("has not jsut run :(");

        if (!instruction_access && bubble_exists) { 
            bubble_exists = false; 
            memory.scheduler.tick(1);
        }


        if ((address & 0xFFFF) == 0) {
            access_type = AccessType.NONSEQUENTIAL;
        } 

        if (!paused && this.enabled) {
            uint address_head = this.current_address - this.current_buffer_size;

            // is the requested value currently being prefetched?
            if (address == this.current_address) {
                memory.scheduler.tick(this.cycles_till_access_complete);

                this.invalidate();
                if (this.prefetch_access_size == AccessSize.HALFWORD) {
                    this.start_new_prefetch(current_address + 1, this.prefetch_access_size);
                } else { //                   == AccessSize.WORD
                    this.start_new_prefetch(current_address + 2, this.prefetch_access_size);
                }
                this.can_start_new_prefetch = false;

                return read!T(masked_address);
            }

            // is the requested value at the head of the prefetch buffer?
            if (this.current_buffer_size > 0 && address == address_head) {
                this.current_buffer_size -= this.prefetch_access_size == AccessSize.HALFWORD ? 1 : 2;
                run(1);
                memory.scheduler.tick(1);
                this.can_start_new_prefetch = false;

                return read!T(masked_address);
            }

            // oh, ok. it's not in the prefetch buffer
            this.invalidate();
            this.start_new_prefetch(current_address + 1, this.prefetch_access_size);
            this.can_start_new_prefetch = true;
        }

        uint region = ((address << 1) >> 24) & 0xF;

        AccessSize access_size;
        static if (is(T == ushort)) access_size = AccessSize.HALFWORD;
        static if (is(T == uint  )) access_size = AccessSize.WORD;

        memory.scheduler.tick(memory.waitstates[region][access_type][access_size]);
        
        this.currently_prefetching = true;

        return read!T(masked_address);
    }

    private T read(T)(uint address) {
        static if (is(T == ushort)) return memory.rom.read(address);
        static if (is(T == uint  )) return ((memory.rom.read(address + 1) << 16) | 
                                             memory.rom.read(address));
    }

    void set_enabled(bool enabled) {
        // if(_g_print) writefln("Enabled: %x", enabled);
        if (!this.enabled && enabled) {
            this.invalidate();
        }

        this.enabled = enabled;
    }

    void pause() {
        // why???
        run(2);

        this.paused = true;
    }

    void resume() {
        this.paused = false;
    }

    pragma(inline, true) void pop_bubble() {
        this.bubble_exists = false;
    }
}