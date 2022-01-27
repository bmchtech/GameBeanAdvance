module hw.cpu.arm7tdmi;

import hw.memory;
import hw.interrupts;

import abstracthw.cpu;
import abstracthw.memory;
import hw.cpu;

import diag.logger;

import util;

import jumptable_thumb;
import jumptable_arm;

import std.stdio;
import std.conv;

uint _g_num_log = 0;

final class ARM7TDMI : IARM7TDMI {

    Word[2] arm_pipeline;
    Half[2] thumb_pipeline;
    
    Memory memory;

    InstructionSet instruction_set;   

    bool enabled = false;
    bool halted  = false; 

    AccessType pipeline_access_type;

    this(Memory memory) {
        this.memory = memory;
    }

    pragma(inline, true) T fetch(T)() {

        static if (is(T == Word)) {
            T result        = arm_pipeline[0];
            arm_pipeline[0] = arm_pipeline[1];
            arm_pipeline[1] = memory.read_word(regs[pc]);
            writefln("fetching %x %x", regs[pc], arm_pipeline[1]);
            regs[pc] += 4;
            return result;
        }

        static if (is(T == Half)) {
            T result          = thumb_pipeline[0];
            thumb_pipeline[0] = thumb_pipeline[1];
            thumb_pipeline[1] = memory.read_half(regs[pc]);
            regs[pc] += 2;
            return result;
        }

        assert(0);
    }

    pragma(inline, true) void execute(T)(T opcode) {
        static if (is(T == Word)) {
            auto cond = get_nth_bits(opcode, 28, 32);
            if (likely(check_cond(cond))) {
                auto entry = get_nth_bits(opcode, 4, 8) | (get_nth_bits(opcode, 20, 28) << 4);
                jumptable_arm.jumptable[entry](this, opcode);
            }
        }

        static if (is(T == Half)) {
            jumptable_thumb.jumptable[opcode >> 8](this, opcode);
        }
    }

    void run_instruction() {
        if (instruction_set == InstructionSet.ARM) {
            Word opcode = fetch!Word();
            writefln("ARM: executing %x", opcode);
            execute!Word(opcode);
        } else {
            Half opcode = fetch!Half();
            execute!Half(opcode);
        }
    }

    pragma(inline, true) Word get_reg(int i) {
        if (i == pc) {
            return regs[pc] - (instruction_set == InstructionSet.ARM ? 4 : 2);
        }
        
        return regs[i];
    }

    pragma(inline, true) void set_reg(int i, Word value) {
        regs[i] = value;

        if (i == pc) {
            align_pc();
            refill_pipeline();
        }
    }

    pragma(inline, true) void align_pc() {
        regs[pc] &= instruction_set == InstructionSet.ARM ? ~3 : ~1;
    }

    Word get_cpsr() { 
        return cpsr; 
    }

    InstructionSet get_instruction_set() { 
        return instruction_set; 
    }

    Word get_pipeline_entry(int i) {
        return instruction_set == InstructionSet.ARM ? 
            arm_pipeline[i] :
            thumb_pipeline[i]; 
    }

    void exception(CpuException exception) {

    }


    void enable() {
        this.enabled = true;
    }

    void disable() {
        this.enabled = false;
    }

    void halt() {
        this.halted = true;
    }

    void set_mode(CpuMode mode) {

    }

    void set_interrupt_manager(InterruptManager m) {

    }

    void refill_pipeline() {
        if (instruction_set == InstructionSet.ARM) {
            fetch!Word();
            fetch!Word();
        } else {
            fetch!Half();
            fetch!Half();
        }
    }

    // reads the CPSR and figures out what the current mode is. then, it updates it using new_mode.
    void update_mode() {
        int mode_bits = get_nth_bits(*cpsr, 0, 5);
        for (int i = 0; i < NUM_CPU_MODES; i++) {
            if (MODES[i].CPSR_ENCODING == mode_bits) {
                set_mode(MODES[i]);
            }
        }
    }

