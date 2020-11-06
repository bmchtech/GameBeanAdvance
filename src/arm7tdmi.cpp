#include "arm7tdmi.h"
#include "memory.h"
#include "util.h"
#include "jumptable/jumptable-thumb.h"
#include "jumptable/jumptable-arm.h"

#include <iostream>

ARM7TDMI::ARM7TDMI(Memory* memory) {
    this->memory = memory;       
    
    // 16 registers * 6 CPU modes
    register_file = new uint32_t[NUM_REGISTERS * 6]();
    regs = register_file;
    current_mode = MODE_USER;

    // the program status register
    cpsr = 0x00000000;
    spsr = 0x00000000;
}

ARM7TDMI::~ARM7TDMI() {
    delete[] register_file;
}

void ARM7TDMI::cycle() {
    execute(fetch());
}

uint32_t ARM7TDMI::fetch() {
    if (get_bit_T()) { // thumb mode: grab a halfword and return it
        uint16_t opcode = *((uint16_t*)(memory->main + (*pc & 0xFFFFFFFE)));
        *pc += 2;
        return opcode;
    } else {           // arm mode: grab a word and return it
        uint32_t opcode = *((uint32_t*)(memory->main + (*pc & 0xFFFFFFFE)));
        *pc += 4;
        return opcode;
    }
}

void ARM7TDMI::execute(uint32_t opcode) {
    if (get_bit_T()) {
        jumptable_thumb[opcode >> 8](this, opcode);
    } else {
        if (should_execute((opcode & 0xF0000000) >> 28)) {
            jumptable_arm[opcode >> 20](this, opcode);
        }
    }
}

// determines whether or not this function should execute based on COND (the high 4 bits of the opcode)
// note that this only applies to ARM instructions.
bool ARM7TDMI::should_execute(int cond) {
    if (cond == 0b1110) [[likely]] {
        return true;
    }

    switch (cond) {
        case 0b0000: return  get_flag_Z(); break;
        case 0b0001: return !get_flag_Z(); break;
        case 0b0010: return  get_flag_C(); break;
        case 0b0011: return !get_flag_C(); break;
        case 0b0100: return  get_flag_N(); break;
        case 0b0101: return !get_flag_N(); break;
        case 0b0110: return  get_flag_V(); break;
        case 0b0111: return !get_flag_V(); break;
        case 0b1000: return  get_flag_C() && !get_flag_Z(); break;
        case 0b1001: return !get_flag_C() ||  get_flag_Z(); break;
        case 0b1010: return  get_flag_N() ==  get_flag_V(); break;
        case 0b1011: return  get_flag_N() !=  get_flag_V(); break;
        case 0b1100: return !get_flag_Z() &&  (get_flag_N() == get_flag_V()); break;
        case 0b1101: return  get_flag_Z() &&  (get_flag_N() != get_flag_V()); break;
        default:     return false;
    }
}