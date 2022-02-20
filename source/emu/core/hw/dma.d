module hw.dma;

import hw.memory;
import abstracthw.memory;
import hw.gba;
import hw.apu;
import hw.interrupts;
import hw.cpu;

import diag.log;

import util;
import scheduler;

import std.stdio;

import core.bitop;

final class DMAManager {
public:
    void delegate(uint) interrupt_cpu;
    Scheduler scheduler;

    this(Memory memory, Scheduler scheduler, void delegate(uint) interrupt_cpu) {
        this.memory        = memory;
        this.scheduler     = scheduler;
        this.interrupt_cpu = interrupt_cpu;

        dma_channels = [
            DMAChannel(0, 0, 0, 0, 0, 0, false, false, false, false, false, false, 0, false, DestAddrMode.Increment, SourceAddrMode.Increment, DMAStartTiming.Immediately,),
            DMAChannel(0, 0, 0, 0, 0, 0, false, false, false, false, false, false, 0, false, DestAddrMode.Increment, SourceAddrMode.Increment, DMAStartTiming.Immediately),
            DMAChannel(0, 0, 0, 0, 0, 0, false, false, false, false, false, false, 0, false, DestAddrMode.Increment, SourceAddrMode.Increment, DMAStartTiming.Immediately),
            DMAChannel(0, 0, 0, 0, 0, 0, false, false, false, false, false, false, 0, false, DestAddrMode.Increment, SourceAddrMode.Increment, DMAStartTiming.Immediately)
        ];
    }

    int dmas_available = 0;

    pragma(inline, true) void check_dma() {
        if (dmas_available > 0) {
            dmas_available--;
            handle_dma();
        }
    }

    uint num_dmas_running      = 0;

    uint dmas_running_bitfield = 0;
    uint get_highest_priority_dma_running() {
        // or with 0x10 because bsf is undefined if the input is 0
        // which causes issues in some compilations. so i get around
        // this by orring with 0x10
        return bsf(dmas_running_bitfield | 0x10);
    }

