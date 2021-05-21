module memory-mapped-io;

class mmio {

    // IO Registers
    //          NAME            ADDRESS       SIZE  R/W   DESCRIPTION

    static uint DISPCNT       = 0x4000000; //  2    R/W   LCD Control
    static uint DISPSTAT      = 0x4000004; //  2    R/W   General LCD Status (STAT,LYC)
    static uint VCOUNT        = 0x4000006; //  2    R     Vertical Counter (LY)
    static uint BG0CNT        = 0x4000008; //  2    R/W   BG0 Control
    static uint BG1CNT        = 0x400000A; //  2    R/W   BG1 Control
    static uint BG2CNT        = 0x400000C; //  2    R/W   BG2 Control
    static uint BG3CNT        = 0x400000E; //  2    R/W   BG3 Control
    static uint BG0HOFS       = 0x4000010; //  2      W   BG0 X-Offset
    static uint BG0VOFS       = 0x4000012; //  2      W   BG0 Y-Offset
    static uint BG1HOFS       = 0x4000014; //  2      W   BG1 X-Offset
    static uint BG1VOFS       = 0x4000016; //  2      W   BG1 Y-Offset
    static uint BG2HOFS       = 0x4000018; //  2      W   BG2 X-Offset
    static uint BG2VOFS       = 0x400001A; //  2      W   BG2 Y-Offset
    static uint BG3HOFS       = 0x400001C; //  2      W   BG3 X-Offset
    static uint BG3VOFS       = 0x400001E; //  2      W   BG3 Y-Offset
    static uint BG2PA         = 0x4000020; //  2      W   BG2 Rotation/Scaling Parameter A (dx)
    static uint BG2PB         = 0x4000022; //  2      W   BG2 Rotation/Scaling Parameter B (dmx)
    static uint BG2PC         = 0x4000024; //  2      W   BG2 Rotation/Scaling Parameter C (dy)
    static uint BG2PD         = 0x4000026; //  2      W   BG2 Rotation/Scaling Parameter D (dmy)
    static uint BG2X          = 0x4000028; //  4      W   BG2 Reference Point X-Coordinate
    static uint BG2Y          = 0x400002C; //  4      W   BG2 Reference Point Y-Coordinate
    static uint BG3PA         = 0x4000030; //  2      W   BG3 Rotation/Scaling Parameter A (dx)
    static uint BG3PB         = 0x4000032; //  2      W   BG3 Rotation/Scaling Parameter B (dmx)
    static uint BG3PC         = 0x4000034; //  2      W   BG3 Rotation/Scaling Parameter C (dy)
    static uint BG3PD         = 0x4000036; //  2      W   BG3 Rotation/Scaling Parameter D (dmy)
    static uint BG3X          = 0x4000038; //  4      W   BG3 Reference Point X-Coordinate
    static uint BG3Y          = 0x400003C; //  4      W   BG3 Reference Point Y-Coordinate
    static uint WIN0H         = 0x4000040; //  2      W   Window 0 Horizontal Dimensions
    static uint WIN1H         = 0x4000042; //  2      W   Window 1 Horizontal Dimensions
    static uint WIN0V         = 0x4000044; //  2      W   Window 0 Vertical Dimensions
    static uint WIN1V         = 0x4000046; //  2      W   Window 1 Vertical Dimensions
    static uint WININ         = 0x4000048; //  2    R/W   Inside of Window 0 and 1
    static uint WINOUT        = 0x400004A; //  2    R/W   Inside of OBJ Window & Outside of Windows
    static uint MOSAIC        = 0x400004C; //  2      W   Mosaic Size
    static uint BLDCNT        = 0x4000050; //  2    R/W   Color Special Effects Selection
    static uint BLDALPHA      = 0x4000052; //  2    R/W   Alpha Blending Coefficients
    static uint BLDY          = 0x4000054; //  2      W   Brightness (Fade-In/Out) Coefficient

    static uint SOUND1CNT_L   = 0x4000060; //  2    R/W   Channel 1 Sweep Register       (NR10)
    static uint SOUND1CNT_H   = 0x4000062; //  2    R/W   Channel 1 Duty/Length/Envelope (NR11, NR12)
    static uint SOUND1CNT_X   = 0x4000064; //  2    R/W   Channel 1 Frequency/Control    (NR13, NR14)
    static uint SOUND2CNT_L   = 0x4000068; //  2    R/W   Channel 2 Duty/Length/Envelope (NR21, NR22)
    static uint SOUND2CNT_H   = 0x400006C; //  2    R/W   Channel 2 Frequency/Control    (NR23, NR24)
    static uint SOUND3CNT_L   = 0x4000070; //  2    R/W   Channel 3 Stop/Wave RAM select (NR30)
    static uint SOUND3CNT_H   = 0x4000072; //  2    R/W   Channel 3 Length/Volume        (NR31, NR32)
    static uint SOUND3CNT_X   = 0x4000074; //  2    R/W   Channel 3 Frequency/Control    (NR33, NR34)
    static uint SOUND4CNT_L   = 0x4000078; //  2    R/W   Channel 4 Length/Envelope      (NR41, NR42)
    static uint SOUND4CNT_H   = 0x400007C; //  2    R/W   Channel 4 Frequency/Control    (NR43, NR44)
    static uint SOUNDCNT_L    = 0x4000080; //  2    R/W   Control Stereo/Volume/Enable   (NR50, NR51)
    static uint SOUNDCNT_H    = 0x4000082; //  2    R/W   Control Mixing/DMA Control
    static uint SOUNDCNT_X    = 0x4000084; //  2    R/W   Control Sound on/off           (NR52)
    static uint SOUNDBIAS     = 0x4000088; //  2    BIOS  Sound PWM Control

