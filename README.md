# GameBeanAdvance
WIP Gameboy Advance Emulator written in D. Currently working on the GBA PPU.

# Compiling and Running
A makefile is provided for running the program. To compile the program, simply type `dub build`. And, to run it, type `./gba [rom_file]`.

It will load the rom file and attempt to run the game. Not many games are functional yet. For example, anything that uses PPU Modes 1, 2, or 3 will not run.

To run the tests, type `dub test`. And, to run the tests, type `./test`. This will test the ARM CPU by running it through the GBA files located in __/tests/asm/bin/__. If the cpu states after every cycle matches the expected states found in the log files in __/tests/asm/log__, then the tests will pass.

# The Jumptable
The jumptable is perhaps the most tedious part of the emulator. 

## The Jumptable - Thumb Mode
The high 8 bits of each 16 bit thumb instruction is extracted and fed into a jumptable, which tells the program what to do at that instruction. Rather than writing all 2<sup>16</sup> functions, we've only written a small subset (37 of them to be exact). I've written a script called make-jumptable.py which reads through the small subset and produces the rest of the functions, which makes it more readable and maintainable while retaining the efficiency of a jumptable. In order to generate the Thumb jumptable, run `python3 make-jumptable.py jumptable-thumb-config.cpp jumptable-thumb.cpp jumptable-thumb.h 16 8 jumptable_thumb JUMPTABLE_THUMB_H uint16_t instruction_thumb`. This turns the __jumptable-thumb-config.cpp__ file into a cpp and h file. As migration continues, the script will output a D file instead. For more details, check __/src/jumptable/jumptable-thumb.cpp__.

## The Jumptable - Arm Mode
For ARM, we use a more powerful script located in __/d-jump/source__. To generate the Arm jumptable, run `d-jump/source/compile <input_file_name> <output_file_name>`. An example of how to use the outputted D file is located in `d-jump/source/app.d`. Essentially, the outputted D file will contain an `execute_instruction` function that can be used to, well, execute an instruction.

# More Details About Testing
Aside from the unit tests that test each specific instruction individually, there's another type of test we will employ that will test the entire instruction set by running through a GBA rom file. These roms are written in ARM assembly and are located in __/tests/asm/src__. These tests have their own makefile that produces a .gba file as well as a log file. The format of the makefile command is: `make [file_name] INSTRUCTIONS=[number_of_instructions]`, where number_of_instructions specifies how many instructions the makefile should produce log files for. Logfile production requires having my editted version of visualboyadvance-m, and having the command `visualboyadvance-m` added to PATH.

# Relevant Resources
ARM Technical Reference Manual: https://static.docs.arm.com/ddi0029/g/DDI0029.pdf

ARM Architectural Reference Manual: https://cs.nyu.edu/courses/spring18/CSCI-GA.2130-001/ARM/arm_arm.pdf

GBATEK: https://problemkaputt.de/gbatek.htm

Patater GBA ASM Guide: https://patater.com/gbaguy/gbaasm.htm