    void handle_dma() {
        // get the channel with highest priority that wants to start dma
        int current_channel = -1;
        for (int i = 0; i < 4; i++) {
            if (dma_channels[i].enabled && dma_channels[i].waiting_to_start) {
                current_channel = i;
                break;
            }
        }
        
        if (current_channel == -1) return; //error("DMA requested but no active channels found");
        
        if (get_highest_priority_dma_running() < current_channel) {
            // defer this dma to the end of the current dma
            return;
        }

        dma_channels[current_channel].waiting_to_start = false;

        bool source_beginning_in_rom = in_rom(dma_channels[current_channel].source_buf);
        bool dest_beginning_in_rom   = in_rom(dma_channels[current_channel].dest_buf);
        
        // i no longer have any idea what's going on

        memory.dma_cycle_accumulation_state = Memory.DMACycleAccumulationState.ACCUMULATE;

        if (num_dmas_running == 0) {
            // if (source_beginning_in_rom) memory.prefetch_buffer.pause();
            memory.clock(1); 
        }
        num_dmas_running++;
        dmas_running_bitfield |= (1 << current_channel);

        uint excess_cycles = memory.cycles;

        uint bytes_to_transfer  = dma_channels[current_channel].size_buf;
        int  source_increment   = 0;
        int  dest_increment     = 0;

        // if (!is_dma_channel_fifo(current_channel)) writefln("DMA Channel %x running: Transferring %x %s from %x to %x (Control: %x)",
        //          current_channel,
        //          bytes_to_transfer,
        //          dma_channels[current_channel].transferring_words ? "words" : "halfwords",
        //          dma_channels[current_channel].source_buf,
        //          dma_channels[current_channel].dest_buf,
        //          read_DMAXCNT_H(0, current_channel) | (read_DMAXCNT_H(1, current_channel) << 8));

        switch (dma_channels[current_channel].source_addr_control) {
            case SourceAddrMode.Increment:  source_increment =  1; break;
            case SourceAddrMode.Decrement:  source_increment = -1; break;
            case SourceAddrMode.Fixed:      source_increment =  0; break;
            case SourceAddrMode.Prohibited: error("Prohibited DMA Source Addr Control Used."); break;
            default: assert(0);
        }

        DestAddrMode interpretted_dest_addr_control = is_dma_channel_fifo(current_channel) ? DestAddrMode.Fixed : dma_channels[current_channel].dest_addr_control;

        switch (interpretted_dest_addr_control) {
            case DestAddrMode.Increment:       dest_increment =  1; break;
            case DestAddrMode.Decrement:       dest_increment = -1; break;
            case DestAddrMode.Fixed:           dest_increment =  0; break;
            case DestAddrMode.IncrementReload: dest_increment =  1; break;
            default: assert(0);
        }

        source_increment *= (dma_channels[current_channel].transferring_words ? 4 : 2);
        dest_increment   *= (dma_channels[current_channel].transferring_words ? 4 : 2);

        int source_offset = 0;
        int dest_offset   = 0;

        AccessType access_type = AccessType.NONSEQUENTIAL;
        bool both_in_rom = source_beginning_in_rom && dest_beginning_in_rom;

        if (dma_channels[current_channel].transferring_words || is_dma_channel_fifo(current_channel)) {
            bytes_to_transfer *= 4;
            for (int i = 0; i < bytes_to_transfer; i += 4) {
                uint read_address = dma_channels[current_channel].source_buf + source_offset;

                if (in_rom(read_address)) source_increment = 4;
                if (in_rom(read_address)) {
                    memory.prefetch_buffer.pause();
                }

                if (read_address >= 0x0200_0000) { // make sure we are not accessing DMA open bus
                    dma_channels[current_channel].open_bus_latch = memory.read_word(dma_channels[current_channel].source_buf + source_offset, access_type);
                }

                if (both_in_rom) access_type = AccessType.SEQUENTIAL;

                if (in_rom(dma_channels[current_channel].dest_buf + dest_offset)) { 
                    memory.prefetch_buffer.pause(); 
                }

                memory.write_word(dma_channels[current_channel].dest_buf + dest_offset, dma_channels[current_channel].open_bus_latch, access_type);
                source_offset += source_increment;
                dest_offset   += dest_increment;

                access_type = AccessType.SEQUENTIAL;

            }
        } else {
            bytes_to_transfer *= 2;

            for (int i = 0; i < bytes_to_transfer; i += 2) {
                uint read_address  = dma_channels[current_channel].source_buf + source_offset;
                uint write_address = dma_channels[current_channel].dest_buf   + dest_offset;
                
                bool source_is_aligned = (read_address  & 2) != 0;
                bool dest_is_aligned   = (write_address & 2) != 0;

                if (read_address >= 0x0200_0000) { // make sure we are not accessing DMA open bus
                    auto shift      = source_is_aligned * 16;

                    if (in_rom(read_address)) source_increment = 2;
                    if (in_rom(read_address)) { 
                        memory.prefetch_buffer.pause(); 
                    }

                    auto read_value = memory.read_half(read_address, access_type);

                    if (both_in_rom) access_type = AccessType.SEQUENTIAL;

                    dma_channels[current_channel].open_bus_latch = read_value | (read_value << 16);

                    if (in_rom(write_address)) { 
                        memory.prefetch_buffer.pause(); 
                    }

                    memory.write_half(write_address, read_value, access_type);
                } else {
                    auto shift = dest_is_aligned * 16;
                    ushort open_bus_value = (dma_channels[current_channel].open_bus_latch >> shift) & 0xFFFF;

                    if (both_in_rom) access_type = AccessType.SEQUENTIAL;

                    if (in_rom(write_address)) { 
                        memory.prefetch_buffer.pause(); 
                    }

                    memory.write_half(write_address, open_bus_value, access_type);
                }

                source_offset += source_increment;
                dest_offset   += dest_increment;

                access_type = AccessType.SEQUENTIAL;
            }
        }

        dma_channels[current_channel].source_buf += source_offset;
        dma_channels[current_channel].dest_buf   += dest_offset;

        bool source_ending_in_rom = (dma_channels[current_channel].source_buf >> 24) >= 8;
        bool dest_ending_in_rom   = (dma_channels[current_channel].dest_buf   >> 24) >= 8;

        // TODO: why do these idle cycles happen? do they happen just if we start out in ROM, or if we touch it at any point?
        // according to gbatek:
        // Internal time for DMA processing is 2I (normally), or 4I (if both source and destination are in gamepak memory area).
        uint idle_cycles = (source_beginning_in_rom || source_ending_in_rom) &&
                           (dest_beginning_in_rom   || dest_ending_in_rom) ?
                           2 : 2;
        // TODO: i have no idea why but idling for 2 cycles in either case makes me pass more dma tests. future me, figure this out.

        num_dmas_running--;
        dmas_running_bitfield &= ~(1 << current_channel);
        if (num_dmas_running == 0) {
            // memory.clock(idle_cycles);
            memory.clock(1);
            memory.prefetch_buffer.resume();
        }

        memory.dma_cycle_accumulation_state = Memory.DMACycleAccumulationState.REIMBURSE;
        
        if (dma_channels[current_channel].irq_on_end) {
            scheduler.add_event_relative_to_clock(() => interrupt_cpu(Interrupt.DMA_0 << current_channel), 2);
        }

        if (is_dma_channel_fifo(current_channel) || dma_channels[current_channel].repeat) {
            if (interpretted_dest_addr_control == DestAddrMode.IncrementReload) {
                dma_channels[current_channel].dest_buf = dma_channels[current_channel].dest;
            }

            enable_dma(current_channel);
        } else {
            dma_channels[current_channel].enabled = false;
        }

        if (dma_channels[current_channel].last) {
            dma_channels[current_channel].enabled = false;
        }

        memory.dma_open_bus = dma_channels[current_channel].open_bus_latch;
        memory.dma_recently = true;
        handle_dma();
        return;
    }

