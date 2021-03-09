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
        this.memory  = memory;
        this.cpu     = new ARM7TDMI(memory);
        this.cpu     = new PPU(memory);
        this.enabled = false;

        // TODO: figure out a better way to do logging
    }

    struct DMAChannel {
        uint[]   source;
        uint[]   dest;
        ushort[] cnt_l;
        ushort[] cnt_h;

        uint     source_buf;
        uint     dest_buf;
        ushort   size_buf;
        
        bool     enabled;
    }
    
    void run(string rom_name) {
        get_rom_as_bytes(rom_name, memory.rom_1, SIZE_ROM_1);
        *cpu.pc = OFFSET_ROM_1;

        enabled = true;
        // std::thread t(gba_thread, this);
        // t.detach();
    }

    // cycles the GBA CPU once, executing one instruction to completion.
    // maybe this method belongs in an ARM7TDMI class. nobody knows. i don't see the reason for having such a class, so
    // this is staying here for now.
    void cycle() {
        cpu.cycle();

        ppu.cycle();
        ppu.cycle();
        ppu.cycle();
        ppu.cycle();
    }

    // returns true if a DMA transfer occurred this cycle.
    bool handle_dma() {
        assert(0);
    }

    bool enabled;

    ARM7TDMI* cpu;
    PPU*      ppu;
    Memory*   memory;

private:
    alias DMAChannel_t = GBA.DMAChannel;
    GBA.DMAChannel_t[4] dma_channels;
    bool dma_cycle = false;
}
