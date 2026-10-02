"""Ascension strategy comparison (CORE-GAME v2 section 6). Average player, 8 hours of play.
Rules: Ascension n+1 needs the run to clear depth ASC_DEPTH[n] (4,5,5,6,6,7,7,8,8, then Infinity 1,2,...);
it pays 1 shard + 1 per x100 of peak power beyond that boss's power;
power x (1 + 0.5 x shards). Kept: spirits, slots, shards. Reset: power, coins, zones, stones, forms."""
import json, statistics as st
from economy import Player, ZONES, fmt
gates = json.load(open("gates.json"))["gates"]

def play(policy_depth, seed, hours=8, profile="average"):
    pl = Player(profile, gates, seed)
    first8 = None
    while pl.t < hours * 3600:
        pl.step(); pl.boss()
        if pl.deepest >= 8 and first8 is None: first8 = pl.t
        if pl.can_ascend() and pl.shards_now() >= policy_depth:
            pl.ascend()
    return pl, first8

def first_hours(seed, hours=2, policy=2):
    pl = Player("average", gates, seed); log = []
    while pl.t < hours * 3600:
        before = set(pl.ev)
        pl.step(); pl.boss()
        if pl.can_ascend() and pl.shards_now() >= policy:
            pl.ascend()
        for k in set(pl.ev) - before: log.append((pl.ev[k], k))
    return sorted(log)

if __name__ == "__main__":
    print(f"{'policy':<26}{'ascensions':>11}{'shards':>8}{'power x':>9}{'spirit x':>12}{'first boss 8':>14}")
    for depth in [1, 2, 3, 4]:
        res = [play(depth, 77 + s) for s in range(24)]
        name = f"ascend at {depth}+ shards"
        asc = st.median(p.asc for p, _ in res); sh = st.median(p.shards for p, _ in res)
        sm = st.median(p.spirit_mult() for p, _ in res)
        f8 = [f for _, f in res if f]
        dp = st.median(p.deepest for p, _ in res)
        print(f"{name:<26}{asc:>11}{sh:>8}{1+0.5*sh:>9.1f}{sm:>12,.0f}{(fmt(st.median(f8)) if f8 else 'never'):>14}  deepest now {dp}")
    print("\nFIRST 2 HOURS, average player, ascends at 2+ shards (one representative seed; key events)")
    for t, k in first_hours(4):
        if any(w in k for w in ["boss", "Ascension", "first", "slot", "form 2", "infinity"]):
            print(f"  {fmt(t)}  {k}")
