module jumptable_arm;

import abstracthw.cpu;
import abstracthw.memory;
import instruction;
import ops;
import util;
import barrel_shifter;
import core.bitop;

alias JumptableEntry = void function(IARM7TDMI cpu, Word opcode);

static void create_nop(IARM7TDMI cpu, Word opcode) {}

static void create_branch(Word static_opcode)(IARM7TDMI cpu, Word opcode) {
    enum branch_with_link = get_nth_bit(static_opcode, 24);
    
    static if (branch_with_link) cpu.set_reg(lr, cpu.get_reg(pc) - 8);
    Word offset = cpu.sext_32(get_nth_bits(opcode, 0, 24) * 4, 22);
    cpu.set_reg(pc, cpu.get_reg(pc) + offset);
}

static void create_branch_exchange(Word static_opcode)(IARM7TDMI cpu, Word opcode) {
    Reg rm = get_nth_bits(opcode, 0, 4);
    Word address = cpu.get_reg(rm);

    cpu.set_flag(Flag.T, address & 1);
    cpu.set_reg(pc, address & ~1);
}

static void create_mrs(Word static_opcode)(IARM7TDMI cpu, Word opcode) {
    enum transfer_spsr = get_nth_bit(static_opcode, 22);

    Reg rd = get_nth_bits(opcode, 12, 16);
    static if (transfer_spsr) cpu.set_reg(rd, cpu.get_spsr());
    else                      cpu.set_reg(rd, cpu.get_cpsr());
}

static void create_multiply(Word static_opcode)(IARM7TDMI cpu, Word opcode) {
    enum multiply_long = get_nth_bit(static_opcode, 23);
    enum signed        = get_nth_bit(static_opcode, 22);
    enum accumulate    = get_nth_bit(static_opcode, 21);
    enum update_flags  = get_nth_bit(static_opcode, 20);

    Reg rd = get_nth_bits(opcode, 16, 20);
    Reg rn = get_nth_bits(opcode, 12, 16);
    Reg rs = get_nth_bits(opcode,  8, 12);
    Reg rm = get_nth_bits(opcode,  0, 4);

    static if (multiply_long) {
        static if (signed) {
            s64 operand1 = cpu.sext_64(cpu.get_reg(rm), 32);
            s64 operand2 = cpu.sext_64(cpu.get_reg(rs), 32);
        } else {
            u64 operand1 = cpu.get_reg(rm);
            u64 operand2 = cpu.get_reg(rs);
        }
    } else {
        u32 operand1 = cpu.get_reg(rm);
        u32 operand2 = cpu.get_reg(rs);
    }
    
    u64 result = cast(u64) (operand1 * operand2);

    static if (accumulate) {
        static if (multiply_long) {
            result += ((cast(u64) cpu.get_reg(rd)) << 32UL) + (cast(u64) cpu.get_reg(rn));
        } else {
            result += cpu.get_reg(rn);
        }
    }

    static if (multiply_long) {
        cpu.set_reg(rd, result >> 32);
        cpu.set_reg(rn, result & 0xFFFFFFFF);
        bool modifying_pc = unlikely(rd == pc || rn == pc);
        bool overflow = result >> 63;
    } else {
        cpu.set_reg(rd, result & 0xFFFFFFFF);
        bool modifying_pc = unlikely(rd == pc);
        bool overflow = (result >> 31) & 1;
    }

    if (update_flags) {
        if (modifying_pc) {
            cpu.set_cpsr(cpu.get_spsr());
        } else {
            cpu.set_flag(Flag.Z, result == 0);
            cpu.set_flag(Flag.N, overflow);
        }
    }
}

