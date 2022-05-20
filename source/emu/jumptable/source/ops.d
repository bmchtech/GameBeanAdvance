module ops;

import abstracthw.cpu;
import abstracthw.memory;
import util;

void add(T : IARM7TDMI)(T cpu, Reg rd, Word operand1, Word operand2, bool writeback = true, bool set_flags = true) {
    Word result = operand1 + operand2;

    if (writeback) cpu.set_reg(rd, result);

    if (set_flags) {
        cpu.set_flag(Flag.N, get_nth_bit(result, 31));
        cpu.set_flag(Flag.Z, result == 0);

        cpu.set_flag(Flag.C, (cast(u64) operand1 + cast(u64) operand2) >= 0x1_0000_0000);
        cpu.set_flag(Flag.V, ((operand1 >> 31) == (operand2 >> 31)) && ((operand1 >> 31) ^ (result >> 31)));
    }
}

void sub(T : IARM7TDMI)(T cpu, Reg rd, Word operand1, Word operand2, bool writeback = true, bool set_flags = true) {
    Word result = operand1 - operand2;

    if (writeback) cpu.set_reg(rd, result);

    if (set_flags) {
        cpu.set_flags_NZ(result);

        cpu.set_flag(Flag.C, cast(u64) operand2 <= cast(u64) operand1);
        cpu.set_flag(Flag.V, ((operand2 >> 31) ^ (operand1 >> 31)) && ((operand2 >> 31) == (result >> 31)));
    }
}

void adc(T : IARM7TDMI)(T cpu, Reg rd, Word operand1, Word operand2, bool writeback = true, bool set_flags = true) {
    Word result = operand1 + operand2 + cpu.get_flag(Flag.C);

    if (writeback) cpu.set_reg(rd, result);

    if (set_flags) {
        cpu.set_flags_NZ(result);

        cpu.set_flag(Flag.C, (cast(u64) operand1 + cast(u64) operand2 + cpu.get_flag(Flag.C)) >= 0x1_0000_0000);
        cpu.set_flag(Flag.V, ((operand1 >> 31) == (operand2 >> 31)) && ((operand1 >> 31) ^ (result >> 31)));
    }
}

void sbc(T : IARM7TDMI)(T cpu, Reg rd, Word operand1, Word operand2, bool writeback = true, bool set_flags = true) {
    u64 operand2_carry = cast(u64) operand2 + cast(u64) (cpu.get_flag(Flag.C) ? 0 : 1);
    Word result = operand1 - cast(u32) operand2_carry;

    if (writeback) cpu.set_reg(rd, result);

    if (set_flags) {
        cpu.set_flags_NZ(result);

import std.stdio;
        cpu.set_flag(Flag.C, operand2_carry <= operand1);
        cpu.set_flag(Flag.V, ((operand2 >> 31) ^ (operand1 >> 31)) && ((operand2 >> 31) == (result >> 31)));
    }
}

void mov(T : IARM7TDMI)(T cpu, Reg rd, Word immediate, bool set_flags = true) {
    cpu.set_reg(rd, immediate);
    if (set_flags) cpu.set_flags_NZ(immediate);
}

void cmp(T : IARM7TDMI)(T cpu, Reg rd, Word operand1, Word operand2, bool set_flags = true) {
    sub(cpu, rd, operand1, operand2, false, set_flags);
}

void and(T : IARM7TDMI)(T cpu, Reg rd, Word operand1, Word operand2, bool writeback = true, bool set_flags = true) {
    Word result = operand1 & operand2;
    if (set_flags) cpu.set_flags_NZ(result);
    if (writeback) cpu.set_reg(rd, result);
}

void rsb(T : IARM7TDMI)(T cpu, Reg rd, Word operand1, Word operand2, bool writeback = true, bool set_flags = true) {
    sub(cpu, rd, operand2, operand1, writeback, set_flags);
}

void rsc(T : IARM7TDMI)(T cpu, Reg rd, Word operand1, Word operand2, bool writeback = true, bool set_flags = true) {
    sbc(cpu, rd, operand2, operand1, writeback, set_flags);
}

void tst(T : IARM7TDMI)(T cpu, Reg rd, Word operand1, Word operand2, bool set_flags = true) {
    and(cpu, rd, operand1, operand2, false, set_flags);
}

void teq(T : IARM7TDMI)(T cpu, Reg rd, Word operand1, Word operand2, bool set_flags = true) {
    eor(cpu, rd, operand1, operand2, false, set_flags);
}

void eor(T : IARM7TDMI)(T cpu, Reg rd, Word operand1, Word operand2, bool writeback = true, bool set_flags = true) {
    Word result = operand1 ^ operand2;
    if (set_flags) cpu.set_flags_NZ(result);
    if (writeback) cpu.set_reg(rd, result);
}

