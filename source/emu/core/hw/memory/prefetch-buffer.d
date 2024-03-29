module hw.memory.prefetch_buffer;

import util;
import hw.memory;
import abstracthw.memory;

import hw.cpu;
import diag.log;
import std.stdio;

import hw.gpio.rtc;

final class PrefetchBuffer {
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

    private RTC_S_35180 rtc;
    

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

        this.rtc                         = new RTC_S_35180();
    }


    uint sussy;
    pragma(inline, true) void run(uint num_cycles) {
        if (!this.enabled || !this.currently_prefetching || this.paused) return;
        if (_g_num_log > 0) log!(LogSource.DEBUG)("Prefetch buffer running for %d cycles. %d / %d remaining till access complete", num_cycles, cycles_till_access_complete, sussy);

        prefetch_buffer_has_run = true;
        
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
        //            the prefetch of either half of the full word to complete. this is what the
        //            variable halfway_marker is used for.
        
        bubble_exists =
            (this.prefetch_access_size == AccessSize.HALFWORD && (cycles_till_access_complete == 1)) || 
            (this.prefetch_access_size == AccessSize.WORD     && (cycles_till_access_complete == 1 || cycles_till_access_complete == halfway_marker + 1));
    
    
        if (_g_num_log > 0) if (bubble_exists) log!(LogSource.DEBUG)("Blowing a bubble...", num_cycles, cycles_till_access_complete);
    }

    pragma(inline, true) void finish_current_prefetch() {
        if (_g_num_log > 0) log!(LogSource.DEBUG)("Finishing prefetch.");
        bool was_paused = this.paused;
        this.paused = false;
        run(cycles_till_access_complete);

        // import ui.device.video.sdl.sdl;
        tick(cycles_till_access_complete);
        memory.maybe_accumulate_dma_cycles(cycles_till_access_complete);

        this.paused = was_paused;
    }

    pragma(inline, true) void invalidate() {
        if (this.paused) return;
        // if (_g_num_log > 0) writefln("invalidated");

        this.current_buffer_size   = 0;
        this.currently_prefetching = false;
    }
    
    pragma(inline, true) void start_new_prefetch(uint address, AccessSize prefetch_access_size, bool first = false) {
        if (!enabled || paused) return;

        this.currently_prefetching = true;
        this.new_prefetch = true;

        uint current_region       = memory.get_region(address << 1);
        this.current_address      = address;
        this.prefetch_access_size = prefetch_access_size;

        this.cycles_till_access_complete = memory.waitstates[current_region][first ? AccessType.NONSEQUENTIAL : AccessType.SEQUENTIAL][prefetch_access_size];
        this.halfway_marker              = this.cycles_till_access_complete >> 1;
        sussy = this.cycles_till_access_complete;
    }

    enum GPIO_PORT_DATA    = 0x0800_00C4;
    enum GPIO_PORT_DIR     = 0x0800_00C6;
    enum GPIO_PORT_CONTROL = 0x0800_00C8;

    pragma(inline, true) void write(T)(uint address, T value, AccessType access_type) {

        uint masked_address = address & 0xFF_FFFF;
        // if (_g_num_log > 0) log!(LogSource.DEBUG)("Requesting data from ROM at address %x. [%s, %s]", address, instruction_access ? "Instruction" : "Data", access_type == AccessType.NONSEQUENTIAL ? "Nonsequential" : "Sequential");
        prefetch_buffer_has_run = false;

        if (bubble_exists) {
            log!(LogSource.DEBUG)("Popping the bubble...");
            tick(1);
            memory.maybe_accumulate_dma_cycles(1);
            cycles_till_access_complete--;
        }

        bubble_exists = false;

        if ((address & 0xFFFF) == 0) {
            access_type = AccessType.NONSEQUENTIAL;
        } 

        this.invalidate();
        this.start_new_prefetch(current_address + 1, this.prefetch_access_size);
        this.can_start_new_prefetch = true;

        uint region = ((address << 1) >> 24) & 0xF;

        AccessSize access_size;
        static if (is(T == ushort)) access_size = AccessSize.HALFWORD;
        static if (is(T == uint  )) access_size = AccessSize.WORD;

        tick(memory.waitstates[region][access_type][access_size]);
        memory.maybe_accumulate_dma_cycles(memory.waitstates[region][access_type][access_size]);
    }

    bool sussy_baka = false;
    pragma(inline, true) T request_data_from_rom(T)(uint address, AccessType access_type, bool instruction_access) {
        // if (address << 1 == GPIO_PORT_DATA) {
        //     return rtc.read();
        // }
        sussy_baka = true;
        
        uint masked_address = address & 0xFF_FFFF;
        if (_g_num_log > 0) log!(LogSource.DEBUG)("Requesting data from ROM at address %x. [%s, %s]", address, instruction_access ? "Instruction" : "Data", access_type == AccessType.NONSEQUENTIAL ? "Nonsequential" : "Sequential");
        prefetch_buffer_has_run = false;

        if (!instruction_access && bubble_exists) {
            log!(LogSource.DEBUG)("Popping the bubble...");
            tick(1);
            memory.maybe_accumulate_dma_cycles(1);
            cycles_till_access_complete--;
        }

        bubble_exists = false;

        if ((address & 0xFFFF) == 0) {
            access_type = AccessType.NONSEQUENTIAL;
        } 

        if (!instruction_access) {
            this.invalidate();
            this.start_new_prefetch(current_address + 1, this.prefetch_access_size);
            this.can_start_new_prefetch = true;
        }

        if (instruction_access && !paused && this.enabled) {
            bubble_exists = false; 
            uint address_head = this.current_address - this.current_buffer_size;

            if (currently_prefetching) {
                // is the requested value currently being prefetched?
                if (address == this.current_address) {
                    if (_g_num_log > 0) log!(LogSource.DEBUG)("Obtaining data from current prefetch.");
                    tick(this.cycles_till_access_complete);
                    memory.maybe_accumulate_dma_cycles(this.cycles_till_access_complete);

                    this.invalidate();
                    if (this.prefetch_access_size == AccessSize.HALFWORD) {
                        this.start_new_prefetch(current_address + 1, this.prefetch_access_size);
                    } else { //                   == AccessSize.WORD
                        this.start_new_prefetch(current_address + 2, this.prefetch_access_size);
                    }
                    this.can_start_new_prefetch = false;

                    sussy_baka = false;
                    return read!T(masked_address);
                }

                // is the requested value at the head of the prefetch buffer?
                if (this.current_buffer_size > 0 && address == address_head) {
                    // if (_g_num_log > 0) log!(LogSource.DEBUG)("Obtaining data from prefetch head.");
                    this.current_buffer_size -= this.prefetch_access_size == AccessSize.HALFWORD ? 1 : 2;
                    run(1);
                    tick(1);
                    memory.maybe_accumulate_dma_cycles(1);
                    this.can_start_new_prefetch = false;

                    sussy_baka = false;
                    return read!T(masked_address);
                }

                // oh, ok. it's not in the prefetch buffer
                // if (_g_num_log > 0) log!(LogSource.DEBUG)("Data missing from prefetch buffer.");
                this.invalidate();
                this.start_new_prefetch(current_address + 1, this.prefetch_access_size);
                this.can_start_new_prefetch = true;
            } else {
                this.start_new_prefetch(current_address + 1, this.prefetch_access_size, true);
            }
        }

        uint region = ((address << 1) >> 24) & 0xF;

        AccessSize access_size;
        static if (is(T == ushort)) access_size = AccessSize.HALFWORD;
        static if (is(T == uint  )) access_size = AccessSize.WORD;

        tick(memory.waitstates[region][access_type][access_size]);
        memory.maybe_accumulate_dma_cycles(memory.waitstates[region][access_type][access_size]);

        sussy_baka = false;
        return read!T(masked_address);
    }

    private T read(T)(uint address) {
        static if (is(T == ushort)) return memory.rom.read(address);
        static if (is(T == uint  )) return ((memory.rom.read(address + 1) << 16) | 
                                             memory.rom.read(address));
    }

    void set_enabled(bool enabled) {
        if (!this.enabled && enabled) {
            this.invalidate();
        }

        this.enabled = enabled;
    }

    void pause() {
        this.paused = true;
    }

    void resume() {
        this.paused = false;
    }

    int cycles_ticked = 0;
    void tick(int num_cycles) {
        memory.scheduler.tick(num_cycles);
    }

    pragma(inline, true) void pop_bubble() {
        this.bubble_exists = false;
    }
}