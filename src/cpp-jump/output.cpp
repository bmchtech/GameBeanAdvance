void entry_00() {
    uint8_t discriminator = (((opcode >> 0) & 0) << 0) | (((opcode >> 1) & 1) << 0);

    switch (discriminator) {
        case 0b0: {
            // yes this is useless code but its filler so
            int a = 3;
            
            int b = 6;
            int result = a - b;
            break;
        }
    }
}

void entry_01() {
    uint8_t discriminator = (((opcode >> 0) & 0) << 0) | (((opcode >> 1) & 1) << 0);

    switch (discriminator) {
        case 0b0: {
            // yes this is useless code but its filler so
            int a = 3;
            
            int b = 6;
            int result = a - b;
            break;
        }
    }
}

void entry_10() {
    uint8_t discriminator = (((opcode >> 0) & 0) << 0) | (((opcode >> 1) & 1) << 0);

    switch (discriminator) {
        case 0b0: {
            // yes this is useless code but its filler so
            
            int a = 5;
            int b = 6;
            int result = a - b;
            break;
        }
        case 0b1: {
            // yes this is useless code but its filler so
            
            int a = 5;
            int b = 6;
            int result = a + b;
            break;
        }
    }
}

void entry_11() {
    uint8_t discriminator = (((opcode >> 0) & 0) << 0) | (((opcode >> 1) & 1) << 0);

    switch (discriminator) {
        case 0b0: {
            // yes this is useless code but its filler so
            
            int a = 5;
            int b = 6;
            int result = a - b;
            break;
        }
        case 0b1: {
            // yes this is useless code but its filler so
            
            int a = 5;
            int b = 6;
            int result = a + b;
            break;
        }
    }
}

