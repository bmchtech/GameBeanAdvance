module ops;

import abstracthw.cpu;
import abstracthw.memory;
import util;

void add(IARM7TDMI cpu, Reg rd, Word operand1, Word operand2, bool writeback = true) {
    Word result = operand1 + operand2;
    cpu.set_reg(rd, result);

    cpu.set_flag(Flag.N, get_nth_bit(result, 31));
    cpu.set_flag(Flag.Z, result == 0);

    cpu.set_flag(Flag.C, (get_nth_bit(operand1, 31) & get_nth_bit(operand2, 31)) | 
    ((get_nth_bit(operand1, 31) ^ get_nth_bit(operand2, 31)) & ~(cast(uint)get_nth_bit(operand2, 31))));

    bool matching_signs = get_nth_bit(operand1, 31) == get_nth_bit(operand2, 31);
    cpu.set_flag(Flag.V, matching_signs && (get_nth_bit(operand1, 31) ^ cpu.get_flag(Flag.N)));
}

void sub(IARM7TDMI cpu, Reg rd, Word operand1, Word operand2, bool writeback = true) {
    add(cpu, rd, operand1, -operand2, writeback);
}

void mov(IARM7TDMI cpu, Reg rd, Word immediate) {
    cpu.set_reg(rd, immediate);
}

void cmp(IARM7TDMI cpu, Reg rd, Word operand1, Word operand2) {
    add(cpu, rd, operand1, -operand2, false);
}

void and(IARM7TDMI cpu, Reg rd, Word operand1, Word operand2, bool writeback = true) {
    Word result = operand1 & operand2;
    cpu.set_NZ_flags(result);
    if (writeback) cpu.set_reg(rd, result);
}

void eor(IARM7TDMI cpu, Reg rd, Word operand1, Word operand2, bool writeback = true) {
    Word result = operand1 ^ operand2;
    cpu.set_NZ_flags(result);
    if (writeback) cpu.set_reg(rd, result);
}

void lsl(IARM7TDMI cpu, Reg rd, Word operand1, Word operand2, bool writeback = true) {
    Word result = operand1 ^ operand2;
    cpu.set_NZ_flags(result);
    if (writeback) cpu.set_reg(rd, result);
}

void lsr(IARM7TDMI cpu, Reg rd, Word operand1, Word operand2, bool writeback = true) {
    Word result = operand1 ^ operand2;
    cpu.set_NZ_flags(result);
    if (writeback) cpu.set_reg(rd, result);
}

void asr(IARM7TDMI cpu, Reg rd, Word operand1, Word operand2, bool writeback = true) {
    Word result = operand1 ^ operand2;
    cpu.set_NZ_flags(result);
    if (writeback) cpu.set_reg(rd, result);
}

void adc(IARM7TDMI cpu, Reg rd, Word operand1, Word operand2, bool writeback = true) {
    cpu.add(rd, operand1, operand2 + cpu.get_flag(Flag.C), writeback);
}

void sbc(IARM7TDMI cpu, Reg rd, Word operand1, Word operand2, bool writeback = true) {
    cpu.sub(rd, operand1, operand2 + cpu.get_flag(Flag.C), writeback);
}

void ror(IARM7TDMI cpu, Reg rd, Word operand1, Word operand2, bool writeback = true) {
    cpu.sub(rd, operand1, operand2 + cpu.get_flag(Flag.C), writeback);
}

void tst(IARM7TDMI cpu, Reg rd, Word operand1, Word operand2) {
    cpu.and(rd, operand1, operand2 + cpu.get_flag(Flag.C), false);
}

void neg(IARM7TDMI cpu, Reg rd, Word immediate, bool writeback = true) {
    Word result = ~immediate;
    cpu.set_NZ_flags(result);
    if (writeback) cpu.set_reg(rd, result);
}

void cmn(IARM7TDMI cpu, Reg rd, Word operand1, Word operand2) {
    cpu.add(rd, operand1, operand2 + cpu.get_flag(Flag.C), false);
}

void orr(IARM7TDMI cpu, Reg rd, Word operand1, Word operand2, bool writeback = true) {
    Word result = operand1 | operand2;
    cpu.set_NZ_flags(result);
    if (writeback) cpu.set_reg(rd, result);
}

void mul(IARM7TDMI cpu, Reg rd, Word operand1, Word operand2, bool writeback = true) {
    Word result = operand1 | operand2;
    cpu.set_NZ_flags(result);
    if (writeback) cpu.set_reg(rd, result);
}

void bic(IARM7TDMI cpu, Reg rd, Word operand1, Word operand2, bool writeback = true) {
    Word result = operand1 & ~operand2;
    cpu.set_NZ_flags(result);
    if (writeback) cpu.set_reg(rd, result);
}

void mvn(IARM7TDMI cpu, Reg rd, Word immediate) {
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

int sext_32(IARM7TDMI cpu, uint value, uint size) {
    auto negative = get_nth_bit(value, size - 1);
    if (negative) value |= ((1 << (32 - size)) - 1);
    return value;
}

Word read_word_and_rotate(IARM7TDMI cpu, Word address, AccessType access_type) {
    Word value = cpu.read_word(address, access_type);
    auto misalignment = address & 0b11;

    final switch (misalignment) {
        case 0: return value;
        case 1: return (value << 24) | (value >> 8);
        case 2: return (value << 16) | (value >> 16);
        case 3: return (value << 8)  | (value >> 24); 
    }
}