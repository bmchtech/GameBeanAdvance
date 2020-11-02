// NOTE: this code is not meant to be run in its raw form. it should first be parsed by make-jumptable.py
// with these settings. this is automatically done by the makefile already:
//     INSTRUCTION_SIZE        = 32 (the first 4 bits is a COND that wil be pre-processed by the gba before 
//                                   running the instruction)
//     JUMPTABLE_BIT_WIDTH     = 12
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
//     that the following function is a local function and should appear in the .cpp file. osometimes i use
//     @LOCAL_INLINE() to tell the script this is an inlined function and should be specified in the header.
//
// Extra note: 
//    The first four bits of every instruction will be labeled "WXYZ". This represents the COND value that
//    precedes every ARM instruction. The reason it's labeled "WXYZ" and not "COND" is so i don't use up
//    common letters like C, O, N, and D on bit variables that aren't going to be used. The execute() function
//    itself will handle the COND.

#ifdef DEBUG_MESSAGE
    #define DEBUG_MESSAGE(message) std::cout << message << std::endl;
#else
    #define DEBUG_MESSAGE(message) do {} while(0)
#endif



// *********************************************** Opcode Functions **********************************************
//                     A list of local helper functions that are used in the instruction set
// ***************************************************************************************************************



// https://stackoverflow.com/questions/14721275/how-can-i-use-arithmetic-right-shifting-with-an-unsigned-int
@LOCAL_INLINE()
inline uint32_t ASR(uint32_t value, uint8_t shift) {
    if ((value >> 31) == 1) {
        // breakdown of this formula:
        // value >> 31                                                         : the most significant bit
        // (value >> 31) << shift)                                             : the most significant bit, but shifted "shift" times
        // ((((value >> 31) << shift) - 1)                                     : the most significant bit, but repeated "shift" times
        // ((((value >> 31) << shift) - 1) << (32 - shift))                    : basically this value is the mask that turns the logical 
        //                                                                     : shift to an arithmetic shift
        // ((((value >> 31) << shift) - 1) << (32 - shift)) | (value >> shift) : the arithmetic shift
        return (((1 << shift) - 1) << (32 - shift)) | (value >> shift);
    } else {
        return value >> shift;
    }
}

@LOCAL_INLINE()
inline void EOR(ARM7TDMI* cpu, uint32_t opcode) {
    uint32_t* rd = &cpu->regs[get_nth_bits(opcode, 12, 16)];

    *rd = cpu->regs[get_nth_bits(opcode, 16, 20)] ^ cpu->shifter_operand;
    if (get_nth_bit(opcode, 20)) {
        if (get_nth_bits(opcode, 12, 16) == 15) { // are we register PC?
            cpu->cpsr = cpu->spsr;
        } else {
            cpu->set_flag_N(get_nth_bit(*rd, 31));
            cpu->set_flag_Z(*rd == 0);
            cpu->set_flag_C(cpu->shifter_carry_out);
        }
    }
}

@LOCAL_INLINE()
inline void LDR(ARM7TDMI* cpu, uint32_t address, uint32_t opcode) {
    uint32_t value = cpu->memory->read_word(address & 0xFFFFFFFC);
    if ((address & 0b11) == 0b01) value = ((value & 0xFF)     << 24) | (value >> 8);
    if ((address & 0b11) == 0b10) value = ((value & 0xFFFF)   << 16) | (value >> 16);
    if ((address & 0b11) == 0b11) value = ((value & 0xFFFFFF) << 8)  | (value >> 24);

    uint8_t rd = get_nth_bits(opcode, 12, 16);
    if (rd == 15) {
        *cpu->pc = value & 0xFFFFFFFC;
    } else {
        cpu->regs[rd] = value;
    }
}

@LOCAL_INLINE()
inline void LDRB(ARM7TDMI* cpu, uint32_t address, uint32_t opcode) {
    cpu->regs[get_nth_bits(opcode, 12, 16)] = cpu->memory->read_byte(address);
}

@LOCAL_INLINE()
inline void LDRBT(ARM7TDMI* cpu, uint32_t address, uint32_t opcode) {
    cpu->regs[get_nth_bits(opcode, 12, 16)] = cpu->memory->read_byte(address);
}

@LOCAL_INLINE()
inline void LDRH(ARM7TDMI* cpu, uint32_t address, uint32_t opcode) {
    cpu->regs[get_nth_bits(opcode, 12, 16)] = cpu->memory->read_halfword(address);
}

