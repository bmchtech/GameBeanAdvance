from copy import copy
                
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
    'NAMESPACE',
    'INCLUDE',
    'EXCLUDE',
    'FORMAT',
    'OPCODE_FORMAT'
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
    'NEWLINE',

    'IF_BEGIN',
    'TRUE_BITVARIABLE',
    'FALSE_BITVARIABLE',
    'IF_END',

    'CPLUSPLUS',
    'WHITESPACE'
] + reserved

states = (
    ('binary',   'exclusive'),
    ('cpp',      'exclusive'),
    ('if',       'exclusive'),
    ('tab',      'exclusive')
)

t_ignore                 = r' '
t_cpp_ignore             = r''
t_tab_ignore             = r''

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

t_if_TRUE_BITVARIABLE    = r'[A-Z]'
t_if_FALSE_BITVARIABLE   = r'![A-Z]'

# for matching a line of c++ code
t_cpp_CPLUSPLUS          = r'[^@\s].*'

t_if_ignore = ' '

def t_cpp_IF_BEGIN(t):
    r'@IF\('
    t.lexer.push_state('if')
    return t

def t_if_IF_END(t):
    r'\)'
    t.lexer.pop_state()
    return t

def t_IDENTIFIER(t):
    r'[A-Za-z_][A-Za-z_0-9]*'

    # handle reserved keywords that may have been wrongly interpretted as an identifier
    if t.value in reserved:
        t.type = t.value
    
    if t.value in ['INCLUDE', 'EXCLUDE']:
        t.lexer.begin('binary')

    if t.value in ['FORMAT', 'OPCODE_FORMAT']:
        t.lexer.begin('binary')

    return t

# '{' signifies the beginning of a code block
def t_LCURLY(t):
    r'{'
    t.lexer.push_state('cpp')
    return t

# '}' signifies the end of a code block
def t_tab_RCURLY(t):
    r'(?<=\n)}'
    t.lexer.pop_state()
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
    t.lexer.push_state('tab')
    t.type = 'NEWLINE'
    return t

def t_tab_WHITESPACE(t):
    r'[ \s]+'
    t.lexer.pop_state()
    t.type = 'WHITESPACE'
    return t

# On error, we report the illegal character and skip to continue.
# We also set a flag to let the compiler know that it shouldn't
# parse the tokens to ensure they're grammatically correct.
error_found = False

def t_error(t):
    t.lexer.skip(1)

def t_binary_error(t):
    t.lexer.skip(1)

def t_cpp_error(t):
    t.lexer.skip(1)

def t_if_error(t):
    t.lexer.skip(1)

def t_tab_error(t):
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

# The default rule - the AST will be full of a collection of 'complete_items'
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
    'complete_settings : settings_header name opcode_format settings_footer'
    p[0] = ['SETTINGS', p[2], p[3]]

def p_settings_header(p):
    'settings_header : LBRACKET SETTINGS RBRACKET NEWLINE'

def p_name(p):
    'name : DASH NAMESPACE COLON IDENTIFIER NEWLINE'
    p[0] = ['NAMESPACE', p[4]]

def p_opcode_format(p):
    'opcode_format : DASH OPCODE_FORMAT COLON list_formatted_binary_item NEWLINE'
    p[0] = ['OPCODE_FORMAT', p[4]]

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
    p[0] = ['INCLUDE', p[4]]

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
    p[0] = ['EXCLUDE', p[4]]

def p_component_statement(p):
    'component_statement : DASH COMPONENT COLON IDENTIFIER NEWLINE'
    p[0] = ['COMPONENT', p[4]]

def p_rule_footer(p):
    'rule_footer : LBRACKET SLASH RULE RBRACKET NEWLINE'

def p_complete_component(p):
    'complete_component : component_header format_statement code_statement component_footer'
    p[0] = ['COMPONENT', p[1], p[2], p[3]]

def p_component_header(p):
    'component_header : LBRACKET COMPONENT IDENTIFIER RBRACKET NEWLINE'
    p[0] = p[3]

def p_format_statement(p):
    'format_statement : DASH FORMAT COLON list_formatted_binary_item NEWLINE'
    p[0] = p[4]

def p_code_statement(p):
    'code_statement : LCURLY NEWLINE list_cplusplus RCURLY NEWLINE'
    p[0] = p[3]

def p_list_cplusplus_single_A(p):
    '''list_cplusplus : WHITESPACE CPLUSPLUS NEWLINE'''
    p[0] = [[[], p[2], p[1]]]

