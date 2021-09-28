module save.backups.backup;

class Backup {
    T    read(T) (uint address)         { return 0x0;}
    void write(T)(uint address, T data) { return; }

    ubyte[] serialize()                 { return [];}
    void    deserialize(ubyte[] data)   { return; }
}