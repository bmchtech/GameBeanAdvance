module apu.directsound;

import fifo;

shared(Fifo<ubyte>) fifo_a = new Fifo(0x20, 0x00);
shared(Fifo<ubyte>) fifo_b = new Fifo(0x20, 0x00);
