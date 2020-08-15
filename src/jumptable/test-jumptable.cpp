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
//     @EXCLUDE. @DEFAULT is used for a default function (in this case, the default is a nop function).
//     default functions are used when no other function matches the jumptable. this all was uint16_tended as a way 
//     to make the code cleaner and more readable.

@DEFAULT()
void nop(uint16_t opcode) {
    // NOP
}

// logical shift right
void run_00000ABC(uint16_t opcode) {
    std::cout << "Logical Shift Right" << std::endl;
    uint8_t source = get_nth_bits(opcode, 3,  6);
    uint8_t dest   = get_nth_bits(opcode, 0,  3);
    uint8_t shift  = get_nth_bits(opcode, 6,  11);

    if (shift == 0) // if shift == 0, the cpu shifts by 32, which is the size of the register.
        memory.regs[source] = 0;
    else
        memory.regs[source] >>= shift;
}

// logical shift left
void run_00001ABC(uint16_t opcode) {

}

// arithmetic shift left
void run_00010ABC(uint16_t opcode) {

}

// add and subtract
void run_000111OA(uint16_t opcode) {

}

// move, compare, add, and subtract immediate
void run_001OPABC(uint16_t opcode) {

}

// ALU operation
void run_010000PC(uint16_t opcode) {

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

// load and store halfword
void run_1000LOFS(uint16_t opcode) {

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

// multiple load and store
void run_1100LREG(uint16_t opcode) {

}

// conditional branch
@EXCLUDE(11011111)
void run_1101COND(uint16_t opcode) {

}

// software uint16_terrupt
void run_11011111(uint16_t opcode) {

}

// unconditional branch
void run_11100OFS(uint16_t opcode) {

}

// long branch with link
void run_1111HOFS(uint16_t opcode) {

}