    const uint[4] DMA_SOURCE_BUF_MASK = [0x07FF_FFFF, 0x0FFF_FFFF, 0x0FFF_FFFF, 0x0FFF_FFFF];
    const uint[4] DMA_DEST_BUF_MASK   = [0x07FF_FFFF, 0x07FF_FFFF, 0x07FF_FFFF, 0x0FFF_FFFF];

    void initialize_dma(int dma_id) {
        dma_channels[dma_id].source_buf = dma_channels[dma_id].source & (dma_channels[dma_id].transferring_words ? ~3 : ~1);
        dma_channels[dma_id].dest_buf   = dma_channels[dma_id].dest   & (dma_channels[dma_id].transferring_words ? ~3 : ~1);
    
        dma_channels[dma_id].source_buf &= DMA_SOURCE_BUF_MASK[dma_id];
        dma_channels[dma_id].dest_buf   &= DMA_DEST_BUF_MASK[dma_id];
    }

    void enable_dma(int dma_id) {
        dma_channels[dma_id].num_units = dma_channels[dma_id].num_units & 0x0FFFFFFF;
        if (dma_id == 3) dma_channels[dma_id].num_units &= 0x07FFFFFF;

        if (is_dma_channel_fifo(dma_id)) {
            dma_channels[dma_id].num_units = 4;
        }
        dma_channels[dma_id].enabled  = true;

        dma_channels[dma_id].size_buf = dma_channels[dma_id].num_units;

        if (dma_channels[dma_id].dma_start_timing == DMAStartTiming.Immediately) {
            // don't try to start an immediate DMA with repeat mode enabled, looking at you Teen Titans
            dma_channels[dma_id].repeat = false;
            start_dma_channel(dma_id, false);
        }
        else dma_channels[dma_id].waiting_to_start = false;
    }

    bool in_rom(uint addr) {
        auto region = (addr >> 24) & 0xF;
        return region >= 0x8 && region <= 0xD;
    }

    pragma(inline, true) void start_dma_channel(int dma_id, bool last) {
        dma_channels[dma_id].waiting_to_start = true;
        dmas_available++;
        scheduler.add_event_relative_to_clock(&check_dma, 2, true);
        if (_g_num_log > 0) log!(LogSource.DEBUG)("DMA enabled. Scheduled to happen in 2 cycles", num_cycles);

        dma_channels[dma_id].last = last;
    }

    pragma(inline, true) bool is_dma_channel_fifo(int i) {
        return (i == 1 || i == 2) && dma_channels[i].dma_start_timing == DMAStartTiming.Special;
    }

    void maybe_refill_fifo(DirectSound fifo_type) {
        uint destination_address = 0;
        final switch (fifo_type) {
            case DirectSound.A: destination_address = MMIO.FIFO_A; break;
            case DirectSound.B: destination_address = MMIO.FIFO_B; break;
        }

        for (int i = 0; i < 4; i++) {
            if (dma_channels[i].dest == destination_address && is_dma_channel_fifo(i)) {
                start_dma_channel(i, false);
            }
        }
    }

