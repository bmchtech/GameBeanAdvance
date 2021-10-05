module hw.cpu.arm7tdmi;

import hw.cpu.state;
import hw.cpu.exception;
import hw.memory;

import abstracthw.cpu;
import abstracthw.memory;

import diag.logger;

import util;

import jumptable_arm;
import jumptable_thumb;

import std.stdio;
import std.conv;

version (LDC) {
    import ldc.intrinsics;
}

ulong _g_num_log              = 0;
ulong _g_cpu_cycles_remaining = 0;

__gshared bool  _g_log = false;

class ARM7TDMI : IARM7TDMI {

    Memory m_memory;

    @property IMemory memory() { return m_memory; }

    CpuMode current_mode;

    enum CPU_STATE_LOG_LENGTH = 1;
    CpuState[CPU_STATE_LOG_LENGTH] cpu_states;

    uint[2] pipeline;
    Memory.AccessType pipeline_access_type;

    uint current_instruction_size;

    this(Memory memory) {
        this.memory        = memory;

        this.regs          = new uint[18];
        this.register_file = new uint[18 * 6];

        register_file[MODE_USER.OFFSET       + 13] = 0x03007f00;
        register_file[MODE_IRQ.OFFSET        + 13] = 0x03007fa0;
        register_file[MODE_SUPERVISOR.OFFSET + 13] = 0x03007fe0;

        // the current mode
        current_mode = MODES[0];
        for (int i = 0; i < 7; i++) {
            register_file[MODES[i].OFFSET + 16] |= MODES[i].CPSR_ENCODING;
        }
        regs[0 .. 18] = register_file[MODE_USER.OFFSET .. MODE_USER.OFFSET + 18];

        pc   = &regs[15];
        lr   = &regs[14];
        sp   = &regs[13];
        cpsr = &regs[16];
        spsr = &regs[17];

        pipeline_access_type = Memory.AccessType.NONSEQUENTIAL;
        set_bit_T(false);
    }

    // returns true if the exception is accepted (or, excepted :P)
    bool exception(const CpuException exception) {
        // interrupts not allowed if the cpu itself has interrupts disabled.
        if ((exception == CpuException.IRQ && get_nth_bit(*cpsr, 7)) ||
            (exception == CpuException.FIQ && get_nth_bit(*cpsr, 6))) {
            return false;
        }

        CpuMode mode = get_mode_from_exception(exception);
        // writefln("Interrupt! Setting LR to %x", *pc);
        // writefln("Interrupt type: %s", get_exception_name(exception));
        // writefln("IF: %x", memory.read_halfword(0x4000202));

        register_file[mode.OFFSET + 14] = *pc - 2 * (get_bit_T() ? 2 : 4);
        if (exception == CpuException.IRQ) {
            // _g_num_log += 30;
            register_file[mode.OFFSET + 14] += 4; // in an IRQ, the linkage register must point to the next instruction + 4
        }

        register_file[mode.OFFSET + 17] = *cpsr;
        set_mode(mode);

        *cpsr |= (1 << 7); // disable normal interrupts

        if (exception == CpuException.Reset || exception == CpuException.FIQ) {
            *cpsr |= (1 << 6); // disable fast interrupts
        }

        *pc = get_address_from_exception(exception);
        set_bit_T(false);
        memory.can_read_from_bios = true;
        
        if (exception == CpuException.SoftwareInterrupt) {
            refill_pipeline_partial();
        } else {
            refill_pipeline();
        }


        halted = false;

        return true;
    }

    void halt() {
        halted = true;
    }

    uint get_address_from_exception(CpuException exception) {
        final switch (exception) {
            case CpuException.Reset:             return 0x0000_0000;
            case CpuException.Undefined:         return 0x0000_0004;
            case CpuException.SoftwareInterrupt: return 0x0000_0008;
            case CpuException.PrefetchAbort:     return 0x0000_000C;
            case CpuException.DataAbort:         return 0x0000_0010;
            case CpuException.IRQ:               return 0x0000_0018;
            case CpuException.FIQ:               return 0x0000_001C;
        }
    }

    CpuMode get_mode_from_exception(CpuException exception) {
        final switch (exception) {
            case CpuException.Reset:             return MODE_SUPERVISOR;
            case CpuException.Undefined:         return MODE_UNDEFINED;
            case CpuException.SoftwareInterrupt: return MODE_SUPERVISOR;
            case CpuException.PrefetchAbort:     return MODE_ABORT;
            case CpuException.DataAbort:         return MODE_ABORT;
            case CpuException.IRQ:               return MODE_IRQ;
            case CpuException.FIQ:               return MODE_FIQ;
        }
    }

