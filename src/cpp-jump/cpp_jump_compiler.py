import ply.lex  as lex
import ply.yacc as yacc
import math
import string
import sys

############################################### OVERVIEW ###############################################

# C++ Jump is a superset of C++ that was created to help fill in a jumptable without having
# unnecessarily reptitive code. This can be used in the creation of emulators. One of the
# biggest challenges in decoding emulators is filling in the jumptable succinctly. Often times,
# to properly decode an assembly instruction, a large number of bits have to be read (i.e > 12).
# The popular approach is to create a jumptable, and have the decode bits be an index into 
# the jumptable. The jumptable would be an array of function pointers, which can be used to
# execute a particular instruction. The problem is that when there is a large number of bits
# required to properly decode, you have the choice between either making the jumptable very
# large, or making it small and including some switch-case logic later on inside the functions
# that the jumptable points to to help decode the rest of the instruction. This can get really
# messy really quickly, and is prone to bugs.
#
# C++ Jump fixes this by introducing two new features: Rules and Components. A more detailed
# BNF is provided below, but here's the gist. Rules consist of an Include statement, zero or
# more Exclude statements, and one or more Components. The Include statements tell provide
# information as to where in the jumptable this particular instruction should appear. For example,
# a Rule with an Include of 010011010010 would appear in the jumptable at index 010011010010.
# Includes can get more complicated. For example, you can have a '-' in the binary expression,
# which means that any bit can appear in that slot. So, a Rule with an Include of 01001101001-
# would appear in both 010011010010 and 010011010011. Rules can also have zero or more Exclude
# statements, which means that if a Rule matches the Include but also matches the Exclude, then
# it is not added into the jumptable.
#
# Each rule contains an arbitrary (but non-zero) number of components. A component can be thought
# of as a C macro with special features. Each component contains one Format as well as a valid
# C++ block of code (by valid, I mean that if this block of code were inserted into a void function),
# then the code would execute properly. Formats can be thought of similarly to Includes, but
# they serve a wildly different purpose. Formats are constructed as a binary number with both dashes
# and capital letters inserted into the expression. The capital letters can be used to alter flow
# of the C++ code block. This can be achieved using '@IF()' statements within the C++ code block.
#
# Here's an example of a Component to explain how this works:
# [COMPONENT ADD]
# - FORMAT: 010011B10010]
# {
#   @IF( B) uint32_t result = 2;
#   @IF(!B) uint32_t result = 3;
# }
# [/COMPONENT]
#
#
# In this example, whenever the ADD Component is used, if the B bit happens to be 1, then only
# the line 'uint32_t result = 2;' is added. If the B bit is 0, then only the line 'uint32_t 
# result = 3;' is added. This can be used to make program flow dependent on the values of certain
# bits in the instruction.
#
# Additionally, there is required to be a list of settings somewhere in the file. Here's an example
# for the settings:
#
# [SETTINGS]
# - NAME: ARM7TDMI_ARM
# - TOTAL_BITS: 16
# - ADDRESSABLE_BITS: 12
# - OPCODE_SIZE: 32
# [/SETTINGS]
#
# This is an example setting for configuring ARM instructions for the ARM7TDMI. Each of these settings
# needs to be specified (and in that specific order). Here's a description of the meaning of each setting:
# NAME:             Used to generate a typedef for the functions that are found in the jumptable.
# TOTAL_BITS:       The total number of bits needed to decode an instruction
# ADDRESSABLE_BITS: The total number of bits that can be used as an index into the jumptable. Note that
#                   the rest of the bits will be dealt with using a switch case within each function.
# OPCODE_SIZE:      The size of the whole opcode.

