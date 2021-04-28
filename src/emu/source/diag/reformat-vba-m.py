import sys

lines = open(sys.argv[1], 'r').readlines()

output = []

for line in lines:
    elements = line.split(" ")
    if elements[0] == 'THM':
        elements[0] = "THUMB"
        elements[1] = '    ' + elements[1][2:].rjust(4, '0')
        elements[17] = hex(int(elements[17], 16) - 2)[2:]
    else: # elements[0] == 'ARM'
        elements[0] = 'ARM  '
        elements[1] = elements[1][2:].rjust(8, '0')
        elements[17] = hex(int(elements[17], 16) - 4)[2:]
    
    for i in range(2, len(elements)):
        elements[i] = elements[i].rjust(8, '0')

    elements.insert(2,  '|')
    elements = elements[:-2]

    elements = elements[0:2] + list(map(lambda a : a.strip(), elements[2:]))
    elements.append(' \n')
    output.append(elements)

f = open(sys.argv[2], 'w+')
for line in output:
    f.write(' '.join(line))