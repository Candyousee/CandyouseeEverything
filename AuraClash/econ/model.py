"""Aura Clash economy model v0 (seeded). Pacing targets + crate odds/pity maths.
Run: python model.py"""
import random
random.seed(7)

# ---------- Pacing ----------
ZONES = 8
TAPS_PER_SEC = 3.0          # manual; auto-train = 2.0
PERFECT_BONUS = 1.25        # avg gain from charge/perfect releases (skill)
ZONE_BASE = [1 * 6 ** z for z in range(ZONES)]          # power per tap in zone z (x6 per zone)
SPIRIT_MULT = [1.5, 3, 6, 12, 25, 50, 100, 200]         # typical equipped-spirit multiplier while in zone z
# gate = power needed to win the zone boss clash (skill lets you win at ~0.8x of it)
TARGET_MIN = [3, 6, 10, 15, 25, 40, 60, 90]            # target minutes per zone, first run (free player)

def per_sec(z, asc_mult=1.0, pass_mult=1.0):
    return TAPS_PER_SEC * PERFECT_BONUS * ZONE_BASE[z] * SPIRIT_MULT[z] * asc_mult * pass_mult

gates, total = [], 0.0
print("FIRST RUN (no ascension), free player")
print(f"{'zone':>4} {'pwr/s':>12} {'minutes':>8} {'gate power':>14} {'cum min':>8}")
for z in range(ZONES):
    total_power_needed = per_sec(z) * TARGET_MIN[z] * 60
    gates.append(total_power_needed)
    total += TARGET_MIN[z]
    print(f"{z+1:>4} {per_sec(z):>12,.0f} {TARGET_MIN[z]:>8} {total_power_needed:>14,.0f} {total:>8}")

print("\nWith 2x Power pass (payer): every zone takes half the time -> first run", total/2, "min")
print("Ascension multiplier: x(1 + 0.75*n). Ascension 1 needs zone 4 boss (~34 min in).")
for n in range(1, 6):
    m = 1 + 0.75 * n
    t = sum(TARGET_MIN[:4]) / m
    print(f"  Ascension {n}: mult x{m:.2f}, zones 1-4 replay in ~{t:.0f} min")

# ---------- Crates / eggs ----------
def opens_until(p, pity):
    for i in range(1, pity + 1):
        if random.random() < p:
            return i
    return pity

def crate_stats(name, p, pity, price_robux, n=200_000):
    runs = [opens_until(p, pity) for _ in range(n)]
    runs.sort()
    mean = sum(runs) / n
    hit_pity = sum(1 for r in runs if r == pity) / n
    p50, p90 = runs[n // 2], runs[int(n * 0.9)]
    print(f"{name:<22} p={p:<7} pity={pity:<4} mean opens={mean:6.1f}  median={p50:4}  p90={p90:4}  "
          f"reach pity={hit_pity:5.1%}  mean cost={mean*price_robux:7.0f} R$")

print("\nPAID AURA CRATE (49 R$/open, 10-pack 399 R$): odds Common 60 / Rare 28 / Epic 9 / Legendary 2.5 / Mythic 0.5")
crate_stats("Legendary+ (3%)", 0.03, 50, 40)
crate_stats("Mythic (0.5%)", 0.005, 300, 40)
print("Dry streak without pity, 1% item after 100 opens:", f"{(0.99**100):.1%} still empty")
