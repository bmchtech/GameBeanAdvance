module hw.memory.prefetch_buffer;

import util;
import hw.memory;
import abstracthw.memory;

class PrefetchBuffer {
    private uint[] buffer;
    private uint   buffer_index;

    private Memory memory;
    private uint   current_address;
    private uint   cycles_till_access_complete;

    this(Memory memory) {
        this.memory                      = memory;
        this.buffer                      = new uint[8];
        this.current_address             = 0;
        this.cycles_till_access_complete = 0;
    }

    pragma(inline, true) void run(uint num_cycles) {
        cycles_till_access_complete -= num_cycles;

        // are we done with a prefetch?
        while (num_cycles <= 0) {
            this.buffer[buffer_index] = current_address;

            this.current_address += 2;
            uint current_region = memory.get_region(this.current_address);

            this.cycles_till_access_complete = memory.waitstates[current_region][AccessType.SEQUENTIAL][AccessSize.HALFWORD];
            this.cycles_till_access_complete -= -num_cycles;
        }
    }

    pragma(inline, true) void invalidate() {
        this.buffer       = [];
        this.buffer_index = 0;
    }

    pragma(inline, true) ushort request_data_from_rom(T)(uint address) {
        if (address == buffer[0]) return 0;
        else                      return cycles_till_access_complete;
    }
}