def p_list_cplusplus_single_B(p):
    '''list_cplusplus : WHITESPACE IF_BEGIN list_bitvariable IF_END CPLUSPLUS NEWLINE'''
    p[0] = [[p[3], p[5], p[1]]]

def p_list_cplusplus_group_A(p):
    '''list_cplusplus : list_cplusplus WHITESPACE CPLUSPLUS NEWLINE'''
    p[1].append([[], p[3], p[2]])
    p[0] = p[1]

def p_list_cplusplus_group_B(p):
    '''list_cplusplus : list_cplusplus WHITESPACE IF_BEGIN list_bitvariable IF_END CPLUSPLUS NEWLINE'''
    p[1].append([p[4], p[6], p[2]])
    p[0] = p[1]

def p_list_bitvariable_single(p):
    'list_bitvariable : bitvariable'
    p[0] = [p[1]]

def p_list_bitvariable_group(p):
    'list_bitvariable : list_bitvariable bitvariable'
    p[0] = p[1] + [p[2]]

def p_bitvariable_A(p):
    'bitvariable : TRUE_BITVARIABLE'
    p[0] = [p[1], 1]

def p_bitvariable_B(p):
    'bitvariable : FALSE_BITVARIABLE'
    # we index [1] twice because p[1] = ![A-Z], and we don't want to include the !
    # in the ast.
    p[0] = [p[1][1], 0]

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

def p_error(p):
    global error_found
    error_found = True
    print("Error at {}".format(parser.token()))

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
#             ['NAMESPACE',             name], 
#             ['OPCODE_FORMAT',    opcode_format]]
# settings is well-formed if:
# 1. every occurrence in opcode_format is one of: '-', 'I', 'D',
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
# 3. every element of opcode_format in settings that is a '-' is also a '-' in binary_sequence
#
# exclude_statement = ['EXCLUDE', binary_sequence]
# exclude_statement is well-formed if:
# 1. len(binary_sequence) == settings['ADDRESSABLE_BITS']
# 2. every element of binary_sequence is one of: ['0', '1', '-']
# 3. every element of opcode_format in settings that is a '-' is also a '-' in binary_sequence
#
# component_statement = ['COMPONENT', component_name] 
# component_statement is well-formed if:
# 1. component_name is defined in a component ONCE (i.e. [COMPONENT component_name] exists)
# 2. every element of [cpp_sattement ...] is well_formed
#
# component = ['COMPONENT', component_name, formatted_binary_sequence, [cpp_statement ...]]
# component is well-formed if:
# 1. len(formatted_binary_sequence) == settings['ADDRESSABLE_BITS']
# 2. every element of binary_sequence is one of: ['0', '1', '-', 'A-Z']
# 3. every bit variable in cpp_statement can be found somewhere in formatted_binary_sequence
# 4. every element of opcode_format in settings that is a '-' is also a '-' in binary_sequence
# 5. any bit-variable is at an index that is not marked as '-' in the settings
# NOTE: cpp_statement = [bit_variables C++ leading_whitespace]
# NOTE: there is a way to have this compiler deal with #5 on its own - maybe ill implement it later.
# NOTE: #4 does not have to be checked. It is impossible to write a well-formed ast that only
#       violates condition #4. The reasoning is that if condition #4 is violated, then so is
#       either condition #4 of rule, or condition #3 of include.

# TODO: add a check to make sure all rule includes are unique (i.e., there is no index
# that can match two rules)

