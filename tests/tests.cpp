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





TEST_CASE("CPU Thumb Mode - Logical AND") {
    set_flag_C(true);
    set_flag_V(true);

    SECTION("AND R2, R3 (Carry)") {
        memory.regs[2] = 0xFF00FF88;
        memory.regs[3] = 0xF1111111;
        execute(0b010000'0000'010'011);

        REQUIRE(memory.regs[3] == 0xF1001100);
        check_flags_NZCV(true, false, true, true);
    }

    SECTION("AND R2, R3 (Zero)") {
        memory.regs[2] = 0x00000000;
        memory.regs[3] = 0x12345678;
        execute(0b010000'0000'010'011);

        REQUIRE(memory.regs[3] == 0x00000000);
        check_flags_NZCV(false, true, true, true);
    }
}





TEST_CASE("CPU Thumb Mode - Logical EOR") {
    set_flag_C(true);
    set_flag_V(true);

    SECTION("EOR R2, R3 (Carry)") {
        memory.regs[2] = 0xFF00FF88;
        memory.regs[3] = 0x11111111;
        execute(0b010000'0001'010'011);

        REQUIRE(memory.regs[3] == 0xEE11EE99);
        check_flags_NZCV(true, false, true, true);
    }

    SECTION("AND R2, R3 (Zero)") {
        memory.regs[2] = 0x12345678;
        memory.regs[3] = 0x12345678;
        execute(0b010000'0001'010'011);

        REQUIRE(memory.regs[3] == 0x00000000);
        check_flags_NZCV(false, true, true, true);
    }
}






TEST_CASE("CPU Thumb Mode - Logical LSL") {
    set_flag_V(true);

    SECTION("LSL R2, R3 (Shift == 0)") {
        set_flag_C(true);
        memory.regs[2] = 0xFFFF0000;
        memory.regs[3] = 0x12345678;
        execute(0b010000'0010'010'011);

        REQUIRE(memory.regs[3] == 0x12345678);
        check_flags_NZCV(false, false, true, true);
    }

    SECTION("LSL R2, R3 (Shift < 32)") {
        set_flag_C(true);
        memory.regs[2] = 0xFFFF0004;
        memory.regs[3] = 0x1F345678;
        execute(0b010000'0010'010'011);

        REQUIRE(memory.regs[3] == 0xF3456780);
        check_flags_NZCV(true, false, true, true);
    }

    SECTION("LSL R2, R3 (Shift == 32)") {
        set_flag_C(true);
        memory.regs[2] = 0xFFFF0020;
        memory.regs[3] = 0x1F345679;
        execute(0b010000'0010'010'011);

        REQUIRE(memory.regs[3] == 0x00000000);
        check_flags_NZCV(false, true, true, true);
    }

    SECTION("LSL R2, R3 (Shift > 32)") {
        set_flag_C(true);
        memory.regs[2] = 0xFFFF0021;
        memory.regs[3] = 0x1F345678;
        execute(0b010000'0010'010'011);

        REQUIRE(memory.regs[3] == 0x00000000);
        check_flags_NZCV(false, true, false, true);
    }
}





TEST_CASE("CPU Thumb Mode - Logical LSR") {
    set_flag_V(true);

    SECTION("LSR R2, R3 (Shift == 0)") {
        set_flag_C(true);
        memory.regs[2] = 0xFFFF0000;
        memory.regs[3] = 0x12345678;
        execute(0b010000'0011'010'011);

        REQUIRE(memory.regs[3] == 0x12345678);
        check_flags_NZCV(false, false, true, true);
    }

    SECTION("LSR R2, R3 (Shift < 32)") {
        set_flag_C(true);
        memory.regs[2] = 0xFFFF0004;
        memory.regs[3] = 0x1F345678;
        execute(0b010000'0011'010'011);

        REQUIRE(memory.regs[3] == 0x01F34567);
        check_flags_NZCV(false, false, true, true);
    }

    SECTION("LSR R2, R3 (Shift == 32)") {
        set_flag_C(true);
        memory.regs[2] = 0xFFFF0020;
        memory.regs[3] = 0x1F345679;
        execute(0b010000'0011'010'011);

        REQUIRE(memory.regs[3] == 0x00000000);
        check_flags_NZCV(false, true, false, true);
    }

    SECTION("LSR R2, R3 (Shift > 32)") {
        set_flag_C(true);
        memory.regs[2] = 0xFFFF0021;
        memory.regs[3] = 0x1F345678;
        execute(0b010000'0011'010'011);

        REQUIRE(memory.regs[3] == 0x00000000);
        check_flags_NZCV(false, true, false, true);
    }
} 





TEST_CASE("CPU Thumb Mode - Logical ASR") {
    set_flag_V(true);

    SECTION("ASR R2, R3 (Shift == 0)") {
        set_flag_C(true);
        memory.regs[2] = 0xFFFF0000;
        memory.regs[3] = 0x12345678;
        execute(0b010000'0100'010'011);

        REQUIRE(memory.regs[3] == 0x12345678);
        check_flags_NZCV(false, false, true, true);
    }

    SECTION("ASR R2, R3 (Shift < 32)") {
        set_flag_C(true);
        memory.regs[2] = 0xFFFF0004;
        memory.regs[3] = 0x9F345678;
        execute(0b010000'0100'010'011);

        REQUIRE(memory.regs[3] == 0xF9F34567);
        check_flags_NZCV(true, false, true, true);
    }

    SECTION("ASR R2, R3 (Shift >= 32, positive)") {
        set_flag_C(true);
        memory.regs[2] = 0xFFFF0020;
        memory.regs[3] = 0x1F345679;
        execute(0b010000'0100'010'011);

        REQUIRE(memory.regs[3] == 0x00000000);
        check_flags_NZCV(false, true, false, true);
    }

    SECTION("ASR R2, R3 (Shift >= 32, negative)") {
        set_flag_C(true);
        memory.regs[2] = 0xFFFF0020;
        memory.regs[3] = 0x9F345678;
        execute(0b010000'0100'010'011);

        REQUIRE(memory.regs[3] == 0xFFFFFFFF);
        check_flags_NZCV(true, false, true, true);
    }
}





TEST_CASE("CPU Thumb Mode - ADC") {
    SECTION("ADC R2, R3 (Zero)") {
        set_flag_C(false);
        memory.regs[2] = 0x00000000;
        memory.regs[3] = 0x00000000;
        execute(0b010000'0101'010'011);

        REQUIRE(memory.regs[3] == 0x00000000);
        check_flags_NZCV(false, true, false, false);
    }

    SECTION("ADC R2, R3 (V flag)") {
        set_flag_C(true);
        memory.regs[2] = 0x7FFFFFFF;
        memory.regs[3] = 0x00000001;
        execute(0b010000'0101'010'011);
        REQUIRE(memory.regs[3] == 0x80000001);

        check_flags_NZCV(true, false, false, true);
    }

    SECTION("ADC R2, R3 (No Overflow)") {
        set_flag_C(false);
        memory.regs[2] = 0x00000001;
        memory.regs[3] = 0xFFFFFFFE;
        execute(0b010000'0101'010'011);

        REQUIRE(memory.regs[3] == 0xFFFFFFFF);
        check_flags_NZCV(true, false, false, false);
    }

    SECTION("ADC R2, R3 (Overflow)") {
        set_flag_C(true);
        memory.regs[2] = 0x00000001;
        memory.regs[3] = 0xFFFFFFFE;
        execute(0b010000'0101'010'011);
        
        REQUIRE(memory.regs[3] == 0x00000000);
        check_flags_NZCV(false, true, true, false);
    }
    wipe_registers();
}





TEST_CASE("CPU Thumb Mode - SBC") {
    SECTION("SBC R2, R3 (Zero)") {
        set_flag_C(true);
        memory.regs[2] = 0x00000000;
        memory.regs[3] = 0x00000000;
        execute(0b010000'0110'010'011);

        REQUIRE(memory.regs[3] == 0x00000000);
        check_flags_NZCV(false, true, false, false);
    }

    SECTION("SBC R2, R3 (V flag)") {
        set_flag_C(false);
        memory.regs[2] = 0x80000000;
        memory.regs[3] = 0x80000001;
        execute(0b010000'0110'010'011);

        REQUIRE(memory.regs[3] == 0x00000000);
        check_flags_NZCV(false, true, true, true);
    }

    SECTION("SBC R2, R3 (No Overflow)") {
        set_flag_C(true);
        memory.regs[2] = 0x00000001;
        memory.regs[3] = 0xFFFFFFFE;
        execute(0b010000'0110'010'011);

        REQUIRE(memory.regs[3] == 0xFFFFFFFD);
        check_flags_NZCV(true, false, true, false);
    }

    SECTION("SBC R2, R3 (Overflow)") {
        set_flag_C(false);
        memory.regs[2] = 0xFFFFFFFF;
        memory.regs[3] = 0xFFFFFFFE;
        execute(0b010000'0110'010'011);
        
        REQUIRE(memory.regs[3] == 0xFFFFFFFE);
        check_flags_NZCV(true, false, false, false);
    }
    wipe_registers();
}





TEST_CASE("CPU Thumb Mode - ROR") {
    set_flag_C(true);
    set_flag_V(true);

    SECTION("ROR R2, R3 (r3 == 0)") {
        memory.regs[2] = 0xFFFFFF00;
        memory.regs[3] = 0x01234567;
        execute(0b010000'0111'010'011);

        REQUIRE(memory.regs[3] == 0x01234567);
        check_flags_NZCV(false, false, true, true);
    }

    SECTION("ROR R2, R3 (r3[4:0] == 0 && r3 r3[7:0] != 0)") {
        memory.regs[2] = 0xFFFFFFF0;
        memory.regs[3] = 0x01234567;
        execute(0b010000'0111'010'011);
        REQUIRE(memory.regs[3] == 0x01234567);

        check_flags_NZCV(false, false, false, true);
    }

    SECTION("ROR R2, R3 (r3[4:0] > 0)") {
        memory.regs[2] = 0xFFFFFFF8;
        memory.regs[3] = 0x01234567;
        execute(0b010000'0111'010'011);

        REQUIRE(memory.regs[3] == 0x67012345);
        check_flags_NZCV(false, false, false, true);
    }
    wipe_registers();
}





TEST_CASE("CPU Thumb Mode - TST") {
    set_flag_C(true);
    set_flag_V(true);

    SECTION("TST R2, R3 (alu_out != 0)") {
        memory.regs[2] = 0xFF00FF00;
        memory.regs[3] = 0x91234567;
        execute(0b010000'1000'010'011);

        REQUIRE(memory.regs[3] == 0x91234567);
        check_flags_NZCV(true, false, true, true);
    }

    SECTION("TST R2, R3 (alu_out == 0)") {
        memory.regs[2] = 0xFEDCBA98;
        memory.regs[3] = 0x01234567;
        execute(0b010000'1000'010'011);

        REQUIRE(memory.regs[3] == 0x01234567);
        check_flags_NZCV(false, true, true, true);
    }
}





TEST_CASE("CPU Thumb Mode - NEG") {
    set_flag_C(true);
    set_flag_V(true);

    SECTION("TST R2, R3 (Zero)") {
        memory.regs[2] = 0x00000000;
        execute(0b010000'1001'010'011);

        REQUIRE(memory.regs[3] == 0x00000000);
        check_flags_NZCV(false, true, false, false);
    }

    SECTION("TST R2, R3 (Carry set)") {
        memory.regs[2] = 0b00000000'00000000'00000000'00011001;
        execute(0b010000'1001'010'011);

        REQUIRE(memory.regs[3] == 0b11111111'11111111'11111111'11100111);
        check_flags_NZCV(true, false, true, false);
    }

    SECTION("TST R2, R3 (Overflow set)") {
        memory.regs[2] = 0b10000000'00000000'00000000'00000000;
        execute(0b010000'1001'010'011);

        REQUIRE(memory.regs[3] == 0b10000000'00000000'00000000'00000000);
        check_flags_NZCV(true, false, true, true);
    }
}





TEST_CASE("CPU Thumb Mode - CMP Registers (Low)") {
    SECTION("CMP R2, R3 (Zero)") {
        memory.regs[2] = 0x00000000;
        memory.regs[3] = 0x00000000;
        execute(0b010000'1010'010'011);

        check_flags_NZCV(false, true, false, false);
    }

    SECTION("CMP R2, R3 (V flag)") {
        memory.regs[2] = 0x80000000;
        memory.regs[3] = 0x80000000;
        execute(0b010000'1010'010'011);

        check_flags_NZCV(false, true, true, true);
    }

    SECTION("CMP R2, R3 (No Overflow)") {
        memory.regs[2] = 0x00000001;
        memory.regs[3] = 0xFFFFFFFE;
        execute(0b010000'1010'010'011);

        check_flags_NZCV(true, false, true, false);
    }

    SECTION("CMP R2, R3 (Overflow)") {
        memory.regs[2] = 0xFFFFFFFF;
        memory.regs[3] = 0xFFFFFFFD;
        execute(0b010000'1010'010'011);
        
        check_flags_NZCV(true, false, false, false);
    }
    wipe_registers();
}