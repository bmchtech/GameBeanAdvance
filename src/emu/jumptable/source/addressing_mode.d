module addressing_mode;

import abstracthw.cpu;
import util;
import ops;

import std.stdio;

static void create_addressing_mode_2(bool register, bool pre, bool up, bool byte_access, bool writeback, bool load)(IARM7TDMI cpu, Word opcode) {
    Reg rd = get_nth_bits(opcode, 12, 16);
    Reg rn = get_nth_bits(opcode, 16, 20);
    
    static if (register) {
        // magic!
        Word address = 0;
    } else {
        auto offset = get_nth_bits(opcode, 0, 12);
        enum dir = up ? 1 : -1;

        static if (pre) {
            Word address = cpu.get_reg(rn) + dir * offset;
        } else {
            Word address = cpu.get_reg(rn);
        }
    }

    writefln("%x %x %x %x", address, rd, load, cpu.get_reg(rd));
    static if ( load &&  byte_access) cpu.ldrb(rd, address);
    static if ( load && !byte_access) cpu.ldr (rd, address);
    static if (!load &&  byte_access) cpu.strb(rd, address);
    static if (!load && !byte_access) cpu.str (rd, address);
}
