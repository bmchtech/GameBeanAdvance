import util.d
import memory.d
import arm7tdmi.d"

void run_00000000(ARM7TDMI* cpu, uint16_t opcode);
void run_00000000(ARM7TDMI* cpu, uint16_t opcode) {
    DEBUG_MESSAGE("Logical Shift Left");

    uint8_t source = get_nth_bits(opcode, 3,  6);
    uint8_t dest   = get_nth_bits(opcode, 0,  3);
    uint8_t shift  = get_nth_bits(opcode, 6,  11);

    if (shift == 0) { // if shift == 0, the cpu shifts by 32, which is the size of the register.
        cpu->regs[dest] = cpu->regs[source];
    } else {
        cpu->set_flag_C(get_nth_bit(cpu->regs[source], 32 - shift));
        cpu->regs[dest] = (cpu->regs[source] << shift);
    }

    cpu->set_flag_N(get_nth_bit(cpu->regs[dest], 31));
    cpu->set_flag_Z(cpu->regs[dest] == 0);

    cpu->cycles_remaining += 2;
}

void run_00000001(ARM7TDMI* cpu, uint16_t opcode);
void run_00000001(ARM7TDMI* cpu, uint16_t opcode) {
    DEBUG_MESSAGE("Logical Shift Left");

    uint8_t source = get_nth_bits(opcode, 3,  6);
    uint8_t dest   = get_nth_bits(opcode, 0,  3);
    uint8_t shift  = get_nth_bits(opcode, 6,  11);

    if (shift == 0) { // if shift == 0, the cpu shifts by 32, which is the size of the register.
        cpu->regs[dest] = cpu->regs[source];
    } else {
        cpu->set_flag_C(get_nth_bit(cpu->regs[source], 32 - shift));
        cpu->regs[dest] = (cpu->regs[source] << shift);
    }

    cpu->set_flag_N(get_nth_bit(cpu->regs[dest], 31));
    cpu->set_flag_Z(cpu->regs[dest] == 0);

    cpu->cycles_remaining += 2;
}

void run_00000010(ARM7TDMI* cpu, uint16_t opcode);
void run_00000010(ARM7TDMI* cpu, uint16_t opcode) {
    DEBUG_MESSAGE("Logical Shift Left");

    uint8_t source = get_nth_bits(opcode, 3,  6);
    uint8_t dest   = get_nth_bits(opcode, 0,  3);
    uint8_t shift  = get_nth_bits(opcode, 6,  11);

    if (shift == 0) { // if shift == 0, the cpu shifts by 32, which is the size of the register.
        cpu->regs[dest] = cpu->regs[source];
    } else {
        cpu->set_flag_C(get_nth_bit(cpu->regs[source], 32 - shift));
        cpu->regs[dest] = (cpu->regs[source] << shift);
    }

    cpu->set_flag_N(get_nth_bit(cpu->regs[dest], 31));
    cpu->set_flag_Z(cpu->regs[dest] == 0);

    cpu->cycles_remaining += 2;
}

void run_00000011(ARM7TDMI* cpu, uint16_t opcode);
void run_00000011(ARM7TDMI* cpu, uint16_t opcode) {
    DEBUG_MESSAGE("Logical Shift Left");

    uint8_t source = get_nth_bits(opcode, 3,  6);
    uint8_t dest   = get_nth_bits(opcode, 0,  3);
    uint8_t shift  = get_nth_bits(opcode, 6,  11);

    if (shift == 0) { // if shift == 0, the cpu shifts by 32, which is the size of the register.
        cpu->regs[dest] = cpu->regs[source];
    } else {
        cpu->set_flag_C(get_nth_bit(cpu->regs[source], 32 - shift));
        cpu->regs[dest] = (cpu->regs[source] << shift);
    }

    cpu->set_flag_N(get_nth_bit(cpu->regs[dest], 31));
    cpu->set_flag_Z(cpu->regs[dest] == 0);

    cpu->cycles_remaining += 2;
}

void run_00000100(ARM7TDMI* cpu, uint16_t opcode);
void run_00000100(ARM7TDMI* cpu, uint16_t opcode) {
    DEBUG_MESSAGE("Logical Shift Left");

    uint8_t source = get_nth_bits(opcode, 3,  6);
    uint8_t dest   = get_nth_bits(opcode, 0,  3);
    uint8_t shift  = get_nth_bits(opcode, 6,  11);

    if (shift == 0) { // if shift == 0, the cpu shifts by 32, which is the size of the register.
        cpu->regs[dest] = cpu->regs[source];
    } else {
        cpu->set_flag_C(get_nth_bit(cpu->regs[source], 32 - shift));
        cpu->regs[dest] = (cpu->regs[source] << shift);
    }

    cpu->set_flag_N(get_nth_bit(cpu->regs[dest], 31));
    cpu->set_flag_Z(cpu->regs[dest] == 0);

    cpu->cycles_remaining += 2;
}

void run_00000101(ARM7TDMI* cpu, uint16_t opcode);
void run_00000101(ARM7TDMI* cpu, uint16_t opcode) {
    DEBUG_MESSAGE("Logical Shift Left");

    uint8_t source = get_nth_bits(opcode, 3,  6);
    uint8_t dest   = get_nth_bits(opcode, 0,  3);
    uint8_t shift  = get_nth_bits(opcode, 6,  11);

    if (shift == 0) { // if shift == 0, the cpu shifts by 32, which is the size of the register.
        cpu->regs[dest] = cpu->regs[source];
    } else {
        cpu->set_flag_C(get_nth_bit(cpu->regs[source], 32 - shift));
        cpu->regs[dest] = (cpu->regs[source] << shift);
    }

    cpu->set_flag_N(get_nth_bit(cpu->regs[dest], 31));
    cpu->set_flag_Z(cpu->regs[dest] == 0);

    cpu->cycles_remaining += 2;
}

void run_00000110(ARM7TDMI* cpu, uint16_t opcode);
void run_00000110(ARM7TDMI* cpu, uint16_t opcode) {
    DEBUG_MESSAGE("Logical Shift Left");

    uint8_t source = get_nth_bits(opcode, 3,  6);
    uint8_t dest   = get_nth_bits(opcode, 0,  3);
    uint8_t shift  = get_nth_bits(opcode, 6,  11);

    if (shift == 0) { // if shift == 0, the cpu shifts by 32, which is the size of the register.
        cpu->regs[dest] = cpu->regs[source];
    } else {
        cpu->set_flag_C(get_nth_bit(cpu->regs[source], 32 - shift));
        cpu->regs[dest] = (cpu->regs[source] << shift);
    }

    cpu->set_flag_N(get_nth_bit(cpu->regs[dest], 31));
    cpu->set_flag_Z(cpu->regs[dest] == 0);

    cpu->cycles_remaining += 2;
}

void run_00000111(ARM7TDMI* cpu, uint16_t opcode);
void run_00000111(ARM7TDMI* cpu, uint16_t opcode) {
    DEBUG_MESSAGE("Logical Shift Left");

    uint8_t source = get_nth_bits(opcode, 3,  6);
    uint8_t dest   = get_nth_bits(opcode, 0,  3);
    uint8_t shift  = get_nth_bits(opcode, 6,  11);

    if (shift == 0) { // if shift == 0, the cpu shifts by 32, which is the size of the register.
        cpu->regs[dest] = cpu->regs[source];
    } else {
        cpu->set_flag_C(get_nth_bit(cpu->regs[source], 32 - shift));
        cpu->regs[dest] = (cpu->regs[source] << shift);
    }

    cpu->set_flag_N(get_nth_bit(cpu->regs[dest], 31));
    cpu->set_flag_Z(cpu->regs[dest] == 0);

    cpu->cycles_remaining += 2;
}

void run_00001000(ARM7TDMI* cpu, uint16_t opcode);
void run_00001000(ARM7TDMI* cpu, uint16_t opcode) {
    DEBUG_MESSAGE("Logical Shift Right");

    uint8_t source = get_nth_bits(opcode, 3,  6);
    uint8_t dest   = get_nth_bits(opcode, 0,  3);
    uint8_t shift  = get_nth_bits(opcode, 6,  11);

    if (shift == 0) { // if shift == 0, the cpu shifts by 32, which is the size of the register.
        cpu->set_flag_C(get_nth_bit(cpu->regs[source], 31));
        cpu->regs[dest] = 0;
    } else {
        cpu->set_flag_C(get_nth_bit(cpu->regs[source], shift - 1));
        cpu->regs[dest] = (cpu->regs[source] >> shift);
    }

    cpu->set_flag_N(get_nth_bit(cpu->regs[dest], 31));
    cpu->set_flag_Z(cpu->regs[dest] == 0);

    cpu->cycles_remaining += 2;
}

void run_00001001(ARM7TDMI* cpu, uint16_t opcode);
void run_00001001(ARM7TDMI* cpu, uint16_t opcode) {
    DEBUG_MESSAGE("Logical Shift Right");

    uint8_t source = get_nth_bits(opcode, 3,  6);
    uint8_t dest   = get_nth_bits(opcode, 0,  3);
    uint8_t shift  = get_nth_bits(opcode, 6,  11);

    if (shift == 0) { // if shift == 0, the cpu shifts by 32, which is the size of the register.
        cpu->set_flag_C(get_nth_bit(cpu->regs[source], 31));
        cpu->regs[dest] = 0;
    } else {
        cpu->set_flag_C(get_nth_bit(cpu->regs[source], shift - 1));
        cpu->regs[dest] = (cpu->regs[source] >> shift);
    }

    cpu->set_flag_N(get_nth_bit(cpu->regs[dest], 31));
    cpu->set_flag_Z(cpu->regs[dest] == 0);

    cpu->cycles_remaining += 2;
}

void run_00001010(ARM7TDMI* cpu, uint16_t opcode);
void run_00001010(ARM7TDMI* cpu, uint16_t opcode) {
    DEBUG_MESSAGE("Logical Shift Right");

    uint8_t source = get_nth_bits(opcode, 3,  6);
    uint8_t dest   = get_nth_bits(opcode, 0,  3);
    uint8_t shift  = get_nth_bits(opcode, 6,  11);

    if (shift == 0) { // if shift == 0, the cpu shifts by 32, which is the size of the register.
        cpu->set_flag_C(get_nth_bit(cpu->regs[source], 31));
        cpu->regs[dest] = 0;
    } else {
        cpu->set_flag_C(get_nth_bit(cpu->regs[source], shift - 1));
        cpu->regs[dest] = (cpu->regs[source] >> shift);
    }

    cpu->set_flag_N(get_nth_bit(cpu->regs[dest], 31));
    cpu->set_flag_Z(cpu->regs[dest] == 0);

    cpu->cycles_remaining += 2;
}

void run_00001011(ARM7TDMI* cpu, uint16_t opcode);
void run_00001011(ARM7TDMI* cpu, uint16_t opcode) {
    DEBUG_MESSAGE("Logical Shift Right");

    uint8_t source = get_nth_bits(opcode, 3,  6);
    uint8_t dest   = get_nth_bits(opcode, 0,  3);
    uint8_t shift  = get_nth_bits(opcode, 6,  11);

    if (shift == 0) { // if shift == 0, the cpu shifts by 32, which is the size of the register.
        cpu->set_flag_C(get_nth_bit(cpu->regs[source], 31));
        cpu->regs[dest] = 0;
    } else {
        cpu->set_flag_C(get_nth_bit(cpu->regs[source], shift - 1));
        cpu->regs[dest] = (cpu->regs[source] >> shift);
    }

    cpu->set_flag_N(get_nth_bit(cpu->regs[dest], 31));
    cpu->set_flag_Z(cpu->regs[dest] == 0);

    cpu->cycles_remaining += 2;
}

void run_00001100(ARM7TDMI* cpu, uint16_t opcode);
void run_00001100(ARM7TDMI* cpu, uint16_t opcode) {
    DEBUG_MESSAGE("Logical Shift Right");

    uint8_t source = get_nth_bits(opcode, 3,  6);
    uint8_t dest   = get_nth_bits(opcode, 0,  3);
    uint8_t shift  = get_nth_bits(opcode, 6,  11);

    if (shift == 0) { // if shift == 0, the cpu shifts by 32, which is the size of the register.
        cpu->set_flag_C(get_nth_bit(cpu->regs[source], 31));
        cpu->regs[dest] = 0;
    } else {
        cpu->set_flag_C(get_nth_bit(cpu->regs[source], shift - 1));
        cpu->regs[dest] = (cpu->regs[source] >> shift);
    }

    cpu->set_flag_N(get_nth_bit(cpu->regs[dest], 31));
    cpu->set_flag_Z(cpu->regs[dest] == 0);

    cpu->cycles_remaining += 2;
}

void run_00001101(ARM7TDMI* cpu, uint16_t opcode);
void run_00001101(ARM7TDMI* cpu, uint16_t opcode) {
    DEBUG_MESSAGE("Logical Shift Right");

    uint8_t source = get_nth_bits(opcode, 3,  6);
    uint8_t dest   = get_nth_bits(opcode, 0,  3);
    uint8_t shift  = get_nth_bits(opcode, 6,  11);

    if (shift == 0) { // if shift == 0, the cpu shifts by 32, which is the size of the register.
        cpu->set_flag_C(get_nth_bit(cpu->regs[source], 31));
        cpu->regs[dest] = 0;
    } else {
        cpu->set_flag_C(get_nth_bit(cpu->regs[source], shift - 1));
        cpu->regs[dest] = (cpu->regs[source] >> shift);
    }

    cpu->set_flag_N(get_nth_bit(cpu->regs[dest], 31));
    cpu->set_flag_Z(cpu->regs[dest] == 0);

    cpu->cycles_remaining += 2;
}

void run_00001110(ARM7TDMI* cpu, uint16_t opcode);
void run_00001110(ARM7TDMI* cpu, uint16_t opcode) {
    DEBUG_MESSAGE("Logical Shift Right");

    uint8_t source = get_nth_bits(opcode, 3,  6);
    uint8_t dest   = get_nth_bits(opcode, 0,  3);
    uint8_t shift  = get_nth_bits(opcode, 6,  11);

    if (shift == 0) { // if shift == 0, the cpu shifts by 32, which is the size of the register.
        cpu->set_flag_C(get_nth_bit(cpu->regs[source], 31));
        cpu->regs[dest] = 0;
    } else {
        cpu->set_flag_C(get_nth_bit(cpu->regs[source], shift - 1));
        cpu->regs[dest] = (cpu->regs[source] >> shift);
    }

    cpu->set_flag_N(get_nth_bit(cpu->regs[dest], 31));
    cpu->set_flag_Z(cpu->regs[dest] == 0);

    cpu->cycles_remaining += 2;
}

void run_00001111(ARM7TDMI* cpu, uint16_t opcode);
void run_00001111(ARM7TDMI* cpu, uint16_t opcode) {
    DEBUG_MESSAGE("Logical Shift Right");

    uint8_t source = get_nth_bits(opcode, 3,  6);
    uint8_t dest   = get_nth_bits(opcode, 0,  3);
    uint8_t shift  = get_nth_bits(opcode, 6,  11);

    if (shift == 0) { // if shift == 0, the cpu shifts by 32, which is the size of the register.
        cpu->set_flag_C(get_nth_bit(cpu->regs[source], 31));
        cpu->regs[dest] = 0;
    } else {
        cpu->set_flag_C(get_nth_bit(cpu->regs[source], shift - 1));
        cpu->regs[dest] = (cpu->regs[source] >> shift);
    }

    cpu->set_flag_N(get_nth_bit(cpu->regs[dest], 31));
    cpu->set_flag_Z(cpu->regs[dest] == 0);

    cpu->cycles_remaining += 2;
}

void run_00010000(ARM7TDMI* cpu, uint16_t opcode);
void run_00010000(ARM7TDMI* cpu, uint16_t opcode) {
    uint8_t rm    = get_nth_bits(opcode, 3,  6);
    uint8_t rd    = get_nth_bits(opcode, 0,  3);
    uint8_t shift = get_nth_bits(opcode, 6,  11);

    if (shift == 0) {
        cpu->set_flag_C(cpu->regs[rm] >> 31);
        if ((cpu->regs[rm] >> 31) == 0) cpu->regs[rd] = 0x00000000;
        else                              cpu->regs[rd] = 0xFFFFFFFF;
    } else {
        cpu->set_flag_C(get_nth_bit(cpu->regs[rm], shift - 1));
        // arithmetic shift requires us to cast to signed int first, then back to unsigned to store in registers.
        cpu->regs[rd] = (uint32_t) (((int32_t) cpu->regs[rm]) >> shift);
    }

    cpu->set_flag_N(cpu->regs[rd] >> 31);
    cpu->set_flag_Z(cpu->regs[rd] == 0);

    cpu->cycles_remaining += 2;
}

void run_00010001(ARM7TDMI* cpu, uint16_t opcode);
void run_00010001(ARM7TDMI* cpu, uint16_t opcode) {
    uint8_t rm    = get_nth_bits(opcode, 3,  6);
    uint8_t rd    = get_nth_bits(opcode, 0,  3);
    uint8_t shift = get_nth_bits(opcode, 6,  11);

    if (shift == 0) {
        cpu->set_flag_C(cpu->regs[rm] >> 31);
        if ((cpu->regs[rm] >> 31) == 0) cpu->regs[rd] = 0x00000000;
        else                              cpu->regs[rd] = 0xFFFFFFFF;
    } else {
        cpu->set_flag_C(get_nth_bit(cpu->regs[rm], shift - 1));
        // arithmetic shift requires us to cast to signed int first, then back to unsigned to store in registers.
        cpu->regs[rd] = (uint32_t) (((int32_t) cpu->regs[rm]) >> shift);
    }

    cpu->set_flag_N(cpu->regs[rd] >> 31);
    cpu->set_flag_Z(cpu->regs[rd] == 0);

    cpu->cycles_remaining += 2;
}

void run_00010010(ARM7TDMI* cpu, uint16_t opcode);
void run_00010010(ARM7TDMI* cpu, uint16_t opcode) {
    uint8_t rm    = get_nth_bits(opcode, 3,  6);
    uint8_t rd    = get_nth_bits(opcode, 0,  3);
    uint8_t shift = get_nth_bits(opcode, 6,  11);

    if (shift == 0) {
        cpu->set_flag_C(cpu->regs[rm] >> 31);
        if ((cpu->regs[rm] >> 31) == 0) cpu->regs[rd] = 0x00000000;
        else                              cpu->regs[rd] = 0xFFFFFFFF;
    } else {
        cpu->set_flag_C(get_nth_bit(cpu->regs[rm], shift - 1));
        // arithmetic shift requires us to cast to signed int first, then back to unsigned to store in registers.
        cpu->regs[rd] = (uint32_t) (((int32_t) cpu->regs[rm]) >> shift);
    }

    cpu->set_flag_N(cpu->regs[rd] >> 31);
    cpu->set_flag_Z(cpu->regs[rd] == 0);

    cpu->cycles_remaining += 2;
}

void run_00010011(ARM7TDMI* cpu, uint16_t opcode);
void run_00010011(ARM7TDMI* cpu, uint16_t opcode) {
    uint8_t rm    = get_nth_bits(opcode, 3,  6);
    uint8_t rd    = get_nth_bits(opcode, 0,  3);
    uint8_t shift = get_nth_bits(opcode, 6,  11);

    if (shift == 0) {
        cpu->set_flag_C(cpu->regs[rm] >> 31);
        if ((cpu->regs[rm] >> 31) == 0) cpu->regs[rd] = 0x00000000;
        else                              cpu->regs[rd] = 0xFFFFFFFF;
    } else {
        cpu->set_flag_C(get_nth_bit(cpu->regs[rm], shift - 1));
        // arithmetic shift requires us to cast to signed int first, then back to unsigned to store in registers.
        cpu->regs[rd] = (uint32_t) (((int32_t) cpu->regs[rm]) >> shift);
    }

    cpu->set_flag_N(cpu->regs[rd] >> 31);
    cpu->set_flag_Z(cpu->regs[rd] == 0);

    cpu->cycles_remaining += 2;
}

void run_00010100(ARM7TDMI* cpu, uint16_t opcode);
void run_00010100(ARM7TDMI* cpu, uint16_t opcode) {
    uint8_t rm    = get_nth_bits(opcode, 3,  6);
    uint8_t rd    = get_nth_bits(opcode, 0,  3);
    uint8_t shift = get_nth_bits(opcode, 6,  11);

    if (shift == 0) {
        cpu->set_flag_C(cpu->regs[rm] >> 31);
        if ((cpu->regs[rm] >> 31) == 0) cpu->regs[rd] = 0x00000000;
        else                              cpu->regs[rd] = 0xFFFFFFFF;
    } else {
        cpu->set_flag_C(get_nth_bit(cpu->regs[rm], shift - 1));
        // arithmetic shift requires us to cast to signed int first, then back to unsigned to store in registers.
        cpu->regs[rd] = (uint32_t) (((int32_t) cpu->regs[rm]) >> shift);
    }

    cpu->set_flag_N(cpu->regs[rd] >> 31);
    cpu->set_flag_Z(cpu->regs[rd] == 0);

    cpu->cycles_remaining += 2;
}

void run_00010101(ARM7TDMI* cpu, uint16_t opcode);
void run_00010101(ARM7TDMI* cpu, uint16_t opcode) {
    uint8_t rm    = get_nth_bits(opcode, 3,  6);
    uint8_t rd    = get_nth_bits(opcode, 0,  3);
    uint8_t shift = get_nth_bits(opcode, 6,  11);

    if (shift == 0) {
        cpu->set_flag_C(cpu->regs[rm] >> 31);
        if ((cpu->regs[rm] >> 31) == 0) cpu->regs[rd] = 0x00000000;
        else                              cpu->regs[rd] = 0xFFFFFFFF;
    } else {
        cpu->set_flag_C(get_nth_bit(cpu->regs[rm], shift - 1));
        // arithmetic shift requires us to cast to signed int first, then back to unsigned to store in registers.
        cpu->regs[rd] = (uint32_t) (((int32_t) cpu->regs[rm]) >> shift);
    }

    cpu->set_flag_N(cpu->regs[rd] >> 31);
    cpu->set_flag_Z(cpu->regs[rd] == 0);

    cpu->cycles_remaining += 2;
}

void run_00010110(ARM7TDMI* cpu, uint16_t opcode);
void run_00010110(ARM7TDMI* cpu, uint16_t opcode) {
    uint8_t rm    = get_nth_bits(opcode, 3,  6);
    uint8_t rd    = get_nth_bits(opcode, 0,  3);
    uint8_t shift = get_nth_bits(opcode, 6,  11);

    if (shift == 0) {
        cpu->set_flag_C(cpu->regs[rm] >> 31);
        if ((cpu->regs[rm] >> 31) == 0) cpu->regs[rd] = 0x00000000;
        else                              cpu->regs[rd] = 0xFFFFFFFF;
    } else {
        cpu->set_flag_C(get_nth_bit(cpu->regs[rm], shift - 1));
        // arithmetic shift requires us to cast to signed int first, then back to unsigned to store in registers.
        cpu->regs[rd] = (uint32_t) (((int32_t) cpu->regs[rm]) >> shift);
    }

    cpu->set_flag_N(cpu->regs[rd] >> 31);
    cpu->set_flag_Z(cpu->regs[rd] == 0);

    cpu->cycles_remaining += 2;
}

void run_00010111(ARM7TDMI* cpu, uint16_t opcode);
void run_00010111(ARM7TDMI* cpu, uint16_t opcode) {
    uint8_t rm    = get_nth_bits(opcode, 3,  6);
    uint8_t rd    = get_nth_bits(opcode, 0,  3);
    uint8_t shift = get_nth_bits(opcode, 6,  11);

    if (shift == 0) {
        cpu->set_flag_C(cpu->regs[rm] >> 31);
        if ((cpu->regs[rm] >> 31) == 0) cpu->regs[rd] = 0x00000000;
        else                              cpu->regs[rd] = 0xFFFFFFFF;
    } else {
        cpu->set_flag_C(get_nth_bit(cpu->regs[rm], shift - 1));
        // arithmetic shift requires us to cast to signed int first, then back to unsigned to store in registers.
        cpu->regs[rd] = (uint32_t) (((int32_t) cpu->regs[rm]) >> shift);
    }

    cpu->set_flag_N(cpu->regs[rd] >> 31);
    cpu->set_flag_Z(cpu->regs[rd] == 0);

    cpu->cycles_remaining += 2;
}

