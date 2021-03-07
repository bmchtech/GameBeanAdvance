module gba;

import core.stdc.stdint; //uint16_t uint32_t 
import memory;
import arm7tdmi;
import ppu;

enum CART_SIZE = 0x1000000;

enum ROM_ENTRY_POINT = 0x000;
enum GAME_TITLE_OFFSET = 0x0A0;
enum GAME_TITLE_SIZE = 12;

class GBA {
public:
    struct DMAChannel {
        uint32_t[] source;
        uint32_t[] dest;
        uint16_t[] cnt_l;
        uint16_t[] cnt_h;
        uint32_t source_buf;
        uint32_t dest_buf;
        uint16_t size_buf;
        bool enabled;
    }

    void error(string message);

    // TODO: run the GBA. probably going to be one of the last things that is actually implemented, since manually cycling
    // the emulator is a lot easier to test. heck, this method might not even exist, idk. but, it's here for now.
    void run(string rom_name);

    // cycles the GBA CPU once, executing one instruction to completion.
    // maybe this method belongs in an ARM7TDMI class. nobody knows. i don't see the reason for having such a class, so
    // this is staying here for now.
    void cycle();

    // returns true if a DMA transfer occurred this cycle.
    bool handle_dma();

    bool enabled;
private:
    int[] cpu;
    int[] ppu;
    int[] memory;

    alias DMAChannel_t = GBA.DMAChannel;
    GBA.DMAChannel_t[4] dma_channels;
    bool dma_cycle = false;
}