# ASSUME: tree is a list_complete_item
def check_cpp_jump_ast(source: list):
    # if this tree is well formed, then it has a well-formed settings.
    # and if this tree has a well-formed settings, then it has a valid opcode_size
    # and if it has a valid opcode_size, then by the time this function is done
    # checking all the important parts, this variable must have a value.
    opcode_size = -1

    # by the end of evaluation, this has a list of indices where "I" shows up in the
    # OPCODE_FORMAT specified in the settings.
    indices_I = []

    # this is just the same as indices_I... but with "-"
    indices_DASH = []

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
        assert_with_error(len(candidates) == 1, 'Error: More than one component defined with name {}'.format(component_name))
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
        for i in range(len(tree[2][1])):
            bit = tree[2][1][i]
            assert_with_error(bit in ['I', 'D', '-'],
                              'Error: invalid bit in settings: {}'.format(bit))
            
            if bit == 'I':
                indices_I.append(i)
            if bit == '-':
                indices_DASH.append(i)

        nonlocal opcode_size
        opcode_size = len(tree[2][1])
    
    # the conditions for 'rules' and 'rule' are both checked here
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
        pending_assertions.append([lambda: len(tree[1]) == opcode_size,
                                   ('Error: size of binary sequence {} differs from ' +
                                   'opcode_size').format(''.join(tree[1]))])
        for i in range(len(tree[1])):
            assert_with_error(tree[1][i] in ['0', '1', '-'], 'Error: invalid character in INCLUDE: {}'.format(tree[1][i]))

            if not tree[1][i] == '-':
                i_copy = copy(i)

                pending_assertions.append([lambda : not i_copy in indices_DASH,
                                           'Error: value {} specified at an index which is not marked as insignificant.'.format(tree[1][i])])
    
    def check_exclude_statement(tree: list):
        pending_assertions.append([lambda: len(tree[1]) == opcode_size,
                                   ('Error: size of binary sequence {} differs from ' +
                                   'opcode_size').format(''.join(tree[1]))])
        for i in range(len(tree[1])):
            assert_with_error(tree[1][i] in ['0', '1', '-'], 'Error: invalid character in EXCLUDE: {}'.format(tree[1][i]))

            if not tree[1][i] == '-':
                i_copy = copy(i)

                pending_assertions.append([lambda : not i_copy in indices_DASH,
                                           'Error: value {} specified at an index which is not marked as insignificant.'.format(tree[1][i])])
    
    def check_component_statement(tree: list):
        pending_assertions.append([lambda: [x[1] for x in collected_components].count(tree[1]) != 0,
                                   '''Error: invalid component: {}. You must give it an implementation using [COMPONENT]'''.format(tree[1])])
        pending_assertions.append([lambda: [x[1] for x in collected_components].count(tree[1]) == 1,
                                   'Error: component: {} was defined more than once.'.format(tree[1])])
    
    def check_component(tree: list):
        pending_assertions.append([lambda: len(tree[2]) == opcode_size,
                                   ('Error: size of binary sequence {} differs from ' +
                                   'opcode_size').format(''.join(tree[2]))])
        for i in range(len(tree[2])):
            assert_with_error(tree[2][i] in ['0', '1', '-'] + list(string.ascii_uppercase), 
                             'Error: invalid character in FORMAT: {}'.format(tree[2][i]))

            # are we a bitvariable?
            if not tree[2][i] in ['0', '1', '-']:
                i_copy = copy(i)

                pending_assertions.append([lambda : not i_copy in indices_DASH,
                                           'Error: bitvariable specified at an index which is specified as a dash bit in the settings.'])

        collected_components.append(tree)
        for cpp_line in tree[3]:
            for bitvariable in cpp_line[0]:
                assert_with_error(bitvariable[0] in tree[2],
                                  'Error: bitvariable {} not found in format statement {}'.format(bitvariable[0], tree[2]))
        
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

# Similarly, sets the nth bit of the binary representation of n and returns it
def set_nth_bit(value, n):
    return value | (1 << n)

# Similarly, clears the nth bit of the binary representation of n and returns it
def clear_nth_bit(value, n):
    return value & (0 << n)

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

# Now, we deal with Settings: Settings is going to decode the OPCODE_FORMAT into something that's
# more easily useable

class Settings:
    def __init__(self, ast):
        # Grab the settings. We already know there should only be one, so grabbing list(...)[0] should be okay.
        settings_wf_raw = list(filter(lambda x : x[0] == 'SETTINGS', ast))[0]
        self.namespace = settings_wf_raw[1][1]

        opcode_format = settings_wf_raw[2][1]
        opcode_format.reverse()

        # These are defined the same way as in check_cpp_jump_ast
        self.indices_I           = [i for i in range(len(opcode_format)) if opcode_format[i] == 'I']
        self.indices_D           = [i for i in range(len(opcode_format)) if opcode_format[i] == 'D']
        self.indices_DASH        = [i for i in range(len(opcode_format)) if opcode_format[i] == '-']

        self.opcode_size      = len(opcode_format)
        self.addressable_bits = len(self.indices_I) + len(self.indices_D)
    
    # given the current iteration, we return the index into the jumptable.
    # this works by taking the iteration and plugging it into the I bits.
    # for example, if the opcode_format is IID-, and we are at iteration
    # x (where x is 2 bits,) then the index we return is x << 2 (because
    # we're shifting x to where the I is located.
    # the discriminator is obtained by the same process, just with D bits
    # instead of I bits.
    def map_iteration_to_index_and_discriminator(self, iteration):
        index         = 0
        discriminator = 0
        current_bit   = 0

        for i in range(self.opcode_size):
            if i in self.indices_I:
                if get_nth_bit(iteration, current_bit) == 1:
                    index = set_nth_bit(index, self.indices_I.index(i))
                current_bit += 1

            if i in self.indices_D:
                if get_nth_bit(iteration, current_bit) == 1:
                    discriminator = set_nth_bit(discriminator, self.indices_D.index(i))
                current_bit += 1
        
        return index, discriminator
    
    # takes the given iteration (which is an assignment of I and D bits)
    # and inflates it to a full opcode, where there are now zeroes in the
    # dash positions
    def inflate_iteration(self, iteration):
        opcode      = 0
        current_bit = 0

        for i in range(self.opcode_size):
            if not i in self.indices_DASH:
                if get_nth_bit(iteration, current_bit) == 1:
                    opcode = set_nth_bit(opcode, i)
                current_bit += 1

        return opcode

