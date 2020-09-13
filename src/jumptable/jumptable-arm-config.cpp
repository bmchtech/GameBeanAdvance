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

@DEFAULT()
void nop(uint32_t opcode) {
    DEBUG_MESSAGE("NOP");
}


// ADC / UMLAL instruction
@EXCLUDE(1111------------)
void run_WXYZ00I0101S(uint32_t opcode) {

}

// ADD / UMULL instruction
@EXCLUDE(1111------------)
void run_WXYZ00I0100S(uint32_t opcode) {

}

// AND / MUL instruction
@EXCLUDE(1111------------)
void run_WXYZ00I0000S(uint32_t opcode) {

}

// B, BL instructions
@EXCLUDE(1111------------)
void run_WXYZ101LABCD(uint32_t opcode) {

}

// BIC instruction
@EXCLUDE(1111------------)
void run_WXYZ00I1110S(uint32_t opcode) {

}

// CDP / MCR / MRC instructions
@EXCLUDE(1111------------)
void run_WXYZ1110OPCD(uint32_t opcode) {

}

// CMN instruction
@EXCLUDE(1111------------)
void run_WXYZ00I10111(uint32_t opcode) {

}

// CMP instruction
@EXCLUDE(1111------------)
void run_WXYZ00I10101(uint32_t opcode) {

}

// CPS instruction
// note: this instruction requires the COND to be 1111.
void run_111100010000(uint32_t opcode) {

}

// LDC instruction. we won't use a coprocessor, so this should generate
// an Undefined Instruction exception. also WXYZ is AXYZ here because W 
// is an important bit-variable. see comment at top of file for more info
// about WXYZ
@EXCLUDE(1111------------)
void run_AXYZ110PUNW1(uint32_t opcode) {

}

// LDM #1 instruction
// WXYZ is AXYZ here because W  is an important bit-variable. see comment 
// at top of file for more info about WXYZ
@EXCLUDE(1111------------)
void run_AXYZ100PU0W1(uint32_t opcode) {

}

// LDM #2 / #3 instruction
// #2 has bit 15 clear, #3 has bit 15 set.
@EXCLUDE(1111------------)
void run_WXYZ100PU101(uint32_t opcode) {

}

// LDR / LDRT instruction
// WXYZ is AXYZ here because W  is an important bit-variable. see comment 
// at top of file for more info about WXYZ
@EXCLUDE(1111------------)
void run_AXYZ01IPU0W1(uint32_t opcode) {

}

// LDRB / LDRBT instruction
// WXYZ is AXYZ here because W  is an important bit-variable. see comment 
// at top of file for more info about WXYZ
@EXCLUDE(1111------------)
void run_AXYZ01IPU1W1(uint32_t opcode) {

}

// LDRH / LDRSB / LDRSH instructions
// LDRH  is run when opcode[4:7] == 0b1011
// LDRSB is run when opcode[4:7] == 0b1101
// LDRSH Is run when opcode[4:7] == 0b1111
// WXYZ is AXYZ here because W  is an important bit-variable. see comment 
// at top of file for more info about WXYZ
@EXCLUDE(1111------------)
@EXCLUDE(----00010101----)
@EXCLUDE(----00010111----)
@EXCLUDE(----0001110-----)
@EXCLUDE(----0001111-----)
@EXCLUDE(----0000011-----)
@EXCLUDE(----0000111-----)
@EXCLUDE(----0000110-----)
@EXCLUDE(----0000010-----)
void run_AXYZ000PU1W1(uint32_t opcode) {

}

// EOR / MLA instruction
@EXCLUDE(1111------------)
void run_WXYZ0000001S(uint32_t opcode) {

}

// MOV instruction. opcode[16:19] should be 0, but the hardware doesn't
// explicitly check this, so neither will the we.
@EXCLUDE(1111------------)
void run_WXYZ00I1101S(uint32_t opcode) {

}

// MSR instruction
@EXCLUDE(1111------------)
@EXCLUDE(----000--1-0----)
void run_WXYZ00S10R10(uint32_t opcode) {

}

// MVN instruction. opcode[16:19] should be 0, but the hardware doesn't
// explicitly check this, so neither will the we.
@EXCLUDE(1111------------)
void run_WXYZ00I1111S(uint32_t opcode) {

}

// ORR instruction
@EXCLUDE(1111------------)
void run_WXYZ00I1100S(uint32_t opcode) {

}

// RSC / SMLAL instruction
@EXCLUDE(1111------------)
void run_WXYZ00I0111S(uint32_t opcode) {

}

// SBC / SMULL instruction
@EXCLUDE(1111------------)
void run_WXYZ00I0110S(uint32_t opcode) {

}

// STC instruction. we won't use a coprocessor, so this should generate
// an Undefined Instruction exception.
// WXYZ is AXYZ here because W  is an important bit-variable. see comment 
// at top of file for more info about WXYZ
@EXCLUDE(1111------------)
void run_AXYZ110PUNW0(uint32_t opcode) {

}

// STM #1 instruction
// WXYZ is AXYZ here because W  is an important bit-variable. see comment 
// at top of file for more info about WXYZ
@EXCLUDE(1111------------)
void run_AXYZ100PU0W0(uint32_t opcode) {

}

// STM #2 instruction
@EXCLUDE(1111------------)
void run_WXYZ100PU100(uint32_t opcode) {

}

// STR / STRT instruction
// WXYZ is AXYZ here because W  is an important bit-variable. see comment 
// at top of file for more info about WXYZ
@EXCLUDE(1111------------)
void run_AXYZ01IPU0W0(uint32_t opcode) {

}

// STRB / STRBT instruction
// WXYZ is AXYZ here because W  is an important bit-variable. see comment 
// at top of file for more info about WXYZ
@EXCLUDE(1111------------)
void run_AXYZ01IPU1W0(uint32_t opcode) {

}

// STRH / RSB / MRS instruction
// WXYZ is AXYZ here because W  is an important bit-variable. see comment 
// at top of file for more info about WXYZ
@EXCLUDE(1111------------)
@EXCLUDE(----00-10-10----)
@EXCLUDE(----00-0110-----)
@EXCLUDE(----00-0111-----)
@EXCLUDE(----00-0010-----)
@EXCLUDE(----00-1110-----)
@EXCLUDE(----00-1111-----)
@EXCLUDE(----00-1010-----)
void run_AXYZ000PU1W0(uint32_t opcode) {

}

// SUB instruction
@EXCLUDE(1111------------)
void run_WXYZ00I0010S(uint32_t opcode) {

}

// SWI instruction
@EXCLUDE(1111------------)
void run_WXYZ1111ABCD(uint32_t opcode) {

}

// SWP instruction
@EXCLUDE(1111------------)
void run_WXYZ00010000(uint32_t opcode) {

}

// SWPB instruction
@EXCLUDE(1111------------)
void run_WXYZ00010100(uint32_t opcode) {

}

// TEQ instruction
@EXCLUDE(1111------------)
void run_WXYZ00I10011(uint32_t opcode) {

}

// TST instruction
@EXCLUDE(1111------------)
void run_WXYZ00I10001(uint32_t opcode) {

}