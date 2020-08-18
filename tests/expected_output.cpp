#include "cpu_state.h"
#include "../src/util.h"
#include "expected_output.h"

#include <iostream>
#include <sstream>
#include <string>
#include <stdint.h>
#include <fstream>

// reads a log file and outputs a list of cpu_state
CpuState* produce_expected_cpu_states(std::string file_name, uint32_t num_lines) {
    std::ifstream infile(file_name);
    std::string line;
        
    // used to convert from hex string to int
    std::stringstream ss;
    std::string temp;

    // check if file exists
    if (!infile.good()) {
        error("Expected log file not found, are you sure you gave the right file name?");
    }

    CpuState* cpu_states = new CpuState[num_lines];
    // regular for loop that also terminates if there's no more lines left to read
    for (int i = 0; std::getline(infile, line) && i < num_lines; i++) {
        std::istringstream iss(line);

        // create struct
        CpuState cpu_state;

        // first determine type
        std::string instruction_type;
        if (!(iss >> instruction_type)) {
            error("Couldn't parse expected log file: no instruction type found.");
        }

        if (instruction_type == "ARM") {
            cpu_state.type = ARM;
        } else {
            cpu_state.type = THUMB;
        }

        // fill the rest of the struct in
        if (!(iss >> temp)) {
            error("Couldn't parse expected log file: no opcode found.");
        } else {
            ss << std::hex << temp;
            ss >> cpu_state.opcode;
        }

        for (int i = 0; i < 16; i++) {
            if (!(iss >> temp)) {
                error("Couldn't parse expected log file: no register " + std::to_string(i) + " found.");
            } else {
                ss << std::hex << temp;
                ss >> cpu_state.regs[i];
            }
        }

        cpu_states[i] = cpu_state;
    }

    return cpu_states;
}