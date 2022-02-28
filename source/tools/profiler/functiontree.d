module tools.profiler.functiontree;

import util;
import util.pointerpool;

alias FunctionID = u32;

final class FunctionTree {
    enum MAX_FUNCTION_CALLS = 200;
    enum MAX_FUNCTION_DEPTH = 30;

    alias FunctionList = FunctionCall*[MAX_FUNCTION_CALLS];
    alias FunctionPool = PointerPool!(FunctionCall, 1 << 20);

    struct FunctionCall {
        u64          cycles;
        FunctionID   function_id;
        FunctionList function_call_list;
        int          function_call_list_length;
        bool         entered_before;
    }

    FunctionPool pointer_pool;

    FunctionCall*[MAX_FUNCTION_DEPTH] call_stack;
    int call_stack_size = 0;

    FunctionCall* current_function_call;
    
    u64 cycles = 0;

    this() {
        pointer_pool = new FunctionPool();

        call_stack[0] = pointer_pool.get_pointer();
        call_stack[0].cycles = 0;
        call_stack[0].function_id = -1;
        call_stack[0].function_call_list = pointer_pool.get_pointer();
        call_stack[0].function_call_list_length = 0;
        call_stack[0].entered_before = false;
        current_function_call = call_stack[0];

        call_stack_size = 1;
    }    

    void enter_function(FunctionID function_id) {
        increment_current_function_call(cycles);

        auto search_return = search_for_function_id(function_id);
        if (search_return.found) {
            add_new_function_call(function_id, search_return.index);
        }
    
        current_function_call = &current_function_call[search_return.index];
        current_function_call.entered_before = true;

        call_stack[call_stack_size++] = current_function_call;
    }

    void exit_function() {
        if (call_stack_size <= 1) return;
        current_function_call = call_stack[--call_stack_size];
    }

    void add_new_function_call(FunctionID function_id, int index) {
        auto function_call_list = current_function_call.function_call_list;

        function_call_list[index] = pointer_pool.get_pointer();
        
        function_call_list[index].cycles                    = 0;
        function_call_list[index].function_id               = function_id;
        function_call_list[index].function_call_list_length = 0;

        current_function_call.function_call_list_length++;
    }

    void increment_current_function_call(u64 cycles) {
        current_function_call.cycles += cycles;
        cycles = 0;
    }

    void tick(u64 cycles) {
        this.cycles += cycles;
    }

    struct SearchReturn {
        u32 index;
        bool found;
    }

    SearchReturn search_for_function_id(FunctionID function_id) {
        for (int i = 0; i < MAX_FUNCTION_CALLS; i++) {
            auto f = current_function_call.function_call_list[i];

            if (f.function_id == function_id) return SearchReturn(i, true);
            if (!f.entered_before)            return SearchReturn(i, false);
        }

        // TODO: maybe something more descriptive??
        error("Exceeded maximum call list.");

        return SearchReturn(0, false); // this wont trigger but it shuts up the compiler
    }
}