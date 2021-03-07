module arm_pinky;

import std.stdio;
void entry_00(ubyte opcode) {
    ubyte discriminator = (((opcode >> 0) & 0) << 0) | (((opcode >> 1) & 1) << 0);

    switch (discriminator) {
        case 0b0: {
            // yes this is useless code but its filler so
            int a = 3;
            
            int b = 6;
            int result = a - b;
            writeln(result);
            break;
        }
        case 0b1: {
            writeln("No implementation for opcode");
            break;
        }
    default: break;
    }
}

void entry_01(ubyte opcode) {
    ubyte discriminator = (((opcode >> 0) & 0) << 0) | (((opcode >> 1) & 1) << 0);

    switch (discriminator) {
        case 0b0: {
            // yes this is useless code but its filler so
            int a = 3;
            
            int b = 6;
            int result = a - b;
            writeln(result);
            break;
        }
        case 0b1: {
            writeln("No implementation for opcode");
            break;
        }
    default: break;
    }
}

void entry_10(ubyte opcode) {
    ubyte discriminator = (((opcode >> 0) & 0) << 0) | (((opcode >> 1) & 1) << 0);

    switch (discriminator) {
        case 0b0: {
            // yes this is useless code but its filler so
            int a = 5;
            int b = 6;
            int result = a - b;
            writeln(result);
            break;
        }
        case 0b1: {
            // yes this is useless code but its filler so
            int a = 5;
            // special comment! :D
            int b = 6;
            int result = a + b;
            writeln(result);
            break;
        }
    default: break;
    }
}

void entry_11(ubyte opcode) {
    ubyte discriminator = (((opcode >> 0) & 0) << 0) | (((opcode >> 1) & 1) << 0);

    switch (discriminator) {
        case 0b0: {
            // yes this is useless code but its filler so
            int a = 5;
            int b = 6;
            int result = a - b;
            writeln(result);
            break;
        }
        case 0b1: {
            // yes this is useless code but its filler so
            int a = 5;
            // special comment! :D
            int b = 6;
            int result = a + b;
            writeln(result);
            break;
        }
    default: break;
    }
}

void execute_instruction(ubyte opcode) {
    jumptable[(((opcode >> 0) & 0) << 0) | (((opcode >> 2) & 3) << 0)](opcode);
}

immutable jumptable = [
    &entry_00,
    &entry_01,
    &entry_10,
    &entry_11,
];