    static uint DMA0SAD       = 0x40000B0; //  4      W   DMA 0 Source Address
    static uint DMA0DAD       = 0x40000B4; //  4      W   DMA 0 Destination Address
    static uint DMA0CNT_L     = 0x40000B8; //  2      W   DMA 0 Word Count
    static uint DMA0CNT_H     = 0x40000BA; //  2    R/W   DMA 0 Control
    static uint DMA1SAD       = 0x40000BC; //  4      W   DMA 1 Source Address
    static uint DMA1DAD       = 0x40000C0; //  4      W   DMA 1 Destination Address
    static uint DMA1CNT_L     = 0x40000C4; //  2      W   DMA 1 Word Count
    static uint DMA1CNT_H     = 0x40000C6; //  2    R/W   DMA 1 Control
    static uint DMA2SAD       = 0x40000C8; //  4      W   DMA 2 Source Address
    static uint DMA2DAD       = 0x40000CC; //  4      W   DMA 2 Destination Address
    static uint DMA2CNT_L     = 0x40000D0; //  2      W   DMA 2 Word Count
    static uint DMA2CNT_H     = 0x40000D2; //  2    R/W   DMA 2 Control
    static uint DMA3SAD       = 0x40000D4; //  4      W   DMA 3 Source Address
    static uint DMA3DAD       = 0x40000D8; //  4      W   DMA 3 Destination Address
    static uint DMA3CNT_L     = 0x40000DC; //  2      W   DMA 3 Word Count
    static uint DMA3CNT_H     = 0x40000DE; //  2    R/W   DMA 3 Control

    static uint TM0CNT_L      = 0x4000100; //  2    R/W   Timer 0 Counter/Reload
    static uint TM0CNT_H      = 0x4000102; //  2    R/W   Timer 0 Control
    static uint TM1CNT_L      = 0x4000104; //  2    R/W   Timer 1 Counter/Reload
    static uint TM1CNT_H      = 0x4000106; //  2    R/W   Timer 1 Control
    static uint TM2CNT_L      = 0x4000108; //  2    R/W   Timer 2 Counter/Reload
    static uint TM2CNT_H      = 0x400010A; //  2    R/W   Timer 2 Control
    static uint TM3CNT_L      = 0x400010C; //  2    R/W   Timer 3 Counter/Reload
    static uint TM3CNT_H      = 0x400010E; //  2    R/W   Timer 3 Control

    static uint KEYINPUT      = 0x4000130; //  2    R     Key Status
    static uint KEYCNT        = 0x4000132; //  2    R/W   Key Interrupt Control
    
    static uint IE            = 0x4000200; //  2    R/W   Interrupt Enable Register
    static uint IF            = 0x4000202; //  2    R/W   Interrupt Request Flags / IRQ Acknowledge
    static uint IME           = 0x4000208; //  2    R/W   Interrupt Master Enable Register

    this() {

    }

