#include "cpu_state.h"
#include "../src/memory.h"

#include <iostream>

extern Memory memory;

void set_cpu_state(CpuState cpu_state) {
    for (int i = 0; i < 16; i++) {
        memory.regs[i] = cpu_state.regs[i];
    }
    memory.regs[15] = memory.regs[15];
}

CpuState get_cpu_state() {
    CpuState cpu_state;
    cpu_state.type   = THUMB;
    cpu_state.opcode = *((uint16_t*)(memory.main + *memory.pc));
    cpu_state.regs = new uint32_t[16];
        
    for (int i = 0; i < 16; i++) {
        std::cout << std::to_string(i) << std::endl;
        cpu_state.regs[i] = memory.regs[i];
    }

    return cpu_state;
}