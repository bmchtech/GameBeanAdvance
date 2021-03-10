module arm7tdmi;

import cpu_mode;
import cpu_state;
import memory;
import util;

import jumptable_arm;
import jumptable_thumb;

import std.stdio;
import std.conv;

enum CPU_STATE_LOG_LENGTH = 1;

class ARM7TDMI {
    // an explanation of these constants is partially in here as well as cpu-mode.h

    enum MODE_USER       = CpuMode(0b10000, 0b1111111111111111, 16 * 0);
    enum MODE_SYSTEM     = CpuMode(0b11111, 0b1111111111111111, 16 * 1);
    enum MODE_SUPERVISOR = CpuMode(0b10011, 0b1001111111111111, 16 * 2);
    enum MODE_ABORT      = CpuMode(0b10111, 0b1001111111111111, 16 * 3);
    enum MODE_UNDEFINED  = CpuMode(0b11011, 0b1001111111111111, 16 * 4);
    enum MODE_IRQ        = CpuMode(0b10010, 0b1001111111111111, 16 * 5);
    enum MODE_FIQ        = CpuMode(0b10001, 0b1000000011111111, 16 * 6);

    enum NUM_MODES = 7;
    static CpuMode[NUM_MODES] MODES = [
        MODE_USER, MODE_FIQ, MODE_IRQ, MODE_SUPERVISOR, MODE_ABORT, MODE_UNDEFINED,
        MODE_SYSTEM
    ];
    
