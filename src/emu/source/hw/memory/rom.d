module hw.memory.rom;

import std.stdio;

class ROM {
    const ushort[] data;
    const uint    rom_mask;

    this(ubyte[] data, uint rom_mask) {
        this.data     = cast(ushort[]) data;
        this.rom_mask = rom_mask;
    }

    ushort read(uint address) {
        if (address & (0xFF_FFFF ^ rom_mask)) return calculate_unmapped_rom_value(address);
        return data[address & rom_mask];
    }

    // https://problemkaputt.de/gbatek.htm#gbaunpredictablethings
    pragma(inline, true) ushort calculate_unmapped_rom_value(uint address) {
        return address & 0xFFFF;
    }

    ubyte[] get_bytes() {
        return cast(ubyte[]) data;
    }
}