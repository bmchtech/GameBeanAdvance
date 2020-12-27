import unittest
from cpp_jump_compiler import check_cpp_jump_ast

class TestWellFormedness(unittest.TestCase):
    def test_multiple_settings(self):
        with self.assertRaises(SystemExit):
            check_cpp_jump_ast([['SETTINGS', ['NAME', 'ARM7TDMI_ARM'], 
                                             ['TOTAL_BITS', '16'], 
                                             ['ADDRESSABLE_BITS', '4'], 
                                             ['OPCODE_SIZE', '32']],
                                ['SETTINGS', ['NAME', 'ARM7TDMI_THUMB'],
                                             ['TOTAL_BITS', '8'],
                                             ['ADDRESSABLE_BITS', '8'],
                                             ['OPCODE_SIZE', '16']]])
    
    def test_settings_addressable_greater_than_total(self):
        with self.assertRaises(SystemExit):
            check_cpp_jump_ast([['SETTINGS', ['NAME', 'ARM7TDMI_ARM'], 
                                             ['TOTAL_BITS', '16'], 
                                             ['ADDRESSABLE_BITS', '20'], 
                                             ['OPCODE_SIZE', '32']]])
    
    def test_settings_total_greater_than_opcode(self):
        with self.assertRaises(SystemExit):
            check_cpp_jump_ast([['SETTINGS', ['NAME', 'ARM7TDMI_ARM'], 
                                             ['TOTAL_BITS', '48'], 
                                             ['ADDRESSABLE_BITS', '20'], 
                                             ['OPCODE_SIZE', '32']]])
    
    def test_rules_no_include_statement(self):
        with self.assertRaises(SystemExit):
            check_cpp_jump_ast([['SETTINGS', ['NAME', 'ARM7TDMI_ARM'], 
                                             ['TOTAL_BITS', '16'], 
                                             ['ADDRESSABLE_BITS', '4'], 
                                             ['OPCODE_SIZE', '32']],
                                ['RULE', 'ADC', [['COMPONENT', 'ADDRESSING_MODE_3']]],
                                ['COMPONENT', 'ADDRESSING_MODE_3', ['0', '1', '1', '0']]])
    
    def test_rules_multiple_include_statement(self):
        with self.assertRaises(SystemExit):
            check_cpp_jump_ast([['SETTINGS', ['NAME', 'ARM7TDMI_ARM'], 
                                             ['TOTAL_BITS', '16'], 
                                             ['ADDRESSABLE_BITS', '4'], 
                                             ['OPCODE_SIZE', '32']],
                                ['RULE', 'ADC', [['INCLUDE', ['0', '1', '0', '1']],
                                                 ['INCLUDE', ['0', '1', '0', '1']],
                                                 ['COMPONENT', 'ADDRESSING_MODE_3']]],
                                ['COMPONENT', 'ADDRESSING_MODE_3', ['0', '1', '1', '0']]])
    
    def test_rules_no_component_statement(self):
        with self.assertRaises(SystemExit):
            check_cpp_jump_ast([['SETTINGS', ['NAME', 'ARM7TDMI_ARM'], 
                                             ['TOTAL_BITS', '16'], 
                                             ['ADDRESSABLE_BITS', '4'], 
                                             ['OPCODE_SIZE', '32']],
                                ['RULE', 'ADC', [['INCLUDE', ['0', '1', '0', '1']]]]])
    
    def test_rules_component_incompatible_1(self):
        with self.assertRaises(SystemExit):
            check_cpp_jump_ast([['SETTINGS', ['NAME', 'ARM7TDMI_ARM'], 
                                             ['TOTAL_BITS', '16'], 
                                             ['ADDRESSABLE_BITS', '4'], 
                                             ['OPCODE_SIZE', '32']],
                                ['RULE', 'ADC', [['INCLUDE', ['0', '1', '0', '1']],
                                                 ['COMPONENT', 'ADDRESSING_MODE_3']]],
                                ['COMPONENT', 'ADDRESSING_MODE_3', ['0', '1', '0', '0']]])
    
    def test_rules_component_incompatible_2(self):
        with self.assertRaises(SystemExit):
            check_cpp_jump_ast([['SETTINGS', ['NAME', 'ARM7TDMI_ARM'], 
                                             ['TOTAL_BITS', '16'], 
                                             ['ADDRESSABLE_BITS', '4'], 
                                             ['OPCODE_SIZE', '32']],
                                ['RULE', 'ADC', [['INCLUDE', ['0', '1', '-', '0']],
                                                 ['COMPONENT', 'ADDRESSING_MODE_3']]],
                                ['COMPONENT', 'ADDRESSING_MODE_3', ['0', '1', '0', '0']]])
    
    def test_rules_include_length_mismatched(self):
        with self.assertRaises(SystemExit):
            check_cpp_jump_ast([['SETTINGS', ['NAME', 'ARM7TDMI_ARM'], 
                                             ['TOTAL_BITS', '16'], 
                                             ['ADDRESSABLE_BITS', '4'], 
                                             ['OPCODE_SIZE', '32']],
                                ['RULE', 'ADC', [['INCLUDE', ['0', '1', '0']],
                                                 ['COMPONENT', 'ADDRESSING_MODE_3']]],
                                ['COMPONENT', 'ADDRESSING_MODE_3', ['0', '1', '0', '0']]])
    
    def test_rules_include_invalid_sequence(self):
        with self.assertRaises(SystemExit):
            check_cpp_jump_ast([['SETTINGS', ['NAME', 'ARM7TDMI_ARM'], 
                                             ['TOTAL_BITS', '16'], 
                                             ['ADDRESSABLE_BITS', '4'], 
                                             ['OPCODE_SIZE', '32']],
                                ['RULE', 'ADC', [['INCLUDE', ['0', '1', 'A', '0']],
                                                 ['COMPONENT', 'ADDRESSING_MODE_3']]],
                                ['COMPONENT', 'ADDRESSING_MODE_3', ['0', '1', '0', '0']]])
    
    def test_rules_exclude_length_mismatched(self):
        with self.assertRaises(SystemExit):
            check_cpp_jump_ast([['SETTINGS', ['NAME', 'ARM7TDMI_ARM'], 
                                             ['TOTAL_BITS', '16'], 
                                             ['ADDRESSABLE_BITS', '4'], 
                                             ['OPCODE_SIZE', '32']],
                                ['RULE', 'ADC', [['INCLUDE', ['0', '1', '0', '0']],
                                                 ['EXCLUDE', ['0', '1', '0']],
                                                 ['COMPONENT', 'ADDRESSING_MODE_3']]],
                                ['COMPONENT', 'ADDRESSING_MODE_3', ['0', '1', '0', '0']]])
    
    def test_rules_exclude_invalid_sequence(self):
        with self.assertRaises(SystemExit):
            check_cpp_jump_ast([['SETTINGS', ['NAME', 'ARM7TDMI_ARM'], 
                                             ['TOTAL_BITS', '16'], 
                                             ['ADDRESSABLE_BITS', '4'], 
                                             ['OPCODE_SIZE', '32']],
                                ['RULE', 'ADC', [['INCLUDE', ['0', '1', '0', '0']],
                                                 ['EXCLUDE', ['0', '1', 'A', '0']],
                                                 ['COMPONENT', 'ADDRESSING_MODE_3']]],
                                ['COMPONENT', 'ADDRESSING_MODE_3', ['0', '1', '0', '0']]])
    
    def test_rules_component_statement_never_defined(self):
        with self.assertRaises(SystemExit):
            check_cpp_jump_ast([['SETTINGS', ['NAME', 'ARM7TDMI_ARM'], 
                                             ['TOTAL_BITS', '16'], 
                                             ['ADDRESSABLE_BITS', '4'], 
                                             ['OPCODE_SIZE', '32']],
                                ['RULE', 'ADC', [['INCLUDE', ['0', '1', '0', '0']],
                                                 ['COMPONENT', 'ADDRESSING_MODE_3']]]])
    
    def test_rules_component_statement_defined_twice(self):
        with self.assertRaises(SystemExit):
            check_cpp_jump_ast([['SETTINGS', ['NAME', 'ARM7TDMI_ARM'], 
                                             ['TOTAL_BITS', '16'], 
                                             ['ADDRESSABLE_BITS', '4'], 
                                             ['OPCODE_SIZE', '32']],
                                ['RULE', 'ADC', [['INCLUDE', ['0', '1', '0', '0']],
                                                 ['COMPONENT', 'ADDRESSING_MODE_3']]],
                                ['COMPONENT', 'ADDRESSING_MODE_3', ['0', '1', '0', '0']],
                                ['COMPONENT', 'ADDRESSING_MODE_3', ['0', '1', '1', '0']]])
    
    def test_components_format_length_mismatched(self):
        with self.assertRaises(SystemExit):
            check_cpp_jump_ast([['SETTINGS', ['NAME', 'ARM7TDMI_ARM'], 
                                             ['TOTAL_BITS', '16'], 
                                             ['ADDRESSABLE_BITS', '4'], 
                                             ['OPCODE_SIZE', '32']],
                                ['RULE', 'ADC', [['INCLUDE', ['0', '1', '0', '0']],
                                                 ['COMPONENT', 'ADDRESSING_MODE_3']]],
                                ['COMPONENT', 'ADDRESSING_MODE_3', ['0', '1', '0']]])
    
    def test_components_format_invalid_sequence(self):
        with self.assertRaises(SystemExit):
            check_cpp_jump_ast([['SETTINGS', ['NAME', 'ARM7TDMI_ARM'], 
                                             ['TOTAL_BITS', '16'], 
                                             ['ADDRESSABLE_BITS', '4'], 
                                             ['OPCODE_SIZE', '32']],
                                ['RULE', 'ADC', [['INCLUDE', ['0', '1', '0', '0']],
                                                 ['COMPONENT', 'ADDRESSING_MODE_3']]],
                                ['COMPONENT', 'ADDRESSING_MODE_3', ['0', '1', '0', '01']]])

if __name__ == '__main__':
    unittest.main()



# if len(sys.argv) < 2:
#     print("Usage: python {} <file_name>".format(sys.argv[0]))
#     exit(-1)
    
# with open(sys.argv[1], 'r') as f:
#     ast = parser.parse(f.read() + '\n')