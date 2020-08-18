#ifndef GBA_H
#define GBA_H

#include "memory.h"

#define CART_SIZE         0x1000000

#define ROM_ENTRY_POINT   0x000
#define GAME_TITLE_OFFSET 0x0A0
#define GAME_TITLE_SIZE   12

void run();
void get_rom_as_bytes(std::string rom_name, uint8_t* out, int out_length);
void test_thumb();
int  fetch();
void execute(int opcode);

#ifdef TEST
    #include "../tests/cpu_state.h"
    
    CpuState get_state();
    void set_State(CpuState cpu_state);
#endif

#endif