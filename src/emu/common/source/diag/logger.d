module diag.logger;

import std.stdio;
import std.conv;

import abstracthw.gba;
import abstracthw.cpu;

import util;

import abstracthw.cputrace;

class Logger {
    static Logger instance;

    static Logger singleton(ICpuTrace cpu_trace) {
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
    this(ICpuTrace cpu_trace) {
        this.cpu_trace = cpu_trace;
    }

    ICpuTrace cpu_trace;
}