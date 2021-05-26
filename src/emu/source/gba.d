module gba;

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
    // DirectSound  direct_sound;

    this(Memory memory) {
        this.memory            = memory;
        this.cpu               = new ARM7TDMI(memory, &bios_call);
        this.interrupt_manager = new InterruptManager(&interrupt_cpu);
        this.ppu               = new PPU(memory, &interrupt_manager.interrupt);
        this.apu               = new APU(memory, &on_fifo_empty);
        this.dma_manager       = new DMAManager(memory);
        this.timers            = new TimerManager(memory, &on_timer_overflow);
        // this.direct_sound = new DirectSound(memory);

        MMIO mmio = new MMIO(ppu, apu, dma_manager, timers, interrupt_manager);
        memory.set_mmio(mmio);

        this.enabled = false;

        cpu.set_mode(cpu.MODE_SYSTEM);

        // load bios
        ubyte[] bios = get_rom_as_bytes("source/bios.gba");
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

    // interrupt_code must be one-hot
    void interrupt_cpu() {
        cpu.interrupt();
    }

    void on_timer_overflow(int timer_id) {
        // do we have to tell direct sound to request another sample from dma?
        apu.on_timer_overflow(timer_id);
    }

    void on_fifo_empty(DirectSound fifo_type) {
        dma_manager.maybe_refill_fifo(fifo_type);
    }

    void bios_call(int bios_function) {
        switch (bios_function) {
            case 0x01: { // Register RAM Reset
                // note entry 7 is special so it isnt included
                uint[7] ram_clear_offsets = [
                    memory.OFFSET_WRAM_BOARD,
                    memory.OFFSET_WRAM_CHIP,
                    memory.OFFSET_PALETTE_RAM,
                    memory.OFFSET_VRAM,
                    memory.OFFSET_OAM,
                    0x4000120, // TODO: replace with the actual registers once theyre implemented
                    0x4000060
                ];

                uint[7] ram_clear_sizes = [
                    memory.SIZE_WRAM_BOARD,
                    memory.SIZE_WRAM_CHIP - 0x200,
                    memory.SIZE_PALETTE_RAM,
                    memory.SIZE_VRAM,
                    memory.SIZE_OAM,
                    0x2C,
                    0x48
                ];

                for (int i = 0; i < 7; i++)
                    if (get_nth_bit(cpu.regs[0], i)) cpu.memory.main[ram_clear_offsets[i] .. (ram_clear_offsets[i] + ram_clear_sizes[i])] = 0;
                
                if (get_nth_bit(cpu.regs[0], 8)) {
                    cpu.memory.main[0x0400_0000 .. 0x400_0060] = 0;
                    cpu.memory.main[0x0400_00B0 .. 0x400_0100] = 0;
                    cpu.memory.main[0x0400_0120 .. 0x400_0808] = 0;
                }

                break;
            }

            case 0x04: {
                // import std.stdio;
                // writefln("%x, %x", cpu.regs[0], cpu.regs[1]);
                cpu.halted = true;
                // *cpu.pc += 4;
                break;
            }

            case 0x05: { // VBlankIntrWait
                cpu.regs[0] = 1;
                cpu.regs[1] = 1;
                goto case 0x04;
            }

            case 0x06: { // Division
                int numerator   = cast(int) cpu.regs[0];
                int denominator = cast(int) cpu.regs[1];

                cpu.regs[3] = cpu.regs[0] / cpu.regs[1];
                cpu.regs[0] = cast(uint) numerator / denominator;
                cpu.regs[1] = cast(uint) numerator % denominator; // TEST PLEASE

                cpu.cycles_remaining += 5;
                break;
            }

            case 0x0B: { // CpuSet
                uint source_address = cpu.regs[0];
                uint dest_address   = cpu.regs[1];
                // warning(format("%x %x %x", cpu.regs[0], cpu.regs[1], cpu.regs[2]));
                uint length         = get_nth_bits(cpu.regs[2], 0, 21);
                bool is_fill        = get_nth_bit (cpu.regs[2], 24); // if false, this is a copy
                bool is_word        = get_nth_bit (cpu.regs[2], 26); // if false, we're transferring halfwords

                for (int i = 0; i < length; i++) {
                    if (is_word) {
                        memory.write_word    (dest_address, memory.read_word(source_address));
                        dest_address += 4;
                    } else {
                        memory.write_halfword(dest_address, memory.read_halfword(source_address));
                        dest_address += 2;
                    }

                    if (!is_fill) {
                        if (is_word) {
                            source_address += 4;
                        } else {
                            source_address += 2;
                        }
                    }
                }

                break;
            }

            case 0x0C: { // CpuFastSet
                uint source_address = cpu.regs[0];
                uint dest_address   = cpu.regs[1];
                uint length         = get_nth_bits(cpu.regs[2], 0, 21);
                bool is_fill        = get_nth_bit (cpu.regs[2], 24); // if false, this is a copy

                // warning(format("FAST %x %x %x", cpu.regs[0], cpu.regs[1], cpu.regs[2]));
                if ((length & 0b111) != 0) length = (length & 0xFFFFFFF8) + 8; // round up if not a multiple of 8

                for (int i = 0; i < length; i++) {
                    // warning(format("%x", dest_address));
                    memory.write_word(dest_address, memory.read_word(source_address));
                    dest_address += 4;

                    if (!is_fill) {
                        source_address += 4;
                    }
                }

                break;
            }
        
            case 0x11: { // LZ77UnCompReadNormalWrite8bit
                uint source_address = cpu.regs[0];
                uint dest_address   = cpu.regs[1];

                uint data_size = get_nth_bits(memory.read_word(source_address), 8, 32);
                source_address += 4;
                
                cpu.cycles_remaining += 20 * data_size; // rough estimate

                uint data_read = 0;
                while (data_read < data_size) {
                    ubyte flag_data = memory.read_byte(source_address);
                    source_address++;
                    data_read++;

                    uint mask = 0b1000_0000;
                    for (int i = 0; i < 8; i++) {
                        if (flag_data & mask) { // this bytes compressed
                            ushort compressed_data = memory.read_halfword(source_address);
                            source_address += 2;

                            uint disp = (get_nth_bits(compressed_data, 0, 4) << 8) | get_nth_bits(compressed_data, 8, 16);
                            for (int j = 0; j < get_nth_bits(compressed_data, 4, 8) + 3; j++) {
                                memory.write_byte(dest_address, memory.read_byte(dest_address - disp - 1));
                                dest_address++;
                            }

                            data_read += 2;
                        } else { // this bytes uncompressed
                            memory.write_byte(dest_address, memory.read_byte(source_address));
                            source_address++;
                            dest_address++;
                            data_read += 1;
                        }

                        mask >>= 1;
                    }
                }

                break;
            }

            default: 
                warning(format("Invalid BIOS Call: %x", bios_function));
        }
    }

    bool enabled;

private:
    bool dma_cycle = false;
    int idle_cycles = 0;
    
}
