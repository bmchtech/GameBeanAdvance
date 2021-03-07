
/* 
    so, the general idea behind the GBA is this:
    at least now, while im testing the THUMB. we're gonna skip all the ARM instructions
    and just set the PC straight to the beginnings of THUMB. then, we're gonna see what
    we can do from there by editing test-jumptable.cpp
*/

#include <fstream>
#include <iterator>
#include <vector>
#include <iostream>
#include <cstring>
#include <chrono>
#include <thread>
#include <functional>

#include "gba.h"
#include "memory.h"
#include "util.h"
#include "arm7tdmi.h"

extern Memory memory;

GBA::GBA(Memory* memory) {
    this->memory = memory;
    cpu          = new ARM7TDMI(memory);
    ppu          = new PPU(memory);
    enabled      = false;

    cpu->set_mode(ARM7TDMI::MODE_SYSTEM);

    dma_channels[0] = {memory->DMA0DAD, memory->DMA0SAD, memory->DMA0CNT_L, memory->DMA0CNT_H,
                       0,               0,               0,                 
                       false};
    dma_channels[1] = {memory->DMA1DAD, memory->DMA1SAD, memory->DMA1CNT_L, memory->DMA1CNT_H,
                       0,               0,               0,                 
                       false};
    dma_channels[2] = {memory->DMA2DAD, memory->DMA2SAD, memory->DMA2CNT_L, memory->DMA2CNT_H,
                       0,               0,               0,                 
                       false};
    dma_channels[3] = {memory->DMA3DAD, memory->DMA3SAD, memory->DMA3CNT_L, memory->DMA3CNT_H,
                       0,               0,               0,                 
                       false};

#ifndef RELEASE
    logger_gba = this;
#endif
}

GBA::~GBA() {
    delete memory;
    delete cpu;
}

void gba_thread(GBA* gba) {
    uint64_t instruction_count = 0;

    while (gba->enabled) {
        auto s = std::chrono::steady_clock::now() + std::chrono::milliseconds(1000);
        uint16_t count = 0;

        while (count < 1000) {
            auto x = std::chrono::steady_clock::now() + std::chrono::milliseconds(1);
            
            for (int i = 0; i < 16780 / 4; i++) {
                count++;
                gba->cycle();

                instruction_count++;
            }

            std::this_thread::sleep_until(x);
        }

        if (std::chrono::steady_clock::now() > s) {
            warning("Emulator running too slow!");
        } 
    }
}

void GBA::run(std::string rom_name) {
    get_rom_as_bytes(rom_name, memory->rom_1, SIZE_ROM_1);

    // extract the game name
    // char game_name[GAME_TITLE_SIZE];
    // for (int i = 0; i < GAME_TITLE_SIZE; i++) {
    //     game_name[i] = memory->rom_1[GAME_TITLE_OFFSET + i];
    // }
    // std::cout << game_name << std::endl;
    *cpu->pc = OFFSET_ROM_1;

    enabled = true;
    std::thread t(gba_thread, this);
    t.detach();
}

void GBA::cycle() {
    if (!handle_dma())
        cpu->cycle();

    ppu->cycle();
    ppu->cycle();
    ppu->cycle();
    ppu->cycle();
}

bool GBA::handle_dma() {
    // if any of the channels wants to start dma, then copy its data over to the buffers.
    for (int i = 0; i < 4; i++) {
        if (!dma_channels[i].enabled && get_nth_bit(*dma_channels[i].cnt_h, 15)) {
            dma_channels[i].dest_buf   = *dma_channels[i].dest;
            dma_channels[i].source_buf = *dma_channels[i].source;
            dma_channels[i].size_buf   = *dma_channels[i].cnt_l & 0x0FFFFFFF;

            if (i == 3) dma_channels[i].size_buf &= 0x07FFFFFF;
            dma_channels[i].enabled = true;
            return true;
        }
    }

    // get the channel with highest priority that wants to start dma
    int current_channel = -1;
    for (int i = 0; i < 4; i++) {
        if (dma_channels[i].enabled) {
            current_channel = i;
            break;
        }
    }

    // if we found no channels, leave.
    if (current_channel == -1) return false;

    // dma happens every other cycle
    dma_cycle ^= 1;
    if (!dma_cycle) return false;

    if (get_nth_bit(*dma_channels[current_channel].cnt_h, 14)) {
        std::cout << "EXPECTED INTERRUPT" << std::endl;
    }

    // copy one piece of data over.
    int increment = 0;
        // std::cout << "A " << to_hex_string(dma_channels[current_channel].source_buf) << std::endl;
        // std::cout << "B " << to_hex_string(dma_channels[current_channel].dest_buf) << std::endl;
        // std::cout << "B " << to_hex_string(dma_channels[current_channel].size_buf) << std::endl;
    if (get_nth_bit(*dma_channels[current_channel].cnt_h, 10)) {
        memory->write_word    (dma_channels[current_channel].dest_buf, memory->read_word    (dma_channels[current_channel].source_buf));
        increment = 4;
    } else {
        memory->write_halfword(dma_channels[current_channel].dest_buf, memory->read_halfword(dma_channels[current_channel].source_buf));
        increment = 2;
    }

    // edit dest_buf and source_buf as needed to set up for the next dma
    switch (get_nth_bits(*dma_channels[current_channel].cnt_h, 5, 6)) {
        case 0b00:
        case 0b11:
            dma_channels[current_channel].dest_buf   += increment; break;
        case 0b01:
            dma_channels[current_channel].dest_buf   -= increment; break;
    }
    switch (get_nth_bits(*dma_channels[current_channel].cnt_h, 7, 8)) {
        case 0b00:
            dma_channels[current_channel].source_buf += increment; break;
        case 0b01:
            dma_channels[current_channel].source_buf -= increment; break;
    }
    if (dma_channels[current_channel].size_buf < increment) dma_channels[current_channel].size_buf = 0;
    else                                                    dma_channels[current_channel].size_buf -= increment;

    // did we finish dma?
    if (dma_channels[current_channel].size_buf == 0) {
        // do we repeat dma?
        if (get_nth_bit(*dma_channels[current_channel].cnt_h, 9)) {
            if (get_nth_bits(*dma_channels[current_channel].cnt_h, 5, 6) == 0b11) {
                dma_channels[current_channel].dest_buf = *dma_channels[current_channel].dest;
            }

            dma_channels[current_channel].size_buf = *dma_channels[current_channel].cnt_l & 0x0FFFFFFF;
            if (current_channel == 3) dma_channels[current_channel].size_buf &= 0x07FFFFFF;
        } else {
            dma_channels[current_channel].enabled = false;
            *dma_channels[current_channel].cnt_h &= ~(1UL << 15);
        }
    }
}