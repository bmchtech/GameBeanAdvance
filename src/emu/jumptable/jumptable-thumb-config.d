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

@DEFAULT()
void nop(ushort opcode) {
    // yes. making this a warning instead of an error looks stupid
    // but some games literally try to run undefined instructions
    // so what can i do.
    warning(format("No implementation for opcode %x", opcode));
}

@LOCAL()
uint read_word_and_rotate(IMemory IMemory, uint address, AccessType access_type) {
    uint value = IMemory.read_word(address & 0xFFFFFFFC, access_type);
    if ((address & 0b11) == 0b01) value = ((value & 0xFF)     << 24) | (value >> 8);
    if ((address & 0b11) == 0b10) value = ((value & 0xFFFF)   << 16) | (value >> 16);
    if ((address & 0b11) == 0b11) value = ((value & 0xFFFFFF) << 8)  | (value >> 24);

    return value;
}

// logical shift left/right
void run_0000SABC(ushort opcode) {
    @IF(S)  //DEBUG_MESSAGE("Logical Shift Right");
    @IF(!S) //DEBUG_MESSAGE("Logical Shift Left");
    ubyte source = cast(ubyte) get_nth_bits(opcode, 3,  6);
    ubyte dest   = cast(ubyte) get_nth_bits(opcode, 0,  3);
    ubyte shift  = cast(ubyte) get_nth_bits(opcode, 6,  11);

    if (shift == 0) { // if shift == 0, the cpu shifts by 32, which is the size of the register.
        @IF(S)  cpu.set_flag_C(get_nth_bit(cpu.regs[source], 31));
        @IF(S)  cpu.regs[dest] = 0;
        @IF(!S) cpu.regs[dest] = cpu.regs[source];
    } else {
        @IF(S)  cpu.set_flag_C(get_nth_bit(cpu.regs[source], shift - 1));
        @IF(!S) cpu.set_flag_C(get_nth_bit(cpu.regs[source], 32 - shift));
        @IF(S)  cpu.regs[dest] = (cpu.regs[source] >> shift);
        @IF(!S) cpu.regs[dest] = (cpu.regs[source] << shift);
    }

    cpu.set_flag_N(get_nth_bit(cpu.regs[dest], 31));
    cpu.set_flag_Z(cpu.regs[dest] == 0);

    // _g_cpu_cycles_remaining += 2;
}

// arithmetic shift right
void run_00010ABC(ushort opcode) {
    ubyte rm    = cast(ubyte) get_nth_bits(opcode, 3,  6);  // 0
    ubyte rd    = cast(ubyte) get_nth_bits(opcode, 0,  3);  // 1
    ubyte shift = cast(ubyte) get_nth_bits(opcode, 6,  11); // 31 

    if (shift == 0) {
        cpu.set_flag_C(cpu.regs[rm] >> 31);
        if ((cpu.regs[rm] >> 31) == 0) cpu.regs[rd] = 0x00000000;
        else                           cpu.regs[rd] = 0xFFFFFFFF;
    } else {
        cpu.set_flag_C(get_nth_bit(cpu.regs[rm], shift - 1));
        // arithmetic shift requires us to cast to signed int first, then back to unsigned to store in registers.
        cpu.regs[rd] = cast(uint) ((cast(int) cpu.regs[rm]) >> shift);
    }

    cpu.set_flag_N(cpu.regs[rd] >> 31);
    cpu.set_flag_Z(cpu.regs[rd] == 0);

    // _g_cpu_cycles_remaining += 2;
}

// add #3 010 001 001
void run_0001100A(ushort opcode) {
    //DEBUG_MESSAGE("Add #3");

    int rn = cpu.regs[get_nth_bits(opcode, 3, 6)];
    int rm = cpu.regs[get_nth_bits(opcode, 6, 9)];
    
    cpu.regs[get_nth_bits(opcode, 0, 3)] = rn + rm;
    int rd = cpu.regs[get_nth_bits(opcode, 0, 3)];

    cpu.set_flag_N(get_nth_bit(rd, 31));
    cpu.set_flag_Z(rd == 0);
    // cpu.set_flag_C((uint64_t)rn + (uint64_t)rm > rd); // probably can be optimized

    // Signed carry formula = (A AND B) OR (~DEST AND (A XOR B)) - works for all add operations once tested
    cpu.set_flag_C((get_nth_bit(rm, 31) & get_nth_bit(rn, 31)) | 
    ((get_nth_bit(rm, 31) ^ get_nth_bit(rn, 31)) & ~(cast(uint)get_nth_bit(rd, 31))));


    // this is garbage, but essentially what's going on is:
    // if the two operands had matching signs but their sign differed from the result's sign,
    // then there was an overflow and we set the flag.
    bool matching_signs = get_nth_bit(rn, 31) == get_nth_bit(rm, 31);
    cpu.set_flag_V(matching_signs && (get_nth_bit(rn, 31) ^ cpu.get_flag_N()));

    // _g_cpu_cycles_remaining += 1;
}

