#pragma once

#include <cstdint>

namespace arm_pinky {
    typedef void (*instruction)(uint8_t);

    void entry_00(uint8_t opcode);
    void entry_01(uint8_t opcode);
    void entry_10(uint8_t opcode);
    void entry_11(uint8_t opcode);

    void execute_instruction(uint8_t opcode);

    extern instruction jumptable[];
}