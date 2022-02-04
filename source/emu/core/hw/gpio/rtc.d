module hw.gpio.rtc;

import util;
import std.datetime;

class RTC_S_35180 {
    bool SCK;
    bool SIO;
    bool CS;

    ubyte serial_data;
    int   serial_index;

    ubyte* active_register;
    ubyte  status_register_2;
    ubyte  date_time_year;
    ubyte  date_time_month;
    ubyte  date_time_day;
    ubyte  date_time_day_of_week;
    ubyte  date_time_hh;
    ubyte  date_time_mm;
    ubyte  date_time_ss;

    int current_command_index;
    int current_register_index;

    enum State {
        WAITING_FOR_COMMAND,
        RECEIVING_COMMAND,
        READING_PARAMETERS,
        WRITING_REGISTER
    }

    struct CommandData {
        ubyte*[] registers;
    }
    CommandData[] commands;

    State state;

    this() {
        reset();
        init_commands();
    }

    void init_commands() {
        commands = [
            CommandData([]),
            CommandData([&status_register_2]),
            CommandData([&date_time_year,
                         &date_time_month,
                         &date_time_day,
                         &date_time_day_of_week,
                         &date_time_hh,
                         &date_time_mm,
                         &date_time_ss]),
            CommandData([&date_time_hh,
                         &date_time_mm,
                         &date_time_ss]),
            CommandData([]),
            CommandData([]),
            CommandData([]),
            CommandData([]),
        ];
    }

    import std.stdio;
    void write(ubyte value) {

        bool old_SCK = SCK;
        bool old_SIO = SIO;
        bool old_CS  = CS;

        SCK = get_nth_bit(value, 0); 
        SIO = get_nth_bit(value, 1); 
        CS  = get_nth_bit(value, 2); 
    
        if (rising_edge(old_CS, CS)) {
            this.state = State.RECEIVING_COMMAND;
        }

        if (falling_edge(old_CS, CS)) {
            this.state = State.WAITING_FOR_COMMAND;
        }

        if (rising_edge(old_SCK, SCK) && state != State.WAITING_FOR_COMMAND) {
            
            switch (state) {
                case State.READING_PARAMETERS:
                    SIO = get_nth_bit(*this.get_active_register(), this.serial_index); 
                    serial_index++;

                    if (this.serial_index == 8) {
                        this.serial_index = 0; 
                        advance_current_register_value();
                    }
                    
                    break;

                case State.WRITING_REGISTER:
                    auto old_value = *this.get_active_register();
                    old_value &= ~(1 << this.serial_index);
                    old_value |= (SIO << this.serial_index);

                    *this.get_active_register() = old_value; 
                    serial_index++;

                    if (this.serial_index == 8) {
                        this.serial_index = 0; 
                        advance_current_register_value();
                    }

                    break;
                case State.RECEIVING_COMMAND:
                    this.serial_data |= (SIO << this.serial_index);

                    serial_index++;

                    // last serial transfer?
                    if (this.serial_index == 8) {
                        this.serial_index = 0;

                        if (!is_command(this.serial_data)) {
                            import core.bitop;
                            this.serial_data = bitswap((cast(uint) this.serial_data) << 24) & 0xFF;
                        }

                        this.state = get_nth_bit(this.serial_data, 0) ?
                            State.READING_PARAMETERS :
                            State.WRITING_REGISTER;

                        auto command = get_nth_bits(this.serial_data, 1, 4);
                        handle_command(command);
                        this.serial_data = 0;
                    }
                    break;
                default: break;
            }
        }
    }

    ubyte to_bcd(int input) {
        // assumes 2 digits in input
        auto digit_1 = input / 10;
        auto digit_2 = input % 10;
        return cast(ubyte) ((digit_1 << 4) | digit_2);
    }

    bool is_command(ubyte data) {
        return get_nth_bits(data, 4, 8) == 6;
    }

    void advance_current_register_value() {
        auto current_command = commands[current_command_index];

        if (current_register_index + 1 >= current_command.registers.length) {
            current_register_index = 0;
            state = State.WAITING_FOR_COMMAND;
            return;
        }

        auto next_register = current_command.registers[current_register_index + 1];

        set_active_register_value(next_register);
        current_register_index++;
    }

    void set_active_register_value(ubyte* register) {
        this.active_register = register;
    }

    ubyte* get_active_register() {
        return this.active_register;
    }

    void handle_command(int command) {
        switch (command) {
            case 0: reset(); break;

            default:
                reset_time();
                this.current_command_index  = command;
                this.current_register_index = 0;
                set_active_register_value(commands[command].registers[0]);
        }
    }

    void reset_time() {
        auto st = Clock.currTime();
        this.date_time_year        = to_bcd(st.year - 2000);
        this.date_time_month       = to_bcd(st.month);
        this.date_time_day         = to_bcd(st.day);
        this.date_time_day_of_week = to_bcd(st.dayOfWeek);
        this.date_time_hh          = to_bcd(st.hour);
        this.date_time_mm          = to_bcd(st.minute);
        this.date_time_ss          = to_bcd(st.second);
    }

    void reset() {
        state = State.WAITING_FOR_COMMAND;

        this.SCK = false;
        this.SIO = false;
        this.CS  = false;

        this.serial_data  = 0;
        this.serial_index = 0;

        this.current_command_index  = 0;
        this.current_register_index = 0;
        
        reset_time();

        set_active_register_value(&status_register_2);
        status_register_2 = 0;
    }

    bool rising_edge (bool old_value, bool new_value) { return !old_value  &&  new_value; }
    bool falling_edge(bool old_value, bool new_value) { return  old_value  && !new_value; }

    ubyte read() {
        return (SCK << 2) | (SIO << 1) | CS;
    }
}