module hw.dma;

import hw.memory;
import hw.gba;
import hw.apu;
import hw.interrupts;

import util;
import scheduler;

import std.stdio;

class DMAManager {
public:
    void delegate(uint) interrupt_cpu;
    Scheduler scheduler;

    this(Memory memory, Scheduler scheduler, void delegate(uint) interrupt_cpu) {
        this.memory        = memory;
        this.scheduler     = scheduler;
        this.interrupt_cpu = interrupt_cpu;

        dma_cycle          = false;
        this.idle_cycles   = 0;

        dma_channels = [
            DMAChannel(0, 0, 0, 0, 0, 0, false, false, false, false, false, false, 0, DestAddrMode.Increment, SourceAddrMode.Increment, DMAStartTiming.Immediately),
            DMAChannel(0, 0, 0, 0, 0, 0, false, false, false, false, false, false, 0, DestAddrMode.Increment, SourceAddrMode.Increment, DMAStartTiming.Immediately),
            DMAChannel(0, 0, 0, 0, 0, 0, false, false, false, false, false, false, 0, DestAddrMode.Increment, SourceAddrMode.Increment, DMAStartTiming.Immediately),
            DMAChannel(0, 0, 0, 0, 0, 0, false, false, false, false, false, false, 0, DestAddrMode.Increment, SourceAddrMode.Increment, DMAStartTiming.Immediately)
        ];
    }

    int dmas_available = 0;

    pragma(inline, true) int check_dma() {
        if (dmas_available > 0) {
            dmas_available--;
            return handle_dma();
        }

        return 0;
    }

    // returns the amount of cycles to idle
    int handle_dma() {
        memory.cycles = 0;
        idle_cycles = 0;
        
        // get the channel with highest priority that wants to start dma
        int current_channel = -1;
        for (int i = 0; i < 4; i++) {
            if (dma_channels[i].enabled && dma_channels[i].waiting_to_start) {
                current_channel = i;
                break;
            }
        }

        // writefln("[%016x] Running DMA Channel %x", num_cycles, current_channel);

        if (current_channel == -1) return 0; //error("DMA requested but no active channels found");

        uint bytes_to_transfer  = dma_channels[current_channel].size_buf;
        int  source_increment   = 0;
        int  dest_increment     = 0;

        if (!is_dma_channel_fifo(current_channel)) writefln("DMA Channel %x running: Transferring %x %s from %x to %x (Control: %x)",
                 current_channel,
                 bytes_to_transfer,
                 dma_channels[current_channel].transferring_words ? "words" : "halfwords",
                 dma_channels[current_channel].source_buf,
                 dma_channels[current_channel].dest_buf,
                 read_DMAXCNT_H(0, current_channel) | (read_DMAXCNT_H(1, current_channel) << 8));

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

        if (dma_channels[current_channel].transferring_words || is_dma_channel_fifo(current_channel)) {
            bytes_to_transfer *= 4;
            for (int i = 0; i < bytes_to_transfer; i += 4) {
                uint read_address = dma_channels[current_channel].source_buf + source_offset;

                if (read_address >= 0x0200_0000) { // make sure we are not accessing DMA open bus
                    dma_channels[current_channel].open_bus_latch = memory.read_word(dma_channels[current_channel].source_buf + source_offset);
                }
                
                memory.write_word(dma_channels[current_channel].dest_buf + dest_offset, dma_channels[current_channel].open_bus_latch);
                source_offset += source_increment;
                dest_offset   += dest_increment;
            }
        } else {
            bytes_to_transfer *= 2;
            bool is_aligned = dma_channels[current_channel].source_buf & 1;

            for (int i = 0; i < bytes_to_transfer; i += 2) {
                uint read_address = dma_channels[current_channel].source_buf + source_offset;

                if (read_address >= 0x0200_0000) { // make sure we are not accessing DMA open bus
                    auto shift      = is_aligned * 16;
                    auto read_value = memory.read_halfword(dma_channels[current_channel].source_buf + source_offset);

                    dma_channels[current_channel].open_bus_latch &= 0xFFFF << shift;
                    dma_channels[current_channel].open_bus_latch |= read_value << shift;
                    memory.write_halfword(dma_channels[current_channel].dest_buf + dest_offset, read_value);
                } else {
                    auto shift = is_aligned * 16;
                    ushort open_bus_value = (dma_channels[current_channel].open_bus_latch >> shift) & 0xFFFF;

                    memory.write_halfword(dma_channels[current_channel].dest_buf + dest_offset, open_bus_value);
                }

                source_offset += source_increment;
                dest_offset   += dest_increment;

                is_aligned ^= 1;
            }
        }

        dma_channels[current_channel].source_buf += source_offset;
        dma_channels[current_channel].dest_buf   += dest_offset;
        
        idle_cycles += bytes_to_transfer * 2;

        if (dma_channels[current_channel].irq_on_end) {
            scheduler.add_event_relative_to_self(() => interrupt_cpu(Interrupt.DMA_0 + current_channel), idle_cycles);
        }


        if (is_dma_channel_fifo(current_channel) || dma_channels[current_channel].repeat) {
            if (interpretted_dest_addr_control == DestAddrMode.IncrementReload) {
                dma_channels[current_channel].dest_buf = dma_channels[current_channel].dest;
            }

            enable_dma(current_channel);
            // if (get_nth_bits(*dma_channels[current_channel].cnt_h, 12, 14) == 3 && (current_channel == 1 || current_channel == 2)) {
            //     dma_channels[current_channel].enabled = false;
            //     *dma_channels[current_channel].cnt_h &= ~(1UL << 15);
            //     *dma_channels[current_channel].source = dma_channels[current_channel].source_buf;
            //     return true;
            // }
        } else {
            // writefln("DMA Channel %x Finished", current_channel);
            dma_channels[current_channel].enabled = false;
        }

        // if (current_channel == 1) writefln("DMA Channel %x successfully transfered %x from %x to %x. %x units left.", current_channel, memory.read_word(dma_channels[current_channel].source_buf), dma_channels[current_channel].source_buf, dma_channels[current_channel].dest_buf, dma_channels[current_channel].size_buf);

        // are we writing to direct sound fifos?
        // if (!(get_nth_bits(*dma_channels[current_channel].cnt_h, 12, 14) == 3 && (current_channel == 1 || current_channel == 2))) {
        //     // edit dest_buf and source_buf as needed to set up for the next dma
        //     switch (get_nth_bits(*dma_channels[current_channel].cnt_h, 5, 7)) {
        //         case 0b00:
        //         case 0b11:
        //             dma_channels[current_channel].dest_buf   += increment; break;
        //         case 0b01:
        //             dma_channels[current_channel].dest_buf   -= increment; break;
                
        //         default: {}
        //     }
        // }

        // switch (get_nth_bits(*dma_channels[current_channel].cnt_h, 7, 9)) {
        //     case 0b00:
        //         dma_channels[current_channel].source_buf += increment; break;
        //     case 0b01:
        //         dma_channels[current_channel].source_buf -= increment; break;
            
        //     default: {}
        // }

        return 2 + memory.cycles;
    }