// sub #3 010 001 001
void run_0001101A(ushort opcode) {
    //DEBUG_MESSAGE("Sub #3");

    uint rn = cpu.regs[get_nth_bits(opcode, 3, 6)];
    uint rm = ~cpu.regs[get_nth_bits(opcode, 6, 9)] + 1;
    
    cpu.regs[get_nth_bits(opcode, 0, 3)] = rn + rm;
    uint rd = cpu.regs[get_nth_bits(opcode, 0, 3)];

    cpu.set_flag_N(get_nth_bit(rd, 31));
    cpu.set_flag_Z(rd == 0);
    // cpu.set_flag_C((uint64_t)rn + (uint64_t)rm > rd); // probably can be optimized

    // Signed carry formula = (A AND B) OR (~DEST AND (A XOR B)) - works for all add operations once tested
    cpu.set_flag_C((!((cast(ulong)rn) < cpu.regs[get_nth_bits(opcode, 6, 9)])));


    // this is garbage, but essentially what's going on is:
    // if the two operands had matching signs but their sign differed from the result's sign,
    // then there was an overflow and we set the flag.
    bool matching_signs = get_nth_bit(rn, 31) == get_nth_bit(cpu.regs[get_nth_bits(opcode, 6, 9)], 31);
    cpu.set_flag_V(!matching_signs && (get_nth_bit(cpu.regs[get_nth_bits(opcode, 6, 9)], 31) == cpu.get_flag_N()));

    // _g_cpu_cycles_remaining += 1;
}

// add #1 
void run_0001110A(ushort opcode) {
    int immediate_value = get_nth_bits(opcode, 6, 9);
    int rn_value        = cpu.regs[get_nth_bits(opcode, 3, 6)];

    cpu.regs[get_nth_bits(opcode, 0, 3)] = immediate_value + rn_value;
    int rd_value = cpu.regs[get_nth_bits(opcode, 0, 3)];

    cpu.set_flag_N(get_nth_bit(rd_value, 31));
    cpu.set_flag_Z(rd_value == 0);

    // Signed carry formula = (A AND B) OR (~DEST AND (A XOR B)) - works for all add operations once tested
    cpu.set_flag_C((get_nth_bit(immediate_value, 31) & get_nth_bit(rn_value, 31)) | 
    ((get_nth_bit(immediate_value, 31) ^ get_nth_bit(rn_value, 31)) & ~(cast(uint)get_nth_bit(rd_value, 31))));

    bool matching_signs = get_nth_bit(immediate_value, 31) == get_nth_bit(rn_value, 31);
    cpu.set_flag_V(matching_signs && (get_nth_bit(immediate_value, 31) ^ cpu.get_flag_N()));

    // _g_cpu_cycles_remaining += 1;
}

// Subtract #1
void run_0001111A(ushort opcode) {
    int immediate_value = (~get_nth_bits(opcode, 6, 9)) + 1;
    int rn_value        = cpu.regs[get_nth_bits(opcode, 3, 6)];

    cpu.regs[get_nth_bits(opcode, 0, 3)] = rn_value + immediate_value;
    int rd_value = cpu.regs[get_nth_bits(opcode, 0, 3)];

    cpu.set_flag_N(get_nth_bit(rd_value, 31));
    cpu.set_flag_Z(rd_value == 0);

    // Signed carry formula = (A AND B) OR (~DEST AND (A XOR B)) - works for all add operations once tested
    cpu.set_flag_C((!((cast(ulong)cpu.regs[get_nth_bits(opcode, 3, 6)]) < get_nth_bits(opcode, 6, 9))));

    bool matching_signs = get_nth_bit(rn_value, 31) == get_nth_bit(get_nth_bits(opcode, 6, 9), 31);
    cpu.set_flag_V(!matching_signs && (get_nth_bit(get_nth_bits(opcode, 6, 9), 31) == cpu.get_flag_N()));

    // _g_cpu_cycles_remaining += 1;
}

// move immediate
void run_00100ABC(ushort opcode) {
    //DEBUG_MESSAGE("Move Immediate");

    ushort immediate_value = cast(ushort) get_nth_bits(opcode, 0, 8);
    cpu.regs[get_nth_bits(opcode, 8, 11)] = immediate_value;
    // flags
    cpu.set_flag_N(get_nth_bit(immediate_value, 31));
    cpu.set_flag_Z(immediate_value == 0);

    // _g_cpu_cycles_remaining += 1;
}

// compare immediate
void run_00101ABC(ushort opcode) {
    ubyte immediate_value = cast(ubyte) get_nth_bits(opcode, 0, 8);

    // CMP, which is basically a subtraction but the result isn't stored.
    // this uses the same two's complement trick that makes ADD the same as SUB.
    int rn_value     = ~cast(int)immediate_value + 1; // the trick is implemented here
    int old_rd_value = cpu.regs[get_nth_bits(opcode, 8, 11)];
    
    uint result = old_rd_value + rn_value;

    cpu.set_flag_Z(result == 0);
    cpu.set_flag_N(result >> 31);

    // Signed carry formula = (A AND B) OR (~DEST AND (A XOR B)) - works for all add operations once tested
    cpu.set_flag_C(!(immediate_value > cast(uint)old_rd_value));

    bool matching_signs = get_nth_bit(old_rd_value, 31) == get_nth_bit(immediate_value, 31);
    cpu.set_flag_V(!matching_signs && (get_nth_bit(old_rd_value, 31) ^ get_nth_bit(result, 31)));

    // _g_cpu_cycles_remaining += 1;
}

// add immediate
void run_00110ABC(ushort opcode) {
    //DEBUG_MESSAGE("Add Register Immediate");

    int immediate_value = get_nth_bits(opcode, 0, 8);
    uint rd             = get_nth_bits(opcode, 8, 11);
    int old_rd_value    = cpu.regs[rd];

    cpu.regs[rd] += immediate_value;
    int new_rd_value    = cpu.regs[rd];

    cpu.set_flag_N(get_nth_bit(new_rd_value, 31));
    cpu.set_flag_Z((new_rd_value == 0));

    // Signed carry formula = (A AND B) OR (~DEST AND (A XOR B)) - works for all add operations once tested
    cpu.set_flag_C((get_nth_bit(immediate_value, 31) & get_nth_bit(old_rd_value, 31)) | 
    ((get_nth_bit(immediate_value, 31) ^ get_nth_bit(old_rd_value, 31)) & ~(cast(uint)get_nth_bit(new_rd_value, 31))));

    bool matching_signs = get_nth_bit(old_rd_value, 31) == get_nth_bit(immediate_value, 31);
    cpu.set_flag_V(matching_signs && (get_nth_bit(old_rd_value, 31) ^ cpu.get_flag_N()));

    // _g_cpu_cycles_remaining += 1;
}

