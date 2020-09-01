// NOTE: this code is not meant to be run in its raw form. it should first be parsed by make-jumptable.py
// with these settings. this is automatically done by the makefile already:
//     INSTRUCTION_SIZE        = 16
//     JUMPTABLE_BIT_WIDTH     = 8
//
// Explanation of some of the notation:
//     all functions are titled run_<some binary value>. the binary value specifies where in the jumptable
//     the function belongs. if the binary value contains variables as bits (let's call them bit-variables), 
//     then those bits can be either 0 or 1, and the jumptable is updated accordingly. if you begin a function 
//     with @IF(<insert bit-variable here>), then the line is only included in entries of the jumptable where
//     that specific bit-variable is 1. if a function is preceded by @EXCLUDE(<some binary value>), then
//     the function will not be inserted in the jumptable at that binary value. - is used as a wildcard in
//     @EXCLUDE. @DEFAULT() is used for a default function (in this case, the default is a nop function).
//     default functions are used when no other function matches the jumptable. @LOCAL() to tell the script
//     that the following function is a local function and should appear in the .cpp file. i'm not using @LOCAL
//     anymore, but it's still supported by make-jumptable.py in case i ever need it. this all was intended
//     as a way to make the code cleaner and more readable.

#ifdef DEBUG_MESSAGE
    #define DEBUG_MESSAGE(message) std::cout << message << std::endl;
#else
    #define DEBUG_MESSAGE(message) do {} while(0)
#endif

@DEFAULT()
void nop(uint16_t opcode) {
    DEBUG_MESSAGE("NOP");
}

// logical shift left/right
void run_0000SABC(uint16_t opcode) {
    @IF(S)  DEBUG_MESSAGE("Logical Shift Right");
    @IF(!S) DEBUG_MESSAGE("Logical Shift Left");

    uint8_t source = get_nth_bits(opcode, 3,  6);
    uint8_t dest   = get_nth_bits(opcode, 0,  3);
    uint8_t shift  = get_nth_bits(opcode, 6,  11);

    if (shift == 0) { // if shift == 0, the cpu shifts by 32, which is the size of the register.
        @IF(S)  set_flag_C(get_nth_bit(memory.regs[source], 31));
        memory.regs[dest] = 0;
    } else {
        @IF(S)  set_flag_C(get_nth_bit(memory.regs[source], shift - 1));
        @IF(!S) set_flag_C(get_nth_bit(memory.regs[source], 32 - shift));
        @IF(S)  memory.regs[dest] = (memory.regs[source] >> shift);
        @IF(!S) memory.regs[dest] = (memory.regs[source] << shift);
    }

    set_flag_N(get_nth_bit(memory.regs[dest], 31));
    set_flag_Z(memory.regs[dest] == 0);
}

// arithmetic shift left
void run_00010ABC(uint16_t opcode) {

}

// add #1 010 001 001
void run_00011000(uint16_t opcode) {
    DEBUG_MESSAGE("Add #1");

    int32_t rn = memory.regs[get_nth_bits(opcode, 3, 6)];
    int32_t rm = memory.regs[get_nth_bits(opcode, 6, 9)];
    
    memory.regs[get_nth_bits(opcode, 0, 3)] = rn + rm;
    int32_t rd = memory.regs[get_nth_bits(opcode, 0, 3)];

    set_flag_N(get_nth_bit(rd, 31));
    set_flag_Z(rd == 0);
    // set_flag_C((uint64_t)rn + (uint64_t)rm > rd); // probably can be optimized

    // Signed carry formula = (A AND B) OR (~DEST AND (A XOR B)) - works for all add operations once tested
    set_flag_C((get_nth_bit(rm, 31) & get_nth_bit(rn, 31)) | 
    ((get_nth_bit(rm, 31) ^ get_nth_bit(rn, 31)) & ~(get_nth_bit(rd, 31))));


    // this is garbage, but essentially what's going on is:
    // if the two operands had matching signs but their sign differed from the result's sign,
    // then there was an overflow and we set the flag.
    bool matching_signs = get_nth_bit(rn, 31) == get_nth_bit(rm, 31);
    set_flag_V(matching_signs && (get_nth_bit(rn, 31) ^ get_flag_N()));
}

// add #2 and subtract #2
void run_000111OA(uint16_t opcode) {

}