# EBNF for C++ Jump. Note that <C++> denotes valid C++ code as described above.
#
# <settings>             ::= <settings-header> <name> <total-bits> <addressable-bits> <opcode-size> <settings-footer>
# <rule>                 ::= <rule-header> <include> <exclude>* <component>+ <rule-footer>
# <component>            ::= <component-header> <format> <C++> <component-footer>
#
# <settings-header>      ::= [SETTINGS]
# <name>                 ::= - NAME: <identifier>
# <total_bits>           ::= - TOTAL_BITS: <number>
# <addressable_bits>     ::= - ADDRESSABLE_BITS: <number>
# <opcode_size>          ::= - OPCODE_SIZE: <number>
# <settings-footer>      ::= [/SETTINGS]
#
# <rule-header>          ::= [RULE <rule-name>]
# <include>              ::= - INCLUDE: <binary-sequence>
# <exclude>              ::= - EXCLUDE: <binary-sequence>
# <component>            ::= - COMPONENT: <component-name>
# <rule-footer>          ::= [/RULE]

# <component-header>     ::= [COMPONENT <component-name>]
# <format>               ::= - FORMAT: <formatted-binary-sequence>
# <component-footer>     ::= [/COMPONENT]

# Note that the above EBNF is written to summarize the important parts of C++ Jump, as well as to give
# an overview for the following regex. Because of this, some of the of the regex shown below match things
# not in the EBNF like left and right square brackets to make grammar checking easier.





################################################ LEXER ################################################

# here's some regex to help match the above, as well as some associated tokens


reserved = [
    'SETTINGS',
    'RULE',
    'COMPONENT',
    'NAME',
    'TOTAL_BITS',
    'ADDRESSABLE_BITS',
    'OPCODE_SIZE',
    'INCLUDE',
    'EXCLUDE',
    'FORMAT'
]

tokens = [
    'IDENTIFIER',
    'BINARY',
    'BINARY_VARIABLE',

    'LBRACKET',
    'RBRACKET',
    'DASH',
    'COLON',
    'SLASH',
    'LCURLY',
    'RCURLY',
    'NUMBER',
    'NEWLINE',

    'CPLUSPLUS'
] + reserved

states = (
    ('binary',   'exclusive'),
    ('settings', 'inclusive'),
    ('cpp',      'exclusive')
)

t_ignore                 = r' '
t_cpp_ignore             = r''

t_BINARY                 = r'[01]'
t_BINARY_VARIABLE        = r'[A-Z]'

t_LBRACKET               = r'\['
t_RBRACKET               = r'\]'
t_DASH                   = r'-'
t_COLON                  = r':'
t_SLASH                  = r'/'

t_binary_ignore          = r' '
t_binary_COLON           = r':'
t_binary_BINARY          = r'[01]'
t_binary_BINARY_VARIABLE = r'[A-Z]'
t_binary_DASH            = r'-'

t_settings_NUMBER        = r'[0-9]+'

# for matching a line of c++ code
t_cpp_CPLUSPLUS          = r'\s+.*\n'

def t_IDENTIFIER(t):
    r'[A-Za-z_][A-Za-z_0-9]*'

    # handle reserved keywords that may have been wrongly interpretted as an identifier
    if t.value in reserved:
        t.type = t.value
    
    if t.value in ['INCLUDE', 'EXCLUDE']:
        t.lexer.begin('INITIAL')

    if t.value in ['FORMAT']:
        t.lexer.begin('binary')
    
    if t.value in ['SETTINGS']:
        t.lexer.begin('settings')

    return t

# '{' signifies the beginning of a code block
def t_LCURLY(t):
    r'{'
    t.lexer.push_state('cpp')
    return t

# '}' signifies the end of a code block
def t_cpp_RCURLY(t):
    r'(?<=\n)}'
    t.lexer.pop_state()
    return t

# https://www.dabeaz.com/ply/ply.html#ply_nn23
# Define a rule so we can track line numbers
def t_newline(t):
    r'\n+'
    t.lexer.lineno += 1
    t.type = 'NEWLINE'
    return t

def t_binary_newline(t):
    r'\n+'
    t.lexer.lineno += 1
    t.lexer.begin('INITIAL')
    t.type = 'NEWLINE'
    return t

def t_cpp_newline(t):
    r'\n+'
    t.lexer.lineno += 1
    t.type = 'NEWLINE'
    return t