// subtract immediate
void run_00111ABC(ushort opcode) {
    // maybe we can link add immediate with subtract immediate using twos complement...
    // like, a - b is the same as a + (~b)
    //DEBUG_MESSAGE("Subtract Immediate");

    uint immediate_value = get_nth_bits(opcode, 0, 8);
    ubyte  rd            = cast(ubyte) get_nth_bits(opcode, 8, 11);
    uint old_rd_value    = cpu.regs[rd];
    
    cpu.regs[rd]  -= immediate_value;
    uint new_rd_value    = cpu.regs[rd];

    cpu.set_flag_N(get_nth_bit(new_rd_value, 31));
    cpu.set_flag_Z(new_rd_value == 0);
    cpu.set_flag_C(immediate_value <= old_rd_value);

    // this is garbage, but essentially what's going on is:
    // if the two operands had matching signs but their sign differed from the result's sign,
    // then there was an overflow and we set the flag.
    /*
    bool matching_signs = get_nth_bit(old_rd_value, 31) == get_nth_bit(immediate_value, 31);
    cpu.set_flag_V(matching_signs && (get_nth_bit(new_rd_value, 31) ^ cpu.get_flag_N()));*/
    bool matching_signs = get_nth_bit(old_rd_value, 31) == get_nth_bit(immediate_value, 31);
    cpu.set_flag_V(!matching_signs && (get_nth_bit(immediate_value, 31) == cpu.get_flag_N()));

    // _g_cpu_cycles_remaining += 1;
}

// ALU operation - AND, EOR, LSL #2, LSR #2
void run_01000000(ushort opcode) {
    //DEBUG_MESSAGE("ALU Operation - AND / EOR / LSL #2 / LSR #2");
    ubyte rd = cast(ubyte) get_nth_bits(opcode, 0, 3);
    ubyte rm = cast(ubyte) get_nth_bits(opcode, 3, 6);

    switch (get_nth_bits(opcode, 6, 8)) {
        case 0b00:
            cpu.regs[rd] &= cpu.regs[rm];
            break;
        case 0b01:
            cpu.regs[rd] ^= cpu.regs[rm];
            break;
        case 0b10:
            if ((cpu.regs[rm] & 0xFF) < 32 && (cpu.regs[rm] & 0xFF) != 0) {
                cpu.set_flag_C(get_nth_bit(cpu.regs[rd], 32 - (cpu.regs[rm] & 0xFF)));
                cpu.regs[rd] <<= (cpu.regs[rm] & 0xFF);
            } else if ((cpu.regs[rm] & 0xFF) == 32) {
                cpu.set_flag_C(cpu.regs[rd] & 1);
                cpu.regs[rd] = 0;
            } else if ((cpu.regs[rm] & 0xFF) > 32) {
                cpu.set_flag_C(false);
                cpu.regs[rd] = 0;
            }
            
            cpu.run_idle_cycle();
            break;
        case 0b11:
            if ((cpu.regs[rm] & 0xFF) < 32 && (cpu.regs[rm] & 0xFF) != 0) {
                cpu.set_flag_C(get_nth_bit(cpu.regs[rd], (cpu.regs[rm] & 0xFF) - 1));
                cpu.regs[rd] >>= (cpu.regs[rm] & 0xFF);
            } else if ((cpu.regs[rm] & 0xFF) == 32) {
                cpu.set_flag_C(cpu.regs[rd] >> 31);
                cpu.regs[rd] = 0;
            } else if ((cpu.regs[rm] & 0xFF) > 32) {
                cpu.set_flag_C(false);
                cpu.regs[rd] = 0;
            }

            cpu.run_idle_cycle();
            break;
        
        default: assert(0);
    }

    cpu.set_flag_N(cpu.regs[rd] >> 31);
    cpu.set_flag_Z(cpu.regs[rd] == 0);

    // _g_cpu_cycles_remaining += 1;
}

