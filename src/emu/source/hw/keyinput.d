module hw.keyinput;

import hw.memory;
import hw.cpu;
import hw.interrupts;

import std.stdio;

import util;

class KeyInput {
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
        // writefln("Reading from INP at %x", target_byte);
        if (target_byte == 0) {
            return (keyinput & 0x00FF) >> 0;
        } else {
            return cast(ubyte) (((keyinput & 0xFF00) >> 8) | (cast(ubyte) irq_condition << 6) | (irq_enabled << 7));
        }
    }

    ubyte read_KEYCNT(int target_byte) {
        if (target_byte == 0) {
            return (keycnt & 0x00FF) >> 0;
        } else {
            return (keycnt & 0xFF00) >> 8;
        }
    }

    void set_key(int code, bool pressed) {
        if (pressed) keyinput &= ~(0b1 << code);
        else         keyinput |=  (0b1 << code);

        if (should_interrupt()) interrupt_cpu(Interrupt.KEYPAD);
    }

    bool should_interrupt() {
        final switch (irq_condition) {
            case IRQCondition.OR:
                return (keycnt & keyinput) != 0;
            case IRQCondition.AND:
                return (keycnt & keyinput) == keycnt;
        }
    }
}