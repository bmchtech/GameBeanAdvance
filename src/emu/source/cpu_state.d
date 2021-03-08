module cpu_state;

import core.stdc.stdint; //uint32_t 
import arm7tdmi;

enum CpuType {
    ARM,
    THUMB,
}

struct CpuState {
    CpuType type;
    uint32_t opcode;
    uint32_t[16] regs;
    uint32_t mode;
    uint32_t mem_0x03000003;
}

CpuState get_cpu_state(ARM7TDMI cpu);
void set_cpu_state(ARM7TDMI cpu, CpuState cpu_state);
