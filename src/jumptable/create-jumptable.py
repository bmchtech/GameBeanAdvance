import re

# the jumptable will only index a certain number of bits in the instruction
# INSTRUCTION_SIZE defines the number of bits in the whole instruction, while
# JUMPTABLE_BIT_WIDTH is the number of bits we use to index.
INPUT_FILE_NAME         = "test-jumptable.cpp"
OUTPUT_HEADER_FILE      = "jumptable.h"
OUTPUT_CPP_FILE         = "jumptable.cpp"
FUNCTION_HEADER         = "void run_" 
INSTRUCTION_SIZE        = 8
JUMPTABLE_BIT_WIDTH     = 6
JUMPTABLE_EXCLUDED_BITS = INSTRUCTION_SIZE - JUMPTABLE_BIT_WIDTH
CONDITIONAL_INCLUSION   = "@IF("


# formatting for the output files
HEADER_FILE_HEADER      = '''
#ifndef JUMPTABLE_H
#define JUMPTABLE_H\n\n'''

HEADER_FILE_FOOTER      = '''
#endif'''

CPP_FILE_HEADER         = '''
#include "jumptable.h"\n\n'''

CPP_FILE_FOOTER         = ''''''






lines = open(INPUT_FILE_NAME, "r").read().split("\n")

i = 0
vars = {} # contain aliases for the bits in the opcode.
num_vars = 0
jumptable = [None] * pow(2, JUMPTABLE_BIT_WIDTH) 

def get_nth_bit(val, n):
    return (val >> n) & 1

def set_nth_bit(val, n):
    return val | (1 << n)

for i in range(0, len(lines)):
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
        base = int(base) << JUMPTABLE_EXCLUDED_BITS
        
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
            
            # we have the new function body. now we just gotta insert it into its rightful place.
            new_base = base
            for var in keys:
                if get_nth_bit(current_iteration, keys.index(var)):
                    new_base = set_nth_bit(new_base, vars[var] - JUMPTABLE_EXCLUDED_BITS)
                    print(new_base)
            
            jumptable[new_base] = new_function





# assemble the file using the jumptable data
header_file = open(OUTPUT_HEADER_FILE, 'w')
cpp_file    = open(OUTPUT_CPP_FILE,    'w')

# first we write the headers to the files
header_file.write(HEADER_FILE_HEADER)
cpp_file.write(CPP_FILE_HEADER)

# now we write the body
i = 0
for i in range(0, pow(2, JUMPTABLE_BIT_WIDTH)):
    result_function = jumptable[i]

    if result_function != None:
        function_name = FUNCTION_HEADER + format(i, '#0' + str(JUMPTABLE_BIT_WIDTH + 2) + 'b')[2:] + "()"
        header_file.write(function_name + ";\n")
        cpp_file.write(function_name + " {\n")
        cpp_file.write('\n'.join(result_function))
        cpp_file.write("\n}\n\n")

# and now the footers
header_file.write(HEADER_FILE_FOOTER)
cpp_file.write(CPP_FILE_FOOTER)

# and fin