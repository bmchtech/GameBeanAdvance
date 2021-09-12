module rom_tests;

import hw.gba;
import hw.cpu;
import hw.memory;

import util;

import std.conv;
import std.stdio;
import std.algorithm;
import std.array;
import std.range;
import std.format;

void assert_print_cpu_state(bool expression, CpuState expected, CpuState actual, string error_message) {
    if (!expression) {
        writeln("EXPECTED CPU STATE:");
        print_cpu_state(expected);

        writeln("\n");

        writeln("ACTUAL CPU STATE:");
        print_cpu_state(actual);
        
        assert(0, error_message);
    }
}

void print_cpu_state(CpuState state) {
    writeln(format("Opcode: %x", state.opcode));

    for (int i = 0; i < 16; i++)
        writeln(format("Register %s: %x", i, state.regs[i]));
    
    writeln(format("Mode: %x", state.mode));
    writeln(format("main[0x03000003]: %x", state.mem_0x03000003));
}

void check_cpu_state(CpuState expected, CpuState actual, string error_message) {
    for (int i = 0; i < 16; i++) {
        assert_print_cpu_state(expected.regs[i] == actual.regs[i], expected, actual, format("%s at register #%s", error_message, i));
    }

    assert_print_cpu_state( expected.type           ==  actual.type,           expected, actual, error_message);
    assert_print_cpu_state( expected.opcode         ==  actual.opcode,         expected, actual, error_message);
    // assert_print_cpu_state((expected.mode & 0x1F)   == (actual.mode & 0x1F),   expected, actual, error_message);
    assert_print_cpu_state( expected.mem_0x03000003 ==  actual.mem_0x03000003, expected, actual, error_message);
}

CpuState[] produce_expected_cpu_states(string file_name, uint num_lines) {
    CpuState[] states;

    foreach (line; File(file_name).byLine().take(num_lines)) {
        states = states ~ [produce_expected_cpu_state(line)];
    }

    return states;
}

CpuState produce_expected_cpu_state(char[] input_string) {
    CpuState state;
    string[] tokens = to!string(input_string).split();

    state.type           = tokens[0] == "ARM" ? CpuType.ARM : CpuType.THUMB;
    state.opcode         = to!uint(tokens[1][2..$],  16);
    state.mode           = 0;
    state.mem_0x03000003 = to!uint(tokens[18], 16);

    for (int i = 0; i < 16; i++) state.regs[i] = to!uint(tokens[i + 2], 16);
    state.regs[15] -= state.type == CpuType.ARM ? 8 : 4;

    return state;
}

void test_thumb_mode(string gba_file, string log_file, int num_instructions) {
    Memory   memory = new Memory();
    ARM7TDMI cpu    = new ARM7TDMI(memory);

    CpuState[] expected_output = produce_expected_cpu_states(log_file, num_instructions);
    
    ubyte[] rom = get_rom_as_bytes(gba_file);
    cpu.memory.rom[0 .. rom.length] = rom[0 .. rom.length];

    set_cpu_state(cpu, expected_output[0]);
    cpu.refill_pipeline();
    cpu.set_mode(cpu.MODE_SYSTEM);

    bool wasPreviousInstructionARM = true; // if so, we reset the CPU's state
    for (int i = 0; i < num_instructions - 1; i++) {
        // print_cpu_state(get_cpu_state(cpu));

        if (expected_output[i].type == CpuType.THUMB) {
            if (wasPreviousInstructionARM) {
                cpu.set_bit_T(true);
                set_cpu_state(cpu, expected_output[i]);
                // print_cpu_state(get_cpu_state(cpu));
                cpu.refill_pipeline();
            }
            
            cpu.cycle();

            check_cpu_state(expected_output[i + 1], get_cpu_state(cpu), "Failed at instruction #" ~ to!string(i));
        } else {
            wasPreviousInstructionARM = true;
        }
    }

    // make sure we've reached B infin
    assert(cpu.pipeline[0] == 0xE7FE, "ROM did not reach B infin!");
}

void test_arm_mode(string gba_file, string log_file, int num_instructions, int start_instruction, bool b_infin_check) {
    Memory   memory = new Memory();
    ARM7TDMI cpu    = new ARM7TDMI(memory);

    CpuState[] expected_output = produce_expected_cpu_states(log_file, num_instructions);
    
    ubyte[] rom = get_rom_as_bytes(gba_file);
    cpu.memory.rom[0 .. rom.length] = rom[0 .. rom.length];

    set_cpu_state(cpu, expected_output[0]);
    cpu.set_bit_T(true);
    cpu.set_mode(cpu.MODE_SYSTEM);
    cpu.refill_pipeline();

    for (int i = 0; i < num_instructions - 1; i++) {
        // print_cpu_state(get_cpu_state(cpu));

        // ARM instructions won't be run until log #190 is passed (the ARM that occurs before then is needless 
        // busywork as far as these tests are concerned, and make it harder to unit test the emulator).
        if (i == start_instruction) {
            // cpu.set_bit_T(false);
            *cpu.cpsr = (*cpu.cpsr & 0x00FFFFFFFF) | 0x60000000; // theres a bit of arm instructions that edit the CPSR that we skip, so let's manually set it.
        }

        if (i < start_instruction) cpu.set_bit_T(true);

        if (i > start_instruction || expected_output[i].type == CpuType.THUMB) {
            cpu.cycle();
            check_cpu_state(expected_output[i + 1], get_cpu_state(cpu), "Failed at instruction #" ~ to!string(i));
        } else {
            print_cpu_state(get_cpu_state(cpu));
            set_cpu_state(cpu, expected_output[i + 1]);
            cpu.refill_pipeline();
        }
    }

    // make sure we've reached B infin
    if (b_infin_check) assert(cpu.pipeline[0] == 0xEAFFFFFE, "ROM did not reach B infin!");
}



// @("tests-thumb") 
// unittest {
//     test_thumb_mode("../../tests/asm/bin/thumb-simple.gba", "../../tests/asm/logs/thumb-simple.log", 3866);
// }

// @("tests-arm-addressing-mode-1") 
// unittest {
//     test_arm_mode("../../tests/asm/bin/arm-addressing-mode-1.gba", "../../tests/asm/logs/arm-addressing-mode-1.log", 1290, 216, true);
// }

// @("tests-arm-addressing-mode-2") 
// unittest {
//     test_arm_mode("../../tests/asm/bin/arm-addressing-mode-2.gba", "../../tests/asm/logs/arm-addressing-mode-2.log", 1290, 212, true);
// }

// @("tests-arm-addressing-mode-3") 
// unittest {
//     test_arm_mode("../../tests/asm/bin/arm-addressing-mode-3.gba", "../../tests/asm/logs/arm-addressing-mode-3.log", 1290, 212, true);
// }

// @("tests-arm-opcodes") 
// unittest {
//     test_arm_mode("../../tests/asm/bin/arm-opcodes.gba", "../../tests/asm/logs/arm-opcodes.log", 2000, 276, true);
// }

// @("tests-roms-fountain") 
// unittest {
//     test_arm_mode("../../tests/asm/bin/Fountain.gba", "../../tests/asm/logs/Fountain.log", 300000, 0, false);
// }

// @("tests-roms-superstar-saga") 
// unittest {
//     test_arm_mode("roms/superstarsaga.gba", "../../tests/asm/logs/superstarsaga.log", 2100, 0, false);
// }