module hw.beancomputer;

import std.stdio;

final class BeanComputer {
    enum SUPPORT_MAGIC   = 0xBEA7;
    enum SUPPORT_VERSION = 1;

    this() {
        this.keyinput = 0x0FFF_FFFF_FFFF_FFFF;
    }

    private ulong keyinput;

    ubyte read_SUPPORT(int target_byte) {
        final switch (target_byte) {
            case 0b00: return (SUPPORT_VERSION >> 0) & 0xFF;
            case 0b01: return (SUPPORT_VERSION >> 8) & 0xFF;
            case 0b10: return (SUPPORT_MAGIC   >> 0) & 0xFF;
            case 0b11: return (SUPPORT_MAGIC   >> 8) & 0xFF;
        }
    }

    ubyte read_KEYBOARD1(int target_byte) {
        return (keyinput >> (8 * target_byte)) & 0xFF;
    }

    ubyte read_KEYBOARD2(int target_byte) {
        return (keyinput >> (8 * target_byte + 32)) & 0xFF;
    }

    void set_key(int code, bool pressed) {
        if (pressed) keyinput &= ~(0b1 << code);
        else         keyinput |=  (0b1 << code);
    }
}