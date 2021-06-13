module mmio;

import ppu;
import apu;
import dma;
import timers;
import interrupts;
import keyinput;

import std.stdio;

class MMIO {

    // IO Registers
    //          NAME            ADDRESS       SIZE  R/W   DESCRIPTION

    enum DISPCNT       = 0x4000000; //  2    R/W   LCD Control
    enum DISPSTAT      = 0x4000004; //  2    R/W   General LCD Status (STAT,LYC)
    enum VCOUNT        = 0x4000006; //  2    R     Vertical Counter (LY)
    enum BG0CNT        = 0x4000008; //  2    R/W   BG0 Control
    enum BG1CNT        = 0x400000A; //  2    R/W   BG1 Control
    enum BG2CNT        = 0x400000C; //  2    R/W   BG2 Control
    enum BG3CNT        = 0x400000E; //  2    R/W   BG3 Control
    enum BG0HOFS       = 0x4000010; //  2      W   BG0 X-Offset
    enum BG0VOFS       = 0x4000012; //  2      W   BG0 Y-Offset
    enum BG1HOFS       = 0x4000014; //  2      W   BG1 X-Offset
    enum BG1VOFS       = 0x4000016; //  2      W   BG1 Y-Offset
    enum BG2HOFS       = 0x4000018; //  2      W   BG2 X-Offset
    enum BG2VOFS       = 0x400001A; //  2      W   BG2 Y-Offset
    enum BG3HOFS       = 0x400001C; //  2      W   BG3 X-Offset
    enum BG3VOFS       = 0x400001E; //  2      W   BG3 Y-Offset
    enum BG2PA         = 0x4000020; //  2      W   BG2 Rotation/Scaling Parameter A (dx)
    enum BG2PB         = 0x4000022; //  2      W   BG2 Rotation/Scaling Parameter B (dmx)
    enum BG2PC         = 0x4000024; //  2      W   BG2 Rotation/Scaling Parameter C (dy)
    enum BG2PD         = 0x4000026; //  2      W   BG2 Rotation/Scaling Parameter D (dmy)
    enum BG2X          = 0x4000028; //  4      W   BG2 Reference Point X-Coordinate
    enum BG2Y          = 0x400002C; //  4      W   BG2 Reference Point Y-Coordinate
    enum BG3PA         = 0x4000030; //  2      W   BG3 Rotation/Scaling Parameter A (dx)
    enum BG3PB         = 0x4000032; //  2      W   BG3 Rotation/Scaling Parameter B (dmx)
    enum BG3PC         = 0x4000034; //  2      W   BG3 Rotation/Scaling Parameter C (dy)
    enum BG3PD         = 0x4000036; //  2      W   BG3 Rotation/Scaling Parameter D (dmy)
    enum BG3X          = 0x4000038; //  4      W   BG3 Reference Point X-Coordinate
    enum BG3Y          = 0x400003C; //  4      W   BG3 Reference Point Y-Coordinate
    enum WIN0H         = 0x4000040; //  2      W   Window 0 Horizontal Dimensions
    enum WIN1H         = 0x4000042; //  2      W   Window 1 Horizontal Dimensions
    enum WIN0V         = 0x4000044; //  2      W   Window 0 Vertical Dimensions
    enum WIN1V         = 0x4000046; //  2      W   Window 1 Vertical Dimensions
    enum WININ         = 0x4000048; //  2    R/W   Inside of Window 0 and 1
    enum WINOUT        = 0x400004A; //  2    R/W   Inside of OBJ Window & Outside of Windows
    enum MOSAIC        = 0x400004C; //  2      W   Mosaic Size
    enum BLDCNT        = 0x4000050; //  2    R/W   Color Special Effects Selection
    enum BLDALPHA      = 0x4000052; //  2    R/W   Alpha Blending Coefficients
    enum BLDY          = 0x4000054; //  2      W   Brightness (Fade-In/Out) Coefficient