    pragma(inline, true) bool has_spsr() {
        return !(current_mode == MODE_USER || current_mode == MODE_SYSTEM);
    }

    pragma(inline, true) bool in_a_privileged_mode() {
        return current_mode != MODE_USER;
    }

    uint[] m_register_file;
    uint[] m_regs;

    @property uint[] regs() { return m_regs; }
    @property uint[] register_file() { return m_register_file; }

    uint* m_pc;
    uint* m_lr;
    uint* m_sp;
    uint* m_cpsr;
    uint* m_spsr; // not valid in USER or SYSTEM modes
    
    uint m_shifter_operand;
    bool m_shifter_carry_out;

    @property uint* pc() { return m_pc;}
    @property uint* lr() { return m_lr;}
    @property uint* sp() { return m_sp;}
    @property uint* cpsr() { return m_cpsr;}
    @property uint* spsr() { return m_spsr;}

    @property bool shifter_carry_out() { return m_shifter_carry_out;}
    @property bool shifter_carry_out(bool value) { return m_shifter_carry_out = value;}

    @property uint shifter_operand() { return m_shifter_operand;}
    @property uint shifter_operand(uint value) { return m_shifter_operand = value;}

    pragma(inline, true) uint read_reg(int reg) {
        // when reading register PC (15), the pipeline will cause the read value to be
        // one instruction_size greater than it should be. therefore if we're trying to
        // read from pc, we subtract the current instruction_size to accomodate for this.
        return reg == 15 ? regs[reg] - (get_bit_T() ? 2 : 4) : regs[reg];
    }

    pragma(inline, true) void write_reg(int reg, uint value) {
        regs[reg] = value;
        if (reg == 15) refill_pipeline();
    }

    // reg is [0, 7] - these are used to access only the lower regs
    pragma(inline, true) uint read_reg__lower(int reg) {
        return regs[reg];
    }

    // reg is [0, 7] - these are used to access only the lower regs
    pragma(inline, true) void write_reg__lower(int reg, uint value) {
        regs[reg] = value;
    }

    pragma(inline, true) void set_flag_N(bool condition) {
        if (condition) *cpsr |= 0x80000000;
        else           *cpsr &= 0x7FFFFFFF;
    }

    pragma(inline, true) void set_flag_Z(bool condition) {
        if (condition) *cpsr |= 0x40000000;
        else           *cpsr &= 0xBFFFFFFF;
    }

    pragma(inline, true) void set_flag_C(bool condition) {
        if (condition) *cpsr |= 0x20000000;
        else           *cpsr &= 0xDFFFFFFF;
    }

    pragma(inline, true) void set_flag_V(bool condition) {
        if (condition) *cpsr |= 0x10000000;
        else           *cpsr &= 0xEFFFFFFF;
    }

    pragma(inline, true) void set_bit_T(bool condition) {
        if (condition) *cpsr |= 0x00000020;
        else           *cpsr &= 0xFFFFFFDF;

        current_instruction_size = condition ? 2 : 4;
    }

    pragma(inline, true) bool get_flag_N() {
        return (*cpsr >> 31) & 1;
    }

    pragma(inline, true) bool get_flag_Z() {
        return (*cpsr >> 30) & 1;
    }

    pragma(inline, true) bool get_flag_C() {
        return (*cpsr >> 29) & 1;
    }

    pragma(inline, true) bool get_flag_V() {
        return (*cpsr >> 28) & 1;
    }

    pragma(inline, true) bool get_bit_T() {
        return (*cpsr >> 5) & 1;
    }

