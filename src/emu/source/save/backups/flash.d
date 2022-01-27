module save.backups.flash;

import save;
import util;

import std.stdio;
import core.stdc.string;

final class Flash : Backup {
    // https://mgba-emu.github.io/gbatek/#gbacartbackupflashrom
    // for more context on what these two constants represent
    // i can't for the life of me come up with a better name so
    // the gist is that these addresses should be written to in
    // series to execute a command.
    enum uint[] COMMAND_ADDRESS = [0x5555, 0x2AAA, 0x5555];
    enum uint[] COMMAND_HEADER  = [0xAA, 0x55];

    enum State {
        WAITING_FOR_COMMAND,       // waiting for COMMAND_ADDRESS[0] to be written to

        RECEIVING_COMMAND_0,       // after COMMAND_ADDRESS[0] has been written to
        RECEIVING_COMMAND_1,       // after COMMAND_ADDRESS[1] has been written to

        BANK_SWITCHING,            // allows you to switch the bank number
        WRITING_SINGLE_BYTE
    }

    // thanks Dillon! :) https://dillonbeliveau.com/2020/06/05/GBA-FLASH.html
    enum Command {
        ENTER_IDENTIFICATION = 0x90,
        EXIT_IDENTIFICATION  = 0xF0,

        PREPARE_ERASE        = 0x80,
        ERASE_ENTIRE_CHIP    = 0x10,
        ERASE_SECTOR         = 0x30,
        
        WRITE_SINGLE_BYTE    = 0xA0,
        SET_MEMORY_BANK      = 0xB0
    }

    ubyte[] all_data;
    ubyte*  accessible_data;

    ubyte manufacturer_id;
    ubyte device_id;

    this(int total_size, bool banked, int num_banks, ubyte manufacturer_id, ubyte device_id) {
        this.sector_size     = 4096;
        this.total_size      = total_size;
        this.banked          = banked;
        this.bank            = 0;
        this.bank_size       = total_size / num_banks;
        this.identification  = false;

        this.manufacturer_id = manufacturer_id;
        this.device_id       = device_id;

        all_data = new ubyte[total_size];
        accessible_data = &all_data[0];
        erase_entire_chip();
    }

    override void write_byte(uint address, ubyte data) {
        address &= 0xFFFF;
        final switch (state) {
            case State.WAITING_FOR_COMMAND: handle_command_header_0(address, data); break;
            case State.RECEIVING_COMMAND_0: handle_command_header_1(address, data); break;
            case State.RECEIVING_COMMAND_1: handle_command_data    (address, data); break;

            case State.BANK_SWITCHING:      handle_bank_switching  (address, data); break;
            case State.WRITING_SINGLE_BYTE: write_single_byte      (address, data); break;
        }
    }

    override ubyte read_byte(uint address) {
        address &= 0xFFFF;
        if (identification) {
            if (address == 0) return this.manufacturer_id;
            if (address == 1) return this.device_id;
            return 0x0;
        } else {
            return accessible_data[address];
        }
    }

    override ubyte[] serialize() {
        return all_data;
    }

    override void deserialize(ubyte[] data) {
        this.all_data = data;
    }

    override BackupType get_backup_type() {
        return BackupType.FLASH;
    }

    override int get_backup_size() {
        return total_size;
    }

    private void handle_command_header_0(uint address, uint data) {
        if (address == COMMAND_ADDRESS[0] && data == COMMAND_HEADER[0]) 
            state = State.RECEIVING_COMMAND_0;
    }

    private void handle_command_header_1(uint address, uint data) {
        if (address == COMMAND_ADDRESS[1] && data == COMMAND_HEADER[1]) 
            state = State.RECEIVING_COMMAND_1;
    }

    private void handle_command_data(uint address, uint data) {
        switch (cast(Command) data) {
            case Command.ENTER_IDENTIFICATION:
                identification = true;
                state = State.WAITING_FOR_COMMAND; break;
            
            case Command.EXIT_IDENTIFICATION:
                identification = false;
                state = State.WAITING_FOR_COMMAND; break;
            
            case Command.PREPARE_ERASE:
                preparing_erase = true;
                state = State.WAITING_FOR_COMMAND; break;
            
            case Command.ERASE_ENTIRE_CHIP:
                if (preparing_erase)
                    erase_entire_chip();
                preparing_erase = false;
                state = State.WAITING_FOR_COMMAND;
                break;
            
            case Command.ERASE_SECTOR:
                if (preparing_erase)
                    erase_sector(get_nth_bits(address, 12, 16));
                preparing_erase = false;
                state = State.WAITING_FOR_COMMAND;
                break;
            
            case Command.SET_MEMORY_BANK:
                state = State.BANK_SWITCHING;
                break;

            case Command.WRITE_SINGLE_BYTE:
                state = State.WRITING_SINGLE_BYTE;
                break;
            
            default: break;
        }
    }

    private void handle_bank_switching(uint address, uint data) {
        this.bank = data & 1;
        this.accessible_data = &this.all_data[bank * bank_size];
        state = State.WAITING_FOR_COMMAND;
    }

    private void write_single_byte(uint address, ubyte data) {
        this.accessible_data[address] = data;
        state = State.WAITING_FOR_COMMAND;

        backup_file[address + bank * bank_size] = data;
    }

    private void erase_entire_chip() {
        memset(cast(void*) all_data, 0xFF, total_size);
    }

    private void erase_sector(int sector) {
        memset(cast(void*) &accessible_data[sector * sector_size], 0xFF, sector_size);
    }

    private int total_size;
    private int sector_size;
    private int bank_size;
    private bool banked;
    private int bank;

    private State state;
    private bool preparing_erase;
    private bool identification;
}