    enum SOUND1CNT_L   = 0x4000060; //  2    R/W   Channel 1 Sweep Register       (NR10)
    enum SOUND1CNT_H   = 0x4000062; //  2    R/W   Channel 1 Duty/Length/Envelope (NR11, NR12)
    enum SOUND1CNT_X   = 0x4000064; //  2    R/W   Channel 1 Frequency/Control    (NR13, NR14)
    enum SOUND2CNT_L   = 0x4000068; //  2    R/W   Channel 2 Duty/Length/Envelope (NR21, NR22)
    enum SOUND2CNT_H   = 0x400006C; //  2    R/W   Channel 2 Frequency/Control    (NR23, NR24)
    enum SOUND3CNT_L   = 0x4000070; //  2    R/W   Channel 3 Stop/Wave RAM select (NR30)
    enum SOUND3CNT_H   = 0x4000072; //  2    R/W   Channel 3 Length/Volume        (NR31, NR32)
    enum SOUND3CNT_X   = 0x4000074; //  2    R/W   Channel 3 Frequency/Control    (NR33, NR34)
    enum SOUND4CNT_L   = 0x4000078; //  2    R/W   Channel 4 Length/Envelope      (NR41, NR42)
    enum SOUND4CNT_H   = 0x400007C; //  2    R/W   Channel 4 Frequency/Control    (NR43, NR44)
    enum SOUNDCNT_L    = 0x4000080; //  2    R/W   Control Stereo/Volume/Enable   (NR50, NR51)
    enum SOUNDCNT_H    = 0x4000082; //  2    R/W   Control Mixing/DMA Control
    enum SOUNDCNT_X    = 0x4000084; //  2    R/W   Control Sound on/off           (NR52)
    enum SOUNDBIAS     = 0x4000088; //  2    BIOS  Sound PWM Control
    enum FIFO_A        = 0x40000A0; //  4      W   Channel A FIFO, Data 0-3
    enum FIFO_B        = 0x40000A4; //  4      W   Channel B FIFO, Data 0-3

    enum DMA0SAD       = 0x40000B0; //  4      W   DMA 0 Source Address
    enum DMA0DAD       = 0x40000B4; //  4      W   DMA 0 Destination Address
    enum DMA0CNT_L     = 0x40000B8; //  2      W   DMA 0 Word Count
    enum DMA0CNT_H     = 0x40000BA; //  2    R/W   DMA 0 Control
    enum DMA1SAD       = 0x40000BC; //  4      W   DMA 1 Source Address
    enum DMA1DAD       = 0x40000C0; //  4      W   DMA 1 Destination Address
    enum DMA1CNT_L     = 0x40000C4; //  2      W   DMA 1 Word Count
    enum DMA1CNT_H     = 0x40000C6; //  2    R/W   DMA 1 Control
    enum DMA2SAD       = 0x40000C8; //  4      W   DMA 2 Source Address
    enum DMA2DAD       = 0x40000CC; //  4      W   DMA 2 Destination Address
    enum DMA2CNT_L     = 0x40000D0; //  2      W   DMA 2 Word Count
    enum DMA2CNT_H     = 0x40000D2; //  2    R/W   DMA 2 Control
    enum DMA3SAD       = 0x40000D4; //  4      W   DMA 3 Source Address
    enum DMA3DAD       = 0x40000D8; //  4      W   DMA 3 Destination Address
    enum DMA3CNT_L     = 0x40000DC; //  2      W   DMA 3 Word Count
    enum DMA3CNT_H     = 0x40000DE; //  2    R/W   DMA 3 Control

    enum TM0CNT_L      = 0x4000100; //  2    R/W   Timer 0 Counter/Reload
    enum TM0CNT_H      = 0x4000102; //  2    R/W   Timer 0 Control
    enum TM1CNT_L      = 0x4000104; //  2    R/W   Timer 1 Counter/Reload
    enum TM1CNT_H      = 0x4000106; //  2    R/W   Timer 1 Control
    enum TM2CNT_L      = 0x4000108; //  2    R/W   Timer 2 Counter/Reload
    enum TM2CNT_H      = 0x400010A; //  2    R/W   Timer 2 Control
    enum TM3CNT_L      = 0x400010C; //  2    R/W   Timer 3 Counter/Reload
    enum TM3CNT_H      = 0x400010E; //  2    R/W   Timer 3 Control

    enum KEYINPUT      = 0x4000130; //  2    R     Key Status
    enum KEYCNT        = 0x4000132; //  2    R/W   Key Interrupt Control
    
