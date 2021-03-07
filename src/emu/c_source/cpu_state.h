#ifndef CPU_STATE
#define CPU_STATE

#include <stdint.h>

class ARM7TDMI;

enum CpuType { ARM, THUMB };

typedef struct CpuState {
    CpuType  type;   // either arm or thumb
    uint32_t opcode;
    uint32_t regs[16];
    uint32_t mode;
    uint32_t mem_0x03000003;
} CpuState;

CpuState get_cpu_state(ARM7TDMI* cpu);
void set_cpu_state(ARM7TDMI* cpu, CpuState cpu_state);

#endif