from cpp_jump_compiler import compile, lexer

# with open('test.jpp', 'r') as f:
#     lexer.input(f.read() + '\n')
#     for token in lexer:
#         print(token)

compile('test.jpp')