# On error, we report the illegal character and skip to continue.
# We also set a flag to let the compiler know that it shouldn't
# parse the tokens to ensure they're grammatically correct.
error_found = False

def t_error(t):
    global error_found
    error_found = True

    print('Illegal character "%s"' % t.value[0])
    t.lexer.skip(1)

def t_binary_error(t):
    global error_found
    error_found = True

    print('Illegal character "%s"' % t.value[0])
    t.lexer.skip(1)

def t_cpp_error(t):
    global error_found
    error_found = True

    print('Illegal character "%s"' % t.value[0])
    t.lexer.skip(1)

# set up the lexer
lexer = lex.lex()





############################################ SYNTAX ANALYSIS ############################################
# Here, we generate an AST given the tokens generated beforehand

# Example of a valid complete_rule:
# [RULE RULE1]
# - INCLUDE: 10--
# - EXCLUDE: ---1
# - COMPONENT: ADDRESSING_MODE_1
# - COMPONENT: ADD
# [/RULE]

# And the AST it generates:
# ['RULE', [['INCLUDE', ['1', '0', '-', '-']], 
#           ['EXCLUDE', ['-', '-', '-', '1']], 
#           ['COMPONENT', 'ADDRESSING_MODE_1'], 
#           ['COMPONENT', 'ADD']]

# Example of a valid complete_component:
# [COMPONENT ADDRESSING_MODE_1]
# - FORMAT: 1ABC
# [/COMPONENT]

# And the AST it generates:
# ['COMPONENT', ['1', 'A', 'B', 'C']]

# The default rule - the AST will be full of a collection of "complete_items"
# The following two functions are a list pattern for list_complete_item. One handles the case where
# the list has one item, one where it has many items. This pattern will appear many times.
def p_list_complete_item_single(p):
    'list_complete_item : complete_item'
    p[0] = [p[1]]

def p_list_complete_item_group(p):
    'list_complete_item : list_complete_item complete_item'
    p[0] = p[1] + [p[2]]

def p_complete_item(p):
    '''complete_item : complete_settings
                     | complete_rule
                     | complete_component'''
    p[0] = p[1]

def p_complete_settings(p):
    'complete_settings : settings_header name total_bits addressable_bits opcode_size settings_footer'
    p[0] = ['SETTINGS'] + p[2:6]

def p_settings_header(p):
    'settings_header : LBRACKET SETTINGS RBRACKET NEWLINE'

def p_name(p):
    'name : DASH NAME COLON IDENTIFIER NEWLINE'
    p[0] = ['NAME', p[4]]

def p_total_bits(p):
    'total_bits : DASH TOTAL_BITS COLON NUMBER NEWLINE'
    p[0] = ['TOTAL_BITS', p[4]]

def p_addressable_bits(p):
    'addressable_bits : DASH ADDRESSABLE_BITS COLON NUMBER NEWLINE'
    p[0] = ['ADDRESSABLE_BITS', p[4]]

def p_opcode_size(p):
    'opcode_size : DASH OPCODE_SIZE COLON NUMBER NEWLINE'
    p[0] = ['OPCODE_SIZE', p[4]]

def p_settings_footer(p):
    'settings_footer : LBRACKET SLASH SETTINGS RBRACKET NEWLINE'

def p_complete_rule(p):
    'complete_rule : rule_header list_rule_component rule_footer'
    p[0] = ['RULE', p[1], p[2]]

def p_rule_header(p):
    'rule_header : LBRACKET RULE IDENTIFIER RBRACKET NEWLINE'
    p[0] = p[3]

def p_list_rule_component_single(p):
    'list_rule_component : rule_component'
    p[0] = [p[1]]

def p_list_rule_component_group(p):
    'list_rule_component : list_rule_component rule_component'
    p[0] = p[1] + [p[2]]

def p_rule_component(p):
    '''rule_component : include_statement
                      | exclude_statement
                      | component_statement'''
    p[0] = p[1]

