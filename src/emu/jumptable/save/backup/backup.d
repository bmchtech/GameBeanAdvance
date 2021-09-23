module backup.backup;

abstract class Backup {
    abstract T    read(T) (uint address);
    abstract void write(T)(uint address, T data);

    abstract ubyte[] serialize();
    abstract void    deserialize(ubyte[] data);
}