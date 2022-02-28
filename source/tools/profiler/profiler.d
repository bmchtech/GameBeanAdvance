module tools.profiler.profiler;

import tools.profiler.functiontree;

import elf;
import util;

import std.algorithm;
import std.array;
import std.stdio;

import hw.gba;
import hw.cpu;
import hw.memory;

struct Function {
    Word start_address;
    Word end_address;
    string name;
    bool is_thumb;
}

final class Profiler {
    GBA gba;

    FunctionTree tree;
    Function[] functions;

    ELF elf;

    // please don't execute code anywhere that's not rom or ram pls ty
    alias FunctionIndex = int;
    alias FunctionMap   = FunctionIndex[];
    FunctionMap function_map__iwram;
    FunctionMap function_map__ewram;
    FunctionMap function_map__rom;
    FunctionMap*[] function_maps;
    Word[] function_map_masks;

    Word[] callstack_indices;
    int callstack_size = 0;

    bool in_function_prologue;
    bool in_function_epilogue;

    this(GBA gba, string elf_file) {
        this.gba = gba;

	    elf = ELF.fromFile(elf_file);

        function_map__iwram = new FunctionIndex[SIZE_WRAM_CHIP  / 2];
        function_map__ewram = new FunctionIndex[SIZE_WRAM_BOARD / 2];
        function_map__rom   = new FunctionIndex[SIZE_ROM        / 2];
        
        foreach (symbol; SymbolTable(elf.getSection(".symtab").get).symbols()) {
            if (symbol.type == SymbolType.func && symbol.size != 0) {
                functions ~= Function(
                    cast(Word)  (symbol.value & ~1),
                    cast(Word) ((symbol.value & ~1) + symbol.size) - (symbol.value & 1 ? 2 : 4),
                    symbol.name,
                    symbol.value & 1
                );

                // writefln("%08x ~ %08x : %s", symbol.value, symbol.value + symbol.size, symbol.name);
            }
        }

        function_map_masks = [
            0,
            0,
            SIZE_WRAM_BOARD - 1,
            SIZE_WRAM_CHIP  - 1,
            0,
            0,
            0,
            0,
            SIZE_ROM - 1,
            SIZE_ROM - 1,
            SIZE_ROM - 1,
            SIZE_ROM - 1,
            SIZE_ROM - 1,
            SIZE_ROM - 1,
            0,
            0
        ];

        generate_function_map(&function_map__iwram, OFFSET_WRAM_CHIP);
        generate_function_map(&function_map__ewram, OFFSET_WRAM_BOARD);
        generate_function_map(&function_map__rom,   OFFSET_ROM_1);

        function_maps = [
            null, 
            null,
            &function_map__ewram, 
            &function_map__iwram, 
            null, 
            null, 
            null, 
            null,
            &function_map__rom, 
            &function_map__rom, 
            &function_map__rom, 
            &function_map__rom, 
            &function_map__rom, 
            &function_map__rom, 
            null,
            null
        ];

        callstack_indices = new Word[200];

        tree = new FunctionTree();


	writeln();
	writeln("'.debug_abbrev' section contents:");

	// ELF .debug_abbrev information

	writeln();
	writeln("'.debug_line' section contents:");

	// ELF .debug_line information
	ELFSection dlSection = elf.getSection(".debug_line").get;

	auto dl = DebugLine(dlSection);
	foreach (program; dl.programs) {
		writefln("  Files:\n%-(    %s\n%)\n", program.allFiles());
		writefln("%-(  %s\n%)", program.addressInfo.map!(a => "0x%x => %s@%s".format(a.address, program.fileFromIndex(a.fileIndex), a.line)));
	}
        error("sussy");
	}

    void generate_function_map(FunctionMap* function_map, Word offset) {
        auto region = get_nth_bits(offset, 24, 28);
        
        struct FunctionIndexPair {
            Function f;
            FunctionIndex i;
        }

        // we only want the functions that reside in the current function map region.
        // we also want to loop through the functions from largest to smallest, as that *greatly* simplifies the algorithm.
        FunctionIndexPair[] temp = [];
        for (int i = 0; i < functions.length; i++) {
            temp ~= FunctionIndexPair(functions[i], i);
        }

        auto sorted_funcs = temp.filter!((fip) => get_nth_bits(fip.f.start_address, 24, 28) == region)
                                .array
                                .sort!((fip1, fip2) => (fip1.f.end_address - fip1.f.start_address) > (fip2.f.end_address - fip2.f.start_address));
        
        foreach (fip; sorted_funcs) {
            for (Word address = fip.f.start_address; address < fip.f.end_address; address += 2) {
                (*function_map)[(address / 2) & function_map_masks[region]] = fip.i;
            }
        }
    }

    FunctionIndex get_function_index(Word address) {
        auto region = get_nth_bits(address, 24, 28);
        auto map    = function_maps[region];
        
        if (map != null) {
            return (*map)[(address / 2) & function_map_masks[region]];
        } else {
            return -1;
        }
    }

    void push_to_callstack(Word sp) {
        callstack_indices[callstack_size++] = sp;
    }

    Word pop_from_callstack() {
        return callstack_indices[--callstack_size];
    }

    Word peek_callstack() {
        return callstack_indices[callstack_size - 1];
    }

    void notify__cpu_at_address(Word address) {
        // assume entry points to functions are at the beginning of said functions
        if (get_function_index(address) != get_function_index(address - 2)) {
            enter_function(gba.cpu.regs[pc]);
        }
    }

    // yes theres a lot of extraneous arguments in these notify functions
    // but i leave them there in case i need them in the future.
    void notify__cpu_decremented_sp(Word amount) {
        
    }

    void notify__cpu_incremented_sp(Word amount) {

    }

    void notify__cpu_bx(Reg reg) {
        if (reg == lr) exit_function();
    }


    void notify__cpu_pushed_stack(Reg reg, Word address) {
        // if (in_function_prologue && reg == lr) {
        //     push_to_callstack(address);
        //     enter_function(gba.cpu.regs[pc]);

        //     in_function_prologue = false;
        // }
    }

    void notify__cpu_popped_stack(Reg reg, Word address) {
        // if (callstack_size > 0 && peek_callstack() == address) {
        //     pop_from_callstack();
        //     exit_function();

        //     in_function_epilogue = false;
        // }
    }

    void enter_function(Word address) {
        auto index = get_function_index(address);
        writefln("entering %s", functions[index].name);

        if (index != -1) tree.enter_function(index);
    }

    void exit_function() {
        writefln("exitting.");
        tree.exit_function();
    }
}