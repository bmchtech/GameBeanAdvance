module logger;

import std.stdio;
import std.conv;

import gba;
import util;
import cputrace;

class Logger {
    static Logger instance;

    static Logger singleton(CpuTrace cpu_trace) {
        if (!instance)
            instance = new Logger(cpu_trace);
        
        return instance;
    }

    void print() {
        writeln("HEY!");
        cpu_trace.print_trace();
    }

private:
    this(CpuTrace cpu_trace) {
        this.cpu_trace = cpu_trace;
    }

    CpuTrace cpu_trace;
}