a = open('temp.log', 'r').readlines()
b = list(map(lambda x : x.strip(), a))

c = list(filter(lambda x : all(c in 'abcdef0123456789' for c in x), b))

from itertools import groupby
d = [list(j) for i, j in groupby(c)]

g = []

for f in d:
    g.append((f[0], len(f)))

print(list(filter(lambda x : (x[1] != 4 and x[1] != 5), g)))
