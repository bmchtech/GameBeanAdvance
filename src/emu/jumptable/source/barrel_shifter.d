module barrel_shifter;

import abstracthw.cpu;
import ops;
import util;

struct BarrelShifter {
    Word result;
    bool carry;
}

BarrelShifter barrel_shift(int shift_type, bool is_immediate)(IARM7TDMI cpu, Word operand, Word shift) {
    Word result;
    bool carry;

    // "static switch" doesnt exist, sadly
    static if (shift_type == 0) { // LSL
        if (shift == 0) {
            result = operand;
            carry  = cpu.get_flag(Flag.C);
        } else if (shift < 32) {
            result = operand << shift;
            carry  = get_nth_bit(operand, 32 - shift);
        } else {
            result = 0;
            carry  = (result == 32) ? get_nth_bit(operand, 0) : 0;
        }
    }

    static if (shift_type == 1) { // LSR
        static if (is_immediate) if (shift == 0) shift = 32;

        if (shift == 0) {
            result = operand;
            carry  = cpu.get_flag(Flag.C);
        } else if (shift < 32) {
            result = operand >> shift;
            carry  = get_nth_bit(operand, shift - 1);
        } else if (shift == 32) {
            result = 0;
            carry  = get_nth_bit(operand, 31);
        } else {
            result = 0;
            carry  = 0;
        }
    }

    static if (shift_type == 2) { // ASR
        static if (is_immediate) if (shift == 0) shift = 32;

        if (shift == 0) {
            result = operand;
            carry  = cpu.get_flag(Flag.C);
        } else if (shift < 32) {
            result = cpu.sext_32(operand >> shift, 32 - shift);
            carry  = get_nth_bit(operand, shift - 1);
        } else {
            result = get_nth_bit(operand, 31) ? 0xFFFFFFFF : 0x00000000;
            carry  = get_nth_bit(operand, 31);
        }
    }

    static if (shift_type == 3) { // ROR
        bool done = false;

        static if (!is_immediate) {
            if ((shift & 0xFF) == 0) {
                result = operand;
                carry  = cpu.get_flag(Flag.C);
                done   = true;
            } else {
                shift &= 0x1F;
                if (shift == 0) shift = 32;
            }
        }

        if (!done) {
            if (shift == 0) {
                result = cpu.get_flag(Flag.C) << 31 | (operand >> 1);
                carry  = get_nth_bit(operand, 0);
            } else {
                result = rotate_right(operand, shift);
                carry  = get_nth_bit(operand, shift - 1);
            }
        }
    }

    return BarrelShifter(result, carry);
}