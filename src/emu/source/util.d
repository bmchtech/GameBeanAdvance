module util;

import core.stdc.math; //core.stdc.math.pow 
import core.stdc.stdint; //uint32_t uint8_t 

version (!(UTIL_H)) {
    version = UTIL_H;

    class GBA;
    // the color for message output
    //#define YELLOW  "
    //33[33m"
    //#define RED     "
    //33[31m" 
    //#define RESET   "
    //33[0m"

    // a warning will not terminate the program
    void warning(string message);
    // an error terminates the program and calls exit(EXIT_FAILURE);
    void error(string message);
    // converts uint32_t to hex string
    string to_hex_string(uint32_t val);
    // get nth bits from value as so: [start, end)
    uint32_t get_nth_bits(uint32_t val, uint8_t start, uint8_t end) {
        return (val >> start) & cast(uint32_t)(core.stdc.math.pow(2, end - start) - 1);
    }

    // get nth bit from value
    bool get_nth_bit(uint32_t val, uint8_t n) {
        return (val >> n) & 1;
    }

    // sign extend the given value
    uint32_t sign_extend(uint32_t val, uint8_t num_bits) {
        return (val ^ (1 << (num_bits - 1))) - (1 << (num_bits - 1));
    }

    // reads the ROM as bytes (given the file name). stores the result into out. any data after out_length will be truncated
    // off the ROM.
    void get_rom_as_bytes(string rom_name, uint8_t[] out_, size_t out_length);
    // set this to enable gba logging
    GBA logger_gba;

    import core.stdc.stdint; //uint32_t uint8_t 
    import core.stdc.stdlib; //core.stdc.stdlib.exit 
    import cpp_std; //cpp_std.Stringstream 
    import iosfwd; //std::ifstream std::ios 

    void warning(string message) {
    }

    void error(string message) {
        if ( /*OpaqueValueExpr Stmt*/ ) {
        }

        core.stdc.stdlib.exit(-1);
    }

    string to_hex_string(uint32_t val) {
        cpp_std.Stringstream ss;
    }

    void get_rom_as_bytes(string rom_name, uint8_t[] out_, size_t out_length) {
        // open file
        ifstream infile = new ifstream();
        infile.open(rom_name, ios.binary);
        // check if file exists
        if (!infile.good()) {
        }

        // get length of file
        infile.seekg(0, ios.end);
        size_t length;
        infile.seekg(0, ios.beg);
        // read file
        char[] buffer = new char[length];
        infile.read(buffer, length);
        length = infile.gcount();
        if (out_length < length) {
            length = out_length;
        }

        for (int i = 0; i < length; i++) {
            out_[i] = buffer[i];
        }

        buffer = null;
    }

    int[] logger_gba;
