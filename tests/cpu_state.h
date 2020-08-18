#ifndef CPU_STATE
#define CPU_STATE

#include <stdint.h>

enum CpuType { ARM, THUMB };

typedef struct CpuState {
    CpuType   type;   // either arm or thumb
    uint32_t  opcode;
    uint32_t* regs;
} CpuState;

#endif