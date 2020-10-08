#ifndef GBA_H
#define GBA_H

#include "memory.h"
#include <string>

#define CART_SIZE         0x1000000

#define ROM_ENTRY_POINT   0x000
#define GAME_TITLE_OFFSET 0x0A0
#define GAME_TITLE_SIZE   12

void gba_init();
void gba_run(std::string rom_name);
void get_rom_as_bytes(std::string rom_name, uint8_t* out, int out_length);
uint32_t fetch();
void execute(uint32_t opcode);

#define MODE_USER       0b10000
#define MODE_FIQ        0b10001
#define MODE_IRQ        0b10010
#define MODE_SUPERVISOR 0b10011
#define MODE_ABORT      0b10111
#define MODE_UNDEFINED  0b11011
#define MODE_SYSTEM     0b11111

inline void set_mode(int mode) {
    memory.cpsr = (memory.cpsr & 0xFFFFFFE0) | mode;
}

// determines whether or not this function should execute based on COND (the high 4 bits of the opcode)
// note that this only applies to ARM instructions.
bool should_execute(int opcode);

#endif