// ALU operation - ASR #2, ADC, SBC, ROR
void run_01000001(ushort opcode) {
    //DEBUG_MESSAGE("ALU Operation - ASR #2 / ADC / SBC / ROR");
    ubyte rd = cast(ubyte) get_nth_bits(opcode, 0, 3);
    ubyte rm = cast(ubyte) get_nth_bits(opcode, 3, 6);

    switch (get_nth_bits(opcode, 6, 8)) {
        case 0b00: {
            // ASR #2
            ubyte low_byte = cast(ubyte) (cpu.regs[rm] & 0xFF);
            if (low_byte < 32 && low_byte != 0) {
                cpu.set_flag_C(get_nth_bit(cpu.regs[rd], low_byte - 1));
                // arithmetic shift requires us to cast to signed int first, then back to unsigned to store in registers.
                cpu.regs[rd] = cast(uint) ((cast(int) cpu.regs[rd]) >> low_byte);
            } else if (low_byte >= 32) {
                cpu.set_flag_C(cpu.regs[rd] >> 31);
                if (cpu.get_flag_C()) {
                    cpu.regs[rd] = 0xFFFFFFFF; // taking into account two's complement
                } else {
                    cpu.regs[rd] = 0x00000000;
                }
            }

            cpu.run_idle_cycle();
            break;
        }
        
        case 0b01: {
            // ADC - this code will look very similar to the Add Register instruction. it just also utilizes the carry bit.
            int rm_value     = cpu.regs[rm];
            int old_rd_value = cpu.regs[rd];

            cpu.regs[rd] += rm_value + cpu.get_flag_C();
            int new_rd_value = cpu.regs[rd];

            cpu.set_flag_N(get_nth_bit(new_rd_value, 31));
            cpu.set_flag_Z((new_rd_value == 0));

            // Signed carry formula = (A AND B) OR (~DEST AND (A XOR B)) - works for all add operations once tested
            cpu.set_flag_C((get_nth_bit(rm_value, 31) & get_nth_bit(old_rd_value, 31)) | 
            ((get_nth_bit(rm_value, 31) ^ get_nth_bit(old_rd_value, 31)) & ~(cast(uint)get_nth_bit(new_rd_value, 31))));

            bool matching_signs = get_nth_bit(old_rd_value, 31) == get_nth_bit(rm_value, 31);
            cpu.set_flag_V(matching_signs && (get_nth_bit(old_rd_value, 31) ^ cpu.get_flag_N()));
            break;
        }

        case 0b10: {
            // SBC - using a twos complement trick, SBC will just be the same thing as ADC, just with a negative rm_value.
            int rm_value     = ~cpu.regs[rm] + 1; // the trick is implemented here
            int old_rd_value = cpu.regs[rd];

            cpu.regs[rd] += rm_value - (cpu.get_flag_C() ? 0 : 1); // as well as over here
            int new_rd_value = cpu.regs[rd];

            cpu.set_flag_N(get_nth_bit(new_rd_value, 31));
            cpu.set_flag_Z((new_rd_value == 0));

            // bool matching_signs = get_nth_bit(old_rd_value, 31) == get_nth_bit(rm_value - (cpu.get_flag_C() ? 0 : 1), 31);
            // cpu.set_flag_V(matching_signs && (get_nth_bit(old_rd_value, 31) ^ cpu.get_flag_N()));
            bool matching_signs = get_nth_bit(old_rd_value, 31) == get_nth_bit(cpu.regs[rm], 31);
            cpu.set_flag_V(!matching_signs && (get_nth_bit(cpu.regs[rm], 31) == cpu.get_flag_N()));

            // Signed carry formula = (A AND B) OR (~DEST AND (A XOR B)) - works for all add operations once tested
            cpu.set_flag_C((!((cast(ulong)cpu.regs[rm]) + (cpu.get_flag_C() ? 0 : 1) > cast(uint)old_rd_value)));
            break;
        }

        case 0b11: {
            // ROR - Rotates the register to the right by cpu.regs[rm]
            if ((cpu.regs[rm] & 0xFF) == 0) 
                break;

            if ((cpu.regs[rm] & 0x1F) == 0) {
                cpu.set_flag_C(get_nth_bit(cpu.regs[rd], 31));
            } else {
                cpu.set_flag_C(get_nth_bit(cpu.regs[rd], (cpu.regs[rm] & 0x1F) - 1));
                uint rotated_off = get_nth_bits(cpu.regs[rd], 0, cpu.regs[rm] & 0x1F);  // the value that is rotated off
                uint rotated_in  = get_nth_bits(cpu.regs[rd], cpu.regs[rm] & 0x1F, 32); // the value that stays after the rotation
                cpu.regs[rd] = rotated_in | (rotated_off << (32 - (cpu.regs[rm] & 0x1F)));
            }

            cpu.run_idle_cycle();
            break;
        }
        
        default: assert(0);
    }

    // _g_cpu_cycles_remaining += 1;
    cpu.set_flag_N(cpu.regs[rd] >> 31);
    cpu.set_flag_Z(cpu.regs[rd] == 0);
}

// ALU operation - TST, NEG, CMP #2, CMN
void run_01000010(ushort opcode) {
    //DEBUG_MESSAGE("ALU Operation - TST / NEG / CMP #2 / CMN");
    ubyte rd = cast(ubyte) get_nth_bits(opcode, 0, 3);
    ubyte rm = cast(ubyte) get_nth_bits(opcode, 3, 6);
    uint result;

    switch (get_nth_bits(opcode, 6, 8)) {
        case 0b00:
            // TST - result is equal to the two values and'ed.
            result = cpu.regs[rm] & cpu.regs[rd];
            break;

        case 0b01:
            // NEG - Rd = 0 - Rm
            cpu.regs[rd] = ~cpu.regs[rm] + 1;
            result = cpu.regs[rd];
            cpu.set_flag_C(result == 0);
            cpu.set_flag_V(get_nth_bit(result, 31) && get_nth_bit(cpu.regs[rm], 31));
            break;

        case 0b10: {
            // warning(format("%x %x", cpu.regs[rm], cpu.regs[rd]));
            // CMP, which is basically a subtraction but the result isn't stored.
            // again, this uses the same two's complement trick that makes ADD the same as SUB.
            uint rm_value     = ~cpu.regs[rm] + 1; // the trick is implemented here
            uint old_rd_value = cpu.regs[rd];

            result = cpu.regs[rd] + rm_value;

            // Signed carry formula = (A AND B) OR (~DEST AND (A XOR B)) - works for all add operations once tested
            cpu.set_flag_C(!(cpu.regs[rm] > cpu.regs[rd]));

            bool matching_signs = get_nth_bit(old_rd_value, 31) == get_nth_bit(cpu.regs[rm], 31);
            cpu.set_flag_V(!matching_signs && (get_nth_bit(old_rd_value, 31) ^ get_nth_bit(result, 31)));

            break;
        }
        
        case 0b11: {
            // CMN - see the above note for CMP (case 0b10). CMP is to SUB what CMN is to ADD.
            int rm_value     = cpu.regs[rm];
            int old_rd_value = cpu.regs[rd];

            result = cpu.regs[rd] + rm_value;

            // Signed carry formula = (A AND B) OR (~DEST AND (A XOR B)) - works for all add operations once tested
            cpu.set_flag_C((get_nth_bit(rm_value, 31) & get_nth_bit(old_rd_value, 31)) | 
            ((get_nth_bit(rm_value, 31) ^ get_nth_bit(old_rd_value, 31)) & ~(cast(uint)get_nth_bit(result, 31))));

            bool matching_signs = get_nth_bit(old_rd_value, 31) == get_nth_bit(rm_value, 31);
            cpu.set_flag_V(matching_signs && (get_nth_bit(old_rd_value, 31) ^ get_nth_bit(result, 31)));
            break;
        }
        
        default: assert(0);
    }

    // _g_cpu_cycles_remaining += 1;
    cpu.set_flag_N(get_nth_bit(result, 31));
    cpu.set_flag_Z(result == 0);
}

