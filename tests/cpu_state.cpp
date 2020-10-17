#include "cpu_state.h"
#include "../src/memory.h"

#include <iostream>

void set_cpu_state(ARM7TDMI* cpu, CpuState cpu_state) {
    for (int i = 0; i < 16; i++) {
        cpu->memory->regs[i] = cpu_state.regs[i];
    }
}

CpuState get_cpu_state(ARM7TDMI* cpu) {
    CpuState cpu_state;
    cpu_state.type   = cpu->memory->get_bit_T() ? THUMB : ARM;
    cpu_state.opcode = cpu->memory->get_bit_T() ? *((uint16_t*)(cpu->memory->main + *cpu->memory->pc)) : *((uint32_t*)(cpu->memory->main + *cpu->memory->pc));
    cpu_state.regs = new uint32_t[16];
        
    for (int i = 0; i < 16; i++) {
        cpu_state.regs[i] = cpu->memory->regs[i];
    }

    return cpu_state;
}