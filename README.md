# GameBeanAdvance
WIP Gameboy Advance Emulator written in C++. Currently working on the ARM7TDMI CPU.

# Compiling and Running
A makefile is provided for running the program. To compile the program, simply type `make gba`. And, to run it, type `./gba [rom_file]`.

It will load the rom file and display the game name on screen. Since the ARM instruction set hasn't been implemented yet, it doesn't actually run through the ROM at all, because in GBA the first instruction is always an ARM instruction, and it's usually a branch instruction too.

To run the tests, type `make test`. You may have to `make clean` first. And, to run the tests, type `./test`. This will run test the Thumb instruction set with several unit tests, and then it will run __tests/asm/bin/thumb-alu.gba__ and check it against a working emulator (visualboyadvance) which I have modified to produce logs that contain each instruction exected as well as the values of registers r0-r15.

# The Jumptable
The jumptable is perhaps the most tedious part of the emulator. The high 8 bits of each 16 bit thumb instruction is extracted and fed into a jumptable, which tells the program what to do at that instruction. Rather than writing all 2<sup>16</sup> functions, we've only written a small subset (37 of them to be exact). I've written a script called make-jumptable.py which reads through the small subset and produces the rest of the functions, which makes it more readable and maintainable while retaining the efficiency of a jumptable. For more details, check __/src/jumptable/jumptable-thumb.cpp__.

# More Details About Testing
Aside from the unit tests that test each specific instruction individually, there's another type of test we will employ that will test the entire instruction set by running through a GBA rom file. These roms are written in __/tests/asm/src__. These tests have their own makefile that produces a .gba file as well as a log file. The format of the makefile command is: `make [file_name] INSTRUCTIONS=[number_of_instructions]`, where number_of_instructions specifies how many instructions the makefile should produce log files for. Logfile production requires having my editted version of visualboyadvance-m, and having the command `visualboyadvance-m` added to PATH.

# Relevant Resources
ARM Technical Reference Manual: https://static.docs.arm.com/ddi0029/g/DDI0029.pdf

ARM Architectural Reference Manual: https://cs.nyu.edu/courses/spring18/CSCI-GA.2130-001/ARM/arm_arm.pdf

GBATEK: https://problemkaputt.de/gbatek.htm

Patater GBA ASM Guide: https://patater.com/gbaguy/gbaasm.htm