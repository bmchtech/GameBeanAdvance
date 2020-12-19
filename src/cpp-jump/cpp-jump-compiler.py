import ply.lex  as lex
import ply.yacc as yacc

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
    p[0] = [p[1], p[2]]

def p_rule_header(p):
    'rule_header : LBRACKET RULE IDENTIFIER RBRACKET NEWLINE'
    p[0] = p[2]

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
    p[0] = ["COMPONENT", p[2]]

def p_component_header(p):
    'component_header : LBRACKET COMPONENT IDENTIFIER RBRACKET NEWLINE'

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

print(ast)

############################################ Syntax Checking ############################################
