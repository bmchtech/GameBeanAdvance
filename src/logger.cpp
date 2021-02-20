#include "logger.h"
#include "util.h"

Logger::Logger(GBA* gba) {
    this->gba = gba;
}

void Logger::error(std::string message) {
    if (gba != NULL) {
        for (int i = 0; i < CPU_STATE_LOG_LENGTH; i++) {
            CpuState cpu_state = gba->cpu->cpu_states[i];
            std::cout << ((cpu_state.type == ARM) ? "ARM " : "THUMB ");
            std::cout << to_hex_string(cpu_state.opcode);

            for (int i = 0; i < 16; i++) {
                std::string register_value = to_hex_string(cpu_state.regs[i]);
                std::cout << " " << std::string(8 - register_value.length(), '0').append(register_value);
            }

            std::cout << " " << to_hex_string(cpu_state.mode);
            std::cout << std::endl;
        }

        error(message);
    }
}

void Logger::warning(std::string message) {
    warning(message);
}