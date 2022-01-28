module util;

// import diag.logger;

import core.stdc.math; //core.stdc.math.pow 

import std.stdio;
import std.conv;

import diag.logger;

public {
    import std.format;
}

alias u8  = ubyte;
alias u16 = ushort;
alias u32 = uint;
alias u64 = ulong;
alias s8  = byte;
alias s16 = short;
alias s32 = int;
alias s64 = long;

alias Word = uint;
alias Half = ushort;
alias Byte = ubyte;

version (LDC) {
    import ldc.intrinsics;
}

pragma(inline, true) bool likely(bool value) {
    version (LDC) {
        return llvm_expect!bool(value, true);
    } else {
        return value;
    }
}

pragma(inline, true) bool unlikely(bool value) {
    version (LDC) {
        return llvm_expect!bool(value, false);
    } else {
        return value;
    }
}

enum YELLOW = "\033[33m";
enum RED = "\033[31m";
enum RESET = "\033[0m";

static int verbosity_level = 0;

// get nth bits from value as so: [start, end)
// pragma(inline) uint get_nth_bits(uint val, ubyte start, ubyte end) {
//     return (val >> start) & ((1 << (end - start)) - 1);
// }

// get nth bit from value
pragma(inline, true) bool get_nth_bit(uint val, ubyte n) {
    return (val >> n) & 1;
}

// sign extend the given value
uint sign_extend(uint val, ubyte num_bits) {
    return (val ^ (1 << (num_bits - 1))) - (1 << (num_bits - 1));
}

// a warning will not terminate the program
void warning(string message) {
    stderr.writefln("%sWARNING: %s%s", YELLOW, RESET, message);
}

// an error terminates the program and calls exit(EXIT_FAILURE);
void error(string message) {
    if (Logger.instance) {
        Logger.instance.print();
    }
    stderr.writefln("%sERROR: %s%s", RED, RESET, message);

    assert(0, "terminating due to error");
}

string to_hex_string(uint val) {
    return format("%x", val);
}

// get nth bits from value as so: [start, end)
pragma(inline, true) pure int get_nth_bits(int val, const int start, const int end) {
    if (end - start == 32) return val;
    else return cast(uint)(cast(uint)(val) >> start) & ((1 << cast(uint)(end - start)) - 1);
}

// get nth bit from value
// please inline this function for the love of god the profiler is screaming at you
pragma(inline, true) pure bool get_nth_bit(int val, int n) {
    return (val >> n) & 1;
}

// sign extend the given value
pragma(inline, true) pure int sign_extend(int val, int num_bits) {
    return (val ^ (1U << (num_bits - 1))) - (1U << (num_bits - 1));
}

pragma(inline, true) pure uint rotate_right(uint val, int shift) {
    return (val >> shift) | (val << (32 - shift));
}

ubyte[] load_rom_as_bytes(string rom_name) {
    File file = File(rom_name, "r");
    auto buffer = new ubyte[file.size()];
    file.rawRead(buffer);
    return buffer;
}

pragma(inline) double convert_from_8_8f_to_double(ushort input) {
    return ((cast(short) input) >> 8) + ((cast(double) (input & 0xFF)) / 256.0);
}

pragma(inline) ushort convert_from_double_to_8_8f(double input) {
    return (cast(ushort) ((cast(ushort) (input / 1)) << 8)) | ((cast(ushort) ((input % 1) * 256)) & 0xFF);
}

final class NSStopwatch {
    import core.time;

    this() {
        last_ticks = MonoTime.currTime();
    }

    long update() {
        auto ticks = MonoTime.currTime();
        auto elapsed_dur = ticks - last_ticks;
        long elapsed = elapsed_dur.total!"nsecs";
        last_ticks = ticks;

        total_time += elapsed;

        return elapsed;
    }

    MonoTimeImpl!(ClockType.normal) last_ticks;
    long total_time = 0;
}
