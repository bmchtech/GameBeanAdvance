import ply.lex as lex

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
# Includes can get more complicated. For example, you can have a "-" in the binary expression,
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
# of the C++ code block. This can be achieved using "@IF()" statements within the C++ code block.
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
# the line "uint32_t result = 2;" is added. If the B bit is 0, then only the line "uint32_t 
# result = 3;" is added. This can be used to make program flow dependent on the values of certain
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

# here's some regex to help match the above, as well as some associated tokens

tokens = [
    'RULE_HEADER',
    'INCLUDE',
    'EXCLUDE',
    'COMPONENT'
    'RULE_END',

    'COMPONENT_HEADER',
    'FORMAT',
    'COMPONENT_END'
]

t_ignore  = ' \t'    # ignores spaces and tabs

t_RULE_HEADER    = r'\[RULE RULE1]'
INCLUDE          = r'\- INCLUDE: ([01\-]+)'
EXCLUDE          = r'\- EXCLUDE: ([01\-]+)'
COMPONENT        = r'\- COMPONENT: ([A-Za-z_]+)'
RULE_FOOTER      = r'\[/RULE]'

COMPONENT_HEADER = r'\[COMPONENT ([A-Za-z_]+)]'
FORMAT_REGEX     = r'\- FORMAT: ([01A-Z\-]+)'
COMPONENT_FOOTER = r'\[/COMPONENT]'

# Define a rule so we can track line numbers
def t_newline(t):
    r'\n+'
    t.lexer.lineno += len(t.value)

lexer = lex.lex()
with open("test.cpp", 'r') as f:
    lexer.input(f.read())
    
# tokenize
while True:
    tok = lexer.token()