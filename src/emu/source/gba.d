module gba;

public {
    import memory;
    import ppu;
    import cpu;
    import util;
    import dma;
    import timers;
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
    ARM7TDMI     cpu;
    PPU          ppu;
    Memory       memory;
    DMAManager   dma_manager;
    TimerManager timers;

    this(Memory memory) {
        this.memory      = memory;
        this.cpu         = new ARM7TDMI(memory, &bios_call);
        this.ppu         = new PPU(memory);
        this.dma_manager = new DMAManager(memory);
        this.timers      = new TimerManager(memory);

        this.enabled = false;

        cpu.set_mode(cpu.MODE_SYSTEM);
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

        ppu.cycle();
    }

    void maybe_cycle_cpu() {
        if (!dma_manager.handle_dma()) {
            cpu.cycle();
            timers.cycle();
        }
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
                uint length         = get_nth_bits(cpu.regs[2], 0, 21);
                bool is_fill        = get_nth_bit (cpu.regs[2], 24); // if false, this is a copy
                bool is_halfword    = get_nth_bit (cpu.regs[2], 26); // if false, we're transferring words

                for (int i = 0; i < length; i++) {
                    if (is_halfword) {
                        memory.write_halfword(dest_address, memory.read_halfword(source_address));
                        dest_address += 2;
                    } else {
                        memory.write_word    (dest_address, memory.read_halfword(source_address));
                        dest_address += 2;
                    }

                    if (!is_fill) {
                        source_address += 2;
                    }
                }

                break;
            }

            case 0x0C: { // CpuFastSet
                uint source_address = cpu.regs[0];
                uint dest_address   = cpu.regs[1];
                uint length         = get_nth_bits(cpu.regs[2], 0, 21);
                bool is_fill        = get_nth_bit (cpu.regs[2], 24); // if false, this is a copy

                if ((length & 0b111) != 0) length = (length & 0xFFFFFFF8) + 1; // round up if not a multiple of 8

                for (int i = 0; i < length; i++) {
                    memory.write_word(dest_address, memory.read_halfword(source_address));
                    dest_address += 2;

                    if (!is_fill) {
                        source_address += 2;
                    }
                }

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
