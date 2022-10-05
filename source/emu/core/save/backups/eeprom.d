module save.backups.eeprom;

import save.backups;

import std.stdio;

import util;

final class EEPROM : Backup {
    private ubyte[] data;
    private uint address_mask;

    enum State {
        IDLE,
        READ,
        WRITE
    }

    int  index;
    long command;
    ubyte[8] write_buf;
    int  address;

    int address_length;

    State state = State.IDLE;

    uint size;

    bool first_write = true;

    this(uint size) {
        assert((size & (size - 1)) == 0); // size must be a power of 2

        if (size == 512) {
            address_length = 6;
        } else {
            address_length = 14;
        }

        this.data = new ubyte[size];
        this.address_mask = size - 1;
        this.size = size;
    }

    void idle() {
        this.index     = 0;
        this.command   = 0;
        this.address   = 0;
        this.state     = State.IDLE;

        write_buf[0..8] = 0;
    }

    import std.stdio;
    void write(int bit) {
        if (first_write) {
            first_write = false;
            for (int i = 0; i < size; i++) {
                this.data[i] = 0xFF;
                backup_file[i] = 0xFF;
            }
        }
        writefln("shitty bit %d. data: %d %d %d %s", bit, command, index, address, state);

        final switch (state) {
        case State.IDLE:  
            command |= bit << ((address_length + 1) - index++);
            if (index == address_length + 2) {
                if (((command >> address_length) & 3) == 2) {
                    state = State.WRITE;
                } else if (((command >> address_length) & 3) == 3) {
                    state = State.READ;
                } else {
                    error("invalid eeprom command");
                }

                address = cast(int) (command & ((1 << address_length) - 1)) * 8;

                writefln("calculating address as %d", address);
                index = 0;
            }
            break;

        case State.READ:
            break;
            
        case State.WRITE:
            if (index == 64) {
                writefln("writing to addresses %d to %d", address, address + 7);

                data[address .. address + 8] = write_buf[0 .. 8];
                
                // don't ask
                for (int i = 0; i < 8; i++) {
                    backup_file[address + i] = write_buf[i];
                }
                idle();
                break;
            }

            int byte_index = index / 8;
            int offset     = index % 8;
            write_buf[byte_index] |= bit << (7 - offset);
            index++;
            break;
        }
    }

    int read() {
        if (state != State.READ) {
            return 1;
        }

        if (index <= 3) {
            index++;
            writefln("reading uwu, returning dummy");
            return 0;
        }

        int byte_index = (index - 4) / 8;
        int offset     = (index - 4) % 8;
        writefln("reading uwu [%d], returning %d", index, (data[address + byte_index] >> (7 - offset)) & 1);

        index++;

        bool return_value = (data[address + byte_index] >> (7 - offset)) & 1;

        if (index == 68) {
            idle();
        }

        return return_value;
    }

    override uint read_word(uint address) { 
        return cast(uint) read();
    }

    override ushort read_half(uint address) { 
        return cast(ushort) read();
    }

    override ubyte read_byte(uint address) { 
        return cast(ubyte) read();
    }

    override void write_word(uint address, uint data) {
        write(data & 1);
    }

    override void write_half(uint address, ushort data) { 
        write(data & 1);
    }

    override void write_byte(uint address, ubyte data) {
        write(data & 1);
    }

    override ubyte[] serialize() { 
        return data;
    }

    override void deserialize(ubyte[] data) { 
        this.data = data;
    }

    override BackupType get_backup_type() { 
        return BackupType.EEPROM; 
    }

    private ubyte read(uint address) {
        return this.data[address & address_mask];
    }

    private void write(uint address, ubyte data) {
        this.data[address & address_mask] = data;
    }

    override int get_backup_size() {
        return size * 8;
    }
}