def get_settings(ast):
    return Settings(ast)

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
    
        # curse you python, how dare you make 'format' a keyword
        forma = component_wf[2]
        forma.reverse()

        # each element in the code array is an anonymous function that takes in the index into the
        # jumptable and produces the line of code if the index matches the assignments of bitvariables.
        # else, it returns ''
        self.code = []
        for line in component_wf[3]:
            # to break this line of code down:
            # for each bitvariable:
            #     get the nth bit of index that is in the same location as that bitvariable
            #     check if its equal to bitvariable[1] (the given assignment for the bitvariable)
            #     make sure this is true for all bitvariables
            # if the result is true, return the line of code. else, return 0

            self.code.append(self.generate_verifier(line, forma))

    def generate_verifier(self, line, forma):
        # closure for generating an element of self.code

        def check_bit(index, bitvariable):
            return get_nth_bit(index, forma.index(bitvariable[0])) == bitvariable[1]

        bitvariables       = line[0]
        leading_whitespace = line[2]
        line_of_code       = leading_whitespace + line[1] + "\n"
        return lambda x : line_of_code if all([check_bit(x, bitvariable) for bitvariable in bitvariables]) else ''

    # produces code for the given index
    def produce_code(self, index):
        result = []
        for line in self.code:
            result.append(line(index))

        return result
        
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

# Used to find the component with the given name
def find_component_with_name(name, components):
    # We know that because this is wf that a component with the given name *does* exist.
    return next(filter(lambda x : x.name == name, components))

# given an array of discriminators, returns a C++ expression
# to extract the full discriminator from the opcode
def get_expression(discriminators):
    num_contiguous = 0
    starting_index = -1
    expression     = []
    bits_flushed   = 0

    for discriminator in discriminators + [-1]:
        if not discriminator == starting_index + 1:
            shift = starting_index - num_contiguous + 1
            mask  = int(math.pow(2, num_contiguous)) - 1
            expression.append('(((opcode >> {}) & {}) << {})'.format(shift, mask, bits_flushed))
      
            bits_flushed   += num_contiguous
            num_contiguous = 0
            starting_index = discriminator

        num_contiguous += 1
        starting_index = discriminator

    return ' | '.join(expression)

# returns the C++ type that can match the opcode. maximum 64 bits.
# structs can be used to make this higher, but cmon whose heard of
# a computer chip that uses more than 64 bits for its opcode size?
# either way i can remedy this by producing a struct that's large
# enough.
def get_data_type_by_size(data_size):
    if   data_size <= 8:
        return "uint8_t"
    elif data_size <= 16:
        return "uint16_t"
    elif data_size <= 32:
        return "uint32_t"
    elif data_size <= 64:
        return "uint64_t"
    else:
        print("data size too large (given {} bits)! Maximum supported is 64.".format(data_size))

# takes an array of lines of code, and if there is multiple consecutive empty
# lines, it turns them into one giant line instead. this should be done before
# outputing to a file for a complicated aesthetic reason that has to do with the
# @IF blocks.
def beautify_lines_of_code(lines_of_code):
    was_empty_line = False
    beautified_lines_of_code = []

    for line_of_code in lines_of_code:
        if was_empty_line or not line_of_code.isspace():    
            beautified_lines_of_code += line_of_code

        was_empty_line = line_of_code.isspace()
    
    return beautified_lines_of_code
    