    string get_exception_name(CpuException exception) {
        final switch (exception) {
            case CpuException.Reset:             return "RESET";
            case CpuException.Undefined:         return "UNDEFINED";
            case CpuException.SoftwareInterrupt: return "SWI";
            case CpuException.PrefetchAbort:     return "PREFETCH ABORT";
            case CpuException.DataAbort:         return "DATA ABORT";
            case CpuException.IRQ:               return "IRQ";
            case CpuException.FIQ:               return "FIQ";
        }
    }

    // the register array is going to be accessed as such:
    // USER | SYSTEM | SUPERVISOR | ABORT | UNDEFINED | INTERRUPT | FAST INTERRUPT
    //  r0  |   r0   |     r0     |  r0   |    r0     |    r0     |      r0
    //  r1  |   r1   |     r1     |  r1   |    r1     |    r1     |      r1
    //  r2  |   r2   |     r2     |  r2   |    r2     |    r2     |      r2
    //  r3  |   r3   |     r3     |  r3   |    r3     |    r3     |      r3
    //  r4  |   r4   |     r4     |  r4   |    r4     |    r4     |      r4
    //  r5  |   r5   |     r5     |  r5   |    r5     |    r5     |      r5
    //  r6  |   r6   |     r6     |  r6   |    r6     |    r6     |      r6
    //  r7  |   r7   |     r7     |  r7   |    r7     |    r7     |      r7
    //  r8  |   r8   |     r8     |  r8   |    r8     |    r8     |\     r8
    //  r9  |   r9   |     r9     |  r9   |    r9     |    r9     |\     r9
    //  r10 |   r10  |     r10    |  r10  |    r10    |    r10    |\     r10
    //  r11 |   r11  |     r11    |  r11  |    r11    |    r11    |\     r11
    //  r12 |   r12  |     r12    |  r12  |    r12    |    r12    |\     r12
    //  r13 |   r13  |\    r13    |\ r13  |\   r13    |\   r13    |\     r13
    //  r14 |   r14  |\    r14    |\ r14  |\   r14    |\   r14    |\     r14
    //  r15 |   r15  |     r15    |  r15  |    r15    |    r15    |      r15
    // SPSR |  CPSR  |    CPSR    |  CPSR |    CPSR   |    CPSR   |      CPSR
    // SPSR |  SPSR  |    SPSR    |  SPSR |    SPSR   |    SPSR   |      SPSR

    // note that from the official documentation, some registers are not unique and are instead
    // the same across different CPU modes. more specifically, the registers with slashes before them
    // are UNIQUE, and will not be carried over when transfering from one register to another.
    // how do we determine which registers to carry over from one mode to another when switching CPU
    // modes? well, we can create 21 different functions designed to do this... but that's ugly so
    // i'm encoding the uniqueness of the regsiters in each CPU mode in binary. refer to the definition
    // of the cpu modes above as reference. the REGISTER_UNIQUENESS field is a 18 bit integer (because
    // 18 registers) where the nth bit is a 1 if the register is not unique, and 0 otherwise. by ANDing
    // any two of these values together, we get a number that represents the shared registers between
    // any two cpu modes. this idea is represented in the following function:

    // sets the CPU mode. can be one of: MODE_USER, MODE_FIQ, MODE_IRQ, MODE_SUPERVISOR, MODE_ABORT, MODE_UNDEFINED, or MODE_SYSTEM.
    // these modes are ARM7TDMI modes that dictate how the cpu runs.
    void set_mode(const CpuMode new_mode) {
        uint mask;

        mask = current_mode.REGISTER_UNIQUENESS;
        // writeback
        for (int i = 0; i < 18; i++) {
            if (mask & 1) {
                register_file[MODE_USER   .OFFSET + i] = regs[i];
            } else {
                register_file[current_mode.OFFSET + i] = regs[i];
            }

            mask >>= 1;
        }

        mask = new_mode.REGISTER_UNIQUENESS;
        for (int i = 0; i < 18; i++) {
            if (mask & 1) {
                regs[i] = register_file[MODE_USER   .OFFSET + i];
            } else {
                regs[i] = register_file[new_mode.OFFSET + i];
            }

            mask >>= 1;
        }

        // user and system modes dont have spsr. spsr reads return cpsr.
        if (new_mode == MODE_USER || new_mode == MODE_SYSTEM) {
            spsr = cpsr;
        } else {
            spsr = &regs[17];
        }

        // bool old_bit_T = get_bit_T();
        // set_bit_T(old_bit_T);
        // writefln("Linkage: %x", register_file[new_mode.OFFSET + 14]);

        bool had_interrupts_disabled = (*cpsr >> 7) & 1;

        *cpsr = (*cpsr & 0xFFFFFFE0) | new_mode.CPSR_ENCODING;
        current_mode = new_mode;

        if (had_interrupts_disabled && (*cpsr >> 7) && memory.read_halfword(0x4000202)) {
            exception(CpuException.IRQ);
        }
    }

