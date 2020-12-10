import sys

class ReachedMax(Exception): pass

def incr(counts, coins, max_cap):
    for i in range(len(counts)):
        counts[i] += 1
        if sum(x*c for x, c in zip(counts, coins)) > max_cap:
            counts[i] = 0
        else:
            return
    raise ReachedMax

def find_combo(coins, target):
    counts = [0] * len(coins)
    while sum(x*c for x, c in zip(counts, coins)) != target:
        try:
            incr(counts, coins, target)
        except ReachedMax:
            find_combo(coins, target-1)
            return
    print counts


find_combo([int(s) for s in sys.argv[1].split(',')], int(sys.argv[2]))
