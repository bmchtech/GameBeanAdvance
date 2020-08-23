#include "catch/catch.hpp"
#include "../src/gba.h"

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

TEST_CASE("CPU Thumb Mode - ADD Two Registers") {
    wipe_registers();
    SECTION("ADD R1, R2 into R3") {
        memory.regs[1] = 0x00000001;
        memory.regs[2] = 0x00000001;
        execute(0x1853);

        REQUIRE(memory.regs[3] == 0x00000002);
        check_flags_NZCV(false, false, false, false);
    }
    wipe_registers();
}

TEST_CASE("CPU Thumb Mode - ADD Immediate Register") {
    SECTION("ADD R2, #0x00") {
        memory.regs[2] = 0x00000000;
        execute(0x3200);

        REQUIRE(memory.regs[2] == 0x00000000);
        check_flags_NZCV(false, true, false, false);
    }

    SECTION("ADD R2, #0x01") {
        memory.regs[2] = 0x7FFFFFFF;
        execute(0x3201);
        REQUIRE(memory.regs[2] == 0x80000000);

        check_flags_NZCV(true, false, false, true);
    }

    SECTION("ADD R2, #0xFF (No Overflow)") {
        memory.regs[2] = 0x00000000;
        execute(0x32FF);

        REQUIRE(memory.regs[2] == 0x000000FF);
        check_flags_NZCV(false, false, false, false);
    }

    SECTION("ADD R2, #0xFF (Overflow)") {
        memory.regs[2] = 0xFFFFFFFF;
        execute(0x3280);
        
        REQUIRE(memory.regs[2] == 0x0000007F);
        check_flags_NZCV(false, false, true, true);
    }
    wipe_registers();
}

TEST_CASE("CPU Thumb Mode - MOV Immediate") {
    SECTION("MOV R2, #0xCD") {
        memory.regs[2] = 0x00000000;
        execute(0x22CD);
        REQUIRE(memory.regs[2] == 0xCD);
    }
    wipe_registers();
}

TEST_CASE("CPU Thumb Mode - LSL Immediate") {
    set_flag_V(false);
    
    SECTION("LSL R2, R3, #0b00000") {
        memory.regs[2] = 0x00000000;
        set_flag_C(false);
        execute(0b00000'00000'010'011);

        REQUIRE(memory.regs[2] == 0x00000000);
        REQUIRE(memory.regs[3] == 0x00000000);
        check_flags_NZCV(false, true, false, false);
    }

    SECTION("LSL R2, R3, #0b00001") {
        memory.regs[2] = 0x00000001;
        execute(0b00000'00001'010'011);

        REQUIRE(memory.regs[2] == 0x00000001);
        REQUIRE(memory.regs[3] == 0x00000002);
        check_flags_NZCV(false, false, false, false);
    }

    SECTION("LSL R2, R3, #0b00100") {
        memory.regs[2] = 0xFFFFFFFF;
        execute(0b00000'00100'010'011);

        REQUIRE(memory.regs[2] == 0xFFFFFFFF);
        REQUIRE(memory.regs[3] == 0xFFFFFFF0);
        check_flags_NZCV(true, false, true, false);
    }
    wipe_registers();
}

TEST_CASE("CPU Thumb Mode - LSR Immediate") {
    set_flag_V(false);

    SECTION("LSR R2, R3, #0b00000") {
        set_flag_C(false);

        memory.regs[2] = 0x00000000;
        execute(0b00001'00000'010'011);

        REQUIRE(memory.regs[2] == 0x00000000);
        REQUIRE(memory.regs[3] == 0x00000000);
        check_flags_NZCV(false, true, false, false);
    }

    SECTION("LSR R2, R3, #0b00001") {
        memory.regs[2] = 0x00000001;
        execute(0b00001'00001'010'011);

        REQUIRE(memory.regs[2] == 0x00000001);
        REQUIRE(memory.regs[3] == 0x00000000);
        check_flags_NZCV(false, true, true, false);
    }

    SECTION("LSR R2, R3, #0b00100") {
        memory.regs[2] = 0xFFFFFFFF;
        execute(0b00001'00100'010'011);

        REQUIRE(memory.regs[2] == 0xFFFFFFFF);
        REQUIRE(memory.regs[3] == 0x0FFFFFFF);
        check_flags_NZCV(false, false, true, false);
    }
    wipe_registers();
}

TEST_CASE("CPU Thumb Mode - Conditional Branches") {
    SECTION("BEQ #0x02 (Simple Test)") {
        *memory.pc = 0x10000000;
        set_flag_Z(true);
        execute(0xD002);

        REQUIRE(*memory.pc == 0x10000006);
    }

    SECTION("BEQ #0xFE (Simple Test)") {
        *memory.pc = 0x10000000;
        set_flag_Z(true);
        execute(0xD0FE);

        REQUIRE(*memory.pc == 0x0FFFFFFE);
    }
}