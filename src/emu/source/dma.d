module dma;

import memory;
import util;

import std.stdio;

class DMAManager {
public:
    this(Memory memory) {
        this.memory      = memory;
        dma_cycle        = false;
        this.idle_cycles = 0;

        dma_channels = [
            DMAChannel(
                memory.DMA0SAD,
                memory.DMA0DAD,
                memory.DMA0CNT_L,
                memory.DMA0CNT_H,
                0, 0, 0, false, false
            ),
            DMAChannel(
                memory.DMA1SAD,
                memory.DMA1DAD,
                memory.DMA1CNT_L,
                memory.DMA1CNT_H,
                0, 0, 0, false, false
            ),
            DMAChannel(
                memory.DMA2SAD,
                memory.DMA2DAD,
                memory.DMA2CNT_L,
                memory.DMA2CNT_H,
                0, 0, 0, false, false
            ),
            DMAChannel(
                memory.DMA3SAD,
                memory.DMA3DAD,
                memory.DMA3CNT_L,
                memory.DMA3CNT_H,
                0, 0, 0, false, false
            )
        ];
    }

    // returns true if any DMA cycle occurred. returns false otherwise.
    bool handle_dma() {
        if (idle_cycles > 0) {
            idle_cycles--;
            return true;
        }

        // if any of the channels wants to start dma, then copy its data over to the buffers.
        for (int i = 0; i < 4; i++) {
            if (get_nth_bit(*dma_channels[i].cnt_h, 15) && !dma_channels[i].enabled) {
                dma_channels[i].enabled = true;
                dma_channels[i].waiting_to_start = get_nth_bits(*dma_channels[i].cnt_h, 12, 14) == 0b00;

                // dma_channels[i].dest_buf   = *dma_channels[i].dest;
                dma_channels[i].source_buf = *dma_channels[i].source;
                dma_channels[i].size_buf   = *dma_channels[i].cnt_l & 0x0FFFFFFF;
                writefln("Enabling DMA Channel %x: Transfering %x words from %x to %x (Settings: %x)", i, dma_channels[i].size_buf, *dma_channels[i].source, *dma_channels[i].dest, *dma_channels[i].cnt_h);
                // // writefln("RAW DMA Channel %x: Transfering %x words from %x to %x", i, *dma_channels[i].cnt_l, *dma_channels[i].source, *dma_channels[i].dest);

                if (i == 3) dma_channels[i].size_buf &= 0x07FFFFFF;
                // dma_channels[i].enabled = true;

                // // are we writing to direct sound fifos?
                // if ((get_nth_bits(*dma_channels[i].cnt_h, 12, 14) == 3 && (i == 1 || i == 2))) {
                //     dma_channels[i].size_buf = 4;
                //     *dma_channels[i].cnt_h |= (1 << 9);
                //     *dma_channels[i].cnt_h |= (1 << 10);
                // }
                // return true;
            }
        }

        // get the channel with highest priority that wants to start dma
        int current_channel = -1;
        for (int i = 0; i < 4; i++) {
            if (dma_channels[i].enabled && dma_channels[i].waiting_to_start) {
                current_channel = i;
                break;
            }
        }

        // if we found no channels, leave.
        if (current_channel == -1) return false;

        uint bytes_to_transfer  = dma_channels[current_channel].size_buf;
        bool transferring_words = get_nth_bit(*dma_channels[current_channel].cnt_h, 10);
        int  source_increment   = 0;
        int  dest_increment     = 0;

        switch (get_nth_bits(*dma_channels[current_channel].cnt_h, 7, 9)) {
            case 0b00: source_increment =  1; break;
            case 0b01: source_increment = -1; break;
            case 0b10: source_increment =  0; break;
            default: assert(0);
        }

        switch (get_nth_bits(*dma_channels[current_channel].cnt_h, 5, 7)) {
            case 0b00: dest_increment =  1; break;
            case 0b01: dest_increment = -1; break;
            case 0b10: dest_increment =  0; break;
            case 0b11: dest_increment =  1; break;
            default: assert(0);
        }

        source_increment *= (transferring_words ? 4 : 2);
        dest_increment   *= (transferring_words ? 4 : 2);

        int source_offset = 0;
        int dest_offset   = 0;

        if (get_nth_bit(*dma_channels[current_channel].cnt_h, 10)) {
            bytes_to_transfer *= 4;
            for (int i = 0; i < bytes_to_transfer; i += 4) {
                memory.write_word(*dma_channels[current_channel].dest + source_offset, memory.read_word(*dma_channels[current_channel].source + dest_offset));
                source_offset += source_increment;
                dest_offset   += dest_increment;
            }
        } else {
            bytes_to_transfer *= 2;
            for (int i = 0; i < bytes_to_transfer; i += 2) {
                memory.write_halfword(*dma_channels[current_channel].dest + source_offset, memory.read_halfword(*dma_channels[current_channel].source + dest_offset));
                source_offset += source_increment;
                dest_offset   += dest_increment;
            }
        }
        
        idle_cycles += bytes_to_transfer * 2;

        if (get_nth_bit(*dma_channels[current_channel].cnt_h, 14)) {
            warning("EXPECTED INTERRUPT");
        }


        // do we repeat dma?
        if (get_nth_bit(*dma_channels[current_channel].cnt_h, 9)) {
            if (get_nth_bits(*dma_channels[current_channel].cnt_h, 5, 6) == 0b11) {
                dma_channels[current_channel].dest_buf = *dma_channels[current_channel].dest;
            }

            dma_channels[current_channel].size_buf = *dma_channels[current_channel].cnt_l & 0x0FFFFFFF;
            if (current_channel == 3) dma_channels[current_channel].size_buf &= 0x07FFFFFF;

            // writefln("Repeating DMA Channel %x", current_channel);

            if (get_nth_bits(*dma_channels[current_channel].cnt_h, 12, 14) == 3 && (current_channel == 1 || current_channel == 2)) {
                dma_channels[current_channel].enabled = false;
                *dma_channels[current_channel].cnt_h &= ~(1UL << 15);
                *dma_channels[current_channel].source = dma_channels[current_channel].source_buf;
                return true;
            }
        } else {
            // writefln("DMA Channel %x Finished", current_channel);
            dma_channels[current_channel].enabled = false;
            *dma_channels[current_channel].cnt_h &= ~(1UL << 15);
            return true;
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

        return true;
    }

private:
    Memory memory;
    bool   dma_cycle;

    DMAChannel[4] dma_channels;

    uint    idle_cycles;
}

struct DMAChannel {
    uint*   source;
    uint*   dest;
    ushort* cnt_l;
    ushort* cnt_h;

    uint    source_buf;
    uint    dest_buf;
    ushort  size_buf;
    
    bool    enabled;
    bool    waiting_to_start;
}