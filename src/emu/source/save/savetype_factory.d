module save.savetype_factory;

import save;
import util;

public Backup create_savetype(Savetype savetype) {
    switch (savetype) {
        case Savetype.Flash_512k_Atmel_RTC:     return new Flash(65536,     false, 1, 0x32, 0x1B);
        case Savetype.Flash_512k_Atmel:         return new Flash(65536,     false, 1, 0x32, 0x1B);
        case Savetype.Flash_512k_SST_RTC:       return new Flash(65536,     false, 1, 0x32, 0x1B);
        case Savetype.Flash_512k_SST:           return new Flash(65536,     false, 1, 0x32, 0x1B);
        case Savetype.Flash_512k_Panasonic_RTC: return new Flash(65536,     false, 1, 0x32, 0x1B);
        case Savetype.Flash_512k_Panasonic:     return new Flash(65536,     false, 1, 0x32, 0x1B);
        case Savetype.Flash_1M_Macronix_RTC:    return new Flash(65536 * 2, true,  2, 0x62, 0x13);
        case Savetype.Flash_1M_Macronix:        return new Flash(65536 * 2, true,  2, 0x62, 0x13);
        case Savetype.Flash_1M_Sanyo_RTC:       return new Flash(65536 * 2, true,  2, 0x62, 0x13);
        case Savetype.Flash_1M_Sanyo:           return new Flash(65536 * 2, true,  2, 0x62, 0x13);
        case Savetype.SRAM_256K:                return new SRAM (32768);

        default: warning("Invalid savetype given"); return new Backup(); // this will never trigger when all saves are finally implemented
    }
}