static void create_data_processing(Word static_opcode)(IARM7TDMI cpu, Word opcode) {
    enum is_immediate = get_nth_bit(static_opcode, 25);

    Reg rn = get_nth_bits(opcode, 16, 20);
    Reg rd = get_nth_bits(opcode, 12, 16);
    Reg rs = get_nth_bits(opcode,  0,  4);
    Word operand1 = cpu.get_reg(rn);
 
    static if (is_immediate) {
        Word immediate     = get_nth_bits(opcode, 0, 8);
        Word shift         = get_nth_bits(opcode, 8, 12) * 2;
        Word operand2      = rotate_right(immediate, shift);
        bool shifter_carry = shift == 0 ? cpu.get_flag(Flag.C) : get_nth_bit(operand2, 31);
    } else {
        Word immediate = cpu.get_reg(get_nth_bits(opcode, 0, 4));

        enum shift_type = get_nth_bits(static_opcode, 5, 7);
        enum register_shift = get_nth_bit(static_opcode, 4);
        static if (register_shift) {
            Word shift = cpu.get_reg(get_nth_bits(opcode, 8, 12)) & 0xFF;
        } else {
            Word shift = get_nth_bits(opcode, 7, 12);
        }

        BarrelShifter shifter = barrel_shift!(shift_type, is_immediate)(cpu, immediate, shift);
        Word operand2 = shifter.result;
        bool shifter_carry = shifter.carry;
    }

    bool is_pc = rd == pc;
    enum update_flags = get_nth_bit(static_opcode, 20);

    enum operation = get_nth_bits(static_opcode, 21, 25);
    static if (operation ==  0) { cpu.and(rd, operand1, operand2, true, update_flags && !is_pc); cpu.set_flag(Flag.C, shifter_carry); }
    static if (operation ==  1) { cpu.eor(rd, operand1, operand2, true, update_flags && !is_pc); cpu.set_flag(Flag.C, shifter_carry); }
    static if (operation ==  2) { cpu.sub(rd, operand1, operand2, true, update_flags && !is_pc); }
    static if (operation ==  3) { cpu.rsb(rd, operand1, operand2, true, update_flags && !is_pc); }
    static if (operation ==  4) { cpu.add(rd, operand1, operand2, true, update_flags && !is_pc); }
    static if (operation ==  5) { cpu.adc(rd, operand1, operand2, true, update_flags && !is_pc); }
    static if (operation ==  6) { cpu.sbc(rd, operand1, operand2, true, update_flags && !is_pc); }
    static if (operation ==  7) { cpu.rsc(rd, operand1, operand2, true, update_flags && !is_pc); }
    static if (operation ==  8) { cpu.tst(rd, operand1, operand2,       update_flags && !is_pc); }
    static if (operation ==  9) { cpu.teq(rd, operand1, operand2,       update_flags && !is_pc); }
    static if (operation == 10) { cpu.cmp(rd, operand1, operand2,       update_flags && !is_pc); }
    static if (operation == 11) { cpu.cmn(rd, operand1, operand2,       update_flags && !is_pc); }
    static if (operation == 12) { cpu.orr(rd, operand1, operand2, true, update_flags && !is_pc); cpu.set_flag(Flag.C, shifter_carry); }
    static if (operation == 13) { cpu.mov(rd,           operand2,       update_flags && !is_pc); cpu.set_flag(Flag.C, shifter_carry); }
    static if (operation == 14) { cpu.bic(rd, operand1, operand2, true, update_flags && !is_pc); cpu.set_flag(Flag.C, shifter_carry); }
    static if (operation == 15) { cpu.mvn(rd,           operand2,       update_flags && !is_pc); cpu.set_flag(Flag.C, shifter_carry); }
}

static void create_half_data_transfer(Word static_opcode)(IARM7TDMI cpu, Word opcode) {
    enum pre                = get_nth_bit(static_opcode, 24);
    enum up                 = get_nth_bit(static_opcode, 23);
    enum is_immediate       = get_nth_bit(static_opcode, 22);
    enum writeback          = get_nth_bit(static_opcode, 21) || !pre; // post-indexing implies writeback
    enum load               = get_nth_bit(static_opcode, 20);
    enum signed             = get_nth_bit(static_opcode, 6);
    enum half               = get_nth_bit(static_opcode, 5);

    Reg rd = get_nth_bits(opcode, 12, 16);
    Reg rn = get_nth_bits(opcode, 16, 20);

    static if (is_immediate) {
        Word offset = get_nth_bits(opcode, 0, 4) | (get_nth_bits(opcode, 8, 12) << 4);
    } else {
        Word offset = cpu.get_reg(get_nth_bits(opcode, 0, 4));
    }

    Word address = cpu.get_reg(rn);
    enum dir = up ? 1 : -1;
    Word writeback_value = address + dir * offset;
    static if (pre) address = writeback_value;

    static if (load) {
        static if (signed) {
            static if (half) cpu.ldrsh(rd, address);
            else             cpu.ldrsb(rd, address);
        } else {
            cpu.ldrh(rd, address);
        }
    } else {
        cpu.strh(rd, address);
    }

    static if (writeback) cpu.set_reg(rn, writeback_value);
}