    ubyte read_mem(uint address) {
        switch (address) {
            case DISPCNT     + 0: return ppu.read_DISPCNT(address); break;
            case DISPCNT     + 1: return ppu.read_DISPCNT(address); break;
            case DISPSTAT    + 0: return ppu.read_DISPSTAT(address); break;
            case DISPSTAT    + 1: return ppu.read_DISPSTAT(address); break;
            case VCOUNT      + 0: return ppu.read_VCOUNT(address); break;
            case VCOUNT      + 1: return ppu.read_VCOUNT(address); break;
            case BG0CNT      + 0: return ppu.read_BG0CNT(address); break;
            case BG0CNT      + 1: return ppu.read_BG0CNT(address); break;
            case BG1CNT      + 0: return ppu.read_BG1CNT(address); break;
            case BG1CNT      + 1: return ppu.read_BG1CNT(address); break;
            case BG2CNT      + 0: return ppu.read_BG2CNT(address); break;
            case BG2CNT      + 1: return ppu.read_BG2CNT(address); break;
            case BG3CNT      + 0: return ppu.read_BG3CNT(address); break;
            case BG3CNT      + 1: return ppu.read_BG3CNT(address); break;
            case WININ       + 0: return ppu.read_WININ(address); break;
            case WININ       + 1: return ppu.read_WININ(address); break;
            case WINOUT      + 0: return ppu.read_WINOUT(address); break;
            case WINOUT      + 1: return ppu.read_WINOUT(address); break;
            case BLDCNT      + 0: return ppu.read_BLDCNT(address); break;
            case BLDCNT      + 1: return ppu.read_BLDCNT(address); break;
            case BLDALPHA    + 0: return ppu.read_BLDALPHA(address); break;
            case BLDALPHA    + 1: return ppu.read_BLDALPHA(address); break;

            case SOUND1CNT_L + 0: return apu.read_SOUND1CNT_L(address); break;
            case SOUND1CNT_L + 1: return apu.read_SOUND1CNT_L(address); break;
            case SOUND1CNT_H + 0: return apu.read_SOUND1CNT_H(address); break;
            case SOUND1CNT_H + 1: return apu.read_SOUND1CNT_H(address); break;
            case SOUND1CNT_X + 0: return apu.read_SOUND1CNT_X(address); break;
            case SOUND1CNT_X + 1: return apu.read_SOUND1CNT_X(address); break;
            case SOUND2CNT_L + 0: return apu.read_SOUND2CNT_L(address); break;
            case SOUND2CNT_L + 1: return apu.read_SOUND2CNT_L(address); break;
            case SOUND2CNT_H + 0: return apu.read_SOUND2CNT_H(address); break;
            case SOUND2CNT_H + 1: return apu.read_SOUND2CNT_H(address); break;
            case SOUND3CNT_L + 0: return apu.read_SOUND3CNT_L(address); break;
            case SOUND3CNT_L + 1: return apu.read_SOUND3CNT_L(address); break;
            case SOUND3CNT_H + 0: return apu.read_SOUND3CNT_H(address); break;
            case SOUND3CNT_H + 1: return apu.read_SOUND3CNT_H(address); break;
            case SOUND3CNT_X + 0: return apu.read_SOUND3CNT_X(address); break;
            case SOUND3CNT_X + 1: return apu.read_SOUND3CNT_X(address); break;
            case SOUND4CNT_L + 0: return apu.read_SOUND4CNT_L(address); break;
            case SOUND4CNT_L + 1: return apu.read_SOUND4CNT_L(address); break;
            case SOUND4CNT_H + 0: return apu.read_SOUND4CNT_H(address); break;
            case SOUND4CNT_H + 1: return apu.read_SOUND4CNT_H(address); break;
            case SOUNDCNT_L  + 0: return apu.read_SOUNDCNT_L(address); break;
            case SOUNDCNT_L  + 1: return apu.read_SOUNDCNT_L(address); break;
            case SOUNDCNT_H  + 0: return apu.read_SOUNDCNT_H(address); break;
            case SOUNDCNT_H  + 1: return apu.read_SOUNDCNT_H(address); break;
            case SOUNDCNT_X  + 0: return apu.read_SOUNDCNT_X(address); break;
            case SOUNDCNT_X  + 1: return apu.read_SOUNDCNT_X(address); break;
            case SOUNDBIAS   + 0: return apu.read_SOUNDBIAS(address); break;
            case SOUNDBIAS   + 1: return apu.read_SOUNDBIAS(address); break;


            case DMA0CNT_H   + 0: return dma.read_DMA0CNT_H(address); break;
            case DMA0CNT_H   + 1: return dma.read_DMA0CNT_H(address); break;
            case DMA1CNT_H   + 0: return dma.read_DMA1CNT_H(address); break;
            case DMA1CNT_H   + 1: return dma.read_DMA1CNT_H(address); break;
            case DMA2CNT_H   + 0: return dma.read_DMA2CNT_H(address); break;
            case DMA2CNT_H   + 1: return dma.read_DMA2CNT_H(address); break;
            case DMA3CNT_H   + 0: return dma.read_DMA3CNT_H(address); break;
            case DMA3CNT_H   + 1: return dma.read_DMA3CNT_H(address); break;

            case TM0CNT_L    + 0: return timers.read_TM0CNT_L(address); break;
            case TM0CNT_L    + 1: return timers.read_TM0CNT_L(address); break;
            case TM0CNT_H    + 0: return timers.read_TM0CNT_H(address); break;
            case TM0CNT_H    + 1: return timers.read_TM0CNT_H(address); break;
            case TM1CNT_L    + 0: return timers.read_TM1CNT_L(address); break;
            case TM1CNT_L    + 1: return timers.read_TM1CNT_L(address); break;
            case TM1CNT_H    + 0: return timers.read_TM1CNT_H(address); break;
            case TM1CNT_H    + 1: return timers.read_TM1CNT_H(address); break;
            case TM2CNT_L    + 0: return timers.read_TM2CNT_L(address); break;
            case TM2CNT_L    + 1: return timers.read_TM2CNT_L(address); break;
            case TM2CNT_H    + 0: return timers.read_TM2CNT_H(address); break;
            case TM2CNT_H    + 1: return timers.read_TM2CNT_H(address); break;
            case TM3CNT_L    + 0: return timers.read_TM3CNT_L(address); break;
            case TM3CNT_L    + 1: return timers.read_TM3CNT_L(address); break;
            case TM3CNT_H    + 0: return timers.read_TM3CNT_H(address); break;
            case TM3CNT_H    + 1: return timers.read_TM3CNT_H(address); break;

            case KEYINPUT    + 0: return keyinput.read_KEYINPUT(address); break;
            case KEYINPUT    + 1: return keyinput.read_KEYINPUT(address); break;
            case KEYCNT      + 0: return keyinput.read_KEYCNT(address); break;
            case KEYCNT      + 1: return keyinput.read_KEYCNT(address); break;

            case IE          + 0: return interrupt.read_IE(address); break;
            case IE          + 1: return interrupt.read_IE(address); break;
            case IF          + 0: return interrupt.read_IF(address); break;
            case IF          + 1: return interrupt.read_IF(address); break;
            case IME         + 0: return interrupt.read_IME(address); break;
            case IME         + 1: return interrupt.read_IME(address); break;
        }
    }

