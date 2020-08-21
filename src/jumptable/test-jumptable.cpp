// NOTE: this code is not meant to be run in its raw form. it should first be parsed by make-jumptable.py
// with these settings. this is automatically done by the makefile already:
//     INSTRUCTION_SIZE        = 16
//     JUMPTABLE_BIT_WIDTH     = 8
//
// Explanation of some of the notation:
//     all functions are titled run_<some binary value>. the binary value specifies where in the jumptable
//     the function belongs. if the binary value contains variables as bits (let's call them bit-variables), 
//     then those bits can be either 0 or 1, and the jumptable is updated accordingly. if you begin a function 
//     with @IF(<insert bit-variable here>), then the line is only included in entries of the jumptable where
//     that specific bit-variable is 1. if a function is preceded by @EXCLUDE(<some binary value>), then
//     the function will not be inserted in the jumptable at that binary value. - is used as a wildcard in
//     @EXCLUDE. @DEFAULT() is used for a default function (in this case, the default is a nop function).
//     default functions are used when no other function matches the jumptable. @LOCAL() to tell the script
//     that the following function is a local function and should appear in the .cpp file. i'm not using @LOCAL
//     anymore, but it's still supported by make-jumptable.py in case i ever need it. this all was intended
//     as a way to make the code cleaner and more readable.

@DEFAULT()
void nop(uint16_t opcode) {
    std::cout << "NOP" << std::endl;
}

// logical shift left/right
void run_0000SABC(uint16_t opcode) {
    @IF(S)  std::cout << "Logical Shift Right" << std::endl;
    @IF(!S) std::cout << "Logical Shift Left" << std::endl;

    uint8_t source = get_nth_bits(opcode, 3,  6);
    uint8_t dest   = get_nth_bits(opcode, 0,  3);
    uint8_t shift  = get_nth_bits(opcode, 6,  11);

    if (shift == 0) { // if shift == 0, the cpu shifts by 32, which is the size of the register.
        memory.regs[dest] = 0;
    } else {
        @IF(S)  flag_C = get_nth_bit(memory.regs[source], shift - 1);
        @IF(!S) flag_C = get_nth_bit(memory.regs[source], 32 - shift);
        @IF(S)  memory.regs[dest] = (memory.regs[source] >> shift);
        @IF(!S) memory.regs[dest] = (memory.regs[source] << shift);
    }

    flag_N = get_nth_bit(memory.regs[dest], 31);
    flag_Z = memory.regs[dest] == 0;
}

// arithmetic shift left
void run_00010ABC(uint16_t opcode) {

}

// add #1 010 001 001
void run_00011000(uint16_t opcode) {
    std::cout << "Add #1" << std::endl;

    uint32_t rn = memory.regs[get_nth_bits(opcode, 3, 6)];
    uint32_t rm = memory.regs[get_nth_bits(opcode, 6, 9)];
    
    memory.regs[get_nth_bits(opcode, 0, 3)] = rn + rm;
    uint32_t rd = memory.regs[get_nth_bits(opcode, 0, 3)];

    flag_N = get_nth_bit(rd, 31);
    flag_Z = rd == 0;
    flag_C = (uint64_t)rn + (uint64_t)rm > rd; // probably can be optimized

    // this is garbage, but essentially what's going on is:
    // if the two operands had matching signs but their sign differed from the result's sign,
    // then there was an overflow and we set the flag.
    bool matching_signs = get_nth_bit(rn, 31) == get_nth_bit(rm, 31);
    flag_V = matching_signs && (get_nth_bit(rn, 31) ^ flag_N);
}

// add #2 and subtract #2
void run_000111OA(uint16_t opcode) {

}

// move immediate
void run_00100ABC(uint16_t opcode) {
    std::cout << "Move Immediate" << std::endl;
    uint16_t immediate_value = get_nth_bits(opcode, 0, 8);
    memory.regs[get_nth_bits(opcode, 8, 11)] = immediate_value;
    // flags
    flag_N = get_nth_bit(immediate_value, 31);
    flag_Z = immediate_value == 0;
}