void run_00011000(ARM7TDMI* cpu, uint16_t opcode);
void run_00011000(ARM7TDMI* cpu, uint16_t opcode) {
    DEBUG_MESSAGE("Add #3");

    int32_t rn = cpu->regs[get_nth_bits(opcode, 3, 6)];
    int32_t rm = cpu->regs[get_nth_bits(opcode, 6, 9)];
    
    cpu->regs[get_nth_bits(opcode, 0, 3)] = rn + rm;
    int32_t rd = cpu->regs[get_nth_bits(opcode, 0, 3)];

    cpu->set_flag_N(get_nth_bit(rd, 31));
    cpu->set_flag_Z(rd == 0);
    // cpu->set_flag_C((uint64_t)rn + (uint64_t)rm > rd); // probably can be optimized

    // Signed carry formula = (A AND B) OR (~DEST AND (A XOR B)) - works for all add operations once tested
    cpu->set_flag_C((get_nth_bit(rm, 31) & get_nth_bit(rn, 31)) | 
    ((get_nth_bit(rm, 31) ^ get_nth_bit(rn, 31)) & ~(get_nth_bit(rd, 31))));


    // this is garbage, but essentially what's going on is:
    // if the two operands had matching signs but their sign differed from the result's sign,
    // then there was an overflow and we set the flag.
    bool matching_signs = get_nth_bit(rn, 31) == get_nth_bit(rm, 31);
    cpu->set_flag_V(matching_signs && (get_nth_bit(rn, 31) ^ cpu->get_flag_N()));

    cpu->cycles_remaining += 1;
}

void run_00011001(ARM7TDMI* cpu, uint16_t opcode);
void run_00011001(ARM7TDMI* cpu, uint16_t opcode) {
    DEBUG_MESSAGE("Add #3");

    int32_t rn = cpu->regs[get_nth_bits(opcode, 3, 6)];
    int32_t rm = cpu->regs[get_nth_bits(opcode, 6, 9)];
    
    cpu->regs[get_nth_bits(opcode, 0, 3)] = rn + rm;
    int32_t rd = cpu->regs[get_nth_bits(opcode, 0, 3)];

    cpu->set_flag_N(get_nth_bit(rd, 31));
    cpu->set_flag_Z(rd == 0);
    // cpu->set_flag_C((uint64_t)rn + (uint64_t)rm > rd); // probably can be optimized

    // Signed carry formula = (A AND B) OR (~DEST AND (A XOR B)) - works for all add operations once tested
    cpu->set_flag_C((get_nth_bit(rm, 31) & get_nth_bit(rn, 31)) | 
    ((get_nth_bit(rm, 31) ^ get_nth_bit(rn, 31)) & ~(get_nth_bit(rd, 31))));


    // this is garbage, but essentially what's going on is:
    // if the two operands had matching signs but their sign differed from the result's sign,
    // then there was an overflow and we set the flag.
    bool matching_signs = get_nth_bit(rn, 31) == get_nth_bit(rm, 31);
    cpu->set_flag_V(matching_signs && (get_nth_bit(rn, 31) ^ cpu->get_flag_N()));

    cpu->cycles_remaining += 1;
}

void run_00011010(ARM7TDMI* cpu, uint16_t opcode);
void run_00011010(ARM7TDMI* cpu, uint16_t opcode) {
    DEBUG_MESSAGE("Sub #3");

    int32_t rn = cpu->regs[get_nth_bits(opcode, 3, 6)];
    int32_t rm = ~cpu->regs[get_nth_bits(opcode, 6, 9)] + 1;
    
    cpu->regs[get_nth_bits(opcode, 0, 3)] = rn + rm;
    int32_t rd = cpu->regs[get_nth_bits(opcode, 0, 3)];

    cpu->set_flag_N(get_nth_bit(rd, 31));
    cpu->set_flag_Z(rd == 0);
    // cpu->set_flag_C((uint64_t)rn + (uint64_t)rm > rd); // probably can be optimized

    // Signed carry formula = (A AND B) OR (~DEST AND (A XOR B)) - works for all add operations once tested
    cpu->set_flag_C((!(((uint64_t)rn) < cpu->regs[get_nth_bits(opcode, 6, 9)])));


    // this is garbage, but essentially what's going on is:
    // if the two operands had matching signs but their sign differed from the result's sign,
    // then there was an overflow and we set the flag.
    bool matching_signs = get_nth_bit(rn, 31) == get_nth_bit(cpu->regs[get_nth_bits(opcode, 6, 9)], 31);
    cpu->set_flag_V(!matching_signs && (get_nth_bit(cpu->regs[get_nth_bits(opcode, 6, 9)], 31) == cpu->get_flag_N()));

    cpu->cycles_remaining += 1;
}

void run_00011011(ARM7TDMI* cpu, uint16_t opcode);
void run_00011011(ARM7TDMI* cpu, uint16_t opcode) {
    DEBUG_MESSAGE("Sub #3");

    int32_t rn = cpu->regs[get_nth_bits(opcode, 3, 6)];
    int32_t rm = ~cpu->regs[get_nth_bits(opcode, 6, 9)] + 1;
    
    cpu->regs[get_nth_bits(opcode, 0, 3)] = rn + rm;
    int32_t rd = cpu->regs[get_nth_bits(opcode, 0, 3)];

    cpu->set_flag_N(get_nth_bit(rd, 31));
    cpu->set_flag_Z(rd == 0);
    // cpu->set_flag_C((uint64_t)rn + (uint64_t)rm > rd); // probably can be optimized

    // Signed carry formula = (A AND B) OR (~DEST AND (A XOR B)) - works for all add operations once tested
    cpu->set_flag_C((!(((uint64_t)rn) < cpu->regs[get_nth_bits(opcode, 6, 9)])));


    // this is garbage, but essentially what's going on is:
    // if the two operands had matching signs but their sign differed from the result's sign,
    // then there was an overflow and we set the flag.
    bool matching_signs = get_nth_bit(rn, 31) == get_nth_bit(cpu->regs[get_nth_bits(opcode, 6, 9)], 31);
    cpu->set_flag_V(!matching_signs && (get_nth_bit(cpu->regs[get_nth_bits(opcode, 6, 9)], 31) == cpu->get_flag_N()));

    cpu->cycles_remaining += 1;
}

void run_00011100(ARM7TDMI* cpu, uint16_t opcode);
void run_00011100(ARM7TDMI* cpu, uint16_t opcode) {
    int32_t immediate_value = get_nth_bits(opcode, 6, 9);
    int32_t rn_value        = cpu->regs[get_nth_bits(opcode, 3, 6)];

    cpu->regs[get_nth_bits(opcode, 0, 3)] = immediate_value + rn_value;
    int32_t rd_value = cpu->regs[get_nth_bits(opcode, 0, 3)];

    cpu->set_flag_N(get_nth_bit(rd_value, 31));
    cpu->set_flag_Z(rd_value == 0);

    // Signed carry formula = (A AND B) OR (~DEST AND (A XOR B)) - works for all add operations once tested
    cpu->set_flag_C((get_nth_bit(immediate_value, 31) & get_nth_bit(rn_value, 31)) | 
    ((get_nth_bit(immediate_value, 31) ^ get_nth_bit(rn_value, 31)) & ~(get_nth_bit(rd_value, 31))));

    bool matching_signs = get_nth_bit(immediate_value, 31) == get_nth_bit(rn_value, 31);
    cpu->set_flag_V(matching_signs && (get_nth_bit(immediate_value, 31) ^ cpu->get_flag_N()));

    cpu->cycles_remaining += 1;
}

void run_00011101(ARM7TDMI* cpu, uint16_t opcode);
void run_00011101(ARM7TDMI* cpu, uint16_t opcode) {
    int32_t immediate_value = get_nth_bits(opcode, 6, 9);
    int32_t rn_value        = cpu->regs[get_nth_bits(opcode, 3, 6)];

    cpu->regs[get_nth_bits(opcode, 0, 3)] = immediate_value + rn_value;
    int32_t rd_value = cpu->regs[get_nth_bits(opcode, 0, 3)];

    cpu->set_flag_N(get_nth_bit(rd_value, 31));
    cpu->set_flag_Z(rd_value == 0);

    // Signed carry formula = (A AND B) OR (~DEST AND (A XOR B)) - works for all add operations once tested
    cpu->set_flag_C((get_nth_bit(immediate_value, 31) & get_nth_bit(rn_value, 31)) | 
    ((get_nth_bit(immediate_value, 31) ^ get_nth_bit(rn_value, 31)) & ~(get_nth_bit(rd_value, 31))));

    bool matching_signs = get_nth_bit(immediate_value, 31) == get_nth_bit(rn_value, 31);
    cpu->set_flag_V(matching_signs && (get_nth_bit(immediate_value, 31) ^ cpu->get_flag_N()));

    cpu->cycles_remaining += 1;
}

void run_00011110(ARM7TDMI* cpu, uint16_t opcode);
void run_00011110(ARM7TDMI* cpu, uint16_t opcode) {
    int32_t immediate_value = (~get_nth_bits(opcode, 6, 9)) + 1;
    int32_t rn_value        = cpu->regs[get_nth_bits(opcode, 3, 6)];

    cpu->regs[get_nth_bits(opcode, 0, 3)] = rn_value + immediate_value;
    int32_t rd_value = cpu->regs[get_nth_bits(opcode, 0, 3)];

    cpu->set_flag_N(get_nth_bit(rd_value, 31));
    cpu->set_flag_Z(rd_value == 0);

    // Signed carry formula = (A AND B) OR (~DEST AND (A XOR B)) - works for all add operations once tested
    cpu->set_flag_C((!(((uint64_t)cpu->regs[get_nth_bits(opcode, 3, 6)]) < get_nth_bits(opcode, 6, 9))));

    bool matching_signs = get_nth_bit(rn_value, 31) == get_nth_bit(get_nth_bits(opcode, 6, 9), 31);
    cpu->set_flag_V(!matching_signs && (get_nth_bit(get_nth_bits(opcode, 6, 9), 31) == cpu->get_flag_N()));

    cpu->cycles_remaining += 1;
}

void run_00011111(ARM7TDMI* cpu, uint16_t opcode);
void run_00011111(ARM7TDMI* cpu, uint16_t opcode) {
    int32_t immediate_value = (~get_nth_bits(opcode, 6, 9)) + 1;
    int32_t rn_value        = cpu->regs[get_nth_bits(opcode, 3, 6)];

    cpu->regs[get_nth_bits(opcode, 0, 3)] = rn_value + immediate_value;
    int32_t rd_value = cpu->regs[get_nth_bits(opcode, 0, 3)];

    cpu->set_flag_N(get_nth_bit(rd_value, 31));
    cpu->set_flag_Z(rd_value == 0);

    // Signed carry formula = (A AND B) OR (~DEST AND (A XOR B)) - works for all add operations once tested
    cpu->set_flag_C((!(((uint64_t)cpu->regs[get_nth_bits(opcode, 3, 6)]) < get_nth_bits(opcode, 6, 9))));

    bool matching_signs = get_nth_bit(rn_value, 31) == get_nth_bit(get_nth_bits(opcode, 6, 9), 31);
    cpu->set_flag_V(!matching_signs && (get_nth_bit(get_nth_bits(opcode, 6, 9), 31) == cpu->get_flag_N()));

    cpu->cycles_remaining += 1;
}

void run_00100000(ARM7TDMI* cpu, uint16_t opcode);
void run_00100000(ARM7TDMI* cpu, uint16_t opcode) {
    DEBUG_MESSAGE("Move Immediate");

    uint16_t immediate_value = get_nth_bits(opcode, 0, 8);
    cpu->regs[get_nth_bits(opcode, 8, 11)] = immediate_value;
    // flags
    cpu->set_flag_N(get_nth_bit(immediate_value, 31));
    cpu->set_flag_Z(immediate_value == 0);

    cpu->cycles_remaining += 1;
}

void run_00100001(ARM7TDMI* cpu, uint16_t opcode);
void run_00100001(ARM7TDMI* cpu, uint16_t opcode) {
    DEBUG_MESSAGE("Move Immediate");

    uint16_t immediate_value = get_nth_bits(opcode, 0, 8);
    cpu->regs[get_nth_bits(opcode, 8, 11)] = immediate_value;
    // flags
    cpu->set_flag_N(get_nth_bit(immediate_value, 31));
    cpu->set_flag_Z(immediate_value == 0);

    cpu->cycles_remaining += 1;
}

void run_00100010(ARM7TDMI* cpu, uint16_t opcode);
void run_00100010(ARM7TDMI* cpu, uint16_t opcode) {
    DEBUG_MESSAGE("Move Immediate");

    uint16_t immediate_value = get_nth_bits(opcode, 0, 8);
    cpu->regs[get_nth_bits(opcode, 8, 11)] = immediate_value;
    // flags
    cpu->set_flag_N(get_nth_bit(immediate_value, 31));
    cpu->set_flag_Z(immediate_value == 0);

    cpu->cycles_remaining += 1;
}

void run_00100011(ARM7TDMI* cpu, uint16_t opcode);
void run_00100011(ARM7TDMI* cpu, uint16_t opcode) {
    DEBUG_MESSAGE("Move Immediate");

    uint16_t immediate_value = get_nth_bits(opcode, 0, 8);
    cpu->regs[get_nth_bits(opcode, 8, 11)] = immediate_value;
    // flags
    cpu->set_flag_N(get_nth_bit(immediate_value, 31));
    cpu->set_flag_Z(immediate_value == 0);

    cpu->cycles_remaining += 1;
}

void run_00100100(ARM7TDMI* cpu, uint16_t opcode);
void run_00100100(ARM7TDMI* cpu, uint16_t opcode) {
    DEBUG_MESSAGE("Move Immediate");

    uint16_t immediate_value = get_nth_bits(opcode, 0, 8);
    cpu->regs[get_nth_bits(opcode, 8, 11)] = immediate_value;
    // flags
    cpu->set_flag_N(get_nth_bit(immediate_value, 31));
    cpu->set_flag_Z(immediate_value == 0);

    cpu->cycles_remaining += 1;
}

void run_00100101(ARM7TDMI* cpu, uint16_t opcode);
void run_00100101(ARM7TDMI* cpu, uint16_t opcode) {
    DEBUG_MESSAGE("Move Immediate");

    uint16_t immediate_value = get_nth_bits(opcode, 0, 8);
    cpu->regs[get_nth_bits(opcode, 8, 11)] = immediate_value;
    // flags
    cpu->set_flag_N(get_nth_bit(immediate_value, 31));
    cpu->set_flag_Z(immediate_value == 0);

    cpu->cycles_remaining += 1;
}

void run_00100110(ARM7TDMI* cpu, uint16_t opcode);
void run_00100110(ARM7TDMI* cpu, uint16_t opcode) {
    DEBUG_MESSAGE("Move Immediate");

    uint16_t immediate_value = get_nth_bits(opcode, 0, 8);
    cpu->regs[get_nth_bits(opcode, 8, 11)] = immediate_value;
    // flags
    cpu->set_flag_N(get_nth_bit(immediate_value, 31));
    cpu->set_flag_Z(immediate_value == 0);

    cpu->cycles_remaining += 1;
}

void run_00100111(ARM7TDMI* cpu, uint16_t opcode);
void run_00100111(ARM7TDMI* cpu, uint16_t opcode) {
    DEBUG_MESSAGE("Move Immediate");

    uint16_t immediate_value = get_nth_bits(opcode, 0, 8);
    cpu->regs[get_nth_bits(opcode, 8, 11)] = immediate_value;
    // flags
    cpu->set_flag_N(get_nth_bit(immediate_value, 31));
    cpu->set_flag_Z(immediate_value == 0);

    cpu->cycles_remaining += 1;
}

void run_00101000(ARM7TDMI* cpu, uint16_t opcode);
void run_00101000(ARM7TDMI* cpu, uint16_t opcode) {
    uint8_t immediate_value = get_nth_bits(opcode, 0, 8);

    // CMP, which is basically a subtraction but the result isn't stored.
    // this uses the same two's complement trick that makes ADD the same as SUB.
    int32_t rn_value     = ~immediate_value + 1; // the trick is implemented here
    int32_t old_rd_value = cpu->regs[get_nth_bits(opcode, 8, 11)];
    
    uint32_t result = old_rd_value + rn_value;

    cpu->set_flag_Z(result == 0);
    cpu->set_flag_N(result >> 31);

    // Signed carry formula = (A AND B) OR (~DEST AND (A XOR B)) - works for all add operations once tested
    cpu->set_flag_C(!(immediate_value > (uint32_t)old_rd_value));

    bool matching_signs = get_nth_bit(old_rd_value, 31) == get_nth_bit(rn_value, 31);
    cpu->set_flag_V(matching_signs && (get_nth_bit(old_rd_value, 31) ^ get_nth_bit(result, 31)));

    cpu->cycles_remaining += 1;
}

void run_00101001(ARM7TDMI* cpu, uint16_t opcode);
void run_00101001(ARM7TDMI* cpu, uint16_t opcode) {
    uint8_t immediate_value = get_nth_bits(opcode, 0, 8);

    // CMP, which is basically a subtraction but the result isn't stored.
    // this uses the same two's complement trick that makes ADD the same as SUB.
    int32_t rn_value     = ~immediate_value + 1; // the trick is implemented here
    int32_t old_rd_value = cpu->regs[get_nth_bits(opcode, 8, 11)];
    
    uint32_t result = old_rd_value + rn_value;

    cpu->set_flag_Z(result == 0);
    cpu->set_flag_N(result >> 31);

    // Signed carry formula = (A AND B) OR (~DEST AND (A XOR B)) - works for all add operations once tested
    cpu->set_flag_C(!(immediate_value > (uint32_t)old_rd_value));

    bool matching_signs = get_nth_bit(old_rd_value, 31) == get_nth_bit(rn_value, 31);
    cpu->set_flag_V(matching_signs && (get_nth_bit(old_rd_value, 31) ^ get_nth_bit(result, 31)));

    cpu->cycles_remaining += 1;
}

void run_00101010(ARM7TDMI* cpu, uint16_t opcode);
void run_00101010(ARM7TDMI* cpu, uint16_t opcode) {
    uint8_t immediate_value = get_nth_bits(opcode, 0, 8);

    // CMP, which is basically a subtraction but the result isn't stored.
    // this uses the same two's complement trick that makes ADD the same as SUB.
    int32_t rn_value     = ~immediate_value + 1; // the trick is implemented here
    int32_t old_rd_value = cpu->regs[get_nth_bits(opcode, 8, 11)];
    
    uint32_t result = old_rd_value + rn_value;

    cpu->set_flag_Z(result == 0);
    cpu->set_flag_N(result >> 31);

    // Signed carry formula = (A AND B) OR (~DEST AND (A XOR B)) - works for all add operations once tested
    cpu->set_flag_C(!(immediate_value > (uint32_t)old_rd_value));

    bool matching_signs = get_nth_bit(old_rd_value, 31) == get_nth_bit(rn_value, 31);
    cpu->set_flag_V(matching_signs && (get_nth_bit(old_rd_value, 31) ^ get_nth_bit(result, 31)));

    cpu->cycles_remaining += 1;
}

void run_00101011(ARM7TDMI* cpu, uint16_t opcode);
void run_00101011(ARM7TDMI* cpu, uint16_t opcode) {
    uint8_t immediate_value = get_nth_bits(opcode, 0, 8);

    // CMP, which is basically a subtraction but the result isn't stored.
    // this uses the same two's complement trick that makes ADD the same as SUB.
    int32_t rn_value     = ~immediate_value + 1; // the trick is implemented here
    int32_t old_rd_value = cpu->regs[get_nth_bits(opcode, 8, 11)];
    
    uint32_t result = old_rd_value + rn_value;

    cpu->set_flag_Z(result == 0);
    cpu->set_flag_N(result >> 31);

    // Signed carry formula = (A AND B) OR (~DEST AND (A XOR B)) - works for all add operations once tested
    cpu->set_flag_C(!(immediate_value > (uint32_t)old_rd_value));

    bool matching_signs = get_nth_bit(old_rd_value, 31) == get_nth_bit(rn_value, 31);
    cpu->set_flag_V(matching_signs && (get_nth_bit(old_rd_value, 31) ^ get_nth_bit(result, 31)));

    cpu->cycles_remaining += 1;
}

void run_00101100(ARM7TDMI* cpu, uint16_t opcode);
void run_00101100(ARM7TDMI* cpu, uint16_t opcode) {
    uint8_t immediate_value = get_nth_bits(opcode, 0, 8);

    // CMP, which is basically a subtraction but the result isn't stored.
    // this uses the same two's complement trick that makes ADD the same as SUB.
    int32_t rn_value     = ~immediate_value + 1; // the trick is implemented here
    int32_t old_rd_value = cpu->regs[get_nth_bits(opcode, 8, 11)];
    
    uint32_t result = old_rd_value + rn_value;

    cpu->set_flag_Z(result == 0);
    cpu->set_flag_N(result >> 31);

    // Signed carry formula = (A AND B) OR (~DEST AND (A XOR B)) - works for all add operations once tested
    cpu->set_flag_C(!(immediate_value > (uint32_t)old_rd_value));

    bool matching_signs = get_nth_bit(old_rd_value, 31) == get_nth_bit(rn_value, 31);
    cpu->set_flag_V(matching_signs && (get_nth_bit(old_rd_value, 31) ^ get_nth_bit(result, 31)));

    cpu->cycles_remaining += 1;
}

void run_00101101(ARM7TDMI* cpu, uint16_t opcode);
void run_00101101(ARM7TDMI* cpu, uint16_t opcode) {
    uint8_t immediate_value = get_nth_bits(opcode, 0, 8);

    // CMP, which is basically a subtraction but the result isn't stored.
    // this uses the same two's complement trick that makes ADD the same as SUB.
    int32_t rn_value     = ~immediate_value + 1; // the trick is implemented here
    int32_t old_rd_value = cpu->regs[get_nth_bits(opcode, 8, 11)];
    
    uint32_t result = old_rd_value + rn_value;

    cpu->set_flag_Z(result == 0);
    cpu->set_flag_N(result >> 31);

    // Signed carry formula = (A AND B) OR (~DEST AND (A XOR B)) - works for all add operations once tested
    cpu->set_flag_C(!(immediate_value > (uint32_t)old_rd_value));

    bool matching_signs = get_nth_bit(old_rd_value, 31) == get_nth_bit(rn_value, 31);
    cpu->set_flag_V(matching_signs && (get_nth_bit(old_rd_value, 31) ^ get_nth_bit(result, 31)));

    cpu->cycles_remaining += 1;
}

void run_00101110(ARM7TDMI* cpu, uint16_t opcode);
void run_00101110(ARM7TDMI* cpu, uint16_t opcode) {
    uint8_t immediate_value = get_nth_bits(opcode, 0, 8);

    // CMP, which is basically a subtraction but the result isn't stored.
    // this uses the same two's complement trick that makes ADD the same as SUB.
    int32_t rn_value     = ~immediate_value + 1; // the trick is implemented here
    int32_t old_rd_value = cpu->regs[get_nth_bits(opcode, 8, 11)];
    
    uint32_t result = old_rd_value + rn_value;

    cpu->set_flag_Z(result == 0);
    cpu->set_flag_N(result >> 31);

    // Signed carry formula = (A AND B) OR (~DEST AND (A XOR B)) - works for all add operations once tested
    cpu->set_flag_C(!(immediate_value > (uint32_t)old_rd_value));

    bool matching_signs = get_nth_bit(old_rd_value, 31) == get_nth_bit(rn_value, 31);
    cpu->set_flag_V(matching_signs && (get_nth_bit(old_rd_value, 31) ^ get_nth_bit(result, 31)));

    cpu->cycles_remaining += 1;
}

void run_00101111(ARM7TDMI* cpu, uint16_t opcode);
void run_00101111(ARM7TDMI* cpu, uint16_t opcode) {
    uint8_t immediate_value = get_nth_bits(opcode, 0, 8);

    // CMP, which is basically a subtraction but the result isn't stored.
    // this uses the same two's complement trick that makes ADD the same as SUB.
    int32_t rn_value     = ~immediate_value + 1; // the trick is implemented here
    int32_t old_rd_value = cpu->regs[get_nth_bits(opcode, 8, 11)];
    
    uint32_t result = old_rd_value + rn_value;

    cpu->set_flag_Z(result == 0);
    cpu->set_flag_N(result >> 31);

    // Signed carry formula = (A AND B) OR (~DEST AND (A XOR B)) - works for all add operations once tested
    cpu->set_flag_C(!(immediate_value > (uint32_t)old_rd_value));

    bool matching_signs = get_nth_bit(old_rd_value, 31) == get_nth_bit(rn_value, 31);
    cpu->set_flag_V(matching_signs && (get_nth_bit(old_rd_value, 31) ^ get_nth_bit(result, 31)));

    cpu->cycles_remaining += 1;
}

void run_00110000(ARM7TDMI* cpu, uint16_t opcode);
void run_00110000(ARM7TDMI* cpu, uint16_t opcode) {
    DEBUG_MESSAGE("Add Register Immediate");

    int32_t immediate_value = get_nth_bits(opcode, 0, 8);
    uint32_t rd             = get_nth_bits(opcode, 8, 11);
    int32_t old_rd_value    = cpu->regs[rd];

    cpu->regs[rd] += immediate_value;
    int32_t new_rd_value    = cpu->regs[rd];

    cpu->set_flag_N(get_nth_bit(new_rd_value, 31));
    cpu->set_flag_Z((new_rd_value == 0));

    // Signed carry formula = (A AND B) OR (~DEST AND (A XOR B)) - works for all add operations once tested
    cpu->set_flag_C((get_nth_bit(immediate_value, 31) & get_nth_bit(old_rd_value, 31)) | 
    ((get_nth_bit(immediate_value, 31) ^ get_nth_bit(old_rd_value, 31)) & ~(get_nth_bit(new_rd_value, 31))));

    bool matching_signs = get_nth_bit(old_rd_value, 31) == get_nth_bit(immediate_value, 31);
    cpu->set_flag_V(matching_signs && (get_nth_bit(old_rd_value, 31) ^ cpu->get_flag_N()));

    cpu->cycles_remaining += 1;
}