// ALU operation - ORR, MUL, BIC, MVN 
void run_01000011(ushort opcode) {
    //DEBUG_MESSAGE("ALU Operation - ORR / MUL / BIC / MVN");
    ubyte rd = cast(ubyte) get_nth_bits(opcode, 0, 3);
    ubyte rm = cast(ubyte) get_nth_bits(opcode, 3, 6);

    switch (get_nth_bits(opcode, 6, 8)) {
        case 0b00:
            cpu.regs[rd] |= cpu.regs[rm];
            break;
        case 0b01:
            // m is the the number of extra cycles required by multiplication
            int m = 4;
            uint operand = cpu.regs[rd];
            if      ((operand >> 8)  == 0x0 || (operand >> 8)  == 0xFFFFFF) m = 1;
            else if ((operand >> 16) == 0x0 || (operand >> 16) == 0xFFFF)   m = 2;
            else if ((operand >> 24) == 0x0 || (operand >> 24) == 0xFF)     m = 3;

            for (int i = 0; i < m; i++) cpu.run_idle_cycle();

            cpu.regs[rd] *= cpu.regs[rm];
            break;
        case 0b10:
            cpu.regs[rd] = cpu.regs[rd] & ~ cpu.regs[rm];
            break;
        case 0b11:
            cpu.regs[rd] = ~cpu.regs[rm];
            break;
        
        default: assert(0);
    }

    // _g_cpu_cycles_remaining += 1;
    cpu.set_flag_N(get_nth_bit(cpu.regs[rd], 31));
    cpu.set_flag_Z(cpu.regs[rd] == 0);
}

// ADD #4 - high registers, does not change flags
void run_01000100(ushort opcode) {
    ubyte rm = cast(ubyte) get_nth_bits(opcode, 3, 7);
    ubyte rd = cast(ubyte) (get_nth_bits(opcode, 0, 3) | (get_nth_bit(opcode, 7) << 3));

    if (rd == 15) cpu.regs[rd] -= 2;
    if (rm == 15) cpu.regs[rd] -= 2;

    cpu.regs[rd] += cpu.regs[rm];

    if (rd == 15) {
        cpu.regs[15] &= ~1;
        cpu.refill_pipeline();
    }
     
    // _g_cpu_cycles_remaining += 1;
}

// CMP #4 - high registers
void run_01000101(ushort opcode) {
    // CMP is basically a subtraction but the result isn't stored.
    // this uses a two's complement trick that makes ADD the same as SUB.
    ubyte rm = cast(ubyte) get_nth_bits(opcode, 3, 7);
    ubyte rd = cast(ubyte) get_nth_bits(opcode, 0, 3) | (get_nth_bit(opcode, 7) << 3);

    if (rd == 15) cpu.regs[rd] -= 2;
    if (rm == 15) cpu.regs[rd] -= 2;

    int rm_value     = ~cpu.regs[rm] + 1; // the trick is implemented here
    int old_rd_value = cpu.regs[rd];

    uint result = cpu.read_reg(rd) + rm_value;

    cpu.set_flag_N(get_nth_bit(result, 31));
    cpu.set_flag_Z(result == 0);

    // Signed carry formula = (A AND B) OR (~DEST AND (A XOR B)) - works for all add operations once tested
    cpu.set_flag_C(!(cpu.read_reg(rm) > cpu.read_reg(rd)));

    bool matching_signs = get_nth_bit(old_rd_value, 31) == get_nth_bit(rm_value, 31);
    cpu.set_flag_V(matching_signs && (get_nth_bit(old_rd_value, 31) ^ get_nth_bit(result, 31)));

    // _g_cpu_cycles_remaining += 1;
}

// MOV #3 - high registers, does not change flags
void run_01000110(ushort opcode) {
    ubyte rm = cast(ubyte) get_nth_bits(opcode, 3, 7);
    ubyte rd = cast(ubyte) (get_nth_bits(opcode, 0, 3) | (get_nth_bit(opcode, 7) << 3));
    cpu.regs[rd] = cpu.read_reg(rm);

    if (rd == 15) {
        // the least significant bit of pc (cpu.regs[15]) must be clear.
        cpu.regs[rd] &= 0xFFFFFFFE;
        cpu.refill_pipeline();
    }

    // _g_cpu_cycles_remaining += 1;
}

