// module apu.directsound;

// import apu;
// import memory;
// import util;

// import std.stdio;


// // initial fifo size
// enum FIFO_LENGTH         = 0x20;

// // when fifo length is <= this number, directsound will try to request dma to fill it back up again.
// enum FIFO_FULL_THRESHOLD = 4;

// enum DirectSoundFifo {
//     A, B
// };

// class DirectSound {
//     Memory memory;
    
//     this(Memory memory) {
//         this.memory = memory;
//     }

//     void push_one_sample_to_buffer(DirectSoundFifo direct_sound_fifo_type) {
//         Fifo!ubyte fifo;
//         // writefln("Pushing");

//         if (direct_sound_fifo_type == DirectSoundFifo.A) fifo = memory.fifo_a;
//         if (direct_sound_fifo_type == DirectSoundFifo.B) fifo = memory.fifo_b;

//         if (fifo.size != 0) {
//             ubyte value = fifo.pop();
//             push_to_buffer([value]);
//         }

//         if (fifo.size <= FIFO_FULL_THRESHOLD) {
//             uint desired_destination_address = direct_sound_fifo_type == DirectSoundFifo.A ? 0x40000A0 : 0x40000A4;
//             // writefln("%x %x %x", desired_destination_address, *memory.DMA1DAD, *memory.DMA1CNT_H);

//             if (*memory.DMA1DAD == desired_destination_address && get_nth_bits(*memory.DMA1CNT_H, 12, 14) == 0b11) {
//                 memory.write_halfword(0x40000C6, *memory.DMA1CNT_H | (1 << 15));
//             }
//             if (*memory.DMA2DAD == desired_destination_address && get_nth_bits(*memory.DMA2CNT_H, 12, 14) == 0b11)
//                 memory.write_halfword(0x40000D2, *memory.DMA2CNT_H | (1 << 15));
//         }
//         // writefln("Pushed");
//     }
// }