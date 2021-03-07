module arm7tdmi;

version (!(ARM7TDMI_H)) {
    version = ARM7TDMI_H;

    class ARM7TDMI {
        //friend void error(int message
        );
        int[] memory;
        static const(int) MODE_USER;
        static const(int) MODE_SYSTEM;
        static const(int) MODE_SUPERVISOR;
        static const(int) MODE_ABORT;
        static const(int) MODE_UNDEFINED;
        static const(int) MODE_IRQ;
        static const(int) MODE_FIQ;
        static const(int) NUM_MODES = 7;
        static int[7] MODES;
        final void set_mode(const(int) new_mode) {
            int mask;
            for (int i = 0; i < 16; i++) {
                if (mask & 1) {
                }

                mask >>= 1;
            }

        }

        int[] register_file;
        int[] regs;
        int[] pc;
        int[] lr;
        int[] sp;
        int cpsr;
        int spsr;
        int shifter_operand;
        bool shifter_carry_out;
        final void set_flag_N(bool condition) {
        }

        final void set_flag_Z(bool condition) {
        }

        final void set_flag_C(bool condition) {
        }

        final void set_flag_V(bool condition) {
        }

        final void set_bit_T(bool condition) {
        }

        final bool get_flag_N() {
        }

        final bool get_flag_Z() {
        }

        final bool get_flag_C() {
        }

        final bool get_flag_V() {
        }

        final bool get_bit_T() {
        }

        final const(int) ASR(int value, int shift) {
            if ( /*OpaqueValueExpr Stmt*/ ) {
                // breakdown of this formula:
                // value >> 31                                                         : the most significant bit
                // (value >> 31) << shift)                                             : the most significant bit, but shifted "shift" times
                // ((((value >> 31) << shift) - 1)                                     : the most significant bit, but repeated "shift" times
                // ((((value >> 31) << shift) - 1) << (32 - shift))                    : basically this value is the mask that turns the logical 
                //                                                                     : shift to an arithmetic shift
                // ((((value >> 31) << shift) - 1) << (32 - shift)) | (value >> shift) : the arithmetic shift
                return (((1 << shift) - 1) << (32 - shift)) | (value >> shift);
            } else {
            }

        }

        final const(int) LSL(int value, int shift) {
        }

        final const(int) LSR(int value, int shift) {
        }

        final const(int) ROR(int value, int shift) {
            int rotated_off;
            // the value that is rotated off
            int rotated_in;
            // the value that stays after the rotation
            return rotated_in | (rotated_off << (32 - shift));
        }

        final int RRX(ARM7TDMI cpu, int value, int shift) {
            int rotated_off;
            // the value that is rotated off
            int rotated_in;
            // the value that stays after the rotation

            int result;
        }

        int cycles_remaining = ;
    private:
        int current_mode;
        int[1] cpu_states;
        int cpu_states_size = 0;
        bool enable_pc_checking = false;
        int setup_cycles = 200000;
    }
