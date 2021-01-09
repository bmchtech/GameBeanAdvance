#include <cstdint>
#include "iostream"
#include "pinky.h"

void arm_pinky::entry_00(uint8_t opcode) {
    uint8_t discriminator = (((opcode >> 0) & 0) << 0) | (((opcode >> 1) & 1) << 0);

    switch (discriminator) {
        case 0b0: {
            // yes this is useless code but its filler so
            int a = 3;
            
            int b = 6;
            int result = a - b;
            std::cout << std::to_string(result) << std::endl;
            break;
        }
    }
}

void arm_pinky::entry_01(uint8_t opcode) {
    uint8_t discriminator = (((opcode >> 0) & 0) << 0) | (((opcode >> 1) & 1) << 0);

    switch (discriminator) {
        case 0b0: {
            // yes this is useless code but its filler so
            int a = 3;
            
            int b = 6;
            int result = a - b;
            std::cout << std::to_string(result) << std::endl;
            break;
        }
    }
}

void arm_pinky::entry_10(uint8_t opcode) {
    uint8_t discriminator = (((opcode >> 0) & 0) << 0) | (((opcode >> 1) & 1) << 0);

    switch (discriminator) {
        case 0b0: {
            // yes this is useless code but its filler so
            int a = 5;
            int b = 6;
            int result = a - b;
            std::cout << std::to_string(result) << std::endl;
            break;
        }
        case 0b1: {
            // yes this is useless code but its filler so
            int a = 5;
            // special comment! :D
            int b = 6;
            int result = a + b;
            std::cout << std::to_string(result) << std::endl;
            break;
        }
    }
}

void arm_pinky::entry_11(uint8_t opcode) {
    uint8_t discriminator = (((opcode >> 0) & 0) << 0) | (((opcode >> 1) & 1) << 0);

    switch (discriminator) {
        case 0b0: {
            // yes this is useless code but its filler so
            int a = 5;
            int b = 6;
            int result = a - b;
            std::cout << std::to_string(result) << std::endl;
            break;
        }
        case 0b1: {
            // yes this is useless code but its filler so
            int a = 5;
            // special comment! :D
            int b = 6;
            int result = a + b;
            std::cout << std::to_string(result) << std::endl;
            break;
        }
    }
}

void arm_pinky::execute_instruction(uint8_t opcode) {
    arm_pinky::jumptable[(((opcode >> 0) & 0) << 0) | (((opcode >> 2) & 3) << 0)](opcode);
}

arm_pinky::instruction arm_pinky::jumptable[] = {
    &arm_pinky::entry_00,
    &arm_pinky::entry_01,
    &arm_pinky::entry_10,
    &arm_pinky::entry_11,
};
