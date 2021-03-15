module cputrace;

import cpu;

class CpuTrace() {
    ARM7TDMI   cpu;
    RingBuffer ringbuffer;

    this(ARM7TDMI cpu, int length) {
        this.cpu        = cpu;
        this.ringbuffer = RingBuffer!CpuState(length);
    }

    void capture() {
        ringbuffer.add(get_cpu_state(cpu));
    }

    void print_trace() {
        CpuState[] trace = ringbuffer.get();
        for (int i = 0; i < trace.length; i++) {
            write(format("%x | ", state.mode));
            write(format("%x | ", state.opcode));

            for (int i = 0; i < 16; i++)
                write(format("%x ", i, state.regs[i]));
        }
    }
}