void lsl(T : IARM7TDMI)(T cpu, Reg rd, Word operand, Word shift, bool writeback = true, bool set_flags = true) {
    Word result;
    bool carry;

    if (shift < 32) {
        result = operand << shift;
        carry  = get_nth_bit(operand, 32 - shift);
    } else if (shift == 32) {
        result = 0;
        carry  = get_nth_bit(operand, 0);
    } else { // shift > 32
        result = 0;
        carry  = false;
    }

    if (set_flags) {
        cpu.set_flags_NZ(result);
        cpu.set_flag(Flag.C, carry);
    }

    if (writeback) cpu.set_reg(rd, result);
}

void lsr(T : IARM7TDMI)(T cpu, Reg rd, Word operand, Word shift, bool writeback = true, bool set_flags = true) {
    Word result;
    bool carry;

    if        (shift == 0) {
        result = operand;
        carry = cpu.get_flag(Flag.C);
        writeback = false; // TODO: CHECK THIS!!!!
    } else if (shift < 32) {
        result = operand >> shift;
        carry  = get_nth_bit(operand, shift - 1);
    } else if (shift == 32) {
        result = 0;
        carry  = get_nth_bit(operand, 31);
    } else { // shift > 32
        result = 0;
        carry  = false;
    }

    if (set_flags) {
        cpu.set_flags_NZ(result);
        cpu.set_flag(Flag.C, carry);
    }
    
    if (writeback) cpu.set_reg(rd, result);
}

void asr(T : IARM7TDMI)(T cpu, Reg rd, Word operand, Word shift, bool writeback = true, bool set_flags = true) {
    Word result;
    bool carry;

    if        (shift == 0) {
        result = operand;
        carry  = cpu.get_flag(Flag.C);
    } else if (shift < 32) {
        result = cpu.sext_32(operand >> shift, 32 - shift);
        carry  = get_nth_bit(operand, shift - 1);
    } else { // shift >= 32
        result = get_nth_bit(operand, 31) ? ~0 : 0;
        carry  = get_nth_bit(operand, 31);
    }

    if (set_flags) {
        cpu.set_flags_NZ(result);
        cpu.set_flag(Flag.C, carry);
    }
    
    if (writeback) cpu.set_reg(rd, result);
}

void ror(T : IARM7TDMI)(T cpu, Reg rd, Word operand, Word shift, bool writeback = true, bool set_flags = true) {
    Word result = rotate_right(operand, shift);

    if (shift == 0) {
        cpu.set_flags_NZ(operand);
        return; // CHECK THIS
    }

    if ((shift & 0x1F) == 0) {
        cpu.set_flag(Flag.C, get_nth_bit(operand, 31));
    } else {
        cpu.set_flag(Flag.C, get_nth_bit(operand, (shift & 0x1F) - 1));
    }

    if (writeback) cpu.set_reg(rd, result);
    if (set_flags) cpu.set_flags_NZ(result);
}

void tst(T : IARM7TDMI)(T cpu, Reg rd, Word operand1, Word operand2) {
    cpu.and(rd, operand1, operand2, false);
}

void neg(T : IARM7TDMI)(T cpu, Reg rd, Word immediate, bool writeback = true, bool set_flags = true) {
    sub(cpu, rd, 0, immediate, writeback, set_flags);
}

void cmn(T : IARM7TDMI)(T cpu, Reg rd, Word operand1, Word operand2, bool set_flags = true) {
    cpu.add(rd, operand1, operand2, false, set_flags);
}

void orr(T : IARM7TDMI)(T cpu, Reg rd, Word operand1, Word operand2, bool writeback = true, bool set_flags = true) {
    Word result = operand1 | operand2;
    if (set_flags) cpu.set_flags_NZ(result);
    if (writeback) cpu.set_reg(rd, result);
}

void mul(T : IARM7TDMI)(T cpu, Reg rd, Word operand1, Word operand2, bool writeback = true, bool set_flags = true) {
    Word result = operand1 * operand2;

    int idle_cycles = calculate_multiply_cycles!true(operand1);
    for (int i = 0; i < idle_cycles; i++) cpu.run_idle_cycle();

    if (set_flags) cpu.set_flags_NZ(result);
    if (writeback) cpu.set_reg(rd, result);
}

void bic(T : IARM7TDMI)(T cpu, Reg rd, Word operand1, Word operand2, bool writeback = true, bool set_flags = true) {
    Word result = operand1 & ~operand2;
    if (set_flags) cpu.set_flags_NZ(result);
    if (writeback) cpu.set_reg(rd, result);
}

