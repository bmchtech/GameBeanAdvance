// NOTE: this code is not meant to be run in its raw form. it should first be parsed by make-jumptable.py
// with these settings. this is automatically done by the makefile already:
//     INSTRUCTION_SIZE        = 32 (the first 4 bits is a COND that wil be pre-processed by the gba before 
//                                   running the instruction)
//     JUMPTABLE_BIT_WIDTH     = 12
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
//
// Extra note: 
//    The first four bits of every instruction will be labeled "WXYZ". This represents the COND value that
//    precedes every ARM instruction. The reason it's labeled "WXYZ" and not "COND" is so i don't use up
//    common letters like C, O, N, and D on bit variables that aren't going to be used. The execute() function
//    itself will handle the COND.

#ifdef DEBUG_MESSAGE
    #define DEBUG_MESSAGE(message) std::cout << message << std::endl;
#else
    #define DEBUG_MESSAGE(message) do {} while(0)
#endif



// ********************************************** Addressing Mode 2 **********************************************
//                                             LDR / LDRB / STR / STRB
// ***************************************************************************************************************



@LOCAL()
inline uint32_t addressing_mode_2_immediate(uint32_t opcode)  {
    bool is_pc = get_nth_bits(opcode, 16, 20) == 15;

    if      (!is_pc &&  get_nth_bit(opcode, 23))   return memory.regs[get_nth_bits(opcode, 16, 20)] + get_nth_bits(opcode, 0, 12);
    else if (!is_pc && !get_nth_bit(opcode, 23))   return memory.regs[get_nth_bits(opcode, 16, 20)] - get_nth_bits(opcode, 0, 12);
    else if ( is_pc &&  get_nth_bit(opcode, 23))   return memory.regs[get_nth_bits(opcode, 16, 20)] + get_nth_bits(opcode, 0, 12) + 4;
    else  /*( is_pc && !get_nth_bit(opcode, 23))*/ return memory.regs[get_nth_bits(opcode, 16, 20)] - get_nth_bits(opcode, 0, 12) + 4;
}

@LOCAL()
inline uint32_t addressing_mode_2_immediate_preindexed(uint32_t opcode) {
    if (get_nth_bit(opcode, 23)) memory.regs[get_nth_bits(opcode, 16, 20)] += get_nth_bits(opcode, 0, 12);
    else                         memory.regs[get_nth_bits(opcode, 16, 20)] -= get_nth_bits(opcode, 0, 12);
    return memory.regs[get_nth_bits(opcode, 16, 20)];
}

@LOCAL()
inline uint32_t addressing_mode_2_immediate_postindexed(uint32_t opcode) {
    uint32_t address = memory.regs[get_nth_bits(opcode, 16, 20)];
    if (get_nth_bit(opcode, 23)) memory.regs[get_nth_bits(opcode, 16, 20)] += get_nth_bits(opcode, 0, 12);
    else                         memory.regs[get_nth_bits(opcode, 16, 20)] -= get_nth_bits(opcode, 0, 12);
    return address;
}




// *********************************************** Opcode Functions **********************************************
//                     A list of local helper functions that are used in the instruction set
// ***************************************************************************************************************



@LOCAL()
inline void ldr(uint32_t address, uint32_t opcode) {
    uint32_t value = *((uint32_t*)(memory.main + address));
    if ((address & 0b11) == 0b01) value = ((value & 0xFF)     << 24) | (value >> 8);
    if ((address & 0b11) == 0b10) value = ((value & 0xFFFF)   << 16) | (value >> 16);
    if ((address & 0b11) == 0b11) value = ((value & 0xFFFFFF) << 8)  | (value >> 24);

    uint8_t rd = get_nth_bits(opcode, 12, 16);
    if (rd == 15) {
        *memory.pc = value & 0xFFFFFFFC;
    } else {
        memory.regs[rd] = value;
    }
}



// *********************************************** Instruction Set ***********************************************
//                                      The actual ARM Instruction Set Config
// ***************************************************************************************************************



@DEFAULT()
void nop(uint32_t opcode) {
    DEBUG_MESSAGE("NOP");
}

// LDR instruction
// Addressing Mode 2, immediate
void run_COND0101U001(uint32_t opcode) {
    uint32_t address = addressing_mode_2_immediate(opcode);
    ldr(address, opcode);
}

// LDR Instruction
// Addressing Mode 2, immedaite pre-indexed
void run_COND0101U011(uint32_t opcode) {
    uint32_t address = addressing_mode_2_immediate_preindexed(opcode);
    ldr(address, opcode);
}

// LDR Instruction
// Addressing Mode 2, immedaite post-indexed
void run_COND0100U001(uint32_t opcode) {
    uint32_t address = addressing_mode_2_immediate_postindexed(opcode);
    ldr(address, opcode);
}

// B / BL instruction
void run_COND101LABEF(uint32_t opcode) {
    @IF(L) *memory.lr = *memory.pc;
    // unintuitive sign extension: http://graphics.stanford.edu/~seander/bithacks.html#FixedSignExtend
    *memory.pc += ((((1U << 23) ^ get_nth_bits(opcode, 0, 24)) - (1U << 23)) << 2) + 4;
}