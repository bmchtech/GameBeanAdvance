#ifndef ARM7TDMI_H
#define ARM7TDMI_H

#include "memory.h"
#include "cpu-mode.h"

class ARM7TDMI {
    public:
        // takes in pre-allocated memory, and uses it as its own memory.
        ARM7TDMI(Memory* memory);

        // will do literally nothing yet
        ~ARM7TDMI();

        // cycles the ARM7TDMI once, running one single instruction to completion.
        void cycle();

        Memory* memory;

        // fetches one from memory, and returns the value. returns a uint16_t in THUMB mode, and uint32_t in ARM mode.
        uint32_t fetch();

        // executes the given instruction. in THUMB mode, giving a value larger than the size of a uint16_t will cause the
        // program to segfault, so don't do that.
        void execute(uint32_t opcode);

        // an explanation of these constants is partially in here as well as cpu-mode.h

        static constexpr CpuMode MODE_USER       = {0b10000, 0b1111111111111111, 16 * 0};
        static constexpr CpuMode MODE_FIQ        = {0b10001, 0b1111111111111111, 16 * 1};
        static constexpr CpuMode MODE_IRQ        = {0b10010, 0b1001111111111111, 16 * 2};
        static constexpr CpuMode MODE_SUPERVISOR = {0b10011, 0b1001111111111111, 16 * 3};
        static constexpr CpuMode MODE_ABORT      = {0b10111, 0b1001111111111111, 16 * 4};
        static constexpr CpuMode MODE_UNDEFINED  = {0b11011, 0b1001111111111111, 16 * 5};
        static constexpr CpuMode MODE_SYSTEM     = {0b11111, 0b1000000011111111, 16 * 6};

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
        inline void set_mode(const CpuMode new_mode) {
            int mask = current_mode.REGISTER_UNIQUENESS & new_mode.REGISTER_UNIQUENESS;

            for (int i = 0; i < 16; i++) {
                if (~(mask & 1))
                    register_file[i + new_mode.OFFSET] = register_file[i + current_mode.OFFSET];

                mask >>= 1;
            }

            current_mode = new_mode;
            cpsr = (cpsr & 0xFFFFFFE0) | new_mode.CPSR_ENCODING;

            regs = register_file + new_mode.OFFSET;
            pc = &regs[15];
            lr = &regs[14];
            sp = &regs[13];
        }

        uint32_t* register_file; // the full file of registers. usually you shouldn't be indexing from here.
        uint32_t* regs;          // the currently used registers in the ARM7TDMI

        uint32_t* pc;            // program counter   aka regs[0xF]
        uint32_t* lr;            // linkage register  aka regs[0xE]
        uint32_t* sp;            // stack pointer     aka regs[0xD]
        
        // program status registers
        // NZCV--------------------IFT43210
        uint32_t cpsr;            // the current program status register
        uint32_t spsr;            // the saved   program status register

        // registers used in ARM mode
        uint32_t shifter_operand;
        bool shifter_carry_out;

        inline void set_flag_N(bool condition) {
            if (condition) cpsr |= 0x80000000;
            else           cpsr &= 0x7FFFFFFF;
        }

        inline void set_flag_Z(bool condition) {
            if (condition) cpsr |= 0x40000000;
            else           cpsr &= 0xBFFFFFFF;
        }

        inline void set_flag_C(bool condition) {
            if (condition) cpsr |= 0x20000000;
            else           cpsr &= 0xDFFFFFFF;
        }

        inline void set_flag_V(bool condition) {
            if (condition) cpsr |= 0x10000000;
            else           cpsr &= 0xEFFFFFFF;
        }

        inline void set_bit_T(bool condition) {
            if (condition) cpsr |= 0x00000020;
            else           cpsr &= 0xFFFFFFDF;
        }

        inline bool get_flag_N() {
            return (cpsr >> 31) & 1;
        }

        inline bool get_flag_Z() {
            return (cpsr >> 30) & 1;
        }

        inline bool get_flag_C() {
            return (cpsr >> 29) & 1;
        }

        inline bool get_flag_V() {
            return (cpsr >> 28) & 1;
        }

        inline bool get_bit_T() {
            return (cpsr >> 5) & 1;
        }

    private:
        // determines whether or not this function should execute based on COND (the high 4 bits of the opcode)
        // note that this only applies to ARM instructions.
        bool should_execute(int opcode);

        CpuMode current_mode;
};

#endif