// branch exchange
void run_01000111(ushort opcode) {
    uint pointer = cpu.read_reg(get_nth_bits(opcode, 3, 7));
//    warning(format("%x %x", pointer, get_nth_bits(opcode, 3, 7)));
    *cpu.pc = pointer & ((pointer & 1) ? ~1 : ~3); // the PC must be even, so we & with 0xFFFFFFFE.

    cpu.set_bit_T(pointer & 1);
    
    cpu.refill_pipeline();
}

// pc-relative load
void run_01001REG(ushort opcode) {
    //DEBUG_MESSAGE("PC-Relative Load");
    ubyte reg = cast(ubyte) (get_nth_bits(opcode, 8,  11));
    uint loc = (get_nth_bits(opcode, 0,  8) << 2) + ((*cpu.pc - 2) & 0xFFFFFFFC);

    cpu.run_idle_cycle();
    cpu.regs[reg] = read_word_and_rotate(cpu.memory, loc, AccessType.NONSEQUENTIAL);
}

// load with relative offset
@EXCLUDE(01010000)
@EXCLUDE(01010001)
@EXCLUDE(01010010)
@EXCLUDE(01010011)
@EXCLUDE(01010100)
@EXCLUDE(01010101)
void run_0101LSBR(ushort opcode) {
    // 111-: LDRSH  rn + rm (load 2 bytes), sign extend
    // 110-: LDRB#2 rn + rm (load 1 byte)
    // 101-: LDRH#2 rn + rm (load 2 bytes) 
    // 100-: LDR #2 rn + rm (load 4 bytes)
    // 011-: LDRSB  rn + rm (load 1 byte),  sign extend
    ubyte rm = cast(ubyte) get_nth_bits(opcode, 6, 9);
    ubyte rn = cast(ubyte) get_nth_bits(opcode, 3, 6);
    ubyte rd = cast(ubyte) get_nth_bits(opcode, 0, 3);
    uint address = cpu.regs[rm] + cpu.regs[rn];

    cpu.pipeline_access_type = AccessType.NONSEQUENTIAL;
    @IF( L  S  B) int  value = cast(uint)            (cpu.memory.read_halfword(address & 0xFFFFFFFE, AccessType.NONSEQUENTIAL));
    @IF( L  S !B) uint value = cast(uint)            (cpu.memory.read_byte    (address,              AccessType.NONSEQUENTIAL));
    @IF( L !S  B) uint value = cast(uint)            (cpu.memory.read_halfword(address & 0xFFFFFFFE, AccessType.NONSEQUENTIAL));
    @IF(!L  S  B) int  value = cast(uint) sign_extend(cpu.memory.read_byte    (address,              AccessType.NONSEQUENTIAL), 8);

    @IF( L !S !B) uint value = cast(uint)            (read_word_and_rotate(cpu.memory, (address & 0xFFFFFFFC), AccessType.NONSEQUENTIAL));

    @IF( L !S !B) if ((address & 0b11) == 0b01) value = ((value & 0xFF)     << 24) | (value >> 8);
    @IF( L !S !B) if ((address & 0b11) == 0b10) value = ((value & 0xFFFF)   << 16) | (value >> 16);
    @IF( L !S !B) if ((address & 0b11) == 0b11) value = ((value & 0xFFFFFF) << 8)  | (value >> 24);
    
    @IF( L !S  B) if ((address & 0b1 ) == 0b1 ) value = ((value & 0xFF)     << 24) | (value >> 8);

    @IF( L  S  B) if ((address & 0b1 ) == 0b1 ) value = sign_extend(value >> 8, 8); // get this - if LDRSH acts on an odd address, it acts like LDRSB
    @IF( L  S  B) else                          value = sign_extend(value,      16);

    cpu.regs[rd] = value;

    // _g_cpu_cycles_remaining += 3;
}

// store sign-extended byte and halfword
@EXCLUDE(01010110)
@EXCLUDE(01010111)
void run_01010SBR(ushort opcode) {
    // 10-: STRB #2 rn + rm (store 1 byte)
    // 01-: STRH #2 rn + rm (store 2 bytes)
    // 00-: STR  #2 rn + rm (store 4 bytes)
    ubyte rm = cast(ubyte) get_nth_bits(opcode, 6, 9);
    ubyte rn = cast(ubyte) get_nth_bits(opcode, 3, 6);
    ubyte rd = cast(ubyte) get_nth_bits(opcode, 0, 3);

    @IF( S !B) uint value = cpu.regs[rd] & 0xFF;
    @IF(!S  B) uint value = cpu.regs[rd] & 0xFFFF;
    @IF(!S !B) uint value = cpu.regs[rd];
    
    cpu.pipeline_access_type = AccessType.NONSEQUENTIAL;

    @IF( S !B) cpu.memory.write_byte    (cpu.regs[rm] + cpu.regs[rn], cast(ubyte)  value, AccessType.NONSEQUENTIAL);
    @IF(!S  B) cpu.memory.write_halfword(cpu.regs[rm] + cpu.regs[rn], cast(ushort) value, AccessType.NONSEQUENTIAL);
    @IF(!S !B) cpu.memory.write_word    (cpu.regs[rm] + cpu.regs[rn], value,              AccessType.NONSEQUENTIAL);

    // _g_cpu_cycles_remaining += 2;
}