def p_include_statement(p):
    'include_statement : DASH INCLUDE COLON list_binary_item NEWLINE'
    p[0] = ["INCLUDE", p[4]]

def p_list_binary_item_single(p):
    '''list_binary_item : binary_item'''
    p[0] = [p[1]]

def p_list_binary_item_group(p):
    '''list_binary_item : list_binary_item binary_item'''
    p[0] = p[1] + [p[2]]

def p_binary_item(p):
    '''binary_item : BINARY
                   | DASH'''
    p[0] = p[1]

def p_exclude_statement(p):
    'exclude_statement : DASH EXCLUDE COLON list_binary_item NEWLINE'
    p[0] = ["EXCLUDE", p[4]]

def p_component_statement(p):
    'component_statement : DASH COMPONENT COLON IDENTIFIER NEWLINE'
    p[0] = ["COMPONENT", p[4]]

def p_rule_footer(p):
    'rule_footer : LBRACKET SLASH RULE RBRACKET NEWLINE'

def p_complete_component(p):
    'complete_component : component_header format_statement code_statement component_footer'
    p[0] = ["COMPONENT", p[1], p[2], p[3]]

def p_component_header(p):
    'component_header : LBRACKET COMPONENT IDENTIFIER RBRACKET NEWLINE'
    p[0] = p[3]

def p_format_statement(p):
    'format_statement : DASH FORMAT COLON list_formatted_binary_item NEWLINE'
    p[0] = p[4]

def p_code_statement(p):
    'code_statement : LCURLY NEWLINE list_cplusplus RCURLY NEWLINE'
    p[0] = p[3]

def p_list_cplusplus_single(p):
    '''list_cplusplus : CPLUSPLUS'''
    p[0] = [p[1]]

def p_list_cplusplus_group(p):
    '''list_cplusplus : list_cplusplus CPLUSPLUS'''
    p[0] = p[1] + [p[2]]

def p_list_formatted_binary_item_single(p):
    'list_formatted_binary_item : formatted_binary_item'
    p[0] = [p[1]]

def p_list_formatted_binary_item_group(p):
    'list_formatted_binary_item : list_formatted_binary_item formatted_binary_item'
    p[0] = p[1] + [p[2]]

def p_formatted_binary_item(p):
    '''formatted_binary_item : binary_item
                             | BINARY_VARIABLE'''
    p[0] = p[1]

def p_component_footer(t):
    'component_footer : LBRACKET SLASH COMPONENT RBRACKET NEWLINE'

parser = yacc.yacc()





########################################### WELL-FORMEDENESS ###########################################

# Now, we can check the settings, rules, and components lists to make sure they're well-formed. Here are the
# conditions that need to be true in order for these lists to be well-formed.

# ast = [settings | rule | component ...]
# ast is well-formed if:
# 1. it contains only one setting.
# 2. everything it contains is also well-formed.
#
# settings = ['SETTINGS',
#             ['NAME',             name], 
#             ['TOTAL_BITS',       total_bits], 
#             ['ADDRESSABLE_BITS', addressable_bits],
#             ['OPCODE_BITS',      opcode_bits]]
# settings is well-formed if:
# 1. total_bits  >= addressable_bits
# 2. opcode_bits >= total_bits
# 3. an entry exists for name.
#
# rules = [rule ...]
# rules is well-formed if:
# 1. every rule in it is well formed
#
# rule = ['RULE', rule_name, [rule_statement ...]]
# rule is well-formed if:
# 1. every element in rule_statements is well-formed (recall a rule_statement is either include_statement,
#    exclude_statement, or component_statement.
# 2. list_rule_statements has one include-statement
# 3. list_rule_statements has at least one component-statement
# 4. every component-statement in list_rule_statements is compatible with the include-statement
#    there's two cases where incompatibility may occur:
#    a) include specifies a '0' or a '1' where format specifies a '1' or a '0', respectively
#    b) include specifies an 'A-Z' where format specifies a '1' or '0'.
#
# include_statement = ['INCLUDE', binary_sequence]
# include_statement is well-formed if:
# 1. len(binary_sequence) == settings['ADDRESSABLE_BITS']
# 2. every element of binary_sequence is one of: ['0', '1', '-']
#
# exclude_statement = ['EXCLUDE', binary_sequence]
# exclude_statement is well-formed if:
# 1. len(binary_sequence) == settings['ADDRESSABLE_BITS']
# 2. every element of binary_sequence is one of: ['0', '1', '-']
#
# component_statement = ['COMPONENT', component_name, C++] 
# component_statement is well-formed if:
# 1. component_name is defined in a component ONCE (i.e. [COMPONENT component_name] exists)
# NOTE: C++ is just an array of lines of C++ code
#
# component = ['COMPONENT', component_name, formatted_binary_sequence]
# component is well-formed if:
# 1. len(formatted_binary_sequence) == settings['ADDRESSABLE_BITS']
# 2. every element of binary_sequence is one of: ['0', '1', '-', 'A-Z']

