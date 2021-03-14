#ifndef CPUMODE_H
#define CPUMODE_H

// CPU modes will be described as the following:
// 1) their encoding in the CPSR register
// 2) their register uniqueness (see the diagram in arm7tdmi.h).
// 3) their offset into the registers array.

struct CpuMode {
    constexpr CpuMode():
        CPSR_ENCODING(0),
        REGISTER_UNIQUENESS(0),
        OFFSET(0) {}

    constexpr CpuMode(const int c, const int r, const int o):
        CPSR_ENCODING(c),
        REGISTER_UNIQUENESS(r),
        OFFSET(o) {}

    int CPSR_ENCODING;
    int REGISTER_UNIQUENESS;  
    int OFFSET;
};

#endif