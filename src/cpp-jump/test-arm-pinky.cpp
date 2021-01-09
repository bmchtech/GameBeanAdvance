#include <iostream>
#include "output.h"

int main() {
    for (int i = 0; i < 16; i++) {
        arm_pinky::execute_instruction((uint8_t) i);
    }
}