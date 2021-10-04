![icon](media/icon.png)

# GameBeanAdvance
WIP Gameboy Advance Emulator written in D. Currently working on GBA accuracy.

# Demo Videos (Turn audio up)

https://user-images.githubusercontent.com/15221993/134795596-50df7538-6ca9-40c1-a22c-97055fd389f7.mov


https://user-images.githubusercontent.com/15221993/134795668-0a3c979e-dc54-4b23-87b4-050dcdab5d5e.mov


# Usage
Emulator main project is in `src/emu`.

## Build

### Requirements
+ Dlang + DUB
+ Python3/PyPy3 (packages: `ply`)

### Standard Build

Optionally add `-b release --compiler=ldc2` for optimized build.
To speed up jumptable generation, you can set environment variable `PYTHON=pypy3` to use PyPy3 JIT.

```
dub build
```

### Profiling

Build with support for [gperftools_d](https://github.com/prasunanand/gperftools_d). This requires the LDC2 compiler.

```sh
dub build -c gperf --compiler=ldc2 -b release-debug
```

Then, run with the `CPUPROFILE=/tmp/prof.out` environment var to write a profile log.

Finally, convert the log to human readable graph:
```sh
pprof --pdf gamebean-emu /tmp/prof.out > ~/Downloads/gamebean_profile.pdf
```

## Run

Specify path to rom. You can also optionally use `-s` to specify window scaling (default = 1). Note that you must have a __gba_bios.bin__ located in the same directory as the executable. You can acquire a substitute BIOS (see [Cult of GBA](https://github.com/Cult-of-GBA/BIOS)), or you can dump the official BIOS from a GBA.
```
./gamebean-emu [rom]
```

## Tests

To run the tests, run `dub test`. This will test the ARM CPU by running it through the GBA files located in __/tests/asm/bin/__. If the cpu states after every cycle matches the expected states found in the log files in __/tests/asm/log__, then the tests will pass.

# Technical Overview
## General Structure
The GBA is comprised of three main modules. The CPU, the PPU, and the Sound Controller. The PPU is similar to a GPU. Currently, the cpu implementation can be found in __/src/arm7tdmi.d__, and the ppu implementation can be found in __/src/ppu.d__. There is no sound controller yet. You can find memory in __/src/memory.d__, as well as __/src/memory-mapped-io.d__. Finally, there is one more general file that ties everything together - __/src/gba.d__. This file simply loads the ROMs, manages the scheduler, and handles any DMA requests. 

## The Jumptable
The ARM7TDMI CPU has two modes - ARM and THUMB. Each mode has a different instruction set, and thus needs a different jumptable to decode the instruction. This section will explain how the THUMB and ARM jumptables work.

The thumb jumptable has a size of 2<sup>8</sup>, while the arm jumptable has a size of 2<sup>12</sup>. This is because you need 8/16 bits to decode a THUMB instruction, and 12/32 bits to decode an ARM one. As you can imagine, manually formatting the jumptable by putting the appropraite function into each index takes a lot of work, so there's two python scripts that help automate this.

### The Jumptable - Thumb Mode
The THUMB jumptable is found in __/src/jumptable/jumptable-thumb-config.cpp__. there is also a file called __/src/jumptable/make_jumptable.py__ which generates the jumptable files. Here's how the notation in __jumptable-thumb-config.cpp__ works:

All functions are titled run_<some binary value>. the binary value specifies where in the jumptable the function belongs. if the binary value contains letters as bits (let's call them bit-variables), then those bits can be either 0 or 1, and the jumptable is updated accordingly. Examples:

run_0101 would be inserted into index 0101 in the jumptable.
run_010A would be inserted into indices 0100, and 0101 in the jumptable.

If you begin a line with @IF(<insert bit-variable here>), then the line is only included in entries of the jumptable where that specific bit-variable is 1. If a function is preceded by @EXCLUDE(<some binary value>), then the function will not be inserted in the jumptable at that binary value. '-' is used as a wildcard in @EXCLUDE, similarly to bit-variables. @DEFAULT() is used for a default function (in this case, the default is a nop function). Default functions are used when no other function matches the jumptable. Finally, @LOCAL() to tell the script that the following function is a local function and should appear in the .cpp file.

In order to generate the Thumb jumptable, run `python3 make-jumptable.py jumptable-thumb-config.cpp jumptable-thumb.cpp jumptable-thumb.h 16 8 jumptable_thumb JUMPTABLE_THUMB_H uint16_t instruction_thumb`. This turns the __jumptable-thumb-config.cpp__ file into a D file. For more details, check __/src/jumptable/jumptable-thumb.cpp__.

### The Jumptable - Arm Mode
For ARM, I use a more powerful script located in __/d-jump/source__. To generate the Arm jumptable, run `d-jump/source/compile <input_file_name> <output_file_name>`. An example of how to use the outputted D file is located in `d-jump/source/app.d`. Essentially, the outputted D file will contain an `execute_instruction` function that can be used to, well, execute an instruction. There's extensive documentation in the D-Jump compiler script if you want to learn more.

## D Jump - Why was it created?

D Jump was created to help fill in a jumptable without having unnecessarily reptitive code. This can be used in the creation of emulators. One of the biggest challenges in decoding emulators is filling in the jumptable succinctly. Often times, to properly decode an assembly instruction, a large number of bits have to be read (i.e > 12). The popular approach is to create a jumptable, and have the decode bits be an index into the jumptable. The jumptable would be an array of function pointers, which can be used to execute a particular instruction. The problem is that when there is a large number of bits required to properly decode, you have the choice between either making the jumptable very large, or making it small and including some switch-case logic later on inside the functions that the jumptable points to to help decode the rest of the instruction. This can get really messy really quickly, and is prone to bugs.

## D Jump - Rules

D Jump fixes this by introducing two new features: Rules and Components. A more detailed BNF is provided within the D-Jump compiler, but here's the gist. Rules consist of an Include statement, zero or more Exclude statements, and one or more Components. The Include statements provide information as to where in the jumptable this particular instruction should appear. For example, a Rule with an Include of 010011010010 would appear in the jumptable at index 010011010010. Includes can get more complicated. For example, you can have a '-' in the binary expression, which means that any bit can appear in that slot. So, a Rule with an Include of 01001101001- would appear in both 010011010010 and 010011010011. Rules can also have zero or more Exclude statements, which means that if a Rule matches the Include but also matches the Exclude, then it is not added into the jumptable.

## D Jump - Components
Each rule contains an arbitrary (but non-zero) number of components. A component can be thought of as a C macro with special features. Each component contains one Format as well as a valid D block of code (by valid, I mean that if this block of code were inserted into a void function), then the code would execute properly. Formats can be thought of similarly to Includes, but they serve a wildly different purpose. Formats are constructed as a binary number with both dashes and capital letters inserted into the expression. The capital letters can be used to alter flow of the D code block. This can be achieved using '@IF()' statements within the D code block.

## D Jump - Examples

Here's an example of a Component to explain how this works:
```'D
[COMPONENT ADD]
- FORMAT: 010011B10010]
{
    @IF( B) uint result = 2;
    @IF(!B) uint result = 3;
}
[/COMPONENT]
```

In this example, whenever the ADD Component is used, if the B bit happens to be 1, then only the line 'uint32_t result = 2;' is added. If the B bit is 0, then only the line 'uint32_t result = 3;' is added. This can be used to make program flow dependent on the values of certain bits in the instruction. It's basically templated functions but on steroids, and in my opinion, cleaner.

## More Details About Testing

Aside from the unit tests that test each specific instruction individually, there's another type of test I will employ that will test the entire instruction set by running through a GBA rom file. These roms are written in ARM assembly and are located in __/tests/asm/src__. These tests have their own makefile that produces a .gba file as well as a log file. Logfile production requires having my editted version of NanoBoyAdvance, and having the command `NanoBoyAdvance` added to PATH.

# Relevant Resources
ARM Technical Reference Manual: https://static.docs.arm.com/ddi0029/g/DDI0029.pdf

ARM Architectural Reference Manual: https://cs.nyu.edu/courses/spring18/CSCI-GA.2130-001/ARM/arm_arm.pdf

GBATEK: https://problemkaputt.de/gbatek.htm

Patater GBA ASM Guide: https://patater.com/gbaguy/gbaasm.htm

# Special Thanks
+ nocash https://problemkaputt.de/gbatek.htm
+ fleroviux https://github.com/fleroviux/NanoBoyAdvance
+ DenSinH https://github.com/DenSinH/DSHBA
