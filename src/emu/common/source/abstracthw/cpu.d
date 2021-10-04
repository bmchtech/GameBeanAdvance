module abstracthw.cpu;

interface IARM7TDMI {
    uint read_reg(int reg);
    void write_reg(int reg, uint value);
    uint read_reg__lower(int reg);
    void write_reg__lower(int reg, uint value);
    void set_flag_N(bool condition);
    void set_flag_Z(bool condition);
    void set_flag_C(bool condition);
    void set_flag_V(bool condition);
    void set_bit_T(bool condition);
    bool get_flag_N();
    bool get_flag_Z();
    bool get_flag_C();
    bool get_flag_V();
    bool get_bit_T();

    uint LSL(uint value, ubyte shift);
    uint LSR(uint value, ubyte shift);
    uint ROR(uint value, ubyte shift);
    uint ASR(uint value, ubyte shift);
    uint ASL(uint value, ubyte shift);

    void refill_pipeline_partial();
    void refill_pipeline();
    void update_mode();

    @property uint* cpsr();
    @property uint* spsr();

    @property uint shifter_operand();
    @property uint shifter_operand(uint value);
    @property uint shifter_carry_out();
    @property uint shifter_carry_out(uint value);

    @property uint[] regs();
}