module apu.directsound;

import apu;
import memory;
import util;

// initial fifo size
enum FIFO_LENGTH         = 0x20;

// when fifo length is <= this number, directsound will try to request dma to fill it back up again.
enum FIFO_FULL_THRESHOLD = 4;

enum DirectSoundFifo {
    A, B
};

class DirectSound {
    Memory memory;
    
    this(Memory memory) {
        this.memory = memory;
    }

    void push_one_sample_to_buffer(DirectSoundFifo direct_sound_fifo_type) {
        Fifo!ubyte fifo;

        if (direct_sound_fifo_type == DirectSoundFifo.A) fifo = memory.fifo_a;
        if (direct_sound_fifo_type == DirectSoundFifo.B) fifo = memory.fifo_b;

        if (fifo.size() != 0)
            push_to_buffer([fifo.pop()]);

        if (fifo.size() <= FIFO_FULL_THRESHOLD) {
            uint desired_destination_address = direct_sound_fifo_type == DirectSoundFifo.A ? 0x40000A0 : 0x400000A4;

            if (*memory.DMA1DAD == desired_destination_address && get_nth_bits(*memory.DMA1CNT_H, 12, 14) == 0b11)
                memory.write_halfword(*memory.DMA1CNT_H, *memory.DMA1CNT_H | (1 << 15));
            if (*memory.DMA2DAD == desired_destination_address && get_nth_bits(*memory.DMA2CNT_H, 12, 14) == 0b11)
                memory.write_halfword(*memory.DMA2CNT_H, *memory.DMA2CNT_H | (1 << 15));
        }
    }
}