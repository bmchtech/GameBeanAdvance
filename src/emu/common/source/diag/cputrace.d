module diag.cputrace;

interface ICpuTrace {
    void print_trace();
    void capture();
}