// move immediate
void run_00100ABC(uint16_t opcode) {
    DEBUG_MESSAGE("Move Immediate");

    uint16_t immediate_value = get_nth_bits(opcode, 0, 8);
    memory.regs[get_nth_bits(opcode, 8, 11)] = immediate_value;
    // flags
    set_flag_N(get_nth_bit(immediate_value, 31));
    set_flag_Z(immediate_value == 0);
}

// compare immediate
void run_00101ABC(uint16_t opcode) {

}

// add immediate
void run_00110ABC(uint16_t opcode) {
    DEBUG_MESSAGE("Add Register Immediate");

    int32_t immediate_value = get_nth_bits(opcode, 0, 8);
    uint32_t rd             = get_nth_bits(opcode, 8, 11);
    int32_t old_rd_value    = memory.regs[rd];

    memory.regs[rd] += immediate_value;
    int32_t new_rd_value    = memory.regs[rd];

    set_flag_N(get_nth_bit(new_rd_value, 31));
    set_flag_Z((new_rd_value == 0));

    // Signed carry formula = (A AND B) OR (~DEST AND (A XOR B)) - works for all add operations once tested
    set_flag_C(get_nth_bit(immediate_value, 31) & get_nth_bit(old_rd_value, 31) | 
    ((get_nth_bit(immediate_value, 31) ^ get_nth_bit(old_rd_value, 31)) & ~(get_nth_bit(new_rd_value, 31))));

    bool matching_signs = get_nth_bit(old_rd_value, 31) == get_nth_bit(immediate_value, 7);
    set_flag_V(matching_signs && (get_nth_bit(old_rd_value, 31) ^ get_flag_N()));
}

// subtract immediate
void run_00111ABC(uint16_t opcode) {
    // maybe we can link add immediate with subtract immediate using twos complement...
    // like, a - b is the same as a + (~b)
    DEBUG_MESSAGE("Subtract Immediate");

    uint32_t immediate_value = get_nth_bits(opcode, 0, 8);
    uint8_t  rd              = get_nth_bits(opcode, 8, 11);
    uint32_t old_rd_value    = memory.regs[rd];
    
    memory.regs[rd]  -= immediate_value;
    uint32_t new_rd_value    = memory.regs[rd];

    set_flag_N(get_nth_bit(new_rd_value, 31));
    set_flag_Z(new_rd_value == 0);
    set_flag_C(immediate_value > old_rd_value);

    // this is garbage, but essentially what's going on is:
    // if the two operands had matching signs but their sign differed from the result's sign,
    // then there was an overflow and we set the flag.
    bool matching_signs = get_nth_bit(old_rd_value, 31) == get_nth_bit(immediate_value, 31);
    set_flag_V(matching_signs && (get_nth_bit(new_rd_value, 31) ^ get_flag_N()));
}

// ALU operation - AND, EOR, LSL #2, LSR #2
void run_01000000(uint16_t opcode) {
    DEBUG_MESSAGE("ALU Operation - AND / EOR / LSL #2 / LSR #2");
    uint8_t rd = get_nth_bits(opcode, 0, 3);
    uint8_t rm = get_nth_bits(opcode, 3, 6);

    switch (get_nth_bits(opcode, 6, 8)) {
        case 0b00:
            memory.regs[rd] &= memory.regs[rm];
            break;
        case 0b01:
            memory.regs[rd] ^= memory.regs[rm];
            break;
        case 0b10:
            if ((memory.regs[rm] & 0xFF) < 32 && (memory.regs[rm] & 0xFF) != 0) {
                set_flag_C(get_nth_bit(memory.regs[rd], 32 - (memory.regs[rm] & 0xFF)));
                memory.regs[rd] <<= (memory.regs[rm] & 0xFF);
            } else if ((memory.regs[rm] & 0xFF) == 32) {
                set_flag_C(memory.regs[rd] & 1);
                memory.regs[rd] = 0;
            } else if ((memory.regs[rm] & 0xFF) > 32) {
                set_flag_C(false);
                memory.regs[rd] = 0;
            }
            break;
        case 0b11:
            if ((memory.regs[rm] & 0xFF) < 32 && (memory.regs[rm] & 0xFF) != 0) {
                set_flag_C(get_nth_bit(memory.regs[rd], (memory.regs[rm] & 0xFF) - 1));
                memory.regs[rd] >>= (memory.regs[rm] & 0xFF);
            } else if ((memory.regs[rm] & 0xFF) == 32) {
                set_flag_C(memory.regs[rd] >> 31);
                memory.regs[rd] = 0;
            } else if ((memory.regs[rm] & 0xFF) > 32) {
                set_flag_C(false);
                memory.regs[rd] = 0;
            }
            break;
    }

    set_flag_N(memory.regs[rd] >> 31);
    set_flag_Z(memory.regs[rd] == 0);
}

