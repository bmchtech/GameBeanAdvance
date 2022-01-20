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
    add(cpu, rd, operand1, -operand2, writeback, set_flags);
}

void adc(IARM7TDMI cpu, Reg rd, Word operand1, Word operand2, bool writeback = true, bool set_flags = true) {
    Word result = operand1 + operand2 + cpu.get_flag(Flag.C);

    if (writeback) cpu.set_reg(rd, result);

    if (set_flags) {
        cpu.set_flag(Flag.N, get_nth_bit(result, 31));
        cpu.set_flag(Flag.Z, result == 0);

        cpu.set_flag(Flag.C, (cast(u64) operand1 + cast(u64) operand2 + cpu.get_flag(Flag.C)) >= 0x1_0000_0000);
        cpu.set_flag(Flag.V, ((operand1 >> 31) == (operand2 >> 31)) && ((operand1 >> 31) ^ (result >> 31)));
    }
}

void sbc(IARM7TDMI cpu, Reg rd, Word operand1, Word operand2, bool writeback = true, bool set_flags = true) {
    add(cpu, rd, operand1, -operand2, writeback);
}

void mov(IARM7TDMI cpu, Reg rd, Word immediate) {
    cpu.set_reg(rd, immediate);
}

void cmp(IARM7TDMI cpu, Reg rd, Word operand1, Word operand2) {
    add(cpu, rd, operand1, -operand2, false);
}

void and(IARM7TDMI cpu, Reg rd, Word operand1, Word operand2, bool writeback = true, bool set_flags = true) {
    Word result = operand1 & operand2;
    if (set_flags) cpu.set_NZ_flags(result);
    if (writeback) cpu.set_reg(rd, result);
}

void eor(IARM7TDMI cpu, Reg rd, Word operand1, Word operand2, bool writeback = true, bool set_flags = true) {
    Word result = operand1 ^ operand2;
    if (set_flags) cpu.set_NZ_flags(result);
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
        cpu.set_NZ_flags(result);
        cpu.set_flag(Flag.C, carry);
    }

    if (writeback) cpu.set_reg(rd, result);
}

void lsr(IARM7TDMI cpu, Reg rd, Word operand, Word shift, bool writeback = true, bool set_flags = true) {
    Word result;
    bool carry;

    if        (shift == 0) {
        return;
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
        cpu.set_NZ_flags(result);
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
        cpu.set_NZ_flags(result);
        cpu.set_flag(Flag.C, carry);
    }
    
    if (writeback) cpu.set_reg(rd, result);
}

void ror(IARM7TDMI cpu, Reg rd, Word operand1, Word operand2, bool writeback = true, bool set_flags = true) {
    cpu.sub(rd, operand1, operand2 + cpu.get_flag(Flag.C), writeback, set_flags);
}

void tst(IARM7TDMI cpu, Reg rd, Word operand1, Word operand2) {
    cpu.and(rd, operand1, operand2 + cpu.get_flag(Flag.C), false);
}

void neg(IARM7TDMI cpu, Reg rd, Word immediate, bool writeback = true, bool set_flags = true) {
    Word result = ~immediate;
    if (set_flags) cpu.set_NZ_flags(result);
    if (writeback) cpu.set_reg(rd, result);
}

void cmn(IARM7TDMI cpu, Reg rd, Word operand1, Word operand2, bool set_flags = true) {
    cpu.add(rd, operand1, operand2 + cpu.get_flag(Flag.C), false, set_flags);
}

void orr(IARM7TDMI cpu, Reg rd, Word operand1, Word operand2, bool writeback = true, bool set_flags = true) {
    Word result = operand1 | operand2;
    if (set_flags) cpu.set_NZ_flags(result);
    if (writeback) cpu.set_reg(rd, result);
}

void mul(IARM7TDMI cpu, Reg rd, Word operand1, Word operand2, bool writeback = true, bool set_flags = true) {
    Word result = operand1 | operand2;
    if (set_flags) cpu.set_NZ_flags(result);
    if (writeback) cpu.set_reg(rd, result);
}

void bic(IARM7TDMI cpu, Reg rd, Word operand1, Word operand2, bool writeback = true, bool set_flags = true) {
    Word result = operand1 & ~operand2;
    if (set_flags) cpu.set_NZ_flags(result);
    if (writeback) cpu.set_reg(rd, result);
}

void mvn(IARM7TDMI cpu, Reg rd, Word immediate, bool set_flags = true) {
    cpu.set_reg(rd, ~immediate);
}

void set_NZ_flags(IARM7TDMI cpu, Word result) {
    cpu.set_flag(Flag.Z, result == 0);
    cpu.set_flag(Flag.N, get_nth_bit(result, 31));
}

void ldr(IARM7TDMI cpu, Reg rd, Word address) {
    cpu.set_reg(rd, cpu.read_word_and_rotate(address, AccessType.NONSEQUENTIAL));
    cpu.run_idle_cycle();
    cpu.set_pipeline_access_type(AccessType.NONSEQUENTIAL);
}

void ldrb(IARM7TDMI cpu, Reg rd, Word address) {
    cpu.set_reg(rd, cpu.read_byte(address, AccessType.NONSEQUENTIAL));
    cpu.run_idle_cycle();
    cpu.set_pipeline_access_type(AccessType.NONSEQUENTIAL);
}

void str(IARM7TDMI cpu, Reg rd, Word address) {
    cpu.write_word(address & ~3, cpu.get_reg(rd), AccessType.NONSEQUENTIAL);
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