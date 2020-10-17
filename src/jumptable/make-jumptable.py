import re
import sys

# the jumptable will only index a certain number of bits in the instruction
# INSTRUCTION_SIZE defines the number of bits in the whole instruction, while
# JUMPTABLE_BIT_WIDTH is the number of bits we use to index.

# there's a lot of arguments, so here's a description:
INPUT_FILE_NAME         = sys.argv[1]       # the name of the config file to read from
OUTPUT_CPP_FILE         = sys.argv[2]       # the name of the cpp file to output
OUTPUT_HEADER_FILE      = sys.argv[3]       # the name of the header file to output
INSTRUCTION_SIZE        = int(sys.argv[4])  # the size of an instruction in bits (16 for thumb, 32 for arm)
JUMPTABLE_BIT_WIDTH     = int(sys.argv[5])  # the number of bits used for indexing into the jumptable
JUMPTABLE_NAME          = sys.argv[6]       # the name of the jumptable that should be put into the cpp and header files
JUMPTABLE_INCLUDE_GUARD = sys.argv[7]       # the name of the include guard to use in the header file.
OPCODE_DATA_TYPE        = sys.argv[8]       # the datatype of the opcode, probably either uint16_t or uint32_t
INSTRUCTION_NAME        = sys.argv[9]       # the name of the instruction typedef

FUNCTION_HEADER         = "void run_" 
JUMPTABLE_EXCLUDED_BITS = INSTRUCTION_SIZE - JUMPTABLE_BIT_WIDTH
CONDITIONAL_INCLUSION   = "@IF("
JUMPTABLE_FORMAT_WIDTH  = 4
EXCLUSION_HEADER        = "@EXCLUDE("
DEFAULT_HEADER          = "@DEFAULT("
LOCAL_HEADER            = "@LOCAL("
LOCAL_INLINE_HEADER     = "@LOCAL_INLINE("

# formatting for the output files
HEADER_FILE_HEADER      = '''
#ifndef ''' + JUMPTABLE_INCLUDE_GUARD + '''
#define ''' + JUMPTABLE_INCLUDE_GUARD + '''\n\n
#include "../util.h"
#include "../memory.h"
#include "../arm7tdmi.h"\n\n'''[1:] # the [1:] is used to remove the beginning \n

HEADER_FILE_FOOTER      = '''
#endif'''[1:]

CPP_FILE_HEADER         = '''
#include <iostream>

#include "''' + OUTPUT_HEADER_FILE + '"' + '''\n
#include "../util.h"
#include "../memory.h"
#include "../arm7tdmi.h"

#ifdef DEBUG_MESSAGE
    #define DEBUG_MESSAGE(message) std::cout << message << std::endl;
#else
    #define DEBUG_MESSAGE(message) do {} while(0)
#endif\n\n'''[1:]

CPP_FILE_FOOTER         = ''''''






lines = open(INPUT_FILE_NAME, "r").read().split("\n")

i = 0
vars = {} # contain aliases for the bits in the opcode.
exclusions = []
num_vars = 0
jumptable = [None] * pow(2, JUMPTABLE_BIT_WIDTH) 

default_function = []
local_functions = []
local_inline_functions = []



def get_nth_bit(val, n):
    return (val >> n) & 1

def set_nth_bit(val, n):
    return val | (1 << n)

# get the possible exclusions given the tag, taking - into account
def get_exclusions(tag):
    dashes = []
    exclusions = []
    base = 0

    for i in range(0, JUMPTABLE_BIT_WIDTH):
        bit = tag[i]

        if bit == '1':
            base = set_nth_bit(base, JUMPTABLE_BIT_WIDTH - i - 1)
        if bit == '-':
            dashes.append(JUMPTABLE_BIT_WIDTH - i - 1)

    for i in range(0, pow(2, len(dashes))):
        new_base = base

        for j in range(0, len(dashes)):
            if get_nth_bit(i, j) == 1:
                new_base = set_nth_bit(new_base, dashes[j])
        exclusions.append(new_base)

    return exclusions