    ulong cycle() {
        memory.cycles = 0;

        if (interrupt_manager.has_irq()) exception(CpuException.IRQ);

        if (Logger.instance) Logger.instance.capture_cpu();

        _g_cpu_cycles_remaining = 0;

        uint opcode = m_pipeline[0];
        m_pipeline[0] = m_pipeline[1];
        m_pipeline[1] = fetch();

        m_pipeline_access_type = AccessType.SEQUENTIAL;

        if (*pc > 0x0FFF_FFFF) {
            error("PC out of range!");
        }

        // if (*pc == 0xC) {
        //    error("rebooting");
        // }

        if (_g_num_log > 0) {
            _g_num_log--;
            writef("[%04x] ", _g_num_log);
            if (get_bit_T()) write("THM ");
            else write("ARM ");

            write(format("0x%x ", opcode));
            
            for (int j = 0; j < 16; j++)
                write(format("%08x ", regs[j]));

            // write(format("%x ", *cpsr));
            write(format("%x", register_file[MODE_SYSTEM.OFFSET + 17]));
            writeln();
            if (_g_num_log == 0) writeln();
        }

        m_memory.can_read_from_bios = (*pc >> 24) == 0;
        execute(opcode);

        return 0;
    }

    bool check_condition(uint cond) {
        likely(cond == 0xE);
        
        switch (cond) {
        case 0x0: return ( get_flag(Flag.Z));
        case 0x1: return (!get_flag(Flag.Z));
        case 0x2: return ( get_flag(Flag.C));
        case 0x3: return (!get_flag(Flag.C));
        case 0x4: return ( get_flag(Flag.N));
        case 0x5: return (!get_flag(Flag.N));
        case 0x6: return ( get_flag(Flag.V));
        case 0x7: return (!get_flag(Flag.V));
        case 0x8: return ( get_flag(Flag.C) && !get_flag(Flag.Z));
        case 0x9: return (!get_flag(Flag.C) ||  get_flag(Flag.Z));
        case 0xA: return ( get_flag(Flag.N) ==  get_flag(Flag.V));
        case 0xB: return ( get_flag(Flag.N) !=  get_flag(Flag.V));
        case 0xC: return (!get_flag(Flag.Z) && (get_flag(Flag.N) == get_flag(Flag.V)));
        case 0xD: return ( get_flag(Flag.Z) || (get_flag(Flag.N) != get_flag(Flag.V)));
        case 0xE: return true;
        case 0xF: error("Opcode has COND == 0xF"); return false;

        default: error(format("Illegal cond passed in: %x", cond)); return false;
        }
    }

    void set_flag(Flag flag, bool value) {
        auto set   = (uint offset) => cpsr |=  (1 << offset);
        auto clear = (uint offset) => cpsr &= ~(1 << offset);
        auto modify = (uint offset, bool value) => value ? set(offset) : clear(offset);

        modify(flag, value);

        if (flag == Flag.T) {
            instruction_set = value ? instruction_set.THUMB : instruction_set.ARM;
        }
    }

    void execute(uint opcode) {
        if (get_bit_T()) {
            jumptable_thumb.exec!ARM7TDMI.jumptable[opcode >> 8](this, cast(ushort)opcode);
        } else {
            if (check_condition(opcode >> 28)) {
                jumptable_arm.exec!ARM7TDMI.execute_instruction(opcode, this);
            }
        }
    }

    void set_pipeline_access_type(AccessType access_type) {
        this.pipeline_access_type = access_type;
    }

    void run_idle_cycle() {
        pipeline_access_type = AccessType.NONSEQUENTIAL;
        memory.idle();
    }

    Word read_word(Word address, AccessType access_type) { return memory.read_word(address, access_type, false); }
    Half read_half(Word address, AccessType access_type) { return memory.read_half(address, access_type, false); }
    Byte read_byte(Word address, AccessType access_type) { return memory.read_byte(address, access_type, false); }

    void write_word(Word address, Word value, AccessType access_type) { memory.write_word(address, value, access_type, false); }
    void write_half(Word address, Half value, AccessType access_type) { memory.write_half(address, value, access_type, false); }
    void write_byte(Word address, Byte value, AccessType access_type) { memory.write_byte(address, value, access_type, false); }
}
