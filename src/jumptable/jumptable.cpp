
#include "jumptable.h"

void run_000000() {
    std::cout << B << std::endl;
}

void run_000001() {
    std::cout << B << std::endl;
}

void run_000010() {
    std::cout << P << std::endl;
    std::cout << B << std::endl;
}

void run_000011() {
    std::cout << P << std::endl;
    std::cout << B << std::endl;
}

void (* jumptable [])() = {
    &run_000000, &run_000001, &run_000010, &run_000011, 
    &run_000100, &run_000101, &run_000110, &run_000111, 
    &run_001000, &run_001001, &run_001010, &run_001011, 
    &run_001100, &run_001101, &run_001110, &run_001111, 
    &run_010000, &run_010001, &run_010010, &run_010011, 
    &run_010100, &run_010101, &run_010110, &run_010111, 
    &run_011000, &run_011001, &run_011010, &run_011011, 
    &run_011100, &run_011101, &run_011110, &run_011111, 
    &run_100000, &run_100001, &run_100010, &run_100011, 
    &run_100100, &run_100101, &run_100110, &run_100111, 
    &run_101000, &run_101001, &run_101010, &run_101011, 
    &run_101100, &run_101101, &run_101110, &run_101111, 
    &run_110000, &run_110001, &run_110010, &run_110011, 
    &run_110100, &run_110101, &run_110110, &run_110111, 
    &run_111000, &run_111001, &run_111010, &run_111011, 
    &run_111100, &run_111101, &run_111110, &run_111111
}