void run_00110001(ARM7TDMI* cpu, uint16_t opcode);
void run_00110001(ARM7TDMI* cpu, uint16_t opcode) {
    DEBUG_MESSAGE("Add Register Immediate");

    int32_t immediate_value = get_nth_bits(opcode, 0, 8);
    uint32_t rd             = get_nth_bits(opcode, 8, 11);
    int32_t old_rd_value    = cpu->regs[rd];

    cpu->regs[rd] += immediate_value;
    int32_t new_rd_value    = cpu->regs[rd];

    cpu->set_flag_N(get_nth_bit(new_rd_value, 31));
    cpu->set_flag_Z((new_rd_value == 0));

    // Signed carry formula = (A AND B) OR (~DEST AND (A XOR B)) - works for all add operations once tested
    cpu->set_flag_C((get_nth_bit(immediate_value, 31) & get_nth_bit(old_rd_value, 31)) | 
    ((get_nth_bit(immediate_value, 31) ^ get_nth_bit(old_rd_value, 31)) & ~(get_nth_bit(new_rd_value, 31))));

    bool matching_signs = get_nth_bit(old_rd_value, 31) == get_nth_bit(immediate_value, 31);
    cpu->set_flag_V(matching_signs && (get_nth_bit(old_rd_value, 31) ^ cpu->get_flag_N()));

    cpu->cycles_remaining += 1;
}

void run_00110010(ARM7TDMI* cpu, uint16_t opcode);
void run_00110010(ARM7TDMI* cpu, uint16_t opcode) {
    DEBUG_MESSAGE("Add Register Immediate");

    int32_t immediate_value = get_nth_bits(opcode, 0, 8);
    uint32_t rd             = get_nth_bits(opcode, 8, 11);
    int32_t old_rd_value    = cpu->regs[rd];

    cpu->regs[rd] += immediate_value;
    int32_t new_rd_value    = cpu->regs[rd];

    cpu->set_flag_N(get_nth_bit(new_rd_value, 31));
    cpu->set_flag_Z((new_rd_value == 0));

    // Signed carry formula = (A AND B) OR (~DEST AND (A XOR B)) - works for all add operations once tested
    cpu->set_flag_C((get_nth_bit(immediate_value, 31) & get_nth_bit(old_rd_value, 31)) | 
    ((get_nth_bit(immediate_value, 31) ^ get_nth_bit(old_rd_value, 31)) & ~(get_nth_bit(new_rd_value, 31))));

    bool matching_signs = get_nth_bit(old_rd_value, 31) == get_nth_bit(immediate_value, 31);
    cpu->set_flag_V(matching_signs && (get_nth_bit(old_rd_value, 31) ^ cpu->get_flag_N()));

    cpu->cycles_remaining += 1;
}

void run_00110011(ARM7TDMI* cpu, uint16_t opcode);
void run_00110011(ARM7TDMI* cpu, uint16_t opcode) {
    DEBUG_MESSAGE("Add Register Immediate");

    int32_t immediate_value = get_nth_bits(opcode, 0, 8);
    uint32_t rd             = get_nth_bits(opcode, 8, 11);
    int32_t old_rd_value    = cpu->regs[rd];

    cpu->regs[rd] += immediate_value;
    int32_t new_rd_value    = cpu->regs[rd];

    cpu->set_flag_N(get_nth_bit(new_rd_value, 31));
    cpu->set_flag_Z((new_rd_value == 0));

    // Signed carry formula = (A AND B) OR (~DEST AND (A XOR B)) - works for all add operations once tested
    cpu->set_flag_C((get_nth_bit(immediate_value, 31) & get_nth_bit(old_rd_value, 31)) | 
    ((get_nth_bit(immediate_value, 31) ^ get_nth_bit(old_rd_value, 31)) & ~(get_nth_bit(new_rd_value, 31))));

    bool matching_signs = get_nth_bit(old_rd_value, 31) == get_nth_bit(immediate_value, 31);
    cpu->set_flag_V(matching_signs && (get_nth_bit(old_rd_value, 31) ^ cpu->get_flag_N()));

    cpu->cycles_remaining += 1;
}

void run_00110100(ARM7TDMI* cpu, uint16_t opcode);
void run_00110100(ARM7TDMI* cpu, uint16_t opcode) {
    DEBUG_MESSAGE("Add Register Immediate");

    int32_t immediate_value = get_nth_bits(opcode, 0, 8);
    uint32_t rd             = get_nth_bits(opcode, 8, 11);
    int32_t old_rd_value    = cpu->regs[rd];

    cpu->regs[rd] += immediate_value;
    int32_t new_rd_value    = cpu->regs[rd];

    cpu->set_flag_N(get_nth_bit(new_rd_value, 31));
    cpu->set_flag_Z((new_rd_value == 0));

    // Signed carry formula = (A AND B) OR (~DEST AND (A XOR B)) - works for all add operations once tested
    cpu->set_flag_C((get_nth_bit(immediate_value, 31) & get_nth_bit(old_rd_value, 31)) | 
    ((get_nth_bit(immediate_value, 31) ^ get_nth_bit(old_rd_value, 31)) & ~(get_nth_bit(new_rd_value, 31))));

    bool matching_signs = get_nth_bit(old_rd_value, 31) == get_nth_bit(immediate_value, 31);
    cpu->set_flag_V(matching_signs && (get_nth_bit(old_rd_value, 31) ^ cpu->get_flag_N()));

    cpu->cycles_remaining += 1;
}

void run_00110101(ARM7TDMI* cpu, uint16_t opcode);
void run_00110101(ARM7TDMI* cpu, uint16_t opcode) {
    DEBUG_MESSAGE("Add Register Immediate");

    int32_t immediate_value = get_nth_bits(opcode, 0, 8);
    uint32_t rd             = get_nth_bits(opcode, 8, 11);
    int32_t old_rd_value    = cpu->regs[rd];

    cpu->regs[rd] += immediate_value;
    int32_t new_rd_value    = cpu->regs[rd];

    cpu->set_flag_N(get_nth_bit(new_rd_value, 31));
    cpu->set_flag_Z((new_rd_value == 0));

    // Signed carry formula = (A AND B) OR (~DEST AND (A XOR B)) - works for all add operations once tested
    cpu->set_flag_C((get_nth_bit(immediate_value, 31) & get_nth_bit(old_rd_value, 31)) | 
    ((get_nth_bit(immediate_value, 31) ^ get_nth_bit(old_rd_value, 31)) & ~(get_nth_bit(new_rd_value, 31))));

    bool matching_signs = get_nth_bit(old_rd_value, 31) == get_nth_bit(immediate_value, 31);
    cpu->set_flag_V(matching_signs && (get_nth_bit(old_rd_value, 31) ^ cpu->get_flag_N()));

    cpu->cycles_remaining += 1;
}

void run_00110110(ARM7TDMI* cpu, uint16_t opcode);
void run_00110110(ARM7TDMI* cpu, uint16_t opcode) {
    DEBUG_MESSAGE("Add Register Immediate");

    int32_t immediate_value = get_nth_bits(opcode, 0, 8);
    uint32_t rd             = get_nth_bits(opcode, 8, 11);
    int32_t old_rd_value    = cpu->regs[rd];

    cpu->regs[rd] += immediate_value;
    int32_t new_rd_value    = cpu->regs[rd];

    cpu->set_flag_N(get_nth_bit(new_rd_value, 31));
    cpu->set_flag_Z((new_rd_value == 0));

    // Signed carry formula = (A AND B) OR (~DEST AND (A XOR B)) - works for all add operations once tested
    cpu->set_flag_C((get_nth_bit(immediate_value, 31) & get_nth_bit(old_rd_value, 31)) | 
    ((get_nth_bit(immediate_value, 31) ^ get_nth_bit(old_rd_value, 31)) & ~(get_nth_bit(new_rd_value, 31))));

    bool matching_signs = get_nth_bit(old_rd_value, 31) == get_nth_bit(immediate_value, 31);
    cpu->set_flag_V(matching_signs && (get_nth_bit(old_rd_value, 31) ^ cpu->get_flag_N()));

    cpu->cycles_remaining += 1;
}

void run_00110111(ARM7TDMI* cpu, uint16_t opcode);
void run_00110111(ARM7TDMI* cpu, uint16_t opcode) {
    DEBUG_MESSAGE("Add Register Immediate");

    int32_t immediate_value = get_nth_bits(opcode, 0, 8);
    uint32_t rd             = get_nth_bits(opcode, 8, 11);
    int32_t old_rd_value    = cpu->regs[rd];

    cpu->regs[rd] += immediate_value;
    int32_t new_rd_value    = cpu->regs[rd];

    cpu->set_flag_N(get_nth_bit(new_rd_value, 31));
    cpu->set_flag_Z((new_rd_value == 0));

    // Signed carry formula = (A AND B) OR (~DEST AND (A XOR B)) - works for all add operations once tested
    cpu->set_flag_C((get_nth_bit(immediate_value, 31) & get_nth_bit(old_rd_value, 31)) | 
    ((get_nth_bit(immediate_value, 31) ^ get_nth_bit(old_rd_value, 31)) & ~(get_nth_bit(new_rd_value, 31))));

    bool matching_signs = get_nth_bit(old_rd_value, 31) == get_nth_bit(immediate_value, 31);
    cpu->set_flag_V(matching_signs && (get_nth_bit(old_rd_value, 31) ^ cpu->get_flag_N()));

    cpu->cycles_remaining += 1;
}

void run_00111000(ARM7TDMI* cpu, uint16_t opcode);
void run_00111000(ARM7TDMI* cpu, uint16_t opcode) {
    // maybe we can link add immediate with subtract immediate using twos complement...
    // like, a - b is the same as a + (~b)
    DEBUG_MESSAGE("Subtract Immediate");

    uint32_t immediate_value = get_nth_bits(opcode, 0, 8);
    uint8_t  rd              = get_nth_bits(opcode, 8, 11);
    uint32_t old_rd_value    = cpu->regs[rd];
    
    cpu->regs[rd]  -= immediate_value;
    uint32_t new_rd_value    = cpu->regs[rd];

    cpu->set_flag_N(get_nth_bit(new_rd_value, 31));
    cpu->set_flag_Z(new_rd_value == 0);
    cpu->set_flag_C(immediate_value <= old_rd_value);

    // this is garbage, but essentially what's going on is:
    // if the two operands had matching signs but their sign differed from the result's sign,
    // then there was an overflow and we set the flag.
    /*
    bool matching_signs = get_nth_bit(old_rd_value, 31) == get_nth_bit(immediate_value, 31);
    cpu->set_flag_V(matching_signs && (get_nth_bit(new_rd_value, 31) ^ cpu->get_flag_N()));*/
    bool matching_signs = get_nth_bit(old_rd_value, 31) == get_nth_bit(immediate_value, 31);
    cpu->set_flag_V(!matching_signs && (get_nth_bit(immediate_value, 31) == cpu->get_flag_N()));

    cpu->cycles_remaining += 1;
}

void run_00111001(ARM7TDMI* cpu, uint16_t opcode);
void run_00111001(ARM7TDMI* cpu, uint16_t opcode) {
    // maybe we can link add immediate with subtract immediate using twos complement...
    // like, a - b is the same as a + (~b)
    DEBUG_MESSAGE("Subtract Immediate");

    uint32_t immediate_value = get_nth_bits(opcode, 0, 8);
    uint8_t  rd              = get_nth_bits(opcode, 8, 11);
    uint32_t old_rd_value    = cpu->regs[rd];
    
    cpu->regs[rd]  -= immediate_value;
    uint32_t new_rd_value    = cpu->regs[rd];

    cpu->set_flag_N(get_nth_bit(new_rd_value, 31));
    cpu->set_flag_Z(new_rd_value == 0);
    cpu->set_flag_C(immediate_value <= old_rd_value);

    // this is garbage, but essentially what's going on is:
    // if the two operands had matching signs but their sign differed from the result's sign,
    // then there was an overflow and we set the flag.
    /*
    bool matching_signs = get_nth_bit(old_rd_value, 31) == get_nth_bit(immediate_value, 31);
    cpu->set_flag_V(matching_signs && (get_nth_bit(new_rd_value, 31) ^ cpu->get_flag_N()));*/
    bool matching_signs = get_nth_bit(old_rd_value, 31) == get_nth_bit(immediate_value, 31);
    cpu->set_flag_V(!matching_signs && (get_nth_bit(immediate_value, 31) == cpu->get_flag_N()));

    cpu->cycles_remaining += 1;
}

void run_00111010(ARM7TDMI* cpu, uint16_t opcode);
void run_00111010(ARM7TDMI* cpu, uint16_t opcode) {
    // maybe we can link add immediate with subtract immediate using twos complement...
    // like, a - b is the same as a + (~b)
    DEBUG_MESSAGE("Subtract Immediate");

    uint32_t immediate_value = get_nth_bits(opcode, 0, 8);
    uint8_t  rd              = get_nth_bits(opcode, 8, 11);
    uint32_t old_rd_value    = cpu->regs[rd];
    
    cpu->regs[rd]  -= immediate_value;
    uint32_t new_rd_value    = cpu->regs[rd];

    cpu->set_flag_N(get_nth_bit(new_rd_value, 31));
    cpu->set_flag_Z(new_rd_value == 0);
    cpu->set_flag_C(immediate_value <= old_rd_value);

    // this is garbage, but essentially what's going on is:
    // if the two operands had matching signs but their sign differed from the result's sign,
    // then there was an overflow and we set the flag.
    /*
    bool matching_signs = get_nth_bit(old_rd_value, 31) == get_nth_bit(immediate_value, 31);
    cpu->set_flag_V(matching_signs && (get_nth_bit(new_rd_value, 31) ^ cpu->get_flag_N()));*/
    bool matching_signs = get_nth_bit(old_rd_value, 31) == get_nth_bit(immediate_value, 31);
    cpu->set_flag_V(!matching_signs && (get_nth_bit(immediate_value, 31) == cpu->get_flag_N()));

    cpu->cycles_remaining += 1;
}

void run_00111011(ARM7TDMI* cpu, uint16_t opcode);
void run_00111011(ARM7TDMI* cpu, uint16_t opcode) {
    // maybe we can link add immediate with subtract immediate using twos complement...
    // like, a - b is the same as a + (~b)
    DEBUG_MESSAGE("Subtract Immediate");

    uint32_t immediate_value = get_nth_bits(opcode, 0, 8);
    uint8_t  rd              = get_nth_bits(opcode, 8, 11);
    uint32_t old_rd_value    = cpu->regs[rd];
    
    cpu->regs[rd]  -= immediate_value;
    uint32_t new_rd_value    = cpu->regs[rd];

    cpu->set_flag_N(get_nth_bit(new_rd_value, 31));
    cpu->set_flag_Z(new_rd_value == 0);
    cpu->set_flag_C(immediate_value <= old_rd_value);

    // this is garbage, but essentially what's going on is:
    // if the two operands had matching signs but their sign differed from the result's sign,
    // then there was an overflow and we set the flag.
    /*
    bool matching_signs = get_nth_bit(old_rd_value, 31) == get_nth_bit(immediate_value, 31);
    cpu->set_flag_V(matching_signs && (get_nth_bit(new_rd_value, 31) ^ cpu->get_flag_N()));*/
    bool matching_signs = get_nth_bit(old_rd_value, 31) == get_nth_bit(immediate_value, 31);
    cpu->set_flag_V(!matching_signs && (get_nth_bit(immediate_value, 31) == cpu->get_flag_N()));

    cpu->cycles_remaining += 1;
}

void run_00111100(ARM7TDMI* cpu, uint16_t opcode);
void run_00111100(ARM7TDMI* cpu, uint16_t opcode) {
    // maybe we can link add immediate with subtract immediate using twos complement...
    // like, a - b is the same as a + (~b)
    DEBUG_MESSAGE("Subtract Immediate");

    uint32_t immediate_value = get_nth_bits(opcode, 0, 8);
    uint8_t  rd              = get_nth_bits(opcode, 8, 11);
    uint32_t old_rd_value    = cpu->regs[rd];
    
    cpu->regs[rd]  -= immediate_value;
    uint32_t new_rd_value    = cpu->regs[rd];

    cpu->set_flag_N(get_nth_bit(new_rd_value, 31));
    cpu->set_flag_Z(new_rd_value == 0);
    cpu->set_flag_C(immediate_value <= old_rd_value);

    // this is garbage, but essentially what's going on is:
    // if the two operands had matching signs but their sign differed from the result's sign,
    // then there was an overflow and we set the flag.
    /*
    bool matching_signs = get_nth_bit(old_rd_value, 31) == get_nth_bit(immediate_value, 31);
    cpu->set_flag_V(matching_signs && (get_nth_bit(new_rd_value, 31) ^ cpu->get_flag_N()));*/
    bool matching_signs = get_nth_bit(old_rd_value, 31) == get_nth_bit(immediate_value, 31);
    cpu->set_flag_V(!matching_signs && (get_nth_bit(immediate_value, 31) == cpu->get_flag_N()));

    cpu->cycles_remaining += 1;
}

void run_00111101(ARM7TDMI* cpu, uint16_t opcode);
void run_00111101(ARM7TDMI* cpu, uint16_t opcode) {
    // maybe we can link add immediate with subtract immediate using twos complement...
    // like, a - b is the same as a + (~b)
    DEBUG_MESSAGE("Subtract Immediate");

    uint32_t immediate_value = get_nth_bits(opcode, 0, 8);
    uint8_t  rd              = get_nth_bits(opcode, 8, 11);
    uint32_t old_rd_value    = cpu->regs[rd];
    
    cpu->regs[rd]  -= immediate_value;
    uint32_t new_rd_value    = cpu->regs[rd];

    cpu->set_flag_N(get_nth_bit(new_rd_value, 31));
    cpu->set_flag_Z(new_rd_value == 0);
    cpu->set_flag_C(immediate_value <= old_rd_value);

    // this is garbage, but essentially what's going on is:
    // if the two operands had matching signs but their sign differed from the result's sign,
    // then there was an overflow and we set the flag.
    /*
    bool matching_signs = get_nth_bit(old_rd_value, 31) == get_nth_bit(immediate_value, 31);
    cpu->set_flag_V(matching_signs && (get_nth_bit(new_rd_value, 31) ^ cpu->get_flag_N()));*/
    bool matching_signs = get_nth_bit(old_rd_value, 31) == get_nth_bit(immediate_value, 31);
    cpu->set_flag_V(!matching_signs && (get_nth_bit(immediate_value, 31) == cpu->get_flag_N()));

    cpu->cycles_remaining += 1;
}

void run_00111110(ARM7TDMI* cpu, uint16_t opcode);
void run_00111110(ARM7TDMI* cpu, uint16_t opcode) {
    // maybe we can link add immediate with subtract immediate using twos complement...
    // like, a - b is the same as a + (~b)
    DEBUG_MESSAGE("Subtract Immediate");

    uint32_t immediate_value = get_nth_bits(opcode, 0, 8);
    uint8_t  rd              = get_nth_bits(opcode, 8, 11);
    uint32_t old_rd_value    = cpu->regs[rd];
    
    cpu->regs[rd]  -= immediate_value;
    uint32_t new_rd_value    = cpu->regs[rd];

    cpu->set_flag_N(get_nth_bit(new_rd_value, 31));
    cpu->set_flag_Z(new_rd_value == 0);
    cpu->set_flag_C(immediate_value <= old_rd_value);

    // this is garbage, but essentially what's going on is:
    // if the two operands had matching signs but their sign differed from the result's sign,
    // then there was an overflow and we set the flag.
    /*
    bool matching_signs = get_nth_bit(old_rd_value, 31) == get_nth_bit(immediate_value, 31);
    cpu->set_flag_V(matching_signs && (get_nth_bit(new_rd_value, 31) ^ cpu->get_flag_N()));*/
    bool matching_signs = get_nth_bit(old_rd_value, 31) == get_nth_bit(immediate_value, 31);
    cpu->set_flag_V(!matching_signs && (get_nth_bit(immediate_value, 31) == cpu->get_flag_N()));

    cpu->cycles_remaining += 1;
}

void run_00111111(ARM7TDMI* cpu, uint16_t opcode);
void run_00111111(ARM7TDMI* cpu, uint16_t opcode) {
    // maybe we can link add immediate with subtract immediate using twos complement...
    // like, a - b is the same as a + (~b)
    DEBUG_MESSAGE("Subtract Immediate");

    uint32_t immediate_value = get_nth_bits(opcode, 0, 8);
    uint8_t  rd              = get_nth_bits(opcode, 8, 11);
    uint32_t old_rd_value    = cpu->regs[rd];
    
    cpu->regs[rd]  -= immediate_value;
    uint32_t new_rd_value    = cpu->regs[rd];

    cpu->set_flag_N(get_nth_bit(new_rd_value, 31));
    cpu->set_flag_Z(new_rd_value == 0);
    cpu->set_flag_C(immediate_value <= old_rd_value);

    // this is garbage, but essentially what's going on is:
    // if the two operands had matching signs but their sign differed from the result's sign,
    // then there was an overflow and we set the flag.
    /*
    bool matching_signs = get_nth_bit(old_rd_value, 31) == get_nth_bit(immediate_value, 31);
    cpu->set_flag_V(matching_signs && (get_nth_bit(new_rd_value, 31) ^ cpu->get_flag_N()));*/
    bool matching_signs = get_nth_bit(old_rd_value, 31) == get_nth_bit(immediate_value, 31);
    cpu->set_flag_V(!matching_signs && (get_nth_bit(immediate_value, 31) == cpu->get_flag_N()));

    cpu->cycles_remaining += 1;
}

void run_01000000(ARM7TDMI* cpu, uint16_t opcode);
void run_01000000(ARM7TDMI* cpu, uint16_t opcode) {
    DEBUG_MESSAGE("ALU Operation - AND / EOR / LSL #2 / LSR #2");
    uint8_t rd = get_nth_bits(opcode, 0, 3);
    uint8_t rm = get_nth_bits(opcode, 3, 6);

    switch (get_nth_bits(opcode, 6, 8)) {
        case 0b00:
            cpu->regs[rd] &= cpu->regs[rm];
            break;
        case 0b01:
            cpu->regs[rd] ^= cpu->regs[rm];
            break;
        case 0b10:
            if ((cpu->regs[rm] & 0xFF) < 32 && (cpu->regs[rm] & 0xFF) != 0) {
                cpu->set_flag_C(get_nth_bit(cpu->regs[rd], 32 - (cpu->regs[rm] & 0xFF)));
                cpu->regs[rd] <<= (cpu->regs[rm] & 0xFF);
            } else if ((cpu->regs[rm] & 0xFF) == 32) {
                cpu->set_flag_C(cpu->regs[rd] & 1);
                cpu->regs[rd] = 0;
            } else if ((cpu->regs[rm] & 0xFF) > 32) {
                cpu->set_flag_C(false);
                cpu->regs[rd] = 0;
            }

            cpu->cycles_remaining += 1;
            break;
        case 0b11:
            if ((cpu->regs[rm] & 0xFF) < 32 && (cpu->regs[rm] & 0xFF) != 0) {
                cpu->set_flag_C(get_nth_bit(cpu->regs[rd], (cpu->regs[rm] & 0xFF) - 1));
                cpu->regs[rd] >>= (cpu->regs[rm] & 0xFF);
            } else if ((cpu->regs[rm] & 0xFF) == 32) {
                cpu->set_flag_C(cpu->regs[rd] >> 31);
                cpu->regs[rd] = 0;
            } else if ((cpu->regs[rm] & 0xFF) > 32) {
                cpu->set_flag_C(false);
                cpu->regs[rd] = 0;
            }

            cpu->cycles_remaining += 1;
            break;
    }

    cpu->set_flag_N(cpu->regs[rd] >> 31);
    cpu->set_flag_Z(cpu->regs[rd] == 0);

    cpu->cycles_remaining += 1;
}

