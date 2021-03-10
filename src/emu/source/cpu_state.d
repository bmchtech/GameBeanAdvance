module cpu_state;

import arm7tdmi;

import std.stdio;

enum CpuType {
    ARM,
    THUMB,
}

struct CpuState {
    CpuType type;
    uint opcode;
    uint[16] regs;
    uint mode;
    uint mem_0x03000003;
}

CpuState get_cpu_state(ARM7TDMI cpu) {
    CpuState cpu_state;
    cpu_state.type           = cpu.get_bit_T() ? CpuType.THUMB : CpuType.ARM;
    cpu_state.opcode         = cpu.get_bit_T() ? cpu.memory.read_halfword(*cpu.pc) : cpu.memory.read_word(*cpu.pc);
    cpu_state.mode           = cpu.cpsr;
    cpu_state.mem_0x03000003 = cpu.memory.read_byte(0x03000003);

    for (int i = 0; i < 16; i++) {
        cpu_state.regs[i] = cpu.regs[i];
    }

    return cpu_state;
}

void set_cpu_state(ARM7TDMI cpu, CpuState cpu_state) {
    for (int i = 0; i < 16; i++) {
        cpu.regs[i] = cpu_state.regs[i];
    }

    cpu.cpsr = (cpu.cpsr & 0xFFFFFFE0) | (cpu_state.mode & 0x1F);
    cpu.update_mode();

    cpu.memory.write_byte(cast(uint) 0x03000003, cast(ubyte) cpu_state.mem_0x03000003);
}
