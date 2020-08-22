#include "catch/catch.hpp"
#include "../src/gba.h"

#include <iostream>

// note for test cases: do not assume registers or memory values are set to 0 before starting
// a test. set them manually to 0 if you want them to be 0.

TEST_CASE("CPU Thumb Mode - MOV Immediate") {
    memory.regs[2] = 0x00000000;
    execute(0b0010001011001101); // MOV R2, 0xCD
    REQUIRE(memory.regs[2] == 0xCD);
}