@LOCAL_INLINE()
inline void LDRSB(ARM7TDMI* cpu, uint32_t address, uint32_t opcode) {
    cpu->regs[get_nth_bits(opcode, 12, 16)] = sign_extend(cpu->memory->read_byte(address), 8);
}

@LOCAL_INLINE()
inline void LDRSH(ARM7TDMI* cpu, uint32_t address, uint32_t opcode) {
    cpu->regs[get_nth_bits(opcode, 12, 16)] =  sign_extend(cpu->memory->read_halfword(address), 16);
}

@LOCAL_INLINE()
inline uint32_t LSL(uint32_t value, uint8_t shift) {
    return value << shift;
}

@LOCAL_INLINE()
inline uint32_t LSR(uint32_t value, uint8_t shift) {
    return value >> shift;
}

@LOCAL_INLINE()
inline uint32_t ROR(uint32_t value, uint8_t shift) {
    uint32_t rotated_off = get_nth_bits(value, 0,     shift);  // the value that is rotated off
    uint32_t rotated_in  = get_nth_bits(value, shift, 32);     // the value that stays after the rotation
    return rotated_in | (rotated_off << (32 - shift));
}

@LOCAL_INLINE()
inline uint32_t RRX(ARM7TDMI* cpu, uint32_t value, uint8_t shift) {
    uint32_t rotated_off = get_nth_bits(value, 0,     shift - 1);  // the value that is rotated off
    uint32_t rotated_in  = get_nth_bits(value, shift, 32);         // the value that stays after the rotation

    uint32_t result = rotated_in | (rotated_off << (32 - shift)) | (cpu->get_flag_C() << (32 - shift + 1));
    cpu->set_flag_C(get_nth_bit(value, shift));
    return result;
}



// ********************************************** Addressing Mode 1 **********************************************
//                                    MSR, etc. (will be filled out as implemented)
// ***************************************************************************************************************




@LOCAL()
void addressing_mode_1_immediate(ARM7TDMI* cpu, uint32_t opcode) {
    cpu->shifter_operand   = ROR(get_nth_bits(opcode, 0, 8), ((get_nth_bits(opcode, 8, 12)) * 2));
    cpu->shifter_carry_out = get_nth_bits(opcode, 8, 12) == 0 ? cpu->get_flag_C() : get_nth_bit(cpu->shifter_operand, 31);
}

@LOCAL()
void addressing_mode_1_register_by_immediate(ARM7TDMI* cpu, uint32_t opcode) {
    uint32_t shift_immediate = get_nth_bits(opcode, 7, 12);
    uint32_t rm              = cpu->regs[get_nth_bits(opcode, 0, 4)];
    
    switch (get_nth_bits(opcode, 5, 7)) {
        case 0b00: // LSL
            if (shift_immediate == 0) {
                cpu->shifter_operand   = rm;
                cpu->shifter_carry_out = cpu->get_flag_C();
            } else { // shift_immediate > 0
                cpu->shifter_operand   = LSL(rm, shift_immediate);
                cpu->shifter_carry_out = get_nth_bit(rm, 32 - shift_immediate);
            }

            break;

        case 0b01: // LSR
            if (shift_immediate == 0) {
                cpu->shifter_operand   = 0;
                cpu->shifter_carry_out = get_nth_bit(rm, 31);
            } else { // shift_immediate > 0
                cpu->shifter_operand   = LSR(rm, shift_immediate);
                cpu->shifter_carry_out = get_nth_bit(rm, shift_immediate - 1);
            }
            
            break;
        
        case 0b10: // ASR
            if (shift_immediate == 0) {
                cpu->shifter_operand   = get_nth_bit(rm, 31) ? 0xFFFFFFFF : 0x00000000;
                cpu->shifter_carry_out = get_nth_bit(rm, 31);
            } else { // shift_immediate > 0
                cpu->shifter_operand   = ASR(rm, shift_immediate);
                cpu->shifter_carry_out = get_nth_bit(rm, shift_immediate - 1);
            }
            
            break;
        
        case 0b11: // ROR / RRX
            if (shift_immediate == 0) { // RRX
                cpu->shifter_operand   = cpu->get_flag_C() << 31 | LSR(rm, 1);
                cpu->shifter_carry_out = get_nth_bit(rm, 0); 
            } else { // shift_immediate > 0, ROR
                cpu->shifter_operand   = ROR(rm, shift_immediate);
                cpu->shifter_carry_out = get_nth_bit(rm, shift_immediate - 1);
            }

            break;
    }
}