// ALU operation - ASR #2, ADC, SBC, ROR
void run_01000001(uint16_t opcode) {
    DEBUG_MESSAGE("ALU Operation - ASR #2 / ADC / SBC / ROR");
    uint8_t rd = get_nth_bits(opcode, 0, 3);
    uint8_t rm = get_nth_bits(opcode, 3, 6);

    switch (get_nth_bits(opcode, 6, 8)) {
        case 0b00: {
            // ASR #2
            uint8_t low_byte = memory.regs[rm] & 0xFF;
            if (low_byte < 32 && low_byte != 0) {
                set_flag_C(get_nth_bit(memory.regs[rd], low_byte - 1));
                // arithmetic shift requires us to cast to signed int first, then back to unsigned to store in registers.
                memory.regs[rd] = (uint32_t) (((int32_t) memory.regs[rd]) >> memory.regs[rm]);
            } else if (low_byte >= 32) {
                set_flag_C(memory.regs[rd] >> 31);
                if (get_flag_C()) {
                    memory.regs[rd] = 0xFFFFFFFF; // taking into account two's complement
                } else {
                    memory.regs[rd] = 0x00000000;
                }
            }
            break;
        }
        
        case 0b01: {
            // ADC - this code will look very similar to the Add Register instruction. it just also utilizes the carry bit.
            int32_t rm_value     = memory.regs[rm];
            int32_t old_rd_value = memory.regs[rd];

            memory.regs[rd] += rm_value + get_flag_C();
            int32_t new_rd_value = memory.regs[rd];

            set_flag_N(get_nth_bit(new_rd_value, 31));
            set_flag_Z((new_rd_value == 0));

            // Signed carry formula = (A AND B) OR (~DEST AND (A XOR B)) - works for all add operations once tested
            set_flag_C(get_nth_bit(rm_value, 31) & get_nth_bit(old_rd_value, 31) | 
            ((get_nth_bit(rm_value, 31) ^ get_nth_bit(old_rd_value, 31)) & ~(get_nth_bit(new_rd_value, 31))));

            bool matching_signs = get_nth_bit(old_rd_value, 31) == get_nth_bit(rm_value, 31);
            set_flag_V(matching_signs && (get_nth_bit(old_rd_value, 31) ^ get_flag_N()));
            break;
        }

        case 0b10: {
            // SBC - using a twos complement trick, SBC will just be the same thing as ADC, just with a negative rm_value.
            int32_t rm_value     = ~memory.regs[rm] + 1; // the trick is implemented here
            int32_t old_rd_value = memory.regs[rd];

            memory.regs[rd] += rm_value - (get_flag_C() ? 0 : 1); // as well as over here
            int32_t new_rd_value = memory.regs[rd];

            set_flag_N(get_nth_bit(new_rd_value, 31));
            set_flag_Z((new_rd_value == 0));

            // Signed carry formula = (A AND B) OR (~DEST AND (A XOR B)) - works for all add operations once tested
            set_flag_C(get_nth_bit(rm_value, 31) & get_nth_bit(old_rd_value, 31) | 
            ((get_nth_bit(rm_value, 31) ^ get_nth_bit(old_rd_value, 31)) & ~(get_nth_bit(new_rd_value, 31))));

            bool matching_signs = get_nth_bit(old_rd_value, 31) == get_nth_bit(rm_value, 31);
            set_flag_V(matching_signs && (get_nth_bit(old_rd_value, 31) ^ get_flag_N()));
            break;
        }

        case 0b11: {
            // ROR - Rotates the register to the right by memory.regs[rm]
            if ((memory.regs[rm] & 0xFF) == 0) 
                break;

            if ((memory.regs[rm] & 0xF) == 0) {
                set_flag_C(get_nth_bit(memory.regs[rd], 31));
            } else {
                set_flag_C(get_nth_bit(memory.regs[rd], (memory.regs[rm] & 0xF) - 1));
                uint32_t rotated_off = get_nth_bits(memory.regs[rd], 0, memory.regs[rm] & 0xF);  // the value that is rotated off
                uint32_t rotated_in  = get_nth_bits(memory.regs[rd], memory.regs[rm] & 0xF, 32); // the value that stays after the rotation
                memory.regs[rd] = rotated_in | (rotated_off << (32 - (memory.regs[rm] & 0xF)));
            }
        }
    }

    set_flag_N(memory.regs[rd] >> 31);
    set_flag_Z(memory.regs[rd] == 0);
}

