module abstracthw.cpu;

import std.stdio;
import abstracthw.memory;

interface IARM7TDMI {
    uint read_reg(int reg);
    void write_reg(int reg, uint value);
    uint read_reg__lower(int reg);
    void write_reg__lower(int reg, uint value);
    void set_flag_N(bool condition);
    void set_flag_Z(bool condition);
    void set_flag_C(bool condition);
    void set_flag_V(bool condition);
    void set_bit_T(bool condition);
    bool get_flag_N();
    bool get_flag_Z();
    bool get_flag_C();
    bool get_flag_V();
    bool get_bit_T();

    uint LSL(uint value, ubyte shift);
    uint LSR(uint value, ubyte shift);
    uint ROR(uint value, ubyte shift);
    uint ASR(uint value, ubyte shift);

    void refill_pipeline();
    void update_mode();
    bool in_a_privileged_mode();
    bool has_spsr();
    void run_idle_cycle();

    bool exception(const CpuException exception);

    @property uint[2] pipeline();
    @property AccessType pipeline_access_type();
    @property AccessType pipeline_access_type(AccessType access_type);

    @property uint* pc();
    @property uint* lr();
    @property uint* sp();
    @property uint* cpsr();
    @property uint* spsr();

    @property uint shifter_operand();
    @property uint shifter_operand(uint value);
    @property bool shifter_carry_out();
    @property bool shifter_carry_out(bool value);

    @property uint[] register_file();
    @property uint[] regs();
    @property IMemory memory();
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

CpuState get_cpu_state(IARM7TDMI cpu) {
    CpuState cpu_state;
    cpu_state.type = cpu.get_bit_T() ? CpuType.THUMB : CpuType.ARM;
    cpu_state.opcode = cpu.pipeline[0];
    cpu_state.mode = *cpu.cpsr;
    cpu_state.mem_0x03000003 = 0; //cpu.memory.read_byte(0x03000003);

    for (int i = 0; i < 16; i++) {
        cpu_state.regs[i] = cpu.regs[i];
    }

    cpu_state.regs[15] -= cpu.get_bit_T() ? 4 : 8;

    return cpu_state;
}

void set_cpu_state(IARM7TDMI cpu, CpuState cpu_state) {
    for (int i = 0; i < 16; i++) {
        cpu.regs[i] = cpu_state.regs[i];
    }

    // *cpu.cpsr = (*cpu.cpsr & 0xFFFFFFE0) | (cpu_state.mode & 0x1F);
    // cpu.update_mode();

    cpu.memory.write_byte(cast(uint) 0x03000003, cast(ubyte) cpu_state.mem_0x03000003);
}
