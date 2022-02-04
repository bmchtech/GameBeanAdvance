import sys
import itertools

expected = open(sys.argv[1], 'r').readlines()
actual   = open(sys.argv[2], 'r').readlines()

# do a pc analysis. easiest bugs to find are the ones where we simply dont run a set of code that
# the expected output shows should be run.
expected_pcs = list(map(lambda x : x.strip().split(" ")[-1], expected))
actual_pcs   = list(map(lambda x : x.strip().split(" ")[-1], actual))

expected_pcs = list(set(expected_pcs))
actual_pcs   = list(set(actual_pcs))

print("Running PC Analysis...")
pcs_not_found = []
for pc in expected_pcs:
    if not pc in actual_pcs:
        # personal constraints:
        if (int(pc, 16) & 0xFF000000) == 0x00000000:
            continue
        
        if (int(pc, 16) & 0xFF000000) == 0x03000000:
            continue

        pcs_not_found.append(int(pc, 16))

pcs_not_found.sort()

ranged_pcs_not_found = []

previous_pc = -1
start_range = -1
range_len   = -1
for pc in pcs_not_found:
    if pc == previous_pc + 2 or pc == previous_pc + 4 or pc == previous_pc:
        range_len += (pc - previous_pc)
    else:
        ranged_pcs_not_found.append((start_range, range_len))

        range_len = 0
        start_range = pc
    
    previous_pc = pc
pcs_not_found = pcs_not_found[1:]

print("\nResults:")
for r in ranged_pcs_not_found:
    start = '{0:#010x}'.format(r[0])
    end   = '{0:#010x}'.format(r[0] + r[1])
    
    print("PCs in Range: {} to {} were not found.".format(start, end))

print("PC Analysis Complete")