// load and store with immediate offset
void run_011BLOFS(ushort opcode) {
    // BL:
    // 00 - STR  #1 4 bytes (store)
    // 01 - LDR  #1 4 bytes (load)
    // 10 - STRB #1 1 byte  (store)
    // 11 - LDRB #1 1 byte  (load, zero-extend)
    ubyte rn = cast(ubyte) get_nth_bits(opcode, 3, 6);
    ubyte rd = cast(ubyte) get_nth_bits(opcode, 0, 3);
    ubyte immediate_value = cast(ubyte) get_nth_bits(opcode, 6, 11);

    cpu.pipeline_access_type = AccessType.NONSEQUENTIAL;
    // looking at the table above, the B bit determines the size of the store/load, and the L bit determines whether we store or load.
    @IF(!B !L) cpu.memory.write_word(cpu.regs[rn] + (immediate_value << 2), cpu.regs[rd],                      AccessType.NONSEQUENTIAL);
    @IF( B !L) cpu.memory.write_byte(cpu.regs[rn] + (immediate_value),      cast(ubyte) (cpu.regs[rd] & 0xFF), AccessType.NONSEQUENTIAL);
    
    
    @IF(L)  cpu.run_idle_cycle();
    @IF(!L) cpu.pipeline_access_type = AccessType.NONSEQUENTIAL;

    @IF(!B  L) cpu.regs[rd] = read_word_and_rotate(cpu.memory, cpu.regs[rn] + (immediate_value << 2), AccessType.NONSEQUENTIAL);
    @IF( B  L) cpu.regs[rd] = cpu.memory.read_byte(cpu.regs[rn] + immediate_value, AccessType.NONSEQUENTIAL);
}

// store halfword
void run_10000OFS(ushort opcode) {
    ubyte rn     = cast(ubyte) get_nth_bits(opcode, 3, 6);
    ubyte rd     = cast(ubyte) get_nth_bits(opcode, 0, 3);
    ubyte offset = cast(ubyte) get_nth_bits(opcode, 6, 11);
    
    cpu.memory.write_halfword(cpu.regs[rn] + (offset << 1), cast(ushort) cpu.regs[rd], AccessType.NONSEQUENTIAL);

    // _g_cpu_cycles_remaining += 2;
}

// load halfword
void run_10001OFS(ushort opcode) {
    ubyte rn     = cast(ubyte) get_nth_bits(opcode, 3, 6);
    ubyte rd     = cast(ubyte) get_nth_bits(opcode, 0, 3);
    ubyte offset = cast(ubyte) get_nth_bits(opcode, 6, 11);
    
    cpu.regs[rd] = cpu.memory.read_halfword(cpu.regs[rn] + offset * 2, AccessType.NONSEQUENTIAL);

    // _g_cpu_cycles_remaining += 3;
}

// sp-relative load and store
void run_1001LREG(ushort opcode) {
    ubyte rd = cast(ubyte) (get_nth_bits(opcode, 8, 11));
    ubyte immediate_value = cast(ubyte) (opcode & 0xFF);

    // if L is set, we load. if L is not set, we store.
    @IF(L)  cpu.regs[rd] = read_word_and_rotate(cpu.memory, *cpu.sp + (immediate_value << 2), AccessType.NONSEQUENTIAL);
    @IF(!L) cpu.memory.write_word(*cpu.sp + (immediate_value << 2), cpu.regs[rd], AccessType.NONSEQUENTIAL);

    // _g_cpu_cycles_remaining += 2;
    @IF( L) // _g_cpu_cycles_remaining += 1;
}

// add #5 / #6 - PC and SP relative respectively
void run_1010SREG(ushort opcode) {
    ubyte rd = cast(ubyte) (get_nth_bits(opcode, 8, 11));
    ubyte immediate_value = cast(ubyte) (opcode & 0xFF);
    @IF( S) cpu.regs[rd] =   *cpu.sp                    + (immediate_value << 2);
    @IF(!S) cpu.regs[rd] = ((*cpu.pc - 2) & 0xFFFFFFFC) + (immediate_value << 2);

    // _g_cpu_cycles_remaining += 3;
}

// add / subtract offset to stack pointer
void run_10110000(ushort opcode) {
    ushort offset     = cast(ushort) (get_nth_bits(opcode, 0, 7) << 2);
    bool is_subtraction = get_nth_bit(opcode, 7);
    
    if (is_subtraction) {
        *cpu.sp -= offset;
    } else {
        *cpu.sp += offset;
    }

    // _g_cpu_cycles_remaining += 1;
}

// push registers
void run_1011010R(ushort opcode) {
    // warning(format("%x", *cpu.sp));
    ubyte register_list  = cast(ubyte) (opcode & 0xFF);
    bool    is_lr_included = get_nth_bit(opcode, 8);

    AccessType access_type = AccessType.NONSEQUENTIAL;
    // deal with the linkage register (LR)
    if (is_lr_included) {
        *cpu.sp -= 4;
        cpu.memory.write_word(*cpu.sp, *cpu.lr, access_type);
        access_type = AccessType.SEQUENTIAL;
    }

    int num_pushed = 0;
    // now loop backwards through the registers
    for (int i = 7; i >= 0; i--) {
        if (get_nth_bit(register_list, i)) {
            *cpu.sp -= 4;
            cpu.memory.write_word(*cpu.sp, cpu.regs[i], access_type);
            num_pushed++;
            access_type = AccessType.SEQUENTIAL;
        }
    }

    // _g_cpu_cycles_remaining += num_pushed + 1;
}

// pop registers
void run_1011110R(ushort opcode) {
    ubyte register_list  = cast(ubyte) (opcode & 0xFF);
    bool    is_lr_included = get_nth_bit(opcode, 8);

    AccessType access_type = AccessType.NONSEQUENTIAL;
    // loop forwards through the registers
    for (int i = 0; i < 8; i++) {
        if (get_nth_bit(register_list, i)) {
            cpu.regs[i] = read_word_and_rotate(cpu.memory, *cpu.sp, access_type);
            *cpu.sp += 4;

            access_type = AccessType.SEQUENTIAL;
        }
    }

    // now deal with the linkage register (LR) and set it to the PC if it exists.
    if (is_lr_included) {
        *cpu.pc = read_word_and_rotate(cpu.memory, *cpu.sp, access_type) & 0xFFFFFFFE;
        *cpu.sp += 4;

        cpu.run_idle_cycle();
        cpu.refill_pipeline();
    }

    // _g_cpu_cycles_remaining += num_pushed + 2;
}