// ALU operation - TST, NEG, CMP #2, CMN
void run_01000010(uint16_t opcode) {
    DEBUG_MESSAGE("ALU Operation - TST / NEG / CMP #2 / CMN");
    uint8_t rd = get_nth_bits(opcode, 0, 3);
    uint8_t rm = get_nth_bits(opcode, 3, 6);
    uint32_t result;

    switch (get_nth_bits(opcode, 6, 8)) {
        case 0b00:
            // TST - result is equal to the two values and'ed.
            result = memory.regs[rm] & memory.regs[rd];
            break;

        case 0b01:
            // NEG - Rd = 0 - Rm
            memory.regs[rd] = ~memory.regs[rm] + 1;
            result = memory.regs[rd];
            set_flag_C(result != 0);
            set_flag_V(get_nth_bit(result, 31) && get_nth_bit(memory.regs[rm], 31));
            break;

        case 0b10: {
            // CMP, which is basically a subtraction but the result isn't stored.
            // again, this uses the same two's complement trick that makes ADD the same as SUB.
            int32_t rm_value     = ~memory.regs[rm] + 1; // the trick is implemented here
            int32_t old_rd_value = memory.regs[rd];

            result = memory.regs[rd] + rm_value;

            // Signed carry formula = (A AND B) OR (~DEST AND (A XOR B)) - works for all add operations once tested
            set_flag_C(get_nth_bit(rm_value, 31) & get_nth_bit(old_rd_value, 31) | 
            ((get_nth_bit(rm_value, 31) ^ get_nth_bit(old_rd_value, 31)) & ~(get_nth_bit(result, 31))));

            bool matching_signs = get_nth_bit(old_rd_value, 31) == get_nth_bit(rm_value, 31);
            set_flag_V(matching_signs && (get_nth_bit(old_rd_value, 31) ^ get_nth_bit(result, 31)));
            break;
        }
        
        case 0b11: {
            // CMN - see the above note for CMP (case 0b10). CMP is to SUB what CMN is to ADD.
            int32_t rm_value     = memory.regs[rm];
            int32_t old_rd_value = memory.regs[rd];

            result = memory.regs[rd] + rm_value;

            // Signed carry formula = (A AND B) OR (~DEST AND (A XOR B)) - works for all add operations once tested
            set_flag_C(get_nth_bit(rm_value, 31) & get_nth_bit(old_rd_value, 31) | 
            ((get_nth_bit(rm_value, 31) ^ get_nth_bit(old_rd_value, 31)) & ~(get_nth_bit(result, 31))));

            bool matching_signs = get_nth_bit(old_rd_value, 31) == get_nth_bit(rm_value, 31);
            set_flag_V(matching_signs && (get_nth_bit(old_rd_value, 31) ^ get_nth_bit(result, 31)));
            break;
        }
    }

    set_flag_N(get_nth_bit(result, 31));
    set_flag_Z(result == 0);
}

// ALU operation - ORR, MUL, BIC, MVN 
void run_01000011(uint16_t opcode) {
    DEBUG_MESSAGE("ALU Operation - ORR / MUL / BIC / MVN");
    uint8_t rd = get_nth_bits(opcode, 0, 3);
    uint8_t rm = get_nth_bits(opcode, 3, 6);

    switch (get_nth_bits(opcode, 6, 8)) {
        case 0b00:
            memory.regs[rd] |= memory.regs[rm];
            break;
        case 0b01:
            memory.regs[rd] *= memory.regs[rm];
            break;
        case 0b10:
            memory.regs[rd] = memory.regs[rd] & ~ memory.regs[rm];
            break;
        case 0b11:
            memory.regs[rd] = ~memory.regs[rm];
    }

    set_flag_N(get_nth_bit(memory.regs[rd], 31));
    set_flag_Z(memory.regs[rd] == 0);
}