void run_01000001(ARM7TDMI* cpu, uint16_t opcode);
void run_01000001(ARM7TDMI* cpu, uint16_t opcode) {
    DEBUG_MESSAGE("ALU Operation - ASR #2 / ADC / SBC / ROR");
    uint8_t rd = get_nth_bits(opcode, 0, 3);
    uint8_t rm = get_nth_bits(opcode, 3, 6);

    switch (get_nth_bits(opcode, 6, 8)) {
        case 0b00: {
            // ASR #2
            uint8_t low_byte = cpu->regs[rm] & 0xFF;
            if (low_byte < 32 && low_byte != 0) {
                cpu->set_flag_C(get_nth_bit(cpu->regs[rd], low_byte - 1));
                // arithmetic shift requires us to cast to signed int first, then back to unsigned to store in registers.
                cpu->regs[rd] = (uint32_t) (((int32_t) cpu->regs[rd]) >> cpu->regs[rm]);
            } else if (low_byte >= 32) {
                cpu->set_flag_C(cpu->regs[rd] >> 31);
                if (cpu->get_flag_C()) {
                    cpu->regs[rd] = 0xFFFFFFFF; // taking into account two's complement
                } else {
                    cpu->regs[rd] = 0x00000000;
                }
            }

            cpu->cycles_remaining += 1;
            break;
        }
        
        case 0b01: {
            // ADC - this code will look very similar to the Add Register instruction. it just also utilizes the carry bit.
            int32_t rm_value     = cpu->regs[rm];
            int32_t old_rd_value = cpu->regs[rd];

            cpu->regs[rd] += rm_value + cpu->get_flag_C();
            int32_t new_rd_value = cpu->regs[rd];

            cpu->set_flag_N(get_nth_bit(new_rd_value, 31));
            cpu->set_flag_Z((new_rd_value == 0));

            // Signed carry formula = (A AND B) OR (~DEST AND (A XOR B)) - works for all add operations once tested
            cpu->set_flag_C((get_nth_bit(rm_value, 31) & get_nth_bit(old_rd_value, 31)) | 
            ((get_nth_bit(rm_value, 31) ^ get_nth_bit(old_rd_value, 31)) & ~(get_nth_bit(new_rd_value, 31))));

            bool matching_signs = get_nth_bit(old_rd_value, 31) == get_nth_bit(rm_value, 31);
            cpu->set_flag_V(matching_signs && (get_nth_bit(old_rd_value, 31) ^ cpu->get_flag_N()));
            break;
        }

        case 0b10: {
            // SBC - using a twos complement trick, SBC will just be the same thing as ADC, just with a negative rm_value.
            int32_t rm_value     = ~cpu->regs[rm] + 1; // the trick is implemented here
            int32_t old_rd_value = cpu->regs[rd];

            cpu->regs[rd] += rm_value - (cpu->get_flag_C() ? 0 : 1); // as well as over here
            int32_t new_rd_value = cpu->regs[rd];

            cpu->set_flag_N(get_nth_bit(new_rd_value, 31));
            cpu->set_flag_Z((new_rd_value == 0));

            // bool matching_signs = get_nth_bit(old_rd_value, 31) == get_nth_bit(rm_value - (cpu->get_flag_C() ? 0 : 1), 31);
            // cpu->set_flag_V(matching_signs && (get_nth_bit(old_rd_value, 31) ^ cpu->get_flag_N()));
            bool matching_signs = get_nth_bit(old_rd_value, 31) == get_nth_bit(cpu->regs[rm], 31);
            cpu->set_flag_V(!matching_signs && (get_nth_bit(cpu->regs[rm], 31) == cpu->get_flag_N()));

            // Signed carry formula = (A AND B) OR (~DEST AND (A XOR B)) - works for all add operations once tested
            cpu->set_flag_C((!(((uint64_t)cpu->regs[rm]) + (cpu->get_flag_C() ? 0 : 1) > (uint32_t)old_rd_value)));
            break;
        }

        case 0b11: {
            // ROR - Rotates the register to the right by cpu->regs[rm]
            if ((cpu->regs[rm] & 0xFF) == 0) 
                break;

            if ((cpu->regs[rm] & 0xF) == 0) {
                cpu->set_flag_C(get_nth_bit(cpu->regs[rd], 31));
            } else {
                cpu->set_flag_C(get_nth_bit(cpu->regs[rd], (cpu->regs[rm] & 0xF) - 1));
                uint32_t rotated_off = get_nth_bits(cpu->regs[rd], 0, cpu->regs[rm] & 0xF);  // the value that is rotated off
                uint32_t rotated_in  = get_nth_bits(cpu->regs[rd], cpu->regs[rm] & 0xF, 32); // the value that stays after the rotation
                cpu->regs[rd] = rotated_in | (rotated_off << (32 - (cpu->regs[rm] & 0xF)));
            }

            cpu->cycles_remaining += 1;
        }
    }

    cpu->cycles_remaining += 1;
    cpu->set_flag_N(cpu->regs[rd] >> 31);
    cpu->set_flag_Z(cpu->regs[rd] == 0);
}

void run_01000010(ARM7TDMI* cpu, uint16_t opcode);
void run_01000010(ARM7TDMI* cpu, uint16_t opcode) {
    DEBUG_MESSAGE("ALU Operation - TST / NEG / CMP #2 / CMN");
    uint8_t rd = get_nth_bits(opcode, 0, 3);
    uint8_t rm = get_nth_bits(opcode, 3, 6);
    uint32_t result;

    switch (get_nth_bits(opcode, 6, 8)) {
        case 0b00:
            // TST - result is equal to the two values and'ed.
            result = cpu->regs[rm] & cpu->regs[rd];
            break;

        case 0b01:
            // NEG - Rd = 0 - Rm
            cpu->regs[rd] = ~cpu->regs[rm] + 1;
            result = cpu->regs[rd];
            cpu->set_flag_C(result == 0);
            cpu->set_flag_V(get_nth_bit(result, 31) && get_nth_bit(cpu->regs[rm], 31));
            break;

        case 0b10: {
            // CMP, which is basically a subtraction but the result isn't stored.
            // again, this uses the same two's complement trick that makes ADD the same as SUB.
            int32_t rm_value     = ~cpu->regs[rm] + 1; // the trick is implemented here
            int32_t old_rd_value = cpu->regs[rd];

            result = cpu->regs[rd] + rm_value;

            // Signed carry formula = (A AND B) OR (~DEST AND (A XOR B)) - works for all add operations once tested
            cpu->set_flag_C(!(cpu->regs[rm] > cpu->regs[rd]));

            bool matching_signs = get_nth_bit(old_rd_value, 31) == get_nth_bit(rm_value, 31);
            cpu->set_flag_V(matching_signs && (get_nth_bit(old_rd_value, 31) ^ get_nth_bit(result, 31)));
            break;
        }
        
        case 0b11: {
            // CMN - see the above note for CMP (case 0b10). CMP is to SUB what CMN is to ADD.
            int32_t rm_value     = cpu->regs[rm];
            int32_t old_rd_value = cpu->regs[rd];

            result = cpu->regs[rd] + rm_value;

            // Signed carry formula = (A AND B) OR (~DEST AND (A XOR B)) - works for all add operations once tested
            cpu->set_flag_C((get_nth_bit(rm_value, 31) & get_nth_bit(old_rd_value, 31)) | 
            ((get_nth_bit(rm_value, 31) ^ get_nth_bit(old_rd_value, 31)) & ~(get_nth_bit(result, 31))));

            bool matching_signs = get_nth_bit(old_rd_value, 31) == get_nth_bit(rm_value, 31);
            cpu->set_flag_V(matching_signs && (get_nth_bit(old_rd_value, 31) ^ get_nth_bit(result, 31)));
            break;
        }
    }

    cpu->cycles_remaining += 1;
    cpu->set_flag_N(get_nth_bit(result, 31));
    cpu->set_flag_Z(result == 0);
}

void run_01000011(ARM7TDMI* cpu, uint16_t opcode);
void run_01000011(ARM7TDMI* cpu, uint16_t opcode) {
    DEBUG_MESSAGE("ALU Operation - ORR / MUL / BIC / MVN");
    uint8_t rd = get_nth_bits(opcode, 0, 3);
    uint8_t rm = get_nth_bits(opcode, 3, 6);

    switch (get_nth_bits(opcode, 6, 8)) {
        case 0b00:
            cpu->regs[rd] |= cpu->regs[rm];
            break;
        case 0b01:
            cpu->regs[rd] *= cpu->regs[rm];
            break;
        case 0b10:
            cpu->regs[rd] = cpu->regs[rd] & ~ cpu->regs[rm];
            break;
        case 0b11:
            cpu->regs[rd] = ~cpu->regs[rm];
    }

    cpu->cycles_remaining += 1;
    cpu->set_flag_N(get_nth_bit(cpu->regs[rd], 31));
    cpu->set_flag_Z(cpu->regs[rd] == 0);
}

void run_01000100(ARM7TDMI* cpu, uint16_t opcode);
void run_01000100(ARM7TDMI* cpu, uint16_t opcode) {
    uint8_t rm = get_nth_bits(opcode, 3, 7);
    uint8_t rd = get_nth_bits(opcode, 0, 3) | (get_nth_bit(opcode, 7) << 3);

    cpu->regs[rd] += cpu->regs[rm];

    cpu->cycles_remaining += 1;
}

void run_01000101(ARM7TDMI* cpu, uint16_t opcode);
void run_01000101(ARM7TDMI* cpu, uint16_t opcode) {
    // CMP is basically a subtraction but the result isn't stored.
    // this uses a two's complement trick that makes ADD the same as SUB.
    uint8_t rm = get_nth_bits(opcode, 3, 7);
    uint8_t rd = get_nth_bits(opcode, 0, 3) | (get_nth_bit(opcode, 7) << 3);
    int32_t rm_value     = ~cpu->regs[rm] + 1; // the trick is implemented here
    int32_t old_rd_value = cpu->regs[rd];

    uint32_t result = cpu->regs[rd] + rm_value;

    cpu->set_flag_N(get_nth_bit(result, 31));
    cpu->set_flag_Z(result == 0);

    // Signed carry formula = (A AND B) OR (~DEST AND (A XOR B)) - works for all add operations once tested
    cpu->set_flag_C(!(cpu->regs[rm] > cpu->regs[rd]));

    bool matching_signs = get_nth_bit(old_rd_value, 31) == get_nth_bit(rm_value, 31);
    cpu->set_flag_V(matching_signs && (get_nth_bit(old_rd_value, 31) ^ get_nth_bit(result, 31)));

    cpu->cycles_remaining += 1;
}

void run_01000110(ARM7TDMI* cpu, uint16_t opcode);
void run_01000110(ARM7TDMI* cpu, uint16_t opcode) {
    uint8_t rm = get_nth_bits(opcode, 3, 7);
    uint8_t rd = get_nth_bits(opcode, 0, 3) | (get_nth_bit(opcode, 7) << 3);
    cpu->regs[rd] = cpu->regs[rm];

    if (rd == 15) {
        // the least significant bit of pc (cpu->regs[15]) must be clear.
        cpu->regs[rd] &= 0xFFFFFFFE;
    }

    if (rm == 15) {
        cpu->regs[rd] += 2;
    }

    cpu->cycles_remaining += 1;
}

void run_01000111(ARM7TDMI* cpu, uint16_t opcode);
void run_01000111(ARM7TDMI* cpu, uint16_t opcode) {
   uint32_t pointer = cpu->regs[get_nth_bits(opcode, 3, 7)];
   if (get_nth_bits(opcode, 3, 7) == 15) pointer += 2;
   *cpu->pc = pointer & 0xFFFFFFFE; // the PC must be even, so we & with 0xFFFFFFFE.
   cpu->set_bit_T(pointer & 1);

    cpu->cycles_remaining += 3;
}

void run_01001000(ARM7TDMI* cpu, uint16_t opcode);
void run_01001000(ARM7TDMI* cpu, uint16_t opcode) {
    DEBUG_MESSAGE("PC-Relative Load");
    uint8_t reg = get_nth_bits(opcode, 8,  11);
    uint32_t loc = (get_nth_bits(opcode, 0,  8) << 2) + ((*cpu->pc + 2) & 0xFFFFFFFC);
    cpu->regs[reg] = cpu->memory->read_word(loc);

    cpu->cycles_remaining += 5;
}

void run_01001001(ARM7TDMI* cpu, uint16_t opcode);
void run_01001001(ARM7TDMI* cpu, uint16_t opcode) {
    DEBUG_MESSAGE("PC-Relative Load");
    uint8_t reg = get_nth_bits(opcode, 8,  11);
    uint32_t loc = (get_nth_bits(opcode, 0,  8) << 2) + ((*cpu->pc + 2) & 0xFFFFFFFC);
    cpu->regs[reg] = cpu->memory->read_word(loc);

    cpu->cycles_remaining += 5;
}

void run_01001010(ARM7TDMI* cpu, uint16_t opcode);
void run_01001010(ARM7TDMI* cpu, uint16_t opcode) {
    DEBUG_MESSAGE("PC-Relative Load");
    uint8_t reg = get_nth_bits(opcode, 8,  11);
    uint32_t loc = (get_nth_bits(opcode, 0,  8) << 2) + ((*cpu->pc + 2) & 0xFFFFFFFC);
    cpu->regs[reg] = cpu->memory->read_word(loc);

    cpu->cycles_remaining += 5;
}

void run_01001011(ARM7TDMI* cpu, uint16_t opcode);
void run_01001011(ARM7TDMI* cpu, uint16_t opcode) {
    DEBUG_MESSAGE("PC-Relative Load");
    uint8_t reg = get_nth_bits(opcode, 8,  11);
    uint32_t loc = (get_nth_bits(opcode, 0,  8) << 2) + ((*cpu->pc + 2) & 0xFFFFFFFC);
    cpu->regs[reg] = cpu->memory->read_word(loc);

    cpu->cycles_remaining += 5;
}

void run_01001100(ARM7TDMI* cpu, uint16_t opcode);
void run_01001100(ARM7TDMI* cpu, uint16_t opcode) {
    DEBUG_MESSAGE("PC-Relative Load");
    uint8_t reg = get_nth_bits(opcode, 8,  11);
    uint32_t loc = (get_nth_bits(opcode, 0,  8) << 2) + ((*cpu->pc + 2) & 0xFFFFFFFC);
    cpu->regs[reg] = cpu->memory->read_word(loc);

    cpu->cycles_remaining += 5;
}

void run_01001101(ARM7TDMI* cpu, uint16_t opcode);
void run_01001101(ARM7TDMI* cpu, uint16_t opcode) {
    DEBUG_MESSAGE("PC-Relative Load");
    uint8_t reg = get_nth_bits(opcode, 8,  11);
    uint32_t loc = (get_nth_bits(opcode, 0,  8) << 2) + ((*cpu->pc + 2) & 0xFFFFFFFC);
    cpu->regs[reg] = cpu->memory->read_word(loc);

    cpu->cycles_remaining += 5;
}

void run_01001110(ARM7TDMI* cpu, uint16_t opcode);
void run_01001110(ARM7TDMI* cpu, uint16_t opcode) {
    DEBUG_MESSAGE("PC-Relative Load");
    uint8_t reg = get_nth_bits(opcode, 8,  11);
    uint32_t loc = (get_nth_bits(opcode, 0,  8) << 2) + ((*cpu->pc + 2) & 0xFFFFFFFC);
    cpu->regs[reg] = cpu->memory->read_word(loc);

    cpu->cycles_remaining += 5;
}

void run_01001111(ARM7TDMI* cpu, uint16_t opcode);
void run_01001111(ARM7TDMI* cpu, uint16_t opcode) {
    DEBUG_MESSAGE("PC-Relative Load");
    uint8_t reg = get_nth_bits(opcode, 8,  11);
    uint32_t loc = (get_nth_bits(opcode, 0,  8) << 2) + ((*cpu->pc + 2) & 0xFFFFFFFC);
    cpu->regs[reg] = cpu->memory->read_word(loc);

    cpu->cycles_remaining += 5;
}

void run_01010000(ARM7TDMI* cpu, uint16_t opcode);
void run_01010000(ARM7TDMI* cpu, uint16_t opcode) {
    // 10-: STRB #2 rn + rm (store 1 byte)
    // 01-: STRH #2 rn + rm (store 2 bytes)
    // 00-: STR  #2 rn + rm (store 4 bytes)
    uint8_t rm = get_nth_bits(opcode, 6, 9);
    uint8_t rn = get_nth_bits(opcode, 3, 6);
    uint8_t rd = get_nth_bits(opcode, 0, 3);

    uint32_t value = cpu->regs[rd];

    cpu->memory->write_word    (cpu->regs[rm] + cpu->regs[rn], value);

    cpu->cycles_remaining += 2;
}

void run_01010001(ARM7TDMI* cpu, uint16_t opcode);
void run_01010001(ARM7TDMI* cpu, uint16_t opcode) {
    // 10-: STRB #2 rn + rm (store 1 byte)
    // 01-: STRH #2 rn + rm (store 2 bytes)
    // 00-: STR  #2 rn + rm (store 4 bytes)
    uint8_t rm = get_nth_bits(opcode, 6, 9);
    uint8_t rn = get_nth_bits(opcode, 3, 6);
    uint8_t rd = get_nth_bits(opcode, 0, 3);

    uint32_t value = cpu->regs[rd];

    cpu->memory->write_word    (cpu->regs[rm] + cpu->regs[rn], value);

    cpu->cycles_remaining += 2;
}

void run_01010010(ARM7TDMI* cpu, uint16_t opcode);
void run_01010010(ARM7TDMI* cpu, uint16_t opcode) {
    // 10-: STRB #2 rn + rm (store 1 byte)
    // 01-: STRH #2 rn + rm (store 2 bytes)
    // 00-: STR  #2 rn + rm (store 4 bytes)
    uint8_t rm = get_nth_bits(opcode, 6, 9);
    uint8_t rn = get_nth_bits(opcode, 3, 6);
    uint8_t rd = get_nth_bits(opcode, 0, 3);

    uint32_t value = cpu->regs[rd] & 0xFFFF;

    cpu->memory->write_halfword(cpu->regs[rm] + cpu->regs[rn], value);

    cpu->cycles_remaining += 2;
}

void run_01010011(ARM7TDMI* cpu, uint16_t opcode);
void run_01010011(ARM7TDMI* cpu, uint16_t opcode) {
    // 10-: STRB #2 rn + rm (store 1 byte)
    // 01-: STRH #2 rn + rm (store 2 bytes)
    // 00-: STR  #2 rn + rm (store 4 bytes)
    uint8_t rm = get_nth_bits(opcode, 6, 9);
    uint8_t rn = get_nth_bits(opcode, 3, 6);
    uint8_t rd = get_nth_bits(opcode, 0, 3);

    uint32_t value = cpu->regs[rd] & 0xFFFF;

    cpu->memory->write_halfword(cpu->regs[rm] + cpu->regs[rn], value);

    cpu->cycles_remaining += 2;
}

void run_01010100(ARM7TDMI* cpu, uint16_t opcode);
void run_01010100(ARM7TDMI* cpu, uint16_t opcode) {
    // 10-: STRB #2 rn + rm (store 1 byte)
    // 01-: STRH #2 rn + rm (store 2 bytes)
    // 00-: STR  #2 rn + rm (store 4 bytes)
    uint8_t rm = get_nth_bits(opcode, 6, 9);
    uint8_t rn = get_nth_bits(opcode, 3, 6);
    uint8_t rd = get_nth_bits(opcode, 0, 3);

    uint32_t value = cpu->regs[rd] & 0xFF;

    cpu->memory->write_byte    (cpu->regs[rm] + cpu->regs[rn], value);

    cpu->cycles_remaining += 2;
}

void run_01010101(ARM7TDMI* cpu, uint16_t opcode);
void run_01010101(ARM7TDMI* cpu, uint16_t opcode) {
    // 10-: STRB #2 rn + rm (store 1 byte)
    // 01-: STRH #2 rn + rm (store 2 bytes)
    // 00-: STR  #2 rn + rm (store 4 bytes)
    uint8_t rm = get_nth_bits(opcode, 6, 9);
    uint8_t rn = get_nth_bits(opcode, 3, 6);
    uint8_t rd = get_nth_bits(opcode, 0, 3);

    uint32_t value = cpu->regs[rd] & 0xFF;

    cpu->memory->write_byte    (cpu->regs[rm] + cpu->regs[rn], value);

    cpu->cycles_remaining += 2;
}

void run_01010110(ARM7TDMI* cpu, uint16_t opcode);
void run_01010110(ARM7TDMI* cpu, uint16_t opcode) {
    // 111-: LDRSH  rn + rm (load 2 bytes), sign extend
    // 110-: LDRB#2 rn + rm (load 1 byte)
    // 101-: LDRH#2 rn + rm (load 2 bytes) 
    // 100-: LDR #2 rn + rm (load 4 bytes)
    // 011-: LDRSB  rn + rm (load 1 byte),  sign extend
    uint8_t rm = get_nth_bits(opcode, 6, 9);
    uint8_t rn = get_nth_bits(opcode, 3, 6);
    uint8_t rd = get_nth_bits(opcode, 0, 3);
    int32_t  value = (uint32_t) sign_extend(cpu->memory->read_byte    (cpu->regs[rm] + cpu->regs[rn]), 8);

    cpu->regs[rd] = value;

    cpu->cycles_remaining += 3;
}

void run_01010111(ARM7TDMI* cpu, uint16_t opcode);
void run_01010111(ARM7TDMI* cpu, uint16_t opcode) {
    // 111-: LDRSH  rn + rm (load 2 bytes), sign extend
    // 110-: LDRB#2 rn + rm (load 1 byte)
    // 101-: LDRH#2 rn + rm (load 2 bytes) 
    // 100-: LDR #2 rn + rm (load 4 bytes)
    // 011-: LDRSB  rn + rm (load 1 byte),  sign extend
    uint8_t rm = get_nth_bits(opcode, 6, 9);
    uint8_t rn = get_nth_bits(opcode, 3, 6);
    uint8_t rd = get_nth_bits(opcode, 0, 3);
    int32_t  value = (uint32_t) sign_extend(cpu->memory->read_byte    (cpu->regs[rm] + cpu->regs[rn]), 8);

    cpu->regs[rd] = value;

    cpu->cycles_remaining += 3;
}

void run_01011000(ARM7TDMI* cpu, uint16_t opcode);
void run_01011000(ARM7TDMI* cpu, uint16_t opcode) {
    // 111-: LDRSH  rn + rm (load 2 bytes), sign extend
    // 110-: LDRB#2 rn + rm (load 1 byte)
    // 101-: LDRH#2 rn + rm (load 2 bytes) 
    // 100-: LDR #2 rn + rm (load 4 bytes)
    // 011-: LDRSB  rn + rm (load 1 byte),  sign extend
    uint8_t rm = get_nth_bits(opcode, 6, 9);
    uint8_t rn = get_nth_bits(opcode, 3, 6);
    uint8_t rd = get_nth_bits(opcode, 0, 3);
    uint32_t value = (uint32_t)            (cpu->memory->read_word    (cpu->regs[rm] + cpu->regs[rn]));

    cpu->regs[rd] = value;

    cpu->cycles_remaining += 3;
}

void run_01011001(ARM7TDMI* cpu, uint16_t opcode);
void run_01011001(ARM7TDMI* cpu, uint16_t opcode) {
    // 111-: LDRSH  rn + rm (load 2 bytes), sign extend
    // 110-: LDRB#2 rn + rm (load 1 byte)
    // 101-: LDRH#2 rn + rm (load 2 bytes) 
    // 100-: LDR #2 rn + rm (load 4 bytes)
    // 011-: LDRSB  rn + rm (load 1 byte),  sign extend
    uint8_t rm = get_nth_bits(opcode, 6, 9);
    uint8_t rn = get_nth_bits(opcode, 3, 6);
    uint8_t rd = get_nth_bits(opcode, 0, 3);
    uint32_t value = (uint32_t)            (cpu->memory->read_word    (cpu->regs[rm] + cpu->regs[rn]));

    cpu->regs[rd] = value;

    cpu->cycles_remaining += 3;
}

void run_01011010(ARM7TDMI* cpu, uint16_t opcode);
void run_01011010(ARM7TDMI* cpu, uint16_t opcode) {
    // 111-: LDRSH  rn + rm (load 2 bytes), sign extend
    // 110-: LDRB#2 rn + rm (load 1 byte)
    // 101-: LDRH#2 rn + rm (load 2 bytes) 
    // 100-: LDR #2 rn + rm (load 4 bytes)
    // 011-: LDRSB  rn + rm (load 1 byte),  sign extend
    uint8_t rm = get_nth_bits(opcode, 6, 9);
    uint8_t rn = get_nth_bits(opcode, 3, 6);
    uint8_t rd = get_nth_bits(opcode, 0, 3);
    uint32_t value = (uint32_t)            (cpu->memory->read_halfword(cpu->regs[rm] + cpu->regs[rn]));

    cpu->regs[rd] = value;

    cpu->cycles_remaining += 3;
}

void run_01011011(ARM7TDMI* cpu, uint16_t opcode);
void run_01011011(ARM7TDMI* cpu, uint16_t opcode) {
    // 111-: LDRSH  rn + rm (load 2 bytes), sign extend
    // 110-: LDRB#2 rn + rm (load 1 byte)
    // 101-: LDRH#2 rn + rm (load 2 bytes) 
    // 100-: LDR #2 rn + rm (load 4 bytes)
    // 011-: LDRSB  rn + rm (load 1 byte),  sign extend
    uint8_t rm = get_nth_bits(opcode, 6, 9);
    uint8_t rn = get_nth_bits(opcode, 3, 6);
    uint8_t rd = get_nth_bits(opcode, 0, 3);
    uint32_t value = (uint32_t)            (cpu->memory->read_halfword(cpu->regs[rm] + cpu->regs[rn]));

    cpu->regs[rd] = value;

    cpu->cycles_remaining += 3;
}

