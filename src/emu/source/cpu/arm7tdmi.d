module cpu.arm7tdmi;

import cpu.mode;
import cpu.state;
import cpu.exception;
import memory;
import util;
import logger;

import jumptable_arm;
import jumptable_thumb;

import std.stdio;
import std.conv;

version (LDC) {
    import ldc.intrinsics;
}

ulong num_log = 0;

enum CPU_STATE_LOG_LENGTH = 1;

long num_arm = 0;
long num_thm = 0;

class ARM7TDMI {

    Memory memory;

    uint cycles_remaining = 0;
    CpuMode current_mode;
    CpuState[CPU_STATE_LOG_LENGTH] cpu_states;

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

        register_file[mode.OFFSET + 14] = *pc;
        if (exception == CpuException.IRQ) {
            // num_log += 30;
            register_file[mode.OFFSET + 14] += 4; // in a SWI, the linkage register must point to the next instruction + 4
        }

        register_file[mode.OFFSET + 17] = *cpsr;
        set_mode(mode);

        *cpsr |= (1 << 7); // disable normal interrupts

        if (exception == CpuException.Reset || exception == CpuException.FIQ) {
            *cpsr |= (1 << 6); // disable fast interrupts
        }

        if (exception == CpuException.SoftwareInterrupt) {
            memory.open_bus_bios_state = Memory.OpenBusBiosState.AFTER_SWI;
        }

        if (exception == CpuException.IRQ) {
            memory.open_bus_bios_state = Memory.OpenBusBiosState.DURING_IRQ;
        }

        *pc = get_address_from_exception(exception);

        halted = false;
        set_bit_T(false);

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
    pragma(inline) void set_mode(const CpuMode new_mode) {
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
        for (int i = 0; i < NUM_MODES; i++) {
            if (MODES[i].CPSR_ENCODING == mode_bits) {
                set_mode(MODES[i]);
            }
        }
    }

    uint[] register_file;
    uint[] regs;

    uint* pc;
    uint* lr;
    uint* sp;
    uint* cpsr;
    uint* spsr; // not valid in USER or SYSTEM modes
    
    uint shifter_operand;
    bool shifter_carry_out;

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

    int cycle() {
        if (halted) return 1;
        // writefln("1");

        cycles_remaining = 1;

        // if (*pc == 0x0800_06f8) num_log += 100;

        // Logger.instance.capture_cpu();

        if (*pc > 0x0FFF_FFFF) {
            error("PC out of range!");
        }

        // if ( && !get_nth_bit(*cpsr, 7)) {
            // exception(CpuException.IRQ);
        // }

        // bios open bus handling
        // if (*pc == 0x0000_00134) memory.open_bus_bios_state = Memory.OpenBusBiosState.DURING_IRQ;
        // if (*pc == 0x0000_0013C) memory.open_bus_bios_state = Memory.OpenBusBiosState.AFTER_IRQ;
        memory.can_read_from_bios = (*pc >> 24) == 0;

        uint opcode = fetch();
        if (num_log > 0) {
            num_log--;
            if (get_bit_T()) write("THM ");
            else write("ARM ");

            write(format("0x%x ", opcode));
            
            for (int j = 0; j < 15; j++)
                write(format("%x ", regs[j]));

            if (get_bit_T()) write(format("%x ", regs[15] + 2));
            else write(format("%x ", regs[15] + 4));

            write(format("%x", memory.read_byte(0x0300_0003)));
            writeln();
        }

        execute(opcode);

        return cycles_remaining * 2;
    }

    uint fetch() {
        if (get_bit_T()) { // thumb mode: grab a halfword and return it
            uint opcode = cast(uint) memory.Aligned!(ushort).read(*pc & 0xFFFFFFFE);
            *pc += 2;
            return opcode;
        } else {           // arm mode: grab a word and return it
            uint opcode = memory.Aligned!(uint).read(*pc & 0xFFFFFFFC);
            *pc += 4;
            return opcode;
        }
    }

    void execute(uint opcode) {
            // write(format("%08x |", opcode));
            
            // for (int j = 0; j < 16; j++)
            //     write(format("%08x ", regs[j]));

            // writeln();
        if (get_bit_T()) {
            num_thm++;
            jumptable_thumb.jumptable[opcode >> 8](this, cast(ushort)opcode);
        } else {
            num_arm++;
            jumptable_arm.execute_instruction(opcode, this);
        }
    }

    void enable() {
        halted = false;
    }

    void disable() {
        halted = true;
    }
    
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

    enum MODE_USER       = CpuMode(0b10000, 0b011111111111111111, 18 * 0);
    enum MODE_SYSTEM     = CpuMode(0b11111, 0b011111111111111111, 18 * 0);
    enum MODE_SUPERVISOR = CpuMode(0b10011, 0b011001111111111111, 18 * 1);
    enum MODE_ABORT      = CpuMode(0b10111, 0b011001111111111111, 18 * 2);
    enum MODE_UNDEFINED  = CpuMode(0b11011, 0b011001111111111111, 18 * 3);
    enum MODE_IRQ        = CpuMode(0b10010, 0b011001111111111111, 18 * 4);
    enum MODE_FIQ        = CpuMode(0b10001, 0b011000000011111111, 18 * 5);

    enum NUM_MODES = 7;
    static CpuMode[NUM_MODES] MODES = [
        MODE_USER, MODE_FIQ, MODE_IRQ, MODE_SUPERVISOR, MODE_ABORT, MODE_UNDEFINED,
        MODE_SYSTEM
    ];

    bool halted = false;

private:
    uint cpu_states_size = 0;
    bool enable_pc_checking = false;
    int setup_cycles = 200000;
}