    enum IE            = 0x4000200; //  2    R/W   Interrupt Enable Register
    enum IF            = 0x4000202; //  2    R/W   Interrupt Request Flags / IRQ Acknowledge
    enum IME           = 0x4000208; //  2    R/W   Interrupt Master Enable Register

    this(PPU ppu, APU apu, DMAManager dma, TimerManager timers, InterruptManager interrupt, KeyInput keyinput) {
        this.ppu       = ppu;
        this.apu       = apu;
        this.dma       = dma;
        this.timers    = timers;
        this.interrupt = interrupt;
        this.keyinput  = keyinput;
    }

    ubyte read(uint address) {
        switch (address) {
            case DISPCNT     + 0: return ppu.read_DISPCNT    (0); 
            case DISPCNT     + 1: return ppu.read_DISPCNT    (1); 
            case DISPSTAT    + 0: return ppu.read_DISPSTAT   (0); 
            case DISPSTAT    + 1: return ppu.read_DISPSTAT   (1); 
            case VCOUNT      + 0: return ppu.read_VCOUNT     (0); 
            case VCOUNT      + 1: return ppu.read_VCOUNT     (1); 
            case BG0CNT      + 0: return ppu.read_BGXCNT     (0, 0); 
            case BG0CNT      + 1: return ppu.read_BGXCNT     (1, 0); 
            case BG1CNT      + 0: return ppu.read_BGXCNT     (0, 1); 
            case BG1CNT      + 1: return ppu.read_BGXCNT     (1, 1); 
            case BG2CNT      + 0: return ppu.read_BGXCNT     (0, 2); 
            case BG2CNT      + 1: return ppu.read_BGXCNT     (1, 2); 
            case BG3CNT      + 0: return ppu.read_BGXCNT     (0, 3); 
            case BG3CNT      + 1: return ppu.read_BGXCNT     (1, 3); 
            case WININ       + 0: return ppu.read_WININ      (0); 
            case WININ       + 1: return ppu.read_WININ      (1); 
            case WINOUT      + 0: return ppu.read_WINOUT     (0); 
            case WINOUT      + 1: return ppu.read_WINOUT     (1); 
            case BLDCNT      + 0: return ppu.read_BLDCNT     (0); 
            case BLDCNT      + 1: return ppu.read_BLDCNT     (1); 
            // case BLDALPHA    + 0: return ppu.read_BLDALPHA(); 
            // case BLDALPHA    + 1: return ppu.read_BLDALPHA(); 

            // case SOUND1CNT_L + 0: return apu.read_SOUND1CNT_L(); 
            // case SOUND1CNT_L + 1: return apu.read_SOUND1CNT_L(); 
            // case SOUND1CNT_H + 0: return apu.read_SOUND1CNT_H(); 
            // case SOUND1CNT_H + 1: return apu.read_SOUND1CNT_H(); 
            // case SOUND1CNT_X + 0: return apu.read_SOUND1CNT_X(); 
            // case SOUND1CNT_X + 1: return apu.read_SOUND1CNT_X(); 
            // case SOUND2CNT_L + 0: return apu.read_SOUND2CNT_L(); 
            // case SOUND2CNT_L + 1: return apu.read_SOUND2CNT_L(); 
            // case SOUND2CNT_H + 0: return apu.read_SOUND2CNT_H(); 
            // case SOUND2CNT_H + 1: return apu.read_SOUND2CNT_H(); 
            // case SOUND3CNT_L + 0: return apu.read_SOUND3CNT_L(); 
            // case SOUND3CNT_L + 1: return apu.read_SOUND3CNT_L(); 
            // case SOUND3CNT_H + 0: return apu.read_SOUND3CNT_H(); 
            // case SOUND3CNT_H + 1: return apu.read_SOUND3CNT_H(); 
            // case SOUND3CNT_X + 0: return apu.read_SOUND3CNT_X(); 
            // case SOUND3CNT_X + 1: return apu.read_SOUND3CNT_X(); 
            // case SOUND4CNT_L + 0: return apu.read_SOUND4CNT_L(); 
            // case SOUND4CNT_L + 1: return apu.read_SOUND4CNT_L(); 
            // case SOUND4CNT_H + 0: return apu.read_SOUND4CNT_H(); 
            // case SOUND4CNT_H + 1: return apu.read_SOUND4CNT_H(); 
            // case SOUNDCNT_L  + 0: return apu.read_SOUNDCNT_L(); 
            // case SOUNDCNT_L  + 1: return apu.read_SOUNDCNT_L(); 
            // case SOUNDCNT_H  + 0: return apu.read_SOUNDCNT_H(); 
            // case SOUNDCNT_H  + 1: return apu.read_SOUNDCNT_H(); 
            // case SOUNDCNT_X  + 0: return apu.read_SOUNDCNT_X(); 
            // case SOUNDCNT_X  + 1: return apu.read_SOUNDCNT_X();
            // case SOUNDBIAS   + 0: return apu.read_SOUNDBIAS(); 
            // case SOUNDBIAS   + 1: return apu.read_SOUNDBIAS(); 


            case DMA0CNT_H   + 0: return dma.read_DMAXCNT_H(0, 0); 
            case DMA0CNT_H   + 1: return dma.read_DMAXCNT_H(1, 0); 
            case DMA1CNT_H   + 0: return dma.read_DMAXCNT_H(0, 1); 
            case DMA1CNT_H   + 1: return dma.read_DMAXCNT_H(1, 1); 
            case DMA2CNT_H   + 0: return dma.read_DMAXCNT_H(0, 2); 
            case DMA2CNT_H   + 1: return dma.read_DMAXCNT_H(1, 2); 
            case DMA3CNT_H   + 0: return dma.read_DMAXCNT_H(0, 3); 
            case DMA3CNT_H   + 1: return dma.read_DMAXCNT_H(1, 3); 

            case TM0CNT_L    + 0: return timers.read_TMXCNT_L(0, 0); 
            case TM0CNT_L    + 1: return timers.read_TMXCNT_L(1, 0); 
            case TM0CNT_H    + 0: return timers.read_TMXCNT_H(0, 0); 
            case TM0CNT_H    + 1: return timers.read_TMXCNT_H(1, 0); 
            case TM1CNT_L    + 0: return timers.read_TMXCNT_L(0, 1); 
            case TM1CNT_L    + 1: return timers.read_TMXCNT_L(1, 1); 
            case TM1CNT_H    + 0: return timers.read_TMXCNT_H(0, 1); 
            case TM1CNT_H    + 1: return timers.read_TMXCNT_H(1, 1); 
            case TM2CNT_L    + 0: return timers.read_TMXCNT_L(0, 2); 
            case TM2CNT_L    + 1: return timers.read_TMXCNT_L(1, 2); 
            case TM2CNT_H    + 0: return timers.read_TMXCNT_H(0, 2); 
            case TM2CNT_H    + 1: return timers.read_TMXCNT_H(1, 2); 
            case TM3CNT_L    + 0: return timers.read_TMXCNT_L(0, 3); 
            case TM3CNT_L    + 1: return timers.read_TMXCNT_L(1, 3); 
            case TM3CNT_H    + 0: return timers.read_TMXCNT_H(0, 3); 
            case TM3CNT_H    + 1: return timers.read_TMXCNT_H(1, 3); 

            case KEYINPUT    + 0: return keyinput.read_KEYINPUT(0); 
            case KEYINPUT    + 1: return keyinput.read_KEYINPUT(1); 
            case KEYCNT      + 0: return keyinput.read_KEYCNT(0); 
            case KEYCNT      + 1: return keyinput.read_KEYCNT(1); 

            case IE          + 0: return interrupt.read_IE   (0); 
            case IE          + 1: return interrupt.read_IE   (1); 
            case IF          + 0: return interrupt.read_IF   (0); 
            case IF          + 1: return interrupt.read_IF   (1); 
            case IME         + 0: return interrupt.read_IME  (0); 
            case IME         + 1: return interrupt.read_IME  (1); 

            default: return 0;
        }
    }

