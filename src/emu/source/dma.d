module dma;

import memory;
import util;
import apu;
import mmio;

import std.stdio;

class DMAManager {
public:
    this(Memory memory) {
        this.memory      = memory;
        dma_cycle        = false;
        this.idle_cycles = 0;

        dma_channels = [
            DMAChannel(0, 0, 0, 0, 0, 0, false, false, false, false, false, false, DestAddrMode.Increment, SourceAddrMode.Increment, DMAStartTiming.Immediately),
            DMAChannel(0, 0, 0, 0, 0, 0, false, false, false, false, false, false, DestAddrMode.Increment, SourceAddrMode.Increment, DMAStartTiming.Immediately),
            DMAChannel(0, 0, 0, 0, 0, 0, false, false, false, false, false, false, DestAddrMode.Increment, SourceAddrMode.Increment, DMAStartTiming.Immediately),
            DMAChannel(0, 0, 0, 0, 0, 0, false, false, false, false, false, false, DestAddrMode.Increment, SourceAddrMode.Increment, DMAStartTiming.Immediately)
        ];
    }

    // returns the amount of cycles to idle
    int handle_dma() {
        idle_cycles = 0;
        
        // get the channel with highest priority that wants to start dma
        int current_channel = -1;
        for (int i = 0; i < 4; i++) {
            if (dma_channels[i].enabled && dma_channels[i].waiting_to_start) {
                current_channel = i;
                break;
            }
        }

        // if we found no channels, leave.
        if (current_channel == -1) return 0;

        uint bytes_to_transfer  = dma_channels[current_channel].size_buf;
        int  source_increment   = 0;
        int  dest_increment     = 0;

        switch (dma_channels[current_channel].source_addr_control) {
            case SourceAddrMode.Increment:       source_increment =  1; break;
            case SourceAddrMode.Decrement:       source_increment = -1; break;
            case SourceAddrMode.Fixed:           source_increment =  0; break;
            case SourceAddrMode.IncrementReload: source_increment =  0; break;
            default: assert(0);
        }

        switch (dma_channels[current_channel].dest_addr_control) {
            case DestAddrMode.Increment:  dest_increment =  1; break;
            case DestAddrMode.Decrement:  dest_increment = -1; break;
            case DestAddrMode.Fixed:      dest_increment =  0; break;
            case DestAddrMode.Prohibited: error("Prohibited DMA Dest Addr Control Used."); break;
            default: assert(0);
        }

        source_increment *= (dma_channels[current_channel].transferring_words ? 4 : 2);
        dest_increment   *= (dma_channels[current_channel].transferring_words ? 4 : 2);

        int source_offset = 0;
        int dest_offset   = 0;

        if (dma_channels[current_channel].transferring_words) {
            bytes_to_transfer *= 4;
            for (int i = 0; i < bytes_to_transfer; i += 4) {
                if (is_dma_channel_fifo(i)) writefln("DMA Channel %x successfully transfered %x from %x to %x. %x words done.", current_channel, memory.read_word(dma_channels[current_channel].source), dma_channels[current_channel].source + source_offset, dma_channels[current_channel].dest, i);

                memory.write_word(dma_channels[current_channel].dest + dest_offset, memory.read_word(dma_channels[current_channel].source + source_offset));
                source_offset += source_increment;
                dest_offset   += dest_increment;
            }
        } else {
            bytes_to_transfer *= 2;
            for (int i = 0; i < bytes_to_transfer; i += 2) {
                // writefln("DMA Channel %x successfully transfered %x from %x to %x. %x halfwords done.", current_channel, memory.read_word(dma_channels[current_channel].source), dma_channels[current_channel].source, dma_channels[current_channel].dest, i);

                memory.write_halfword(dma_channels[current_channel].dest + dest_offset, memory.read_halfword(dma_channels[current_channel].source + source_offset));
                source_offset += source_increment;
                dest_offset   += dest_increment;
            }
        }

        dma_channels[current_channel].source += source_offset;
        dma_channels[current_channel].dest   += dest_offset;
        
        idle_cycles += bytes_to_transfer * 2;

        if (dma_channels[current_channel].irq_on_end) {
            warning("EXPECTED INTERRUPT");
        }


        if (dma_channels[current_channel].repeat) {
            if (dma_channels[current_channel].source_addr_control == SourceAddrMode.IncrementReload) {
                dma_channels[current_channel].source = dma_channels[current_channel].source_buf;
            } else {
                dma_channels[current_channel].source_buf = dma_channels[current_channel].source;
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
            return idle_cycles;
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

        return idle_cycles;
    }

    void enable_dma(int dma_id) {
        dma_channels[dma_id].num_units = dma_channels[dma_id].num_units & 0x0FFFFFFF;
        if (dma_id == 3) dma_channels[dma_id].num_units &= 0x07FFFFFF;

        if (is_dma_channel_fifo(dma_id)) {
            dma_channels[dma_id].num_units          = 4;
            dma_channels[dma_id].repeat             = true;
            dma_channels[dma_id].transferring_words = true;
            dma_channels[dma_id].dest_addr_control  = DestAddrMode.Fixed;
        }

        dma_channels[dma_id].source_buf       = dma_channels[dma_id].source;
        dma_channels[dma_id].dest_buf         = dma_channels[dma_id].dest;
        dma_channels[dma_id].size_buf         = dma_channels[dma_id].num_units;
        dma_channels[dma_id].waiting_to_start = dma_channels[dma_id].dma_start_timing == DMAStartTiming.Immediately;

        dma_channels[dma_id].enabled          = true;
    }

    void start_dma_channel(int dma_id) {
        dma_channels[dma_id].waiting_to_start = true;
    }

    bool is_dma_channel_fifo(int i) {
        return (i == 1 || i == 2) && dma_channels[i].dma_start_timing == DMAStartTiming.Special;
    }

    void maybe_refill_fifo(DirectSound fifo_type) {
        uint destination_address = 0;
        final switch (fifo_type) {
            case DirectSound.A: destination_address = MMIO.FIFO_A; break;
            case DirectSound.B: destination_address = MMIO.FIFO_B; break;
        }

        for (int i = 0; i < 4; i++) { // only check channels 1 and 2, theyre the only ones capable of audio fifo
            if (dma_channels[i].dest == destination_address && is_dma_channel_fifo(i)) {
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
        IncrementReload = 0b11
    }

    enum DestAddrMode {
        Increment       = 0b00,
        Decrement       = 0b01,
        Fixed           = 0b10,
        Prohibited      = 0b11
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
        final switch (target_byte) {
            case 0b00:
                dma_channels[x].dest_addr_control   = cast(DestAddrMode) get_nth_bits(data, 5, 7);
                dma_channels[x].source_addr_control = cast(SourceAddrMode) ((get_nth_bit(data, 7) << 0) | (dma_channels[x].source_addr_control & 0x10));
                break;
            case 0b01:
                dma_channels[x].source_addr_control = cast(SourceAddrMode) ((get_nth_bit (data, 0) << 1) | (dma_channels[x].source_addr_control & 0x01));
                dma_channels[x].repeat              =  get_nth_bit (data, 1);
                dma_channels[x].transferring_words  =  get_nth_bit (data, 2);
                dma_channels[x].gamepak_drq         =  get_nth_bit (data, 3);
                dma_channels[x].dma_start_timing    =  cast(DMAStartTiming) get_nth_bits(data, 4, 6);
                dma_channels[x].irq_on_end          =  get_nth_bit (data, 6);
                dma_channels[x].enabled             =  get_nth_bit (data, 7);

                if (get_nth_bit(data, 7)) {
                    enable_dma(x);
                }
                break;
        }
    }

    ubyte read_DMAXCNT_H(int target_byte, int x) {
        final switch (target_byte) {
            case 0b00:
                return cast(ubyte) ((dma_channels[x].dest_addr_control          << 5) |
                                    (dma_channels[x].source_addr_control & 0b01 << 7));
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

    DMAManager.DestAddrMode   dest_addr_control;
    DMAManager.SourceAddrMode source_addr_control;
    DMAManager.DMAStartTiming dma_start_timing;
}