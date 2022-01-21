module ops;

import abstracthw.cpu;
import abstracthw.memory;
import util;

void add(IARM7TDMI cpu, Reg rd, Word operand1, Word operand2, bool writeback = true, bool set_flags = true) {
    Word result = operand1 + operand2;

    if (writeback) cpu.set_reg(rd, result);

    if (set_flags) {
        cpu.set_flag(Flag.N, get_nth_bit(result, 31));
        cpu.set_flag(Flag.Z, result == 0);

        cpu.set_flag(Flag.C, (cast(u64) operand1 + cast(u64) operand2) >= 0x1_0000_0000);
        cpu.set_flag(Flag.V, ((operand1 >> 31) == (operand2 >> 31)) && ((operand1 >> 31) ^ (result >> 31)));
    }
}

void sub(IARM7TDMI cpu, Reg rd, Word operand1, Word operand2, bool writeback = true, bool set_flags = true) {
    Word result = operand1 - operand2;

    if (writeback) cpu.set_reg(rd, result);

    if (set_flags) {
        cpu.set_flags_NZ(result);

        cpu.set_flag(Flag.C, cast(u64) operand2 <= cast(u64) operand1);
        cpu.set_flag(Flag.V, ((operand2 >> 31) ^ (operand1 >> 31)) && ((operand2 >> 31) == (result >> 31)));
    }
}

void adc(IARM7TDMI cpu, Reg rd, Word operand1, Word operand2, bool writeback = true, bool set_flags = true) {
    Word result = operand1 + operand2 + cpu.get_flag(Flag.C);

    if (writeback) cpu.set_reg(rd, result);

    if (set_flags) {
        cpu.set_flags_NZ(result);

        cpu.set_flag(Flag.C, (cast(u64) operand1 + cast(u64) operand2 + cpu.get_flag(Flag.C)) >= 0x1_0000_0000);
        cpu.set_flag(Flag.V, ((operand1 >> 31) == (operand2 >> 31)) && ((operand1 >> 31) ^ (result >> 31)));
    }
}