    void write(uint address, ubyte data) {
        switch (address) {
            case DISPCNT     + 0: ppu.write_DISPCNT    (0, data); break;
            case DISPCNT     + 1: ppu.write_DISPCNT    (1, data); break;
            case DISPSTAT    + 0: ppu.write_DISPSTAT   (0, data); break;
            case DISPSTAT    + 1: ppu.write_DISPSTAT   (1, data); break;
            case BG0CNT      + 0: ppu.write_BGXCNT     (0, data, 0); break;
            case BG0CNT      + 1: ppu.write_BGXCNT     (1, data, 0); break;
            case BG1CNT      + 0: ppu.write_BGXCNT     (0, data, 1); break;
            case BG1CNT      + 1: ppu.write_BGXCNT     (1, data, 1); break;
            case BG2CNT      + 0: ppu.write_BGXCNT     (0, data, 2); break;
            case BG2CNT      + 1: ppu.write_BGXCNT     (1, data, 2); break;
            case BG3CNT      + 0: ppu.write_BGXCNT     (0, data, 3); break;
            case BG3CNT      + 1: ppu.write_BGXCNT     (1, data, 3); break;
            case BG0HOFS     + 0: ppu.write_BGXHOFS    (0, data, 0); break;
            case BG0HOFS     + 1: ppu.write_BGXHOFS    (1, data, 0); break;
            case BG0VOFS     + 0: ppu.write_BGXVOFS    (0, data, 0); break;
            case BG0VOFS     + 1: ppu.write_BGXVOFS    (1, data, 0); break;
            case BG1HOFS     + 0: ppu.write_BGXHOFS    (0, data, 1); break;
            case BG1HOFS     + 1: ppu.write_BGXHOFS    (1, data, 1); break;
            case BG1VOFS     + 0: ppu.write_BGXVOFS    (0, data, 1); break;
            case BG1VOFS     + 1: ppu.write_BGXVOFS    (1, data, 1); break;
            case BG2HOFS     + 0: ppu.write_BGXHOFS    (0, data, 2); break;
            case BG2HOFS     + 1: ppu.write_BGXHOFS    (1, data, 2); break;
            case BG2VOFS     + 0: ppu.write_BGXVOFS    (0, data, 2); break;
            case BG2VOFS     + 1: ppu.write_BGXVOFS    (1, data, 2); break;
            case BG3HOFS     + 0: ppu.write_BGXHOFS    (0, data, 3); break;
            case BG3HOFS     + 1: ppu.write_BGXHOFS    (1, data, 3); break;
            case BG3VOFS     + 0: ppu.write_BGXVOFS    (0, data, 3); break;
            case BG3VOFS     + 1: ppu.write_BGXVOFS    (1, data, 3); break;
            // case BG2PA       + 0: ppu.write_BG2PA(data); break;
            // case BG2PA       + 1: ppu.write_BG2PA(data); break;
            // case BG2PB       + 0: ppu.write_BG2PB(data); break;
            // case BG2PB       + 1: ppu.write_BG2PB(data); break;
            // case BG2PC       + 0: ppu.write_BG2PC(data); break;
            // case BG2PC       + 1: ppu.write_BG2PC(data); break;
            // case BG2PD       + 0: ppu.write_BG2PD(data); break;
            // case BG2PD       + 1: ppu.write_BG2PD(data); break;
            case BG2X        + 0: ppu.write_BGxX       (0, data, 2); break;
            case BG2X        + 1: ppu.write_BGxX       (1, data, 2); break;
            case BG2X        + 2: ppu.write_BGxX       (2, data, 2); break;
            case BG2X        + 3: ppu.write_BGxX       (3, data, 2); break;
            case BG2Y        + 0: ppu.write_BGxY       (0, data, 2); break;
            case BG2Y        + 1: ppu.write_BGxY       (1, data, 2); break;
            case BG2Y        + 2: ppu.write_BGxY       (2, data, 2); break;
            case BG2Y        + 3: ppu.write_BGxY       (3, data, 2); break;
            // case BG3PA       + 0: ppu.write_BG3PA(data); break;
            // case BG3PA       + 1: ppu.write_BG3PA(data); break;
            // case BG3PB       + 0: ppu.write_BG3PB(data); break;
            // case BG3PB       + 1: ppu.write_BG3PB(data); break;
            // case BG3PC       + 0: ppu.write_BG3PC(data); break;
            // case BG3PC       + 1: ppu.write_BG3PC(data); break;
            // case BG3PD       + 0: ppu.write_BG3PD(data); break;
            // case BG3PD       + 1: ppu.write_BG3PD(data); break;
            case BG3X        + 0: ppu.write_BGxX       (0, data, 3); break;
            case BG3X        + 1: ppu.write_BGxX       (1, data, 3); break;
            case BG3X        + 2: ppu.write_BGxX       (2, data, 3); break;
            case BG3X        + 3: ppu.write_BGxX       (3, data, 3); break;
            case BG3Y        + 0: ppu.write_BGxY       (0, data, 3); break;
            case BG3Y        + 1: ppu.write_BGxY       (1, data, 3); break;
            case BG3Y        + 2: ppu.write_BGxY       (2, data, 3); break;
            case BG3Y        + 3: ppu.write_BGxY       (3, data, 3); break;
            case WIN0H       + 0: ppu.write_WINXH      (0, data, 0); break;
            case WIN0H       + 1: ppu.write_WINXH      (1, data, 0); break;
            case WIN1H       + 0: ppu.write_WINXH      (0, data, 1); break;
            case WIN1H       + 1: ppu.write_WINXH      (1, data, 1); break;
            case WIN0V       + 0: ppu.write_WINXV      (0, data, 0); break;
            case WIN0V       + 1: ppu.write_WINXV      (1, data, 0); break;
            case WIN1V       + 0: ppu.write_WINXV      (0, data, 1); break;
            case WIN1V       + 1: ppu.write_WINXV      (1, data, 1); break;
            case WININ       + 0: ppu.write_WININ      (0, data); break;
            case WININ       + 1: ppu.write_WININ      (1, data); break;
            case WINOUT      + 0: ppu.write_WINOUT     (0, data); break;
            case WINOUT      + 1: ppu.write_WINOUT     (1, data); break;
            // case MOSAIC      + 0: ppu.write_MOSAIC(data); break;
            // case MOSAIC      + 1: ppu.write_MOSAIC(data); break;
            case BLDCNT      + 0: ppu.write_BLDCNT     (0, data); break;
            case BLDCNT      + 1: ppu.write_BLDCNT     (1, data); break;
            // case BLDALPHA    + 0: ppu.write_BLDALPHA   (0, data); break;
            // case BLDALPHA    + 1: ppu.write_BLDALPHA   (1, data); break;
            case BLDY        + 0: ppu.write_BLDY       (0, data); break;
            case BLDY        + 1: ppu.write_BLDY       (1, data); break;

            // case SOUND1CNT_L + 0: apu.write_SOUND1CNT_L(); break; 
            // case SOUND1CNT_L + 1: apu.write_SOUND1CNT_L(); break; 
            // case SOUND1CNT_H + 0: apu.write_SOUND1CNT_H(); break; 
            // case SOUND1CNT_H + 1: apu.write_SOUND1CNT_H(); break; 
            // case SOUND1CNT_X + 0: apu.write_SOUND1CNT_X(); break; 
            // case SOUND1CNT_X + 1: apu.write_SOUND1CNT_X(); break; 
            // case SOUND2CNT_L + 0: apu.write_SOUND2CNT_L(); break; 
            // case SOUND2CNT_L + 1: apu.write_SOUND2CNT_L(); break; 
            // case SOUND2CNT_H + 0: apu.write_SOUND2CNT_H(); break; 
            // case SOUND2CNT_H + 1: apu.write_SOUND2CNT_H(); break; 
            // case SOUND3CNT_L + 0: apu.write_SOUND3CNT_L(); break; 
            // case SOUND3CNT_L + 1: apu.write_SOUND3CNT_L(); break; 
            // case SOUND3CNT_H + 0: apu.write_SOUND3CNT_H(); break; 
            // case SOUND3CNT_H + 1: apu.write_SOUND3CNT_H(); break; 
            // case SOUND3CNT_X + 0: apu.write_SOUND3CNT_X(); break; 
            // case SOUND3CNT_X + 1: apu.write_SOUND3CNT_X(); break; 
            // case SOUND4CNT_L + 0: apu.write_SOUND4CNT_L(); break; 
            // case SOUND4CNT_L + 1: apu.write_SOUND4CNT_L(); break; 
            // case SOUND4CNT_H + 0: apu.write_SOUND4CNT_H(); break; 
            // case SOUND4CNT_H + 1: apu.write_SOUND4CNT_H(); break; 
            // case SOUNDCNT_L  + 0: apu.write_SOUNDCNT_L (0, data); break; 
            // case SOUNDCNT_L  + 1: apu.write_SOUNDCNT_L (1, data); break; 
            case SOUNDCNT_H  + 0: apu.write_SOUNDCNT_H (0, data); break; 
            case SOUNDCNT_H  + 1: apu.write_SOUNDCNT_H (1, data); break; 
            // case SOUNDCNT_X  + 0: apu.write_SOUNDCNT_X (0, data); break; 
            // case SOUNDCNT_X  + 1: apu.write_SOUNDCNT_X (1, data); break;
            case SOUNDBIAS   + 0: apu.write_SOUNDBIAS  (0, data); break; 
            case SOUNDBIAS   + 1: apu.write_SOUNDBIAS  (1, data); break; 
            case FIFO_A      + 0: apu.write_FIFO       (data, DirectSound.A); break;
            case FIFO_A      + 1: apu.write_FIFO       (data, DirectSound.A); break;
            case FIFO_A      + 2: apu.write_FIFO       (data, DirectSound.A); break;
            case FIFO_A      + 3: apu.write_FIFO       (data, DirectSound.A); break;
            case FIFO_B      + 0: apu.write_FIFO       (data, DirectSound.B); break;
            case FIFO_B      + 1: apu.write_FIFO       (data, DirectSound.B); break;
            case FIFO_B      + 2: apu.write_FIFO       (data, DirectSound.B); break;
            case FIFO_B      + 3: apu.write_FIFO       (data, DirectSound.B); break;

            case DMA0SAD     + 0: dma.write_DMAXSAD    (0, data, 0); break;
            case DMA0SAD     + 1: dma.write_DMAXSAD    (1, data, 0); break;
            case DMA0SAD     + 2: dma.write_DMAXSAD    (2, data, 0); break;
            case DMA0SAD     + 3: dma.write_DMAXSAD    (3, data, 0); break;
            case DMA0DAD     + 0: dma.write_DMAXDAD    (0, data, 0); break;
            case DMA0DAD     + 1: dma.write_DMAXDAD    (1, data, 0); break;
            case DMA0DAD     + 2: dma.write_DMAXDAD    (2, data, 0); break;
            case DMA0DAD     + 3: dma.write_DMAXDAD    (3, data, 0); break;
            case DMA0CNT_L   + 0: dma.write_DMAXCNT_L  (0, data, 0); break;
            case DMA0CNT_L   + 1: dma.write_DMAXCNT_L  (1, data, 0); break;
            case DMA0CNT_H   + 0: dma.write_DMAXCNT_H  (0, data, 0); break;
            case DMA0CNT_H   + 1: dma.write_DMAXCNT_H  (1, data, 0); break;
            case DMA1SAD     + 0: dma.write_DMAXSAD    (0, data, 1); break;
            case DMA1SAD     + 1: dma.write_DMAXSAD    (1, data, 1); break;
            case DMA1SAD     + 2: dma.write_DMAXSAD    (2, data, 1); break;
            case DMA1SAD     + 3: dma.write_DMAXSAD    (3, data, 1); break;
            case DMA1DAD     + 0: dma.write_DMAXDAD    (0, data, 1); break;
            case DMA1DAD     + 1: dma.write_DMAXDAD    (1, data, 1); break;
            case DMA1DAD     + 2: dma.write_DMAXDAD    (2, data, 1); break;
            case DMA1DAD     + 3: dma.write_DMAXDAD    (3, data, 1); break;
            case DMA1CNT_L   + 0: dma.write_DMAXCNT_L  (0, data, 1); break;
            case DMA1CNT_L   + 1: dma.write_DMAXCNT_L  (1, data, 1); break;
            case DMA1CNT_H   + 0: dma.write_DMAXCNT_H  (0, data, 1); break;
            case DMA1CNT_H   + 1: dma.write_DMAXCNT_H  (1, data, 1); break;
            case DMA2SAD     + 0: dma.write_DMAXSAD    (0, data, 2); break;
            case DMA2SAD     + 1: dma.write_DMAXSAD    (1, data, 2); break;
            case DMA2SAD     + 2: dma.write_DMAXSAD    (2, data, 2); break;
            case DMA2SAD     + 3: dma.write_DMAXSAD    (3, data, 2); break;
            case DMA2DAD     + 0: dma.write_DMAXDAD    (0, data, 2); break;
            case DMA2DAD     + 1: dma.write_DMAXDAD    (1, data, 2); break;
            case DMA2DAD     + 2: dma.write_DMAXDAD    (2, data, 2); break;
            case DMA2DAD     + 3: dma.write_DMAXDAD    (3, data, 2); break;
            case DMA2CNT_L   + 0: dma.write_DMAXCNT_L  (0, data, 2); break;
            case DMA2CNT_L   + 1: dma.write_DMAXCNT_L  (1, data, 2); break;
            case DMA2CNT_H   + 0: dma.write_DMAXCNT_H  (0, data, 2); break;
            case DMA2CNT_H   + 1: dma.write_DMAXCNT_H  (1, data, 2); break;
            case DMA3SAD     + 0: dma.write_DMAXSAD    (0, data, 3); break;
            case DMA3SAD     + 1: dma.write_DMAXSAD    (1, data, 3); break;
            case DMA3SAD     + 2: dma.write_DMAXSAD    (2, data, 3); break;
            case DMA3SAD     + 3: dma.write_DMAXSAD    (3, data, 3); break;
            case DMA3DAD     + 0: dma.write_DMAXDAD    (0, data, 3); break;
            case DMA3DAD     + 1: dma.write_DMAXDAD    (1, data, 3); break;
            case DMA3DAD     + 2: dma.write_DMAXDAD    (2, data, 3); break;
            case DMA3DAD     + 3: dma.write_DMAXDAD    (3, data, 3); break;
            case DMA3CNT_L   + 0: dma.write_DMAXCNT_L  (0, data, 3); break;
            case DMA3CNT_L   + 1: dma.write_DMAXCNT_L  (1, data, 3); break;
            case DMA3CNT_H   + 0: dma.write_DMAXCNT_H  (0, data, 3); break;
            case DMA3CNT_H   + 1: dma.write_DMAXCNT_H  (1, data, 3); break;

            case TM0CNT_L    + 0: timers.write_TMXCNT_L(0, data, 0); break;
            case TM0CNT_L    + 1: timers.write_TMXCNT_L(1, data, 0); break;
            case TM0CNT_H    + 0: timers.write_TMXCNT_H(0, data, 0); break;
            case TM0CNT_H    + 1: timers.write_TMXCNT_H(1, data, 0); break;
            case TM1CNT_L    + 0: timers.write_TMXCNT_L(0, data, 1); break;
            case TM1CNT_L    + 1: timers.write_TMXCNT_L(1, data, 1); break;
            case TM1CNT_H    + 0: timers.write_TMXCNT_H(0, data, 1); break;
            case TM1CNT_H    + 1: timers.write_TMXCNT_H(1, data, 1); break;
            case TM2CNT_L    + 0: timers.write_TMXCNT_L(0, data, 2); break;
            case TM2CNT_L    + 1: timers.write_TMXCNT_L(1, data, 2); break;
            case TM2CNT_H    + 0: timers.write_TMXCNT_H(0, data, 2); break;
            case TM2CNT_H    + 1: timers.write_TMXCNT_H(1, data, 2); break;
            case TM3CNT_L    + 0: timers.write_TMXCNT_L(0, data, 3); break;
            case TM3CNT_L    + 1: timers.write_TMXCNT_L(1, data, 3); break;
            case TM3CNT_H    + 0: timers.write_TMXCNT_H(0, data, 3); break;
            case TM3CNT_H    + 1: timers.write_TMXCNT_H(1, data, 3); break;

            case KEYCNT      + 0: keyinput.write_KEYCNT(0, data); break;
            case KEYCNT      + 1: keyinput.write_KEYCNT(1, data); break;
            
            case IE          + 0: interrupt.write_IE   (0, data); break;
            case IE          + 1: interrupt.write_IE   (1, data); break;
            case IF          + 0: interrupt.write_IF   (0, data); break;
            case IF          + 1: interrupt.write_IF   (1, data); break;
            case IME         + 0: interrupt.write_IME  (0, data); break;
            case IME         + 1: interrupt.write_IME  (1, data); break;

            default: break;
        }
    }


private:
    PPU              ppu;
    APU              apu;
    DMAManager       dma;
    TimerManager     timers;
    InterruptManager interrupt;
    KeyInput         keyinput;
}