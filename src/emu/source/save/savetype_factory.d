module save.savetype_factory;

// import chip;

class NoSavetypeException : Exception {
    this() {
        super();
    }
}

public Save create_savetype(Savetype savetype) {
    final switch (savetype) {
        case EEPROM_4k:                throw new NoSavetypeException();             
        case EEPROM_4k_alt:            throw new NoSavetypeException();
        case EEPROM_8k:                throw new NoSavetypeException();
        case EEPROM_8k_alt:            throw new NoSavetypeException();
        case Flash_512k_Atmel_RTC:     return new Flash(65536,     false);
        case Flash_512k_Atmel:         return new Flash(65536,     false);
        case Flash_512k_SST_RTC:       return new Flash(65536,     false);
        case Flash_512k_SST:           return new Flash(65536,     false);
        case Flash_512k_Panasonic_RTC: return new Flash(65536,     false);
        case Flash_512k_Panasonic:     return new Flash(65536,     false);
        case Flash_1M_Macronix_RTC:    return new Flash(65536,     false);
        case Flash_1M_Macronix:        return new Flash(65536 * 2, true);
        case Flash_1M_Sanyo_RTC:       return new Flash(65536 * 2, true);
        case Flash_1M_Sanyo:           return new Flash(65536 * 2, true);
        case SRAM_256K:                throw new NoSavetypeException();
        case NONE:                     throw new NoSavetypeException();
        case UNKNOWN:                  throw new NoSavetypeException();
    }
}