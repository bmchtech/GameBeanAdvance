module hw.memory.prefetch_buffer;

import util;
import hw.memory;
import abstracthw.memory;

import std.stdio;

bool _g_print = false;

class PrefetchBuffer {
    private uint   current_buffer_size;
    private Memory memory;
    private uint   current_address;
    private uint   cycles_till_access_complete;
    private bool   currently_prefetching;
    private bool   enabled;

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

        while (this.current_buffer_size < 8 && num_cycles >= cycles_till_access_complete) {
            num_cycles -= cycles_till_access_complete;
        
            this.current_buffer_size++;
            start_new_prefetch(current_address + 1);
        }

        if (this.current_buffer_size < 8) {
            cycles_till_access_complete -= num_cycles;
        }
    }

    pragma(inline, true) void invalidate() {
        this.current_buffer_size   = 0;
        this.currently_prefetching = false;
    }

    pragma(inline, true) void start_new_prefetch() {
        start_new_prefetch(this.current_address);
    }
    
    pragma(inline, true) void start_new_prefetch(uint address) {
        if (!enabled) return;

        this.currently_prefetching = true;

        uint current_region = memory.get_region(address << 1);
        this.current_address = address;

        this.cycles_till_access_complete = memory.waitstates[current_region][AccessType.SEQUENTIAL][AccessSize.HALFWORD];
        // writefln("%x", this.cycles_till_access_complete);
    }

    pragma(inline, true) ushort request_data_from_rom(uint address, AccessType access_type) {
        if (this.enabled && this.currently_prefetching) {
            uint address_head = this.current_address - this.current_buffer_size;
            if (_g_print) writefln("%x %x %x %x", this.current_address << 1, this.current_buffer_size, address << 1, cycles_till_access_complete);

            // is the requested value currently being prefetched?
            if (address == this.current_address) {
                memory.m_cycles += this.cycles_till_access_complete;

                this.invalidate();
                this.start_new_prefetch(current_address + 1);

                return memory.rom.read(address);
            }

            // is the requested value at the head of the prefetch buffer?
            if (this.current_buffer_size > 0 && address == address_head) {
                memory.m_cycles++;

                this.current_buffer_size--;
                if (_g_print) writefln("FUCKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKK");
                return memory.rom.read(address);
            }

            // oh, ok. it's not in the prefetch buffer
            this.invalidate();
            this.start_new_prefetch(current_address + 1);
        }

        uint region = memory.get_region(address << 1);
        memory.m_cycles += memory.waitstates[region][access_type][AccessSize.HALFWORD];
        
        this.currently_prefetching = true;

        return memory.rom.read(address);
    }

    void set_enabled(bool enabled) {
        if(_g_print) writefln("Enabled: %x", enabled);
        if (!this.enabled && enabled) {
            this.invalidate();
        }

        this.enabled = enabled;
    }
}