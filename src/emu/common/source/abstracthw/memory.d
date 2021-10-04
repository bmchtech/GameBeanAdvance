module abstracthw.memory;

enum Region {
    BIOS = 0x0,
    WRAM_BOARD = 0x2,
    WRAM_CHIP = 0x3,
    IO_REGISTERS = 0x4,
    PALETTE_RAM = 0x5,
    VRAM = 0x6,
    OAM = 0x7,

    ROM_WAITSTATE_0_L = 0x8,
    ROM_WAITSTATE_0_H = 0x9,
    ROM_WAITSTATE_1_L = 0xA,
    ROM_WAITSTATE_1_H = 0xB,
    ROM_WAITSTATE_2_L = 0xC,
    ROM_WAITSTATE_2_H = 0xD,
    ROM_SRAM_L = 0xE,
    ROM_SRAM_H = 0xF,
}

enum SIZE_BIOS = 0x4000;
enum SIZE_WRAM_BOARD = 0x40000;
enum SIZE_WRAM_CHIP = 0x8000;
enum SIZE_PALETTE_RAM = 0x400;
enum SIZE_VRAM = 0x18000;
enum SIZE_OAM = 0x400;
enum SIZE_ROM = 0x2000000;

enum OFFSET_BIOS = 0x0000000;
enum OFFSET_WRAM_BOARD = 0x2000000;
enum OFFSET_WRAM_CHIP = 0x3000000;
enum OFFSET_IO_REGISTERS = 0x4000000;
enum OFFSET_PALETTE_RAM = 0x5000000;
enum OFFSET_VRAM = 0x6000000;
enum OFFSET_OAM = 0x7000000;
enum OFFSET_ROM_1 = 0x8000000;
enum OFFSET_ROM_2 = 0xA000000;
enum OFFSET_ROM_3 = 0xC000000;
enum OFFSET_SRAM = 0xE000000;

bool can_read_from_bios = false;

enum OpenBusBiosState {
    STARTUP,
    SOFT_RESET,
    DURING_IRQ,
    AFTER_IRQ,
    AFTER_SWI
}

OpenBusBiosState open_bus_bios_state = OpenBusBiosState.STARTUP;

enum AccessType {
    NONSEQUENTIAL = 0,
    SEQUENTIAL = 1
}

enum AccessSize {
    BYTE = 0,
    HALFWORD = 1,
    WORD = 2
}

interface IMemory {
    ubyte read_byte(uint address, AccessType access_type = AccessType.SEQUENTIAL);
    ushort read_halfword(uint address, AccessType access_type = AccessType.SEQUENTIAL);
    pragma(inline, true) uint read_word(uint address, AccessType access_type = AccessType
            .SEQUENTIAL);

    pragma(inline, true) void write_byte(uint address, ubyte value,
            AccessType access_type = AccessType.SEQUENTIAL);
    void write_halfword(uint address, ushort value, AccessType access_type = AccessType.SEQUENTIAL);
    pragma(inline, true) void write_word(uint address, uint value,
            AccessType access_type = AccessType.SEQUENTIAL);
}