# The function that will actually fill in the jumptable
def translate_and_write(settings, rules, components):
    jumptable_size   = int(math.pow(2, len(settings.indices_I)))
    addressable_size = int(math.pow(2, settings.addressable_bits))

    # contains a list of components at each index
    preliminary_jumptable = [[] for i in range(jumptable_size)]

    # i will be the current index of the jumptable that we are filling in
    for i in range(addressable_size):
        #f.write(('void entry_{0:0' + str(settings['ADDRESSABLE_BITS']) + 'b}() {{').format(i))

        rule = get_matching_rule(rules, settings.inflate_iteration(i))

        if not rule is None:
            index, discriminator = settings.map_iteration_to_index_and_discriminator(i)
            preliminary_jumptable[index].append([discriminator, settings.inflate_iteration(i), rule.components])

        # rule = get_matching_rule(rules, i)
        # if not rule is None:
        #     f.write("\n")
        #     # Now we can go through each component
        #     for component_name in rule.components:
        #         component = find_component_with_name(component_name, components)
        #         f.write(component.produce_code(i))

        #f.write('}\n')
        #f.write('\n')

    opcode_type = get_data_type_by_size(settings.opcode_size)

    # assemble the arguments required:
    arguments = [opcode_type + ' opcode']
    arguments_string = ' '.join(arguments)

    # first the header file because frankly it's a lot easier
    # temporary name:
    with open('output.h', 'w+') as f:
        # first the include guard
        f.write('#pragma once\n')
        f.write('\n')

        # then the includes
        f.write('#include <cstdint>\n')
        f.write('\n')

        # the namespace
        f.write('namespace {} {{\n'.format(settings.namespace))

        # then we have the typedef so we can use function pointers in a sane way
        f.write('    typedef void (*instruction)({});\n'.format(opcode_type))
        f.write('\n')

        # now we have the function definitions
        for index in range(jumptable_size):
            f.write(('    void entry_{0:0' + str(len(settings.indices_I)) + 'b}(' + arguments_string + ');\n').format(index))
        f.write('\n')
        f.write('    void execute_instruction({});\n'.format(arguments_string))
        f.write('\n')

        # and the jumptable itself
        f.write('    extern instruction jumptable[];\n')
        f.write('}')

    # temporary name:
    with open('output.cpp', 'w+') as f:
        # first we put some includes...
        f.write('#include <cstdint>\n')
        f.write('#include <iostream>\n')
        f.write('#include "output.h"\n')
        f.write('\n')

        for index in range(jumptable_size):
            # NOTE: If the program uses the variable "discriminator", then this will break.
            #       one remedy is to generate a unique identifier that doesn't match any
            #       of the ones in the given program, but that requires collecting all existing
            #       identifiers. It's probably just easier to just include something in the readme
            #       warning about this.
            # TODO: include something in the readme warning about this
            
            # welcome to this ugliness:
            # population 0 because as soon as i wrote this line i got the hell out of here
            f.write(('void ' + settings.namespace + '::entry_{0:0' + str(len(settings.indices_I)) + 'b}(' + arguments_string + ') {{\n').format(index))
            f.write('    {} discriminator = {};\n'.format(opcode_type, get_expression(settings.indices_D)))
            f.write('\n')
            f.write('    switch (discriminator) {\n')

            for element in preliminary_jumptable[index]:
                discriminator = element[0]
                opcode        = element[1]
                f.write(('        case 0b{0:' + str(len(settings.indices_D)) + 'b}: {{\n').format(discriminator))

                for component_name in element[2]:
                    component = find_component_with_name(component_name, components)
                    code_lines = ['            {}\n'.format(x.strip()) for x in component.produce_code(opcode)]
                    code_lines = beautify_lines_of_code(code_lines)
                    f.write(''.join(code_lines))

                f.write('            break;\n')
                f.write('        }\n')

            f.write('    }\n')
            f.write('}\n')
            f.write('\n')

        # second to last step: provide an implementation for execute_instruction
        passed_in_arguments_string = ' '.join(arguments_string.split(" ")[1::2])
        f.write('void {}::execute_instruction({}) {{\n'.format(settings.namespace, arguments_string))
        indices_expression = get_expression(settings.indices_I)
        f.write('    {}::jumptable[{}]({});\n'.format(settings.namespace, indices_expression, passed_in_arguments_string))
        f.write('}\n')
        f.write('\n')

        # finally to fill in the jumptable addresses
        f.write('{}::instruction {}::jumptable[] = {{\n'.format(settings.namespace, settings.namespace))
        for index in range(jumptable_size):
            f.write(('    &' + settings.namespace + '::entry_{0:0' + str(len(settings.indices_I)) +'b},\n').format(index))
        f.write('};\n')





##################################### FINALLY THE COMPILER #####################################

# This one's simple. Here's a function you can use to run the compiler:
def compile(file_name):
    with open(file_name, 'r') as f:
        ast = parser.parse(f.read() + '\n')
        if error_found:
            exit(-1)

        check_cpp_jump_ast(ast)

        # get the important bits from the ast
        settings   = get_settings(ast)
        rules      = get_rules(ast)
        components = get_components(ast)

        translate_and_write(settings, rules, components)