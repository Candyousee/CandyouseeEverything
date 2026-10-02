"""AURA CLASH economy model v2: ONE model for every number in CORE-GAME v2.
It plays the actual rules second by second with simulated players:
  training rates (training.py), coins, stone upgrades, eggs (real odds + guarantees), fusion,
  equip-best, forms, boss clashes (win chance from clash_sim.py), slots, Ascension.
Step 1 DERIVES the boss gates from target zone times (average player, first run).
Step 2 VERIFIES with fresh stochastic players and prints the balance table + timelines.
Step 3 compares Ascension strategies. Run: python economy.py  (about 1-2 minutes)."""
import math, random, statistics as st, zlib
from collections import Counter
from training import rate as train_rate
from clash_sim import clash as clash_fight

# ---------------- RULES (mirrors CORE-GAME v2) ----------------
ZONES = 8
STONE_BASE = [6 ** z for z in range(ZONES)]                 # base units per standard release, x6 per zone
STONE_MULT = {1: 1, 2: 2, 3: 4}
RARITIES = ["Common", "Rare", "Epic", "Legendary", "Mythic"]
ODDS = [0.60, 0.28, 0.10, 0.019, 0.001]
R_BONUS = [0.10, 0.25, 0.60, 1.50, 4.00]                    # zone-1 bonus by rarity
SPIRIT_STEP = 2.5                                           # each zone's spirits are x2.5 the previous zone's
GOLD, RAINBOW, SHINY, SHINY_P = 3.0, 9.0, 1.5, 0.01      # fusion: 3 same -> Gold (x3), 3 Gold -> Rainbow (x9)
FUSE_N = 3
FORM_BONUS = 0.05
SLOT_ZONES = {2, 4, 6}                                      # +1 slot the first time you reach these zones (permanent)
BASE_SLOTS, MAX_ASC_SLOTS = 3, 3
EGG_SECONDS, LV2_SECONDS, LV3_SECONDS = 15, 40, 120         # prices = seconds of AVERAGE Lv1 coin income in that zone
FIRST_CLEAR_SECONDS = 30                                    # boss first-clear coins = 30 s of next zone's Lv1 income
HATCH_TIME = 2.0
AUTO_FUSE_RARITIES = {0, 1}                                # auto-fuse default: Commons + Rares, unequipped only
ALTAR_TRIP = 15.0                                          # seconds for a manual-fusion trip to the Plaza altar
OVERPOWER, OVERPOWER_TIME = 3.0, 2.0
TARGET_MIN = [3, 5, 8, 12, 18, 25, 35, 50]                  # DESIGN TARGET: minutes per zone, average player, first run
ASC_DEPTH = [4, 5, 5, 6, 6, 7, 7, 8, 8]                     # depth needed for Ascension n+1; after the list: Infinity tier n-8
ASC_REQ_DEPTH = lambda n: ASC_DEPTH[n] if n < len(ASC_DEPTH) else 8 + (n - len(ASC_DEPTH) + 1)
SHARD_STEP = 100.0
SHARDS = lambda power, req: 1 + int(math.log(max(power, req) / req, SHARD_STEP))   # req = boss power of the required depth
ASC_PER_SHARD = 0.5
INFINITY_STEP = 1.6                                         # Infinity tier k boss power = boss 8 x 1.6^k

PROFILES = {  # training perfect%, clash (perfect, counter), boss attempt ratio
    "idle":    dict(train=("idle", 0.0), clash=(0.40, 0.40), attempt=1.30),
    "casual":  dict(train=("active", 0.40), clash=(0.40, 0.40), attempt=1.25),
    "average": dict(train=("active", 0.60), clash=(0.60, 0.65), attempt=1.10),
    "skilled": dict(train=("active", 0.85), clash=(0.85, 0.90), attempt=0.95),
}
G_RATE = {k: train_rate(v["train"][1], v["train"][0])[0] for k, v in PROFILES.items()}
AVG_INCOME = [G_RATE["average"] * STONE_BASE[z] for z in range(ZONES)]   # coins/s at stone Lv1

def nice(x):
    if x < 10: return max(1, round(x))
    mag = 10 ** (int(math.log10(x)) - 1)
    return int(round(x / mag) * mag)

EGG_PRICE = [nice(EGG_SECONDS * AVG_INCOME[z]) for z in range(ZONES)]
LV2_PRICE = [nice(LV2_SECONDS * AVG_INCOME[z]) for z in range(ZONES)]
LV3_PRICE = [nice(LV3_SECONDS * AVG_INCOME[z]) for z in range(ZONES)]
FIRST_CLEAR = [nice(FIRST_CLEAR_SECONDS * AVG_INCOME[min(z + 1, ZONES - 1)]) for z in range(ZONES)]