// this function's a doozy
@LOCAL()
void addressing_mode_1_register_by_register(ARM7TDMI* cpu, uint32_t opcode) {
    uint32_t rm = cpu->regs[get_nth_bits(opcode, 0, 4)];
    uint32_t rs = get_nth_bits(cpu->regs[get_nth_bits(opcode, 8, 12)], 0, 8);
    
    if (get_nth_bits(opcode, 4, 12) == 0) {
        cpu->shifter_operand   = rm;
        cpu->shifter_carry_out = cpu->get_flag_C(); 
    }

    switch (get_nth_bits(opcode, 5, 7)) {
        case 0b00: // LSL
            if        (rs == 0) {
                cpu->shifter_operand   = rm;
                cpu->shifter_carry_out = cpu->get_flag_C();
            } else if (rs < 32) {
                cpu->shifter_operand   = LSL(rm, rs);
                cpu->shifter_carry_out = get_nth_bit(rm, 32 - rs);
            } else if (rs == 32) {
                cpu->shifter_operand   = 0;
                cpu->shifter_carry_out = get_nth_bit(rm, 0);
            } else if (rs > 32) {
                cpu->shifter_operand   = 0;
                cpu->shifter_carry_out = 0;
            }

            break;

        case 0b01: // LSR
            if        (rs == 0) {
                cpu->shifter_operand   = rm;
                cpu->shifter_carry_out = cpu->get_flag_C();
            } else if (rs < 32) {
                cpu->shifter_operand   = LSR(rm, rs);
                cpu->shifter_carry_out = get_nth_bit(rm, rs - 1);
            } else if (rs == 32) {
                cpu->shifter_operand   = 0;
                cpu->shifter_carry_out = get_nth_bit(rm, 31);
            } else if (rs > 32) {
                cpu->shifter_operand   = 0;
                cpu->shifter_carry_out = 0;
            }
            
            break;
        
        case 0b10: // ASR
            if        (rs == 0) {
                cpu->shifter_operand   = rm;
                cpu->shifter_carry_out = cpu->get_flag_C();
            } else if (rs < 32) {
                cpu->shifter_operand   = ASR(rm, rs);
                cpu->shifter_carry_out = get_nth_bit(rm, rs - 1);
            } else { // rs >= 32
                cpu->shifter_operand   = get_nth_bit(rm, 31) ? 0xFFFFFFFF : 0x00000000;
                cpu->shifter_carry_out = get_nth_bit(rm, 0);
            }
            
            break;
        
        case 0b11: // ROR
            if        (rs == 0) {
                cpu->shifter_operand   = rm;
                cpu->shifter_carry_out = cpu->get_flag_C();
            } else if (rs & 0xF == 0) {
                cpu->shifter_operand   = rm;
                cpu->shifter_carry_out = get_nth_bit(rm, 31);
            } else { // rs & 0xF > 0
                cpu->shifter_operand   = ROR(rm, rs & 0xF);
                cpu->shifter_carry_out = get_nth_bit(rs, rm & 0xF - 1);
            }

            break;
        
    }
}


// ********************************************** Addressing Mode 2 **********************************************
//                                             LDR / LDRB / STR / STRB
// ***************************************************************************************************************



@LOCAL()
uint32_t addressing_mode_2_immediate_offset(ARM7TDMI* cpu, uint32_t opcode)  {
    bool is_pc = get_nth_bits(opcode, 16, 20) == 15;

    if      (!is_pc &&  get_nth_bit(opcode, 23))   return cpu->regs[get_nth_bits(opcode, 16, 20)] + get_nth_bits(opcode, 0, 12);
    else if (!is_pc && !get_nth_bit(opcode, 23))   return cpu->regs[get_nth_bits(opcode, 16, 20)] - get_nth_bits(opcode, 0, 12);
    else if ( is_pc &&  get_nth_bit(opcode, 23))   return cpu->regs[get_nth_bits(opcode, 16, 20)] + get_nth_bits(opcode, 0, 12) + 4;
    else  /*( is_pc && !get_nth_bit(opcode, 23))*/ return cpu->regs[get_nth_bits(opcode, 16, 20)] - get_nth_bits(opcode, 0, 12) + 4;
}

