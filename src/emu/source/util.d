module util;

import core.stdc.math; //core.stdc.math.pow 
import core.stdc.stdint; //uint32_t uint8_t 
import core.stdc.stdlib; //core.stdc.stdlib.exit 
import std.stdio;
import std.conv;
import gba;

public {
    import std.format;
}

enum YELLOW = "\033[33m";
enum RED = "\033[31m";
enum RESET = "\033[0m";

static int verbosity_level = 0;

// get nth bits from value as so: [start, end)
uint32_t get_nth_bits(uint val, ubyte start, ubyte end) {
    return (val >> start) & cast(uint32_t)(core.stdc.math.pow(2, end - start) - 1);
}

// get nth bit from value
bool get_nth_bit(uint val, ubyte n) {
    return (val >> n) & 1;
}

// sign extend the given value
uint sign_extend(uint val, ubyte num_bits) {
    return (val ^ (1 << (num_bits - 1))) - (1 << (num_bits - 1));
}

template VERBOSE_LOG(string Level, string Content) {
        enum VERBOSE_LOG = `if (` ~ Level ~ ` <= verbosity_level)
         writefln(` ~ Content ~ `);
    `;
}

// a warning will not terminate the program
void warning(string message) {
    stderr.writefln("%sWARNING: %s%s", YELLOW, RESET, message);
}

// an error terminates the program and calls exit(EXIT_FAILURE);
void error(string message) {
    stderr.writefln("%sERROR: %s%s", RED, RESET, message);

    assert(0, "terminating due to error");
}

string to_hex_string(uint val) {
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