void run_01011100(ARM7TDMI* cpu, uint16_t opcode);
void run_01011100(ARM7TDMI* cpu, uint16_t opcode) {
    // 111-: LDRSH  rn + rm (load 2 bytes), sign extend
    // 110-: LDRB#2 rn + rm (load 1 byte)
    // 101-: LDRH#2 rn + rm (load 2 bytes) 
    // 100-: LDR #2 rn + rm (load 4 bytes)
    // 011-: LDRSB  rn + rm (load 1 byte),  sign extend
    uint8_t rm = get_nth_bits(opcode, 6, 9);
    uint8_t rn = get_nth_bits(opcode, 3, 6);
    uint8_t rd = get_nth_bits(opcode, 0, 3);
    uint32_t value = (uint32_t)            (cpu->memory->read_byte    (cpu->regs[rm] + cpu->regs[rn]));

    cpu->regs[rd] = value;

    cpu->cycles_remaining += 3;
}

void run_01011101(ARM7TDMI* cpu, uint16_t opcode);
void run_01011101(ARM7TDMI* cpu, uint16_t opcode) {
    // 111-: LDRSH  rn + rm (load 2 bytes), sign extend
    // 110-: LDRB#2 rn + rm (load 1 byte)
    // 101-: LDRH#2 rn + rm (load 2 bytes) 
    // 100-: LDR #2 rn + rm (load 4 bytes)
    // 011-: LDRSB  rn + rm (load 1 byte),  sign extend
    uint8_t rm = get_nth_bits(opcode, 6, 9);
    uint8_t rn = get_nth_bits(opcode, 3, 6);
    uint8_t rd = get_nth_bits(opcode, 0, 3);
    uint32_t value = (uint32_t)            (cpu->memory->read_byte    (cpu->regs[rm] + cpu->regs[rn]));

    cpu->regs[rd] = value;

    cpu->cycles_remaining += 3;
}

void run_01011110(ARM7TDMI* cpu, uint16_t opcode);
void run_01011110(ARM7TDMI* cpu, uint16_t opcode) {
    // 111-: LDRSH  rn + rm (load 2 bytes), sign extend
    // 110-: LDRB#2 rn + rm (load 1 byte)
    // 101-: LDRH#2 rn + rm (load 2 bytes) 
    // 100-: LDR #2 rn + rm (load 4 bytes)
    // 011-: LDRSB  rn + rm (load 1 byte),  sign extend
    uint8_t rm = get_nth_bits(opcode, 6, 9);
    uint8_t rn = get_nth_bits(opcode, 3, 6);
    uint8_t rd = get_nth_bits(opcode, 0, 3);
    int32_t  value = (uint32_t) sign_extend(cpu->memory->read_halfword(cpu->regs[rm] + cpu->regs[rn]), 16);

    cpu->regs[rd] = value;

    cpu->cycles_remaining += 3;
}

void run_01011111(ARM7TDMI* cpu, uint16_t opcode);
void run_01011111(ARM7TDMI* cpu, uint16_t opcode) {
    // 111-: LDRSH  rn + rm (load 2 bytes), sign extend
    // 110-: LDRB#2 rn + rm (load 1 byte)
    // 101-: LDRH#2 rn + rm (load 2 bytes) 
    // 100-: LDR #2 rn + rm (load 4 bytes)
    // 011-: LDRSB  rn + rm (load 1 byte),  sign extend
    uint8_t rm = get_nth_bits(opcode, 6, 9);
    uint8_t rn = get_nth_bits(opcode, 3, 6);
    uint8_t rd = get_nth_bits(opcode, 0, 3);
    int32_t  value = (uint32_t) sign_extend(cpu->memory->read_halfword(cpu->regs[rm] + cpu->regs[rn]), 16);

    cpu->regs[rd] = value;

    cpu->cycles_remaining += 3;
}

void run_01100000(ARM7TDMI* cpu, uint16_t opcode);
void run_01100000(ARM7TDMI* cpu, uint16_t opcode) {
    // BL:
    // 00 - STR  #1 4 bytes (store)
    // 01 - LDR  #1 4 bytes (load)
    // 10 - STRB #1 1 byte  (store)
    // 11 - LDRB #1 1 byte  (load, zero-extend)
    uint8_t rn = get_nth_bits(opcode, 3, 6);
    uint8_t rd = get_nth_bits(opcode, 0, 3);
    uint8_t immediate_value = get_nth_bits(opcode, 6, 11);

    // looking at the table above, the B bit determines the size of the store/load, and the L bit determines whether we store or load.
    cpu->memory->write_word(cpu->regs[rn] + (immediate_value << 2), cpu->regs[rd]);

    cpu->cycles_remaining += 2;
}

void run_01100001(ARM7TDMI* cpu, uint16_t opcode);
void run_01100001(ARM7TDMI* cpu, uint16_t opcode) {
    // BL:
    // 00 - STR  #1 4 bytes (store)
    // 01 - LDR  #1 4 bytes (load)
    // 10 - STRB #1 1 byte  (store)
    // 11 - LDRB #1 1 byte  (load, zero-extend)
    uint8_t rn = get_nth_bits(opcode, 3, 6);
    uint8_t rd = get_nth_bits(opcode, 0, 3);
    uint8_t immediate_value = get_nth_bits(opcode, 6, 11);

    // looking at the table above, the B bit determines the size of the store/load, and the L bit determines whether we store or load.
    cpu->memory->write_word(cpu->regs[rn] + (immediate_value << 2), cpu->regs[rd]);

    cpu->cycles_remaining += 2;
}

void run_01100010(ARM7TDMI* cpu, uint16_t opcode);
void run_01100010(ARM7TDMI* cpu, uint16_t opcode) {
    // BL:
    // 00 - STR  #1 4 bytes (store)
    // 01 - LDR  #1 4 bytes (load)
    // 10 - STRB #1 1 byte  (store)
    // 11 - LDRB #1 1 byte  (load, zero-extend)
    uint8_t rn = get_nth_bits(opcode, 3, 6);
    uint8_t rd = get_nth_bits(opcode, 0, 3);
    uint8_t immediate_value = get_nth_bits(opcode, 6, 11);

    // looking at the table above, the B bit determines the size of the store/load, and the L bit determines whether we store or load.
    cpu->memory->write_word(cpu->regs[rn] + (immediate_value << 2), cpu->regs[rd]);

    cpu->cycles_remaining += 2;
}

void run_01100011(ARM7TDMI* cpu, uint16_t opcode);
void run_01100011(ARM7TDMI* cpu, uint16_t opcode) {
    // BL:
    // 00 - STR  #1 4 bytes (store)
    // 01 - LDR  #1 4 bytes (load)
    // 10 - STRB #1 1 byte  (store)
    // 11 - LDRB #1 1 byte  (load, zero-extend)
    uint8_t rn = get_nth_bits(opcode, 3, 6);
    uint8_t rd = get_nth_bits(opcode, 0, 3);
    uint8_t immediate_value = get_nth_bits(opcode, 6, 11);

    // looking at the table above, the B bit determines the size of the store/load, and the L bit determines whether we store or load.
    cpu->memory->write_word(cpu->regs[rn] + (immediate_value << 2), cpu->regs[rd]);

    cpu->cycles_remaining += 2;
}

void run_01100100(ARM7TDMI* cpu, uint16_t opcode);
void run_01100100(ARM7TDMI* cpu, uint16_t opcode) {
    // BL:
    // 00 - STR  #1 4 bytes (store)
    // 01 - LDR  #1 4 bytes (load)
    // 10 - STRB #1 1 byte  (store)
    // 11 - LDRB #1 1 byte  (load, zero-extend)
    uint8_t rn = get_nth_bits(opcode, 3, 6);
    uint8_t rd = get_nth_bits(opcode, 0, 3);
    uint8_t immediate_value = get_nth_bits(opcode, 6, 11);

    // looking at the table above, the B bit determines the size of the store/load, and the L bit determines whether we store or load.
    cpu->memory->write_word(cpu->regs[rn] + (immediate_value << 2), cpu->regs[rd]);

    cpu->cycles_remaining += 2;
}

void run_01100101(ARM7TDMI* cpu, uint16_t opcode);
void run_01100101(ARM7TDMI* cpu, uint16_t opcode) {
    // BL:
    // 00 - STR  #1 4 bytes (store)
    // 01 - LDR  #1 4 bytes (load)
    // 10 - STRB #1 1 byte  (store)
    // 11 - LDRB #1 1 byte  (load, zero-extend)
    uint8_t rn = get_nth_bits(opcode, 3, 6);
    uint8_t rd = get_nth_bits(opcode, 0, 3);
    uint8_t immediate_value = get_nth_bits(opcode, 6, 11);

    // looking at the table above, the B bit determines the size of the store/load, and the L bit determines whether we store or load.
    cpu->memory->write_word(cpu->regs[rn] + (immediate_value << 2), cpu->regs[rd]);

    cpu->cycles_remaining += 2;
}

void run_01100110(ARM7TDMI* cpu, uint16_t opcode);
void run_01100110(ARM7TDMI* cpu, uint16_t opcode) {
    // BL:
    // 00 - STR  #1 4 bytes (store)
    // 01 - LDR  #1 4 bytes (load)
    // 10 - STRB #1 1 byte  (store)
    // 11 - LDRB #1 1 byte  (load, zero-extend)
    uint8_t rn = get_nth_bits(opcode, 3, 6);
    uint8_t rd = get_nth_bits(opcode, 0, 3);
    uint8_t immediate_value = get_nth_bits(opcode, 6, 11);

    // looking at the table above, the B bit determines the size of the store/load, and the L bit determines whether we store or load.
    cpu->memory->write_word(cpu->regs[rn] + (immediate_value << 2), cpu->regs[rd]);

    cpu->cycles_remaining += 2;
}

void run_01100111(ARM7TDMI* cpu, uint16_t opcode);
void run_01100111(ARM7TDMI* cpu, uint16_t opcode) {
    // BL:
    // 00 - STR  #1 4 bytes (store)
    // 01 - LDR  #1 4 bytes (load)
    // 10 - STRB #1 1 byte  (store)
    // 11 - LDRB #1 1 byte  (load, zero-extend)
    uint8_t rn = get_nth_bits(opcode, 3, 6);
    uint8_t rd = get_nth_bits(opcode, 0, 3);
    uint8_t immediate_value = get_nth_bits(opcode, 6, 11);

    // looking at the table above, the B bit determines the size of the store/load, and the L bit determines whether we store or load.
    cpu->memory->write_word(cpu->regs[rn] + (immediate_value << 2), cpu->regs[rd]);

    cpu->cycles_remaining += 2;
}

void run_01101000(ARM7TDMI* cpu, uint16_t opcode);
void run_01101000(ARM7TDMI* cpu, uint16_t opcode) {
    // BL:
    // 00 - STR  #1 4 bytes (store)
    // 01 - LDR  #1 4 bytes (load)
    // 10 - STRB #1 1 byte  (store)
    // 11 - LDRB #1 1 byte  (load, zero-extend)
    uint8_t rn = get_nth_bits(opcode, 3, 6);
    uint8_t rd = get_nth_bits(opcode, 0, 3);
    uint8_t immediate_value = get_nth_bits(opcode, 6, 11);

    // looking at the table above, the B bit determines the size of the store/load, and the L bit determines whether we store or load.
    cpu->regs[rd] = cpu->memory->read_word(cpu->regs[rn] + (immediate_value << 2));

    cpu->cycles_remaining += 2;
    cpu->cycles_remaining += 1;
}

void run_01101001(ARM7TDMI* cpu, uint16_t opcode);
void run_01101001(ARM7TDMI* cpu, uint16_t opcode) {
    // BL:
    // 00 - STR  #1 4 bytes (store)
    // 01 - LDR  #1 4 bytes (load)
    // 10 - STRB #1 1 byte  (store)
    // 11 - LDRB #1 1 byte  (load, zero-extend)
    uint8_t rn = get_nth_bits(opcode, 3, 6);
    uint8_t rd = get_nth_bits(opcode, 0, 3);
    uint8_t immediate_value = get_nth_bits(opcode, 6, 11);

    // looking at the table above, the B bit determines the size of the store/load, and the L bit determines whether we store or load.
    cpu->regs[rd] = cpu->memory->read_word(cpu->regs[rn] + (immediate_value << 2));

    cpu->cycles_remaining += 2;
    cpu->cycles_remaining += 1;
}

void run_01101010(ARM7TDMI* cpu, uint16_t opcode);
void run_01101010(ARM7TDMI* cpu, uint16_t opcode) {
    // BL:
    // 00 - STR  #1 4 bytes (store)
    // 01 - LDR  #1 4 bytes (load)
    // 10 - STRB #1 1 byte  (store)
    // 11 - LDRB #1 1 byte  (load, zero-extend)
    uint8_t rn = get_nth_bits(opcode, 3, 6);
    uint8_t rd = get_nth_bits(opcode, 0, 3);
    uint8_t immediate_value = get_nth_bits(opcode, 6, 11);

    // looking at the table above, the B bit determines the size of the store/load, and the L bit determines whether we store or load.
    cpu->regs[rd] = cpu->memory->read_word(cpu->regs[rn] + (immediate_value << 2));

    cpu->cycles_remaining += 2;
    cpu->cycles_remaining += 1;
}

void run_01101011(ARM7TDMI* cpu, uint16_t opcode);
void run_01101011(ARM7TDMI* cpu, uint16_t opcode) {
    // BL:
    // 00 - STR  #1 4 bytes (store)
    // 01 - LDR  #1 4 bytes (load)
    // 10 - STRB #1 1 byte  (store)
    // 11 - LDRB #1 1 byte  (load, zero-extend)
    uint8_t rn = get_nth_bits(opcode, 3, 6);
    uint8_t rd = get_nth_bits(opcode, 0, 3);
    uint8_t immediate_value = get_nth_bits(opcode, 6, 11);

    // looking at the table above, the B bit determines the size of the store/load, and the L bit determines whether we store or load.
    cpu->regs[rd] = cpu->memory->read_word(cpu->regs[rn] + (immediate_value << 2));

    cpu->cycles_remaining += 2;
    cpu->cycles_remaining += 1;
}

void run_01101100(ARM7TDMI* cpu, uint16_t opcode);
void run_01101100(ARM7TDMI* cpu, uint16_t opcode) {
    // BL:
    // 00 - STR  #1 4 bytes (store)
    // 01 - LDR  #1 4 bytes (load)
    // 10 - STRB #1 1 byte  (store)
    // 11 - LDRB #1 1 byte  (load, zero-extend)
    uint8_t rn = get_nth_bits(opcode, 3, 6);
    uint8_t rd = get_nth_bits(opcode, 0, 3);
    uint8_t immediate_value = get_nth_bits(opcode, 6, 11);

    // looking at the table above, the B bit determines the size of the store/load, and the L bit determines whether we store or load.
    cpu->regs[rd] = cpu->memory->read_word(cpu->regs[rn] + (immediate_value << 2));

    cpu->cycles_remaining += 2;
    cpu->cycles_remaining += 1;
}

void run_01101101(ARM7TDMI* cpu, uint16_t opcode);
void run_01101101(ARM7TDMI* cpu, uint16_t opcode) {
    // BL:
    // 00 - STR  #1 4 bytes (store)
    // 01 - LDR  #1 4 bytes (load)
    // 10 - STRB #1 1 byte  (store)
    // 11 - LDRB #1 1 byte  (load, zero-extend)
    uint8_t rn = get_nth_bits(opcode, 3, 6);
    uint8_t rd = get_nth_bits(opcode, 0, 3);
    uint8_t immediate_value = get_nth_bits(opcode, 6, 11);

    // looking at the table above, the B bit determines the size of the store/load, and the L bit determines whether we store or load.
    cpu->regs[rd] = cpu->memory->read_word(cpu->regs[rn] + (immediate_value << 2));

    cpu->cycles_remaining += 2;
    cpu->cycles_remaining += 1;
}

void run_01101110(ARM7TDMI* cpu, uint16_t opcode);
void run_01101110(ARM7TDMI* cpu, uint16_t opcode) {
    // BL:
    // 00 - STR  #1 4 bytes (store)
    // 01 - LDR  #1 4 bytes (load)
    // 10 - STRB #1 1 byte  (store)
    // 11 - LDRB #1 1 byte  (load, zero-extend)
    uint8_t rn = get_nth_bits(opcode, 3, 6);
    uint8_t rd = get_nth_bits(opcode, 0, 3);
    uint8_t immediate_value = get_nth_bits(opcode, 6, 11);

    // looking at the table above, the B bit determines the size of the store/load, and the L bit determines whether we store or load.
    cpu->regs[rd] = cpu->memory->read_word(cpu->regs[rn] + (immediate_value << 2));

    cpu->cycles_remaining += 2;
    cpu->cycles_remaining += 1;
}

void run_01101111(ARM7TDMI* cpu, uint16_t opcode);
void run_01101111(ARM7TDMI* cpu, uint16_t opcode) {
    // BL:
    // 00 - STR  #1 4 bytes (store)
    // 01 - LDR  #1 4 bytes (load)
    // 10 - STRB #1 1 byte  (store)
    // 11 - LDRB #1 1 byte  (load, zero-extend)
    uint8_t rn = get_nth_bits(opcode, 3, 6);
    uint8_t rd = get_nth_bits(opcode, 0, 3);
    uint8_t immediate_value = get_nth_bits(opcode, 6, 11);

    // looking at the table above, the B bit determines the size of the store/load, and the L bit determines whether we store or load.
    cpu->regs[rd] = cpu->memory->read_word(cpu->regs[rn] + (immediate_value << 2));

    cpu->cycles_remaining += 2;
    cpu->cycles_remaining += 1;
}

void run_01110000(ARM7TDMI* cpu, uint16_t opcode);
void run_01110000(ARM7TDMI* cpu, uint16_t opcode) {
    // BL:
    // 00 - STR  #1 4 bytes (store)
    // 01 - LDR  #1 4 bytes (load)
    // 10 - STRB #1 1 byte  (store)
    // 11 - LDRB #1 1 byte  (load, zero-extend)
    uint8_t rn = get_nth_bits(opcode, 3, 6);
    uint8_t rd = get_nth_bits(opcode, 0, 3);
    uint8_t immediate_value = get_nth_bits(opcode, 6, 11);

    // looking at the table above, the B bit determines the size of the store/load, and the L bit determines whether we store or load.
    cpu->memory->write_byte(cpu->regs[rn] + (immediate_value), cpu->regs[rd] & 0xFF);

    cpu->cycles_remaining += 2;
}

void run_01110001(ARM7TDMI* cpu, uint16_t opcode);
void run_01110001(ARM7TDMI* cpu, uint16_t opcode) {
    // BL:
    // 00 - STR  #1 4 bytes (store)
    // 01 - LDR  #1 4 bytes (load)
    // 10 - STRB #1 1 byte  (store)
    // 11 - LDRB #1 1 byte  (load, zero-extend)
    uint8_t rn = get_nth_bits(opcode, 3, 6);
    uint8_t rd = get_nth_bits(opcode, 0, 3);
    uint8_t immediate_value = get_nth_bits(opcode, 6, 11);

    // looking at the table above, the B bit determines the size of the store/load, and the L bit determines whether we store or load.
    cpu->memory->write_byte(cpu->regs[rn] + (immediate_value), cpu->regs[rd] & 0xFF);

    cpu->cycles_remaining += 2;
}

void run_01110010(ARM7TDMI* cpu, uint16_t opcode);
void run_01110010(ARM7TDMI* cpu, uint16_t opcode) {
    // BL:
    // 00 - STR  #1 4 bytes (store)
    // 01 - LDR  #1 4 bytes (load)
    // 10 - STRB #1 1 byte  (store)
    // 11 - LDRB #1 1 byte  (load, zero-extend)
    uint8_t rn = get_nth_bits(opcode, 3, 6);
    uint8_t rd = get_nth_bits(opcode, 0, 3);
    uint8_t immediate_value = get_nth_bits(opcode, 6, 11);

    // looking at the table above, the B bit determines the size of the store/load, and the L bit determines whether we store or load.
    cpu->memory->write_byte(cpu->regs[rn] + (immediate_value), cpu->regs[rd] & 0xFF);

    cpu->cycles_remaining += 2;
}

void run_01110011(ARM7TDMI* cpu, uint16_t opcode);
void run_01110011(ARM7TDMI* cpu, uint16_t opcode) {
    // BL:
    // 00 - STR  #1 4 bytes (store)
    // 01 - LDR  #1 4 bytes (load)
    // 10 - STRB #1 1 byte  (store)
    // 11 - LDRB #1 1 byte  (load, zero-extend)
    uint8_t rn = get_nth_bits(opcode, 3, 6);
    uint8_t rd = get_nth_bits(opcode, 0, 3);
    uint8_t immediate_value = get_nth_bits(opcode, 6, 11);

    // looking at the table above, the B bit determines the size of the store/load, and the L bit determines whether we store or load.
    cpu->memory->write_byte(cpu->regs[rn] + (immediate_value), cpu->regs[rd] & 0xFF);

    cpu->cycles_remaining += 2;
}

void run_01110100(ARM7TDMI* cpu, uint16_t opcode);
void run_01110100(ARM7TDMI* cpu, uint16_t opcode) {
    // BL:
    // 00 - STR  #1 4 bytes (store)
    // 01 - LDR  #1 4 bytes (load)
    // 10 - STRB #1 1 byte  (store)
    // 11 - LDRB #1 1 byte  (load, zero-extend)
    uint8_t rn = get_nth_bits(opcode, 3, 6);
    uint8_t rd = get_nth_bits(opcode, 0, 3);
    uint8_t immediate_value = get_nth_bits(opcode, 6, 11);

    // looking at the table above, the B bit determines the size of the store/load, and the L bit determines whether we store or load.
    cpu->memory->write_byte(cpu->regs[rn] + (immediate_value), cpu->regs[rd] & 0xFF);

    cpu->cycles_remaining += 2;
}

void run_01110101(ARM7TDMI* cpu, uint16_t opcode);
void run_01110101(ARM7TDMI* cpu, uint16_t opcode) {
    // BL:
    // 00 - STR  #1 4 bytes (store)
    // 01 - LDR  #1 4 bytes (load)
    // 10 - STRB #1 1 byte  (store)
    // 11 - LDRB #1 1 byte  (load, zero-extend)
    uint8_t rn = get_nth_bits(opcode, 3, 6);
    uint8_t rd = get_nth_bits(opcode, 0, 3);
    uint8_t immediate_value = get_nth_bits(opcode, 6, 11);

    // looking at the table above, the B bit determines the size of the store/load, and the L bit determines whether we store or load.
    cpu->memory->write_byte(cpu->regs[rn] + (immediate_value), cpu->regs[rd] & 0xFF);

    cpu->cycles_remaining += 2;
}

void run_01110110(ARM7TDMI* cpu, uint16_t opcode);
void run_01110110(ARM7TDMI* cpu, uint16_t opcode) {
    // BL:
    // 00 - STR  #1 4 bytes (store)
    // 01 - LDR  #1 4 bytes (load)
    // 10 - STRB #1 1 byte  (store)
    // 11 - LDRB #1 1 byte  (load, zero-extend)
    uint8_t rn = get_nth_bits(opcode, 3, 6);
    uint8_t rd = get_nth_bits(opcode, 0, 3);
    uint8_t immediate_value = get_nth_bits(opcode, 6, 11);

    // looking at the table above, the B bit determines the size of the store/load, and the L bit determines whether we store or load.
    cpu->memory->write_byte(cpu->regs[rn] + (immediate_value), cpu->regs[rd] & 0xFF);

    cpu->cycles_remaining += 2;
}

void run_01110111(ARM7TDMI* cpu, uint16_t opcode);
void run_01110111(ARM7TDMI* cpu, uint16_t opcode) {
    // BL:
    // 00 - STR  #1 4 bytes (store)
    // 01 - LDR  #1 4 bytes (load)
    // 10 - STRB #1 1 byte  (store)
    // 11 - LDRB #1 1 byte  (load, zero-extend)
    uint8_t rn = get_nth_bits(opcode, 3, 6);
    uint8_t rd = get_nth_bits(opcode, 0, 3);
    uint8_t immediate_value = get_nth_bits(opcode, 6, 11);

    // looking at the table above, the B bit determines the size of the store/load, and the L bit determines whether we store or load.
    cpu->memory->write_byte(cpu->regs[rn] + (immediate_value), cpu->regs[rd] & 0xFF);

    cpu->cycles_remaining += 2;
}

void run_01111000(ARM7TDMI* cpu, uint16_t opcode);
void run_01111000(ARM7TDMI* cpu, uint16_t opcode) {
    // BL:
    // 00 - STR  #1 4 bytes (store)
    // 01 - LDR  #1 4 bytes (load)
    // 10 - STRB #1 1 byte  (store)
    // 11 - LDRB #1 1 byte  (load, zero-extend)
    uint8_t rn = get_nth_bits(opcode, 3, 6);
    uint8_t rd = get_nth_bits(opcode, 0, 3);
    uint8_t immediate_value = get_nth_bits(opcode, 6, 11);

    // looking at the table above, the B bit determines the size of the store/load, and the L bit determines whether we store or load.
    cpu->regs[rd] = cpu->memory->read_byte(cpu->regs[rn] + immediate_value);

    cpu->cycles_remaining += 2;
    cpu->cycles_remaining += 1;
}

