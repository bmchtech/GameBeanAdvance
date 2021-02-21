#include "arm7tdmi.h"
#include "memory.h"
#include "util.h"
#include "jumptable/jumptable-thumb.h"
#include "jumptable/jumptable-arm.h"

#include "../tests/cpu_state.h"

#include <iostream>

ARM7TDMI::ARM7TDMI(Memory* memory) {
    this->memory = memory;       
    
    // 16 registers * 6 CPU modes
    register_file = new uint32_t[16 * 7]();
    regs          = register_file;

    regs[MODE_USER.OFFSET       + 13] = 0x03007f00;
    regs[MODE_IRQ.OFFSET        + 13] = 0x03007fa0;
    regs[MODE_SUPERVISOR.OFFSET + 13] = 0x03007fe0;

    // the program status register
    cpsr = 0x00000000;
    spsr = 0x00000000;

    // the current mode
    current_mode = ARM7TDMI::MODES[0];
    set_mode(ARM7TDMI::MODE_USER);
}

ARM7TDMI::~ARM7TDMI() {
    delete[] register_file;
}

void ARM7TDMI::cycle() {
    uint32_t opcode = fetch();

#ifndef RELEASE
    if (cpu_states_size < CPU_STATE_LOG_LENGTH) {
        cpu_states[cpu_states_size] = get_cpu_state(this);
        cpu_states_size++;
    } else {
        for (int i = 0; i < CPU_STATE_LOG_LENGTH - 1; i++) {
            cpu_states[i] = cpu_states[i + 1];
        }
        cpu_states[CPU_STATE_LOG_LENGTH - 1] = get_cpu_state(this);
    }
#endif

    execute(opcode);
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
            arm::execute_instruction(opcode, this);
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

void ARM7TDMI::update_mode() {
    int mode_bits = get_nth_bits(cpsr, 0, 5);
    for (int i = 0; i < ARM7TDMI::NUM_MODES; i++) {
        if (ARM7TDMI::MODES[i].CPSR_ENCODING == mode_bits) {
            set_mode(ARM7TDMI::MODES[i]);
        }
    }
}