    void on_hblank(uint scanline) {
        if (scanline < 160) {
            for (int i = 0; i < 4; i++) {
                if (dma_channels[i].dma_start_timing == DMAStartTiming.HBlank) {
                    start_dma_channel(i, false);
                }
            }
        }

        if (dma_channels[3].dma_start_timing == DMAStartTiming.Special && scanline >= 2 && scanline < 162) {
            start_dma_channel(3, scanline == 161);
        }
    }

    void on_vblank() {
        for (int i = 0; i < 4; i++) {
            if (dma_channels[i].dma_start_timing == DMAStartTiming.VBlank) {
                start_dma_channel(i, false);
            }
        }
    }

private:
    Memory memory;

    DMAChannel[4] dma_channels;

    enum SourceAddrMode {
        Increment       = 0b00,
        Decrement       = 0b01,
        Fixed           = 0b10,
        Prohibited      = 0b11
    }

    enum DestAddrMode {
        Increment       = 0b00,
        Decrement       = 0b01,
        Fixed           = 0b10,
        IncrementReload = 0b11
    }

    enum DMAStartTiming {
        Immediately = 0b00,
        VBlank      = 0b01,
        HBlank      = 0b10,
        Special     = 0b11
    }

    //.......................................................................................................................
    //.RRRRRRRRRRR...EEEEEEEEEEEE....GGGGGGGGG....IIII...SSSSSSSSS...TTTTTTTTTTTTT.EEEEEEEEEEEE..RRRRRRRRRRR....SSSSSSSSS....
    //.RRRRRRRRRRRR..EEEEEEEEEEEE...GGGGGGGGGGG...IIII..SSSSSSSSSSS..TTTTTTTTTTTTT.EEEEEEEEEEEE..RRRRRRRRRRRR..SSSSSSSSSSS...
    //.RRRRRRRRRRRRR.EEEEEEEEEEEE..GGGGGGGGGGGGG..IIII..SSSSSSSSSSSS.TTTTTTTTTTTTT.EEEEEEEEEEEE..RRRRRRRRRRRR..SSSSSSSSSSSS..
    //.RRRR.....RRRR.EEEE..........GGGGG....GGGG..IIII..SSSS....SSSS.....TTTT......EEEE..........RRR.....RRRRR.SSSS....SSSS..
    //.RRRR.....RRRR.EEEE.........GGGGG......GGG..IIII..SSSS.............TTTT......EEEE..........RRR......RRRR.SSSSS.........
    //.RRRR....RRRRR.EEEEEEEEEEEE.GGGG............IIII..SSSSSSSS.........TTTT......EEEEEEEEEEEE..RRR.....RRRR..SSSSSSSS......
    //.RRRRRRRRRRRR..EEEEEEEEEEEE.GGGG....GGGGGGG.IIII..SSSSSSSSSSS......TTTT......EEEEEEEEEEEE..RRRRRRRRRRRR...SSSSSSSSSS...
    //.RRRRRRRRRRRR..EEEEEEEEEEEE.GGGG....GGGGGGG.IIII....SSSSSSSSS......TTTT......EEEEEEEEEEEE..RRRRRRRRRRRR....SSSSSSSSSS..
    //.RRRRRRRRRRR...EEEE.........GGGG....GGGGGGG.IIII........SSSSSS.....TTTT......EEEE..........RRRRRRRRRR..........SSSSSS..
    //.RRRR..RRRRR...EEEE.........GGGGG......GGGG.IIII...SS.....SSSS.....TTTT......EEEE..........RRR...RRRRR....SS.....SSSS..
    //.RRRR...RRRR...EEEE..........GGGGG....GGGGG.IIII.ISSSS....SSSS.....TTTT......EEEE..........RRR....RRRR...SSSS....SSSS..
    //.RRRR...RRRRR..EEEEEEEEEEEEE.GGGGGGGGGGGGGG.IIII.ISSSSSSSSSSSS.....TTTT......EEEEEEEEEEEEE.RRR....RRRRR..SSSSSSSSSSSS..
    //.RRRR....RRRRR.EEEEEEEEEEEEE..GGGGGGGGGGGG..IIII..SSSSSSSSSSS......TTTT......EEEEEEEEEEEEE.RRR.....RRRRR.SSSSSSSSSSSS..
    //.RRRR.....RRRR.EEEEEEEEEEEEE...GGGGGGGGG....IIII...SSSSSSSSS.......TTTT......EEEEEEEEEEEEE.RRR.....RRRRR..SSSSSSSSSS...

public:
    void write_DMAXSAD(int target_byte, ubyte data, int x) {
        // if (x == 0) error("RAW: %x %x %x");
        final switch (target_byte) {
            case 0b00: dma_channels[x].source = (dma_channels[x].source & 0xFFFFFF00) | (data << 0);  break;
            case 0b01: dma_channels[x].source = (dma_channels[x].source & 0xFFFF00FF) | (data << 8);  break;
            case 0b10: dma_channels[x].source = (dma_channels[x].source & 0xFF00FFFF) | (data << 16); break;
            case 0b11: dma_channels[x].source = (dma_channels[x].source & 0x00FFFFFF) | (data << 24); break;
        }
    }

