mine_t = open("mine.log").read().split("\n")
nba_t  = open("nba.log") .read().split("\n")

# look for pc
pc_start = "80002e8"
pc_end   = "80002ea"

def get_next_line_with_pc_start(l, start_index):
    i = start_index
    while i < len(l):
        try:
            if l[i].split(" ")[-2] == pc_start:
                return i
            i += 1
        except:
            print(f"fuck word {i}")
            print(l[i])
            exit(-1)
    return -1

current_mine_index = 0
current_nba_index  = 0

current_nba_index  = get_next_line_with_pc_start(nba_t,  current_nba_index )
current_mine_index = get_next_line_with_pc_start(mine_t, current_mine_index)

print(f"begun comparison at {current_nba_index} and {current_mine_index}")
while (nba_t[current_nba_index].split(" ")[-2] != pc_end):
    if nba_t[current_nba_index] != mine_t[current_mine_index]:
        print(f"Error at lines {current_nba_index} and {current_mine_index}")
        exit(-1)
    current_nba_index  += 1
    current_mine_index += 1
print(f"ended comparison at {current_nba_index} and {current_mine_index}")

current_nba_index  = get_next_line_with_pc_start(nba_t,  current_nba_index )
current_mine_index = get_next_line_with_pc_start(mine_t, current_mine_index)

print(f"begun comparison at {current_nba_index} and {current_mine_index}")
while (nba_t[current_nba_index].split(" ")[-2] != pc_end):
    if nba_t[current_nba_index] != mine_t[current_mine_index]:
        print(f"Error at lines {current_nba_index} and {current_mine_index}")
        exit(-1)
    current_nba_index  += 1
    current_mine_index += 1
print(f"ended comparison at {current_nba_index} and {current_mine_index}")