module hw.sio.sio;

import scheduler;
import util;
import hw.interrupts;

class SIO {
    bool shift_clock;
    bool internal_shift_clock;
    bool si_state;
    bool so_during_inactivity;
    bool start_bit;
    bool transfer_length;
    bool irq_enable;

    uint num_bits_to_transfer;

    void delegate(uint) interrupt_cpu;
    Scheduler scheduler;

    this(void delegate(uint) interrupt_cpu, Scheduler scheduler) {
        this.interrupt_cpu = interrupt_cpu;
        this.scheduler     = scheduler;

        this.num_bits_to_transfer = 0;
    }

    void write_SIOCNT(uint target_byte, ubyte data) {
        final switch (target_byte) {
            case 0b0:
                this.shift_clock          = get_nth_bit(data, 0);
                this.internal_shift_clock = get_nth_bit(data, 1);
                this.si_state             = get_nth_bit(data, 2);
                this.so_during_inactivity = get_nth_bit(data, 3);
                this.start_bit            = get_nth_bit(data, 7);

                if (this.start_bit) start_transfer();
                break;
            
            case 0b1:
                this.transfer_length      = get_nth_bit(data, 0);
                this.irq_enable           = get_nth_bit(data, 6);
                break;
        }
    }

    ubyte read_SIOCNT(uint target_byte) {
        final switch (target_byte) {
            case 0b0:
                return cast(ubyte) 
                    (this.shift_clock          << 0) |
                    (this.internal_shift_clock << 1) |
                    (this.si_state             << 2) |
                    (this.so_during_inactivity << 3) |
                    (this.start_bit            << 7);

            case 0b1:            
                return cast(ubyte) 
                    (this.transfer_length      << 0) |
                    (this.irq_enable           << 6);
        }
    }

    void start_transfer() {
        this.num_bits_to_transfer = this.transfer_length ? 32 : 8;
        schedule_next_value();
    }

    void schedule_next_value() {
        uint cpu_frequency = 16780000;
        uint cycles_to_wait = cpu_frequency / (this.internal_shift_clock ? 2000000 : 256000);
        scheduler.add_event_relative_to_clock(&transfer_one_value, cycles_to_wait);
    }

    void transfer_one_value() {
        this.num_bits_to_transfer--;

        if (this.num_bits_to_transfer > 0) {
            this.start_bit = false;
            schedule_next_value();
        } else {
            if (irq_enable) {
                interrupt_cpu(Interrupt.SERIAL_COMMUNICATION);
            }
        }
    }
}