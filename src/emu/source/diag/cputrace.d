module diag.cputrace;

import hw.cpu;

import abstracthw.cputrace;

import util.ringbuffer;

import std.stdio;
import std.format;

final class CpuTrace : ICpuTrace {
    ARM7TDMI cpu;
    RingBuffer!CpuState ringbuffer;

    this(ARM7TDMI cpu, int length) {
        this.cpu        = cpu;
        this.ringbuffer = new RingBuffer!CpuState(length);
    }

    void capture() {
        ringbuffer.add(get_cpu_state(cpu));
    }

    void print_trace() {
        CpuState[] trace = ringbuffer.get();
        for (int i = 0; i < trace.length; i++) {
            writef("[%04d]", trace.length - i);
            
            if (trace[i].type == CpuType.THUMB) {
                write("THUMB     ");
                write(format("%04x | ", trace[i].opcode));
            } else {
                write("ARM   ");
                write(format("%08x | ", trace[i].opcode));
            }

            for (int j = 0; j < 16; j++)
                write(format("%08x ", trace[i].regs[j]));

            write(format(" | %08x", trace[i].mode));
            writeln();
        }
    }
}