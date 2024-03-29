module jumptable_thumb;

import abstracthw.cpu;
import abstracthw.memory;
import ops;
import util;

import hw.gba;

import core.bitop;

template execute(T : IARM7TDMI) {

    alias JumptableEntry = void function(T cpu, Half opcode);

    static void create_conditional_branch(uint cond)(T cpu, Half opcode) {
        if (cpu.check_cond(cond)) {
            cpu.set_reg(pc, cpu.get_reg(pc) + (cast(s8)(opcode & 0xFF)) * 2);
        }
    }

    static void create_add_sub_mov_cmp(Reg rd, ubyte op)(T cpu, Half opcode) {
        Word immediate = get_nth_bits(opcode, 0, 8);
        Word operand   = cpu.get_reg(rd);

        final switch (op) {
            case 0b00: cpu.mov(rd, immediate); break;
            case 0b01: cpu.cmp(rd, operand, immediate); break;
            case 0b10: cpu.add(rd, operand, immediate); break;
            case 0b11: cpu.sub(rd, operand, immediate); break;
        }
    }

    static void create_add_sub_immediate(ubyte op)(T cpu, Half opcode) {
        Reg rd = get_nth_bits(opcode, 0, 3);
        Reg rn = get_nth_bits(opcode, 3, 6);
        Word operand   = cpu.get_reg(rn);
        Word immediate = get_nth_bits(opcode, 6, 9);

        final switch (op) {
            case 0b0: cpu.add(rd, operand, immediate); break;
            case 0b1: cpu.sub(rd, operand, immediate); break;
        }
    }

    static void create_add_sub(ubyte op)(T cpu, Half opcode) {
        Reg rd = get_nth_bits(opcode, 0, 3);
        Reg rn = get_nth_bits(opcode, 3, 6);
        Reg rm = get_nth_bits(opcode, 6, 9);
        Word operand1 = cpu.get_reg(rn);
        Word operand2 = cpu.get_reg(rm);

        final switch (op) {
            case 0: cpu.add(rd, operand1, operand2); break;
            case 1: cpu.sub(rd, operand1, operand2); break;
        }
    }

    static void create_full_alu(T cpu, Half opcode) {
        auto rd = get_nth_bits(opcode, 0, 3);
        auto rm = get_nth_bits(opcode, 3, 6);
        auto op = get_nth_bits(opcode, 6, 10);
        Word operand1 = cpu.get_reg(rd);
        Word operand2 = cpu.get_reg(rm);

        final switch (op) {
            case  0: cpu.and(rd, operand1, operand2); break;
            case  1: cpu.eor(rd, operand1, operand2); break; 
            case  2: cpu.lsl(rd, operand1, operand2 & 0xFF); break;
            case  3: cpu.lsr(rd, operand1, operand2 & 0xFF); break;
            case  4: cpu.asr(rd, operand1, operand2 & 0xFF); break; 
            case  5: cpu.adc(rd, operand1, operand2); break;
            case  6: cpu.sbc(rd, operand1, operand2); break;
            case  7: cpu.ror(rd, operand1, operand2 & 0xFF); cpu.run_idle_cycle(); break;
            case  8: cpu.tst(rd, operand1, operand2); break;
            case  9: cpu.neg(rd, operand2); break;
            case 10: cpu.cmp(rd, operand1, operand2); break;
            case 11: cpu.cmn(rd, operand1, operand2); break;
            case 12: cpu.orr(rd, operand1, operand2); break;
            case 13: cpu.mul(rd, operand1, operand2); break;
            case 14: cpu.bic(rd, operand1, operand2); break;
            case 15: cpu.mvn(rd, operand2); break;
        }
    }

    static void create_long_branch(bool is_first_instruction)(T cpu, Half opcode) {
        static if (is_first_instruction) {
            auto offset   = get_nth_bits(opcode, 0, 11);
            auto extended = cpu.sext_32(offset, 11);
            cpu.set_reg(lr, cpu.get_reg(pc) + (extended << 12));
        } else {
            auto next_pc = cpu.get_reg(pc) - 2;
            auto offset  = get_nth_bits(opcode, 0, 11) << 1;
            cpu.set_reg(pc, cpu.get_reg(lr) + offset);
            cpu.set_reg(lr, next_pc | 1);
        }
    }

    static void create_branch_exchange(T cpu, Half opcode) {
        Reg rm = get_nth_bits(opcode, 3, 7);

        Word address = cpu.get_reg(rm);
        cpu.set_flag(Flag.T, address & 1);
        cpu.set_reg(pc, address);

        if (g_profile_gba) g_profiler.notify__cpu_bx(rm);
    }

    static void create_pc_relative_load(Reg reg)(T cpu, Half opcode) {
        auto offset  = get_nth_bits(opcode, 0, 8) * 4;
        auto address = (cpu.get_reg(pc) + offset) & ~3;

        cpu.ldr(reg, address);
    }

    static void create_stm(Reg base)(T cpu, Half opcode) {
        Word start_address = cpu.get_reg(base);
        auto register_list = get_nth_bits(opcode, 0, 8);
        AccessType access_type = AccessType.NONSEQUENTIAL;

        if (register_list == 0) {
            cpu.write_word(start_address, cpu.get_reg(pc) + 2, access_type);
            cpu.set_reg(base, start_address + 0x40);
            return;
        }

        auto writeback_value = start_address + popcnt(register_list) * 4;
        bool is_first_access = true;

        Word current_address = start_address;
        for (int i = 0; i < 8; i++) {
            if (get_nth_bit(register_list, i)) {
                cpu.write_word(current_address, cpu.get_reg(i), access_type);
                access_type = AccessType.SEQUENTIAL;
                current_address += 4;

                if (is_first_access) cpu.set_reg(base, writeback_value);
                is_first_access = false;
            }
        }

        cpu.set_pipeline_access_type(AccessType.NONSEQUENTIAL);
    }

    static void create_ldm(Reg base)(T cpu, Half opcode) {
        Word start_address = cpu.get_reg(base);
        auto register_list = get_nth_bits(opcode, 0, 8);
        AccessType access_type = AccessType.NONSEQUENTIAL;

        if (register_list == 0) {
            cpu.set_reg(pc, cpu.read_word(start_address, access_type));
            cpu.set_reg(base, start_address + 0x40);
            return;
        }
        
        Word current_address = start_address;

        for (int i = 0; i < 8; i++) {
            if (get_nth_bit(register_list, i)) {
                cpu.set_reg(i, cpu.read_word(current_address, access_type));
                access_type = AccessType.SEQUENTIAL;
                current_address += 4;
            }
        }

        bool base_in_register_list = get_nth_bit(register_list, base);
        if (!base_in_register_list) {
            cpu.set_reg(base, current_address);
        }
        
        cpu.run_idle_cycle();
    }

    static void create_load_store_immediate_offset(bool is_load, bool is_byte)(T cpu, Half opcode) {
        Reg rd      = get_nth_bits(opcode, 0, 3);
        Reg rn      = get_nth_bits(opcode, 3, 6);
        Word offset = get_nth_bits(opcode, 6, 11);
        Word base   = cpu.get_reg(rn);

        static if ( is_load &&  is_byte) cpu.ldrb(rd, base + offset);
        static if ( is_load && !is_byte) cpu.ldr (rd, base + offset * 4);
        static if (!is_load &&  is_byte) cpu.strb(rd, base + offset);
        static if (!is_load && !is_byte) cpu.str (rd, base + offset * 4);
    }

    static void create_load_store_register_offset(uint op)(T cpu, Half opcode) {
        Reg rd = get_nth_bits(opcode, 0, 3);
        Reg rn = get_nth_bits(opcode, 3, 6);
        Reg rm = get_nth_bits(opcode, 6, 9);
        Word address = cpu.get_reg(rm) + cpu.get_reg(rn);

        enum cpu_func = [
            &str!T,
            &strh!T,
            &strb!T,
            &ldrsb!T,
            &ldr!T,
            &ldrh!T,
            &ldrb!T,
            &ldrsh!T
        ][op];

        cpu_func(cpu, rd, address);
    }

    static void create_alu_high_registers(ubyte op)(T cpu, Half opcode) {
        Reg rm = get_nth_bits(opcode, 3, 7);
        Reg rd = get_nth_bits(opcode, 0, 3) | (get_nth_bit(opcode, 7) << 3);
        Word operand1 = cpu.get_reg(rd);
        Word operand2 = cpu.get_reg(rm);

        final switch (op) {
            case 0b00: cpu.add(rd, operand1, operand2, true, false); break;
            case 0b01: cpu.cmp(rd, operand1, operand2); break;
            case 0b10: cpu.mov(rd, operand2, false); break;
        }
    }

    static void create_add_sp_pc_relative(Reg rd, bool is_sp)(T cpu, Half opcode) {
        Word immediate = get_nth_bits(opcode, 0, 8) << 2;
        static if ( is_sp) Word base = cpu.get_reg(sp);
        static if (!is_sp) Word base = cpu.get_reg(pc) & ~3;

        cpu.set_reg(rd, base + immediate);
    }

    static void create_modify_sp(T cpu, Half opcode) {
        Word immediate      = get_nth_bits(opcode, 0, 7) << 2;
        bool is_subtraction = get_nth_bit (opcode, 7);
        
        if (is_subtraction) cpu.set_reg(sp, cpu.get_reg(sp) - immediate);
        else                cpu.set_reg(sp, cpu.get_reg(sp) + immediate);

        if (g_profile_gba) {
            if (is_subtraction) g_profiler.notify__cpu_decremented_sp(immediate);
            else                g_profiler.notify__cpu_incremented_sp(immediate);
        }
    }

    static void create_logical_shift(bool is_lsr)(T cpu, Half opcode) {
        Reg rd     = get_nth_bits(opcode, 0, 3);
        Reg rm     = get_nth_bits(opcode, 3, 6);
        auto shift = get_nth_bits(opcode, 6, 11);

        auto operand = cpu.get_reg(rm);

        if (shift == 0) {
            static if (!is_lsr) {
                cpu.set_reg(rd, cpu.get_reg(rm));
                return;
            } else {
                shift = 32;
            }
        }

        static if (is_lsr) cpu.lsr(rd, operand, shift);
        else               cpu.lsl(rd, operand, shift);
        
        cpu.run_idle_cycle();
    }

    static void create_arithmetic_shift(T cpu, Half opcode) {
        Reg rd     = get_nth_bits(opcode, 0, 3);
        Reg rm     = get_nth_bits(opcode, 3, 6);
        auto shift = get_nth_bits(opcode, 6, 11);
        if (shift == 0) shift = 32;

        auto operand = cpu.get_reg(rm);
        cpu.asr(rd, operand, shift);
        
        cpu.run_idle_cycle();
    }

    static void create_unconditional_branch(T cpu, Half opcode) {
        auto offset = cpu.sext_32(get_nth_bits(opcode, 0, 11) * 2, 12);
        cpu.set_reg(pc, cpu.get_reg(pc) + offset);
    }

    static void create_sp_relative_load_store(Reg rd, bool is_load)(T cpu, Half opcode) {
        Word offset  = get_nth_bits(opcode, 0, 8) * 4;
        Word address = cpu.get_reg(sp) + offset;
        static if (is_load) cpu.ldr(rd, address);
        else                cpu.str(rd, address);
    }

    static void create_half_access(bool is_load)(T cpu, Half opcode) {
        Reg  rd      = get_nth_bits(opcode, 0, 3);
        Reg  rn      = get_nth_bits(opcode, 3, 6);
        Word offset  = get_nth_bits(opcode, 6, 11) * 2;
        Word address = cpu.get_reg(rn) + offset;
        static if (is_load) cpu.ldrh(rd, address);
        else                cpu.strh(rd, address);
    }

    static void create_pop(bool lr_included)(T cpu, Half opcode) {
        auto register_list = get_nth_bits(opcode, 0, 8);
        AccessType access_type = AccessType.NONSEQUENTIAL;

        Word current_address = cpu.get_reg(sp);
        for (int i = 0; i < 8; i++) {
            if (get_nth_bit(register_list, i)) {
                cpu.set_reg(i, cpu.read_word(current_address & ~3, access_type));
            
                if (g_profile_gba) {
                    g_profiler.notify__cpu_popped_stack(i, current_address & ~3);
                }

                current_address += 4;

                access_type = AccessType.SEQUENTIAL;
            }
        }

        cpu.set_pipeline_access_type(AccessType.NONSEQUENTIAL);

        static if (lr_included) {
            cpu.set_reg(pc, cpu.read_word(current_address & ~3, access_type));
            
            if (g_profile_gba) {
                g_profiler.notify__cpu_popped_stack(lr, current_address & ~3);
            }

            current_address += 4;
        }

        cpu.set_reg(sp, current_address);
    }

    static void create_push(bool lr_included)(T cpu, Half opcode) {
        auto register_list = get_nth_bits(opcode, 0, 8);
        AccessType access_type = AccessType.NONSEQUENTIAL;

        Word current_address = cpu.get_reg(sp);

        static if (lr_included) {
            current_address -= 4;
            cpu.write_word(current_address & ~3, cpu.get_reg(lr), access_type);

            if (g_profile_gba) {
                g_profiler.notify__cpu_pushed_stack(lr, current_address & ~3);
            }
        }

        for (int i = 7; i >= 0; i--) {
            if (get_nth_bit(register_list, i)) {
                current_address -= 4;
                cpu.write_word(current_address & ~3, cpu.get_reg(i), access_type);

                    if (g_profile_gba) {
                        g_profiler.notify__cpu_pushed_stack(i, current_address & ~3);
                    }

                access_type = AccessType.SEQUENTIAL;
            }
        }

        cpu.set_pipeline_access_type(AccessType.NONSEQUENTIAL);

        cpu.set_reg(sp, current_address);
    }

    static void create_store_half(T cpu, Half opcode) {
        Reg rd      = get_nth_bits(opcode, 0, 3);
        Reg rn      = get_nth_bits(opcode, 3, 6);
        Word offset = get_nth_bits(opcode, 6, 11) * 2;

        cpu.strh(rd, cpu.get_reg(rn) + offset);
    }

    static void create_swi(T cpu, Half opcode) {
        cpu.swi();
    }

    static void create_nop(T cpu, Half opcode) {}

    static JumptableEntry[256] create_jumptable() {
        JumptableEntry[256] jumptable;

        static foreach (entry; 0 .. 256) {
            if ((entry & 0b1111_1111) == 0b1101_1111) {
                jumptable[entry] = &create_swi;
            } else

            if ((entry & 0b1110_0000) == 0b0010_0000) {
                enum op = get_nth_bits(entry, 3, 5);
                enum rd = get_nth_bits(entry, 0, 3);
                jumptable[entry] = &create_add_sub_mov_cmp!(rd, op);
            } else

            if ((entry & 0b1111_1100) == 0b0001_1000) {
                enum op = get_nth_bit(entry, 1);
                jumptable[entry] = &create_add_sub!op;
            } else

            if ((entry & 0b1111_0000) == 0b1101_0000) {
                enum cond = get_nth_bits(entry, 0, 4);
                jumptable[entry] = &create_conditional_branch!cond;
            } else

            if ((entry & 0b1111_1111) == 0b0100_0111) {
                jumptable[entry] = &create_branch_exchange;
            } else

            if ((entry & 0b1111_1000) == 0b0100_1000) {
                enum rd = get_nth_bits(entry, 0, 3);
                jumptable[entry] = &create_pc_relative_load!rd;
            } else

            if ((entry & 0b1111_0000) == 0b1111_0000) {
                enum is_first_instruction = !get_nth_bit(entry, 3);
                jumptable[entry] = &create_long_branch!is_first_instruction;
            } else

            if ((entry & 0b1111_1100) == 0b0100_0000) {
                jumptable[entry] = &create_full_alu;
            } else

            if ((entry & 0b1111_1000) == 0b1100_0000) {
                enum base = get_nth_bits(entry, 0, 3);
                jumptable[entry] = &create_stm!base;
            } else

            if ((entry & 0b1111_1000) == 0b1100_1000) {
                enum base = get_nth_bits(entry, 0, 3);
                jumptable[entry] = &create_ldm!base;
            } else

            if ((entry & 0b1111_1100) == 0b0001_1100) {
                enum op = get_nth_bit(entry, 1);
                jumptable[entry] = &create_add_sub_immediate!op;
            } else

            if ((entry & 0b1110_0000) == 0b0110_0000) {
                enum is_load = get_nth_bit(entry, 3);
                enum is_byte = get_nth_bit(entry, 4);
                jumptable[entry] = &create_load_store_immediate_offset!(is_load, is_byte);
            } else

            if ((entry & 0b1111_1100) == 0b0100_0100) {
                enum op = get_nth_bits(entry, 0, 2);
                jumptable[entry] = &create_alu_high_registers!op;
            } else

            if ((entry & 0b1111_0000) == 0b1010_0000) {
                enum rd    = get_nth_bits(entry, 0, 3);
                enum is_sp = get_nth_bit (entry, 3);
                jumptable[entry] = &create_add_sp_pc_relative!(rd, is_sp);
            } else

            if ((entry & 0b1111_0000) == 0b0000_0000) {
                enum is_lsr = get_nth_bit(entry, 3);
                jumptable[entry] = &create_logical_shift!is_lsr;
            } else

            if ((entry & 0b1111_0000) == 0b001_0000) {
                jumptable[entry] = &create_arithmetic_shift;
            } else

            if ((entry & 0b1111_1111) == 0b1011_0000) {
                jumptable[entry] = &create_modify_sp;
            } else

            if ((entry & 0b1111_1000) == 0b1110_0000) {
                jumptable[entry] = &create_unconditional_branch;
            } else

            if ((entry & 0b1111_0000) == 0b0101_0000) {
                enum op = get_nth_bits(entry, 1, 4);
                jumptable[entry] = &create_load_store_register_offset!op;
            } else

            if ((entry & 0b1111_0000) == 0b1001_0000) {
                enum rd      = get_nth_bits(entry, 0, 3);
                enum is_load = get_nth_bit (entry, 3);
                jumptable[entry] = &create_sp_relative_load_store!(rd, is_load);
            } else

            if ((entry & 0b1111_0000) == 0b1000_0000) {
                enum is_load = get_nth_bit(entry, 3);
                jumptable[entry] = &create_half_access!is_load;
            } else

            if ((entry & 0b1111_1110) == 0b1011_1100) {
                enum lr_included = get_nth_bit(entry, 0);
                jumptable[entry] = &create_pop!lr_included;
            } else

            if ((entry & 0b1111_1110) == 0b1011_0100) {
                enum lr_included = get_nth_bit(entry, 0);
                jumptable[entry] = &create_push!lr_included;
            } else

            if ((entry & 0b1111_1000) == 0b1000_0000) {
                jumptable[entry] = &create_store_half;
            } else

            jumptable[entry] = &create_nop;
        }

        return jumptable;
    }

    static JumptableEntry[256] jumptable = create_jumptable();
}