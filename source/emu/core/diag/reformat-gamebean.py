import sys

lines = open(sys.argv[1], 'r').readlines()

output = []

for line in lines:
    elements = line.split(" ")
    elements = elements[:-2]
    elements.append('\n')
    output.append(elements)

f = open(sys.argv[2], 'w+')
for line in output:
    f.write(' '.join(line))