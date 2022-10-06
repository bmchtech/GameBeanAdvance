module hw.memory.rom;

import std.stdio;
import util;

final class ROM {
    ushort[] data;
    uint     rom_mask;
    bool     mirrored;

    this(ubyte[] rom_data) {
        ulong num_bytes     = rom_data.length;
        ulong num_halfs = num_bytes / 2;

        uint rom_mask_size = 0;
        while (num_halfs > 1) {
            num_halfs >>= 1;
            rom_mask_size++;
        }

        uint rom_length = 1 << (rom_mask_size + 1);
        this.rom_mask = rom_length - 1;
        data = new ushort[rom_length];

        // this.data = new ushort[this.rom_mask + 1];
        for (int i = 0; i < rom_data.length / 2; i++) {
            this.data[i] = (cast(ushort[]) rom_data)[i];
        }

        this.mirrored = false;

    }

    ushort read(uint address) {
        if (mirrored) {
            return data[address & rom_mask];
        } else {
            if (address & ~rom_mask) {
                return calculate_unmapped_rom_value(address);
            } else {
                return data[address];
            }
        }
    }

    // https://problemkaputt.de/gbatek.htm#gbaunpredictablethings
    pragma(inline, true) ushort calculate_unmapped_rom_value(uint address) {
        return address & 0xFFFF;
    }

    ubyte[] get_bytes() {
        return cast(ubyte[]) data;
    }
}