// ADD #4 - high registers, does not change flags
void run_01000100(uint16_t opcode) {
    uint8_t rm = get_nth_bits(opcode, 3, 7);
    uint8_t rd = get_nth_bits(opcode, 0, 3) | (get_nth_bit(opcode, 7) << 3);

    memory.regs[rd] += memory.regs[rm];
}

// CMP #4 - high registers
void run_01000101(uint16_t opcode) {
    // CMP is basically a subtraction but the result isn't stored.
    // this uses a two's complement trick that makes ADD the same as SUB.
    uint8_t rm = get_nth_bits(opcode, 3, 7);
    uint8_t rd = get_nth_bits(opcode, 0, 3) | (get_nth_bit(opcode, 7) << 3);
    int32_t rm_value     = ~memory.regs[rm] + 1; // the trick is implemented here
    int32_t old_rd_value = memory.regs[rd];

    uint32_t result = memory.regs[rd] + rm_value;

    set_flag_N(get_nth_bit(result, 31));
    set_flag_Z(result == 0);

    // Signed carry formula = (A AND B) OR (~DEST AND (A XOR B)) - works for all add operations once tested
    set_flag_C(get_nth_bit(rm_value, 31) & get_nth_bit(old_rd_value, 31) | 
    ((get_nth_bit(rm_value, 31) ^ get_nth_bit(old_rd_value, 31)) & ~(get_nth_bit(result, 31))));

    bool matching_signs = get_nth_bit(old_rd_value, 31) == get_nth_bit(rm_value, 31);
    set_flag_V(matching_signs && (get_nth_bit(old_rd_value, 31) ^ get_nth_bit(result, 31)));
}

// MOV #4 - high registers, does not change flags
void run_01000110(uint16_t opcode) {
    uint8_t rm = get_nth_bits(opcode, 3, 7);
    uint8_t rd = get_nth_bits(opcode, 0, 3) | (get_nth_bit(opcode, 7) << 3);
    memory.regs[rd] = memory.regs[rm];
}

// branch exchange
void run_01000111(uint16_t opcode) {
   uint32_t pointer = memory.regs[get_nth_bits(opcode, 3, 7)];
   *memory.pc = pointer & 0xFFFFFFFE; // the PC must be even, so we & with 0xFFFFFFFE.
   set_bit_T(pointer & 1);
}

// pc-relative load
void run_01001REG(uint16_t opcode) {
    DEBUG_MESSAGE("PC-Relative Load");
    uint8_t reg = get_nth_bits(opcode, 8,  11);
    uint32_t loc = (get_nth_bits(opcode, 0,  8) << 2) + *memory.pc + 2;
    memory.regs[reg] = *((uint32_t*)(memory.main + loc));
}

// load with relative offset
@EXCLUDE(01010000)
@EXCLUDE(01010001)
@EXCLUDE(01010010)
@EXCLUDE(01010011)
@EXCLUDE(01010100)
@EXCLUDE(01010101)
void run_0101LSBR(uint16_t opcode) {
    // 111-: LDRSH  rn + rm (load 2 bytes), sign extend
    // 110-: LDRB#2 rn + rm (load 1 byte)
    // 101-: LDRH#2 rn + rm (load 2 bytes) 
    // 100-: LDR #2 rn + rm (load 4 bytes)
    // 011-: LDRSB  rn + rm (load 1 byte),  sign extend
    uint8_t rm = get_nth_bits(opcode, 6, 9);
    uint8_t rn = get_nth_bits(opcode, 3, 6);
    uint8_t rd = get_nth_bits(opcode, 0, 3);
    @IF( L  S  B) int32_t  value = (int32_t)  *((int16_t*)  (memory.main + memory.regs[rm] + memory.regs[rn]));
    @IF( L  S !B) uint32_t value = (uint32_t) *((uint8_t*)  (memory.main + memory.regs[rm] + memory.regs[rn]));
    @IF( L !S  B) uint32_t value = (uint32_t) *((uint16_t*) (memory.main + memory.regs[rm] + memory.regs[rn]));
    @IF( L !S !B) uint32_t value = (uint32_t) *((uint32_t*) (memory.main + memory.regs[rm] + memory.regs[rn]));
    @IF(!L  S  B) int32_t  value = (int32_t)  *((int8_t*)   (memory.main + memory.regs[rm] + memory.regs[rn]));

    memory.regs[rd] = value;
}

