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
//     default functions are used when no other function matches the jumptable. this all was intended as a way 
//     to make the code cleaner and more readable.

#include <iostream>
using namespace std;

@DEFAULT()
void nop(int opcode) {
    // NOP
}

// move shifted register
@EXCLUDE(00011---)
void run_000OPABC(int opcode) {

}

// add and subtract
void run_000111OA(int opcode) {

}

// move, compare, add, and subtract immediate
void run_001OPABC(int opcode) {

}

// ALU operation
void run_010000PC(int opcode) {

}

// high register operations and branch exchange
void run_010001OP(int opcode) {

}

// pc-relative load
void run_01001REG(int opcode) {
    std::cout << opcode << std::endl;
}

// load and store with relative offset
void run_0101LB0R(int opcode) {

}

// load and store sign-extended byte and halfword
void run_0101HS1R(int opcode) {

}

// load and store with immediate offset
void run_011BLOFS(int opcode) {

}

// load and store halfword
void run_1000LOFS(int opcode) {

}

// sp-relative load and store
void run_1001LREG(int opcode) {

}

// load address
void run_1010SREG(int opcode) {

}

// add offset to stack pointer
void run_10110000(int opcode) {

}

// push and pop registers(int opcode)
void run_1011L10R(int opcode) {

}

// multiple load and store
void run_1100LREG(int opcode) {

}

// conditional branch
@EXCLUDE(11011111)
void run_1101COND(int opcode) {

}

// software interrupt
void run_11011111(int opcode) {

}

// unconditional branch
void run_11100OFS(int opcode) {

}

// long branch with link
void run_1111HOFS(int opcode) {

}