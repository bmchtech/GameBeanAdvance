import ply.lex  as lex
import ply.yacc as yacc
import string

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
# - FORMAT 010011B10010]
# @IF( B) uint32_t result = 2;
# @IF(!B) uint32_t result = 3;
# [/COMPONENT]
#
#
# In this example, whenever the ADD Component is used, if the B bit happens to be 1, then only
# the line 'uint32_t result = 2;' is added. If the B bit is 0, then only the line 'uint32_t 
# result = 3;' is added. This can be used to make program flow dependent on the values of certain
# bits in the instruction.
#

# EBNF for C++ Jump. Note that <C++> denotes valid C++ code as described above.
#
# <rule>                 ::= <rule-header> <include> <exclude>* <component>+ <rule-footer>
# <component>            ::= <component-header> <format> <C++> <component-footer>
#
# <rule-header>          ::= [RULE <rule-name>]
# <include>              ::= - INCLUDE: <binary-sequence>
# <exclude>              ::= - EXCLUDE: <binary-sequence>
# <component>            ::= - COMPONENT <component-name>
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
    'RULE',
    'COMPONENT',
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
    'NEWLINE'
] + reserved

states = (
    ('binary', 'exclusive'),
)

t_ignore          = r' '

t_BINARY          = r'[01]'
t_BINARY_VARIABLE = r'[A-Z]'

t_LBRACKET        = r'\['
t_RBRACKET        = r'\]'
t_DASH            = r'-'
t_COLON           = r':'
t_SLASH           = r'/'

t_binary_ignore   = r' '
t_binary_COLON    = r':'
t_binary_BINARY          = r'[01]'
t_binary_BINARY_VARIABLE = r'[A-Z]'
t_binary_DASH            = r'-'

def t_IDENTIFIER(t):
    r'[A-Za-z_][A-Za-z_0-9]*'

    # handle reserved keywords that may have been wrongly interpretted as an identifier
    if t.value in reserved:
        t.type = t.value
    
    if t.value in ['FORMAT']:
        t.lexer.begin('binary')

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
    '''list_complete_item : complete_item'''
    p[0] = [p[1]]

def p_list_complete_item_group(p):
    '''list_complete_item : list_complete_item complete_item'''
    p[0] = p[1] + [p[2]]

def p_complete_item(p):
    '''complete_item : complete_rule
                     | complete_component'''
    p[0] = p[1]

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
    'complete_component : component_header format_statement component_footer'
    p[0] = ["COMPONENT", p[1], p[2]]

def p_component_header(p):
    'component_header : LBRACKET COMPONENT IDENTIFIER RBRACKET NEWLINE'
    p[0] = p[3]

def p_format_statement(p):
    'format_statement : DASH FORMAT COLON list_formatted_binary_item NEWLINE'
    p[0] = p[4]

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

ast = None
with open('test.cpp', 'r') as f:
    ast = parser.parse(f.read() + '\n')





########################################### WELL-FORMEDENESS ###########################################

# C++ Jump AST is well-formed if:
# 1. it is a list of well-formed rules and well-formed components
#
# A Rule is well-formed if:
# 1. it contains          one well-formed include  statement
# 2. it contains at least one well-formed exclude  statement 
# 3. it contains at least one well-formed component statement
# 4. the length of the binary sequences in all include/exclude statements are equal
#
# An include statement is well-formed if:
# 1. its binary sequence is made up of only 0s, 1s, and -s.
# 
# An exclude statement is well-formed if:
# 1. its binary sequence is made up of only 0s, 1s, and -s.
#
# A component statement is well-formed if:
# 1. its identifier is bound (i.e. there exists a well-formed component that matches the identifier)
#
# A component is well-formed if:
# 1. its format statement is well-formed

# ASSUME: tree is a list_complete_item
def check_cpp_jump_ast(source: list):
    bound_component_identifiers     = []
    requested_component_identifiers = []

    # ASSUME: tree is a complete_rule
    def check_rule(tree: list):
        has_include   = False
        has_exclude   = False
        has_component = False

        for statement in tree[2]:
            if (statement[0] == 'INCLUDE'):   
                check_include_statement(statement)
                has_include = True
            if (statement[0] == 'EXCLUDE'):
                has_exclude = True
                check_exclude_statement(statement)
            if (statement[0] == 'COMPONENT'):
                has_component = True 
                check_component_statement(statement)

    # ASSUME: tree is an include_statement
    def check_include_statement(tree: list):
        check_binary_sequence(tree[1])

    # ASSUME: tree is an exclude_statement
    def check_exclude_statement(tree: list):
        check_binary_sequence(tree[1])

    # ASSUME: tree is a binary_sequence
    def check_binary_sequence(tree: list):
        for element in tree:
            if not element in ['0', '1', '-']:
                print("Malformed binary sequence: {}" + element)
                exit(-1)

    # ASSUME: tree is a component_statement
    # This function will add the identifier to requsted_component_identifiers.
    # The outer function will check that this identifier is bound once everything 
    # else has been deemed as well-formed.
    def check_component_statement(tree: list):
        requested_component_identifiers.append(tree[1])

    # ASSUME: tree is a component
    def check_component(tree: list):
        check_formatted_binary_sequence(tree[2])
        bound_component_identifiers.append(tree[1])
    
    # ASSUME: tree is a formatted_binary_sequence
    def check_formatted_binary_sequence(tree: list):
        for element in tree:
            if not element in ['0', '1', '-'] + list(string.ascii_uppercase):
                print("Malformed formatted binary sequence: {}".format(element))
                exit(-1)

    for item in source:
        if (item[0] == 'RULE'): 
            check_rule(item)
        if (item[0] == 'COMPONENT'):
            check_component(item)

    for component in requested_component_identifiers:
        if not component in bound_component_identifiers:
            print("Rule component {} does not have a definition.".format(component))
            exit(-1)

check_cpp_jump_ast(ast)