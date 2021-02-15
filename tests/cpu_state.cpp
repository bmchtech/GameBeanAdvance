#include "cpu_state.h"
#include "../src/memory.h"

#include <iostream>

void set_cpu_state(ARM7TDMI* cpu, CpuState cpu_state) {
    for (int i = 0; i < 16; i++) {
        cpu->regs[i] = cpu_state.regs[i];
    }

    cpu->cpsr = (cpu->cpsr & 0xFFFFFFE0) | (cpu_state.mode & 0x1F);
    cpu->update_mode();

    cpu->memory->write_byte(0x03000003, cpu_state.mem_0x03000003);
}

CpuState get_cpu_state(ARM7TDMI* cpu) {
    CpuState cpu_state;
    cpu_state.type           = cpu->get_bit_T() ? THUMB : ARM;
    cpu_state.opcode         = cpu->get_bit_T() ? *((uint16_t*)(cpu->memory->main + *cpu->pc)) : *((uint32_t*)(cpu->memory->main + *cpu->pc));
    cpu_state.mode           = cpu->cpsr;
    cpu_state.mem_0x03000003 = cpu->memory->read_byte(0x03000003);

    for (int i = 0; i < 16; i++) {
        cpu_state.regs[i] = cpu->regs[i];
    }

    return cpu_state;
}