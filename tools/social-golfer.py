#!/usr/bin/env python3
"""
Resolvable 2-(28,4,1) design (social golfer: 28 players, fours, 9 rounds).

Strategy:
  1. Construct candidate 2-(28,4,1) designs algebraically:
       (a) Hermitian unital H(3): points of the Hermitian curve in PG(2,9),
           blocks = secant-line intersections.
       (b) Ree unital R(3): points = the 28 Sylow-3 subgroups of PSL(2,8),
           blocks = fixed-point sets of the 63 involutions (P in block of t
           iff t normalizes P).
  2. Check the 2-(28,4,1) property in code (63 blocks, size 4, every pair once).
  3. Exact backtracking search for a resolution: partition the 63 blocks into
     9 parallel classes (each a partition of the 28 points).
  4. Full independent verification of the final schedule, then print.
"""
import itertools
from collections import Counter

FULL = (1 << 28) - 1

# ---------------------------------------------------------------------------
# GF(9) = GF(3)[i]/(i^2+1); elements are pairs (a,b) meaning a + b*i
# ---------------------------------------------------------------------------
GF9 = [(a, b) for a in range(3) for b in range(3)]
ZERO = (0, 0)

def add9(x, y): return ((x[0] + y[0]) % 3, (x[1] + y[1]) % 3)
def mul9(x, y):
    a, b = x; c, d = y
    return ((a * c - b * d) % 3, (a * d + b * c) % 3)
def norm9(x):  # x * x^3 = x^4 = a^2 + b^2  (in GF(3))
    return (x[0] * x[0] + x[1] * x[1]) % 3

def pg2_points():
    """Normalized representatives of the 91 points of PG(2,9)."""
    pts = []
    one = (1, 0)
    for y in GF9:
        for z in GF9:
            pts.append((one, y, z))
    for z in GF9:
        pts.append((ZERO, one, z))
    pts.append((ZERO, ZERO, one))
    assert len(pts) == 91
    return pts

def hermitian_unital_blocks():
    pts = pg2_points()
    unital = [i for i, p in enumerate(pts)
              if (norm9(p[0]) + norm9(p[1]) + norm9(p[2])) % 3 == 0]
    assert len(unital) == 28, f"expected 28 unital points, got {len(unital)}"
    label = {pi: k for k, pi in enumerate(unital)}

    def dot(L, P):
        s = ZERO
        for l, p in zip(L, P):
            s = add9(s, mul9(l, p))
        return s

    blocks, tangents = [], 0
    for L in pts:  # dual coordinates: same normalized triples
        on = [label[i] for i, P in enumerate(pts)
              if dot(L, P) == ZERO and i in label]
        if len(on) == 4:
            blocks.append(frozenset(on))
        elif len(on) == 1:
            tangents += 1
        elif len(on) != 0:
            raise AssertionError(f"line meets unital in {len(on)} points")
    assert tangents == 28 and len(blocks) == 63, (tangents, len(blocks))
    return blocks

# ---------------------------------------------------------------------------
# PSL(2,8) acting on PG(1,8) (9 symbols: field elements 0..7, infinity = 8)
# GF(8) = GF(2)[t]/(t^3+t+1), elements encoded as ints 0..7 (bit polynomials)
# ---------------------------------------------------------------------------
def gf8_mul(a, b):
    r = 0
    for bit in range(3):
        if (b >> bit) & 1:
            r ^= a << bit
    # reduce mod t^3 + t + 1
    for deg in (5, 4, 3):
        if (r >> deg) & 1:
            r ^= (1 << deg) | (0b011 << (deg - 3))
    return r

def gf8_inv(a):
    for x in range(1, 8):
        if gf8_mul(a, x) == 1:
            return x
    raise ValueError

INF = 8

def ree_unital_blocks():
    # generating permutations of PSL(2,8) = PGL(2,8) on 9 points
    def perm(f):
        return tuple(f(x) for x in range(9))
    g_add = perm(lambda x: x if x == INF else x ^ 1)                 # x -> x+1
    g_mul = perm(lambda x: x if x == INF else gf8_mul(2, x))         # x -> t*x
    g_inv = perm(lambda x: INF if x == 0 else (0 if x == INF else gf8_inv(x)))

    ident = tuple(range(9))
    def comp(p, q):  # p after q
        return tuple(p[q[i]] for i in range(9))

    group = {ident}
    frontier = [ident]
    gens = [g_add, g_mul, g_inv]
    while frontier:
        nxt = []
        for e in frontier:
            for g in gens:
                c = comp(g, e)
                if c not in group:
                    group.add(c)
                    nxt.append(c)
        frontier = nxt
    assert len(group) == 504, len(group)

    def order(p):
        k, c = 1, p
        while c != ident:
            c = comp(c, p)
            k += 1
        return k

    order9 = [p for p in group if order(p) == 9]
    invols = [p for p in group if order(p) == 2]
    assert len(invols) == 63, len(invols)

    sylows = set()
    for s in order9:
        sub = set()
        c = ident
        while True:
            sub.add(c)
            c = comp(c, s)
            if c == ident:
                break
        sylows.add(frozenset(sub))
    sylows = sorted(sylows, key=lambda S: sorted(S))
    assert len(sylows) == 28, len(sylows)

    gens9 = [next(iter(p for p in S if order(p) == 9)) for S in sylows]
    blocks = []
    for t in invols:  # t^-1 = t
        blk = frozenset(i for i, s in enumerate(gens9)
                        if comp(comp(t, s), t) in sylows[i])
        blocks.append(blk)
    return blocks