@LOCAL()
uint32_t addressing_mode_2_immediate_preindexed(ARM7TDMI* cpu, uint32_t opcode) {
    if (get_nth_bit(opcode, 23)) cpu->regs[get_nth_bits(opcode, 16, 20)] += get_nth_bits(opcode, 0, 12);
    else                         cpu->regs[get_nth_bits(opcode, 16, 20)] -= get_nth_bits(opcode, 0, 12);
    return cpu->regs[get_nth_bits(opcode, 16, 20)];
}

@LOCAL()
uint32_t addressing_mode_2_immediate_postindexed(ARM7TDMI* cpu, uint32_t opcode) {
    uint32_t address = cpu->regs[get_nth_bits(opcode, 16, 20)];
    if (get_nth_bit(opcode, 23)) cpu->regs[get_nth_bits(opcode, 16, 20)] += get_nth_bits(opcode, 0, 12);
    else                         cpu->regs[get_nth_bits(opcode, 16, 20)] -= get_nth_bits(opcode, 0, 12);
    return address;
}

// note, this function serves as both the scaled and the unscaled register offset addressing mode
// why? because they're encoded the same way. an unscaled register offset is the same as a scaled
// register offset just with the shift as 0, that's like saying MOV is just ADD RD, RN, #0x0.
// maybe flags might get screwed up though ill have to see
@LOCAL()
uint32_t addressing_mode_2_register_offset(ARM7TDMI* cpu, uint32_t opcode) {
    uint32_t address = cpu->regs[get_nth_bits(opcode, 16, 20)];
    uint32_t operand = cpu->regs[get_nth_bits(opcode, 0,  4)];
    uint32_t shift_immediate = get_nth_bits(opcode, 7, 12);

    uint32_t index = 0;
    switch (get_nth_bits(opcode, 5, 7)) {
        case 0b00:
            index = LSL(operand, shift_immediate);
            break;
        
        case 0b01:
            index = LSR(operand, shift_immediate);
            break;
        
        case 0b10:
            if (shift_immediate != 0) index = ASR(operand, shift_immediate);
            else index = (get_nth_bit(shift_immediate, 31) == 1 ? 0xFFFFFFFF : 0x00000000);
            break;
        
        case 0b11:
            if (shift_immediate != 0) index = ROR(operand, shift_immediate);
            else index = RRX(cpu, operand, 1);
            break;
    }

    if (get_nth_bit(opcode, 24)) { // offset addressing or pre-indexed addressing
        if (get_nth_bit(opcode, 23)) address += index;
        else                         address -= index;

        if (get_nth_bit(opcode, 21)) { // pre-indexed addressing (writeback)
            cpu->regs[get_nth_bits(opcode, 16, 20)] = address;
        }
    } else {                       // post-indexed addressing
        if (get_nth_bit(opcode, 23)) cpu->regs[get_nth_bits(opcode, 16, 20)] += index;
        else                         cpu->regs[get_nth_bits(opcode, 16, 20)] -= index;
    }
    
    if (get_nth_bits(opcode, 16, 20) == 15) { // are we register PC?
        address += 4;
    }

    return address;
}



// ********************************************** Addressing Mode 3 **********************************************
//                                           LDRH / LDRSB / LDRSH / STRH
// ***************************************************************************************************************



@LOCAL()
uint32_t addressing_mode_3_immediate_offset(ARM7TDMI* cpu, uint32_t opcode) {
    bool is_pc = get_nth_bits(opcode, 16, 20) == 15;
    uint8_t offset = get_nth_bits(opcode, 0, 4) | (get_nth_bits(opcode, 8, 12) << 4);

    if      (!is_pc &&  get_nth_bit(opcode, 23))   return cpu->regs[get_nth_bits(opcode, 16, 20)] + offset;
    else if (!is_pc && !get_nth_bit(opcode, 23))   return cpu->regs[get_nth_bits(opcode, 16, 20)] - offset;
    else if ( is_pc &&  get_nth_bit(opcode, 23))   return cpu->regs[get_nth_bits(opcode, 16, 20)] + offset + 4;
    else  /*( is_pc && !get_nth_bit(opcode, 23))*/ return cpu->regs[get_nth_bits(opcode, 16, 20)] - offset + 4;
}

