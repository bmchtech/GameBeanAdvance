[RULE RULE1]
- INCLUDE: 10--
- EXCLUDE: ---1
- EXCLUDE: --10
- COMPONENT: ADDRESSING_MODE_1
- COMPONENT: ADD
[/RULE]

[COMPONENT ADDRESSING_MODE_1]
- FORMAT: 1ABC
std::cout << "addressing mode 1" << std::endl;
[/COMPONENT]

[COMPONENT ADD]
- FORMAT: 10AB
std::cout << "add" << std::endl;
[/COMPONENT]