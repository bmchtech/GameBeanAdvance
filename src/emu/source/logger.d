module logger;

import std.stdio;
import std.conv;

import hw.gba;
import util;
import diag.cputrace;

class Logger {
    static Logger instance;

    static Logger singleton(CpuTrace cpu_trace) {
        if (!instance)
            instance = new Logger(cpu_trace);
        
        return instance;
    }

    void print() {
        cpu_trace.print_trace();
    }
    
    void capture_cpu() {
        cpu_trace.capture();
    }

private:
    this(CpuTrace cpu_trace) {
        this.cpu_trace = cpu_trace;
    }

    CpuTrace cpu_trace;
}