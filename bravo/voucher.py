import sys

coins = list(reversed(sorted(int(a) for a in sys.argv[1].split(','))))
target = int(sys.argv[2])

counts = [0]*len(coins)
qty = tuple(counts)
max_total = 0
total = 0

while target > total:
    for pos in range(len(counts)):
        counts[pos] += 1
        total = sum([a*b for a,b in zip(coins, counts)])
        if total <= target:
            if total > max_total:
                max_total = total
                qty = tuple(counts)
            break
        else:
            counts[pos] = 0

print zip(coins, qty), '=', max_total
