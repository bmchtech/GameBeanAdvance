module util;

import core.stdc.math; //core.stdc.math.pow 
import core.stdc.stdint; //uint32_t uint8_t 
import core.stdc.stdlib; //core.stdc.stdlib.exit 
import std.stdio;
import std.conv;
import std.format;
import gba;

enum YELLOW = "\033[33m";
enum RED    = "\033[31m";
enum RESET  = "\033[0m";

// a warning will not terminate the program
void warning(string message);
// an error terminates the program and calls exit(EXIT_FAILURE);
void error(string message);
// converts uint32_t to hex string
string to_hex_string(uint32_t val);
// get nth bits from value as so: [start, end)
uint32_t get_nth_bits(uint32_t val, uint8_t start, uint8_t end) {
    return (val >> start) & cast(uint32_t)(core.stdc.math.pow(2, end - start) - 1);
}

// get nth bit from value
bool get_nth_bit(uint32_t val, uint8_t n) {
    return (val >> n) & 1;
}

// sign extend the given value
uint32_t sign_extend(uint32_t val, uint8_t num_bits) {
    return (val ^ (1 << (num_bits - 1))) - (1 << (num_bits - 1));
}

void warning(string message) {
    stderr.writefln("%sWARNING: %s%s", YELLOW, RESET, message);
}

void error(string message) {
    stderr.writefln("%sERROR: %s%s", RED, RESET, message);

    if (logger_gba != null) {
        for (int i = 0; i < CPU_STATE_LOG_LENGTH; i++) {
            CpuState cpu_state = logger_gba.cpu.cpu_states[i];
            writefln(((cpu_state.type == CpuType.ARM) ? "ARM " : "THUMB "));
            writefln(to_hex_string(cpu_state.opcode));
            writefln(" ||");

            for (int j = 0; j < 16; j++) {
                string register_value = to_hex_string(cpu_state.regs[j]);
                writefln(" %s", (to!string(8 - register_value.length, '0') ~ register_value));
            }

            write(" ||");

            writefln(" %s", to_hex_string(cpu_state.mode));
        }
    }

    core.stdc.stdlib.exit(-1);
}

string to_hex_string(uint32_t val) {
    return format("%x", val);
}

// get nth bits from value as so: [start, end)
pragma(inline) int get_nth_bits(int val, int start, int end) {
    return (val >> start) & cast(uint)(pow(2, end - start) - 1);
}

// get nth bit from value
pragma(inline) bool get_nth_bit(int val, int n) {
    return (val >> n) & 1;
}

// sign extend the given value
pragma(inline) int sign_extend(int val, int num_bits) {
    return (val ^ (1U << (num_bits - 1))) - (1U << (num_bits - 1));
}

ubyte[] get_rom_as_bytes(string rom_name) {
	File file = File(rom_name, "r");
    auto buffer = new ubyte[file.size()];
    file.rawRead(buffer);
    return buffer;
}

GBA* logger_gba = null;
