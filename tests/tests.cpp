#include "catch/catch.hpp"
#include "../src/gba.h"
#include "../src/util.h"
#include "cpu_state.h"
#include "expected_output.h"

#include <iostream>

// note for test cases: do not assume registers or memory vsimplees are set to 0 before starting
// a test. set them manually to 0 if you want them to be 0.

// Just a faster way to check flags
void check_flags_NZCV(ARM7TDMI* cpu, bool fN, bool fZ, bool fC, bool fV) {
    REQUIRE(cpu->get_flag_N() == fN);
    REQUIRE(cpu->get_flag_Z() == fZ);
    REQUIRE(cpu->get_flag_C() == fC);
    REQUIRE(cpu->get_flag_V() == fV);
}

void wipe_registers(ARM7TDMI* cpu) {
    for (int i = 0; i < NUM_REGISTERS; ++i) {
        cpu->regs[i] = 0x00000000;
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

TEST_CASE("CPU THUMB Mode - VBA Logs (thumb-simple)") {
    Memory* memory = new Memory();
    ARM7TDMI* cpu = new ARM7TDMI(memory);

    uint32_t num_instructions = 3666;
    CpuState* expected_output = produce_expected_cpu_states("tests/asm/logs/thumb-simple.log", num_instructions);
    
    get_rom_as_bytes("tests/asm/bin/thumb-simple.gba", memory->rom_1, SIZE_ROM_1);
    set_cpu_state(cpu, expected_output[0]);

    bool wasPreviousInstructionARM = true; // if so, we reset the CPU's state
    for (int i = 0; i < num_instructions - 1; i++) {
        if (expected_output[i].type == THUMB) {
            if (wasPreviousInstructionARM) {
                cpu->set_bit_T(true);
                set_cpu_state(cpu, expected_output[i]);
            }
            
            uint16_t opcode = cpu->fetch();
            cpu->execute(opcode);
            check_cpu_state(expected_output[i + 1], get_cpu_state(cpu), "Failed at instruction #" + std::to_string(i) + " with opcode 0x" + to_hex_string(opcode));
        } else {
            wasPreviousInstructionARM = true;
        }
    }

    // make sure we've reached B infin
    REQUIRE(cpu->fetch() == 0xE7FE);

    delete memory;
    delete cpu;
}

#define ARM_START_INSTRUCTION 203

TEST_CASE("CPU ARM Mode - VBA Logs (arm-simple) [Requires Functional THUMB]") {
    Memory* memory = new Memory();
    ARM7TDMI* cpu = new ARM7TDMI(memory);

    uint32_t num_instructions = 1290;
    CpuState* expected_output = produce_expected_cpu_states("tests/asm/logs/arm-simple.log", num_instructions);
    
    get_rom_as_bytes("tests/asm/bin/arm-simple.gba", memory->rom_1, SIZE_ROM_1);
    set_cpu_state(cpu, expected_output[0]);
    cpu->set_bit_T(true);

    for (int i = 0; i < num_instructions - 1; i++) {
        // ARM instructions won't be run until log #190 is passed (the ARM that occurs before then is needless 
        // busywork as far as these tests are concerned, and make it harder to unit test the emulator).
        if (i == ARM_START_INSTRUCTION) {
            cpu->set_bit_T(false);
            cpu->cpsr = 0x6000001F; // theres a bit of arm instructions that edit the CPSR that we skip, so let's manually set it.
        }

        if (i < ARM_START_INSTRUCTION) cpu->set_bit_T(true);

        if (i > ARM_START_INSTRUCTION || expected_output[i].type == THUMB) {
            uint32_t opcode = cpu->fetch();
            cpu->execute(opcode);
            check_cpu_state(expected_output[i + 1], get_cpu_state(cpu), "Failed at instruction #" + std::to_string(i) + " with opcode 0x" + to_hex_string(opcode));
        } else {
            set_cpu_state(cpu, expected_output[i + 1]);
        }
    }

    // make sure we've reached B infin
    REQUIRE(cpu->fetch() == 0xEAFFFFFE);
    
    delete memory;
    delete cpu;
}