void run_01111001(ARM7TDMI* cpu, uint16_t opcode);
void run_01111001(ARM7TDMI* cpu, uint16_t opcode) {
    // BL:
    // 00 - STR  #1 4 bytes (store)
    // 01 - LDR  #1 4 bytes (load)
    // 10 - STRB #1 1 byte  (store)
    // 11 - LDRB #1 1 byte  (load, zero-extend)
    uint8_t rn = get_nth_bits(opcode, 3, 6);
    uint8_t rd = get_nth_bits(opcode, 0, 3);
    uint8_t immediate_value = get_nth_bits(opcode, 6, 11);

    // looking at the table above, the B bit determines the size of the store/load, and the L bit determines whether we store or load.
    cpu->regs[rd] = cpu->memory->read_byte(cpu->regs[rn] + immediate_value);

    cpu->cycles_remaining += 2;
    cpu->cycles_remaining += 1;
}

void run_01111010(ARM7TDMI* cpu, uint16_t opcode);
void run_01111010(ARM7TDMI* cpu, uint16_t opcode) {
    // BL:
    // 00 - STR  #1 4 bytes (store)
    // 01 - LDR  #1 4 bytes (load)
    // 10 - STRB #1 1 byte  (store)
    // 11 - LDRB #1 1 byte  (load, zero-extend)
    uint8_t rn = get_nth_bits(opcode, 3, 6);
    uint8_t rd = get_nth_bits(opcode, 0, 3);
    uint8_t immediate_value = get_nth_bits(opcode, 6, 11);

    // looking at the table above, the B bit determines the size of the store/load, and the L bit determines whether we store or load.
    cpu->regs[rd] = cpu->memory->read_byte(cpu->regs[rn] + immediate_value);

    cpu->cycles_remaining += 2;
    cpu->cycles_remaining += 1;
}

void run_01111011(ARM7TDMI* cpu, uint16_t opcode);
void run_01111011(ARM7TDMI* cpu, uint16_t opcode) {
    // BL:
    // 00 - STR  #1 4 bytes (store)
    // 01 - LDR  #1 4 bytes (load)
    // 10 - STRB #1 1 byte  (store)
    // 11 - LDRB #1 1 byte  (load, zero-extend)
    uint8_t rn = get_nth_bits(opcode, 3, 6);
    uint8_t rd = get_nth_bits(opcode, 0, 3);
    uint8_t immediate_value = get_nth_bits(opcode, 6, 11);

    // looking at the table above, the B bit determines the size of the store/load, and the L bit determines whether we store or load.
    cpu->regs[rd] = cpu->memory->read_byte(cpu->regs[rn] + immediate_value);

    cpu->cycles_remaining += 2;
    cpu->cycles_remaining += 1;
}

void run_01111100(ARM7TDMI* cpu, uint16_t opcode);
void run_01111100(ARM7TDMI* cpu, uint16_t opcode) {
    // BL:
    // 00 - STR  #1 4 bytes (store)
    // 01 - LDR  #1 4 bytes (load)
    // 10 - STRB #1 1 byte  (store)
    // 11 - LDRB #1 1 byte  (load, zero-extend)
    uint8_t rn = get_nth_bits(opcode, 3, 6);
    uint8_t rd = get_nth_bits(opcode, 0, 3);
    uint8_t immediate_value = get_nth_bits(opcode, 6, 11);

    // looking at the table above, the B bit determines the size of the store/load, and the L bit determines whether we store or load.
    cpu->regs[rd] = cpu->memory->read_byte(cpu->regs[rn] + immediate_value);

    cpu->cycles_remaining += 2;
    cpu->cycles_remaining += 1;
}

void run_01111101(ARM7TDMI* cpu, uint16_t opcode);
void run_01111101(ARM7TDMI* cpu, uint16_t opcode) {
    // BL:
    // 00 - STR  #1 4 bytes (store)
    // 01 - LDR  #1 4 bytes (load)
    // 10 - STRB #1 1 byte  (store)
    // 11 - LDRB #1 1 byte  (load, zero-extend)
    uint8_t rn = get_nth_bits(opcode, 3, 6);
    uint8_t rd = get_nth_bits(opcode, 0, 3);
    uint8_t immediate_value = get_nth_bits(opcode, 6, 11);

    // looking at the table above, the B bit determines the size of the store/load, and the L bit determines whether we store or load.
    cpu->regs[rd] = cpu->memory->read_byte(cpu->regs[rn] + immediate_value);

    cpu->cycles_remaining += 2;
    cpu->cycles_remaining += 1;
}

void run_01111110(ARM7TDMI* cpu, uint16_t opcode);
void run_01111110(ARM7TDMI* cpu, uint16_t opcode) {
    // BL:
    // 00 - STR  #1 4 bytes (store)
    // 01 - LDR  #1 4 bytes (load)
    // 10 - STRB #1 1 byte  (store)
    // 11 - LDRB #1 1 byte  (load, zero-extend)
    uint8_t rn = get_nth_bits(opcode, 3, 6);
    uint8_t rd = get_nth_bits(opcode, 0, 3);
    uint8_t immediate_value = get_nth_bits(opcode, 6, 11);

    // looking at the table above, the B bit determines the size of the store/load, and the L bit determines whether we store or load.
    cpu->regs[rd] = cpu->memory->read_byte(cpu->regs[rn] + immediate_value);

    cpu->cycles_remaining += 2;
    cpu->cycles_remaining += 1;
}

void run_01111111(ARM7TDMI* cpu, uint16_t opcode);
void run_01111111(ARM7TDMI* cpu, uint16_t opcode) {
    // BL:
    // 00 - STR  #1 4 bytes (store)
    // 01 - LDR  #1 4 bytes (load)
    // 10 - STRB #1 1 byte  (store)
    // 11 - LDRB #1 1 byte  (load, zero-extend)
    uint8_t rn = get_nth_bits(opcode, 3, 6);
    uint8_t rd = get_nth_bits(opcode, 0, 3);
    uint8_t immediate_value = get_nth_bits(opcode, 6, 11);

    // looking at the table above, the B bit determines the size of the store/load, and the L bit determines whether we store or load.
    cpu->regs[rd] = cpu->memory->read_byte(cpu->regs[rn] + immediate_value);

    cpu->cycles_remaining += 2;
    cpu->cycles_remaining += 1;
}

void run_10000000(ARM7TDMI* cpu, uint16_t opcode);
void run_10000000(ARM7TDMI* cpu, uint16_t opcode) {
    uint8_t rn     = get_nth_bits(opcode, 3, 6);
    uint8_t rd     = get_nth_bits(opcode, 0, 3);
    uint8_t offset = get_nth_bits(opcode, 6, 11);
    
    cpu->memory->write_halfword(cpu->regs[rn] + (offset << 1), cpu->regs[rd]);

    cpu->cycles_remaining += 2;
}

void run_10000001(ARM7TDMI* cpu, uint16_t opcode);
void run_10000001(ARM7TDMI* cpu, uint16_t opcode) {
    uint8_t rn     = get_nth_bits(opcode, 3, 6);
    uint8_t rd     = get_nth_bits(opcode, 0, 3);
    uint8_t offset = get_nth_bits(opcode, 6, 11);
    
    cpu->memory->write_halfword(cpu->regs[rn] + (offset << 1), cpu->regs[rd]);

    cpu->cycles_remaining += 2;
}

void run_10000010(ARM7TDMI* cpu, uint16_t opcode);
void run_10000010(ARM7TDMI* cpu, uint16_t opcode) {
    uint8_t rn     = get_nth_bits(opcode, 3, 6);
    uint8_t rd     = get_nth_bits(opcode, 0, 3);
    uint8_t offset = get_nth_bits(opcode, 6, 11);
    
    cpu->memory->write_halfword(cpu->regs[rn] + (offset << 1), cpu->regs[rd]);

    cpu->cycles_remaining += 2;
}

void run_10000011(ARM7TDMI* cpu, uint16_t opcode);
void run_10000011(ARM7TDMI* cpu, uint16_t opcode) {
    uint8_t rn     = get_nth_bits(opcode, 3, 6);
    uint8_t rd     = get_nth_bits(opcode, 0, 3);
    uint8_t offset = get_nth_bits(opcode, 6, 11);
    
    cpu->memory->write_halfword(cpu->regs[rn] + (offset << 1), cpu->regs[rd]);

    cpu->cycles_remaining += 2;
}

void run_10000100(ARM7TDMI* cpu, uint16_t opcode);
void run_10000100(ARM7TDMI* cpu, uint16_t opcode) {
    uint8_t rn     = get_nth_bits(opcode, 3, 6);
    uint8_t rd     = get_nth_bits(opcode, 0, 3);
    uint8_t offset = get_nth_bits(opcode, 6, 11);
    
    cpu->memory->write_halfword(cpu->regs[rn] + (offset << 1), cpu->regs[rd]);

    cpu->cycles_remaining += 2;
}

void run_10000101(ARM7TDMI* cpu, uint16_t opcode);
void run_10000101(ARM7TDMI* cpu, uint16_t opcode) {
    uint8_t rn     = get_nth_bits(opcode, 3, 6);
    uint8_t rd     = get_nth_bits(opcode, 0, 3);
    uint8_t offset = get_nth_bits(opcode, 6, 11);
    
    cpu->memory->write_halfword(cpu->regs[rn] + (offset << 1), cpu->regs[rd]);

    cpu->cycles_remaining += 2;
}

void run_10000110(ARM7TDMI* cpu, uint16_t opcode);
void run_10000110(ARM7TDMI* cpu, uint16_t opcode) {
    uint8_t rn     = get_nth_bits(opcode, 3, 6);
    uint8_t rd     = get_nth_bits(opcode, 0, 3);
    uint8_t offset = get_nth_bits(opcode, 6, 11);
    
    cpu->memory->write_halfword(cpu->regs[rn] + (offset << 1), cpu->regs[rd]);

    cpu->cycles_remaining += 2;
}

void run_10000111(ARM7TDMI* cpu, uint16_t opcode);
void run_10000111(ARM7TDMI* cpu, uint16_t opcode) {
    uint8_t rn     = get_nth_bits(opcode, 3, 6);
    uint8_t rd     = get_nth_bits(opcode, 0, 3);
    uint8_t offset = get_nth_bits(opcode, 6, 11);
    
    cpu->memory->write_halfword(cpu->regs[rn] + (offset << 1), cpu->regs[rd]);

    cpu->cycles_remaining += 2;
}

void run_10001000(ARM7TDMI* cpu, uint16_t opcode);
void run_10001000(ARM7TDMI* cpu, uint16_t opcode) {
    uint8_t rn     = get_nth_bits(opcode, 3, 6);
    uint8_t rd     = get_nth_bits(opcode, 0, 3);
    uint8_t offset = get_nth_bits(opcode, 6, 11);
    
    cpu->regs[rd] = cpu->memory->read_halfword(cpu->regs[rn] + offset * 2);

    cpu->cycles_remaining += 3;
}

void run_10001001(ARM7TDMI* cpu, uint16_t opcode);
void run_10001001(ARM7TDMI* cpu, uint16_t opcode) {
    uint8_t rn     = get_nth_bits(opcode, 3, 6);
    uint8_t rd     = get_nth_bits(opcode, 0, 3);
    uint8_t offset = get_nth_bits(opcode, 6, 11);
    
    cpu->regs[rd] = cpu->memory->read_halfword(cpu->regs[rn] + offset * 2);

    cpu->cycles_remaining += 3;
}

void run_10001010(ARM7TDMI* cpu, uint16_t opcode);
void run_10001010(ARM7TDMI* cpu, uint16_t opcode) {
    uint8_t rn     = get_nth_bits(opcode, 3, 6);
    uint8_t rd     = get_nth_bits(opcode, 0, 3);
    uint8_t offset = get_nth_bits(opcode, 6, 11);
    
    cpu->regs[rd] = cpu->memory->read_halfword(cpu->regs[rn] + offset * 2);

    cpu->cycles_remaining += 3;
}

void run_10001011(ARM7TDMI* cpu, uint16_t opcode);
void run_10001011(ARM7TDMI* cpu, uint16_t opcode) {
    uint8_t rn     = get_nth_bits(opcode, 3, 6);
    uint8_t rd     = get_nth_bits(opcode, 0, 3);
    uint8_t offset = get_nth_bits(opcode, 6, 11);
    
    cpu->regs[rd] = cpu->memory->read_halfword(cpu->regs[rn] + offset * 2);

    cpu->cycles_remaining += 3;
}

void run_10001100(ARM7TDMI* cpu, uint16_t opcode);
void run_10001100(ARM7TDMI* cpu, uint16_t opcode) {
    uint8_t rn     = get_nth_bits(opcode, 3, 6);
    uint8_t rd     = get_nth_bits(opcode, 0, 3);
    uint8_t offset = get_nth_bits(opcode, 6, 11);
    
    cpu->regs[rd] = cpu->memory->read_halfword(cpu->regs[rn] + offset * 2);

    cpu->cycles_remaining += 3;
}

void run_10001101(ARM7TDMI* cpu, uint16_t opcode);
void run_10001101(ARM7TDMI* cpu, uint16_t opcode) {
    uint8_t rn     = get_nth_bits(opcode, 3, 6);
    uint8_t rd     = get_nth_bits(opcode, 0, 3);
    uint8_t offset = get_nth_bits(opcode, 6, 11);
    
    cpu->regs[rd] = cpu->memory->read_halfword(cpu->regs[rn] + offset * 2);

    cpu->cycles_remaining += 3;
}

void run_10001110(ARM7TDMI* cpu, uint16_t opcode);
void run_10001110(ARM7TDMI* cpu, uint16_t opcode) {
    uint8_t rn     = get_nth_bits(opcode, 3, 6);
    uint8_t rd     = get_nth_bits(opcode, 0, 3);
    uint8_t offset = get_nth_bits(opcode, 6, 11);
    
    cpu->regs[rd] = cpu->memory->read_halfword(cpu->regs[rn] + offset * 2);

    cpu->cycles_remaining += 3;
}

void run_10001111(ARM7TDMI* cpu, uint16_t opcode);
void run_10001111(ARM7TDMI* cpu, uint16_t opcode) {
    uint8_t rn     = get_nth_bits(opcode, 3, 6);
    uint8_t rd     = get_nth_bits(opcode, 0, 3);
    uint8_t offset = get_nth_bits(opcode, 6, 11);
    
    cpu->regs[rd] = cpu->memory->read_halfword(cpu->regs[rn] + offset * 2);

    cpu->cycles_remaining += 3;
}

void run_10010000(ARM7TDMI* cpu, uint16_t opcode);
void run_10010000(ARM7TDMI* cpu, uint16_t opcode) {
    uint8_t rd = get_nth_bits(opcode, 8, 11);
    uint8_t immediate_value = opcode & 0xFF;

    // if L is set, we load. if L is not set, we store.
    cpu->memory->write_word(*cpu->sp + (immediate_value << 2), cpu->regs[rd]);

    cpu->cycles_remaining += 2;
}

void run_10010001(ARM7TDMI* cpu, uint16_t opcode);
void run_10010001(ARM7TDMI* cpu, uint16_t opcode) {
    uint8_t rd = get_nth_bits(opcode, 8, 11);
    uint8_t immediate_value = opcode & 0xFF;

    // if L is set, we load. if L is not set, we store.
    cpu->memory->write_word(*cpu->sp + (immediate_value << 2), cpu->regs[rd]);

    cpu->cycles_remaining += 2;
}

void run_10010010(ARM7TDMI* cpu, uint16_t opcode);
void run_10010010(ARM7TDMI* cpu, uint16_t opcode) {
    uint8_t rd = get_nth_bits(opcode, 8, 11);
    uint8_t immediate_value = opcode & 0xFF;

    // if L is set, we load. if L is not set, we store.
    cpu->memory->write_word(*cpu->sp + (immediate_value << 2), cpu->regs[rd]);

    cpu->cycles_remaining += 2;
}

void run_10010011(ARM7TDMI* cpu, uint16_t opcode);
void run_10010011(ARM7TDMI* cpu, uint16_t opcode) {
    uint8_t rd = get_nth_bits(opcode, 8, 11);
    uint8_t immediate_value = opcode & 0xFF;

    // if L is set, we load. if L is not set, we store.
    cpu->memory->write_word(*cpu->sp + (immediate_value << 2), cpu->regs[rd]);

    cpu->cycles_remaining += 2;
}

void run_10010100(ARM7TDMI* cpu, uint16_t opcode);
void run_10010100(ARM7TDMI* cpu, uint16_t opcode) {
    uint8_t rd = get_nth_bits(opcode, 8, 11);
    uint8_t immediate_value = opcode & 0xFF;

    // if L is set, we load. if L is not set, we store.
    cpu->memory->write_word(*cpu->sp + (immediate_value << 2), cpu->regs[rd]);

    cpu->cycles_remaining += 2;
}

void run_10010101(ARM7TDMI* cpu, uint16_t opcode);
void run_10010101(ARM7TDMI* cpu, uint16_t opcode) {
    uint8_t rd = get_nth_bits(opcode, 8, 11);
    uint8_t immediate_value = opcode & 0xFF;

    // if L is set, we load. if L is not set, we store.
    cpu->memory->write_word(*cpu->sp + (immediate_value << 2), cpu->regs[rd]);

    cpu->cycles_remaining += 2;
}

void run_10010110(ARM7TDMI* cpu, uint16_t opcode);
void run_10010110(ARM7TDMI* cpu, uint16_t opcode) {
    uint8_t rd = get_nth_bits(opcode, 8, 11);
    uint8_t immediate_value = opcode & 0xFF;

    // if L is set, we load. if L is not set, we store.
    cpu->memory->write_word(*cpu->sp + (immediate_value << 2), cpu->regs[rd]);

    cpu->cycles_remaining += 2;
}

void run_10010111(ARM7TDMI* cpu, uint16_t opcode);
void run_10010111(ARM7TDMI* cpu, uint16_t opcode) {
    uint8_t rd = get_nth_bits(opcode, 8, 11);
    uint8_t immediate_value = opcode & 0xFF;

    // if L is set, we load. if L is not set, we store.
    cpu->memory->write_word(*cpu->sp + (immediate_value << 2), cpu->regs[rd]);

    cpu->cycles_remaining += 2;
}

void run_10011000(ARM7TDMI* cpu, uint16_t opcode);
void run_10011000(ARM7TDMI* cpu, uint16_t opcode) {
    uint8_t rd = get_nth_bits(opcode, 8, 11);
    uint8_t immediate_value = opcode & 0xFF;

    // if L is set, we load. if L is not set, we store.
    cpu->regs[rd] = cpu->memory->read_word(*cpu->sp + (immediate_value << 2));

    cpu->cycles_remaining += 2;
    cpu->cycles_remaining += 1;
}

void run_10011001(ARM7TDMI* cpu, uint16_t opcode);
void run_10011001(ARM7TDMI* cpu, uint16_t opcode) {
    uint8_t rd = get_nth_bits(opcode, 8, 11);
    uint8_t immediate_value = opcode & 0xFF;

    // if L is set, we load. if L is not set, we store.
    cpu->regs[rd] = cpu->memory->read_word(*cpu->sp + (immediate_value << 2));

    cpu->cycles_remaining += 2;
    cpu->cycles_remaining += 1;
}

void run_10011010(ARM7TDMI* cpu, uint16_t opcode);
void run_10011010(ARM7TDMI* cpu, uint16_t opcode) {
    uint8_t rd = get_nth_bits(opcode, 8, 11);
    uint8_t immediate_value = opcode & 0xFF;

    // if L is set, we load. if L is not set, we store.
    cpu->regs[rd] = cpu->memory->read_word(*cpu->sp + (immediate_value << 2));

    cpu->cycles_remaining += 2;
    cpu->cycles_remaining += 1;
}

void run_10011011(ARM7TDMI* cpu, uint16_t opcode);
void run_10011011(ARM7TDMI* cpu, uint16_t opcode) {
    uint8_t rd = get_nth_bits(opcode, 8, 11);
    uint8_t immediate_value = opcode & 0xFF;

    // if L is set, we load. if L is not set, we store.
    cpu->regs[rd] = cpu->memory->read_word(*cpu->sp + (immediate_value << 2));

    cpu->cycles_remaining += 2;
    cpu->cycles_remaining += 1;
}

void run_10011100(ARM7TDMI* cpu, uint16_t opcode);
void run_10011100(ARM7TDMI* cpu, uint16_t opcode) {
    uint8_t rd = get_nth_bits(opcode, 8, 11);
    uint8_t immediate_value = opcode & 0xFF;

    // if L is set, we load. if L is not set, we store.
    cpu->regs[rd] = cpu->memory->read_word(*cpu->sp + (immediate_value << 2));

    cpu->cycles_remaining += 2;
    cpu->cycles_remaining += 1;
}

void run_10011101(ARM7TDMI* cpu, uint16_t opcode);
void run_10011101(ARM7TDMI* cpu, uint16_t opcode) {
    uint8_t rd = get_nth_bits(opcode, 8, 11);
    uint8_t immediate_value = opcode & 0xFF;

    // if L is set, we load. if L is not set, we store.
    cpu->regs[rd] = cpu->memory->read_word(*cpu->sp + (immediate_value << 2));

    cpu->cycles_remaining += 2;
    cpu->cycles_remaining += 1;
}

void run_10011110(ARM7TDMI* cpu, uint16_t opcode);
void run_10011110(ARM7TDMI* cpu, uint16_t opcode) {
    uint8_t rd = get_nth_bits(opcode, 8, 11);
    uint8_t immediate_value = opcode & 0xFF;

    // if L is set, we load. if L is not set, we store.
    cpu->regs[rd] = cpu->memory->read_word(*cpu->sp + (immediate_value << 2));

    cpu->cycles_remaining += 2;
    cpu->cycles_remaining += 1;
}

void run_10011111(ARM7TDMI* cpu, uint16_t opcode);
void run_10011111(ARM7TDMI* cpu, uint16_t opcode) {
    uint8_t rd = get_nth_bits(opcode, 8, 11);
    uint8_t immediate_value = opcode & 0xFF;

    // if L is set, we load. if L is not set, we store.
    cpu->regs[rd] = cpu->memory->read_word(*cpu->sp + (immediate_value << 2));

    cpu->cycles_remaining += 2;
    cpu->cycles_remaining += 1;
}

void run_10100000(ARM7TDMI* cpu, uint16_t opcode);
void run_10100000(ARM7TDMI* cpu, uint16_t opcode) {
    uint8_t rd = get_nth_bits(opcode, 8, 11);
    uint8_t immediate_value = opcode & 0xFF;
    cpu->regs[rd] = ((*cpu->pc + 2) & 0xFFFFFFFC) + (immediate_value << 2);

    cpu->cycles_remaining += 3;
}

void run_10100001(ARM7TDMI* cpu, uint16_t opcode);
void run_10100001(ARM7TDMI* cpu, uint16_t opcode) {
    uint8_t rd = get_nth_bits(opcode, 8, 11);
    uint8_t immediate_value = opcode & 0xFF;
    cpu->regs[rd] = ((*cpu->pc + 2) & 0xFFFFFFFC) + (immediate_value << 2);

    cpu->cycles_remaining += 3;
}

void run_10100010(ARM7TDMI* cpu, uint16_t opcode);
void run_10100010(ARM7TDMI* cpu, uint16_t opcode) {
    uint8_t rd = get_nth_bits(opcode, 8, 11);
    uint8_t immediate_value = opcode & 0xFF;
    cpu->regs[rd] = ((*cpu->pc + 2) & 0xFFFFFFFC) + (immediate_value << 2);

    cpu->cycles_remaining += 3;
}

void run_10100011(ARM7TDMI* cpu, uint16_t opcode);
void run_10100011(ARM7TDMI* cpu, uint16_t opcode) {
    uint8_t rd = get_nth_bits(opcode, 8, 11);
    uint8_t immediate_value = opcode & 0xFF;
    cpu->regs[rd] = ((*cpu->pc + 2) & 0xFFFFFFFC) + (immediate_value << 2);

    cpu->cycles_remaining += 3;
}

void run_10100100(ARM7TDMI* cpu, uint16_t opcode);
void run_10100100(ARM7TDMI* cpu, uint16_t opcode) {
    uint8_t rd = get_nth_bits(opcode, 8, 11);
    uint8_t immediate_value = opcode & 0xFF;
    cpu->regs[rd] = ((*cpu->pc + 2) & 0xFFFFFFFC) + (immediate_value << 2);

    cpu->cycles_remaining += 3;
}

void run_10100101(ARM7TDMI* cpu, uint16_t opcode);
void run_10100101(ARM7TDMI* cpu, uint16_t opcode) {
    uint8_t rd = get_nth_bits(opcode, 8, 11);
    uint8_t immediate_value = opcode & 0xFF;
    cpu->regs[rd] = ((*cpu->pc + 2) & 0xFFFFFFFC) + (immediate_value << 2);

    cpu->cycles_remaining += 3;
}