for i in range(0, len(lines)):
    if lines[i].startswith(EXCLUSION_HEADER):
        # we should exclude the following tag from the next function
        tag = lines[i].split(EXCLUSION_HEADER)[1].split(")")[0]
        exclusions += get_exclusions(tag)
    
    # is this a local function
    if lines[i].startswith(LOCAL_HEADER):
        local_function = ""
        j = i + 1
        while not lines[j].startswith("}"):
            local_function += lines[j] + "\n"
            j += 1
        local_function += lines[j] + "\n"

        local_functions.append(local_function)
        continue
    
    # is this a local inline function
    if lines[i].startswith(LOCAL_INLINE_HEADER):
        local_inline_function = ""
        j = i + 1
        while not lines[j].startswith("}"):
            local_inline_function += lines[j] + "\n"
            j += 1
        local_inline_function += lines[j] + "\n"

        local_inline_functions.append(local_inline_function)
        continue

    # is this a default function
    if lines[i].startswith(DEFAULT_HEADER):
        if len(default_function) != 0:
            print("Two default functions detected.")
            print("Terminating.")
            exit(1)

        j = i + 2 # go to the start of the default function
        while not lines[j].startswith("}"):
            default_function.append(lines[j])
            j += 1

    # is this a function definition
    if lines[i].startswith(FUNCTION_HEADER):
        # if so, let's parse through the function name and collect the vars
        tag = lines[i].split(FUNCTION_HEADER)[1].split("(")[0]
        base = "" # we will construct the base as we parse the tag

        # reset the dictionary
        vars = {}
        num_vars = 0

        # set up the dictionary
        current_bit = INSTRUCTION_SIZE - 1
        for bit in tag:
            if bit != "0" and bit != "1":
                vars[bit] = current_bit
                num_vars += 1
                base += "0"
            else:
                base += bit
            current_bit -= 1
        
        # calculate the base given the number of excluded bits in the jumptable
        base = int(base, 2)

        # now, we know the next line is the function body itself
        # lets collect the function body first
        function = []
        i += 1
        while not lines[i].startswith("}"):
            function.append(lines[i])
            i += 1
        
        # we gotta iterate through the lines possible bits...
        keys = list(vars.keys())
        for current_iteration in range(0, pow(2, num_vars)):
            # calculate the index of the new function so we can check it against the exclusions list
            new_base = base
            for var in keys:
                if get_nth_bit(current_iteration, keys.index(var)):
                    new_base = set_nth_bit(new_base, vars[var] - JUMPTABLE_EXCLUDED_BITS)

            # do we exclude this iteration?
            if new_base in exclusions:
                continue

            # current_iteration interpretted in binary
            # see if the line is a conditional inclusion
            new_function = []
            for line in function:
                if line.strip().startswith(CONDITIONAL_INCLUSION):
                    conds = line.split(CONDITIONAL_INCLUSION)[1].split(")")[0].split()

                    # support for multiple vars. example format: @IF(A !B C D !E)
                    result = True
                    for cond in conds:
                        cond.strip()
                        val = True

                        if cond[0] == "!":
                            val = False
                            cond = cond[1:]

                        if get_nth_bit(current_iteration, keys.index(cond)) != val:
                            result = False

                    # should we skip this line?
                    if result:
                        tab = line.split(CONDITIONAL_INCLUSION)[0]
                        new_function.append(tab + ')'.join(line.split(CONDITIONAL_INCLUSION)[1].split(")")[1:]).strip())
                    continue

                # no? okay, lets add the line
                new_function.append(line)
            
            # and now we insert the function into the jumptable
            if (jumptable[new_base] != None):
                print("Collision detected at: " + format(new_base, '#0' + str(JUMPTABLE_BIT_WIDTH + 2) + 'b')[2:])
                print("\n".join(jumptable[new_base]))
                print("\n".join(new_function))
                print("Terminating.")
                exit(1)

            jumptable[new_base] = new_function

        # reset the exclusions
        exclusions = []





# assemble the file using the jumptable data
header_file = open(OUTPUT_HEADER_FILE, 'w')
cpp_file    = open(OUTPUT_CPP_FILE,    'w')

# first we write the headers to the files
header_file.write(HEADER_FILE_HEADER)
cpp_file.write(CPP_FILE_HEADER)

# and now the local functions
for local_function in local_functions:
    cpp_file.write(local_function)

# and now the local inline functions
for local_inline_function in local_inline_functions:
    header_file.write(local_inline_function)

# now we write the body
for i in range(0, pow(2, JUMPTABLE_BIT_WIDTH)):
    result_function = jumptable[i]

    if result_function != None:
        function_name = FUNCTION_HEADER + format(i, '#0' + str(JUMPTABLE_BIT_WIDTH + 2) + 'b')[2:] + "(ARM7TDMI* cpu, " +  OPCODE_DATA_TYPE + " opcode)"
        header_file.write(function_name + ";\n")
        cpp_file.write(function_name + " {\n")
        cpp_file.write('\n'.join(result_function))
        cpp_file.write("\n}\n\n")
    else:
        function_name = FUNCTION_HEADER + format(i, '#0' + str(JUMPTABLE_BIT_WIDTH + 2) + 'b')[2:] + "(ARM7TDMI* cpu, " + OPCODE_DATA_TYPE + " opcode)"
        header_file.write(function_name + ";\n")
        cpp_file.write(function_name + " {\n")
        cpp_file.write('\n'.join(default_function))
        cpp_file.write("\n}\n\n")

# and now we must loop again to put the actual jumptable in the header file
# first we add the typedef and the extern
header_file.write("\ntypedef void (*" + INSTRUCTION_NAME + ")(ARM7TDMI*, " + OPCODE_DATA_TYPE + ");\n")
header_file.write("extern " + INSTRUCTION_NAME + " " + JUMPTABLE_NAME + "[];\n")

# then we add the jumptable
function_names = list("run_" + format(i, '#0' + str(JUMPTABLE_BIT_WIDTH + 2) + 'b')[2:] for i in range(0, pow(2, JUMPTABLE_BIT_WIDTH)))
cpp_file.write("\n" + INSTRUCTION_NAME + " " + JUMPTABLE_NAME + "[] = {")
for i in range(0, pow(2, JUMPTABLE_BIT_WIDTH)):
    if i % JUMPTABLE_FORMAT_WIDTH == 0:
        cpp_file.write("\n    ")
    cpp_file.write("&" + function_names[i])
    if i != pow(2, JUMPTABLE_BIT_WIDTH) - 1:
        cpp_file.write(", ")
cpp_file.write("\n};\n\n")    

# and now the footers
header_file.write(HEADER_FILE_FOOTER)
cpp_file.write(CPP_FILE_FOOTER)

# and fin