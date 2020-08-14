#ifndef GBA_H
#define GBA_H

#include "memory.h"

#define CART_SIZE         0x1000000

#define ROM_ENTRY_POINT   0x000
#define GAME_TITLE_OFFSET 0x0A0
#define GAME_TITLE_SIZE   12

void get_rom_as_bytes(char* rom_name, uint8_t* out, int out_length);
void test_thumb();

#endif