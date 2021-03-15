module cputrace;

import std.stdio;
import std.format;

import cpu;
import ringbuffer;

class CpuTrace {
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
            write(format("%x | ", trace[i].mode));
            write(format("%x | ", trace[i].opcode));

            for (int j = 0; j < 16; j++)
                write(format("%x ", j, trace[i].regs[j]));
        }
    }
}