// compare immediate
void run_00101ABC(uint16_t opcode) {

}

// add immediate
void run_00110ABC(uint16_t opcode) {
    std::cout << "Add Immediate" << std::endl;

    int32_t immediate_value = get_nth_bits(opcode, 0, 8);
    uint32_t rd              = get_nth_bits(opcode, 8, 11);
    int32_t old_rd_value    = memory.regs[rd];

    memory.regs[rd] += immediate_value;
    int32_t new_rd_value    = memory.regs[rd];

    flag_N = get_nth_bit(new_rd_value, 31);
    flag_Z = (new_rd_value == 0);

    // Signed carry formula = (A AND B) OR (~DEST AND (A XOR B)) - works for all add operations once tested
    flag_C = (get_nth_bit(immediate_value, 31) & get_nth_bit(old_rd_value, 31)) | 
    ((get_nth_bit(immediate_value, 31) ^ get_nth_bit(old_rd_value, 31)) & ~(get_nth_bit(new_rd_value, 31)));

    bool matching_signs = get_nth_bit(old_rd_value, 31) == get_nth_bit(immediate_value, 31);
    flag_V = matching_signs && (get_nth_bit(new_rd_value, 31) ^ flag_N);
}

// subtract immediate
void run_00111ABC(uint16_t opcode) {
    // maybe we can link add immediate with subtract immediate using twos complement...
    // like, a - b is the same as a + (~b)
    std::cout << "Subtract Immediate" << std::endl;

    uint32_t immediate_value = get_nth_bits(opcode, 0, 8);
    uint8_t  rd              = get_nth_bits(opcode, 8, 11);
    uint32_t old_rd_value    = memory.regs[rd];
    
    memory.regs[rd]  -= immediate_value;
    uint32_t new_rd_value    = memory.regs[rd];

    flag_N = get_nth_bit(new_rd_value, 31);
    flag_Z = new_rd_value == 0;
    flag_C = immediate_value > old_rd_value;

    // this is garbage, but essentially what's going on is:
    // if the two operands had matching signs but their sign differed from the result's sign,
    // then there was an overflow and we set the flag.
    bool matching_signs = get_nth_bit(old_rd_value, 31) == get_nth_bit(immediate_value, 31);
    flag_V = matching_signs && (get_nth_bit(new_rd_value, 31) ^ flag_N);
}

// ALU operation - miscellaneous
@EXCLUDE(01000011)
void run_010000PC(uint16_t opcode) {
    std::cout << "ALU Operation" << std::endl;
    uint8_t operation = get_nth_bits(opcode, 6, 10);
}

// ALU operation - BIC
void run_01000011(uint16_t opcode) {
    std::cout << "ALU Operation - Bit Clear (BIC)" << std::endl;
    uint8_t rd = get_nth_bits(opcode, 0, 3);
    uint8_t rm = get_nth_bits(opcode, 3, 6);
    memory.regs[rd] = memory.regs[rd] & ~ memory.regs[rm];

    flag_N = get_nth_bit(memory.regs[rd], 31);
    flag_Z = memory.regs[rd] == 0;
}

// high register operations and branch exchange
void run_010001OP(uint16_t opcode) {

}

// pc-relative load
void run_01001REG(uint16_t opcode) {
    std::cout << "PC-Relative Load" << std::endl;
    uint8_t reg = get_nth_bits(opcode, 8,  11);
    uint32_t loc = (get_nth_bits(opcode, 0,  8) << 2) + *memory.pc + 2;
    memory.regs[reg] = *((uint32_t*)(memory.main + loc));
}

// load and store with relative offset
void run_0101LB0R(uint16_t opcode) {

}

// load and store sign-extended byte and halfword
void run_0101HS1R(uint16_t opcode) {

}

// load and store with immediate offset
void run_011BLOFS(uint16_t opcode) {

}

