module save.backups.sram;

import save.backups;

import std.stdio;

final class SRAM : Backup {
    private ubyte[] data;
    private uint address_mask;

    this(uint size) {
        assert((size & (size - 1)) == 0); // size must be a power of 2

        this.data = new ubyte[size];
        this.address_mask = size - 1;
    }

    override uint read_word(uint address) { 
        ubyte read_data = read(address);
        return (read_data << 24) | (read_data << 16) | (read_data << 8) | read_data;
    }

    override ushort read_half(uint address) { 
        ubyte read_data = read(address);
        return (read_data << 8) | read_data;
    }

    override ubyte read_byte(uint address) { 
        return read(address);
    }

    override void write_word(uint address, uint data) { 
        ubyte written_data = data & 0xFF;
        write(address, written_data); 
        write(address | 1, written_data); 
        write(address | 2, written_data); 
        write(address | 3, written_data); 
    }

    override void write_half(uint address, ushort data) { 
        ubyte written_data = data & 0xFF;
        write(address, written_data); 
        write(address | 1, written_data); 
    }

    override void write_byte(uint address, ubyte data) { 
        write(address, data);
    }

    override ubyte[] serialize() { 
        return data;
    }

    override void deserialize(ubyte[] data) { 
        this.data = data; 
    }

    override BackupType get_backup_type() { 
        return BackupType.SRAM; 
    }

    private ubyte read(uint address) {
        return this.data[address & address_mask];
    }

    private void write(uint address, ubyte data) {
        this.data[address & address_mask] = data;
    }
}