# TODO: add a check to make sure all rule includes are unique (i.e., there is no index
# that can match two rules)

# ASSUME: tree is a list_complete_item
def check_cpp_jump_ast(source: list):
    # if this tree is well formed, then it has a well-formed settings.
    # and if this tree has a well-formed settings, then it has a valid addressable_bits
    # and if it has a valid addressable_bits, then by the time this function is done
    # checking all the important parts, this variable must have a value.
    addressable_bits = -1

    # by the end of evaluation, this will be full of all components we have parsed through.
    collected_components = []

    # used in case we need information that we don't have yet for the assertion
    # example: checking requirement #2 of include_statement requires settings to have
    #          already been checked.
    # this is a list of zero-argument lambdas, to defer evaluation of the conditional
    # until we actually go through the pending assertions one by one
    # the first argument is the conditional, and the second argument is the requested
    # error message.
    pending_assertions = []

    # once this gets set to true, it better not be set to true ever again.
    has_settings = False

    def assert_with_error(condition, error):
        if not condition:
            print(error)
            exit(-1)

    def lookup_component(component_name):
        # for now, candidates can't be greater than 1. and i check for this.
        # but, it's important to note that it might be useful to have more than one component
        # with the same name... i might implement a feature like that later.
        # the idea would be that the format would determine which component to use.
        # but this would mean that the two component formats have to be mutually exclusive
        candidates = list(filter(lambda x : x[1] == component_name, collected_components))

        # candidates should never be empty if lookup_component is called after the main for loop
        # of this function ends.
        assert_with_error(len(candidates) == 1, "Error: More than one component defined with name {}".format(component_name))
        return candidates[0]

    # forma = format
    # because format is some kinda key word apparently
    def check_include_format_compatibility(include, forma):
        nonbinary = ['-'] + list(string.ascii_uppercase)

        for item_include, item_format in zip(include, forma):
            assert_with_error(
               not ((item_include == '0' and item_format == '1') or
                    (item_include == '1' and item_format == '0') or
                    (item_include in nonbinary and not item_format in nonbinary)),
               'Error: incompatible include / format: {} / {}'.format(include, forma))
        
        return True

    def check_settings(tree: list):
        assert_with_error(int(tree[2][1]) >= int(tree[3][1]), 
                          'Error: ADDRESSABLE_BITS > TOTAL_BITS')
        assert_with_error(int(tree[4][1]) >= int(tree[2][1]), 
                          'Error: TOTAL_BITS > OPCODE_BITS')
        assert_with_error(not tree[0][1] is None,
                          'Error: Invalid name for settings: {}'.format(tree[0][1]))

        nonlocal addressable_bits
        addressable_bits = int(tree[3][1])
    
    # the conditions for "rules" and "rule" are both checked here
    # makes things simpler.
    def check_rules(tree: list):
        has_include          = False
        has_component        = False

        include_statement    = None
        component_statements = []

        for item in tree[2]:
            if item[0] == 'INCLUDE':
                assert_with_error(not has_include, 'Error: two INCLUDES given for rule {}'.format(tree[1]))
                has_include = True
                include_statement = item

                check_include_statement(item)
            if item[0] == 'EXCLUDE':
                check_exclude_statement(item)
            if item[0] == 'COMPONENT':
                has_component = True
                component_statements.append(item)

                check_component_statement(item)
        
        assert_with_error(has_include,   'Error: no INCLUDE given for rule {}'.format(tree[1]))
        assert_with_error(has_component, 'Error: no COMPONENT given for rule {}'.format(tree[1]))
        
        # much easier to check this after we've already collected relevant information
        # by this point, include_statement should be filled out.
        for item in tree[2]:
            if item[0] == 'COMPONENT':
                # what a mess of an assertion
                # no error is given because check_include_format_compatibility handles that
                # this is unintuitive and needs a rework
                pending_assertions.append([lambda: check_include_format_compatibility(
                    include_statement[1],
                    lookup_component(item[1])[2]),
                    ''])

    
    def check_include_statement(tree: list):
        pending_assertions.append([lambda: len(tree[1]) == addressable_bits,
                                   ('Error: size of binary sequence {} differs from ' +
                                   'ADDRESSABLE_BITS').format(''.join(tree[1]))])
        for item in tree[1]:
            assert_with_error(item in ['0', '1', '-'], 'Error: invalid character in INCLUDE: {}'.format(item))
    
    def check_exclude_statement(tree: list):
        pending_assertions.append([lambda: len(tree[1]) == addressable_bits,
                                   ('Error: size of binary sequence {} differs from ' +
                                   'ADDRESSABLE_BITS').format(''.join(tree[1]))])
        for item in tree[1]:
            assert_with_error(item in ['0', '1', '-'], 'Error: invalid character in EXCLUDE: {}'.format(item))
    
    def check_component_statement(tree: list):
        pending_assertions.append([lambda: [x[1] for x in collected_components].count(tree[1]) != 0,
                                   '''Error: invalid component: {}. You must give it an implementation using [COMPONENT]'''.format(tree[1])])
        pending_assertions.append([lambda: [x[1] for x in collected_components].count(tree[1]) == 1,
                                   'Error: component: {} was defined more than once.'.format(tree[1])])
    
    def check_component(tree: list):
        pending_assertions.append([lambda: len(tree[2]) == addressable_bits,
                                   ('Error: size of binary sequence {} differs from ' +
                                   'ADDRESSABLE_BITS').format(''.join(tree[1]))])
        for item in tree[2]:
            assert_with_error(item in ['0', '1', '-'] + list(string.ascii_uppercase), 
                             'Error: invalid character in FORMAT: {}'.format(item))

        collected_components.append(tree)
    
    # check that the AST is well-formed
    for element in source:
        if element[0] == 'SETTINGS':
            check_settings(element)
            assert_with_error(not has_settings, 'Error: two SETTINGS defined.')
            has_settings = True
        if element[0] == 'RULE':
            check_rules(element)
        if element[0] == 'COMPONENT':
            check_component(element)
    
    for assertion in pending_assertions:
        assert_with_error(assertion[0](), assertion[1])





