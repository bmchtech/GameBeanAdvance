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
            memory->cpsr = (memory->cpsr & 0xFFFFFFE0) | mode;
        }

        Memory* memory;
        // fetches one from memory, and returns the value. returns a uint16_t in THUMB mode, and uint32_t in ARM mode.
        uint32_t fetch();

        // executes the given instruction. in THUMB mode, giving a value larger than the size of a uint16_t will cause the
        // program to segfault, so don't do that.
        void execute(uint32_t opcode);

    private:
        // determines whether or not this function should execute based on COND (the high 4 bits of the opcode)
        // note that this only applies to ARM instructions.
        bool should_execute(int opcode);
};

#endif