def bonus(z, r, tier=0, shiny=False):
    return R_BONUS[r] * SPIRIT_STEP ** z * (GOLD if tier == 1 else RAINBOW if tier == 2 else 1.0) * (SHINY if shiny else 1.0)

# ---------------- clash win table (from clash_sim) ----------------
_CL = {}
def win_prob(profile, ratio, rnd):
    key = (profile, round(min(ratio, 3.0), 2))
    if key not in _CL:
        pp, pc = PROFILES[profile]["clash"]
        r2 = random.Random(zlib.crc32(repr(key).encode()))      # stable seed (no Python hash randomisation)
        res = [clash_fight(key[1], pp, pc, r2) for _ in range(300)]
        wins = [t for w, t in res if w]; losses = [t for w, t in res if not w]
        _CL[key] = (len(wins) / 300, (sum(wins) / len(wins)) if wins else 45.0,
                    (sum(losses) / len(losses)) if losses else 45.0)
    return _CL[key]

# ---------------- the player ----------------
class Player:
    def __init__(self, profile, gates, seed):
        self.p, self.gates, self.rnd = profile, gates, random.Random(seed)
        self.g = G_RATE[profile]
        self.inv = {}                 # (zone, rarity, tier, shiny) -> count
        self.asc, self.shards, self.best_zone_ever = 0, 0, 0
        self.slots_zone = set(); self.hatches_total = 0; self.cleared_ever = set()
        self.t, self.ev = 0.0, {}
        self.reset_run()
        self.hatch(0, free=True)                                # tutorial: a free egg waits at the stand

    def reset_run(self):
        self.zone, self.power, self.coins, self.deepest = 0, 0.0, 0.0, 0
        self.stone = [1] * ZONES; self.form = 1; self.next_try = 0.0
        self._mult = None

    # --- derived values
    def slots(self):
        return BASE_SLOTS + len(self.slots_zone) + min(self.asc, MAX_ASC_SLOTS)
    def equipped_keys(self, inv=None):
        inv = self.inv if inv is None else inv
        items = []
        for k, n in inv.items():
            items += [k] * n
        items.sort(key=lambda k: bonus(*k), reverse=True)
        return items[: self.slots()]
    def equipped(self):
        return [bonus(*k) for k in self.equipped_keys()]
    def mult_of(self, inv):
        return 1 + sum(bonus(*k) for k in self.equipped_keys(inv))
    def spirit_mult(self):
        if self._mult is None:
            self._mult = self.mult_of(self.inv); self._ev = None
        return self._mult
    def asc_mult(self):
        return 1 + ASC_PER_SHARD * self.shards
    def power_rate(self):
        return self.g * STONE_BASE[self.zone] * STONE_MULT[self.stone[self.zone]] * self.spirit_mult() \
               * (1 + FORM_BONUS * (self.form - 1)) * self.asc_mult()
    def coin_rate(self):
        return self.g * STONE_BASE[self.zone] * STONE_MULT[self.stone[self.zone]]

    def mark(self, name):
        self.ev.setdefault(name, self.t)

    # --- actions
    def hatch(self, z, free=False):
        if not free: self.coins -= EGG_PRICE[z]
        self.hatches_total += 1
        if self.hatches_total == 1 and self.asc == 0: r = 0                       # guarantee: 1st hatch Common
        elif self.hatches_total == 3 and self.asc == 0: r = 1                     # guarantee: 3rd hatch Rare
        else:
            x, r = self.rnd.random(), 0
            for i, p in enumerate(ODDS):
                if x < p: r = i; break
                x -= p
        sh = self.rnd.random() < SHINY_P
        k = (z, r, 0, sh); self.inv[k] = self.inv.get(k, 0) + 1
        self.mark("first hatch")
        if r >= 1: self.mark("first Rare+")
        if r >= 2: self.mark("first Epic+")
        if r >= 3: self.mark("first Legendary+")
        self.t += HATCH_TIME
        self._mult = None
        self.auto_fuse(); self.manual_fuse()

    @staticmethod
    def fuse_all(inv):
        """Every possible fusion (used to value an egg: fusing never lowers team power)."""
        inv = dict(inv); changed = True
        while changed:
            changed = False
            for (z, r, tier, sh), n in list(inv.items()):
                if tier < 2 and n >= FUSE_N:
                    inv[(z, r, tier, sh)] = n - FUSE_N
                    k = (z, r, tier + 1, sh); inv[k] = inv.get(k, 0) + 1; changed = True
        return {k: v for k, v in inv.items() if v > 0}

    def _fuse_once(self, key):
        z, r, tier, sh = key
        self.inv[key] -= FUSE_N
        k = (z, r, tier + 1, sh); self.inv[k] = self.inv.get(k, 0) + 1
        self.inv = {k: v for k, v in self.inv.items() if v > 0}
        self.mark("first Gold fusion" if tier == 0 else "first Rainbow fusion"); self._mult = None

    def auto_fuse(self):
        """Auto-fuse rule: enabled rarities only (Common, Rare), using UNEQUIPPED copies only. Runs anywhere."""
        changed = True
        while changed:
            changed = False
            eq = Counter(self.equipped_keys())
            for key, n in list(self.inv.items()):
                z, r, tier, sh = key
                if tier < 2 and r in AUTO_FUSE_RARITIES and n - eq[key] >= FUSE_N:
                    self._fuse_once(key); changed = True; break

    def manual_fuse(self):
        """Manual fusion at the Plaza altar (any rarity, equipped allowed). Uses the SAME logic as egg valuation:
        the player fuses everything fusable (whole chains, normal -> Gold -> Rainbow) when the end result raises
        team power, even if a single intermediate step alone would not. One 15 s trip."""
        target = self.fuse_all(self.inv)
        if self.mult_of(target) <= self.spirit_mult() + 1e-9:
            return
        self.t += ALTAR_TRIP
        for (z, r, tier, sh), n in target.items():
            if tier == 1 and n > self.inv.get((z, r, 1, sh), 0): self.mark("first Gold fusion")
            if tier == 2 and n > self.inv.get((z, r, 2, sh), 0): self.mark("first Rainbow fusion")
        self.inv = target; self._mult = None

    def egg_value(self):
        """Exact expected team-power gain of one hatch, INCLUDING fusions it completes (e.g. the 3rd Epic)."""
        base = self.spirit_mult()
        if getattr(self, "_ev", None) is not None and self._ev[0] == (self.zone, base, self.slots()):
            return self._ev[1]
        z, gain = self.zone, 0.0
        for r, p in enumerate(ODDS):
            trial = dict(self.inv); k = (z, r, 0, False); trial[k] = trial.get(k, 0) + 1
            gain += p * (self.mult_of(self.fuse_all(trial)) - base)
        self._ev = ((self.zone, base, self.slots()), gain / base)
        return self._ev[1]

    def shop(self):
        z = self.zone
        while True:
            options = []
            if self.stone[z] < 3:
                price = LV2_PRICE[z] if self.stone[z] == 1 else LV3_PRICE[z]
                options.append((1.0 / price, "stone", price))
            ev = self.egg_value()
            if ev > 0.002: options.append((ev / EGG_PRICE[z], "egg", EGG_PRICE[z]))
            if not options: return
            options.sort(reverse=True)
            _, what, price = options[0]
            if self.coins < price: return
            if what == "stone":
                self.coins -= price; self.stone[z] += 1; self.mark(f"Z{z+1} stone Lv{self.stone[z]}")
            else:
                self.hatch(z)

    def boss(self):
        z = self.zone
        inf = self.deepest - 8 if self.deepest >= 8 else -1
        gate = self.gates[z] if inf < 0 else self.gates[7] * INFINITY_STEP ** (inf + 1)
        ratio = self.power / gate
        if ratio < PROFILES[self.p]["attempt"] or self.t < self.next_try: return False
        p, win_t, loss_t = (1.0, OVERPOWER_TIME, 0.0) if ratio >= OVERPOWER else win_prob(self.p, ratio, self.rnd)
        if self.rnd.random() >= p:
            self.t += loss_t; self.next_try = self.t + 30; return False
        self.t += win_t
        if inf >= 0:
            self.deepest += 1; self.mark(f"infinity {inf+1}"); return True
        self.deepest = max(self.deepest, z + 1)
        self.form = max(self.form, z + 3); self.mark(f"boss {z+1}" + (f" (A{self.asc})" if self.asc else ""))
        self.mark(f"form {self.form}")
        first = z not in self.cleared_ever; self.cleared_ever.add(z)
        if z + 1 < ZONES:
            self.zone = z + 1
            if first:                                       # first-clear coins + free egg: once per ACCOUNT
                self.coins += FIRST_CLEAR[z]; self.hatch(self.zone, free=True)
            if (self.zone + 1) in SLOT_ZONES and (self.zone + 1) not in self.slots_zone:
                self.slots_zone.add(self.zone + 1); self._mult = None; self.mark(f"slot at zone {self.zone+1}")
        return True

    def depth_gate(self, d):
        return self.gates[d - 1] if d <= 8 else self.gates[7] * INFINITY_STEP ** (d - 8)
    def can_ascend(self):
        return self.deepest >= ASC_REQ_DEPTH(self.asc)
    def shards_now(self):
        return SHARDS(self.power, self.depth_gate(ASC_REQ_DEPTH(self.asc))) if self.can_ascend() else 0

    def ascend(self):
        self.shards += self.shards_now(); self.asc += 1
        self.mark(f"Ascension {self.asc}")
        self.reset_run(); self._mult = None

    def step(self, dt=1.0):
        self.power += self.power_rate() * dt; self.coins += self.coin_rate() * dt; self.t += dt
        if self.form == 1 and self.power >= 0.2 * self.gates[0]:
            self.form = 2; self.mark("form 2 (tutorial)")
        self.shop()

