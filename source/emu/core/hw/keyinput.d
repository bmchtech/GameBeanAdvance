module hw.keyinput;

import hw.memory;
import hw.cpu;
import hw.interrupts;

import std.stdio;

import util;

enum GBAKeyVanilla {
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

final class KeyInput {
    Memory memory;
    void delegate(uint) interrupt_cpu;

    this(Memory memory) {
        this.memory = memory;
        this.keyinput = 0x03FF;
    }

    void set_interrupt_cpu(void delegate(uint) interrupt_cpu) {
        this.interrupt_cpu = interrupt_cpu;
    }

    enum IRQCondition {
        OR  = 0,
        AND = 1
    }

    private ushort keycnt;
    private IRQCondition irq_condition;
    private bool irq_enabled;

    private ushort keyinput;

    void write_KEYCNT(int target_byte, ubyte data) {
        if (target_byte == 0) {
            keycnt = (keycnt & 0xFF00) | data;
        } else {
            keycnt = (keycnt & 0x00FF) | ((data & 3) << 8);

            irq_condition = cast(IRQCondition) get_nth_bit(data, 6);
            irq_enabled   = cast(IRQCondition) get_nth_bit(data, 6);
        }

        if (should_interrupt()) interrupt_cpu(Interrupt.KEYPAD);
    }

    ubyte read_KEYINPUT(int target_byte) {
        if (target_byte == 0) {
            return (keyinput & 0x00FF) >> 0;
        } else {
            return (keyinput & 0xFF00) >> 8;
        }
    }

    ubyte read_KEYCNT(int target_byte) {
        if (target_byte == 0) {
            return (keycnt & 0x00FF) >> 0;
        } else {
            return cast(ubyte) (((keycnt & 0xFF00) >> 8) | (cast(ubyte) irq_condition << 6) | (irq_enabled << 7));
        }
    }

    void set_key(GBAKeyVanilla code, bool pressed) {
        if (pressed) {
            keyinput &= ~(0b1 << code);
        } else {
            keyinput |=  (0b1 << code);
        }

        if (should_interrupt()) interrupt_cpu(Interrupt.KEYPAD);
    }

    import std.stdio;

    bool should_interrupt() {
        uint inverted_keyinput = ~keyinput & 0x3FF;
        final switch (irq_condition) {
            case IRQCondition.OR:
                return (keycnt & inverted_keyinput) != 0;
            case IRQCondition.AND:
                return (keycnt & inverted_keyinput) == keycnt;
        }
    }
}
