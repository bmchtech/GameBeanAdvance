#ifndef ARM7TDMI_H
#define ARM7TDMI_H

#include "memory.h"

class ARM7TDMI {
    public:
        // takes in pre-allocated memory, and uses it as its own memory.
        ARM7TDMI(Memory* memory);

        // will do literally nothing yet
        ~ARM7TDMI();

        // cycles the ARM7TDMI once, running one single instruction to completion.
        void cycle();

        // sets the CPU mode. can be one of: MODE_USER, MODE_FIQ, MODE_IRQ, MODE_SUPERVISOR, MODE_ABORT, MODE_UNDEFINED, or MODE_SYSTEM.
        // these modes are ARM7TDMI modes that dictate how the cpu runs.
        inline void set_mode(int mode) {
            cpsr = (cpsr & 0xFFFFFFE0) | mode;
        }

        Memory* memory;

        // fetches one from memory, and returns the value. returns a uint16_t in THUMB mode, and uint32_t in ARM mode.
        uint32_t fetch();

        // executes the given instruction. in THUMB mode, giving a value larger than the size of a uint16_t will cause the
        // program to segfault, so don't do that.
        void execute(uint32_t opcode);

        uint32_t* regs;           // the registers in the ARM7TDMI
        uint32_t* pc;  // program counter   aka regs[0xF]
        uint32_t* lr;  // linkage register  aka regs[0xE]
        uint32_t* sp;  // stack pointer     aka regs[0xD]
        
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
};

#endif