# ---------------- step 1: derive gates ----------------
def derive_gates(k=60):
    gates = [1.0] * ZONES
    players = [Player("average", gates, s) for s in range(k)]
    for z in range(ZONES):
        end = sum(TARGET_MIN[: z + 1]) * 60
        for pl in players:
            while pl.t < end:
                pl.step()
        gates[z] = nice(st.median(pl.power for pl in players) / 1.1)
        for pl in players:                                   # forced first clear at the target time
            pl.gates = gates
            pl.deepest = z + 1; pl.form = max(pl.form, z + 3)
            if z + 1 < ZONES:
                pl.coins += FIRST_CLEAR[z]; pl.zone = z + 1; pl.hatch(pl.zone, free=True)
                if (z + 2) in SLOT_ZONES: pl.slots_zone.add(z + 2); pl._mult = None
    return gates

def first_run(profile, gates, seed, stop_after_boss=8, limit_h=8):
    pl = Player(profile, gates, seed)
    while pl.deepest < stop_after_boss and pl.t < limit_h * 3600:
        pl.step(); pl.boss()
    return pl

def pct(xs, q):
    xs = sorted(xs); return xs[min(len(xs) - 1, int(q * len(xs)))]

def fmt(sec):
    if sec is None: return "-"
    m = sec / 60
    return f"{m:5.1f} min" if m < 120 else f"{m/60:4.1f} h"