void run_10100110(ARM7TDMI* cpu, uint16_t opcode);
void run_10100110(ARM7TDMI* cpu, uint16_t opcode) {
    uint8_t rd = get_nth_bits(opcode, 8, 11);
    uint8_t immediate_value = opcode & 0xFF;
    cpu->regs[rd] = ((*cpu->pc + 2) & 0xFFFFFFFC) + (immediate_value << 2);

    cpu->cycles_remaining += 3;
}

void run_10100111(ARM7TDMI* cpu, uint16_t opcode);
void run_10100111(ARM7TDMI* cpu, uint16_t opcode) {
    uint8_t rd = get_nth_bits(opcode, 8, 11);
    uint8_t immediate_value = opcode & 0xFF;
    cpu->regs[rd] = ((*cpu->pc + 2) & 0xFFFFFFFC) + (immediate_value << 2);

    cpu->cycles_remaining += 3;
}

void run_10101000(ARM7TDMI* cpu, uint16_t opcode);
void run_10101000(ARM7TDMI* cpu, uint16_t opcode) {
    uint8_t rd = get_nth_bits(opcode, 8, 11);
    uint8_t immediate_value = opcode & 0xFF;
    cpu->regs[rd] =   *cpu->sp                    + (immediate_value << 2);

    cpu->cycles_remaining += 3;
}

void run_10101001(ARM7TDMI* cpu, uint16_t opcode);
void run_10101001(ARM7TDMI* cpu, uint16_t opcode) {
    uint8_t rd = get_nth_bits(opcode, 8, 11);
    uint8_t immediate_value = opcode & 0xFF;
    cpu->regs[rd] =   *cpu->sp                    + (immediate_value << 2);

    cpu->cycles_remaining += 3;
}

void run_10101010(ARM7TDMI* cpu, uint16_t opcode);
void run_10101010(ARM7TDMI* cpu, uint16_t opcode) {
    uint8_t rd = get_nth_bits(opcode, 8, 11);
    uint8_t immediate_value = opcode & 0xFF;
    cpu->regs[rd] =   *cpu->sp                    + (immediate_value << 2);

    cpu->cycles_remaining += 3;
}

void run_10101011(ARM7TDMI* cpu, uint16_t opcode);
void run_10101011(ARM7TDMI* cpu, uint16_t opcode) {
    uint8_t rd = get_nth_bits(opcode, 8, 11);
    uint8_t immediate_value = opcode & 0xFF;
    cpu->regs[rd] =   *cpu->sp                    + (immediate_value << 2);

    cpu->cycles_remaining += 3;
}

void run_10101100(ARM7TDMI* cpu, uint16_t opcode);
void run_10101100(ARM7TDMI* cpu, uint16_t opcode) {
    uint8_t rd = get_nth_bits(opcode, 8, 11);
    uint8_t immediate_value = opcode & 0xFF;
    cpu->regs[rd] =   *cpu->sp                    + (immediate_value << 2);

    cpu->cycles_remaining += 3;
}

void run_10101101(ARM7TDMI* cpu, uint16_t opcode);
void run_10101101(ARM7TDMI* cpu, uint16_t opcode) {
    uint8_t rd = get_nth_bits(opcode, 8, 11);
    uint8_t immediate_value = opcode & 0xFF;
    cpu->regs[rd] =   *cpu->sp                    + (immediate_value << 2);

    cpu->cycles_remaining += 3;
}

void run_10101110(ARM7TDMI* cpu, uint16_t opcode);
void run_10101110(ARM7TDMI* cpu, uint16_t opcode) {
    uint8_t rd = get_nth_bits(opcode, 8, 11);
    uint8_t immediate_value = opcode & 0xFF;
    cpu->regs[rd] =   *cpu->sp                    + (immediate_value << 2);

    cpu->cycles_remaining += 3;
}

void run_10101111(ARM7TDMI* cpu, uint16_t opcode);
void run_10101111(ARM7TDMI* cpu, uint16_t opcode) {
    uint8_t rd = get_nth_bits(opcode, 8, 11);
    uint8_t immediate_value = opcode & 0xFF;
    cpu->regs[rd] =   *cpu->sp                    + (immediate_value << 2);

    cpu->cycles_remaining += 3;
}

void run_10110000(ARM7TDMI* cpu, uint16_t opcode);
void run_10110000(ARM7TDMI* cpu, uint16_t opcode) {
    uint16_t offset     = get_nth_bits(opcode, 0, 7) << 2;
    bool is_subtraction = get_nth_bit(opcode, 7);
    
    if (is_subtraction) {
        *cpu->sp -= offset;
    } else {
        *cpu->sp += offset;
    }

    cpu->cycles_remaining += 1;
}

void run_10110001(ARM7TDMI* cpu, uint16_t opcode);
void run_10110001(ARM7TDMI* cpu, uint16_t opcode) {
    DEBUG_MESSAGE("NOP");
}

void run_10110010(ARM7TDMI* cpu, uint16_t opcode);
void run_10110010(ARM7TDMI* cpu, uint16_t opcode) {
    DEBUG_MESSAGE("NOP");
}

void run_10110011(ARM7TDMI* cpu, uint16_t opcode);
void run_10110011(ARM7TDMI* cpu, uint16_t opcode) {
    DEBUG_MESSAGE("NOP");
}

void run_10110100(ARM7TDMI* cpu, uint16_t opcode);
void run_10110100(ARM7TDMI* cpu, uint16_t opcode) {
    uint8_t register_list  = opcode & 0xFF;
    bool    is_lr_included = get_nth_bit(opcode, 8);

    // deal with the linkage register (LR)
    if (is_lr_included) {
        *cpu->sp -= 4;
        cpu->memory->write_word(*cpu->sp, *cpu->lr);
    }

    int num_pushed = 0;
    // now loop backwards through the registers
    for (int i = 7; i >= 0; i--) {
        if (get_nth_bit(register_list, i)) {
            *cpu->sp -= 4;
            cpu->memory->write_word(*cpu->sp, cpu->regs[i]);
            num_pushed++;
        }
    }

    cpu->cycles_remaining += num_pushed + 1;
}

void run_10110101(ARM7TDMI* cpu, uint16_t opcode);
void run_10110101(ARM7TDMI* cpu, uint16_t opcode) {
    uint8_t register_list  = opcode & 0xFF;
    bool    is_lr_included = get_nth_bit(opcode, 8);

    // deal with the linkage register (LR)
    if (is_lr_included) {
        *cpu->sp -= 4;
        cpu->memory->write_word(*cpu->sp, *cpu->lr);
    }

    int num_pushed = 0;
    // now loop backwards through the registers
    for (int i = 7; i >= 0; i--) {
        if (get_nth_bit(register_list, i)) {
            *cpu->sp -= 4;
            cpu->memory->write_word(*cpu->sp, cpu->regs[i]);
            num_pushed++;
        }
    }

    cpu->cycles_remaining += num_pushed + 1;
}

void run_10110110(ARM7TDMI* cpu, uint16_t opcode);
void run_10110110(ARM7TDMI* cpu, uint16_t opcode) {
    DEBUG_MESSAGE("NOP");
}

void run_10110111(ARM7TDMI* cpu, uint16_t opcode);
void run_10110111(ARM7TDMI* cpu, uint16_t opcode) {
    DEBUG_MESSAGE("NOP");
}

void run_10111000(ARM7TDMI* cpu, uint16_t opcode);
void run_10111000(ARM7TDMI* cpu, uint16_t opcode) {
    DEBUG_MESSAGE("NOP");
}

void run_10111001(ARM7TDMI* cpu, uint16_t opcode);
void run_10111001(ARM7TDMI* cpu, uint16_t opcode) {
    DEBUG_MESSAGE("NOP");
}

void run_10111010(ARM7TDMI* cpu, uint16_t opcode);
void run_10111010(ARM7TDMI* cpu, uint16_t opcode) {
    DEBUG_MESSAGE("NOP");
}

void run_10111011(ARM7TDMI* cpu, uint16_t opcode);
void run_10111011(ARM7TDMI* cpu, uint16_t opcode) {
    DEBUG_MESSAGE("NOP");
}

void run_10111100(ARM7TDMI* cpu, uint16_t opcode);
void run_10111100(ARM7TDMI* cpu, uint16_t opcode) {
    uint8_t register_list  = opcode & 0xFF;
    bool    is_lr_included = get_nth_bit(opcode, 8);

    int num_pushed = 0;
    // loop forwards through the registers
    for (int i = 0; i < 8; i++) {
        if (get_nth_bit(register_list, i)) {
            cpu->regs[i] = cpu->memory->read_word(*cpu->sp);
            *cpu->sp += 4;
            num_pushed++;
        }
    }

    // now deal with the linkage register (LR) and set it to the PC if it exists.
    if (is_lr_included) {
        *cpu->pc = cpu->memory->read_word(*cpu->sp);
        *cpu->sp += 4;
    }

    cpu->cycles_remaining += num_pushed + 2;
}

void run_10111101(ARM7TDMI* cpu, uint16_t opcode);
void run_10111101(ARM7TDMI* cpu, uint16_t opcode) {
    uint8_t register_list  = opcode & 0xFF;
    bool    is_lr_included = get_nth_bit(opcode, 8);

    int num_pushed = 0;
    // loop forwards through the registers
    for (int i = 0; i < 8; i++) {
        if (get_nth_bit(register_list, i)) {
            cpu->regs[i] = cpu->memory->read_word(*cpu->sp);
            *cpu->sp += 4;
            num_pushed++;
        }
    }

    // now deal with the linkage register (LR) and set it to the PC if it exists.
    if (is_lr_included) {
        *cpu->pc = cpu->memory->read_word(*cpu->sp);
        *cpu->sp += 4;
    }

    cpu->cycles_remaining += num_pushed + 2;
}

void run_10111110(ARM7TDMI* cpu, uint16_t opcode);
void run_10111110(ARM7TDMI* cpu, uint16_t opcode) {
    DEBUG_MESSAGE("NOP");
}

void run_10111111(ARM7TDMI* cpu, uint16_t opcode);
void run_10111111(ARM7TDMI* cpu, uint16_t opcode) {
    DEBUG_MESSAGE("NOP");
}

void run_11000000(ARM7TDMI* cpu, uint16_t opcode);
void run_11000000(ARM7TDMI* cpu, uint16_t opcode) {
    DEBUG_MESSAGE("Multiple Store (STMIA)");
    uint32_t* start_address = cpu->regs + get_nth_bits(opcode, 8, 11);
    uint8_t   register_list = get_nth_bits(opcode, 0, 8);

    int num_pushed          = 0;
    for (int i = 0; i < 8; i++) {
        // should we store this register?
        if (get_nth_bit(register_list, i)) {
            // don't optimize this by moving the bitwise and over to the initialization of start_address
            // it has to be this way for when we writeback to cpu->regs after the loop
            *start_address += 4;
            cpu->memory->write_word(((*start_address - 4) & 0xFFFFFFFC),  cpu->regs[i]);
            num_pushed++;
        }
    }

    cpu->cycles_remaining += num_pushed + 1;
}

void run_11000001(ARM7TDMI* cpu, uint16_t opcode);
void run_11000001(ARM7TDMI* cpu, uint16_t opcode) {
    DEBUG_MESSAGE("Multiple Store (STMIA)");
    uint32_t* start_address = cpu->regs + get_nth_bits(opcode, 8, 11);
    uint8_t   register_list = get_nth_bits(opcode, 0, 8);

    int num_pushed          = 0;
    for (int i = 0; i < 8; i++) {
        // should we store this register?
        if (get_nth_bit(register_list, i)) {
            // don't optimize this by moving the bitwise and over to the initialization of start_address
            // it has to be this way for when we writeback to cpu->regs after the loop
            *start_address += 4;
            cpu->memory->write_word(((*start_address - 4) & 0xFFFFFFFC),  cpu->regs[i]);
            num_pushed++;
        }
    }

    cpu->cycles_remaining += num_pushed + 1;
}

void run_11000010(ARM7TDMI* cpu, uint16_t opcode);
void run_11000010(ARM7TDMI* cpu, uint16_t opcode) {
    DEBUG_MESSAGE("Multiple Store (STMIA)");
    uint32_t* start_address = cpu->regs + get_nth_bits(opcode, 8, 11);
    uint8_t   register_list = get_nth_bits(opcode, 0, 8);

    int num_pushed          = 0;
    for (int i = 0; i < 8; i++) {
        // should we store this register?
        if (get_nth_bit(register_list, i)) {
            // don't optimize this by moving the bitwise and over to the initialization of start_address
            // it has to be this way for when we writeback to cpu->regs after the loop
            *start_address += 4;
            cpu->memory->write_word(((*start_address - 4) & 0xFFFFFFFC),  cpu->regs[i]);
            num_pushed++;
        }
    }

    cpu->cycles_remaining += num_pushed + 1;
}

void run_11000011(ARM7TDMI* cpu, uint16_t opcode);
void run_11000011(ARM7TDMI* cpu, uint16_t opcode) {
    DEBUG_MESSAGE("Multiple Store (STMIA)");
    uint32_t* start_address = cpu->regs + get_nth_bits(opcode, 8, 11);
    uint8_t   register_list = get_nth_bits(opcode, 0, 8);

    int num_pushed          = 0;
    for (int i = 0; i < 8; i++) {
        // should we store this register?
        if (get_nth_bit(register_list, i)) {
            // don't optimize this by moving the bitwise and over to the initialization of start_address
            // it has to be this way for when we writeback to cpu->regs after the loop
            *start_address += 4;
            cpu->memory->write_word(((*start_address - 4) & 0xFFFFFFFC),  cpu->regs[i]);
            num_pushed++;
        }
    }

    cpu->cycles_remaining += num_pushed + 1;
}

void run_11000100(ARM7TDMI* cpu, uint16_t opcode);
void run_11000100(ARM7TDMI* cpu, uint16_t opcode) {
    DEBUG_MESSAGE("Multiple Store (STMIA)");
    uint32_t* start_address = cpu->regs + get_nth_bits(opcode, 8, 11);
    uint8_t   register_list = get_nth_bits(opcode, 0, 8);

    int num_pushed          = 0;
    for (int i = 0; i < 8; i++) {
        // should we store this register?
        if (get_nth_bit(register_list, i)) {
            // don't optimize this by moving the bitwise and over to the initialization of start_address
            // it has to be this way for when we writeback to cpu->regs after the loop
            *start_address += 4;
            cpu->memory->write_word(((*start_address - 4) & 0xFFFFFFFC),  cpu->regs[i]);
            num_pushed++;
        }
    }

    cpu->cycles_remaining += num_pushed + 1;
}

void run_11000101(ARM7TDMI* cpu, uint16_t opcode);
void run_11000101(ARM7TDMI* cpu, uint16_t opcode) {
    DEBUG_MESSAGE("Multiple Store (STMIA)");
    uint32_t* start_address = cpu->regs + get_nth_bits(opcode, 8, 11);
    uint8_t   register_list = get_nth_bits(opcode, 0, 8);

    int num_pushed          = 0;
    for (int i = 0; i < 8; i++) {
        // should we store this register?
        if (get_nth_bit(register_list, i)) {
            // don't optimize this by moving the bitwise and over to the initialization of start_address
            // it has to be this way for when we writeback to cpu->regs after the loop
            *start_address += 4;
            cpu->memory->write_word(((*start_address - 4) & 0xFFFFFFFC),  cpu->regs[i]);
            num_pushed++;
        }
    }

    cpu->cycles_remaining += num_pushed + 1;
}

void run_11000110(ARM7TDMI* cpu, uint16_t opcode);
void run_11000110(ARM7TDMI* cpu, uint16_t opcode) {
    DEBUG_MESSAGE("Multiple Store (STMIA)");
    uint32_t* start_address = cpu->regs + get_nth_bits(opcode, 8, 11);
    uint8_t   register_list = get_nth_bits(opcode, 0, 8);

    int num_pushed          = 0;
    for (int i = 0; i < 8; i++) {
        // should we store this register?
        if (get_nth_bit(register_list, i)) {
            // don't optimize this by moving the bitwise and over to the initialization of start_address
            // it has to be this way for when we writeback to cpu->regs after the loop
            *start_address += 4;
            cpu->memory->write_word(((*start_address - 4) & 0xFFFFFFFC),  cpu->regs[i]);
            num_pushed++;
        }
    }

    cpu->cycles_remaining += num_pushed + 1;
}

void run_11000111(ARM7TDMI* cpu, uint16_t opcode);
void run_11000111(ARM7TDMI* cpu, uint16_t opcode) {
    DEBUG_MESSAGE("Multiple Store (STMIA)");
    uint32_t* start_address = cpu->regs + get_nth_bits(opcode, 8, 11);
    uint8_t   register_list = get_nth_bits(opcode, 0, 8);

    int num_pushed          = 0;
    for (int i = 0; i < 8; i++) {
        // should we store this register?
        if (get_nth_bit(register_list, i)) {
            // don't optimize this by moving the bitwise and over to the initialization of start_address
            // it has to be this way for when we writeback to cpu->regs after the loop
            *start_address += 4;
            cpu->memory->write_word(((*start_address - 4) & 0xFFFFFFFC),  cpu->regs[i]);
            num_pushed++;
        }
    }

    cpu->cycles_remaining += num_pushed + 1;
}

void run_11001000(ARM7TDMI* cpu, uint16_t opcode);
void run_11001000(ARM7TDMI* cpu, uint16_t opcode) {
    uint8_t rn               = get_nth_bits(opcode, 8, 11);
    uint8_t register_list    = opcode & 0xFF;
    uint32_t current_address = cpu->regs[rn];

    // should we update rn after the LDMIA?
    // only happens if rn wasn't in register_list.
    bool update_rn         = true;
    int num_pushed         = 0;
    for (int i = 0; i < 8; i++) {
        if (get_nth_bit(register_list, i)) {
            if (rn == i) {
                update_rn = false;
            }

            cpu->regs[i] = cpu->memory->read_word(current_address);
            current_address += 4;
            num_pushed++;
        }
    }

    if (update_rn) {
        cpu->regs[rn] = current_address;
    }

    cpu->cycles_remaining += num_pushed + 2;
}

void run_11001001(ARM7TDMI* cpu, uint16_t opcode);
void run_11001001(ARM7TDMI* cpu, uint16_t opcode) {
    uint8_t rn               = get_nth_bits(opcode, 8, 11);
    uint8_t register_list    = opcode & 0xFF;
    uint32_t current_address = cpu->regs[rn];

    // should we update rn after the LDMIA?
    // only happens if rn wasn't in register_list.
    bool update_rn         = true;
    int num_pushed         = 0;
    for (int i = 0; i < 8; i++) {
        if (get_nth_bit(register_list, i)) {
            if (rn == i) {
                update_rn = false;
            }

            cpu->regs[i] = cpu->memory->read_word(current_address);
            current_address += 4;
            num_pushed++;
        }
    }

    if (update_rn) {
        cpu->regs[rn] = current_address;
    }

    cpu->cycles_remaining += num_pushed + 2;
}

void run_11001010(ARM7TDMI* cpu, uint16_t opcode);
void run_11001010(ARM7TDMI* cpu, uint16_t opcode) {
    uint8_t rn               = get_nth_bits(opcode, 8, 11);
    uint8_t register_list    = opcode & 0xFF;
    uint32_t current_address = cpu->regs[rn];

    // should we update rn after the LDMIA?
    // only happens if rn wasn't in register_list.
    bool update_rn         = true;
    int num_pushed         = 0;
    for (int i = 0; i < 8; i++) {
        if (get_nth_bit(register_list, i)) {
            if (rn == i) {
                update_rn = false;
            }

            cpu->regs[i] = cpu->memory->read_word(current_address);
            current_address += 4;
            num_pushed++;
        }
    }

    if (update_rn) {
        cpu->regs[rn] = current_address;
    }

    cpu->cycles_remaining += num_pushed + 2;
}

void run_11001011(ARM7TDMI* cpu, uint16_t opcode);
void run_11001011(ARM7TDMI* cpu, uint16_t opcode) {
    uint8_t rn               = get_nth_bits(opcode, 8, 11);
    uint8_t register_list    = opcode & 0xFF;
    uint32_t current_address = cpu->regs[rn];

    // should we update rn after the LDMIA?
    // only happens if rn wasn't in register_list.
    bool update_rn         = true;
    int num_pushed         = 0;
    for (int i = 0; i < 8; i++) {
        if (get_nth_bit(register_list, i)) {
            if (rn == i) {
                update_rn = false;
            }

            cpu->regs[i] = cpu->memory->read_word(current_address);
            current_address += 4;
            num_pushed++;
        }
    }

    if (update_rn) {
        cpu->regs[rn] = current_address;
    }

    cpu->cycles_remaining += num_pushed + 2;
}

void run_11001100(ARM7TDMI* cpu, uint16_t opcode);
void run_11001100(ARM7TDMI* cpu, uint16_t opcode) {
    uint8_t rn               = get_nth_bits(opcode, 8, 11);
    uint8_t register_list    = opcode & 0xFF;
    uint32_t current_address = cpu->regs[rn];

    // should we update rn after the LDMIA?
    // only happens if rn wasn't in register_list.
    bool update_rn         = true;
    int num_pushed         = 0;
    for (int i = 0; i < 8; i++) {
        if (get_nth_bit(register_list, i)) {
            if (rn == i) {
                update_rn = false;
            }

            cpu->regs[i] = cpu->memory->read_word(current_address);
            current_address += 4;
            num_pushed++;
        }
    }

    if (update_rn) {
        cpu->regs[rn] = current_address;
    }

    cpu->cycles_remaining += num_pushed + 2;
}

void run_11001101(ARM7TDMI* cpu, uint16_t opcode);
void run_11001101(ARM7TDMI* cpu, uint16_t opcode) {
    uint8_t rn               = get_nth_bits(opcode, 8, 11);
    uint8_t register_list    = opcode & 0xFF;
    uint32_t current_address = cpu->regs[rn];

    // should we update rn after the LDMIA?
    // only happens if rn wasn't in register_list.
    bool update_rn         = true;
    int num_pushed         = 0;
    for (int i = 0; i < 8; i++) {
        if (get_nth_bit(register_list, i)) {
            if (rn == i) {
                update_rn = false;
            }

            cpu->regs[i] = cpu->memory->read_word(current_address);
            current_address += 4;
            num_pushed++;
        }
    }

    if (update_rn) {
        cpu->regs[rn] = current_address;
    }

    cpu->cycles_remaining += num_pushed + 2;
}

void run_11001110(ARM7TDMI* cpu, uint16_t opcode);
void run_11001110(ARM7TDMI* cpu, uint16_t opcode) {
    uint8_t rn               = get_nth_bits(opcode, 8, 11);
    uint8_t register_list    = opcode & 0xFF;
    uint32_t current_address = cpu->regs[rn];

    // should we update rn after the LDMIA?
    // only happens if rn wasn't in register_list.
    bool update_rn         = true;
    int num_pushed         = 0;
    for (int i = 0; i < 8; i++) {
        if (get_nth_bit(register_list, i)) {
            if (rn == i) {
                update_rn = false;
            }

            cpu->regs[i] = cpu->memory->read_word(current_address);
            current_address += 4;
            num_pushed++;
        }
    }

    if (update_rn) {
        cpu->regs[rn] = current_address;
    }

    cpu->cycles_remaining += num_pushed + 2;
}

void run_11001111(ARM7TDMI* cpu, uint16_t opcode);
void run_11001111(ARM7TDMI* cpu, uint16_t opcode) {
    uint8_t rn               = get_nth_bits(opcode, 8, 11);
    uint8_t register_list    = opcode & 0xFF;
    uint32_t current_address = cpu->regs[rn];

    // should we update rn after the LDMIA?
    // only happens if rn wasn't in register_list.
    bool update_rn         = true;
    int num_pushed         = 0;
    for (int i = 0; i < 8; i++) {
        if (get_nth_bit(register_list, i)) {
            if (rn == i) {
                update_rn = false;
            }

            cpu->regs[i] = cpu->memory->read_word(current_address);
            current_address += 4;
            num_pushed++;
        }
    }

    if (update_rn) {
        cpu->regs[rn] = current_address;
    }

    cpu->cycles_remaining += num_pushed + 2;
}

void run_11010000(ARM7TDMI* cpu, uint16_t opcode);
void run_11010000(ARM7TDMI* cpu, uint16_t opcode) {
    // this may look daunting, but it's just the different possibilities for COND.
    // each COND has a different if expression we need to consider.
    if (cpu->get_flag_Z()) {
        DEBUG_MESSAGE("Conditional Branch Taken");
        *cpu->pc += ((int8_t)(opcode & 0xFF)) * 2 + 2;
    } else {
        DEBUG_MESSAGE("Conditional Branch Not Taken");
    }

    cpu->cycles_remaining += 3;
}

void run_11010001(ARM7TDMI* cpu, uint16_t opcode);
void run_11010001(ARM7TDMI* cpu, uint16_t opcode) {
    // this may look daunting, but it's just the different possibilities for COND.
    // each COND has a different if expression we need to consider.
    if (!cpu->get_flag_Z()) {
        DEBUG_MESSAGE("Conditional Branch Taken");
        *cpu->pc += ((int8_t)(opcode & 0xFF)) * 2 + 2;
    } else {
        DEBUG_MESSAGE("Conditional Branch Not Taken");
    }

    cpu->cycles_remaining += 3;
}