    const uint[4] DMA_SOURCE_BUF_MASK = [0x07FF_FFFF, 0x0FFF_FFFF, 0x0FFF_FFFF, 0x0FFF_FFFF];
    const uint[4] DMA_DEST_BUF_MASK   = [0x07FF_FFFF, 0x07FF_FFFF, 0x07FF_FFFF, 0x0FFF_FFFF];

    void initialize_dma(int dma_id) {
        dma_channels[dma_id].source_buf = dma_channels[dma_id].source & (dma_channels[dma_id].transferring_words ? ~3 : ~1);
        dma_channels[dma_id].dest_buf   = dma_channels[dma_id].dest   & (dma_channels[dma_id].transferring_words ? ~3 : ~1);
    
        writefln("masking %x", dma_channels[dma_id].source_buf);
        dma_channels[dma_id].source_buf &= DMA_SOURCE_BUF_MASK[dma_id];
        dma_channels[dma_id].dest_buf   &= DMA_DEST_BUF_MASK[dma_id];
    }

    void enable_dma(int dma_id) {
        // writefln("Enabling DMA %x", dma_id);
        dma_channels[dma_id].num_units = dma_channels[dma_id].num_units & 0x0FFFFFFF;
        if (dma_id == 3) dma_channels[dma_id].num_units &= 0x07FFFFFF;

        if (is_dma_channel_fifo(dma_id)) {
            dma_channels[dma_id].num_units = 4;
        }
        dma_channels[dma_id].enabled  = true;
        dma_channels[dma_id].size_buf = dma_channels[dma_id].num_units;

        if (dma_channels[dma_id].dma_start_timing == DMAStartTiming.Immediately) start_dma_channel(dma_id);
        else dma_channels[dma_id].waiting_to_start = false;
    }

    pragma(inline, true) void start_dma_channel(int dma_id) {
        dma_channels[dma_id].waiting_to_start = true;
        dmas_available++;
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
                start_dma_channel(i);
            }
        }
    }

    void on_hblank() {
        for (int i = 0; i < 4; i++) {
            if (dma_channels[i].dma_start_timing == DMAStartTiming.HBlank) {
                start_dma_channel(i);
            }
        }
    }

private:
    Memory memory;
    bool   dma_cycle;

    DMAChannel[4] dma_channels;

    uint    idle_cycles;

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
        final switch (target_byte) {
            case 0b00: dma_channels[x].source = (dma_channels[x].source & 0xFFFFFF00) | (data << 0);  break;
            case 0b01: dma_channels[x].source = (dma_channels[x].source & 0xFFFF00FF) | (data << 8);  break;
            case 0b10: dma_channels[x].source = (dma_channels[x].source & 0xFF00FFFF) | (data << 16); break;
            case 0b11: dma_channels[x].source = (dma_channels[x].source & 0x00FFFFFF) | (data << 24); break;
        }
    }

    void write_DMAXDAD(int target_byte, ubyte data, int x) {
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
        // writefln("RAW: %x %x %x", target_byte, x, data);
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

                // if (x == 1 || x == 2) writefln("Enabled a DMA? %x", dma_channels[x].repeat);
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

    DMAManager.DestAddrMode   dest_addr_control;
    DMAManager.SourceAddrMode source_addr_control;
    DMAManager.DMAStartTiming dma_start_timing;
}