    // reads the CPSR and figures out what the current mode is. then, it updates it using new_mode.
    void update_mode() {
        int mode_bits = get_nth_bits(*cpsr, 0, 5);
        for (int i = 0; i < NUM_CPU_MODES; i++) {
            if (MODES[i].CPSR_ENCODING == mode_bits) {
                set_mode(MODES[i]);
            }
        }
    }

    pragma(inline, true) bool has_spsr() {
        return !(current_mode == MODE_USER || current_mode == MODE_SYSTEM);
    }

    pragma(inline, true) bool in_a_privileged_mode() {
        return current_mode != MODE_USER;
    }

    uint[] m_register_file;
    uint[] m_regs;

    @property uint[] regs() { return m_regs; }
    @property uint[] register_file() { return m_register_file; }

    uint* m_pc;
    uint* m_lr;
    uint* m_sp;
    uint* m_cpsr;
    uint* m_spsr; // not valid in USER or SYSTEM modes
    
    uint m_shifter_operand;
    bool m_shifter_carry_out;

    @property uint* pc() { return m_pc;}
    @property uint* lr() { return m_lr;}
    @property uint* sp() { return m_sp;}
    @property uint* spsr() { return m_spsr;}

    @property uint shifter_carry_out() { return m_shifter_carry_out;}
    @property uint shifter_carry_out(uint value) { return m_shifter_carry_out = value;}

    @property uint shifter_operand() { return m_shifter_operand;}
    @property uint shifter_operand(uint value) { return m_shifter_operand = value;}

    pragma(inline, true) uint read_reg(int reg) {
        // when reading register PC (15), the pipeline will cause the read value to be
        // one instruction_size greater than it should be. therefore if we're trying to
        // read from pc, we subtract the current instruction_size to accomodate for this.
        return reg == 15 ? regs[reg] - (get_bit_T() ? 2 : 4) : regs[reg];
    }

    pragma(inline, true) void write_reg(int reg, uint value) {
        regs[reg] = value;
        if (reg == 15) refill_pipeline();
    }

    // reg is [0, 7] - these are used to access only the lower regs
    pragma(inline, true) uint read_reg__lower(int reg) {
        return regs[reg];
    }

    // reg is [0, 7] - these are used to access only the lower regs
    pragma(inline, true) void write_reg__lower(int reg, uint value) {
        regs[reg] = value;
    }

    pragma(inline, true) void set_flag_N(bool condition) {
        if (condition) *cpsr |= 0x80000000;
        else           *cpsr &= 0x7FFFFFFF;
    }

    pragma(inline, true) void set_flag_Z(bool condition) {
        if (condition) *cpsr |= 0x40000000;
        else           *cpsr &= 0xBFFFFFFF;
    }

    pragma(inline, true) void set_flag_C(bool condition) {
        if (condition) *cpsr |= 0x20000000;
        else           *cpsr &= 0xDFFFFFFF;
    }

    pragma(inline, true) void set_flag_V(bool condition) {
        if (condition) *cpsr |= 0x10000000;
        else           *cpsr &= 0xEFFFFFFF;
    }

    pragma(inline, true) void set_bit_T(bool condition) {
        if (condition) *cpsr |= 0x00000020;
        else           *cpsr &= 0xFFFFFFDF;

        current_instruction_size = condition ? 2 : 4;
    }

    pragma(inline, true) bool get_flag_N() {
        return (*cpsr >> 31) & 1;
    }

    pragma(inline, true) bool get_flag_Z() {
        return (*cpsr >> 30) & 1;
    }

    pragma(inline, true) bool get_flag_C() {
        return (*cpsr >> 29) & 1;
    }

    pragma(inline, true) bool get_flag_V() {
        return (*cpsr >> 28) & 1;
    }

    pragma(inline, true) bool get_bit_T() {
        return (*cpsr >> 5) & 1;
    }