// store sign-extended byte and halfword
@EXCLUDE(01010110)
@EXCLUDE(01010111)
void run_01010SBR(uint16_t opcode) {
    // 10-: STRB #2 rn + rm (store 1 byte)
    // 01-: STRH #2 rn + rm (store 2 bytes)
    // 00-: STR  #2 rn + rm (store 4 bytes)
    uint8_t rm = get_nth_bits(opcode, 6, 9);
    uint8_t rn = get_nth_bits(opcode, 3, 6);
    uint8_t rd = get_nth_bits(opcode, 0, 3);

    @IF( S !B) uint32_t value = memory.regs[rd] & 0xF;
    @IF(!S  B) uint32_t value = memory.regs[rd] & 0xFF;
    @IF(!S !B) uint32_t value = memory.regs[rd];

    memory.main[memory.regs[rm] + memory.regs[rn]] = value;
}

// load and store with immediate offset
void run_011BLOFS(uint16_t opcode) {
    // BL:
    // 00 - STR  #1 4 bytes (store)
    // 01 - LDR  #1 4 bytes (load)
    // 10 - STRB #1 1 byte  (store)
    // 11 - LDRB #1 1 byte  (load, zero-extend)
    uint8_t rn = get_nth_bits(opcode, 3, 6);
    uint8_t rd = get_nth_bits(opcode, 0, 3);
    uint8_t immediate_value = get_nth_bits(opcode, 6, 11);

    // looking at the table above, the B bit determines the size of the store/load, and the L bit determines whether we store or load.
    @IF(!B !L) *((uint32_t*) (memory.main + memory.regs[rn] + (immediate_value << 2))) = memory.regs[rd];
    @IF( B !L) memory.main[memory.regs[rn] + (immediate_value << 2)] = memory.regs[rd] & 0xFF;
    @IF(!B  L) memory.regs[rd] = *((uint32_t*) (memory.main + memory.regs[rn] + (immediate_value << 2)));
    @IF( B  L) memory.regs[rd] = memory.main[memory.regs[rn] + (immediate_value << 2)];
}

// load halfword
void run_10000OFS(uint16_t opcode) {
    uint8_t base  = get_nth_bits(opcode, 3,  6);
    uint8_t dest  = get_nth_bits(opcode, 0,  3);
    uint8_t shift = get_nth_bits(opcode, 6,  11);

    memory.regs[dest] = *((halfword*)(memory.main + memory.regs[base] + shift * 2));
}

// store halfword
void run_10001OFS(uint16_t opcode) {

}

// sp-relative load and store
void run_1001LREG(uint16_t opcode) {
    uint8_t rd = get_nth_bits(opcode, 8, 11);
    uint8_t immediate_value = opcode & 0xFF;

    // if L is set, we load. if L is not set, we store.
    @IF(L)  memory.regs[rd] = *((uint32_t*) (memory.main + *memory.sp + (immediate_value << 2)));
    @IF(!L) *((uint32_t*) (memory.main + *memory.sp + (immediate_value << 2))) = memory.regs[rd];
}

// load address
void run_1010SREG(uint16_t opcode) {

}

// add / subtract offset to stack pointer
void run_10110000(uint16_t opcode) {
    uint8_t offset      = get_nth_bits(opcode, 0, 7) << 2;
    bool is_subtraction = get_nth_bit(opcode, 7);
    
    if (is_subtraction) {
        *memory.sp -= offset;
    } else {
        *memory.sp += offset;
    }
}

// push registers
void run_1011010R(uint16_t opcode) {
    uint8_t register_list  = opcode & 0xFF;
    bool    is_lr_included = get_nth_bit(opcode, 8);

    // deal with the linkage register (LR)
    if (is_lr_included) {
        *memory.sp -= 4;
        *((uint32_t*)(memory.main + *memory.sp)) = *memory.lr;
    }

    // now loop backwards through the registers
    for (int i = 7; i >= 0; i--) {
        if (get_nth_bit(register_list, i)) {
            *memory.sp -= 4;
            *((uint32_t*)(memory.main + *memory.sp)) = memory.regs[i];
        }
    }
}

