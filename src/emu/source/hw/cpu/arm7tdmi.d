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

class ARM7TDMI : IARM7TDMI {
    Word[16] regs;
    
    Word cpsr;
    Word spsr;

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

    void set_flag(Flag flag, bool value) {
        auto set   = (uint offset) => cpsr |=  (1 << offset);
        auto clear = (uint offset) => cpsr &= ~(1 << offset);
        auto modify = (uint offset, bool value) => value ? set(offset) : clear(offset);

        modify(flag, value);

        if (flag == Flag.T) {
            instruction_set = value ? instruction_set.THUMB : instruction_set.ARM;
        }
    }

    bool get_flag(Flag flag) {
        return get_nth_bit(cpsr, flag);
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
