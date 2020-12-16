#include "catch/catch.hpp"
#include "../src/gba.h"
#include "../src/util.h"
#include "cpu_state.h"
#include "expected_output.h"

#include <iostream>

// NOTE: this file could probably use some refactoring.

// note for test cases: do not assume registers or memory values are set to 0 before starting
// a test. set them manually to 0 if you want them to be 0.

#define REQUIRE_MESSAGE(cond, msg) do { INFO(msg); REQUIRE(cond); } while((void)0, 0)

void check_cpu_state(CpuState expected, CpuState actual, std::string error_message) {
    for (int i = 0; i < 16; i++) {
        REQUIRE_MESSAGE(expected.regs[i] == actual.regs[i], error_message + " at register #" + std::to_string(i));
    }

    REQUIRE_MESSAGE(expected.type           == actual.type,           error_message);
    REQUIRE_MESSAGE(expected.opcode         == actual.opcode,         error_message);
    REQUIRE_MESSAGE(expected.mem_0x03000003 == actual.mem_0x03000003, error_message);
}

void test_thumb_mode(std::string gba_file, std::string log_file, int num_instructions) {
    Memory* memory = new Memory();
    ARM7TDMI* cpu = new ARM7TDMI(memory);

    CpuState* cpu_states = new CpuState[num_instructions];
    CpuState* expected_output = produce_expected_cpu_states(cpu_states, log_file, num_instructions);
    
    get_rom_as_bytes(gba_file, memory->rom_1, SIZE_ROM_1);
    set_cpu_state(cpu, expected_output[0]);
    cpu->set_mode(ARM7TDMI::MODE_SYSTEM);

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

    delete   memory;
    delete   cpu;
    delete[] cpu_states;
}

void test_arm_mode(std::string gba_file, std::string log_file, int num_instructions, int start_instruction) {
    Memory* memory = new Memory();
    ARM7TDMI* cpu = new ARM7TDMI(memory);

    CpuState* cpu_states = new CpuState[num_instructions];
    CpuState* expected_output = produce_expected_cpu_states(cpu_states, log_file, num_instructions);
    
    get_rom_as_bytes(gba_file, memory->rom_1, SIZE_ROM_1);
    set_cpu_state(cpu, expected_output[0]);
    cpu->set_bit_T(true);
    cpu->set_mode(ARM7TDMI::MODE_SYSTEM);

    for (int i = 0; i < num_instructions - 1; i++) {
        // ARM instructions won't be run until log #190 is passed (the ARM that occurs before then is needless 
        // busywork as far as these tests are concerned, and make it harder to unit test the emulator).
        if (i == start_instruction) {
            cpu->set_bit_T(false);
            cpu->cpsr = (cpu->cpsr & 0x00FFFFFFFF) | 0x60000000; // theres a bit of arm instructions that edit the CPSR that we skip, so let's manually set it.
        }

        if (i < start_instruction) cpu->set_bit_T(true);

        if (i > start_instruction || expected_output[i].type == THUMB) {
            uint32_t opcode = cpu->fetch();
            cpu->execute(opcode);
            check_cpu_state(expected_output[i + 1], get_cpu_state(cpu), "Failed at instruction #" + std::to_string(i) + " with opcode 0x" + to_hex_string(opcode));
        } else {
            set_cpu_state(cpu, expected_output[i + 1]);
        }
    }

    // make sure we've reached B infin
    REQUIRE(cpu->fetch() == 0xEAFFFFFE);
    
    delete   memory;
    delete   cpu;
    delete[] cpu_states;
}

TEST_CASE("CPU THUMB Mode - VBA Logs (thumb-simple)") {
    test_thumb_mode("tests/asm/bin/thumb-simple.gba", "tests/asm/logs/thumb-simple.log", 3666);
}

TEST_CASE("CPU ARM Mode - VBA Logs (arm-addresing-mode-1) [Requires Functional THUMB]") {
    test_arm_mode("tests/asm/bin/arm-addressing-mode-1.gba", "tests/asm/logs/arm-addressing-mode-1.log", 1290, 216);
}

TEST_CASE("CPU ARM Mode - VBA Logs (arm-addresing-mode-2) [Requires Functional THUMB]") {
    test_arm_mode("tests/asm/bin/arm-addressing-mode-2.gba", "tests/asm/logs/arm-addressing-mode-2.log", 1290, 212);
}

TEST_CASE("CPU ARM Mode - VBA Logs (arm-addresing-mode-3) [Requires Functional THUMB]") {
    test_arm_mode("tests/asm/bin/arm-addressing-mode-3.gba", "tests/asm/logs/arm-addressing-mode-3.log", 1290, 212);
}

TEST_CASE("CPU ARM Mode - VBA Logs (arm-opcodes) [Requires Functional THUMB]") {
    test_arm_mode("tests/asm/bin/arm-opcodes.gba", "tests/asm/logs/arm-opcodes.log", 2000, 276);
}