# ---------------------------------------------------------------------------
# Design property check: is `blocks` a 2-(28,4,1) design?
# ---------------------------------------------------------------------------
def check_design(blocks):
    if len(blocks) != 63:
        return False, f"block count {len(blocks)} != 63"
    if any(len(b) != 4 for b in blocks):
        return False, "block of size != 4"
    pc = Counter()
    for b in blocks:
        for pair in itertools.combinations(sorted(b), 2):
            pc[pair] += 1
    if len(pc) != 378 or any(v != 1 for v in pc.values()):
        bad = sum(1 for v in pc.values() if v != 1)
        return False, f"pairs covered: {len(pc)}/378, multiply-covered: {bad}"
    return True, "ok"

# ---------------------------------------------------------------------------
# Resolution search: exact backtracking partition of blocks into 9 classes
# ---------------------------------------------------------------------------
class Nodes:
    def __init__(self, limit): self.n, self.limit = 0, limit

def find_resolution(blocks, node_limit=30_000_000):
    bits = [sum(1 << p for p in b) for b in blocks]
    by_point = [[i for i, b in enumerate(blocks) if p in b] for p in range(28)]
    nodes = Nodes(node_limit)

    def extend(covered, cls, avail):
        nodes.n += 1
        if nodes.n > nodes.limit:
            raise TimeoutError("node limit")
        if covered == FULL:
            rest = solve(avail)
            return None if rest is None else [cls] + rest
        low = (~covered & FULL)
        p = (low & -low).bit_length() - 1  # lowest uncovered point
        for bi in by_point[p]:
            if bi in avail and not (bits[bi] & covered):
                avail.discard(bi)
                r = extend(covered | bits[bi], cls + [bi], avail)
                avail.add(bi)
                if r is not None:
                    return r
        return None

    def solve(avail):
        if not avail:
            return []
        a = min(avail)
        return extend(bits[a], [a], avail - {a})

    try:
        res = solve(set(range(63)))
    except TimeoutError:
        return None, nodes.n, True
    return res, nodes.n, False

# ---------------------------------------------------------------------------
# Full independent verification of the final 9-round schedule
# ---------------------------------------------------------------------------
def verify_schedule(rounds):
    teams = [g for r in rounds for g in r]
    n_teams_ok = (len(teams) == 63) and all(len(set(g)) == 4 for g in teams)

    player_ct = Counter(p for g in teams for p in g)
    each_player_9 = (set(player_ct) == set(range(28))
                     and all(v == 9 for v in player_ct.values()))

    pair_ct = Counter(pair for g in teams
                      for pair in itertools.combinations(sorted(g), 2))
    pair_count = len(pair_ct)
    all_once = (pair_count == 378 and all(v == 1 for v in pair_ct.values())
                and pair_ct.keys() == set(itertools.combinations(range(28), 2)))

    each_round_partition = (len(rounds) == 9 and all(
        len(r) == 7 and sorted(p for g in r for p in g) == list(range(28))
        for r in rounds))

    return n_teams_ok, each_player_9, pair_count, all_once, each_round_partition

# ---------------------------------------------------------------------------
def main():
    for name, ctor in (("Hermitian unital H(3)", hermitian_unital_blocks),
                       ("Ree unital R(3)", ree_unital_blocks)):
        blocks = ctor()
        ok, msg = check_design(blocks)
        print(f"{name}: 2-(28,4,1) check -> {ok} ({msg})")
        if not ok:
            continue
        res, nodes, timed_out = find_resolution(blocks)
        if res is None:
            why = "node limit hit" if timed_out else "exhaustive search: none exists"
            print(f"{name}: NO resolution found ({why}, {nodes} nodes)")
            continue
        print(f"{name}: resolution FOUND ({nodes} search nodes)")

        rounds = [sorted((sorted(blocks[bi]) for bi in cls), key=lambda g: g[0])
                  for cls in res]

        t_ok, p9, pc, once, part = verify_schedule(rounds)
        print("--- verification ---")
        print(f"teams = 63, all size 4      : {t_ok}")
        print(f"pair count                  : {pc}")
        print(f"all pairs exactly once      : {once}")
        print(f"each player exactly 9 teams : {p9}")
        print(f"each round partitions 0..27 : {part}")
        if not (t_ok and once and p9 and part):
            print("VERIFICATION FAILED — not printing schedule")
            return 1
        print("--- schedule ---")
        for i, r in enumerate(rounds, 1):
            print(f"Round {i}: " + " ".join("[" + ",".join(map(str, g)) + "]"
                                            for g in r))
        return 0
    print("No resolvable design found from these constructions.")
    return 2

if __name__ == "__main__":
    raise SystemExit(main())
