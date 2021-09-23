module save.backup.flash;

class Flash : Backup {
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

        IDENTIFICATION,            // chip identification mode, returns device ID / manufacturer
        BANK_SWITCHING,            // allows you to switch the bank number
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

    this(int num_sectors, int sector_size) {
        this.num_sectors = num_sectors;
        this.sector_size = sector_size;
    }

    override void write(T)(uint address, T data) {
        static if (data != )
        final switch (state) {
            case WAITING_FOR_COMMAND: handle_command_header_0(address, data);
            case RECEIVING_COMMAND_0: handle_command_header_1(address, data);
            case RECEIVING_COMMAND_1: handle_command_data    (address, data);

            case IDENTIFICATION:      return;
            case BANK_SWITCHING:      handle_bank_switching  (address, data);
        }
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
        final switch (cast(Command) data) {
            case Command.ENTER_IDENTIFICATION:
                state = State.IDENTIFICATION; break;
            
            case Command.EXIT_IDENTIFICATION:
                state = State.WAITING_FOR_COMMAND; break;
            
            case Command.PREPARE_ERASE:
                preparing_erase = true;
                state = State.WAITING_FOR_COMMAND; break;
            
            case Command.ERASE_ENTIRE_CHIP:
                if (preparing_erase)
                    erase_entire_chip();
                preparing_erase = false;
                break;
            
            case Command.ERASE_SECTOR:
                if (preparing_erase)
                    erase_sector()
            
            case Command.SET_MEMORY_BANK:
                state = State.BANK_SWITCHING;
                break;
        }
    }

    private void handle_bank_switching(uint address, uint data) {
        if (address == 0) bank = data & 1;
    }

    private int num_sectors;
    private int sector_size;
    private int bank;

    private State state;
    private bool preparing_erase;
}