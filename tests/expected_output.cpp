#include "cpu_state.h"
#include "../src/util.h"
#include "expected_output.h"

#include <sstream>
#include <string>
#include <stdint.h>
#include <fstream>

// reads a log file and outputs a list of cpu_state
CpuState* produce_expected_cpu_states(CpuState* cpu_states, std::string file_name, uint32_t num_lines) {
    std::ifstream infile(file_name);
    std::string line;
        
    // used to convert from hex string to int
    std::stringstream ss;
    std::string temp;
    uint32_t a;

    // check if file exists
    if (!infile.good()) {
        error("Expected log file not found, are you sure you gave the right file name?");
    }
    
    // regular for loop that also terminates if there's no more lines left to read
    for (int i = 0; std::getline(infile, line) && i < num_lines; i++) {
        std::istringstream iss(line);

        // first determine type
        std::string instruction_type;
        if (!(iss >> instruction_type)) {
            error("Couldn't parse expected log file: no instruction type found.");
        }

        if (instruction_type == "ARM") {
            cpu_states[i].type = ARM;
        } else {
            cpu_states[i].type = THUMB;
        }

        // fill the rest of the struct in
        if (!(iss >> temp)) {
            error("Couldn't parse expected log file: no opcode found.");
        } else {
            ss.str(std::string());
            ss.clear();
            ss << std::hex << temp;
            ss >> a;
            cpu_states[i].opcode = a;
        }

        for (int j = 0; j < 16; j++) {
            if (!(iss >> temp)) {
                error("Couldn't parse expected log file: no register " + std::to_string(i) + " found.");
            } else {
                ss.str(std::string());
                ss.clear();
                ss << std::hex << temp;
                ss >> a;
                cpu_states[i].regs[j] = a;
                if (j == 15) {
                    cpu_states[i].regs[j] -= cpu_states[i].type == ARM ? 4 : 2;
                }
            }
        }
    }

    return cpu_states;
}