static void create_single_data_transfer(Word static_opcode)(IARM7TDMI cpu, Word opcode) {
    enum is_register_offset = get_nth_bit (static_opcode, 25);
    enum shift_type         = get_nth_bits(static_opcode, 5, 7);
    enum pre                = get_nth_bit (static_opcode, 24);
    enum up                 = get_nth_bit (static_opcode, 23);
    enum byte_access        = get_nth_bit (static_opcode, 22);
    enum writeback          = get_nth_bit (static_opcode, 21) || !pre; // post-indexing implies writeback
    enum load               = get_nth_bit (static_opcode, 20);

    Reg rd = get_nth_bits(opcode, 12, 16);
    Reg rn = get_nth_bits(opcode, 16, 20);

    static if (is_register_offset) {
        Reg rm = get_nth_bits(opcode, 0, 4);

        auto shift = get_nth_bits(opcode, 7, 12);
        Word offset = barrel_shift!(shift_type, false)(cpu, cpu.get_reg(rm), shift).result;
    } else { // immediate offset
        Word offset = get_nth_bits(opcode, 0, 12);
    }
    
    Word address = cpu.get_reg(rn);
    enum dir = up ? 1 : -1;
    Word writeback_value = address + dir * offset;
    static if (pre) address = writeback_value;

    static if ( byte_access &&  load) cpu.ldrb(rd, address);
    static if (!byte_access &&  load) cpu.ldr (rd, address);
    static if ( byte_access && !load) cpu.strb(rd, address);
    static if (!byte_access && !load) cpu.str (rd, address);

    static if (writeback) cpu.set_reg(rn, writeback_value);
}

static void create_swap(Word static_opcode)(IARM7TDMI cpu, Word opcode) {
    enum byte_swap = get_nth_bit(static_opcode, 22);
    
    Reg rm = get_nth_bits(opcode,  0,  4);
    Reg rd = get_nth_bits(opcode, 12, 16);
    Reg rn = get_nth_bits(opcode, 16, 20);

    Word address = cpu.get_reg(rn);

    static if (byte_swap) {
        Word value = cpu.read_byte(address, AccessType.NONSEQUENTIAL);
        cpu.write_byte(address, cpu.get_reg(rm) & 0xFF, AccessType.NONSEQUENTIAL);
    } else {
        Word value = cpu.read_word_and_rotate(address, AccessType.NONSEQUENTIAL);
        cpu.write_word(address, cpu.get_reg(rm), AccessType.NONSEQUENTIAL);
    }

    cpu.set_reg(rd, value);
}