// load halfword
void run_10000OFS(uint16_t opcode) {
    uint8_t base  = get_nth_bits(opcode, 3,  6);
    uint8_t dest  = get_nth_bits(opcode, 0,  3);
    uint8_t shift = get_nth_bits(opcode, 6,  11);

    memory.regs[dest] = *((halfword*)(memory.main + memory.regs[base] + shift * 2));
    std::cout << memory.regs[dest] << std::endl;
}

// store halfword
void run_10001OFS(uint16_t opcode) {

}

// sp-relative load and store
void run_1001LREG(uint16_t opcode) {

}

// load address
void run_1010SREG(uint16_t opcode) {

}

// add offset to stack pouint16_ter
void run_10110000(uint16_t opcode) {

}

// push and pop registers(uint16_t opcode)
void run_1011L10R(uint16_t opcode) {

}

// multiple load
void run_11001REG(uint16_t opcode) {

}

// multiple store
void run_11000REG(uint16_t opcode) {
    std::cout << "Multiple Store (STMIA)" << std::endl;
    uint32_t start_address = memory.regs[get_nth_bits(opcode, 8, 10)];
    uint8_t  register_list = get_nth_bits(opcode, 0, 8);

    for (int i = 0; i < 8; i++) {
        // should we store this register?
        if (get_nth_bit(register_list, i)) {
            *(uint32_t*)(memory.main + start_address) = memory.regs[i];
            start_address += 4;
            memory.regs[get_nth_bits(opcode, 8, 10)] += 4;
        }
    }
}

// conditional branch
@EXCLUDE(11011111)
void run_1101COND(uint16_t opcode) {
    // this may look daunting, but it's just the different possibilities for COND.
    // each COND has a different if expression we need to consider.
    @IF(!C !O !N !D) if (flag_Z) {
    @IF(!C !O !N  D) if (!flag_Z) {
    @IF(!C !O  N !D) if (flag_C) {
    @IF(!C !O  N  D) if (!flag_C) {
    @IF(!C  O !N !D) if (flag_N) {
    @IF(!C  O !N  D) if (!flag_N) {
    @IF(!C  O  N !D) if (flag_V) {
    @IF(!C  O  N  D) if (!flag_V) {
    @IF( C !O !N !D) if (flag_C && !flag_Z) {
    @IF( C !O !N  D) if (!flag_C && flag_Z) {
    @IF( C !O  N !D) if (flag_N == flag_V) {
    @IF( C !O  N  D) if (flag_N ^ flag_V) {
    @IF( C  O !N !D) if (!flag_Z && (flag_N == flag_V)) {
    @IF( C  O !N  D) if (flag_Z || (flag_N ^ flag_V)) {
    @IF( C  O  N !D) if (true) { // the compiler will optimize this so it's fine
        std::cout << "Conditional Branch Taken" << std::endl;
        *memory.pc += ((int8_t)(opcode & 0xFF)) * 2 + 2;
    } else {
        std::cout << "Conditional Branch Not Taken" << std::endl;
    }
}

// software interrupt
void run_11011111(uint16_t opcode) {

}

// unconditional branch
void run_11100OFS(uint16_t opcode) {
    std::cout << "Unconditional Branch" << std::endl;

    int32_t sign_extended = (int32_t) (get_nth_bits(opcode, 0, 11));
    *memory.pc = (*memory.pc + 2) + (sign_extended << 1);
}

// long branch with link - high byte
void run_11110OFS(uint16_t opcode) {

    // Sign extend to 32 bits and then left shift 12
    int32_t extended = (int32_t)(get_nth_bits(opcode, 0, 11));
    *memory.lr = (*memory.pc + 2) + (extended << 12);

}

// long branch with link - low byte and call to subroutine
void run_11111OFS(uint16_t opcode) {
    uint32_t next_pc = *(memory.pc);
    *memory.pc = (*memory.lr + (get_nth_bits(opcode, 0, 11) << 1));
    *memory.lr = (next_pc) | 1;
}