// multiple load
void run_11001REG(ushort opcode) {
    ubyte rn               = cast(ubyte) get_nth_bits(opcode, 8, 11);
    ubyte register_list    = cast(ubyte) (opcode & 0xFF);
    uint current_address = cpu.regs[rn];

    // should we update rn after the LDMIA?
    // only happens if rn wasn't in register_list.
    bool update_rn         = true;
    int num_pushed         = 0;
    for (int i = 0; i < 8; i++) {
        if (get_nth_bit(register_list, i)) {
            if (rn == i) {
                update_rn = false;
            }

            cpu.regs[i] = cpu.memory.read_word(current_address, AccessType.NONSEQUENTIAL);
            current_address += 4;
            num_pushed++;
        }
    }

    if (update_rn) {
        cpu.regs[rn] = current_address;
    }

    // _g_cpu_cycles_remaining += num_pushed + 2;
}

// multiple store
void run_11000REG(ushort opcode) {
    // warning(format("STMIA"));
    //DEBUG_MESSAGE("Multiple Store (STMIA)");
    uint* start_address = &cpu.regs[0] + get_nth_bits(opcode, 8, 11);
    ubyte   register_list = cast(ubyte) get_nth_bits(opcode, 0, 8);

    AccessType access_type = AccessType.NONSEQUENTIAL;

    int num_pushed          = 0;
    for (int i = 0; i < 8; i++) {
        // should we store this register?
        if (get_nth_bit(register_list, i)) {
            // don't optimize this by moving the bitwise and over to the initialization of start_address
            // it has to be this way for when we writeback to cpu.regs after the loop
            *start_address += 4;
            cpu.memory.write_word(((*start_address - 4) & 0xFFFFFFFC),  cpu.regs[i], access_type);
            num_pushed++;
            access_type = AccessType.SEQUENTIAL;
        }
    }

    // _g_cpu_cycles_remaining += num_pushed + 1;
}

// conditional branch
@EXCLUDE(11011111)
void run_1101COND(ushort opcode) {
    // this may look daunting, but it's just the different possibilities for COND.
    // each COND has a different if expression we need to consider.
    @IF(!C !O !N !D) if ( cpu.get_flag_Z()) {
    @IF(!C !O !N  D) if (!cpu.get_flag_Z()) {
    @IF(!C !O  N !D) if ( cpu.get_flag_C()) {
    @IF(!C !O  N  D) if (!cpu.get_flag_C()) {
    @IF(!C  O !N !D) if ( cpu.get_flag_N()) {
    @IF(!C  O !N  D) if (!cpu.get_flag_N()) {
    @IF(!C  O  N !D) if ( cpu.get_flag_V()) {
    @IF(!C  O  N  D) if (!cpu.get_flag_V()) {
    @IF( C !O !N !D) if ( cpu.get_flag_C() && !cpu.get_flag_Z()) {
    @IF( C !O !N  D) if (!cpu.get_flag_C() ||  cpu.get_flag_Z()) {
    @IF( C !O  N !D) if ( cpu.get_flag_N() ==  cpu.get_flag_V()) {
    @IF( C !O  N  D) if ( cpu.get_flag_N() ^   cpu.get_flag_V()) {
    @IF( C  O !N !D) if (!cpu.get_flag_Z() && (cpu.get_flag_N() == cpu.get_flag_V())) {
    @IF( C  O !N  D) if ( cpu.get_flag_Z() || (cpu.get_flag_N() ^  cpu.get_flag_V())) {
    @IF( C  O  N !D) if (true) { // the compiler will optimize this so it's fine
        // warning(format("Conditional Branch Taken at %x", *cpu.pc));
        *cpu.pc += (cast(byte)(opcode & 0xFF)) * 2 - 2;
        cpu.refill_pipeline();
        
    } else {
        //DEBUG_MESSAGE("Conditional Branch Not Taken");
    }

    // _g_cpu_cycles_remaining += 3;
}

// software interrupt
void run_11011111(ushort opcode) {
    // warning(format("SWI: %x", opcode));
    cpu.exception(CpuException.SoftwareInterrupt);
}

// unconditional branch
void run_11100OFS(ushort opcode) {
    //DEBUG_MESSAGE("Unconditional Branch");

    int sign_extended = sign_extend(get_nth_bits(opcode, 0, 11) << 1, 12);
    *cpu.pc += sign_extended - 2;
    cpu.refill_pipeline();

    // _g_cpu_cycles_remaining += 3;
}

// long branch with link - high byte
void run_11110OFS(ushort opcode) {
    // Sign extend to 32 bits and then left shift 12
    int extended = cast(int)(get_nth_bits(opcode, 0, 11));
    if (get_nth_bit(extended, 10)) extended |= 0xFFFFF800;

    *cpu.lr = *cpu.pc + (extended << 12) - 2;

    // _g_cpu_cycles_remaining += 3;
}

// long branch with link - low byte and call to subroutine
void run_11111OFS(ushort opcode) {
    uint next_pc = *(cpu.pc) - 4;
    *cpu.pc = (*cpu.lr + (get_nth_bits(opcode, 0, 11) << 1));
    *cpu.lr = (next_pc) | 1;

    cpu.refill_pipeline();

    // _g_cpu_cycles_remaining += 3;
}