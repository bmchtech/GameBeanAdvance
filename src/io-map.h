#ifndef IO_MAP
#define IO_MAP

//      NAME       ADDRESS       SIZE  R/W   DESCRIPTION

#define DISPCNT    0x4000000    // 2   R/W   LCD Control
//#define -        0x4000002    // 2   R/W   Undocumented - Green Swap
#define DISPSTAT   0x4000004    // 2   R/W   General LCD Status (STAT,LYC)
#define VCOUNT     0x4000006    // 2   R     Vertical Counter (LY)
#define BG0CNT     0x4000008    // 2   R/W   BG0 Control
#define BG1CNT     0x400000A    // 2   R/W   BG1 Control
#define BG2CNT     0x400000C    // 2   R/W   BG2 Control
#define BG3CNT     0x400000E    // 2   R/W   BG3 Control
#define BG0HOFS    0x4000010    // 2   W     BG0 X-Offset
#define BG0VOFS    0x4000012    // 2   W     BG0 Y-Offset
#define BG1HOFS    0x4000014    // 2   W     BG1 X-Offset
#define BG1VOFS    0x4000016    // 2   W     BG1 Y-Offset
#define BG2HOFS    0x4000018    // 2   W     BG2 X-Offset
#define BG2VOFS    0x400001A    // 2   W     BG2 Y-Offset
#define BG3HOFS    0x400001C    // 2   W     BG3 X-Offset
#define BG3VOFS    0x400001E    // 2   W     BG3 Y-Offset
#define BG2PA      0x4000020    // 2   W     BG2 Rotation/Scaling Parameter A (dx)
#define BG2PB      0x4000022    // 2   W     BG2 Rotation/Scaling Parameter B (dmx)
#define BG2PC      0x4000024    // 2   W     BG2 Rotation/Scaling Parameter C (dy)
#define BG2PD      0x4000026    // 2   W     BG2 Rotation/Scaling Parameter D (dmy)
#define BG2X       0x4000028    // 4   W     BG2 Reference Point X-Coordinate
#define BG2Y       0x400002C    // 4   W     BG2 Reference Point Y-Coordinate
#define BG3PA      0x4000030    // 2   W     BG3 Rotation/Scaling Parameter A (dx)
#define BG3PB      0x4000032    // 2   W     BG3 Rotation/Scaling Parameter B (dmx)
#define BG3PC      0x4000034    // 2   W     BG3 Rotation/Scaling Parameter C (dy)
#define BG3PD      0x4000036    // 2   W     BG3 Rotation/Scaling Parameter D (dmy)
#define BG3X       0x4000038    // 4   W     BG3 Reference Point X-Coordinate
#define BG3Y       0x400003C    // 4   W     BG3 Reference Point Y-Coordinate
#define WIN0H      0x4000040    // 2   W     Window 0 Horizontal Dimensions
#define WIN1H      0x4000042    // 2   W     Window 1 Horizontal Dimensions
#define WIN0V      0x4000044    // 2   W     Window 0 Vertical Dimensions
#define WIN1V      0x4000046    // 2   W     Window 1 Vertical Dimensions
#define WININ      0x4000048    // 2   R/W   Inside of Window 0 and 1
#define WINOUT     0x400004A    // 2   R/W   Inside of OBJ Window & Outside of Windows
#define MOSAIC     0x400004C    // 2   W     Mosaic Size
#define BLDCNT     0x4000050    // 2   R/W   Color Special Effects Selection
#define BLDALPHA   0x4000052    // 2   R/W   Alpha Blending Coefficients
#define BLDY       0x4000054    // 2   W     Brightness (Fade-In/Out) Coefficient

#endif