// pop registers
void run_1011110R(uint16_t opcode) {
    uint8_t register_list  = opcode & 0xFF;
    bool    is_lr_included = get_nth_bit(opcode, 8);

    // loop forwards through the registers
    for (int i = 0; i < 8; i++) {
        if (get_nth_bit(register_list, i)) {
            memory.regs[i] = *((uint32_t*)(memory.main + *memory.sp));
            *memory.sp += 4;
        }
    }

    // now deal with the linkage register (LR) and set it to the PC if it exists.
    if (is_lr_included) {
        *memory.pc = *((uint32_t*)(memory.main + *memory.sp));
        *memory.sp += 4;
    }
}

// multiple load
void run_11001REG(uint16_t opcode) {

}

// multiple store
void run_11000REG(uint16_t opcode) {
    DEBUG_MESSAGE("Multiple Store (STMIA)");
    uint32_t start_address = memory.regs[get_nth_bits(opcode, 8, 10)];
    uint8_t  register_list = get_nth_bits(opcode, 0, 8);

    for (int i = 0; i < 8; i++) {
        // should we store this register?
        if (get_nth_bit(register_list, i)) {
            *(uint32_t*)(memory.main + start_address) = memory.regs[i];
            start_address += 4;
            memory.regs[get_nth_bits(opcode, 8, 10)] += 4;
        }
    }
}

// conditional branch
@EXCLUDE(11011111)
void run_1101COND(uint16_t opcode) {
    // this may look daunting, but it's just the different possibilities for COND.
    // each COND has a different if expression we need to consider.
    @IF(!C !O !N !D) if (get_flag_Z()) {
    @IF(!C !O !N  D) if (!get_flag_Z()) {
    @IF(!C !O  N !D) if (get_flag_C()) {
    @IF(!C !O  N  D) if (!get_flag_C()) {
    @IF(!C  O !N !D) if (get_flag_N()) {
    @IF(!C  O !N  D) if (!get_flag_N()) {
    @IF(!C  O  N !D) if (get_flag_V()) {
    @IF(!C  O  N  D) if (!get_flag_V()) {
    @IF( C !O !N !D) if (get_flag_C() && !get_flag_Z()) {
    @IF( C !O !N  D) if (!get_flag_C() && get_flag_Z()) {
    @IF( C !O  N !D) if (get_flag_N() == get_flag_V()) {
    @IF( C !O  N  D) if (get_flag_N() ^ get_flag_V()) {
    @IF( C  O !N !D) if (!get_flag_Z() && (get_flag_N() == get_flag_V())) {
    @IF( C  O !N  D) if (get_flag_Z() || (get_flag_N() ^ get_flag_V())) {
    @IF( C  O  N !D) if (true) { // the compiler will optimize this so it's fine
        DEBUG_MESSAGE("Conditional Branch Taken");
        *memory.pc += ((int8_t)(opcode & 0xFF)) * 2 + 2;
    } else {
        DEBUG_MESSAGE("Conditional Branch Not Taken");
    }
}

// software interrupt
void run_11011111(uint16_t opcode) {

}

// unconditional branch
void run_11100OFS(uint16_t opcode) {
    DEBUG_MESSAGE("Unconditional Branch");

    int32_t sign_extended = (int32_t) (get_nth_bits(opcode, 0, 11));
    *memory.pc = (*memory.pc + 2) + (sign_extended << 1);
}

// long branch with link - high byte
void run_11110OFS(uint16_t opcode) {

    // Sign extend to 32 bits and then left shift 12
    int32_t extended = (int32_t)(get_nth_bits(opcode, 0, 11));
    *memory.lr = (*memory.pc + 2) + (extended << 12);

}

// long branch with link - low byte and call to subroutine
void run_11111OFS(uint16_t opcode) {
    uint32_t next_pc = *(memory.pc);
    *memory.pc = (*memory.lr + (get_nth_bits(opcode, 0, 11) << 1));
    *memory.lr = (next_pc) | 1;
}