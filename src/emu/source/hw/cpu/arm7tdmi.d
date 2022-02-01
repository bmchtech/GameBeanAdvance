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
    Word[18 * 7] register_file;
    Word[18]     regs;

    Word[2] arm_pipeline;
    Half[2] thumb_pipeline;
    
    Memory memory;

    InstructionSet instruction_set;   

    bool enabled = false;
    bool halted  = false; 

    CpuMode current_mode;

    AccessType pipeline_access_type;

    this(Memory memory) {
        this.memory = memory;
        current_mode = MODE_USER;
        
        reset();
        // skip_bios();
    }

    void reset() {
        set_mode!MODE_SYSTEM;
        regs[pc] = 0;
        memory.can_read_from_bios = true;

        current_mode = MODES[0];
        for (int i = 0; i < 7; i++) {
            register_file[MODES[i].OFFSET + 16] |= MODES[i].CPSR_ENCODING;
        }    

        regs[0 .. 18] = register_file[MODE_USER.OFFSET .. MODE_USER.OFFSET + 18];
    }

    void skip_bios() {
        set_mode!MODE_SYSTEM;
        register_file[MODE_USER.OFFSET       + sp] = 0x03007f00;
        register_file[MODE_IRQ.OFFSET        + sp] = 0x03007fa0;
        register_file[MODE_SUPERVISOR.OFFSET + sp] = 0x03007fe0;

        set_flag(Flag.T, false);

        for (int i = 0; i < 7; i++) {
            register_file[MODES[i].OFFSET + 16] |= MODES[i].CPSR_ENCODING;
        }    
            
        regs[0 .. 18] = register_file[MODE_USER.OFFSET .. MODE_USER.OFFSET + 18];
        
        set_reg(pc, 0x0800_0000);
    }

    pragma(inline, true) T fetch(T)() {

        static if (is(T == Word)) {
            T result        = arm_pipeline[0];
            arm_pipeline[0] = arm_pipeline[1];
            arm_pipeline[1] = memory.read_word(regs[pc], pipeline_access_type);
            regs[pc] += 4;

            if (memory.can_start_new_prefetch() && pipeline_access_type == AccessType.NONSEQUENTIAL && regs[pc] >> 24 >= 8) {
                memory.invalidate_prefetch_buffer();
                memory.start_new_prefetch(regs[pc] >> 1, AccessSize.WORD);
            }

            pipeline_access_type = AccessType.SEQUENTIAL; 
            return result;
        }

        static if (is(T == Half)) {
            T result          = thumb_pipeline[0];
            thumb_pipeline[0] = thumb_pipeline[1];
            thumb_pipeline[1] = memory.read_half(regs[pc], pipeline_access_type);
            regs[pc] += 2;

            if (memory.can_start_new_prefetch() && pipeline_access_type == AccessType.NONSEQUENTIAL && regs[pc] >> 24 >= 8) {
                memory.invalidate_prefetch_buffer();
                memory.start_new_prefetch(regs[pc] >> 1, AccessSize.HALFWORD);
            }

            pipeline_access_type = AccessType.SEQUENTIAL; 
            return result;
        }

        assert(0);
    }

    pragma(inline, true) void execute(T)(T opcode) {
        static if (is(T == Word)) {
            auto cond = get_nth_bits(opcode, 28, 32);
            if (likely(check_cond(cond))) {
                auto entry = get_nth_bits(opcode, 4, 8) | (get_nth_bits(opcode, 20, 28) << 4);
                jumptable_arm.execute!ARM7TDMI.jumptable[entry](this, opcode);
            }
        }

        static if (is(T == Half)) {
            jumptable_thumb.execute!ARM7TDMI.jumptable[opcode >> 8](this, opcode);
        }
    }

    void run_instruction() {
        if (Logger.instance) Logger.instance.capture_cpu();
        if (interrupt_manager.has_irq()) raise_exception!(CpuException.IRQ);

        if (_g_num_log > 0) {
            _g_num_log--;
            // writefln("%x", _g_num_log);
            if (get_flag(Flag.T)) write("THM ");
            else write("ARM ");

            // write(format("0x%x ", instruction_set == InstructionSet.ARM ? arm_pipeline[0] : thumb_pipeline[0]));
            
            for (int j = 0; j < 18; j++)
            if (j != 15)
                write(format("%08x ", regs[j]));

            // write(format("%x ", *cpsr));
            // write(format("%x", register_file[MODE_SYSTEM.OFFSET + 17]));
            writeln();
            if (_g_num_log == 0) writeln();
        }

        if (instruction_set == InstructionSet.ARM) {
            Word opcode = fetch!Word();
            execute!Word(opcode);
        } else {
            Half opcode = fetch!Half();
            execute!Half(opcode);
        }

        // if (regs[pc] >> 24 == 0) _g_num_log += 20;

        if (regs[pc] <= 0xC) error(format("oh fukc %x", regs[pc]));
    }

    pragma(inline, true) Word get_reg(Reg id) {
        return get_reg__raw(id, &regs);
    }

    pragma(inline, true) void set_reg(Reg id, Word value) {
        set_reg__raw(id, value, &regs);
    }

    pragma(inline, true) Word get_reg(Reg id, CpuMode mode) {
        return get_reg__raw(id, cast(Word[18]*) (&register_file[mode.OFFSET]));
    }

    pragma(inline, true) void set_reg(Reg id, Word value, CpuMode mode) {
        return set_reg__raw(id, value, cast(Word[18]*) (&register_file[mode.OFFSET]));
    }

    pragma(inline, true) Word get_reg__raw(Reg id, Word[18]* regs) {
        if (unlikely(id == pc)) {
            return (*regs)[pc] - (instruction_set == InstructionSet.ARM ? 4 : 2);
        }
        
        return (*regs)[id];
    }

    pragma(inline, true) void set_reg__raw(Reg id, Word value, Word[18]* regs) {
        (*regs)[id] = value;

        if (id == pc) {        
            (*regs)[pc] &= instruction_set == InstructionSet.ARM ? ~3 : ~1;
            pipeline_access_type = AccessType.NONSEQUENTIAL;
            refill_pipeline();
        }
    }

    pragma(inline, true) void align_pc(CpuMode mode) {
        regs[mode.OFFSET + pc] &= instruction_set == InstructionSet.ARM ? ~3 : ~1;
    }

    InstructionSet get_instruction_set() { 
        return instruction_set; 
    }

    Word get_pipeline_entry(int i) {
        return instruction_set == InstructionSet.ARM ? 
            arm_pipeline[i] :
            thumb_pipeline[i]; 
    }


    void enable() {
        this.halted = false;
    }

    void disable() {
        this.halted = true;
    }

    void halt() {
        this.halted = true;
    }

    void set_mode(CpuMode new_mode)() {
        int mask;
        mask = current_mode.REGISTER_UNIQUENESS;
        
        // writeback
        for (int i = 0; i < 18; i++) {
            if (mask & 1) {
                register_file[MODE_USER.OFFSET + i] = regs[i];
            } else {
                register_file[current_mode.OFFSET + i] = regs[i];
            }

            mask >>= 1;
        }

        mask = new_mode.REGISTER_UNIQUENESS;
        for (int i = 0; i < 18; i++) {
            if (mask & 1) {
                regs[i] = register_file[MODE_USER.OFFSET + i];
            } else {
                regs[i] = register_file[new_mode.OFFSET + i];
            }

            mask >>= 1;
        }

        bool had_interrupts_disabled = (get_cpsr() >> 7) & 1;

        set_cpsr((get_cpsr() & 0xFFFFFFE0) | new_mode.CPSR_ENCODING);
        // writefln("setting the sussy cpsr to %x", get_cpsr());
        instruction_set = get_flag(Flag.T) ? InstructionSet.THUMB : InstructionSet.ARM;
        current_mode = new_mode;

        if (had_interrupts_disabled && (get_cpsr() >> 7) && memory.mmio.read(0x4000202)) {
            raise_exception!(CpuException.IRQ);
        }
    }

    Word get_cpsr() {
        return regs[16];
    }

    // user and system modes dont have spsr. spsr reads return cpsr.
    Word get_spsr() {
        if (current_mode == MODE_USER || current_mode == MODE_SYSTEM) {
            return get_cpsr();
        }

        return regs[17];
    }

    void set_cpsr(Word cpsr) {
        regs[16] = cpsr;
        instruction_set = get_flag(Flag.T) ? instruction_set.THUMB : instruction_set.ARM;
    }

    void set_spsr(Word spsr) {
        regs[17] = spsr;
    }

    InterruptManager interrupt_manager;
    void set_interrupt_manager(InterruptManager interrupt_manager) {
        this.interrupt_manager = interrupt_manager;
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

    bool check_cond(uint cond) {
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

    void raise_exception(CpuException exception)() {
        // interrupts not allowed if the cpu itself has interrupts disabled.
        Word cpsr = regs[16];

        if ((exception == CpuException.IRQ && get_nth_bit(cpsr, 7)) ||
            (exception == CpuException.FIQ && get_nth_bit(cpsr, 6))) {
            return;
        }

        enum mode = get_mode_from_exception!(exception);

        register_file[mode.OFFSET + 14] = regs[pc] - 2 * (get_flag(Flag.T) ? 2 : 4);
        if (exception == CpuException.IRQ) {
            register_file[mode.OFFSET + 14] += 4; // in an IRQ, the linkage register must point to the next instruction + 4
        }

        // register_file[mode.OFFSET + 17] = cpsr;
        register_file[mode.OFFSET + 17] = cpsr;
        // writefln("setting SPSR to %x", register_file[mode.OFFSET + 17]);
        set_mode!(mode);
        cpsr = get_cpsr();

        cpsr |= (1 << 7); // disable normal interrupts

        static if (exception == CpuException.Reset || exception == CpuException.FIQ) {
            cpsr |= (1 << 6); // disable fast interrupts
        }
        regs[16] = cpsr;

        regs[pc] = get_address_from_exception!(exception);

        set_flag(Flag.T, false);
        memory.can_read_from_bios = true;
        
        refill_pipeline();
        halted = false;
    }

    static uint get_address_from_exception(CpuException exception)() {
        final switch (exception) {
            case CpuException.Reset:             return 0x0000_0000;
            case CpuException.Undefined:         return 0x0000_0004;
            case CpuException.SoftwareInterrupt: return 0x0000_0008;
            case CpuException.PrefetchAbort:     return 0x0000_000C;
            case CpuException.DataAbort:         return 0x0000_0010;
            case CpuException.IRQ:               return 0x0000_0018;
            case CpuException.FIQ:               return 0x0000_001C;
        }
    }

    static CpuMode get_mode_from_exception(CpuException exception)() {
        final switch (exception) {
            case CpuException.Reset:             return MODE_SUPERVISOR;
            case CpuException.Undefined:         return MODE_UNDEFINED;
            case CpuException.SoftwareInterrupt: return MODE_SUPERVISOR;
            case CpuException.PrefetchAbort:     return MODE_ABORT;
            case CpuException.DataAbort:         return MODE_ABORT;
            case CpuException.IRQ:               return MODE_IRQ;
            case CpuException.FIQ:               return MODE_FIQ;
        }
    }

    static string get_exception_name(CpuException exception)() {
        final switch (exception) {
            case CpuException.Reset:             return "RESET";
            case CpuException.Undefined:         return "UNDEFINED";
            case CpuException.SoftwareInterrupt: return "SWI";
            case CpuException.PrefetchAbort:     return "PREFETCH ABORT";
            case CpuException.DataAbort:         return "DATA ABORT";
            case CpuException.IRQ:               return "IRQ";
            case CpuException.FIQ:               return "FIQ";
        }
    }

    void set_flag(Flag flag, bool value) {
        uint cpsr = get_cpsr();
        cpsr &= ~(1     << flag);
        cpsr |=  (value << flag);
        set_cpsr(cpsr);

        if (flag == Flag.T) {
            instruction_set = value ? InstructionSet.THUMB : InstructionSet.ARM;
        }
    }

    bool get_flag(Flag flag) {
        return get_nth_bit(get_cpsr(), flag);
    }

    void set_pipeline_access_type(AccessType access_type) {
        this.pipeline_access_type = access_type;
    }

    void run_idle_cycle() {
        pipeline_access_type = AccessType.NONSEQUENTIAL;
        memory.idle();
    }

    bool in_a_privileged_mode() {
        return current_mode != MODE_USER;
    }

    void update_mode() {
        int mode_bits = get_nth_bits(get_cpsr(), 0, 5);
        static foreach (i; 0 .. 7) {
            if (MODES[i].CPSR_ENCODING == mode_bits) {
                set_mode!(MODES[i]);
            }
        }
    }

    bool has_spsr() {
        return !(current_mode == MODE_USER || current_mode == MODE_SYSTEM);
    }

    Word read_word(Word address, AccessType access_type) { pipeline_access_type = AccessType.NONSEQUENTIAL; return memory.read_word(address, access_type, false); }
    Half read_half(Word address, AccessType access_type) { pipeline_access_type = AccessType.NONSEQUENTIAL; return memory.read_half(address, access_type, false); }
    Byte read_byte(Word address, AccessType access_type) { pipeline_access_type = AccessType.NONSEQUENTIAL; return memory.read_byte(address, access_type, false); }

    void write_word(Word address, Word value, AccessType access_type) { pipeline_access_type = AccessType.NONSEQUENTIAL; memory.write_word(address, value, access_type, false); }
    void write_half(Word address, Half value, AccessType access_type) { pipeline_access_type = AccessType.NONSEQUENTIAL; memory.write_half(address, value, access_type, false); }
    void write_byte(Word address, Byte value, AccessType access_type) { pipeline_access_type = AccessType.NONSEQUENTIAL; memory.write_byte(address, value, access_type, false); }
}