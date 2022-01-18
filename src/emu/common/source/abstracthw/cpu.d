module abstracthw.cpu;

import std.stdio;
import abstracthw.memory;

import std.meta;
import util;

alias pc = Alias!15;
alias lr = Alias!14;
alias sp = Alias!13;

alias Reg = int;

enum Flag {
    N = 31,
    Z = 30,
    C = 29,
    V = 28,
    T = 5
}

interface IARM7TDMI {
    Word           get_reg(int i);
    void           set_reg(int i, Word value);
    Word           get_cpsr();
    InstructionSet get_instruction_set();
    Word           get_pipeline_entry(int i);
    bool           check_cond(uint cond);
    void           refill_pipeline();
    void           set_flag(Flag flag, bool value);
    bool           get_flag(Flag flag);

    Word           read_word(Word address, AccessType access_type);
    Half           read_half(Word address, AccessType access_type);
    Byte           read_byte(Word address, AccessType access_type);

    void           write_word(Word address, Word value, AccessType access_type);
    void           write_half(Word address, Half value, AccessType access_type);
    void           write_byte(Word address, Byte value, AccessType access_type);

    void           run_idle_cycle();
    void           set_pipeline_access_type(AccessType access_type);

}

// CPU modes will be described as the following:
// 1) their encoding in the CPSR register
// 2) their register uniqueness (see the diagram in arm7tdmi.h).
// 3) their offset into the registers array.

enum MODE_USER = CpuMode(0b10000, 0b011111111111111111, 18 * 0);
enum MODE_SYSTEM = CpuMode(0b11111, 0b011111111111111111, 18 * 0);
enum MODE_SUPERVISOR = CpuMode(0b10011, 0b011001111111111111, 18 * 1);
enum MODE_ABORT = CpuMode(0b10111, 0b011001111111111111, 18 * 2);
enum MODE_UNDEFINED = CpuMode(0b11011, 0b011001111111111111, 18 * 3);
enum MODE_IRQ = CpuMode(0b10010, 0b011001111111111111, 18 * 4);
enum MODE_FIQ = CpuMode(0b10001, 0b011000000011111111, 18 * 5);

enum NUM_CPU_MODES = 7;

enum InstructionSet {
    ARM,
    THUMB
}

struct CpuMode {
    this(const(int) c, const(int) r, const(int) o) {
        CPSR_ENCODING = c;
        REGISTER_UNIQUENESS = r;
        OFFSET = o;
    }

    int CPSR_ENCODING;
    int REGISTER_UNIQUENESS;
    int OFFSET;
}

enum CpuException {
    Reset,
    Undefined,
    SoftwareInterrupt,
    PrefetchAbort,
    DataAbort,
    IRQ,
    FIQ
}

struct CpuState {
    InstructionSet instruction_set;
    uint opcode;
    uint[16] regs;
    uint mode;
    uint mem_0x03000003;
}

CpuState get_cpu_state(IARM7TDMI cpu) {
    CpuState cpu_state;
    cpu_state.instruction_set = cpu.get_instruction_set();
    cpu_state.opcode = cpu.get_pipeline_entry(0);
    cpu_state.mode = cpu.get_cpsr();
    // cpu_state.mem_0x03000003 = memory.read_byte(0x03000003);

    for (int i = 0; i < 16; i++) {
        cpu_state.regs[i] = cpu.get_reg(i);
    }

    cpu_state.regs[15] -= cpu_state.instruction_set == InstructionSet.ARM ? 4 : 2;

    return cpu_state;
}

void set_cpu_state(IARM7TDMI cpu, IMemory memory, CpuState cpu_state) {
    for (int i = 0; i < 16; i++) {
        cpu.set_reg(i, cpu_state.regs[i]);
    }

    // *cpu.cpsr = (*cpu.cpsr & 0xFFFFFFE0) | (cpu_state.mode & 0x1F);
    // cpu.update_mode();

    memory.write_byte(cast(uint) 0x03000003, cast(ubyte) cpu_state.mem_0x03000003);
}
