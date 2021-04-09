module gba;

public {
    import memory;
    import ppu;
    import cpu;
    import util;
    import dma;
}

enum CART_SIZE = 0x1000000;

enum ROM_ENTRY_POINT = 0x000;
enum GAME_TITLE_OFFSET = 0x0A0;
enum GAME_TITLE_SIZE = 12;

enum GBAKey {
    A      = 0,
    B      = 1,
    SELECT = 2,
    START  = 3,
    RIGHT  = 4,
    LEFT   = 5,
    UP     = 6,
    DOWN   = 7,
    R      = 8,
    L      = 9
}

class GBA {
public:
    ARM7TDMI   cpu;
    PPU        ppu;
    Memory     memory;
    DMAManager dma_manager;

    this(Memory memory) {
        this.memory      = memory;
        this.cpu         = new ARM7TDMI(memory, &bios_call);
        this.ppu         = new PPU(memory);
        this.dma_manager = new DMAManager(memory);

        this.enabled = false;

        cpu.set_mode(cpu.MODE_SYSTEM);
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
        maybe_cycle_cpu();
        maybe_cycle_cpu();
        maybe_cycle_cpu();
        maybe_cycle_cpu();

        ppu.cycle();
    }

    void maybe_cycle_cpu() {
        if (!dma_manager.handle_dma()) {
            cpu.cycle();
        }
    }

    void bios_call(int bios_function) {
        switch (bios_function) {
            case 0x06: { // Division
                int numerator   = cast(int) cpu.regs[0];
                int denominator = cast(int) cpu.regs[1];

                cpu.regs[3] = cpu.regs[0] / cpu.regs[1];
                cpu.regs[0] = cast(uint) numerator / denominator;
                cpu.regs[1] = cast(uint) numerator % denominator; // TEST PLEASE

                cpu.cycles_remaining += 5;
                break;
            }

            default: 
                error(format("Invalid BIOS Call: %x", bios_function));
        }
    }

    bool enabled;

private:
    bool dma_cycle = false;
    
}
