# this program is mainly here for me to teach myself
# how the opcode decoding works. this isn't a final or
# efficient solution, it's just a way to understand
# the CPU better. plus it'd be helpful when debugging.

import sys

file_name   =     sys.argv[1]
start_range = int(sys.argv[2])
end_range   = int(sys.argv[3])

raw_lines = open(file_name).read().split("\n")
hex_lines = list(raw_lines[i].split(" ")[1][2:] for i in range(start_range, end_range))
bin_lines = list(bin(int(line, 16))[2:].zfill(32) for line in hex_lines)




COND_CODES = [
    'Z             ',
    '!Z            ',
    'C             ',
    '!C            ',
    'N             ',
    '!N            ',
    'V             ',
    '!V            ',
    'C && !Z       ',
    '!C || Z       ',
    'N == V        ',
    'N != V        ',
    '!Z && (N == V)',
    'Z || (N != V) ',
    'ALWAYS        '
]

DATA_PROCESSING_CODES = [
    'AND',
    'EOR',
    'SUB',
    'RSB',
    'ADD',
    'ADC',
    'SBC',
    'RSC',
    'TST',
    'CMP',
    'CMN',
    'MOV',
    'BIC',
    'MVN'
]

# utility functions
def sign_extend(value, bits):
    sign_bit = 1 << (bits - 1)
    return (value & (sign_bit - 1)) - (value & sign_bit)




# for more detailed explanations of what these functions do, check the for loop below.

def parse_0000(opcode):
    # so this is probably one of the stupidest mechanisms i've seen in my life
    # essentially, this can either be one of the multiply instructions or the
    # halfword data transfers. the only thing that can differentiate between
    # the two is whether or not you're multiplying by 0... the instructions can
    # look virtually identical otherwise
    
    # are we... multiplying by 0
    if int(opcode[8:12], 2) == 0:
        if int(opcode[22], 2) == 0:
            # register offset
            pass
        else:
            # immediate offset
            pass
    
    pass

def parse_0001(opcode):
    # by setting the right flags, some instructions can turn into each other.
    # for example, upon closer scrutiny, single data swap is just a halfword data
    # transfer: register offset with the PUWLSH flags at 100000. so i'm gonna kinda
    # just ignore the fact that single data swaps even exist and just use halfword
    # data transfers with register offset.

    # let's check if we are a branch and exchange:
    if int(opcode[7], 2) == 1:
        pass
    
    # a single data swap is a halfword data transfer register offset in disguise so
    # we'll just check between the two types of halfword data transfers now
    if int(opcode[22], 2) == 0:
        # we're register offset
        pass
    else:
        # we're immediate offset
        pass
    
def parse_0010(opcode):
    operation = int(opcode[21:25], 2)
    Rn        = int(opcode[16:20], 2)
    Rd        = int(opcode[12:16], 2)
    op2       = int(opcode[0:12],  2)

    operation_str = DATA_PROCESSING_CODES[operation]
    reg_1_str     = "R" + str(Rn)
    reg_2_str     = "(R" + str(op2 & 15) + " + " + str(op2 >> 4) + ")"
    reg_dest_str  = "R" + str(Rd)

    return reg_1_str + " " + operation_str + " " + reg_2_str " -> " + reg_dest_str
    
def parse_0011(opcode):
    operation = int(opcode[21:25], 2)
    Rn        = int(opcode[16:20], 2)
    Rd        = int(opcode[12:16], 2)
    op2       = int(opcode[0:12],  2)

    operation_str = DATA_PROCESSING_CODES[operation]
    reg_1_str     = "R" + str(Rn)
    reg_2_str     = "(" + str(op2 & 255) + " rotated " + str(op2 >> 8) + ")"
    reg_dest_str  = "R" + str(Rd)

    return reg_1_str + " " + operation_str + " " + reg_2_str " -> " + reg_dest_str

def parse_0100(opcode):
    return "SINGLE DATA TRANSFER"
    
def parse_0101(opcode):
    return "SINGLE DATA TRANSFER"
    
def parse_0110(opcode):
    if (opcode[4] == "1")
        return "UNDEFINED"
    return "SINGLE DATA TRANSFER"
    
def parse_0111(opcode):
    if (opcode[4] == "1")
        return "UNDEFINED"
    return "SINGLE DATA TRANSFER"
    
def parse_1000(opcode):
    return "BLOCK DATA TRANSFER"
    
def parse_1001(opcode):
    return "BLOCK DATA TRANSFER"
    
def parse_1010(opcode):
    # branch
    offset = sign_extend(int(opcode[0:24], 2) << 2, 32)
    return "B " + offset
    
def parse_1011(opcode):
    # branch with link
    offset = sign_extend(int(opcode[0:24], 2) << 2, 32)
    return "BL " + offset
    
def parse_1100(opcode):
    return "ERROR: GAMEBOY ONLY"
    
def parse_1101(opcode):
    return "ERROR: GAMEBOY ONLY"

def parse_1110(opcode):
    return "ERROR: GAMEBOY ONLY"
    
def parse_1111(opcode):
    return "SOFTWARE INTERRUPT"



for line in bin_lines:
    # grab the condition code
    cond = COND_CODES[int(line[0:4], 2)]

    # the next 4 bits give us a rough idea what the instruction wants to do
    # 0000 - Multiply, Multiply Long, Halfword Data Transfer: Register Offset, Halfword Data Transfer: Immediate Offset
    # 0001 - Single Data Swap, Branch and Exchange, Halfword Data Transfer: Register Offset, Halfword Data Transfer: Immediate Offset
    # 0010 - Data Processing / PSR Transfer
    # 0011 - Data Processing / PSR Transfer
    # 0100 - Single Data Transfer
    # 0101 - Single Data Transfer
    # 0110 - Single Data Transfer, Undefined
    # 0111 - Single Data Transfer, Undefined
    # 1000 - Block Data Transfer
    # 1001 - Block Data Transfer
    # 1010 - Branch
    # 1011 - Branch
    # 1100 - Coprocessor Data Transfer
    # 1101 - Coprocessor Data Transfer
    # 1110 - Coprocessor Data Operation, Coprocessor Register Transfer
    # 1111 - Software Interrupt

    # a lot of the times the first 4 bits aren't enough to identify what the instruction is,
    # so other bits are used to disambiguate and figure out what exactly's going on.
