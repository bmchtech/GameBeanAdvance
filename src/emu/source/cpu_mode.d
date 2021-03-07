module cpu_mode;

version(!(CPUMODE_H))
{
version = CPUMODE_H;

// CPU modes will be described as the following:
// 1) their encoding in the CPSR register
// 2) their register uniqueness (see the diagram in arm7tdmi.h).
// 3) their offset into the registers array.

struct CpuMode
{
    this(
        const(int) c, 
        const(int) r, 
        const(int) o
    )
    {

        CPSR_ENCODING = c;
        REGISTER_UNIQUENESS = r;
        OFFSET = o;    }
    
    int CPSR_ENCODING;
    int REGISTER_UNIQUENESS;
    int OFFSET;
}