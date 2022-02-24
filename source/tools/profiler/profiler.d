module tools.profiler.profiler;

import util;

final class Profiler {
    FunctionTree tree;

    this() {
        tree = new FunctionTree();
    }

    void enter_function(Word address) {
        tree.enter_function(get_id_from_address(address));
    }

    void exit_function(Word address) {
        tree.exit_function(get_id_from_address(address));
    }
    
    // this function will do more interesting things later...
    // specifically, two functions could have the same addresses
    // in very bizarre cases. we shouldn't assign them the same
    // id if that is the case.
    FunctionID get_id_from_address(Word address) {
        return address;
    }
}