module gba;

public {
    import memory;
    import arm7tdmi;
    import ppu;
    import cpu_state;
    import util;
}

enum CART_SIZE = 0x1000000;

enum ROM_ENTRY_POINT = 0x000;
enum GAME_TITLE_OFFSET = 0x0A0;
enum GAME_TITLE_SIZE = 12;

enum GBAKey {
    A = 0,
    B = 1,
    SELECT = 2,
    START = 3,
    RIGHT = 4,
    LEFT = 5,
    UP = 6,
    DOWN = 7,
    R = 8,
    L = 9
}

class GBA {
public:
    ARM7TDMI cpu;
    PPU      ppu;
    Memory   memory;

    this(Memory memory) {
        this.memory  = memory;
        this.cpu     = new ARM7TDMI(memory);
        this.ppu     = new PPU(memory);
        this.enabled = false;

        cpu.set_mode(arm7tdmi.ARM7TDMI.MODE_SYSTEM);
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
    
    void load_rom(string rom_name) {
        ubyte[] rom = get_rom_as_bytes(rom_name);
        cpu.memory.main[Memory.OFFSET_ROM_1 .. Memory.OFFSET_ROM_1 + rom.length] = rom[0 .. rom.length];

        *cpu.pc = memory.OFFSET_ROM_1;
        enabled = true;
    }

    // cycles the GBA CPU once, executing one instruction to completion.
    // maybe this method belongs in an ARM7TDMI class. nobody knows. i don't see the reason for having such a class, so
    // this is staying here for now.
    void cycle() {
        cpu.cycle();
        cpu.cycle();
        cpu.cycle();
        cpu.cycle();

        ppu.cycle();
    }

    // returns true if a DMA transfer occurred this cycle.
    bool handle_dma() {
        assert(0);
    }

    bool enabled;

private:
    alias DMAChannel_t = GBA.DMAChannel;
    GBA.DMAChannel_t[4] dma_channels;
    bool dma_cycle = false;
}
