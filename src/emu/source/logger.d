module logger;

import gba;
import util;
import std.stdio;
import std.conv;

class Logger {
    this(GBA gba) {
        gba = gba;
    }

    void error(string msg) {
        writefln("---- E ---- R ---- R ----");
        if (gba !is null) {
            for (int i = 0; i < CPU_STATE_LOG_LENGTH; i++) {
                CpuState cpu_state = gba.cpu.cpu_states[i];
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
        util.error(msg);
    }

    void warning(string msg) {
        util.warning(msg);
    }

private:
    GBA gba;
}
