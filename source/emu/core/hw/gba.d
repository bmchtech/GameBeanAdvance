module hw.gba;

import hw.memory;
import hw.ppu;
import hw.cpu;
import hw.apu;
import hw.dma;
import hw.timers;
import hw.interrupts;
import hw.keyinput;
import hw.beancomputer;
import hw.sio.sio;

import scheduler;
import util;

import ui.device;

import tools.profiler.profiler;

import std.math;
import std.stdio;

enum CART_SIZE = 0x1000000;

enum ROM_ENTRY_POINT = 0x000;
enum GAME_TITLE_OFFSET = 0x0A0;
enum GAME_TITLE_SIZE = 12;

// 2 ^ 64 can last for up to 3000 years
ulong num_cycles = 0;

// globals, sorry
__gshared bool     g_profile_gba;
__gshared Profiler g_profiler;

final class GBA {
public:
    ARM7TDMI         cpu;
    PPU              ppu;
    APU              apu;
    Memory           memory;
    DMAManager       dma_manager;
    TimerManager     timers;
    InterruptManager interrupt_manager;
    KeyInput         key_input;
    BeanComputer     beancomputer;
    SIO              sio;
    // DirectSound  direct_sound;

    Scheduler        scheduler;

    this(Memory memory, KeyInput key_input, ubyte[] bios, bool is_bean_computer) {
        scheduler = new Scheduler(memory);

        this.memory            = memory;
        this.cpu               = new ARM7TDMI(memory);
        this.interrupt_manager = new InterruptManager(&cpu.enable, &enable);
        this.ppu               = new PPU(memory, scheduler, &interrupt_manager.interrupt, &on_hblank, &on_vblank);
        this.apu               = new APU(memory, scheduler, &on_fifo_empty);
        this.dma_manager       = new DMAManager(memory, scheduler, &interrupt_manager.interrupt);
        this.timers            = new TimerManager(memory, scheduler, this, &interrupt_manager.interrupt, &on_timer_overflow);
        this.sio               = new SIO(&interrupt_manager.interrupt, scheduler);
        this.beancomputer      = new BeanComputer();
        this.key_input         = key_input;

        key_input.set_interrupt_cpu = &interrupt_manager.interrupt;

        // this.direct_sound = new DirectSound(memory);

        MMIO mmio = new MMIO(this, ppu, apu, dma_manager, timers, interrupt_manager, key_input, beancomputer, sio, memory, is_bean_computer);
        memory.set_mmio(mmio);
        memory.set_cpu(this.cpu);
        memory.set_ppu(this.ppu);
        memory.set_scheduler(scheduler);

        this.enabled = false;

        cpu.set_mode!MODE_SYSTEM;
        cpu.set_interrupt_manager(this.interrupt_manager);

        // bios
        memory.bios[0 .. bios.length] = bios[0 .. bios.length];
    }

    void set_frontend(MultiMediaDevice device) {
        ppu.set_frontend_vblank_callback(&device.present_videobuffers);
        apu.set_frontend_audio_callback(&device.push_sample);

        device.set_update_key_callback(&key_input.set_key);
    }

    void set_internal_sample_rate(uint sample_rate) {
        apu.set_internal_sample_rate(sample_rate);
    }

    void skip_bios_bootscreen() {
        cpu.skip_bios();
    }

    void load_rom(string rom_path) {
        load_rom(load_rom_as_bytes(rom_path));
    }

    void load_rom(ubyte[] rom) {
        cpu.memory.load_rom(rom);
        cpu.refill_pipeline();
        enabled = true; 
    }
 
    long extra_cycles = 0;
    void cycle_at_least_n_times(int n) {
        n -= extra_cycles;

        ulong target_time = scheduler.get_current_time() + n;
        while (target_time > scheduler.get_current_time()) {
            cycle_components();
        }

        // warning(format("Cycled to %d.", scheduler.get_current_time()));

        extra_cycles = scheduler.get_current_time() - target_time;
    }

    pragma(inline, true) void cycle_components() {
        if (!cpu.halted) {
            cpu.run_instruction();
        } else {
            // ty organharvester for the halt skipping idea!
            scheduler.tick_to_next_event();
            scheduler.process_events();

            if (interrupt_manager.has_irq()) {
                cpu.raise_exception!(CpuException.IRQ);
            }
        }
    }

    void interrupt_cpu() {
        return;
    }

    void on_timer_overflow(int timer_id) {
        apu.on_timer_overflow(timer_id);
    }

    void on_fifo_empty(DirectSound fifo_type) {
        dma_manager.maybe_refill_fifo(fifo_type);
    }

    void on_hblank(uint scanline) {
        dma_manager.on_hblank(scanline);
    }

    void on_vblank() {
        dma_manager.on_vblank();
    }

    void disable() {
        ppu.disable();
        enabled = false;
    }

    void enable() {
        ppu.enable();
        enabled = true;
    }

    // is this sketchy code? it might be... but its 1 am
    // TODO: fix sketchy code
    void write_HALTCNT(ubyte data) {
        if (get_nth_bit(data, 7)) {
            // idk figure out stopping
            disable();
        } else {
            // halt
            cpu.halt();
        }
    }

    bool enabled;

private:
    bool dma_cycle = false;
    uint idle_cycles = 0;
    
}

enum GBAKeyBeanComputer {
    A = 0,
    B,
    C,
    D,
    E,
    F,
    G,
    H,
    I,
    J,
    K,
    L,
    M,
    N,
    O,
    P,
    Q,
    R,
    S,
    T,
    U,
    V,
    W,
    X,
    Y,
    Z,
    SHIFT,
    CTRL,
    ALT,
    SUPER,
    ESCAPE,

    NUMBER_0 = 32,
    NUMBER_1,
    NUMBER_2,
    NUMBER_3,
    NUMBER_4,
    NUMBER_5,
    NUMBER_6,
    NUMBER_7,
    NUMBER_8,
    NUMBER_9,
    COMMA,
    PERIOD,
    SLASH,
    SEMICOLON,
    QUOTE,
    LBRACKET,
    RBRACKET,
    BACKSLASH,
    MINUS,
    PLUS,
    TAB,
    RETURN,
    BACKSPACE,
    RIGHT,
    LEFT,
    UP,
    DOWN,
}