################################### MAKING THE AST READABLE ###################################

# Now we will map the AST to a series of classes / data structures that will be easier to work with
# Here's some short useful functions to start us off:

# Gets the nth bit of the binary representation of n
def get_nth_bit(value, n):
    return (value >> n) & 1

# Returns True iff for all bits (i, j) in (include, index):
# 1) i == '1' and j == '1'
# 2) i == '0' and j == '0'
# 3) i == '-'
# Note that i represents the include bit, and j represents the bit we're matching against it.
def is_compatible_bits(include, index):
    for k in range(len(include)):
        i = include[k]
        j = str(get_nth_bit(index, k))
        if not ((i == '0' and j == '0') or \
                (i == '1' and j == '1') or \
                (i == '-')):
           return False
    return True

# Now, we deal with Settings: Settings is just going to be a dictionary with the name of each setting as the key
# and the value of the setting as the, well, value. This can be constructed as so:
# NOTE: wf stands for well_formed

def get_settings(ast):
    # Grab the settings. We already know there should only be one, so grabbing list(...)[0] should be okay.
    settings_wf_raw = list(filter(lambda x : x[0] == 'SETTINGS', ast))[0]
    return {
        'NAME':                 settings_wf_raw[1][1],
        'TOTAL_BITS':       int(settings_wf_raw[2][1]),
        'ADDRESSABLE_BITS': int(settings_wf_raw[3][1]),
        'OPCODE_SIZE':      int(settings_wf_raw[4][1])
    }

