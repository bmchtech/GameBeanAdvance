#include "catch/catch.hpp"

#include "expected_output.h"
#include "cpu_state.h"
#include "../src/gba.h"

// checks if the two states match
void check_cpu_state(CpuState expected, CpuState actual);

TEST_CASE("CPU Check - THUMB Mode") {
    uint32_t num_instructions = 100;
    CpuState* expected_output = produce_expected_cpu_states("tests/asm/logs/thumb_100.log", num_instructions);
    
    setup_memory();
    get_rom_as_bytes("tests/asm/bin/thumb.gba", memory.rom_1, SIZE_ROM_1);

    for (int i = 0; i < num_instructions - 1; i++) {
        if (expected_output[i].type == THUMB) {
            set_cpu_state(expected_output[i]);
            execute(fetch());
            check_cpu_state(expected_output[i + 1], get_cpu_state());
        }
    }
}

void check_cpu_state(CpuState expected, CpuState actual) {
    REQUIRE(expected.type   == actual.type);
    REQUIRE(expected.opcode == actual.opcode);
    
    for (int i = 0; i < 16; i++) {
        REQUIRE(expected.regs[i] == actual.regs[i]);
    }
}