    void write_DMAXDAD(int target_byte, ubyte data, int x) {
        // if (x == 0) error("RAW: %x %x %x");
        final switch (target_byte) {
            case 0b00: dma_channels[x].dest = (dma_channels[x].dest & 0xFFFFFF00) | (data << 0);  break;
            case 0b01: dma_channels[x].dest = (dma_channels[x].dest & 0xFFFF00FF) | (data << 8);  break;
            case 0b10: dma_channels[x].dest = (dma_channels[x].dest & 0xFF00FFFF) | (data << 16); break;
            case 0b11: dma_channels[x].dest = (dma_channels[x].dest & 0x00FFFFFF) | (data << 24); break;
        }
    }

    void write_DMAXCNT_L(int target_byte, ubyte data, int x) {
        final switch (target_byte) {
            case 0b00: dma_channels[x].num_units = (dma_channels[x].num_units & 0xFF00) | (data << 0); break;
            case 0b01: dma_channels[x].num_units = (dma_channels[x].num_units & 0x00FF) | (data << 8); break;
        }
    }

    void write_DMAXCNT_H(int target_byte, ubyte data, int x) {
        final switch (target_byte) {
            case 0b00:
                dma_channels[x].dest_addr_control   = cast(DestAddrMode) get_nth_bits(data, 5, 7);
                dma_channels[x].source_addr_control = cast(SourceAddrMode) ((get_nth_bit(data, 7) << 0) | (dma_channels[x].source_addr_control & 0b10));
                break;
            case 0b01:
                dma_channels[x].source_addr_control = cast(SourceAddrMode) ((get_nth_bit (data, 0) << 1) | (dma_channels[x].source_addr_control & 0b01));
                dma_channels[x].repeat              =  get_nth_bit (data, 1);
                dma_channels[x].transferring_words  =  get_nth_bit (data, 2);
                dma_channels[x].gamepak_drq         =  x == 3 ? get_nth_bit (data, 3) : 0;
                dma_channels[x].dma_start_timing    =  cast(DMAStartTiming) get_nth_bits(data, 4, 6);
                dma_channels[x].irq_on_end          =  get_nth_bit (data, 6);
                dma_channels[x].enabled             =  get_nth_bit (data, 7);

                if (get_nth_bit(data, 7)) {
                    initialize_dma(x);
                    enable_dma(x);
                }

                break;
        }
    }

    ubyte read_DMAXCNT_H(int target_byte, int x) {
        final switch (target_byte) {
            case 0b00:
                return cast(ubyte) ((dma_channels[x].dest_addr_control            << 5) |
                                    ((dma_channels[x].source_addr_control & 0b01) << 7));
            case 0b01:
                return cast(ubyte) (((dma_channels[x].source_addr_control & 0b10) >> 1) |
                                     (dma_channels[x].repeat                      << 1) |
                                     (dma_channels[x].transferring_words          << 2) |
                                     (dma_channels[x].gamepak_drq                 << 3) |
                                     (dma_channels[x].dma_start_timing            << 4) |
                                     (dma_channels[x].irq_on_end                  << 6) |
                                     (dma_channels[x].enabled                     << 7));
        }
    }
}

struct DMAChannel {
    uint   source;
    uint   dest;
    ushort num_units;

    uint   source_buf;
    uint   dest_buf;
    ushort size_buf;
    
    bool   enabled;
    bool   waiting_to_start;
    bool   repeat;
    bool   transferring_words;
    bool   gamepak_drq;
    bool   irq_on_end;

    uint   open_bus_latch;

    bool   last;

    DMAManager.DestAddrMode   dest_addr_control;
    DMAManager.SourceAddrMode source_addr_control;
    DMAManager.DMAStartTiming dma_start_timing;
}