# Now, we grab all the rules and formalize them in this class:
class Rule:
    def __init__(self, rule_wf):
        # We know there should only be one include because it's wf
        include_statement_wf    = list(filter(lambda x : x[0] == 'INCLUDE',   rule_wf[2]))[0]
        exclude_statements_wf   = list(filter(lambda x : x[0] == 'EXCLUDE',   rule_wf[2]))
        component_statements_wf = list(filter(lambda x : x[0] == 'COMPONENT', rule_wf[2]))
        
        # grab the name, the includes, excludes, and components from the rule_wf
        self.name       = rule_wf[1]
        self.include    = include_statement_wf[1]
        self.excludes   = list(map(lambda x : x[1], exclude_statements_wf))
        self.components = list(map(lambda x : x[1], component_statements_wf))

        # now we reverse the include and excludes because we want the lowest significant bit
        # in the earliest spot in the array, for convenience sake
        self.include.reverse()
        for exclude in self.excludes:
            exclude.reverse()
    
    # A helper method that will return True iff two conditions are true:
    # 1) the include matches the given value
    # 2) the excludes don't match the given value
    def does_match_index(self, value: int):
        # first check the include
        if not is_compatible_bits(self.include, value):
            return False

        # and now the excludes
        for exclude in self.excludes:
            if is_compatible_bits(exclude, value):
                return False
        return True

def get_rules(ast):
    # turn every element of ast that is a rule into a Rule object
    return list(map(Rule, filter(lambda x : x[0] == 'RULE', ast)))

# Finally, we can grab the components and formalize them into this class:
class Component:
    def __init__(self, component_wf):
        self.name   = component_wf[1]
        self.format = component_wf[2]
        self.code   = component_wf[3]

def get_components(ast):
    # turn every element of ast that is a component into a Component object
    return list(map(Component, filter(lambda x : x[0] == 'COMPONENT', ast)))





###################################### TRANSLATING TO CPP ######################################

# And here's the main function that will do all the fancy translating from JPP to CPP. The idea
# is that we start with an empty jumptable, and for each entry we find the rule that corresponds
# to the entry. Then, we use that rule to figure out what components we need. We can infer the
# values of the bit variables given the index of the jumptable that we are currently filling in.
# Then, we apply the bit variables (the @IF() stuff) to the component code, and write the
# whole code to the file.

# Used to determine which rule in rules has an include that matches i. Returns None if there are
# no such matches.
def get_matching_rule(rules, i):
    matching_rules = list(filter(lambda x : x.does_match_index(i), rules))
    if len(matching_rules) == 0:
        return None
    
    # DANGER!
    return matching_rules[0]

# The function that will actually fill in the jumptable
def translate_and_write(settings, rules, components):
    jumptable_size = int(math.pow(2, settings['ADDRESSABLE_BITS']))

    # i will be the current index of the jumptable that we are filling in
    for i in range(jumptable_size):
        rule = get_matching_rule(rules, i)
        if not rule is None:
            print("index {} matches with a rule!".format(i))





##################################### FINALLY THE COMPILER #####################################

# This one's simple. Here's a function you can use to run the compiler:
def compile(file_name):
    with open(file_name, 'r') as f:
        ast = parser.parse(f.read() + '\n')
        check_cpp_jump_ast(ast)

        # get the important bits from the ast
        settings   = get_settings(ast)
        rules      = get_rules(ast)
        components = get_components(ast)

        translate_and_write(settings, rules, components)