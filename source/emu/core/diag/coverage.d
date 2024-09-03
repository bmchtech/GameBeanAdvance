module emu.core.diag.coverage;

import util;

struct CoverageTrace {
    size_t[Word] block_hits;

    void hit(Word block) {
        block_hits[block]++;
    }
}

class CpuCoverage {
    public CoverageTrace[] traces;
    public CoverageTrace* curr_trace;
    public bool tracing = false;

    this() {
        traces = [];
        curr_trace = null;
    }

    void new_trace() {
        traces ~= CoverageTrace();
        curr_trace = &traces[$ - 1];
    }

    void start_tracing() {
        tracing = true;
    }

    void stop_tracing() {
        tracing = false;
    }

    void commit_trace() {
        curr_trace = null;
    }

    CoverageTrace[] get_traces() {
        return traces;
    }
}
