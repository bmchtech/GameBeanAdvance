module hw.memory.prefetch_buffer;

import util;
import hw.memory;
import abstracthw.memory;

class PrefetchBuffer {
    private uint   current_buffer_size;
    private Memory memory;
    private uint   current_address;
    private uint   cycles_till_access_complete;
    public  bool   enabled;

    this(Memory memory) {
        this.memory                      = memory;
        this.current_buffer_size         = 0;
        this.current_address             = 0;
        this.cycles_till_access_complete = 0;
        this.enabled                     = false;
    }

    pragma(inline, true) void run(uint num_cycles) {
        if (!this.enabled) return;

        cycles_till_access_complete -= num_cycles;

        // are we done with a prefetch?
        while (enabled && num_cycles <= 0) {
            this.current_buffer_size++;
            if (this.current_buffer_size >= 8) this.enabled = false;

            this.current_address++;
            start_new_prefetch();
            this.cycles_till_access_complete -= -num_cycles;
        }
    }

    pragma(inline, true) void invalidate() {
        this.current_buffer_size = 0;
    }

    pragma(inline, true) void start_new_prefetch() {
        start_new_prefetch(this.current_address);
    }
    
    pragma(inline, true) void start_new_prefetch(uint address) {
        uint current_region = memory.get_region(this.current_address);

        this.cycles_till_access_complete = memory.waitstates[current_region][AccessType.SEQUENTIAL][AccessSize.HALFWORD];
    }

    pragma(inline, true) ushort request_data_from_rom(uint address, AccessType access_type) {
        if (enabled) {
            uint address_head = this.current_address - this.current_buffer_size;

            // is the requested value at the head of the prefetch buffer?
            if (this.current_address == address_head) {
                memory.m_cycles++;

                this.current_buffer_size--;
                return memory.rom.read(address);
            }

            // is the requested value currently being prefetched?
            if (this.current_address == this.current_address) {
                memory.m_cycles += this.cycles_till_access_complete;

                this.current_address++;
                this.start_new_prefetch();

                this.current_buffer_size--;
                return memory.rom.read(address);
            }

            // damn, ok. it's not in the prefetch buffer
            this.invalidate();
        }

        uint region = memory.get_region(address << 1);
        memory.m_cycles += memory.waitstates[region][access_type][AccessSize.HALFWORD];
        return memory.rom.read(address);
    }
}