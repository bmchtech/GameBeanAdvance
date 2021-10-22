module save.backups.backup;

class Backup {
    uint   read_word     (uint address)              { return 0x0;}
    ushort read_halfword (uint address)              { return 0x0;}
    ubyte  read_byte     (uint address)              { return 0x0;}
    void   write_word    (uint address, uint data)   { return; }
    void   write_halfword(uint address, ushort data) { return; }
    void   write_byte    (uint address, ubyte data)  { return; }

    ubyte[] serialize()                 { return [];}
    void    deserialize(ubyte[] data)   { return; }

    BackupType get_backup_type()        { return BackupType.NONE; }
}

enum BackupType {
    FLASH,
    SRAM,
    NONE
}