    ulong cycle() {
        if (halted) return 1;
        // writefln("1");

        // if (*pc == 0x0801E106) { _g_num_log += 1000; writefln("CPUSET");}

        // Logger.instance.capture_cpu();
        // if ( && !get_nth_bit(*cpsr, 7)) {
            // exception(CpuException.IRQ);
        // }

        _g_cpu_cycles_remaining = 0;

        uint opcode = pipeline[0];
        pipeline[0] = pipeline[1];
        pipeline[1] = fetch();

        if (*pc > 0x0FFF_FFFF) {
            error("PC out of range!");
        }

        // if (*pc == 0xC) {
        //     error("rebooting");
        // }

        if (memory.read_word(0x0300_000C) == 0x60840000) {
            writefln("something weird happened right here!!!!!");
        }

        // if (_g_log) {
        //     _g_num_log--;
        //     // write("%04x", _g_num_log);
        //     if (get_bit_T()) write("THM ");
        //     else write("ARM ");

        //     write(format("0x%x ", opcode));
            
        //     for (int j = 0; j < 16; j++)
        //         write(format("%08x ", regs[j]));

        //     // write(format("%x ", *cpsr));
        //     write(format("%x", register_file[MODE_SYSTEM.OFFSET + 17]));
        //     writeln();
        // }

        memory.can_read_from_bios = (*pc >> 24) == 0;
        execute(opcode);

        pipeline_access_type = Memory.AccessType.SEQUENTIAL;

        return _g_cpu_cycles_remaining;
    }

    uint fetch() {
        if (get_bit_T()) { // thumb mode: grab a halfword and return it
            uint opcode = cast(uint) memory.read_halfword(*pc & 0xFFFFFFFE, pipeline_access_type);
            *pc += 2;
            return opcode;
        } else {           // arm mode: grab a word and return it
            uint opcode = memory.read_word(*pc & 0xFFFFFFFC, pipeline_access_type);
            *pc += 4;
            return opcode;
        }
    }

    void execute(uint opcode) {
        if (get_bit_T()) {
            jumptable_thumb.jumptable[opcode >> 8](this, cast(ushort)opcode);
        } else {
            jumptable_arm.execute_instruction(opcode, this);
        }
    }

    void enable() {
        halted = false;
    }

    void disable() {
        halted = true;
    }

    void refill_pipeline() {
        memory.can_read_from_bios = (*pc >> 24) == 0;

        pipeline[0] = fetch();
        pipeline[1] = fetch();

        pipeline_access_type = Memory.AccessType.NONSEQUENTIAL;
    }

    pragma(inline, true) void refill_pipeline_partial() {
        refill_pipeline();
    }

    pragma(inline, true)
    
    pragma(inline) uint ASR(uint value, ubyte shift) {
        if ((value >> 31) == 1) {
            // breakdown of this formula:
            // value >> 31                                                         : the most significant bit
            // (value >> 31) << shift)                                             : the most significant bit, but shifted "shift" times
            // ((((value >> 31) << shift) - 1)                                     : the most significant bit, but repeated "shift" times
            // ((((value >> 31) << shift) - 1) << (32 - shift))                    : basically this value is the mask that turns the logical 
            //                                                                     : shift to an arithmetic shift
            // ((((value >> 31) << shift) - 1) << (32 - shift)) | (value >> shift) : the arithmetic shift
            return (((1 << shift) - 1) << (32 - shift)) | (value >> shift);
        } else {
            return value >> shift;
        }
    }

    pragma(inline) uint LSL(uint value, ubyte shift) {
        return value << shift;
    }

    pragma(inline) uint LSR(uint value, ubyte shift) {
        return value >> shift;
    }

    pragma(inline) uint ROR(uint value, ubyte shift) {
        uint rotated_off = get_nth_bits(value, 0,     shift);  // the value that is rotated off
        uint rotated_in  = get_nth_bits(value, shift, 32);     // the value that stays after the rotation
        return rotated_in | (rotated_off << (32 - shift));
    }

    pragma(inline) uint RRX(ARM7TDMI cpu, uint value, uint shift) {
        uint rotated_off = get_nth_bits(value, 0,     shift - 1);  // the value that is rotated off
        uint rotated_in  = get_nth_bits(value, shift, 32);         // the value that stays after the rotation

        uint result = rotated_in | (rotated_off << (32 - shift)) | (cpu.get_flag_C() << (32 - shift + 1));
        cpu.set_flag_C(get_nth_bit(value, shift));
        return result;
    }

    // an explanation of these constants is partially in here as well as cpu-mode.h

    static CpuMode[NUM_CPU_MODES] MODES = [
        MODE_USER, MODE_FIQ, MODE_IRQ, MODE_SUPERVISOR, MODE_ABORT, MODE_UNDEFINED,
        MODE_SYSTEM
    ];

    bool halted = false;

private:
    uint cpu_states_size = 0;
    bool enable_pc_checking = false;
    int setup_cycles = 200000;
}
