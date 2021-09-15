module diag.logger;

import hw.gba;

import diag.cputrace;

import util;

import std.stdio;
import std.conv;

class Logger {
    static Logger instance;

    static Logger singleton(CpuTrace cpu_trace) {
        if (!instance)
            instance = new Logger(cpu_trace);
        
        return instance;
    }

    void print() {
        writeln("error!");
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