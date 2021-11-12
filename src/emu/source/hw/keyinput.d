module hw.keyinput;

import hw.memory;
import hw.cpu;

import std.stdio;

import util;

class KeyInput {
    Memory memory;

    this(Memory memory) {
        this.memory = memory;
        this.keyinput = 0x03FF;
    }

    private ushort keycnt;
    private ushort keyinput;

    void write_KEYCNT(int target_byte, ubyte data) {
        
        if (target_byte == 0) {
            keycnt = (keycnt & 0xFF00) | data;
        } else {
            keycnt = (keycnt & 0x00FF) | (data << 8);
        }
    }

    ubyte read_KEYINPUT(int target_byte) {
        // writefln("Reading from INP at %x", target_byte);
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
            return (keycnt & 0xFF00) >> 8;
        }
    }

    void set_key(int code, bool pressed) {
        // if (code == 3) _g_num_log += 10000000;
        if (pressed) {
            keyinput &= ~(0b1 << code);
        } else {
            keyinput |=  (0b1 << code);
        }
    }
}