#ifndef CPU_STATE
#define CPU_STATE

#include <stdint.h>
#include "../src/memory.h"

enum CpuType { ARM, THUMB };

typedef struct CpuState {
    CpuType   type;   // either arm or thumb
    uint32_t  opcode;
    uint32_t* regs;
} CpuState;

CpuState get_cpu_state();
void set_cpu_state(CpuState cpu_state);

#endif