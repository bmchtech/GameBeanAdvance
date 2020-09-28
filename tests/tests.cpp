#include "catch/catch.hpp"
#include "../src/gba.h"
#include "../src/util.h"
#include "cpu_state.h"
#include "expected_output.h"

#include <iostream>

// note for test cases: do not assume registers or memory values are set to 0 before starting
// a test. set them manually to 0 if you want them to be 0.

// Just a faster way to check flags
void check_flags_NZCV(bool fN, bool fZ, bool fC, bool fV) {
    REQUIRE(get_flag_N() == fN);
    REQUIRE(get_flag_Z() == fZ);
    REQUIRE(get_flag_C() == fC);
    REQUIRE(get_flag_V() == fV);
}

void wipe_registers() {
    for (int i = 0; i < NUM_REGISTERS; ++i) {
        memory.regs[i] = 0x00000000;
    }
}

// TODO: Move the below functions to a different file.

#define REQUIRE_MESSAGE(cond, msg) do { INFO(msg); REQUIRE(cond); } while((void)0, 0)

void check_cpu_state(CpuState expected, CpuState actual, std::string error_message) {
    for (int i = 0; i < 16; i++) {
        REQUIRE_MESSAGE(expected.regs[i] == actual.regs[i], error_message + " at register #" + std::to_string(i));
    }

    REQUIRE_MESSAGE(expected.type   == actual.type,   error_message);
    REQUIRE_MESSAGE(expected.opcode == actual.opcode, error_message);
}

TEST_CASE("CPU THUMB Mode - VBA Logs (thumb-alu)") {
    uint32_t num_instructions = 3666;
    CpuState* expected_output = produce_expected_cpu_states("tests/asm/logs/thumb-alu.log", num_instructions);
    
    get_rom_as_bytes("tests/asm/bin/thumb-alu.gba", memory.rom_1, SIZE_ROM_1);
    set_cpu_state(expected_output[0]);

    bool wasPreviousInstructionARM = true; // if so, we reset the CPU's state
    for (int i = 0; i < num_instructions - 1; i++) {
        if (expected_output[i].type == THUMB) {
            if (wasPreviousInstructionARM) {
                set_bit_T(true);
                set_cpu_state(expected_output[i]);
            }
            
            uint16_t opcode = fetch();
            execute(opcode);
            check_cpu_state(expected_output[i + 1], get_cpu_state(), "Failed at instruction #" + std::to_string(i) + " with opcode 0x" + to_hex_string(opcode));
        } else {
            wasPreviousInstructionARM = true;
        }
    }

    // make sure we've reached B infin
    REQUIRE(fetch() == 0xE7FE);
}