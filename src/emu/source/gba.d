module gba;

public {
    import memory;
    import arm7tdmi;
    import ppu;
    import cpu_state;
}

enum CART_SIZE = 0x1000000;

enum ROM_ENTRY_POINT = 0x000;
enum GAME_TITLE_OFFSET = 0x0A0;
enum GAME_TITLE_SIZE = 12;

class GBA {
public:
    this(Memory* memory) {
        assert(0);
    }

    struct DMAChannel {
        uint[] source;
        uint[] dest;
        ushort[] cnt_l;
        ushort[] cnt_h;
        uint source_buf;
        uint dest_buf;
        ushort size_buf;
        bool enabled;
    }

    void error(string message) {
        assert(0);
    }

    // TODO: run the GBA. probably going to be one of the last things that is actually implemented, since manually cycling
    // the emulator is a lot easier to test. heck, this method might not even exist, idk. but, it's here for now.
    void run(string rom_name) {
        assert(0);
    }

    // cycles the GBA CPU once, executing one instruction to completion.
    // maybe this method belongs in an ARM7TDMI class. nobody knows. i don't see the reason for having such a class, so
    // this is staying here for now.
    void cycle() {
        assert(0);
    }

    // returns true if a DMA transfer occurred this cycle.
    bool handle_dma() {
        assert(0);
    }

    bool enabled;

    ARM7TDMI* cpu;
    PPU* ppu;
    Memory* memory;

private:
    alias DMAChannel_t = GBA.DMAChannel;
    GBA.DMAChannel_t[4] dma_channels;
    bool dma_cycle = false;
}