void run_11010010(ARM7TDMI* cpu, uint16_t opcode);
void run_11010010(ARM7TDMI* cpu, uint16_t opcode) {
    // this may look daunting, but it's just the different possibilities for COND.
    // each COND has a different if expression we need to consider.
    if (cpu->get_flag_C()) {
        DEBUG_MESSAGE("Conditional Branch Taken");
        *cpu->pc += ((int8_t)(opcode & 0xFF)) * 2 + 2;
    } else {
        DEBUG_MESSAGE("Conditional Branch Not Taken");
    }

    cpu->cycles_remaining += 3;
}

void run_11010011(ARM7TDMI* cpu, uint16_t opcode);
void run_11010011(ARM7TDMI* cpu, uint16_t opcode) {
    // this may look daunting, but it's just the different possibilities for COND.
    // each COND has a different if expression we need to consider.
    if (!cpu->get_flag_C()) {
        DEBUG_MESSAGE("Conditional Branch Taken");
        *cpu->pc += ((int8_t)(opcode & 0xFF)) * 2 + 2;
    } else {
        DEBUG_MESSAGE("Conditional Branch Not Taken");
    }

    cpu->cycles_remaining += 3;
}

void run_11010100(ARM7TDMI* cpu, uint16_t opcode);
void run_11010100(ARM7TDMI* cpu, uint16_t opcode) {
    // this may look daunting, but it's just the different possibilities for COND.
    // each COND has a different if expression we need to consider.
    if (cpu->get_flag_N()) {
        DEBUG_MESSAGE("Conditional Branch Taken");
        *cpu->pc += ((int8_t)(opcode & 0xFF)) * 2 + 2;
    } else {
        DEBUG_MESSAGE("Conditional Branch Not Taken");
    }

    cpu->cycles_remaining += 3;
}

void run_11010101(ARM7TDMI* cpu, uint16_t opcode);
void run_11010101(ARM7TDMI* cpu, uint16_t opcode) {
    // this may look daunting, but it's just the different possibilities for COND.
    // each COND has a different if expression we need to consider.
    if (!cpu->get_flag_N()) {
        DEBUG_MESSAGE("Conditional Branch Taken");
        *cpu->pc += ((int8_t)(opcode & 0xFF)) * 2 + 2;
    } else {
        DEBUG_MESSAGE("Conditional Branch Not Taken");
    }

    cpu->cycles_remaining += 3;
}

void run_11010110(ARM7TDMI* cpu, uint16_t opcode);
void run_11010110(ARM7TDMI* cpu, uint16_t opcode) {
    // this may look daunting, but it's just the different possibilities for COND.
    // each COND has a different if expression we need to consider.
    if (cpu->get_flag_V()) {
        DEBUG_MESSAGE("Conditional Branch Taken");
        *cpu->pc += ((int8_t)(opcode & 0xFF)) * 2 + 2;
    } else {
        DEBUG_MESSAGE("Conditional Branch Not Taken");
    }

    cpu->cycles_remaining += 3;
}

void run_11010111(ARM7TDMI* cpu, uint16_t opcode);
void run_11010111(ARM7TDMI* cpu, uint16_t opcode) {
    // this may look daunting, but it's just the different possibilities for COND.
    // each COND has a different if expression we need to consider.
    if (!cpu->get_flag_V()) {
        DEBUG_MESSAGE("Conditional Branch Taken");
        *cpu->pc += ((int8_t)(opcode & 0xFF)) * 2 + 2;
    } else {
        DEBUG_MESSAGE("Conditional Branch Not Taken");
    }

    cpu->cycles_remaining += 3;
}

void run_11011000(ARM7TDMI* cpu, uint16_t opcode);
void run_11011000(ARM7TDMI* cpu, uint16_t opcode) {
    // this may look daunting, but it's just the different possibilities for COND.
    // each COND has a different if expression we need to consider.
    if (cpu->get_flag_C() && !cpu->get_flag_Z()) {
        DEBUG_MESSAGE("Conditional Branch Taken");
        *cpu->pc += ((int8_t)(opcode & 0xFF)) * 2 + 2;
    } else {
        DEBUG_MESSAGE("Conditional Branch Not Taken");
    }

    cpu->cycles_remaining += 3;
}

void run_11011001(ARM7TDMI* cpu, uint16_t opcode);
void run_11011001(ARM7TDMI* cpu, uint16_t opcode) {
    // this may look daunting, but it's just the different possibilities for COND.
    // each COND has a different if expression we need to consider.
    if (!cpu->get_flag_C() || cpu->get_flag_Z()) {
        DEBUG_MESSAGE("Conditional Branch Taken");
        *cpu->pc += ((int8_t)(opcode & 0xFF)) * 2 + 2;
    } else {
        DEBUG_MESSAGE("Conditional Branch Not Taken");
    }

    cpu->cycles_remaining += 3;
}

void run_11011010(ARM7TDMI* cpu, uint16_t opcode);
void run_11011010(ARM7TDMI* cpu, uint16_t opcode) {
    // this may look daunting, but it's just the different possibilities for COND.
    // each COND has a different if expression we need to consider.
    if (cpu->get_flag_N() == cpu->get_flag_V()) {
        DEBUG_MESSAGE("Conditional Branch Taken");
        *cpu->pc += ((int8_t)(opcode & 0xFF)) * 2 + 2;
    } else {
        DEBUG_MESSAGE("Conditional Branch Not Taken");
    }

    cpu->cycles_remaining += 3;
}

void run_11011011(ARM7TDMI* cpu, uint16_t opcode);
void run_11011011(ARM7TDMI* cpu, uint16_t opcode) {
    // this may look daunting, but it's just the different possibilities for COND.
    // each COND has a different if expression we need to consider.
    if (cpu->get_flag_N() ^ cpu->get_flag_V()) {
        DEBUG_MESSAGE("Conditional Branch Taken");
        *cpu->pc += ((int8_t)(opcode & 0xFF)) * 2 + 2;
    } else {
        DEBUG_MESSAGE("Conditional Branch Not Taken");
    }

    cpu->cycles_remaining += 3;
}

void run_11011100(ARM7TDMI* cpu, uint16_t opcode);
void run_11011100(ARM7TDMI* cpu, uint16_t opcode) {
    // this may look daunting, but it's just the different possibilities for COND.
    // each COND has a different if expression we need to consider.
    if (!cpu->get_flag_Z() && (cpu->get_flag_N() == cpu->get_flag_V())) {
        DEBUG_MESSAGE("Conditional Branch Taken");
        *cpu->pc += ((int8_t)(opcode & 0xFF)) * 2 + 2;
    } else {
        DEBUG_MESSAGE("Conditional Branch Not Taken");
    }

    cpu->cycles_remaining += 3;
}

void run_11011101(ARM7TDMI* cpu, uint16_t opcode);
void run_11011101(ARM7TDMI* cpu, uint16_t opcode) {
    // this may look daunting, but it's just the different possibilities for COND.
    // each COND has a different if expression we need to consider.
    if (cpu->get_flag_Z() || (cpu->get_flag_N() ^ cpu->get_flag_V())) {
        DEBUG_MESSAGE("Conditional Branch Taken");
        *cpu->pc += ((int8_t)(opcode & 0xFF)) * 2 + 2;
    } else {
        DEBUG_MESSAGE("Conditional Branch Not Taken");
    }

    cpu->cycles_remaining += 3;
}

void run_11011110(ARM7TDMI* cpu, uint16_t opcode);
void run_11011110(ARM7TDMI* cpu, uint16_t opcode) {
    // this may look daunting, but it's just the different possibilities for COND.
    // each COND has a different if expression we need to consider.
    if (true) { // the compiler will optimize this so it's fine
        DEBUG_MESSAGE("Conditional Branch Taken");
        *cpu->pc += ((int8_t)(opcode & 0xFF)) * 2 + 2;
    } else {
        DEBUG_MESSAGE("Conditional Branch Not Taken");
    }

    cpu->cycles_remaining += 3;
}

void run_11011111(ARM7TDMI* cpu, uint16_t opcode);
void run_11011111(ARM7TDMI* cpu, uint16_t opcode) {

}

void run_11100000(ARM7TDMI* cpu, uint16_t opcode);
void run_11100000(ARM7TDMI* cpu, uint16_t opcode) {
    DEBUG_MESSAGE("Unconditional Branch");

    int32_t sign_extended = (int32_t) (((int8_t) get_nth_bits(opcode, 0, 11)) << 1);
    *cpu->pc = (*cpu->pc + 2) + sign_extended;

    cpu->cycles_remaining += 3;
}

void run_11100001(ARM7TDMI* cpu, uint16_t opcode);
void run_11100001(ARM7TDMI* cpu, uint16_t opcode) {
    DEBUG_MESSAGE("Unconditional Branch");

    int32_t sign_extended = (int32_t) (((int8_t) get_nth_bits(opcode, 0, 11)) << 1);
    *cpu->pc = (*cpu->pc + 2) + sign_extended;

    cpu->cycles_remaining += 3;
}

void run_11100010(ARM7TDMI* cpu, uint16_t opcode);
void run_11100010(ARM7TDMI* cpu, uint16_t opcode) {
    DEBUG_MESSAGE("Unconditional Branch");

    int32_t sign_extended = (int32_t) (((int8_t) get_nth_bits(opcode, 0, 11)) << 1);
    *cpu->pc = (*cpu->pc + 2) + sign_extended;

    cpu->cycles_remaining += 3;
}

void run_11100011(ARM7TDMI* cpu, uint16_t opcode);
void run_11100011(ARM7TDMI* cpu, uint16_t opcode) {
    DEBUG_MESSAGE("Unconditional Branch");

    int32_t sign_extended = (int32_t) (((int8_t) get_nth_bits(opcode, 0, 11)) << 1);
    *cpu->pc = (*cpu->pc + 2) + sign_extended;

    cpu->cycles_remaining += 3;
}

void run_11100100(ARM7TDMI* cpu, uint16_t opcode);
void run_11100100(ARM7TDMI* cpu, uint16_t opcode) {
    DEBUG_MESSAGE("Unconditional Branch");

    int32_t sign_extended = (int32_t) (((int8_t) get_nth_bits(opcode, 0, 11)) << 1);
    *cpu->pc = (*cpu->pc + 2) + sign_extended;

    cpu->cycles_remaining += 3;
}

void run_11100101(ARM7TDMI* cpu, uint16_t opcode);
void run_11100101(ARM7TDMI* cpu, uint16_t opcode) {
    DEBUG_MESSAGE("Unconditional Branch");

    int32_t sign_extended = (int32_t) (((int8_t) get_nth_bits(opcode, 0, 11)) << 1);
    *cpu->pc = (*cpu->pc + 2) + sign_extended;

    cpu->cycles_remaining += 3;
}

void run_11100110(ARM7TDMI* cpu, uint16_t opcode);
void run_11100110(ARM7TDMI* cpu, uint16_t opcode) {
    DEBUG_MESSAGE("Unconditional Branch");

    int32_t sign_extended = (int32_t) (((int8_t) get_nth_bits(opcode, 0, 11)) << 1);
    *cpu->pc = (*cpu->pc + 2) + sign_extended;

    cpu->cycles_remaining += 3;
}

void run_11100111(ARM7TDMI* cpu, uint16_t opcode);
void run_11100111(ARM7TDMI* cpu, uint16_t opcode) {
    DEBUG_MESSAGE("Unconditional Branch");

    int32_t sign_extended = (int32_t) (((int8_t) get_nth_bits(opcode, 0, 11)) << 1);
    *cpu->pc = (*cpu->pc + 2) + sign_extended;

    cpu->cycles_remaining += 3;
}

void run_11101000(ARM7TDMI* cpu, uint16_t opcode);
void run_11101000(ARM7TDMI* cpu, uint16_t opcode) {
    DEBUG_MESSAGE("NOP");
}

void run_11101001(ARM7TDMI* cpu, uint16_t opcode);
void run_11101001(ARM7TDMI* cpu, uint16_t opcode) {
    DEBUG_MESSAGE("NOP");
}

void run_11101010(ARM7TDMI* cpu, uint16_t opcode);
void run_11101010(ARM7TDMI* cpu, uint16_t opcode) {
    DEBUG_MESSAGE("NOP");
}

void run_11101011(ARM7TDMI* cpu, uint16_t opcode);
void run_11101011(ARM7TDMI* cpu, uint16_t opcode) {
    DEBUG_MESSAGE("NOP");
}

void run_11101100(ARM7TDMI* cpu, uint16_t opcode);
void run_11101100(ARM7TDMI* cpu, uint16_t opcode) {
    DEBUG_MESSAGE("NOP");
}

void run_11101101(ARM7TDMI* cpu, uint16_t opcode);
void run_11101101(ARM7TDMI* cpu, uint16_t opcode) {
    DEBUG_MESSAGE("NOP");
}

void run_11101110(ARM7TDMI* cpu, uint16_t opcode);
void run_11101110(ARM7TDMI* cpu, uint16_t opcode) {
    DEBUG_MESSAGE("NOP");
}

void run_11101111(ARM7TDMI* cpu, uint16_t opcode);
void run_11101111(ARM7TDMI* cpu, uint16_t opcode) {
    DEBUG_MESSAGE("NOP");
}

void run_11110000(ARM7TDMI* cpu, uint16_t opcode);
void run_11110000(ARM7TDMI* cpu, uint16_t opcode) {
    // Sign extend to 32 bits and then left shift 12
    int32_t extended = (int32_t)(get_nth_bits(opcode, 0, 11));
    if (get_nth_bit(extended, 10)) extended |= 0xFFFFF800;

    *cpu->lr = (*cpu->pc + 2) + (extended << 12);

    cpu->cycles_remaining += 3;
}

void run_11110001(ARM7TDMI* cpu, uint16_t opcode);
void run_11110001(ARM7TDMI* cpu, uint16_t opcode) {
    // Sign extend to 32 bits and then left shift 12
    int32_t extended = (int32_t)(get_nth_bits(opcode, 0, 11));
    if (get_nth_bit(extended, 10)) extended |= 0xFFFFF800;

    *cpu->lr = (*cpu->pc + 2) + (extended << 12);

    cpu->cycles_remaining += 3;
}

void run_11110010(ARM7TDMI* cpu, uint16_t opcode);
void run_11110010(ARM7TDMI* cpu, uint16_t opcode) {
    // Sign extend to 32 bits and then left shift 12
    int32_t extended = (int32_t)(get_nth_bits(opcode, 0, 11));
    if (get_nth_bit(extended, 10)) extended |= 0xFFFFF800;

    *cpu->lr = (*cpu->pc + 2) + (extended << 12);

    cpu->cycles_remaining += 3;
}

void run_11110011(ARM7TDMI* cpu, uint16_t opcode);
void run_11110011(ARM7TDMI* cpu, uint16_t opcode) {
    // Sign extend to 32 bits and then left shift 12
    int32_t extended = (int32_t)(get_nth_bits(opcode, 0, 11));
    if (get_nth_bit(extended, 10)) extended |= 0xFFFFF800;

    *cpu->lr = (*cpu->pc + 2) + (extended << 12);

    cpu->cycles_remaining += 3;
}

void run_11110100(ARM7TDMI* cpu, uint16_t opcode);
void run_11110100(ARM7TDMI* cpu, uint16_t opcode) {
    // Sign extend to 32 bits and then left shift 12
    int32_t extended = (int32_t)(get_nth_bits(opcode, 0, 11));
    if (get_nth_bit(extended, 10)) extended |= 0xFFFFF800;

    *cpu->lr = (*cpu->pc + 2) + (extended << 12);

    cpu->cycles_remaining += 3;
}

void run_11110101(ARM7TDMI* cpu, uint16_t opcode);
void run_11110101(ARM7TDMI* cpu, uint16_t opcode) {
    // Sign extend to 32 bits and then left shift 12
    int32_t extended = (int32_t)(get_nth_bits(opcode, 0, 11));
    if (get_nth_bit(extended, 10)) extended |= 0xFFFFF800;

    *cpu->lr = (*cpu->pc + 2) + (extended << 12);

    cpu->cycles_remaining += 3;
}

void run_11110110(ARM7TDMI* cpu, uint16_t opcode);
void run_11110110(ARM7TDMI* cpu, uint16_t opcode) {
    // Sign extend to 32 bits and then left shift 12
    int32_t extended = (int32_t)(get_nth_bits(opcode, 0, 11));
    if (get_nth_bit(extended, 10)) extended |= 0xFFFFF800;

    *cpu->lr = (*cpu->pc + 2) + (extended << 12);

    cpu->cycles_remaining += 3;
}

void run_11110111(ARM7TDMI* cpu, uint16_t opcode);
void run_11110111(ARM7TDMI* cpu, uint16_t opcode) {
    // Sign extend to 32 bits and then left shift 12
    int32_t extended = (int32_t)(get_nth_bits(opcode, 0, 11));
    if (get_nth_bit(extended, 10)) extended |= 0xFFFFF800;

    *cpu->lr = (*cpu->pc + 2) + (extended << 12);

    cpu->cycles_remaining += 3;
}

void run_11111000(ARM7TDMI* cpu, uint16_t opcode);
void run_11111000(ARM7TDMI* cpu, uint16_t opcode) {
    uint32_t next_pc = *(cpu->pc);
    *cpu->pc = (*cpu->lr + (get_nth_bits(opcode, 0, 11) << 1));
    *cpu->lr = (next_pc) | 1;

    cpu->cycles_remaining += 3;
}

void run_11111001(ARM7TDMI* cpu, uint16_t opcode);
void run_11111001(ARM7TDMI* cpu, uint16_t opcode) {
    uint32_t next_pc = *(cpu->pc);
    *cpu->pc = (*cpu->lr + (get_nth_bits(opcode, 0, 11) << 1));
    *cpu->lr = (next_pc) | 1;

    cpu->cycles_remaining += 3;
}

void run_11111010(ARM7TDMI* cpu, uint16_t opcode);
void run_11111010(ARM7TDMI* cpu, uint16_t opcode) {
    uint32_t next_pc = *(cpu->pc);
    *cpu->pc = (*cpu->lr + (get_nth_bits(opcode, 0, 11) << 1));
    *cpu->lr = (next_pc) | 1;

    cpu->cycles_remaining += 3;
}

void run_11111011(ARM7TDMI* cpu, uint16_t opcode);
void run_11111011(ARM7TDMI* cpu, uint16_t opcode) {
    uint32_t next_pc = *(cpu->pc);
    *cpu->pc = (*cpu->lr + (get_nth_bits(opcode, 0, 11) << 1));
    *cpu->lr = (next_pc) | 1;

    cpu->cycles_remaining += 3;
}

void run_11111100(ARM7TDMI* cpu, uint16_t opcode);
void run_11111100(ARM7TDMI* cpu, uint16_t opcode) {
    uint32_t next_pc = *(cpu->pc);
    *cpu->pc = (*cpu->lr + (get_nth_bits(opcode, 0, 11) << 1));
    *cpu->lr = (next_pc) | 1;

    cpu->cycles_remaining += 3;
}

void run_11111101(ARM7TDMI* cpu, uint16_t opcode);
void run_11111101(ARM7TDMI* cpu, uint16_t opcode) {
    uint32_t next_pc = *(cpu->pc);
    *cpu->pc = (*cpu->lr + (get_nth_bits(opcode, 0, 11) << 1));
    *cpu->lr = (next_pc) | 1;

    cpu->cycles_remaining += 3;
}

void run_11111110(ARM7TDMI* cpu, uint16_t opcode);
void run_11111110(ARM7TDMI* cpu, uint16_t opcode) {
    uint32_t next_pc = *(cpu->pc);
    *cpu->pc = (*cpu->lr + (get_nth_bits(opcode, 0, 11) << 1));
    *cpu->lr = (next_pc) | 1;

    cpu->cycles_remaining += 3;
}

void run_11111111(ARM7TDMI* cpu, uint16_t opcode);
void run_11111111(ARM7TDMI* cpu, uint16_t opcode) {
    uint32_t next_pc = *(cpu->pc);
    *cpu->pc = (*cpu->lr + (get_nth_bits(opcode, 0, 11) << 1));
    *cpu->lr = (next_pc) | 1;

    cpu->cycles_remaining += 3;
}

immutable jumptable = [
    &run_00000000, &run_00000001, &run_00000010, &run_00000011, 
    &run_00000100, &run_00000101, &run_00000110, &run_00000111, 
    &run_00001000, &run_00001001, &run_00001010, &run_00001011, 
    &run_00001100, &run_00001101, &run_00001110, &run_00001111, 
    &run_00010000, &run_00010001, &run_00010010, &run_00010011, 
    &run_00010100, &run_00010101, &run_00010110, &run_00010111, 
    &run_00011000, &run_00011001, &run_00011010, &run_00011011, 
    &run_00011100, &run_00011101, &run_00011110, &run_00011111, 
    &run_00100000, &run_00100001, &run_00100010, &run_00100011, 
    &run_00100100, &run_00100101, &run_00100110, &run_00100111, 
    &run_00101000, &run_00101001, &run_00101010, &run_00101011, 
    &run_00101100, &run_00101101, &run_00101110, &run_00101111, 
    &run_00110000, &run_00110001, &run_00110010, &run_00110011, 
    &run_00110100, &run_00110101, &run_00110110, &run_00110111, 
    &run_00111000, &run_00111001, &run_00111010, &run_00111011, 
    &run_00111100, &run_00111101, &run_00111110, &run_00111111, 
    &run_01000000, &run_01000001, &run_01000010, &run_01000011, 
    &run_01000100, &run_01000101, &run_01000110, &run_01000111, 
    &run_01001000, &run_01001001, &run_01001010, &run_01001011, 
    &run_01001100, &run_01001101, &run_01001110, &run_01001111, 
    &run_01010000, &run_01010001, &run_01010010, &run_01010011, 
    &run_01010100, &run_01010101, &run_01010110, &run_01010111, 
    &run_01011000, &run_01011001, &run_01011010, &run_01011011, 
    &run_01011100, &run_01011101, &run_01011110, &run_01011111, 
    &run_01100000, &run_01100001, &run_01100010, &run_01100011, 
    &run_01100100, &run_01100101, &run_01100110, &run_01100111, 
    &run_01101000, &run_01101001, &run_01101010, &run_01101011, 
    &run_01101100, &run_01101101, &run_01101110, &run_01101111, 
    &run_01110000, &run_01110001, &run_01110010, &run_01110011, 
    &run_01110100, &run_01110101, &run_01110110, &run_01110111, 
    &run_01111000, &run_01111001, &run_01111010, &run_01111011, 
    &run_01111100, &run_01111101, &run_01111110, &run_01111111, 
    &run_10000000, &run_10000001, &run_10000010, &run_10000011, 
    &run_10000100, &run_10000101, &run_10000110, &run_10000111, 
    &run_10001000, &run_10001001, &run_10001010, &run_10001011, 
    &run_10001100, &run_10001101, &run_10001110, &run_10001111, 
    &run_10010000, &run_10010001, &run_10010010, &run_10010011, 
    &run_10010100, &run_10010101, &run_10010110, &run_10010111, 
    &run_10011000, &run_10011001, &run_10011010, &run_10011011, 
    &run_10011100, &run_10011101, &run_10011110, &run_10011111, 
    &run_10100000, &run_10100001, &run_10100010, &run_10100011, 
    &run_10100100, &run_10100101, &run_10100110, &run_10100111, 
    &run_10101000, &run_10101001, &run_10101010, &run_10101011, 
    &run_10101100, &run_10101101, &run_10101110, &run_10101111, 
    &run_10110000, &run_10110001, &run_10110010, &run_10110011, 
    &run_10110100, &run_10110101, &run_10110110, &run_10110111, 
    &run_10111000, &run_10111001, &run_10111010, &run_10111011, 
    &run_10111100, &run_10111101, &run_10111110, &run_10111111, 
    &run_11000000, &run_11000001, &run_11000010, &run_11000011, 
    &run_11000100, &run_11000101, &run_11000110, &run_11000111, 
    &run_11001000, &run_11001001, &run_11001010, &run_11001011, 
    &run_11001100, &run_11001101, &run_11001110, &run_11001111, 
    &run_11010000, &run_11010001, &run_11010010, &run_11010011, 
    &run_11010100, &run_11010101, &run_11010110, &run_11010111, 
    &run_11011000, &run_11011001, &run_11011010, &run_11011011, 
    &run_11011100, &run_11011101, &run_11011110, &run_11011111, 
    &run_11100000, &run_11100001, &run_11100010, &run_11100011, 
    &run_11100100, &run_11100101, &run_11100110, &run_11100111, 
    &run_11101000, &run_11101001, &run_11101010, &run_11101011, 
    &run_11101100, &run_11101101, &run_11101110, &run_11101111, 
    &run_11110000, &run_11110001, &run_11110010, &run_11110011, 
    &run_11110100, &run_11110101, &run_11110110, &run_11110111, 
    &run_11111000, &run_11111001, &run_11111010, &run_11111011, 
    &run_11111100, &run_11111101, &run_11111110, &run_11111111
];