@LOCAL()
uint32_t addressing_mode_3_register_offset(ARM7TDMI* cpu, uint32_t opcode) {
    bool is_pc = get_nth_bits(opcode, 16, 20) == 15;
    uint32_t offset = cpu->regs[get_nth_bits(opcode, 0, 4)];

    if      (!is_pc &&  get_nth_bit(opcode, 23))   return cpu->regs[get_nth_bits(opcode, 16, 20)] + offset;
    else if (!is_pc && !get_nth_bit(opcode, 23))   return cpu->regs[get_nth_bits(opcode, 16, 20)] - offset;
    else if ( is_pc &&  get_nth_bit(opcode, 23))   return cpu->regs[get_nth_bits(opcode, 16, 20)] + offset + 4;
    else  /*( is_pc && !get_nth_bit(opcode, 23))*/ return cpu->regs[get_nth_bits(opcode, 16, 20)] - offset + 4;
}

@LOCAL()
uint32_t addressing_mode_3_immediate_preindexed(ARM7TDMI* cpu, uint32_t opcode) {
    uint8_t offset = get_nth_bits(opcode, 0, 4) | (get_nth_bits(opcode, 8, 12) << 4);
    if (get_nth_bit(opcode, 23)) cpu->regs[get_nth_bits(opcode, 16, 20)] += offset;
    else                         cpu->regs[get_nth_bits(opcode, 16, 20)] -= offset;
    return cpu->regs[get_nth_bits(opcode, 16, 20)];
}


@LOCAL()
uint32_t addressing_mode_3_register_preindexed(ARM7TDMI* cpu, uint32_t opcode) {
    uint32_t offset = cpu->regs[get_nth_bits(opcode, 0, 4)];
    if (get_nth_bit(opcode, 23)) cpu->regs[get_nth_bits(opcode, 16, 20)] += offset;
    else                         cpu->regs[get_nth_bits(opcode, 16, 20)] -= offset;
    return cpu->regs[get_nth_bits(opcode, 16, 20)];
}


@LOCAL()
uint32_t addressing_mode_3_immediate_postindexed(ARM7TDMI* cpu, uint32_t opcode) {
    uint8_t  offset  = get_nth_bits(opcode, 0, 4) | (get_nth_bits(opcode, 8, 12) << 4);
    uint32_t address = cpu->regs[get_nth_bits(opcode, 16, 20)];
    if (get_nth_bit(opcode, 23)) cpu->regs[get_nth_bits(opcode, 16, 20)] += offset;
    else                         cpu->regs[get_nth_bits(opcode, 16, 20)] -= offset;
    return address;
}

@LOCAL()
uint32_t addressing_mode_3_register_postindexed(ARM7TDMI* cpu, uint32_t opcode) {
    uint32_t offset  = cpu->regs[get_nth_bits(opcode, 0, 4)];
    uint32_t address = cpu->regs[get_nth_bits(opcode, 16, 20)];
    if (get_nth_bit(opcode, 23)) cpu->regs[get_nth_bits(opcode, 16, 20)] += offset;
    else                         cpu->regs[get_nth_bits(opcode, 16, 20)] -= offset;
    return address;
}



// *********************************************** Instruction Set ***********************************************
//                                      The actual ARM Instruction Set Config
// ***************************************************************************************************************



@DEFAULT()
void nop(uint32_t opcode) {
    DEBUG_MESSAGE("NOP");
}

// B / BL instruction
void run_COND101LABEF(uint32_t opcode) {
    @IF(L) *cpu->lr = *cpu->pc;
    // unintuitive sign extension: http://graphics.stanford.edu/~seander/bithacks.html#FixedSignExtend
    *cpu->pc += ((((1U << 23) ^ get_nth_bits(opcode, 0, 24)) - (1U << 23)) << 2) + 4;
}

// EOR instruction
// Addressing Mode 1, immediate offset
void run_COND0010001S(uint32_t opcode) {
    addressing_mode_1_immediate(cpu, opcode);
    EOR(cpu, opcode);
}

// EOR instruction
// Addressing Mode 1, shifts
void run_COND0000001S(uint32_t opcode) {
    if (get_nth_bit(opcode, 4)) addressing_mode_1_register_by_register (cpu, opcode);
    else                        addressing_mode_1_register_by_immediate(cpu, opcode);
    EOR(cpu, opcode);
}

// LDR instruction
// Addressing Mode 2, immediate offset
void run_COND0101UB01(uint32_t opcode) {
    uint32_t address = addressing_mode_2_immediate_offset(cpu, opcode);
    @IF(!B) LDR (cpu, address, opcode);
    @IF( B) LDRB(cpu, address, opcode);
}

