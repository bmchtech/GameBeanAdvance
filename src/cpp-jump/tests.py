import unittest
from cpp_jump_compiler import check_cpp_jump_ast

class TestWellFormedness(unittest.TestCase):
    def test_multiple_settings(self):
        with self.assertRaises(SystemExit):
            check_cpp_jump_ast([['SETTINGS', ['NAMESPACE', 'ARM7TDMI_ARM'], 
                                             ['OPCODE_FORMAT', ['I', 'I', 'D', '-']]],
                                ['SETTINGS', ['NAMESPACE', 'ARM7TDMI_THUMB'], 
                                             ['OPCODE_FORMAT', ['I', 'I', 'D', '-']]]])
    
    def test_settings_malformed_opcode_format(self):
        with self.assertRaises(SystemExit):
            check_cpp_jump_ast([['SETTINGS', ['NAMESPACE', 'ARM7TDMI_THUMB'], 
                                             ['OPCODE_FORMAT', ['I', 'I', 'A', '-']]]])

    def test_rules_no_include_statement(self):
        with self.assertRaises(SystemExit):
            check_cpp_jump_ast([['SETTINGS', ['NAMESPACE', 'ARM7TDMI_ARM'], 
                                             ['OPCODE_FORMAT', ['I', 'I', 'D', '-']]],
                                ['RULE', 'ADC', [['COMPONENT', 'ADDRESSING_MODE_3']]],
                                ['COMPONENT', 'ADDRESSING_MODE_3', ['P', '1', '0', '-'],
                                                 [[[["P", 1]], " int x = 2;\n"]]]])
    
    def test_rules_multiple_include_statement(self):
        with self.assertRaises(SystemExit):
            check_cpp_jump_ast([['SETTINGS', ['NAMESPACE', 'ARM7TDMI_ARM'], 
                                             ['OPCODE_FORMAT', ['I', 'I', 'D', '-']]],
                                ['RULE', 'ADC', [['INCLUDE', ['0', '1', '0', '-']],
                                                 ['INCLUDE', ['0', '1', '0', '-']],
                                                 ['COMPONENT', 'ADDRESSING_MODE_3']]],
                                ['COMPONENT', 'ADDRESSING_MODE_3', ['P', '1', '0', '-'],
                                                 [[[["P", 1]], " int x = 2;\n"]]]])
    
    def test_rules_no_component_statement(self):
        with self.assertRaises(SystemExit):
            check_cpp_jump_ast([['SETTINGS', ['NAMESPACE', 'ARM7TDMI_ARM'], 
                                             ['OPCODE_FORMAT', ['I', 'I', 'D', '-']]],
                                ['RULE', 'ADC', [['INCLUDE', ['0', '1', '0', '-']]]]])
    
    def test_rules_component_incompatible_1(self):
        with self.assertRaises(SystemExit):
            check_cpp_jump_ast([['SETTINGS', ['NAMESPACE', 'ARM7TDMI_ARM'], 
                                             ['OPCODE_FORMAT', ['I', 'I', 'D', '-']]],
                                ['RULE', 'ADC', [['INCLUDE', ['0', '1', '0', '-']],
                                                 ['COMPONENT', 'ADDRESSING_MODE_3']]],
                                ['COMPONENT', 'ADDRESSING_MODE_3', ['P', '1', '1', '-'],
                                                 [[[["P", 1]], " int x = 2;\n"]]]])
    
    def test_rules_component_incompatible_2(self):
        with self.assertRaises(SystemExit):
            check_cpp_jump_ast([['SETTINGS', ['NAMESPACE', 'ARM7TDMI_ARM'], 
                                             ['OPCODE_FORMAT', ['I', 'I', 'D', '-']]],
                                ['RULE', 'ADC', [['INCLUDE', ['0', '1', '-', '-']],
                                                 ['COMPONENT', 'ADDRESSING_MODE_3']]],
                                ['COMPONENT', 'ADDRESSING_MODE_3', ['P', '1', '0', '-'],
                                                 [[[["P", 1]], " int x = 2;\n"]]]])
    
    def test_rules_include_length_mismatched(self):
        with self.assertRaises(SystemExit):
            check_cpp_jump_ast([['SETTINGS', ['NAMESPACE', 'ARM7TDMI_ARM'], 
                                             ['OPCODE_FORMAT', ['I', 'I', 'D', '-']]],
                                ['RULE', 'ADC', [['INCLUDE', ['0', '1', '-']],
                                                 ['COMPONENT', 'ADDRESSING_MODE_3']]],
                                ['COMPONENT', 'ADDRESSING_MODE_3', ['P', '1', '0', '-'],
                                                 [[[["P", 1]], " int x = 2;\n"]]]])
    
    def test_rules_include_invalid_sequence(self):
        with self.assertRaises(SystemExit):
            check_cpp_jump_ast([['SETTINGS', ['NAMESPACE', 'ARM7TDMI_ARM'], 
                                             ['OPCODE_FORMAT', ['I', 'I', 'D', '-']]],
                                ['RULE', 'ADC', [['INCLUDE', ['0', '1', 'A', '-']],
                                                 ['COMPONENT', 'ADDRESSING_MODE_3']]],
                                ['COMPONENT', 'ADDRESSING_MODE_3', ['P', '1', '0', '-'],
                                                 [[[["P", 1]], " int x = 2;\n"]]]])
    
    def test_rules_include_format_mismatch(self):
        with self.assertRaises(SystemExit):
            check_cpp_jump_ast([['SETTINGS', ['NAMESPACE', 'ARM7TDMI_ARM'], 
                                             ['OPCODE_FORMAT', ['I', 'I', 'D', '-']]],
                                ['RULE', 'ADC', [['INCLUDE', ['0', '1', '-', '-']],
                                                 ['COMPONENT', 'ADDRESSING_MODE_3']]],
                                ['COMPONENT', 'ADDRESSING_MODE_3', ['P', '1', '-', '0'],
                                                 [[[["P", 1]], " int x = 2;\n"]]]])
    
    def test_rules_exclude_length_mismatched(self):
        with self.assertRaises(SystemExit):
            check_cpp_jump_ast([['SETTINGS', ['NAMESPACE', 'ARM7TDMI_ARM'], 
                                             ['OPCODE_FORMAT', ['I', 'I', 'D', '-']]],
                                ['RULE', 'ADC', [['INCLUDE', ['0', '1', '0', '-']],
                                                 ['EXCLUDE', ['0', '1', '-']],
                                                 ['COMPONENT', 'ADDRESSING_MODE_3']]],
                                ['COMPONENT', 'ADDRESSING_MODE_3', ['P', '1', '0', '-'],
                                                 [[[["P", 1]], " int x = 2;\n"]]]])
    
    def test_rules_exclude_invalid_sequence(self):
        with self.assertRaises(SystemExit):
            check_cpp_jump_ast([['SETTINGS', ['NAMESPACE', 'ARM7TDMI_ARM'], 
                                             ['OPCODE_FORMAT', ['I', 'I', 'D', '-']]],
                                ['RULE', 'ADC', [['INCLUDE', ['0', '1', '0', '-']],
                                                 ['EXCLUDE', ['0', '1', 'A', '-']],
                                                 ['COMPONENT', 'ADDRESSING_MODE_3']]],
                                ['COMPONENT', 'ADDRESSING_MODE_3', ['P', '1', '0', '-'],
                                                 [[[["P", 1]], " int x = 2;\n"]]]])
    
    def test_rules_exclude_format_mismatch(self):
        with self.assertRaises(SystemExit):
            check_cpp_jump_ast([['SETTINGS', ['NAMESPACE', 'ARM7TDMI_ARM'], 
                                             ['OPCODE_FORMAT', ['I', 'I', 'D', '-']]],
                                ['RULE', 'ADC', [['INCLUDE', ['0', '1', '0', '-']],
                                                 ['EXCLUDE', ['0', '1', '0', '0']],
                                                 ['COMPONENT', 'ADDRESSING_MODE_3']]],
                                ['COMPONENT', 'ADDRESSING_MODE_3', ['P', '1', '0', '-'],
                                                 [[[["P", 1]], " int x = 2;\n"]]]])
    
    def test_rules_component_statement_never_defined(self):
        with self.assertRaises(SystemExit):
            check_cpp_jump_ast([['SETTINGS', ['NAMESPACE', 'ARM7TDMI_ARM'], 
                                             ['OPCODE_FORMAT', ['I', 'I', 'D', '-']]],
                                ['RULE', 'ADC', [['INCLUDE', ['0', '1', '0', '-']],
                                                 ['COMPONENT', 'ADDRESSING_MODE_3']]]])
    
    def test_rules_component_statement_defined_twice(self):
        with self.assertRaises(SystemExit):
            check_cpp_jump_ast([['SETTINGS', ['NAMESPACE', 'ARM7TDMI_ARM'], 
                                             ['OPCODE_FORMAT', ['I', 'I', 'D', '-']]],
                                ['RULE', 'ADC', [['INCLUDE', ['0', '1', '0', '-']],
                                                 ['COMPONENT', 'ADDRESSING_MODE_3']]],
                                ['COMPONENT', 'ADDRESSING_MODE_3', ['P', '1', '0', '-'],
                                                 [[[["P", 1]], " int x = 2;\n"]]],
                                ['COMPONENT', 'ADDRESSING_MODE_3', ['P', '1', 'B', '-'],
                                                 [[[["P", 1]], " int x = 2;\n"]]]])
    
    def test_components_format_length_mismatched(self):
        with self.assertRaises(SystemExit):
            check_cpp_jump_ast([['SETTINGS', ['NAMESPACE', 'ARM7TDMI_ARM'], 
                                             ['OPCODE_FORMAT', ['I', 'I', 'D', '-']]],
                                ['RULE', 'ADC', [['INCLUDE', ['0', '1', '0', '-']],
                                                 ['COMPONENT', 'ADDRESSING_MODE_3']]],
                                ['COMPONENT', 'ADDRESSING_MODE_3', ['P', '1', '-'],
                                                 [[[["P", 1]], " int x = 2;\n"]]]])
    
    def test_components_format_invalid_sequence(self):
        with self.assertRaises(SystemExit):
            check_cpp_jump_ast([['SETTINGS', ['NAMESPACE', 'ARM7TDMI_ARM'], 
                                             ['OPCODE_FORMAT', ['I', 'I', 'D', '-']]],
                                ['RULE', 'ADC', [['INCLUDE', ['0', '1', '0', '-']],
                                                 ['COMPONENT', 'ADDRESSING_MODE_3']]],
                                ['COMPONENT', 'ADDRESSING_MODE_3', ['P', '1', '01', '-'],
                                                 [[[["P", 1]], " int x = 2;\n"]]]])
    
    def test_components_format_bitvariable_in_dash_position(self):
        with self.assertRaises(SystemExit):
            check_cpp_jump_ast([['SETTINGS', ['NAMESPACE', 'ARM7TDMI_ARM'], 
                                             ['OPCODE_FORMAT', ['I', 'I', 'D', '-']]],
                                ['RULE', 'ADC', [['INCLUDE', ['0', '1', '0', '-']],
                                                 ['COMPONENT', 'ADDRESSING_MODE_3']]],
                                ['COMPONENT', 'ADDRESSING_MODE_3', ['P', '1', '-', 'A'],
                                                 [[[["P", 1]], " int x = 2;\n"]]]])
    
    def test_components_format_bitvariable_not_found(self):
        with self.assertRaises(SystemExit):
            check_cpp_jump_ast([['SETTINGS', ['NAMESPACE', 'ARM7TDMI_ARM'], 
                                             ['OPCODE_FORMAT', ['I', 'I', 'D', '-']]],
                                ['RULE', 'ADC', [['INCLUDE', ['0', '1', '0', '-']],
                                                 ['COMPONENT', 'ADDRESSING_MODE_3']]],
                                ['COMPONENT', 'ADDRESSING_MODE_3', ['P', '1', '0', '-'],
                                                 [[[["A", 1]], " int x = 2;\n"]]]])

if __name__ == '__main__':
    unittest.main()