    void write_mem(uint address, ubyte data) {
        switch (address) {
            case DISPCNT     + 0: ppu.write_DISPCNT    (address, data); break;
            case DISPCNT     + 1: ppu.write_DISPCNT    (address, data); break;
            case DISPSTAT    + 0: ppu.write_DISPSTAT(address, data); break;
            case DISPSTAT    + 1: ppu.write_DISPSTAT(address, data); break;
            case VCOUNT      + 0: ppu.write_VCOUNT(address, data); break;
            case VCOUNT      + 1: ppu.write_VCOUNT(address, data); break;
            case BG0CNT      + 0: ppu.write_BG0CNT(address, data); break;
            case BG0CNT      + 1: ppu.write_BG0CNT(address, data); break;
            case BG1CNT      + 0: ppu.write_BG1CNT(address, data); break;
            case BG1CNT      + 1: ppu.write_BG1CNT(address, data); break;
            case BG2CNT      + 0: ppu.write_BG2CNT(address, data); break;
            case BG2CNT      + 1: ppu.write_BG2CNT(address, data); break;
            case BG3CNT      + 0: ppu.write_BG3CNT(address, data); break;
            case BG3CNT      + 1: ppu.write_BG3CNT(address, data); break;
            case BG0HOFS     + 0: ppu.write_BG0HOFS(address, data); break;
            case BG0HOFS     + 1: ppu.write_BG0HOFS(address, data); break;
            case BG0VOFS     + 0: ppu.write_BG0VOFS(address, data); break;
            case BG0VOFS     + 1: ppu.write_BG0VOFS(address, data); break;
            case BG1HOFS     + 0: ppu.write_BG1HOFS(address, data); break;
            case BG1HOFS     + 1: ppu.write_BG1HOFS(address, data); break;
            case BG1VOFS     + 0: ppu.write_BG1VOFS(address, data); break;
            case BG1VOFS     + 1: ppu.write_BG1VOFS(address, data); break;
            case BG2HOFS     + 0: ppu.write_BG2HOFS(address, data); break;
            case BG2HOFS     + 1: ppu.write_BG2HOFS(address, data); break;
            case BG2VOFS     + 0: ppu.write_BG2VOFS(address, data); break;
            case BG2VOFS     + 1: ppu.write_BG2VOFS(address, data); break;
            case BG3HOFS     + 0: ppu.write_BG3HOFS(address, data); break;
            case BG3HOFS     + 1: ppu.write_BG3HOFS(address, data); break;
            case BG3VOFS     + 0: ppu.write_BG3VOFS(address, data); break;
            case BG3VOFS     + 1: ppu.write_BG3VOFS(address, data); break;
            case BG2PA       + 0: ppu.write_BG2PA(address, data); break;
            case BG2PA       + 1: ppu.write_BG2PA(address, data); break;
            case BG2PB       + 0: ppu.write_BG2PB(address, data); break;
            case BG2PB       + 1: ppu.write_BG2PB(address, data); break;
            case BG2PC       + 0: ppu.write_BG2PC(address, data); break;
            case BG2PC       + 1: ppu.write_BG2PC(address, data); break;
            case BG2PD       + 0: ppu.write_BG2PD(address, data); break;
            case BG2PD       + 1: ppu.write_BG2PD(address, data); break;
            case BG2X        + 0: ppu.write_BG2X(address, data); break;
            case BG2X        + 1: ppu.write_BG2X(address, data); break;
            case BG2X        + 2: ppu.write_BG2X(address, data); break;
            case BG2X        + 3: ppu.write_BG2X(address, data); break;
            case BG2Y        + 0: ppu.write_BG2Y(address, data); break;
            case BG2Y        + 1: ppu.write_BG2Y(address, data); break;
            case BG2Y        + 2: ppu.write_BG2Y(address, data); break;
            case BG2Y        + 3: ppu.write_BG2Y(address, data); break;
            case BG3PA       + 0: ppu.write_BG3PA(address, data); break;
            case BG3PA       + 1: ppu.write_BG3PA(address, data); break;
            case BG3PB       + 0: ppu.write_BG3PB(address, data); break;
            case BG3PB       + 1: ppu.write_BG3PB(address, data); break;
            case BG3PC       + 0: ppu.write_BG3PC(address, data); break;
            case BG3PC       + 1: ppu.write_BG3PC(address, data); break;
            case BG3PD       + 0: ppu.write_BG3PD(address, data); break;
            case BG3PD       + 1: ppu.write_BG3PD(address, data); break;
            case BG3X        + 0: ppu.write_BG3X(address, data); break;
            case BG3X        + 1: ppu.write_BG3X(address, data); break;
            case BG3X        + 2: ppu.write_BG3X(address, data); break;
            case BG3X        + 3: ppu.write_BG3X(address, data); break;
            case BG3Y        + 0: ppu.write_BG3Y(address, data); break;
            case BG3Y        + 1: ppu.write_BG3Y(address, data); break;
            case BG3Y        + 2: ppu.write_BG3Y(address, data); break;
            case BG3Y        + 3: ppu.write_BG3Y(address, data); break;
            case WIN0H       + 0: ppu.write_WIN0H(address, data); break;
            case WIN0H       + 1: ppu.write_WIN0H(address, data); break;
            case WIN1H       + 0: ppu.write_WIN1H(address, data); break;
            case WIN1H       + 1: ppu.write_WIN1H(address, data); break;
            case WIN0V       + 0: ppu.write_WIN0V(address, data); break;
            case WIN0V       + 1: ppu.write_WIN0V(address, data); break;
            case WIN1V       + 0: ppu.write_WIN1V(address, data); break;
            case WIN1V       + 1: ppu.write_WIN1V(address, data); break;
            case WININ       + 0: ppu.write_WININ(address, data); break;
            case WININ       + 1: ppu.write_WININ(address, data); break;
            case WINOUT      + 0: ppu.write_WINOUT(address, data); break;
            case WINOUT      + 1: ppu.write_WINOUT(address, data); break;
            case MOSAIC      + 0: ppu.write_MOSAIC(address, data); break;
            case MOSAIC      + 1: ppu.write_MOSAIC(address, data); break;
            case BLDCNT      + 0: ppu.write_BLDCNT(address, data); break;
            case BLDCNT      + 1: ppu.write_BLDCNT(address, data); break;
            case BLDALPHA    + 0: ppu.write_BLDALPHA(address, data); break;
            case BLDALPHA    + 1: ppu.write_BLDALPHA(address, data); break;
            case BLDY        + 0: ppu.write_BLDY(address, data); break;
            case BLDY        + 1: ppu.write_BLDY(address, data); break;
            
            case SOUND1CNT_L + 0: apu.write_SOUND1CNT_L(address, data); break;
            case SOUND1CNT_L + 1: apu.write_SOUND1CNT_L(address, data); break;
            case SOUND1CNT_H + 0: apu.write_SOUND1CNT_H(address, data); break;
            case SOUND1CNT_H + 1: apu.write_SOUND1CNT_H(address, data); break;
            case SOUND1CNT_X + 0: apu.write_SOUND1CNT_X(address, data); break;
            case SOUND1CNT_X + 1: apu.write_SOUND1CNT_X(address, data); break;
            case SOUND2CNT_L + 0: apu.write_SOUND2CNT_L(address, data); break;
            case SOUND2CNT_L + 1: apu.write_SOUND2CNT_L(address, data); break;
            case SOUND2CNT_H + 0: apu.write_SOUND2CNT_H(address, data); break;
            case SOUND2CNT_H + 1: apu.write_SOUND2CNT_H(address, data); break;
            case SOUND3CNT_L + 0: apu.write_SOUND3CNT_L(address, data); break;
            case SOUND3CNT_L + 1: apu.write_SOUND3CNT_L(address, data); break;
            case SOUND3CNT_H + 0: apu.write_SOUND3CNT_H(address, data); break;
            case SOUND3CNT_H + 1: apu.write_SOUND3CNT_H(address, data); break;
            case SOUND3CNT_X + 0: apu.write_SOUND3CNT_X(address, data); break;
            case SOUND3CNT_X + 1: apu.write_SOUND3CNT_X(address, data); break;
            case SOUND4CNT_L + 0: apu.write_SOUND4CNT_L(address, data); break;
            case SOUND4CNT_L + 1: apu.write_SOUND4CNT_L(address, data); break;
            case SOUND4CNT_H + 0: apu.write_SOUND4CNT_H(address, data); break;
            case SOUND4CNT_H + 1: apu.write_SOUND4CNT_H(address, data); break;
            case SOUNDCNT_L  + 0: apu.write_SOUNDCNT_L(address, data); break;
            case SOUNDCNT_L  + 1: apu.write_SOUNDCNT_L(address, data); break;
            case SOUNDCNT_H  + 0: apu.write_SOUNDCNT_H(address, data); break;
            case SOUNDCNT_H  + 1: apu.write_SOUNDCNT_H(address, data); break;
            case SOUNDCNT_X  + 0: apu.write_SOUNDCNT_X(address, data); break;
            case SOUNDCNT_X  + 1: apu.write_SOUNDCNT_X(address, data); break;
            case SOUNDBIAS   + 0: dma.write_SOUNDBIAS(address, data); break;
            case SOUNDBIAS   + 1: dma.write_SOUNDBIAS(address, data); break;
            case DMA0SAD     + 0: dma.write_DMA0SAD(address, data); break;
            case DMA0SAD     + 1: dma.write_DMA0SAD(address, data); break;
            case DMA0SAD     + 2: dma.write_DMA0SAD(address, data); break;
            case DMA0SAD     + 3: dma.write_DMA0SAD(address, data); break;
            case DMA0DAD     + 0: dma.write_DMA0DAD(address, data); break;
            case DMA0DAD     + 1: dma.write_DMA0DAD(address, data); break;
            case DMA0DAD     + 2: dma.write_DMA0DAD(address, data); break;
            case DMA0DAD     + 3: dma.write_DMA0DAD(address, data); break;
            case DMA0CNT_L   + 0: dma.write_DMA0CNT_L(address, data); break;
            case DMA0CNT_L   + 1: dma.write_DMA0CNT_L(address, data); break;
            case DMA0CNT_H   + 0: dma.write_DMA0CNT_H(address, data); break;
            case DMA0CNT_H   + 1: dma.write_DMA0CNT_H(address, data); break;
            case DMA1SAD     + 0: dma.write_DMA1SAD(address, data); break;
            case DMA1SAD     + 1: dma.write_DMA1SAD(address, data); break;
            case DMA1SAD     + 2: dma.write_DMA1SAD(address, data); break;
            case DMA1SAD     + 3: dma.write_DMA1SAD(address, data); break;
            case DMA1DAD     + 0: dma.write_DMA1DAD(address, data); break;
            case DMA1DAD     + 1: dma.write_DMA1DAD(address, data); break;
            case DMA1DAD     + 2: dma.write_DMA1DAD(address, data); break;
            case DMA1DAD     + 3: dma.write_DMA1DAD(address, data); break;
            case DMA1CNT_L   + 0: dma.write_DMA1CNT_L(address, data); break;
            case DMA1CNT_L   + 1: dma.write_DMA1CNT_L(address, data); break;
            case DMA1CNT_H   + 0: dma.write_DMA1CNT_H(address, data); break;
            case DMA1CNT_H   + 1: dma.write_DMA1CNT_H(address, data); break;
            case DMA2SAD     + 0: dma.write_DMA2SAD(address, data); break;
            case DMA2SAD     + 1: dma.write_DMA2SAD(address, data); break;
            case DMA2SAD     + 2: dma.write_DMA2SAD(address, data); break;
            case DMA2SAD     + 3: dma.write_DMA2SAD(address, data); break;
            case DMA2DAD     + 0: dma.write_DMA2DAD(address, data); break;
            case DMA2DAD     + 1: dma.write_DMA2DAD(address, data); break;
            case DMA2DAD     + 2: dma.write_DMA2DAD(address, data); break;
            case DMA2DAD     + 3: dma.write_DMA2DAD(address, data); break;
            case DMA2CNT_L   + 0: dma.write_DMA2CNT_L(address, data); break;
            case DMA2CNT_L   + 1: dma.write_DMA2CNT_L(address, data); break;
            case DMA2CNT_H   + 0: dma.write_DMA2CNT_H(address, data); break;
            case DMA2CNT_H   + 1: dma.write_DMA2CNT_H(address, data); break;
            case DMA3SAD     + 0: dma.write_DMA3SAD(address, data); break;
            case DMA3SAD     + 1: dma.write_DMA3SAD(address, data); break;
            case DMA3SAD     + 2: dma.write_DMA3SAD(address, data); break;
            case DMA3SAD     + 3: dma.write_DMA3SAD(address, data); break;
            case DMA3DAD     + 0: dma.write_DMA3DAD(address, data); break;
            case DMA3DAD     + 1: dma.write_DMA3DAD(address, data); break;
            case DMA3DAD     + 2: dma.write_DMA3DAD(address, data); break;
            case DMA3DAD     + 3: dma.write_DMA3DAD(address, data); break;
            case DMA3CNT_L   + 0: dma.write_DMA3CNT_L(address, data); break;
            case DMA3CNT_L   + 1: dma.write_DMA3CNT_L(address, data); break;
            case DMA3CNT_H   + 0: timers.write_DMA3CNT_H(address, data); break;
            case DMA3CNT_H   + 1: timers.write_DMA3CNT_H(address, data); break;
            case TM0CNT_L    + 0: timers.write_TM0CNT_L(address, data); break;
            case TM0CNT_L    + 1: timers.write_TM0CNT_L(address, data); break;
            case TM0CNT_H    + 0: timers.write_TM0CNT_H(address, data); break;
            case TM0CNT_H    + 1: timers.write_TM0CNT_H(address, data); break;
            case TM1CNT_L    + 0: timers.write_TM1CNT_L(address, data); break;
            case TM1CNT_L    + 1: timers.write_TM1CNT_L(address, data); break;
            case TM1CNT_H    + 0: timers.write_TM1CNT_H(address, data); break;
            case TM1CNT_H    + 1: timers.write_TM1CNT_H(address, data); break;
            case TM2CNT_L    + 0: timers.write_TM2CNT_L(address, data); break;
            case TM2CNT_L    + 1: timers.write_TM2CNT_L(address, data); break;
            case TM2CNT_H    + 0: timers.write_TM2CNT_H(address, data); break;
            case TM2CNT_H    + 1: timers.write_TM2CNT_H(address, data); break;
            case TM3CNT_L    + 0: timers.write_TM3CNT_L(address, data); break;
            case TM3CNT_L    + 1: timers.write_TM3CNT_L(address, data); break;
            case TM3CNT_H    + 0: keyinput.write_TM3CNT_H(address, data); break;
            case TM3CNT_H    + 1: keyinput.write_TM3CNT_H(address, data); break;
            case KEYINPUT    + 0: keyinput.write_KEYINPUT(address, data); break;
            case KEYINPUT    + 1: keyinput.write_KEYINPUT(address, data); break;
            case KEYCNT      + 0: interrupt.write_KEYCNT(address, data); break;
            case KEYCNT      + 1: interrupt.write_KEYCNT(address, data); break;
            case IE          + 0: interrupt.write_IE(address, data); break;
            case IE          + 1: interrupt.write_IE(address, data); break;
            case IF          + 0: interrupt.write_IF(address, data); break;
            case IF          + 1: interrupt.write_IF(address, data); break;
            case IME         + 0: interrupt.write_IME(address, data); break;
            case IME         + 1: interrupt.write_IME(address, data); break;
            case SOUND3CNT_H + 0: apu.write_SOUND3CNT_H(address, data); break;
            case SOUND3CNT_H + 1: apu.write_SOUND3CNT_H(address, data); break;
            case SOUND3CNT_X + 0: apu.write_SOUND3CNT_X(address, data); break;
            case SOUND3CNT_X + 1: apu.write_SOUND3CNT_X(address, data); break;
            case SOUND4CNT_L + 0: apu.write_SOUND4CNT_L(address, data); break;
            case SOUND4CNT_L + 1: apu.write_SOUND4CNT_L(address, data); break;
            case SOUND4CNT_H + 0: apu.write_SOUND4CNT_H(address, data); break;
            case SOUND4CNT_H + 1: apu.write_SOUND4CNT_H(address, data); break;
            case SOUNDCNT_L  + 0: apu.write_SOUNDCNT_L(address, data); break;
            case SOUNDCNT_L  + 1: apu.write_SOUNDCNT_L(address, data); break;
            case SOUNDCNT_H  + 0: apu.write_SOUNDCNT_H(address, data); break;
            case SOUNDCNT_H  + 1: apu.write_SOUNDCNT_H(address, data); break;
            case SOUNDCNT_X  + 0: apu.write_SOUNDCNT_X(address, data); break;
            case SOUNDCNT_X  + 1: apu.write_SOUNDCNT_X(address, data); break;
            case SOUNDBIAS   + 0: apu.write_SOUNDBIAS(address, data); break;
            case SOUNDBIAS   + 1: apu.write_SOUNDBIAS(address, data); break;

            case DMA0SAD     + 0: dma.write_DMA0SAD(address, data); break;
            case DMA0SAD     + 1: dma.write_DMA0SAD(address, data); break;
            case DMA0SAD     + 2: dma.write_DMA0SAD(address, data); break;
            case DMA0SAD     + 3: dma.write_DMA0SAD(address, data); break;
            case DMA0DAD     + 0: dma.write_DMA0DAD(address, data); break;
            case DMA0DAD     + 1: dma.write_DMA0DAD(address, data); break;
            case DMA0DAD     + 2: dma.write_DMA0DAD(address, data); break;
            case DMA0DAD     + 3: dma.write_DMA0DAD(address, data); break;
            case DMA0CNT_L   + 0: dma.write_DMA0CNT_L(address, data); break;
            case DMA0CNT_L   + 1: dma.write_DMA0CNT_L(address, data); break;
            case DMA0CNT_H   + 0: dma.write_DMA0CNT_H(address, data); break;
            case DMA0CNT_H   + 1: dma.write_DMA0CNT_H(address, data); break;
            case DMA1SAD     + 0: dma.write_DMA1SAD(address, data); break;
            case DMA1SAD     + 1: dma.write_DMA1SAD(address, data); break;
            case DMA1SAD     + 2: dma.write_DMA1SAD(address, data); break;
            case DMA1SAD     + 3: dma.write_DMA1SAD(address, data); break;
            case DMA1DAD     + 0: dma.write_DMA1DAD(address, data); break;
            case DMA1DAD     + 1: dma.write_DMA1DAD(address, data); break;
            case DMA1DAD     + 2: dma.write_DMA1DAD(address, data); break;
            case DMA1DAD     + 3: dma.write_DMA1DAD(address, data); break;
            case DMA1CNT_L   + 0: dma.write_DMA1CNT_L(address, data); break;
            case DMA1CNT_L   + 1: dma.write_DMA1CNT_L(address, data); break;
            case DMA1CNT_H   + 0: dma.write_DMA1CNT_H(address, data); break;
            case DMA1CNT_H   + 1: dma.write_DMA1CNT_H(address, data); break;
            case DMA2SAD     + 0: dma.write_DMA2SAD(address, data); break;
            case DMA2SAD     + 1: dma.write_DMA2SAD(address, data); break;
            case DMA2SAD     + 2: dma.write_DMA2SAD(address, data); break;
            case DMA2SAD     + 3: dma.write_DMA2SAD(address, data); break;
            case DMA2DAD     + 0: dma.write_DMA2DAD(address, data); break;
            case DMA2DAD     + 1: dma.write_DMA2DAD(address, data); break;
            case DMA2DAD     + 2: dma.write_DMA2DAD(address, data); break;
            case DMA2DAD     + 3: dma.write_DMA2DAD(address, data); break;
            case DMA2CNT_L   + 0: dma.write_DMA2CNT_L(address, data); break;
            case DMA2CNT_L   + 1: dma.write_DMA2CNT_L(address, data); break;
            case DMA2CNT_H   + 0: dma.write_DMA2CNT_H(address, data); break;
            case DMA2CNT_H   + 1: dma.write_DMA2CNT_H(address, data); break;
            case DMA3SAD     + 0: dma.write_DMA3SAD(address, data); break;
            case DMA3SAD     + 1: dma.write_DMA3SAD(address, data); break;
            case DMA3SAD     + 2: dma.write_DMA3SAD(address, data); break;
            case DMA3SAD     + 3: dma.write_DMA3SAD(address, data); break;
            case DMA3DAD     + 0: dma.write_DMA3DAD(address, data); break;
            case DMA3DAD     + 1: dma.write_DMA3DAD(address, data); break;
            case DMA3DAD     + 2: dma.write_DMA3DAD(address, data); break;
            case DMA3DAD     + 3: dma.write_DMA3DAD(address, data); break;
            case DMA3CNT_L   + 0: dma.write_DMA3CNT_L(address, data); break;
            case DMA3CNT_L   + 1: dma.write_DMA3CNT_L(address, data); break;
            case DMA3CNT_H   + 0: dma.write_DMA3CNT_H(address, data); break;
            case DMA3CNT_H   + 1: dma.write_DMA3CNT_H(address, data); break;

            case TM0CNT_L    + 0: timers.write_TM0CNT_L(address, data); break;
            case TM0CNT_L    + 1: timers.write_TM0CNT_L(address, data); break;
            case TM0CNT_H    + 0: timers.write_TM0CNT_H(address, data); break;
            case TM0CNT_H    + 1: timers.write_TM0CNT_H(address, data); break;
            case TM1CNT_L    + 0: timers.write_TM1CNT_L(address, data); break;
            case TM1CNT_L    + 1: timers.write_TM1CNT_L(address, data); break;
            case TM1CNT_H    + 0: timers.write_TM1CNT_H(address, data); break;
            case TM1CNT_H    + 1: timers.write_TM1CNT_H(address, data); break;
            case TM2CNT_L    + 0: timers.write_TM2CNT_L(address, data); break;
            case TM2CNT_L    + 1: timers.write_TM2CNT_L(address, data); break;
            case TM2CNT_H    + 0: timers.write_TM2CNT_H(address, data); break;
            case TM2CNT_H    + 1: timers.write_TM2CNT_H(address, data); break;
            case TM3CNT_L    + 0: timers.write_TM3CNT_L(address, data); break;
            case TM3CNT_L    + 1: timers.write_TM3CNT_L(address, data); break;
            case TM3CNT_H    + 0: timers.write_TM3CNT_H(address, data); break;
            case TM3CNT_H    + 1: timers.write_TM3CNT_H(address, data); break;

            case KEYCNT      + 0: keyinput.write_KEYCNT(address, data); break;
            case KEYCNT      + 1: keyinput.write_KEYCNT(address, data); break;
            
            case IE          + 0: interrupt.write_IE(address, data); break;
            case IE          + 1: interrupt.write_IE(address, data); break;
            case IF          + 0: interrupt.write_IF(address, data); break;
            case IF          + 1: interrupt.write_IF(address, data); break;
            case IME         + 0: interrupt.write_IME(address, data); break;
            case IME         + 1: interrupt.write_IME(address, data); break;
        }
    }
}