// LDR instruction
// Addressing Mode 2, register unscaled/scaled
void run_COND011PUBW1(uint32_t opcode) {
    uint32_t address = addressing_mode_2_register_offset(cpu, opcode);
    @IF(!B) LDR (cpu, address, opcode);
    @IF( B) LDRB(cpu, address, opcode);
}

// LDR instruction
// Addressing Mode 2, immediate pre-indexed
void run_COND0101UB11(uint32_t opcode) {
    uint32_t address = addressing_mode_2_immediate_preindexed(cpu, opcode);
    @IF(!B) LDR (cpu, address, opcode);
    @IF( B) LDRB(cpu, address, opcode);
}

// LDR instruction
// Addressing Mode 2, immediate post-indexed
void run_COND0100UB01(uint32_t opcode) {
    uint32_t address = addressing_mode_2_immediate_postindexed(cpu, opcode);
    @IF(!B) LDR (cpu, address, opcode);
    @IF( B) LDRB(cpu, address, opcode);
}

// LDRH / LDRSB / LDRSH instructions
// Addressing Mode 3, immediate offset
void run_COND0001U101(uint32_t opcode) {
    uint32_t address = addressing_mode_3_immediate_offset(cpu, opcode);
    switch (get_nth_bits(opcode, 4, 8)) {
        case 0b1011: LDRH (cpu, address, opcode); break;
        case 0b1101: LDRSB(cpu, address, opcode); break;
        case 0b1111: LDRSH(cpu, address, opcode); break;
    }
}

// LDRH / LDRSB / LDRSH instructions
// Addressing Mode 3, register offset
void run_COND0001U001(uint32_t opcode) {
    uint32_t address = addressing_mode_3_register_offset(cpu, opcode);
    switch (get_nth_bits(opcode, 4, 8)) {
        case 0b1011: LDRH (cpu, address, opcode); break;
        case 0b1101: LDRSB(cpu, address, opcode); break;
        case 0b1111: LDRSH(cpu, address, opcode); break;
    }
}


// LDRH / LDRSB / LDRSH instructions
// Addressing Mode 3, immediate pre-indexed
void run_COND0001U111(uint32_t opcode) {
    uint32_t address = addressing_mode_3_immediate_preindexed(cpu, opcode);
    switch (get_nth_bits(opcode, 4, 8)) {
        case 0b1011: LDRH (cpu, address, opcode); break;
        case 0b1101: LDRSB(cpu, address, opcode); break;
        case 0b1111: LDRSH(cpu, address, opcode); break;
    }
}


// LDRH / LDRSB / LDRSH instructions
// Addressing Mode 3, register pre-indexed
void run_COND0001U011(uint32_t opcode) {
    uint32_t address = addressing_mode_3_register_preindexed(cpu, opcode);
    switch (get_nth_bits(opcode, 4, 8)) {
        case 0b1011: LDRH (cpu, address, opcode); break;
        case 0b1101: LDRSB(cpu, address, opcode); break;
        case 0b1111: LDRSH(cpu, address, opcode); break;
    }
}


// LDRH / LDRSB / LDRSH instructions
// Addressing Mode 3, immediate post-indexed
void run_COND0000U101(uint32_t opcode) {
    uint32_t address = addressing_mode_3_immediate_postindexed(cpu, opcode);
    switch (get_nth_bits(opcode, 4, 8)) {
        case 0b1011: LDRH (cpu, address, opcode); break;
        case 0b1101: LDRSB(cpu, address, opcode); break;
        case 0b1111: LDRSH(cpu, address, opcode); break;
    }
}


// LDRH / LDRSB / LDRSH instructions
// Addressing Mode 3, register post-indexed
void run_COND0000U001(uint32_t opcode) {
    uint32_t address = addressing_mode_3_register_postindexed(cpu, opcode);
    switch (get_nth_bits(opcode, 4, 8)) {
        case 0b1011: LDRH (cpu, address, opcode); break;
        case 0b1101: LDRSB(cpu, address, opcode); break;
        case 0b1111: LDRSH(cpu, address, opcode); break;
    }
}


// MRS instruction
void run_COND00010R00(uint32_t opcode) {
    cpu->regs[get_nth_bits(opcode, 12, 16)] = get_nth_bit(opcode, 22) ? cpu->spsr : cpu->cpsr;
}