module gba;

import std.math;
import std.stdio;

public {
    import memory;
    import ppu;
    import cpu;
    import apu;
    import util;
    import dma;
    import timers;
    import mmio;
    import interrupts;
    import keyinput;
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
    ARM7TDMI         cpu;
    PPU              ppu;
    APU              apu;
    Memory           memory;
    DMAManager       dma_manager;
    TimerManager     timers;
    InterruptManager interrupt_manager;
    KeyInput         key_input;
    // DirectSound  direct_sound;

    this(Memory memory, KeyInput key_input) {
        this.memory            = memory;
        this.cpu               = new ARM7TDMI(memory);
        this.interrupt_manager = new InterruptManager(&interrupt_cpu);
        this.ppu               = new PPU(memory, &interrupt_manager.interrupt, &on_hblank);
        this.apu               = new APU(memory, &on_fifo_empty);
        this.dma_manager       = new DMAManager(memory);
        this.timers            = new TimerManager(memory, &on_timer_overflow);
        this.key_input         = key_input;

        // this.direct_sound = new DirectSound(memory);

        MMIO mmio = new MMIO(ppu, apu, dma_manager, timers, interrupt_manager, key_input);
        memory.set_mmio(mmio);

        this.enabled = false;

        cpu.set_mode(cpu.MODE_SYSTEM);

        // load bios
        ubyte[] bios = get_rom_as_bytes("source/gba_bios.bin");
        cpu.memory.main[Memory.OFFSET_BIOS .. Memory.OFFSET_BIOS + bios.length] = bios[0 .. bios.length];
    }

    void set_internal_sample_rate(uint sample_rate) {
        apu.set_internal_sample_rate(sample_rate);
    }
    
    void load_rom(string rom_name) {
        ubyte[] rom = get_rom_as_bytes(rom_name);
        cpu.memory.main[Memory.OFFSET_ROM_1 .. Memory.OFFSET_ROM_1 + rom.length] = rom[0 .. rom.length];

        *cpu.pc = memory.OFFSET_ROM_1;
        enabled = true; 
    }
 
    void cycle() {
        maybe_cycle_cpu();
        maybe_cycle_cpu();
        maybe_cycle_cpu();
        maybe_cycle_cpu();

        apu.cycle();
        apu.cycle();
        apu.cycle();
        apu.cycle();
        
        ppu.cycle();

        timers.cycle();
        timers.cycle();
        timers.cycle();
        timers.cycle();
    }

    void maybe_cycle_cpu() {
        if (idle_cycles > 0) {
            idle_cycles--;
            return;
        }

        idle_cycles += cpu.cycle();
        idle_cycles += dma_manager.handle_dma();
    }

    void interrupt_cpu() {
        cpu.exception(CpuException.IRQ);
    }

    void on_timer_overflow(int timer_id) {
        // do we have to tell direct sound to request another sample from dma?
        apu.on_timer_overflow(timer_id);
    }

    void on_fifo_empty(DirectSound fifo_type) {
        dma_manager.maybe_refill_fifo(fifo_type);
    }

    void on_hblank() {
        dma_manager.on_hblank();
    }

    bool enabled;

private:
    bool dma_cycle = false;
    int idle_cycles = 0;
    
}
