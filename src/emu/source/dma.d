module dma;

import memory;
import util;

import std.stdio;

class DMAManager {
public:
    this(Memory memory) {
        this.memory = memory;
        dma_cycle   = false;

        dma_channels = [
            DMAChannel(
                memory.DMA0SAD,
                memory.DMA0DAD,
                memory.DMA0CNT_L,
                memory.DMA0CNT_H,
                0, 0, 0, false
            ),
            DMAChannel(
                memory.DMA1SAD,
                memory.DMA1DAD,
                memory.DMA1CNT_L,
                memory.DMA1CNT_H,
                0, 0, 0, false
            ),
            DMAChannel(
                memory.DMA2SAD,
                memory.DMA2DAD,
                memory.DMA2CNT_L,
                memory.DMA2CNT_H,
                0, 0, 0, false
            ),
            DMAChannel(
                memory.DMA3SAD,
                memory.DMA3DAD,
                memory.DMA3CNT_L,
                memory.DMA3CNT_H,
                0, 0, 0, false
            )
        ];
    }

    // returns true if any DMA cycle occurred. returns false otherwise.
    bool handle_dma() {
        // if any of the channels wants to start dma, then copy its data over to the buffers.
        for (int i = 0; i < 4; i++) {
            if (!dma_channels[i].enabled && get_nth_bit(*dma_channels[i].cnt_h, 15)) {
                dma_channels[i].dest_buf   = *dma_channels[i].dest;
                dma_channels[i].source_buf = *dma_channels[i].source;
                dma_channels[i].size_buf   = *dma_channels[i].cnt_l & 0x0FFFFFFF;
                writefln("Enabling DMA Channel %x: Transfering %x words from %x to %x (Settings: %x)", i, dma_channels[i].size_buf, dma_channels[i].source_buf, dma_channels[i].dest_buf, *dma_channels[i].cnt_h);
                // writefln("RAW DMA Channel %x: Transfering %x words from %x to %x", i, *dma_channels[i].cnt_l, *dma_channels[i].source, *dma_channels[i].dest);

                if (i == 3) dma_channels[i].size_buf &= 0x07FFFFFF;
                dma_channels[i].enabled = true;
                return true;
            }
        }

        // get the channel with highest priority that wants to start dma
        int current_channel = -1;
        for (int i = 0; i < 4; i++) {
            if (dma_channels[i].enabled) {

                current_channel = i;
                break;
            }
        }

        // if we found no channels, leave.
        if (current_channel == -1) return false;

        // dma happens every other cycle
        dma_cycle ^= 1;
        if (!dma_cycle) return true;

        if (get_nth_bit(*dma_channels[current_channel].cnt_h, 14)) {
            warning("EXPECTED INTERRUPT");
        }

        // did we already finish dma?
        bool finished_dma = dma_channels[current_channel].size_buf == 0;

        if (finished_dma) {
            // do we repeat dma?
            if (get_nth_bit(*dma_channels[current_channel].cnt_h, 9)) {
                if (get_nth_bits(*dma_channels[current_channel].cnt_h, 5, 6) == 0b11) {
                    dma_channels[current_channel].dest_buf = *dma_channels[current_channel].dest;
                }

                dma_channels[current_channel].size_buf = *dma_channels[current_channel].cnt_l & 0x0FFFFFFF;
                if (current_channel == 3) dma_channels[current_channel].size_buf &= 0x07FFFFFF;
            } else {
                writefln("DMA Channel %x Finished", current_channel);
                dma_channels[current_channel].enabled = false;
                *dma_channels[current_channel].cnt_h &= ~(1UL << 15);
                return true;
            }
        } else {
            dma_channels[current_channel].size_buf--;
        }

        // if (current_channel == 3) writefln("DMA Channel %x successfully transfered %x from %x to %x. %x units left.", current_channel, memory.read_word(dma_channels[current_channel].source_buf), dma_channels[current_channel].source_buf, dma_channels[current_channel].dest_buf, dma_channels[current_channel].size_buf);
        // copy one piece of data over.
        int increment = 0;
        //    writefln("%x", dma_channels[current_channel].source_buf);
            // std::cout << "B " << to_hex_string(dma_channels[current_channel].dest_buf) << std::endl;
            // std::cout << "B " << to_hex_string(dma_channels[current_channel].size_buf) << std::endl;
        if (get_nth_bit(*dma_channels[current_channel].cnt_h, 10)) {
            memory.write_word    (dma_channels[current_channel].dest_buf, memory.read_word    (dma_channels[current_channel].source_buf));
            increment = 4;
        } else {
            memory.write_halfword(dma_channels[current_channel].dest_buf, memory.read_halfword(dma_channels[current_channel].source_buf));
            increment = 2;
        }

        // are we writing to direct sound fifos?
        if ((get_nth_bits(*dma_channels[current_channel].cnt_h, 12, 14) == 3 && (current_channel == 1 || current_channel == 2))) {
            increment = 0;
        }


        // edit dest_buf and source_buf as needed to set up for the next dma
        switch (get_nth_bits(*dma_channels[current_channel].cnt_h, 5, 7)) {
            case 0b00:
            case 0b11:
                dma_channels[current_channel].dest_buf   += increment; break;
            case 0b01:
                dma_channels[current_channel].dest_buf   -= increment; break;
            
            default: {}
        }

        switch (get_nth_bits(*dma_channels[current_channel].cnt_h, 7, 9)) {
            case 0b00:
                dma_channels[current_channel].source_buf += increment; break;
            case 0b01:
                dma_channels[current_channel].source_buf -= increment; break;
            
            default: {}
        }

        return true;
    }

private:
    Memory memory;
    bool   dma_cycle;

    DMAChannel[4] dma_channels;
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
}