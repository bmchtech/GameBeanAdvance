module memory;

import core.stdc.stdint; //uint16_t uint32_t uint8_t 

// for more details on the GBA memory map: https://problemkaputt.de/gbatek.htm#gbamemorymap
// i'm going to probably have to split this struct into more specific values later,
// but for now ill just do the ones i can see myself easily using.

class Memory {
    uint8_t[] main;
    uint8_t[] bios;
    uint8_t[] wram_board;
    uint8_t[] wram_chip;
    uint8_t[] io_registers;
    uint8_t[] palette_ram;
    uint8_t[] vram;
    uint8_t[] oam;
    uint8_t[] rom_1;
    uint8_t[] rom_2;
    uint8_t[] rom_3;
    uint8_t[] sram;
    bool has_updated = false;
    uint8_t[] pixels;
    uint16_t[] DISPCNT;
    uint16_t[] DISPSTAT;
    uint16_t[] VCOUNT;
    uint16_t[] BG0CNT;
    uint16_t[] BG1CNT;
    uint16_t[] BG2CNT;
    uint16_t[] BG3CNT;
    uint16_t[] BG0HOFS;
    uint16_t[] BG0VOFS;
    uint16_t[] BG1HOFS;
    uint16_t[] BG1VOFS;
    uint16_t[] BG2HOFS;
    uint16_t[] BG2VOFS;
    uint16_t[] BG3HOFS;
    uint16_t[] BG3VOFS;
    uint16_t[] BG2PA;
    uint16_t[] BG2PB;
    uint16_t[] BG2PC;
    uint16_t[] BG2PD;
    uint32_t[] BG2X;
    uint32_t[] BG2Y;
    uint16_t[] BG3PA;
    uint16_t[] BG3PB;
    uint16_t[] BG3PC;
    uint16_t[] BG3PD;
    uint32_t[] BG3X;
    uint32_t[] BG3Y;
    uint16_t[] WIN0H;
    uint16_t[] WIN1H;
    uint16_t[] WIN0V;
    uint16_t[] WIN1V;
    uint16_t[] WININ;
    uint16_t[] WINOUT;
    uint16_t[] MOSAIC;
    uint16_t[] BLDCNT;
    uint16_t[] BLDALPHA;
    uint16_t[] BLDY;
    uint32_t[] DMA0SAD;
    uint32_t[] DMA0DAD;
    uint16_t[] DMA0CNT_L;
    uint16_t[] DMA0CNT_H;
    uint32_t[] DMA1SAD;
    uint32_t[] DMA1DAD;
    uint16_t[] DMA1CNT_L;
    uint16_t[] DMA1CNT_H;
    uint32_t[] DMA2SAD;
    uint32_t[] DMA2DAD;
    uint16_t[] DMA2CNT_L;
    uint16_t[] DMA2CNT_H;
    uint32_t[] DMA3SAD;
    uint32_t[] DMA3DAD;
    uint16_t[] DMA3CNT_L;
    uint16_t[] DMA3CNT_H;
    uint16_t[] KEYINPUT;
    uint16_t[] KEYCNT;
    uint8_t read_byte(uint32_t address) {
        assert(0);
    }

    uint16_t read_halfword(uint32_t address) {
        assert(0);
    }

    uint32_t read_word(uint32_t address) {
        assert(0);
    }

    void write_byte(uint32_t address, uint8_t value) {
        assert(0);
    }

    void write_halfword(uint32_t address, uint16_t value) {
        assert(0);
    }

    void write_word(uint32_t address, uint32_t value) {
        assert(0);
    }

}
