#ifndef CPU_STATE
#define CPU_STATE

#include <stdint.h>
#include "../src/memory.h"
#include "../src/arm7tdmi.h"

enum CpuType { ARM, THUMB };

typedef struct CpuState {
    CpuType  type;   // either arm or thumb
    uint32_t opcode;
    uint32_t regs[16];
} CpuState;

CpuState get_cpu_state(ARM7TDMI* cpu);
void set_cpu_state(ARM7TDMI* cpu, CpuState cpu_state);

#endif