void sbc(IARM7TDMI cpu, Reg rd, Word operand1, Word operand2, bool writeback = true, bool set_flags = true) {
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

void mov(IARM7TDMI cpu, Reg rd, Word immediate, bool set_flags = true) {
    cpu.set_reg(rd, immediate);
    if (set_flags) cpu.set_flags_NZ(immediate);
}

void cmp(IARM7TDMI cpu, Reg rd, Word operand1, Word operand2, bool set_flags = true) {
    sub(cpu, rd, operand1, operand2, false, set_flags);
}

void and(IARM7TDMI cpu, Reg rd, Word operand1, Word operand2, bool writeback = true, bool set_flags = true) {
    Word result = operand1 & operand2;
    if (set_flags) cpu.set_flags_NZ(result);
    if (writeback) cpu.set_reg(rd, result);
}

void eor(IARM7TDMI cpu, Reg rd, Word operand1, Word operand2, bool writeback = true, bool set_flags = true) {
    Word result = operand1 ^ operand2;
    if (set_flags) cpu.set_flags_NZ(result);
    if (writeback) cpu.set_reg(rd, result);
}

void lsl(IARM7TDMI cpu, Reg rd, Word operand, Word shift, bool writeback = true, bool set_flags = true) {
    Word result;
    bool carry;

    if        (shift == 0) {
        result = operand;
        carry  = cpu.get_flag(Flag.C);
    } else if (shift < 32) {
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

void lsr(IARM7TDMI cpu, Reg rd, Word operand, Word shift, bool writeback = true, bool set_flags = true) {
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

void asr(IARM7TDMI cpu, Reg rd, Word operand, Word shift, bool writeback = true, bool set_flags = true) {
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

void ror(IARM7TDMI cpu, Reg rd, Word operand, Word shift, bool writeback = true, bool set_flags = true) {
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

void tst(IARM7TDMI cpu, Reg rd, Word operand1, Word operand2) {
    cpu.and(rd, operand1, operand2, false);
}

void neg(IARM7TDMI cpu, Reg rd, Word immediate, bool writeback = true, bool set_flags = true) {
    sub(cpu, rd, 0, immediate, writeback, set_flags);
}

void cmn(IARM7TDMI cpu, Reg rd, Word operand1, Word operand2, bool set_flags = true) {
    cpu.add(rd, operand1, operand2, false, set_flags);
}

void orr(IARM7TDMI cpu, Reg rd, Word operand1, Word operand2, bool writeback = true, bool set_flags = true) {
    Word result = operand1 | operand2;
    if (set_flags) cpu.set_flags_NZ(result);
    if (writeback) cpu.set_reg(rd, result);
}

void mul(IARM7TDMI cpu, Reg rd, Word operand1, Word operand2, bool writeback = true, bool set_flags = true) {
    Word result = operand1 * operand2;
    if (set_flags) cpu.set_flags_NZ(result);
    if (writeback) cpu.set_reg(rd, result);
}

void bic(IARM7TDMI cpu, Reg rd, Word operand1, Word operand2, bool writeback = true, bool set_flags = true) {
    Word result = operand1 & ~operand2;
    if (set_flags) cpu.set_flags_NZ(result);
    if (writeback) cpu.set_reg(rd, result);
}

void mvn(IARM7TDMI cpu, Reg rd, Word immediate, bool set_flags = true) {
    cpu.set_reg(rd, ~immediate);
    if (set_flags) cpu.set_flags_NZ(~immediate);
}

void set_flags_NZ(IARM7TDMI cpu, Word result) {
    cpu.set_flag(Flag.Z, result == 0);
    cpu.set_flag(Flag.N, get_nth_bit(result, 31));
}

void ldr(IARM7TDMI cpu, Reg rd, Word address) {
    cpu.set_reg(rd, cpu.read_word_and_rotate(address, AccessType.NONSEQUENTIAL));
    cpu.run_idle_cycle();
    cpu.set_pipeline_access_type(AccessType.NONSEQUENTIAL);
}

void ldrh(IARM7TDMI cpu, Reg rd, Word address) {
    cpu.set_reg(rd, cpu.read_half_and_rotate(address, AccessType.NONSEQUENTIAL));
    cpu.run_idle_cycle();
    cpu.set_pipeline_access_type(AccessType.NONSEQUENTIAL);
}

void ldrb(IARM7TDMI cpu, Reg rd, Word address) {
    cpu.set_reg(rd, cpu.read_byte(address, AccessType.NONSEQUENTIAL));
    cpu.run_idle_cycle();
    cpu.set_pipeline_access_type(AccessType.NONSEQUENTIAL);
}

void ldrsb(IARM7TDMI cpu, Reg rd, Word address) {
    cpu.set_reg(rd, cpu.sext_32(cpu.read_byte(address, AccessType.NONSEQUENTIAL), 8));
    cpu.run_idle_cycle();
    cpu.set_pipeline_access_type(AccessType.NONSEQUENTIAL);
}

void ldrsh(IARM7TDMI cpu, Reg rd, Word address) {
    if (address & 1) ldrsb(cpu, rd, address);
    else {
        cpu.set_reg(rd, cpu.sext_32(cpu.read_half(address, AccessType.NONSEQUENTIAL), 16));
        cpu.run_idle_cycle();
        cpu.set_pipeline_access_type(AccessType.NONSEQUENTIAL);
    }
}

void str(IARM7TDMI cpu, Reg rd, Word address) {
    cpu.write_word(address & ~3, cpu.get_reg(rd), AccessType.NONSEQUENTIAL);
    cpu.set_pipeline_access_type(AccessType.NONSEQUENTIAL);
}

void strh(IARM7TDMI cpu, Reg rd, Word address) {
    cpu.write_half(address & ~1, cast(Half) cpu.get_reg(rd), AccessType.NONSEQUENTIAL);
    cpu.set_pipeline_access_type(AccessType.NONSEQUENTIAL);
}

void strb(IARM7TDMI cpu, Reg rd, Word address) {
    cpu.write_byte(address, cpu.get_reg(rd) & 0xFF, AccessType.NONSEQUENTIAL);
    cpu.set_pipeline_access_type(AccessType.NONSEQUENTIAL);
}

s32 sext_32(IARM7TDMI cpu, u32 value, u32 size) {
    auto negative = get_nth_bit(value, size - 1);
    if (negative) value |= (((1 << (32 - size)) - 1) << size);
    return value;
}

Word read_word_and_rotate(IARM7TDMI cpu, Word address, AccessType access_type) {
    Word value = cpu.read_word(address, access_type);
    auto misalignment = address & 0b11;
    return rotate_right(value, misalignment * 8);
}

Word read_half_and_rotate(IARM7TDMI cpu, Word address, AccessType access_type) {
    Word value = cpu.read_half(address, access_type);
    auto misalignment = address & 0b1;
    return rotate_right(value, misalignment * 8);
}