static void create_ldm_stm(Word static_opcode)(IARM7TDMI cpu, Word opcode) {
    enum pre       = get_nth_bit(static_opcode, 24);
    enum up        = get_nth_bit(static_opcode, 23);
    enum s         = get_nth_bit(static_opcode, 22);
    enum writeback = get_nth_bit(static_opcode, 21);
    enum load      = get_nth_bit(static_opcode, 20);

    Reg rn = get_nth_bits(opcode, 16, 20);

    auto rlist = get_nth_bits(opcode, 0, 16);
    auto reg_count = popcnt(rlist);

    if (rlist == 0) {
        reg_count = 16;
        rlist = (1 << pc);
    }

    Word address = cpu.get_reg(rn);
    Word start_address     = address;
    Word writeback_address = address;

    static if (pre == up) address += 4;
    static if (!up)       address -= reg_count * 4;

    static if (up)        writeback_address += reg_count * 4;
    else                  writeback_address -= reg_count * 4;

    auto mask = 1;
    int  num_transfers = 0;

    static if (load) bool pc_loaded = false;

    static if (s) bool pc_included = get_nth_bit(opcode, 15);

    bool register_in_rlist = (opcode >> rn) & 1;
    bool is_first_access = true;

    AccessType access_type = AccessType.NONSEQUENTIAL;

    for (int i = 0; i < 16; i++) {
        if (opcode & mask) {
            static if (s) {
                static if (load) {
                    if (pc_included) cpu.set_reg(i, cpu.read_word(address, access_type));
                    else             cpu.set_reg(i, cpu.read_word(address, access_type), MODE_USER);
                } else {
                    if (i == pc) cpu.write_word(address, cpu.get_reg(pc, MODE_USER) + 4, access_type);
                    else         cpu.write_word(address, cpu.get_reg(i,  MODE_USER),     access_type);
                }
            } else {
                static if (load) {
                    if (i == pc) cpu.set_reg(i, cpu.read_word(address, access_type));
                    else         cpu.set_reg(i, cpu.read_word(address, access_type));
                } else {
                    if (i == pc) cpu.write_word(address, cpu.get_reg(pc) + 4, access_type);
                    else         cpu.write_word(address, cpu.get_reg(i),      access_type);
                }
            }

            address += 4;

            static if (load) {
                num_transfers++;
                if (i == pc) {
                    pc_loaded = true;
                }
            }

            static if (writeback && !load) {
                if (is_first_access) cpu.set_reg(rn, writeback_address);
                is_first_access = false;
            }

            access_type = AccessType.SEQUENTIAL;
        }

        mask <<= 1; 
    }

    static if (load) cpu.run_idle_cycle();

    static if (load && s) if (pc_loaded) cpu.set_cpsr(cpu.get_spsr());

    static if (writeback &&  load) if (!register_in_rlist) cpu.set_reg(rn, writeback_address);
    static if (writeback && !load) cpu.set_reg(rn, writeback_address);
}

static JumptableEntry[4096] create_jumptable()() {
    JumptableEntry[4096] jumptable;

    static foreach (entry; 0 .. 4096) {{
        enum static_opcode = (get_nth_bits(entry, 0, 4) << 4) | (get_nth_bits(entry, 4, 12) << 20);

        if ((entry & 0b1111_1011_1111) == 0b0001_0000_1001) {
            jumptable[entry] = &create_swap!static_opcode;
        } else

        if ((entry & 0b1100_0000_0000) == 0b0100_0000_0000) {
            jumptable[entry] = &create_single_data_transfer!static_opcode;
        } else

        if (((entry & 0b1111_1100_1111) == 0b0000_0000_1001) ||
            ((entry & 0b1111_1000_1111) == 0b0000_1000_1001)) {
            jumptable[entry] = &create_multiply!static_opcode;
        } else

        if ((entry & 0b1110_0000_1001) == 0b0000_0000_1001) {
            jumptable[entry] = &create_half_data_transfer!static_opcode;
        } else

        if ((entry & 0b1110_0000_0000) == 0b1010_0000_0000) {
            jumptable[entry] = &create_branch!static_opcode;
        } else

        if ((entry & 0b1111_1011_1111) == 0b0001_0000_0000) {
            jumptable[entry] = &create_mrs!static_opcode;
        } else

        if ((entry & 0b1111_1111_1111) == 0b0001_0010_0001) {
            jumptable[entry] = &create_branch_exchange!static_opcode;
        } else

        if ((entry & 0b1110_0000_0000) == 0b1000_0000_0000) {
            jumptable[entry] = &create_ldm_stm!static_opcode;
        } else

        if (((entry & 0b1110_0000_0000) == 0b0010_0000_0000) ||
            ((entry & 0b1110_0000_0001) == 0b0000_0000_0000) ||
            ((entry & 0b1110_0000_1001) == 0b0000_0000_0001)) {
            jumptable[entry] = &create_data_processing!static_opcode;
        } else
        
        jumptable[entry] = &create_nop;
    }}

    return jumptable;
}

static JumptableEntry[4096] jumptable = create_jumptable!();
