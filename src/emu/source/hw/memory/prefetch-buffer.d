module hw.memory.prefetch_buffer;

import util;
import hw.memory;
import abstracthw.memory;

import std.stdio;

class PrefetchBuffer {
    private uint       current_buffer_size;
    private Memory     memory;
    private uint       current_address;
    private uint       cycles_till_access_complete;
    private bool       currently_prefetching;
    private bool       enabled;
    private AccessSize prefetch_access_size;

    this(Memory memory) {
        this.memory                      = memory;
        this.current_buffer_size         = 0;
        this.current_address             = 0;
        this.cycles_till_access_complete = 0;
        this.currently_prefetching       = false;
        this.enabled                     = false;
    }

    pragma(inline, true) void run(uint num_cycles) {
        if (!this.enabled || !this.currently_prefetching) return;
        writefln("Running for %x. %x remaining.", num_cycles, this.cycles_till_access_complete);

        while (this.current_buffer_size < 8 && num_cycles >= cycles_till_access_complete) {
            num_cycles -= cycles_till_access_complete;
        
            uint increment = this.prefetch_access_size == AccessSize.HALFWORD ? 1 : 2;
            this.current_buffer_size += increment;
            start_new_prefetch(current_address + increment, this.prefetch_access_size);
            writefln("advancing.");
        }

        if (this.current_buffer_size < 8) {
            cycles_till_access_complete -= num_cycles;
        }
    }

    pragma(inline, true) void invalidate() {
        this.current_buffer_size   = 0;
        this.currently_prefetching = false;
    }
    
    pragma(inline, true) void start_new_prefetch(uint address, AccessSize prefetch_access_size) {
        if (!enabled) return;

        this.currently_prefetching = true;

        uint current_region       = memory.get_region(address << 1);
        this.current_address      = address;
        this.prefetch_access_size = prefetch_access_size;

        this.cycles_till_access_complete = memory.waitstates[current_region][AccessType.SEQUENTIAL][prefetch_access_size];
        writefln("%x %x", address << 1, this.cycles_till_access_complete);
    }

    pragma(inline, true) T request_data_from_rom(T)(uint address, AccessType access_type) {
        uint masked_address = address & 0xFF_FFFF;

        if (this.enabled && this.currently_prefetching) {
            uint address_head = this.current_address - this.current_buffer_size;
            // writefln("%x %x", shifted_address, this.current_address);

            // is the requested value currently being prefetched?
            if (address == this.current_address) {
                memory.m_cycles += this.cycles_till_access_complete;

                this.invalidate();
                if (this.prefetch_access_size == AccessSize.HALFWORD) {
                    this.start_new_prefetch(current_address + 1, this.prefetch_access_size);
                } else { //                   == AccessSize.WORD
                    this.start_new_prefetch(current_address + 2, this.prefetch_access_size);
                }

                return read!T(masked_address);
            }

            // is the requested value at the head of the prefetch buffer?
            if (this.current_buffer_size > 0 && address == address_head) {
                memory.m_cycles++;

                this.current_buffer_size--;
                return read!T(masked_address);
            }

            // oh, ok. it's not in the prefetch buffer
            this.invalidate();
            this.start_new_prefetch(current_address + 1, this.prefetch_access_size);
        }

        uint region = ((address << 1) >> 24) & 0xF;

        AccessSize access_size;
        static if (is(T == ushort)) access_size = AccessSize.HALFWORD;
        static if (is(T == uint  )) access_size = AccessSize.WORD;

        memory.m_cycles += memory.waitstates[region][access_type][access_size];
        
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
}