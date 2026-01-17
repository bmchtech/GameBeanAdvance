![icon](media/icon.png)



# GameBeanAdvance
WIP Gameboy Advance Emulator written in D. Passes 2020/2020 mGBA timing tests, and fourth software-based emulator to pass the AGS Aging Cartridge test. Currently working on improving GBA accuracy.

# Demo Videos (Turn audio up)

https://user-images.githubusercontent.com/15221993/144956720-35759f25-d480-4e99-aff3-2daa7b0fa977.mp4


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

### GDB stub

Use the optional gdbstub integration:
```sh
git submodule update --init --recursive
dub build -c gdbstub
./gamebean-emu [rom] --gdb 127.0.0.1:5555
```

Then connect with lldb:

```sh
lldb -O "gdb-remote 127.0.0.1:5555"
```

## Tests

To run the tests, run `dub test`. This will test the ARM CPU by running it through the GBA files located in __/tests/asm/bin/__. If the cpu states after every cycle matches the expected states found in the log files in __/tests/asm/log__, then the tests will pass. These roms are written in ARM assembly and are located in __/tests/asm/src__. These tests have their own makefile that produces a .gba file as well as a log file. Logfile production requires having an editted version of NanoBoyAdvance, and having the command `NanoBoyAdvance` added to PATH.

# Relevant Resources

ARM Technical Reference Manual: https://static.docs.arm.com/ddi0029/g/DDI0029.pdf

ARM Architectural Reference Manual: https://cs.nyu.edu/courses/spring18/CSCI-GA.2130-001/ARM/arm_arm.pdf

GBATEK: https://problemkaputt.de/gbatek.htm

Patater GBA ASM Guide: https://patater.com/gbaguy/gbaasm.htm

Tonc: https://www.coranac.com/tonc/text/

# Special Thanks
+ nocash, for the excellent documentation about the GBA's internals on [GBATEK](https://problemkaputt.de/gbatek.htm)
+ fleroviux, for sharing research on GBA timing, as well letting me take inspiration [NanoBoyAdvance](https://github.com/fleroviux/NanoBoyAdvance) for my frontend design.
+ DenSinH, whose code ([DSHBA]([emu](https://github.com/DenSinH/DSHBA))) I referenced while adding shaders to my emu
+ Near and Talarubi, who created the aforementioned [shaders](https://near.sh/articles/video/color-emulation).