void mvn(T : IARM7TDMI)(T cpu, Reg rd, Word immediate, bool set_flags = true) {
    cpu.set_reg(rd, ~immediate);
    if (set_flags) cpu.set_flags_NZ(~immediate);
}

void set_flags_NZ(T : IARM7TDMI)(T cpu, Word result) {
    cpu.set_flag(Flag.Z, result == 0);
    cpu.set_flag(Flag.N, get_nth_bit(result, 31));
}

void ldr(T : IARM7TDMI)(T cpu, Reg rd, Word address) {
    cpu.set_reg(rd, cpu.read_word_and_rotate(address, AccessType.NONSEQUENTIAL));
    cpu.run_idle_cycle();
}

void ldrh(T : IARM7TDMI)(T cpu, Reg rd, Word address) {
    cpu.set_reg(rd, cpu.read_half_and_rotate(address, AccessType.NONSEQUENTIAL));
    cpu.run_idle_cycle();
}

void ldrb(T : IARM7TDMI)(T cpu, Reg rd, Word address) {
    cpu.set_reg(rd, cpu.read_byte(address, AccessType.NONSEQUENTIAL));
    cpu.run_idle_cycle();
}

void ldrsb(T : IARM7TDMI)(T cpu, Reg rd, Word address) {
    cpu.set_reg(rd, cpu.sext_32(cpu.read_byte(address, AccessType.NONSEQUENTIAL), 8));
    cpu.run_idle_cycle();
}

void ldrsh(T : IARM7TDMI)(T cpu, Reg rd, Word address) {
    if (address & 1) ldrsb(cpu, rd, address);
    else {
        cpu.set_reg(rd, cpu.sext_32(cpu.read_half(address, AccessType.NONSEQUENTIAL), 16));
        cpu.run_idle_cycle();
        cpu.set_pipeline_access_type(AccessType.NONSEQUENTIAL);
    }
}

void str(T : IARM7TDMI)(T cpu, Reg rd, Word address) {
    Word value = cpu.get_reg(rd);
    if (unlikely(rd == pc)) value += 4;

    cpu.write_word(address & ~3, value, AccessType.NONSEQUENTIAL);
    cpu.set_pipeline_access_type(AccessType.NONSEQUENTIAL);
}

void strh(T : IARM7TDMI)(T cpu, Reg rd, Word address) {
    Word value = cpu.get_reg(rd);
    if (unlikely(rd == pc)) value += 4;

    cpu.write_half(address & ~1, value & 0xFFFF, AccessType.NONSEQUENTIAL);
    cpu.set_pipeline_access_type(AccessType.NONSEQUENTIAL);
}

void strb(T : IARM7TDMI)(T cpu, Reg rd, Word address) {
    Word value = cpu.get_reg(rd);
    if (unlikely(rd == pc)) value += 4;

    cpu.write_byte(address, value & 0xFF, AccessType.NONSEQUENTIAL);
    cpu.set_pipeline_access_type(AccessType.NONSEQUENTIAL);
}

void swi(T : IARM7TDMI)(T cpu) {
    cpu.raise_exception!(CpuException.SoftwareInterrupt);
}

s32 sext_32(IARM7TDMI cpu, u32 value, u32 size) {
    auto negative = get_nth_bit(value, size - 1);
    if (negative) value |= (((1 << (32 - size)) - 1) << size);
    return value;
}

s64 sext_64(IARM7TDMI cpu, u64 value, u64 size) {
    auto negative = (value >> (size - 1)) & 1;
    if (negative) value |= (((1UL << (64UL - size)) - 1UL) << size);
    return value;
}

Word read_word_and_rotate(IARM7TDMI cpu, Word address, AccessType access_type) {
    Word value = cpu.read_word(address & ~3, access_type);
    auto misalignment = address & 0b11;
    return rotate_right(value, misalignment * 8);
}

Word read_half_and_rotate(IARM7TDMI cpu, Word address, AccessType access_type) {
    Word value = cpu.read_half(address & ~1, access_type);
    auto misalignment = address & 0b1;
    return rotate_right(value, misalignment * 8);
}

static int calculate_multiply_cycles(bool signed)(Word operand) {
    int m = 4;

    static if (signed) {
        if      ((operand >>  8) == 0xFFFFFF) m = 1;
        else if ((operand >> 16) == 0xFFFF)   m = 2;
        else if ((operand >> 24) == 0xFF)     m = 3;
    }

    if      ((operand >> 8)  == 0x0) m = 1;
    else if ((operand >> 16) == 0x0) m = 2;
    else if ((operand >> 24) == 0x0) m = 3;

    import std.stdio;
    writefln("SUSSY BAKA: %x", m);
    return m;
}