    this(Memory memory) {
        this.memory        = memory;
        this.regs          = new uint[16];
        this.register_file = new uint[16 * 7];

        register_file[MODE_USER.OFFSET       + 13] = 0x03007f00;
        register_file[MODE_IRQ.OFFSET        + 13] = 0x03007fa0;
        register_file[MODE_SUPERVISOR.OFFSET + 13] = 0x03007fe0;

        // the program status register
        cpsr = 0x00000000;
        spsr = 0x00000000;

        // the current mode
        current_mode = MODES[0];
        set_mode(MODE_USER);
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

    // note that from the official documentation, some registers are not unique and are instead
    // the same across different CPU modes. more specifically, the registers with slashes before them
    // are UNIQUE, and will not be carried over when transfering from one register to another.
    // how do we determine which registers to carry over from one mode to another when switching CPU
    // modes? well, we can create 21 different functions designed to do this... but that's ugly so
    // i'm encoding the uniqueness of the regsiters in each CPU mode in binary. refer to the definition
    // of the cpu modes above as reference. the REGISTER_UNIQUENESS field is a 16 bit integer (because
    // 16 registers) where the nth bit is a 1 if the register is not unique, and 0 otherwise. by ANDing
    // any two of these values together, we get a number that represents the shared registers between
    // any two cpu modes. this idea is represented in the following function:

    // sets the CPU mode. can be one of: MODE_USER, MODE_FIQ, MODE_IRQ, MODE_SUPERVISOR, MODE_ABORT, MODE_UNDEFINED, or MODE_SYSTEM.
    // these modes are ARM7TDMI modes that dictate how the cpu runs.
    pragma(inline) void set_mode(const CpuMode new_mode) {
        int mask = current_mode.REGISTER_UNIQUENESS & new_mode.REGISTER_UNIQUENESS;

        register_file[current_mode.OFFSET .. current_mode.OFFSET + 16] = regs[0 .. 16];

        for (int i = 0; i < 16; i++) {
            if (mask & 1) {
                register_file[i + new_mode.OFFSET] = register_file[i + current_mode.OFFSET];
            }

            mask >>= 1;
        }

        current_mode = new_mode;
        cpsr = (cpsr & 0xFFFFFFE0) | new_mode.CPSR_ENCODING;

        // assert(0);
        regs[0 .. 16] = register_file[current_mode.OFFSET .. current_mode.OFFSET + 16];
        pc = &regs[15];
        lr = &regs[14];
        sp = &regs[13];
    }

    // reads the CPSR and figures out what the current mode is. then, it updates it using new_mode.
    void update_mode() {
        int mode_bits = get_nth_bits(cpsr, 0, 5);
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
    
    uint cpsr;
    uint spsr;
    uint shifter_operand;
    bool shifter_carry_out;

    pragma(inline) void set_flag_N(bool condition) {
        if (condition) cpsr |= 0x80000000;
        else           cpsr &= 0x7FFFFFFF;
    }

    pragma(inline) void set_flag_Z(bool condition) {
        if (condition) cpsr |= 0x40000000;
        else           cpsr &= 0xBFFFFFFF;
    }

    pragma(inline) void set_flag_C(bool condition) {
        if (condition) cpsr |= 0x20000000;
        else           cpsr &= 0xDFFFFFFF;
    }

    pragma(inline) void set_flag_V(bool condition) {
        if (condition) cpsr |= 0x10000000;
        else           cpsr &= 0xEFFFFFFF;
    }

    pragma(inline) void set_bit_T(bool condition) {
        if (condition) cpsr |= 0x00000020;
        else           cpsr &= 0xFFFFFFDF;
    }

    pragma(inline) bool get_flag_N() {
        return (cpsr >> 31) & 1;
    }

    pragma(inline) bool get_flag_Z() {
        return (cpsr >> 30) & 1;
    }

    pragma(inline) bool get_flag_C() {
        return (cpsr >> 29) & 1;
    }

    pragma(inline) bool get_flag_V() {
        return (cpsr >> 28) & 1;
    }

    pragma(inline) bool get_bit_T() {
        return (cpsr >> 5) & 1;
    }

    void cycle() {
        if (cycles_remaining == 0) {
            uint opcode = fetch();
            execute(opcode);
        }
    }

    uint fetch() {
        if (get_bit_T()) { // thumb mode: grab a halfword and return it
            uint opcode = cast(uint) memory.read_halfword(*pc & 0xFFFFFFFE);
            *pc += 2;
            return opcode;
        } else {           // arm mode: grab a word and return it
            uint opcode = memory.read_word(*pc & 0xFFFFFFFE);
            *pc += 4;
            return opcode;
        }
    }

    void execute(uint opcode) {
        if (get_bit_T()) {
            jumptable_thumb.jumptable[opcode >> 8](this, cast(ushort)opcode);
        } else {
            if (should_execute((opcode & 0xF0000000) >> 28)) {
                jumptable_arm.execute_instruction(opcode, this);
            } else {
                cycles_remaining = 1;
            }
        }
    }

    bool should_execute(int cond) {
        if (cond == 0b1110) {
            return true;
        }

        switch (cond) {
            case 0b0000: return  get_flag_Z(); 
            case 0b0001: return !get_flag_Z(); 
            case 0b0010: return  get_flag_C(); 
            case 0b0011: return !get_flag_C(); 
            case 0b0100: return  get_flag_N(); 
            case 0b0101: return !get_flag_N(); 
            case 0b0110: return  get_flag_V(); 
            case 0b0111: return !get_flag_V(); 
            case 0b1000: return  get_flag_C() && !get_flag_Z(); 
            case 0b1001: return !get_flag_C() ||  get_flag_Z(); 
            case 0b1010: return  get_flag_N() ==  get_flag_V(); 
            case 0b1011: return  get_flag_N() !=  get_flag_V(); 
            case 0b1100: return !get_flag_Z() &&  (get_flag_N() == get_flag_V()); 
            case 0b1101: return  get_flag_Z() &&  (get_flag_N() != get_flag_V()); 
            default:     return false;
        }
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

    Memory memory;

    uint cycles_remaining = 0;
    CpuMode current_mode;
    CpuState[CPU_STATE_LOG_LENGTH] cpu_states;

private:
    uint cpu_states_size = 0;
    bool enable_pc_checking = false;
    int setup_cycles = 200000;
}
