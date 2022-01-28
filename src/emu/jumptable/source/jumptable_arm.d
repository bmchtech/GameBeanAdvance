module jumptable_arm;

import abstracthw.cpu;
import abstracthw.memory;
import instruction;
import ops;
import util;
import addressing_mode;

import core.bitop;

alias JumptableEntry = void function(IARM7TDMI cpu, Word opcode);

static void create_nop(IARM7TDMI cpu, Word opcode) {}

static JumptableEntry[4096] create_jumptable()() {
    JumptableEntry[4096] jumptable;

    static foreach (entry; 0 .. 4096) {
        if ((entry & 0b1100_0000_0000) == 0b0100_0000_0000) {
            enum register    = get_nth_bit(entry, 9);
            enum pre         = get_nth_bit(entry, 8);
            enum up          = get_nth_bit(entry, 7);
            enum byte_access = get_nth_bit(entry, 6);
            enum writeback   = get_nth_bit(entry, 5) || !pre; // post-indexing implies writeback
            enum load        = get_nth_bit(entry, 4);
            jumptable[entry] = &create_addressing_mode_2!(register, pre, up, byte_access, writeback, load);
        }
    }

    return jumptable;
}

static JumptableEntry[4096] jumptable = create_jumptable!();