module gba;

import core.stdc.stdint; //uint16_t uint32_t 

auto const CART_SIZE = 0x1000000;

auto const ROM_ENTRY_POINT = 0x000;
auto const GAME_TITLE_OFFSET = 0x0A0;
auto const GAME_TITLE_SIZE = 12;

class GBA {
    //friend void error(string message
    );
    bool enabled;
private:
    int[] cpu;
    int[] ppu;
    int[] memory;
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

    alias DMAChannel_t = GBA.DMAChannel;
    GBA.DMAChannel_t[4] dma_channels;
    bool dma_cycle = false;
}
