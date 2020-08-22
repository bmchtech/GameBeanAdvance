#include "catch/catch.hpp"
#include "../src/gba.h"

#include <iostream>

// note for test cases: do not assume registers or memory values are set to 0 before starting
// a test. set them manually to 0 if you want them to be 0.

TEST_CASE("CPU Thumb Mode - ADD Immediate Register") {
    SECTION("ADD R2, 0x00") {
        memory.regs[2] = 0x00000000;
        execute(0x3200);
        REQUIRE(memory.regs[2] == 0x00000000);

        REQUIRE(flag_N == false);
        REQUIRE(flag_Z == true);
        REQUIRE(flag_C == false);
        REQUIRE(flag_V == false);
    }

    SECTION("ADD R2, 0x01") {
        memory.regs[2] = 0x7FFFFFFF;
        execute(0x3201);
        REQUIRE(memory.regs[2] == 0x80000000);

        REQUIRE(flag_N == true);
        REQUIRE(flag_Z == false);
        REQUIRE(flag_C == false);
        REQUIRE(flag_V == true);
    }

    SECTION("ADD R2, 0xFF (No Overflow)") {
        memory.regs[2] = 0x00000000;
        execute(0x32FF);
        REQUIRE(memory.regs[2] == 0x000000FF);

        REQUIRE(flag_N == false);
        REQUIRE(flag_Z == false);
        REQUIRE(flag_C == false);
        REQUIRE(flag_V == false);
    }

    SECTION("ADD R2, 0xFF (Overflow)") {
        memory.regs[2] = 0xFFFFFFFF;
        execute(0x3280);
        REQUIRE(memory.regs[2] == 0x0000007F);

        REQUIRE(flag_N == false);
        REQUIRE(flag_Z == false);
        REQUIRE(flag_C == true);
        REQUIRE(flag_V == true);
    }
}

TEST_CASE("CPU Thumb Mode - MOV Immediate") {
    SECTION("MOV R2, 0xCD") {
        memory.regs[2] = 0x00000000;
        execute(0x22CD);
        REQUIRE(memory.regs[2] == 0xCD);
    }
}
