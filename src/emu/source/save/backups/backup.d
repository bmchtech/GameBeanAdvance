module save.backups.backup;

import std.mmfile;

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
    int        get_backup_size()        { return 0; }

    MmFile backup_file;
    void set_backup_file(MmFile backup_file) { 
        this.backup_file = backup_file;
    }
}

enum BackupType {
    FLASH,
    SRAM,
    NONE
}