if __name__ == "__main__":
    print("TRAINING RATES (base units / s):", {k: round(v, 2) for k, v in G_RATE.items()})
    gates = derive_gates()
    print("\nBALANCE TABLE (derived)")
    print(f"{'zone':>4}{'stone base':>11}{'egg':>11}{'stone Lv2':>12}{'stone Lv3':>12}{'boss power':>20}{'gold gate (1.1x)':>20}{'first-clear coins':>18}")
    for z in range(ZONES):
        print(f"{z+1:>4}{STONE_BASE[z]:>11,}{EGG_PRICE[z]:>11,}{LV2_PRICE[z]:>12,}{LV3_PRICE[z]:>12,}{gates[z]:>20,}{nice(1.1*gates[z]):>20,}{(FIRST_CLEAR[z] if z < 7 else 0):>18,}")
    print("\nASCENSION REQUIREMENTS (depth to clear in the run; shards measured vs that boss's power)")
    for n in range(12):
        d = ASC_REQ_DEPTH(n); g = gates[d-1] if d <= 8 else gates[7] * INFINITY_STEP ** (d - 8)
        name = f"boss {d}" if d <= 8 else f"Infinity tier {d-8}"
        print(f"  Ascension {n+1:>2}: clear {name:<16} (boss power {nice(g):,}; +1 shard per x100 beyond)")
    print("\nSPIRIT BONUS BY ZONE (added to the team multiplier; Gold x6, Rainbow x36, Shiny x1.5)")
    print("zone " + "".join(f"{r:>12}" for r in RARITIES))
    for z in range(ZONES):
        print(f"{z+1:>4} " + "".join(f"{'+'+format(bonus(z,r),',.2f'):>12}" for r in range(5)))

    N = 120
    print(f"\nFIRST RUN, {N} simulated players per profile (median [p10-p90])")
    for prof in ["average", "casual", "skilled", "idle"]:
        runs = [first_run(prof, gates, 1000 + i, stop_after_boss=4 if prof == "idle" else 8, limit_h=10) for i in range(N)]
        keys = ["first hatch", "first Rare+", "Z1 stone Lv2", "first Gold fusion", "form 2 (tutorial)"] + [f"boss {i}" for i in range(1, 9)]
        print(f"  [{prof}]")
        for k in keys:
            xs = [r.ev[k] for r in runs if k in r.ev]
            if len(xs) < N * 0.5: print(f"    {k:<20} reached by {len(xs)}/{N}"); continue
            print(f"    {k:<20} {fmt(st.median(xs))}  [{fmt(pct(xs,0.1))} - {fmt(pct(xs,0.9))}]")
    import json; json.dump({"gates": gates}, open("gates.json", "w"))
