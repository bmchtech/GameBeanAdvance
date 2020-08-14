import re

# the jumptable will only index a certain number of bits in the instruction
# INSTRUCTION_SIZE defines the number of bits in the whole instruction, while
# JUMPTABLE_BIT_WIDTH is the number of bits we use to index.
INPUT_FILE_NAME         = "test-jumptable.cpp"
OUTPUT_HEADER_FILE      = "jumptable.h"
OUTPUT_CPP_FILE         = "jumptable.cpp"
FUNCTION_HEADER         = "void run_" 
INSTRUCTION_SIZE        = 16
JUMPTABLE_BIT_WIDTH     = 8
JUMPTABLE_EXCLUDED_BITS = INSTRUCTION_SIZE - JUMPTABLE_BIT_WIDTH
CONDITIONAL_INCLUSION   = "@IF("
JUMPTABLE_FORMAT_WIDTH  = 4
EXCLUSION_HEADER        = "@EXCLUDE("
DEFAULT_HEADER          = "@DEFAULT("

# formatting for the output files
HEADER_FILE_HEADER      = '''
#ifndef JUMPTABLE_H
#define JUMPTABLE_H\n\n'''[1:] # the [1:] is used to remove the beginning \n

HEADER_FILE_FOOTER      = '''
#endif'''

CPP_FILE_HEADER         = '''
#include "jumptable.h"\n\n'''[1:] # the [1:] is used to remove the beginning \n

CPP_FILE_FOOTER         = ''''''






lines = open(INPUT_FILE_NAME, "r").read().split("\n")

i = 0
vars = {} # contain aliases for the bits in the opcode.
exclusions = []
num_vars = 0
jumptable = [None] * pow(2, JUMPTABLE_BIT_WIDTH) 

default_function = []




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
                    var = line.split(CONDITIONAL_INCLUSION)[1].split(")")[0]
                    # should we skip this line?
                    if get_nth_bit(current_iteration, keys.index(var)):
                        tab = line.split(CONDITIONAL_INCLUSION)[0]
                        new_function.append(tab + line.split(CONDITIONAL_INCLUSION)[1].split(")")[1].strip())
                    continue

                # no? okay, lets add the line
                new_function.append(line)
            
            # and now we insert the function into the jumptable
            if (jumptable[new_base] != None):
                print("Collision detected at: " + format(new_base, '#0' + str(JUMPTABLE_BIT_WIDTH + 2) + 'b')[2:])
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

# now we write the body
for i in range(0, pow(2, JUMPTABLE_BIT_WIDTH)):
    result_function = jumptable[i]

    if result_function != None:
        function_name = FUNCTION_HEADER + format(i, '#0' + str(JUMPTABLE_BIT_WIDTH + 2) + 'b')[2:] + "(int opcode)"
        header_file.write(function_name + ";\n")
        cpp_file.write(function_name + " {\n")
        cpp_file.write('\n'.join(result_function))
        cpp_file.write("\n}\n\n")
    else:
        function_name = FUNCTION_HEADER + format(i, '#0' + str(JUMPTABLE_BIT_WIDTH + 2) + 'b')[2:] + "(int opcode)"
        header_file.write(function_name + ";\n")
        cpp_file.write(function_name + " {\n")
        cpp_file.write('\n'.join(default_function))
        cpp_file.write("\n}\n\n")

# and now we must loop again to put the actual jumptable in the cpp file
function_names = list("run_" + format(i, '#0' + str(JUMPTABLE_BIT_WIDTH + 2) + 'b')[2:] for i in range(0, pow(2, JUMPTABLE_BIT_WIDTH)))
cpp_file.write("void (* jumptable [])(int) = {")
for i in range(0, pow(2, JUMPTABLE_BIT_WIDTH)):
    if i % JUMPTABLE_FORMAT_WIDTH == 0:
        cpp_file.write("\n    ")
    cpp_file.write("&" + function_names[i])
    if i != pow(2, JUMPTABLE_BIT_WIDTH) - 1:
        cpp_file.write(", ")
cpp_file.write("\n}\n\n")    

# and now the footers
header_file.write(HEADER_FILE_FOOTER)
cpp_file.write(CPP_FILE_FOOTER)

# and fin
print("Success!")
exit(0)