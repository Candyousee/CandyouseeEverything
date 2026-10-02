"""AURA CLASH v5.1 balance model: plays the CORE-LOOP rules second by second with simulated players.

Covers zones 1-2 (the two-zone test): meditation (AFK / Focus / offline), hunting crystal monsters
with hold-release blasts (PERFECT, combo, Overdrive chains), mutations, the capped bag + SELL,
coins -> eggs / Bag / Mat / Surge, pets (Strength = rarity x zone x stars x level), fusion (stars),
Soul Food levels, rank quests, and the boss fights (phases 1-2 + the beam clash).

Run: python model.py   (prints RESULTS; seeded, reproducible)
Every constant below is a rule in CORE-LOOP.md / CORE-GAME.md. Change one = change the docs.
"""
import math, random, statistics as st, zlib

# ---------------- RULES ----------------
START_POWER, TUTORIAL_POWER, TUTORIAL_TIME = 10, 40, 20
BLAST_TIME, LATE_STAGGER = 1.4, 0.5            # 1.2 s hold + 0.2 s recovery; a late release staggers 0.5 s
EARLY_X, LATE_X, PERFECT_X = 0.6, 0.5, 2.0
COMBO = [1.0, 1.25, 1.5, 1.75, 2.0]            # PERFECT: +1 level; any other release: -1 level
OD_STREAK, OD_TIME, SURGE_STEP = 5, 8.0, 2.0   # 5 PERFECTs in a row -> Overdrive 8 s (+2 s per Surge level)
OD_CHAIN_N, OD_CHAIN_X, OD_AFTER = 2, 0.5, 2   # chains to 2 more monsters at 50%; combo after = level 2 (x1.5)

PET_HIT_EVERY, PET_HIT_X = 1.5, 0.04           # each pet hits every 1.5 s for Strength x 4% of Power
MED_PER_STR = 0.10                             # meditation +10% per point of equipped Strength
RARITIES = ["Common", "Rare", "Epic", "Legendary", "Mythic", "Secret"]
ODDS = [0.60, 0.28, 0.10, 0.019, 0.001 - 1 / 500_000, 1 / 500_000]
R_STR = [1, 2, 4, 10, 20, 50]
SPECIES = [2, 2, 1, 1, 1, 1]                   # species per rarity per zone
ZONE_PET = [1, 2]                              # zone 2 pets are x2 zone 1 pets
STAR = [1, 3, 9]                               # fusion: 3 same -> star (x3), 3 star -> double star (x9)
LEVEL_X, MAX_LEVEL = 0.05, 30                  # +5% Strength per level above 1
XP_TO_NEXT = lambda lv: 2 * lv                 # Soul Food XP to go from lv to lv+1
FOOD_XP = [1, 3]                               # XP per food item by zone
BASE_SLOTS = 3

SHRINE = [0.5, 2.0]                            # Power per second, AFK, by zone
MAT_STEP = 0.25
OFFLINE_X, OFFLINE_CAP_H = 0.25, 8

#            name           HP     shards bright gemP  food  overhead(s)
MONSTERS = [[("Shardling",    20,   1, 0.0, 0.0, 0.1, 0.6),
             ("Crystal Boar", 200,  3, 0.2, 0.0, 1.0, 1.5),
             ("Crag Brute",   2000, 8, 2.0, 0.1, 3.0, 3.0)],
            [("Ember Slime",  400,  1, 0.0, 0.0, 0.1, 0.6),
             ("Lava Hound",   4000, 3, 0.2, 0.0, 1.0, 1.5),
             ("Obsidian Brute", 40000, 8, 2.0, 0.1, 3.0, 3.0)]]
BIG_MIN_CYCLE = 10.0                           # 3 Brutes per zone, 30 s respawn -> at most one every ~10 s
NEARBY = [3, 1, 0]                             # other monsters of the same type within chain range (packs / pairs / alone)
ALTAR_TIME = 5.0                               # a manual-fusion visit to the Fusion Altar ("Stay" after a sell)
AUTO_FUSE_MAX_RARITY = 1                       # auto-fuse: Commons + Rares, unequipped copies only
SHARD_VAL = [(3, 40, 250), (30, 400, 2500)]    # shard, bright, gem coins by zone
#             name        chance      value  HP
MUTATIONS = [("Gold",      1 / 25,     5,  2),
             ("Fire",      1 / 60,    10,  3),
             ("Frost",     1 / 60,    10,  3),
             ("Rainbow",   1 / 400,   25,  4),
             ("Void",      1 / 2000,  75,  6),
             ("Celestial", 1 / 10000, 250, 8)]
MUT_FOOD_X = 3
BAG = [60, 100, 150, 200, 250]
BAG_PRICE = [50, 250, 3000, 10000]
MAT_PRICE = [100, 400, 4000, 12000, 30000]
SURGE_PRICE = [300, 5000, 15000]
EGG_PRICE = [60, 1500]
SELL_TIME, HATCH_TIME = 3.0, 2.0
UPGRADE_ORDER = ["bag", "mat", "bag", "surge", "mat", "bag", "mat", "surge", "bag", "mat", "surge", "mat"]

BOSS = [dict(name="Stone Golem", rec=300, hp_x=1.0), dict(name="Magma Oni", rec=10000, hp_x=2.5)]
PLATES, PLATE_HP_X, BODY_HP_X = 6, 3.3, 20     # boss HP = these x recommended Power x the boss's hp_x
BOSS_DODGE_SHARE = 0.4                         # share of phase 1-2 time spent dodging instead of blasting
CLASH_START, CLASH_HIT_COST, CLASH_FLOOR = 60, 5, 30
CLASH_PERFECT, CLASH_OTHER = 12, 6
CLASH_DRIFT = 3.0                              # boss push per second at Power = recommended (x rec / Power, max x4)
CLASH_COUNTER_EVERY, CLASH_COUNTER_WIN, CLASH_COUNTER_LOSS = 4.0, 5, 8
CLASH_TIMEOUT = 30.0
BOSS_RETRY_GAP = 20.0

QUESTS = [  # zone 1, zone 2 (the last quest of each zone is the boss Power check)
    [("focus", 20), ("kill", "Shardling", 20), ("hatch", 5), ("kill", "Crystal Boar", 10), ("power", 300)],
    [("focus", 60), ("kill", "Ember Slime", 50), ("hatch", 8), ("kill", "Lava Hound", 20), ("level", 10), ("power", 10000)],
]
QUEST_REWARD = {  # (zone, quest index) -> reward. Never coins (coins only come from hunting) and never Power.
    (0, 0): "slot", (0, 1): "egg", (0, 2): "food10", (0, 3): "slot", (0, 4): "gate",
    (1, 0): "slot", (1, 1): "egg", (1, 2): "food30", (1, 3): "slot", (1, 4): "egg", (1, 5): "gate",
}

PROFILES = {  # perfect rate, Focus average multiplier, counter success, mean hits taken per boss
    "weak":    dict(p=0.35, focus=1.8, counter=0.40, hits=4.0),
    "average": dict(p=0.60, focus=2.4, counter=0.65, hits=2.0),
    "strong":  dict(p=0.80, focus=2.8, counter=0.90, hits=1.0),
}


def seed(*parts):
    return zlib.crc32("|".join(map(str, parts)).encode())


class Pet:
    __slots__ = ("z", "r", "sp", "stars", "lv", "xp")

    def __init__(self, z, r, sp):
        self.z, self.r, self.sp, self.stars, self.lv, self.xp = z, r, sp, 0, 1, 0

    def strength(self):
        return R_STR[self.r] * ZONE_PET[self.z] * STAR[self.stars] * (1 + LEVEL_X * (self.lv - 1))


class Player:
    def __init__(self, profile, run=0, log=False):
        self.pf, self.name = PROFILES[profile], profile
        self.rng = random.Random(seed(profile, run))
        self.t, self.power, self.coins = 0.0, START_POWER, 0
        self.food = [0, 0]                 # Soul Food pouch by origin zone (XP depends on where it dropped)
        self.od_until, self.od_active = -1.0, False   # Overdrive ends at a TIMESTAMP: real time keeps running
        self.field, self.last_big = [], -1e9
        self.kill_log = []                 # (time, monster, cause) for checks
        self.bag, self.bag_val = 0, 0
        self.bag_lv = self.mat_lv = self.surge_lv = 0
        self.upg_i = 0
        self.pets, self.slots, self.hatches, self.zone_hatches = [], BASE_SLOTS, 0, {}
        self.zone, self.quest, self.kills = 0, 0, {}
        self.combo, self.streak = 0, 0
        self.focus_done = 0.0
        self.log_on, self.events = log, []
        self.hunt_time = self.med_time = self.player_dmg = self.pet_dmg = 0.0
        self.coins_earned = self.mut_coins = 0
        self.sells_since_med = 0
        self.boss_attempts = [0, 0]
        self.milestones = {}

    # ---------- helpers ----------
    def note(self, key, text=None):
        self.milestones.setdefault(key, self.t)
        if self.log_on and text:
            self.events.append((self.t, text))

    def team(self):
        return sorted(self.pets, key=lambda p: -p.strength())[: self.slots]

    def team_str(self):
        return sum(p.strength() for p in self.team())

    def med_rate(self, focus):
        return SHRINE[self.zone] * focus * (1 + MED_PER_STR * self.team_str()) * (1 + MAT_STEP * self.mat_lv)

    def exp_blast(self):
        p = self.pf["p"]
        avg_combo = combo_avg(p)
        return self.power * (p * PERFECT_X * avg_combo + (1 - p) * 0.75 * EARLY_X + (1 - p) * 0.25 * LATE_X)

    def exp_dps(self):
        return self.exp_blast() / BLAST_TIME + self.team_str() * PET_HIT_X * self.power / PET_HIT_EVERY

    def green(self, mz, mi):
        """HP bar is green when the monster dies to about 3 of your blasts (pets included)."""
        return MONSTERS[mz][mi][1] <= 3 * BLAST_TIME * self.exp_dps()

    # ---------- meditation ----------
    def meditate(self, seconds, focus=True):
        f = self.pf["focus"] if focus else 1.0
        gain = self.med_rate(f) * seconds
        self.power += gain
        self.t += seconds
        self.med_time += seconds
        if focus:
            self.focus_done += seconds
        self.sells_since_med = 0
        return gain

    def meditate_until(self, target, cap=None):
        f = self.pf["focus"]
        need = max(0.0, target - self.power)
        secs = need / self.med_rate(f) + 5   # +5 s to sit down and build Focus
        if cap:
            secs = min(secs, cap)
        self.meditate(secs)
        self.note(f"meditate_z{self.zone}", f"meditates to Power {self.power:.0f}")

    # ---------- hunting ----------
    def blast(self):
        """One hold-release. Returns (damage, time, was_perfect, in_overdrive)."""
        r = self.rng.random()
        p = self.pf["p"]
        if r < p:
            self.combo = min(4, self.combo + 1)
            self.streak += 1
            return self.power * PERFECT_X * COMBO[self.combo], BLAST_TIME, True
        self.streak = 0
        self.combo = max(0, self.combo - 1)
        if r < p + (1 - p) * 0.75:
            return self.power * EARLY_X, BLAST_TIME, False
        return self.power * LATE_X, BLAST_TIME + LATE_STAGGER, False

    def pick_monster(self):
        """Best coins per minute among green monsters, plus the next size up if it still dies fast (<= 6 s)."""
        best, best_rate = 0, -1
        for i, m in enumerate(MONSTERS[self.zone]):
            if not self.green(self.zone, i) and m[1] / self.exp_dps() > 6:
                continue
            hp, sh, br, gem = m[1], m[2], m[3], m[4]
            sv, bv, gv = SHARD_VAL[self.zone]
            value = sh * sv + br * bv + gem * gv
            kt = hp / self.exp_dps() + m[6]
            if i == 2:
                kt = max(kt, BIG_MIN_CYCLE)
            rate = value / kt
            if rate > best_rate:
                best, best_rate = i, rate
        return best

    def roll_mutation(self):
        """ONE roll against exclusive bands, so each mutation's real chance is exactly its advertised chance."""
        x, acc = self.rng.random(), 0.0
        for m in MUTATIONS:
            acc += m[1]
            if x < acc:
                return m
        return None

    def spawn(self, mi):
        mut = self.roll_mutation()
        if self.milestones.get("mut_tutorial") is None and self.zone == 0 and self.t > 60:
            mi, mut = 0, MUTATIONS[0]                        # the guaranteed tutorial Gold Shardling
            self.note("mut_tutorial", "the tutorial Gold Shardling")
        hp = MONSTERS[self.zone][mi][1] * (mut[3] if mut else 1)
        return {"mi": mi, "hp": hp, "mut": mut}

    def fill_field(self, mi):
        """The target plus the monsters of the same type standing close enough to be chained."""
        want = 1 + NEARBY[mi]
        while len(self.field) < want:
            self.field.append(self.spawn(mi))
        del self.field[want:]

    def start_overdrive(self):
        self.od_until = self.t + OD_TIME + SURGE_STEP * self.surge_lv
        self.od_active = True
        self.note("overdrive", "first OVERDRIVE")

    def in_overdrive(self):
        """A release counts as Overdrive only if it lands before the expiry timestamp. The timer runs through
        walking, selling, hatching, fusing and meditating, because all of them advance self.t."""
        if self.od_active and self.t + BLAST_TIME > self.od_until:
            self.od_active = False
            self.combo, self.streak = OD_AFTER, 0
        return self.od_active

    def loot(self, mon, cause, in_od=False):
        z, mi, mut = self.zone, mon["mi"], mon["mut"]
        name, hp, sh, br, gem, food, over = MONSTERS[z][mi]
        n_bright = int(br) + (1 if self.rng.random() < br - int(br) else 0)
        n_gem = 1 if self.rng.random() < gem else 0
        vx = mut[2] if mut else 1
        for val, n in ((SHARD_VAL[z][0], sh), (SHARD_VAL[z][1], n_bright), (SHARD_VAL[z][2], n_gem)):
            for _ in range(n):
                if self.bag < BAG[self.bag_lv]:          # 1 shard = 1 slot, whatever its mutation
                    self.bag += 1
                    self.bag_val += val * vx
                    if mut:
                        self.mut_coins += val * (vx - 1)
        f = food * (MUT_FOOD_X if mut else 1)
        whole = int(f) + (1 if self.rng.random() < f - int(f) else 0)
        self.food[z] += whole
        if whole:
            self.feed()                                   # Auto-feed (on by default) runs as food drops
        self.kills[name] = self.kills.get(name, 0) + 1
        self.kill_log.append((self.t, name, cause, in_od))

    def hunt_blast(self, mi):
        """One blast at the field's target. Overdrive chains hit at most OD_CHAIN_N nearby monsters for 50%.
        Excess damage is lost (it never carries over into extra kills)."""
        self.fill_field(mi)
        if self.in_overdrive():
            d, dt, perf = self.power * PERFECT_X * COMBO[4], BLAST_TIME, True
            in_od = True
        else:
            d, dt, perf = self.blast()
            in_od = False
            if self.streak >= OD_STREAK:
                self.start_overdrive()
                self.streak = 0
        pet_d = self.team_str() * PET_HIT_X * self.power * (dt / PET_HIT_EVERY + (1 if perf else 0))
        target = self.field[0]
        target["hp"] -= d + pet_d
        self.player_dmg += d
        self.pet_dmg += pet_d
        if in_od:
            for mon in self.field[1:1 + OD_CHAIN_N]:
                mon["hp"] -= d * OD_CHAIN_X
                self.player_dmg += d * OD_CHAIN_X
        self.t += dt
        self.hunt_time += dt
        dead = [m for m in self.field if m["hp"] <= 0]
        target_died = target["hp"] <= 0
        for m in dead:
            self.field.remove(m)
            self.loot(m, "target" if m is target else "chain", in_od)
            if self.bag >= BAG[self.bag_lv]:
                self.sell()
        if target_died:
            # walk to the next target; Brutes are limited by their respawns
            over = MONSTERS[self.zone][mi][6]
            if mi == 2:
                over = max(over, self.last_big + BIG_MIN_CYCLE - self.t)
                self.last_big = self.t + over
            self.t += over
            self.hunt_time += over

    def hunt_session(self, mi, seconds=None, until_sells=None):
        end = self.t + seconds if seconds else None
        start_sells = self.milestones.get("_sells", 0)
        if self.field and self.field[0]["mi"] != mi:
            self.field = []
        while True:
            before = len(self.kill_log)
            self.hunt_blast(mi)
            if end and self.t >= end:
                return
            if until_sells and self.milestones.get("_sells", 0) - start_sells >= until_sells:
                return
            if len(self.kill_log) > before and self.quest_check():
                return

    # ---------- money ----------
    def sell(self):
        self.t += SELL_TIME
        self.coins += self.bag_val
        self.coins_earned += self.bag_val
        self.note("first_sell", f"first SELL: {self.bag_val} coins")
        self.milestones["_sells"] = self.milestones.get("_sells", 0) + 1
        self.bag, self.bag_val = 0, 0
        self.sells_since_med += 1
        self.spend()
        if self.fuse(manual=True, dry_run=True):        # "Stay" at the Shrine and use the Fusion Altar
            self.t += ALTAR_TIME
            self.fuse(manual=True)

    def upgrade_cost(self):
        while self.upg_i < len(UPGRADE_ORDER):
            kind = UPGRADE_ORDER[self.upg_i]
            lv = {"bag": self.bag_lv, "mat": self.mat_lv, "surge": self.surge_lv}[kind]
            table = {"bag": BAG_PRICE, "mat": MAT_PRICE, "surge": SURGE_PRICE}[kind]
            if lv < len(table):
                return kind, table[lv]
            self.upg_i += 1
        return None, None

    def spend(self):
        egg = EGG_PRICE[self.zone]
        while True:
            if len(self.pets) < self.slots and self.coins >= egg:
                self.hatch()
                continue
            kind, cost = self.upgrade_cost()
            if kind and self.coins >= cost:
                self.coins -= cost
                setattr(self, kind + "_lv", getattr(self, kind + "_lv") + 1)
                self.upg_i += 1
                self.note(f"{kind}{getattr(self, kind + '_lv')}")
                continue
            if kind and cost <= 3 * egg:
                return                  # save for the next upgrade
            if self.coins >= egg:
                self.hatch()
                continue
            return

    def hatch(self, free=False):
        z = self.zone
        if not free:
            self.coins -= EGG_PRICE[z]
        self.t += HATCH_TIME
        self.hatches += 1
        self.zone_hatches[z] = self.zone_hatches.get(z, 0) + 1
        if self.hatches == 1:
            r, sp = 0, 0                                     # the tutorial Light Fox
        elif self.hatches == 3 and not any(p.r >= 1 for p in self.pets):
            r, sp = 1, 0                                     # guaranteed Rare on the 3rd hatch
        else:
            x, r = self.rng.random(), 0
            acc = 0.0
            for i, o in enumerate(ODDS):
                acc += o
                if x < acc:
                    r = i
                    break
            sp = self.rng.randrange(SPECIES[r])
        self.pets.append(Pet(z, r, sp))
        self.note("first_hatch", "first hatch")
        self.auto_fuse()
        self.feed()

    def auto_fuse(self):
        """Auto-fuse (on by default): Commons + Rares, UNEQUIPPED copies only. Never touches the team."""
        changed = True
        while changed:
            changed = False
            team = set(map(id, self.team()))
            groups = {}
            for p in self.pets:
                if p.r <= AUTO_FUSE_MAX_RARITY and p.stars < 2 and id(p) not in team:
                    groups.setdefault((p.z, p.r, p.sp, p.stars), []).append(p)
            for (z, r, sp, st_), lst in groups.items():
                if len(lst) >= 3:
                    lst.sort(key=lambda p: -p.lv)
                    for p in lst[:3]:
                        self.pets.remove(p)
                    new = Pet(z, r, sp)
                    new.stars, new.lv = st_ + 1, lst[0].lv
                    self.pets.append(new)
                    self.note("first_star", "first star fusion")
                    changed = True
                    break

    def fuse(self, manual=True, dry_run=False):
        """Manual fusion at the Fusion Altar: any rarity, equipped copies allowed, only if the team gets stronger."""
        did = False
        changed = True
        while changed:
            changed = False
            groups = {}
            for p in self.pets:
                groups.setdefault((p.z, p.r, p.sp, p.stars), []).append(p)
            for (z, r, sp, st_), lst in groups.items():
                if len(lst) < 3 or st_ >= 2:
                    continue
                lst.sort(key=lambda p: -p.lv)
                before = self.team_str()
                keep = lst[:3]
                for p in keep:
                    self.pets.remove(p)
                new = Pet(z, r, sp)
                new.stars, new.lv = st_ + 1, keep[0].lv
                self.pets.append(new)
                better = self.team_str() > before + 1e-9
                if dry_run or not better:
                    self.pets.remove(new)
                    self.pets.extend(keep)
                    if dry_run and better:
                        return True
                    continue
                self.note("first_star", "first star fusion")
                did = changed = True
                break
        return did

    def feed(self):
        """Feed All / Auto-feed: equipped pets, lowest level first. Each item gives the XP of the zone it dropped in."""
        team = self.team()
        while team and sum(self.food) > 0:
            pet = min(team, key=lambda p: p.lv)
            if pet.lv >= MAX_LEVEL:
                break
            fz = 0 if self.food[0] > 0 else 1
            self.food[fz] -= 1
            pet.xp += FOOD_XP[fz]
            while pet.lv < MAX_LEVEL and pet.xp >= XP_TO_NEXT(pet.lv):
                pet.xp -= XP_TO_NEXT(pet.lv)
                pet.lv += 1
                self.note("first_level", "first pet level-up")

    # ---------- quests + bosses ----------
    def quest_check(self):
        """Advance rank quests; returns True when the current hunt should stop (a quest needs something else)."""
        z = self.zone
        while self.quest < len(QUESTS[z]):
            q = QUESTS[z][self.quest]
            done = False
            if q[0] == "focus":
                return True
            if q[0] == "kill":
                done = self.kills.get(q[1], 0) >= q[2]
            elif q[0] == "hatch":
                done = self.zone_hatches.get(z, 0) >= q[1]
            elif q[0] == "level":
                done = any(p.lv >= q[1] for p in self.team())
            elif q[0] == "power":
                done = self.power >= q[1]
            if not done:
                return False
            self.quest_reward(z, self.quest)
            self.quest += 1
        return True

    def quest_reward(self, z, i):
        r = QUEST_REWARD.get((z, i))
        self.note(f"quest_z{z}_{i}")
        if r == "slot":
            self.slots += 1
        elif r == "egg":
            self.hatch(free=True)
        elif r and r.startswith("food"):
            self.food[z] += int(r[4:])
            self.feed()

    def boss_fight(self):
        b = BOSS[self.zone]
        rec = b["rec"]
        dps = self.exp_dps()
        hx = b["hp_x"]
        p1 = PLATES * PLATE_HP_X * rec * hx / (dps * (1 - BOSS_DODGE_SHARE))
        p2 = BODY_HP_X * rec * hx / (dps * (1 - BOSS_DODGE_SHARE))
        hits = min(6, int(self.rng.expovariate(1 / self.pf["hits"]) + 0.5)) if self.pf["hits"] else 0
        win, t3 = clash(self.pf["p"], self.pf["counter"], hits, self.power / rec, self.rng)
        self.t += p1 + p2 + t3
        self.boss_attempts[self.zone] += 1
        return win, p1 + p2 + t3

    def run(self, until_zone=2, max_t=4 * 3600):
        self.t += TUTORIAL_TIME
        self.power += TUTORIAL_POWER
        self.note("tutorial", "tutorial meditation")
        while self.zone < until_zone and self.t < max_t:
            z = self.zone
            if self.quest < len(QUESTS[z]) and QUESTS[z][self.quest][0] == "focus":
                if self.t > (30 if z == 0 else 0) and (z > 0 or self.hatches >= 3):
                    self.meditate(QUESTS[z][self.quest][1])
                    self.quest_reward(z, self.quest)
                    self.quest += 1
                    continue
            if self.quest_check() and self.quest >= len(QUESTS[z]):
                win, dur = self.boss_fight()
                if win:
                    self.note(f"boss{z + 1}", f"beats {BOSS[z]['name']}")
                    self.zone += 1
                    self.quest = 0
                    if self.zone < len(SHRINE):
                        self.hatch(free=True)
                    continue
                self.t += BOSS_RETRY_GAP
                continue
            q = QUESTS[z][self.quest] if self.quest < len(QUESTS[z]) else None
            if q and q[0] == "power" and self.quest == len(QUESTS[z]) - 1:
                self.meditate_until(q[1])
                continue
            # the switch rule: after 2+ sells, if the next monster up isn't green yet, sit and meditate until it is
            mi = self.pick_monster()
            nxt = mi + 1
            if self.sells_since_med >= 2 and nxt < 3 and not self.green(z, nxt):
                target = MONSTERS[z][nxt][1] / (3 * BLAST_TIME) / max(1e-9, self.exp_dps() / self.power)
                self.meditate_until(target, cap=120)
                continue
            if q and q[0] == "kill":
                mi = [m[0] for m in MONSTERS[z]].index(q[1]) if self.kills.get(q[1], 0) < q[2] else mi
            self.hunt_session(mi, seconds=30)
        return self


def loot_recipients(damage_log):
    """Shared monsters, personal loot: EVERY player who damaged the monster gets their own full drop
    (shards, food, the mutation) and quest credit. Nothing is split, so a newcomer next to a veteran never loses out."""
    return sorted(pid for pid, dmg in damage_log.items() if dmg > 0)


# ---------------- crowded servers: protected quest spawns ----------------
PERSONAL_PACK = {"Shardling": 4, "Crystal Boar": 2, "Ember Slime": 4, "Lava Hound": 2}   # while that kill quest is active
PERSONAL_RESPAWN = 5.0
SHARED_POINTS, SHARED_RESPAWN = 8, 5.0


def crowded_quest_time(veterans, personal, kills_needed=20, seed_=0, vet_kill_every=0.7, cap=900.0):
    """A beginner (one-shots Shardlings, 1.4 s per blast + 0.6 s to retarget) does "Defeat 20 Shardlings"
    next to `veterans` who each kill any shared Shardling in reach every `vet_kill_every` seconds.
    Credit needs the beginner's hit to LAND on a living monster (personal loot, CORE-LOOP 8).
    personal=True adds the protected quest pack: monsters only the beginner can damage.
    Returns seconds to finish the quest (cap if never)."""
    rng = random.Random(seed(veterans, personal, seed_))
    dt = 0.1
    shared = [0.0] * SHARED_POINTS                 # time each shared point is next alive
    pack = [0.0] * (PERSONAL_PACK["Shardling"] if personal else 0)
    vet_next = [rng.random() * vet_kill_every for _ in range(veterans)]
    t, kills, aim = 0.0, 0, None                   # aim = (kind, index, lands_at)
    while t < cap:
        for v in range(veterans):                  # veterans clear shared monsters
            if t >= vet_next[v]:
                alive = [i for i, r in enumerate(shared) if r <= t]
                if alive:
                    i = rng.choice(alive)
                    shared[i] = t + SHARED_RESPAWN
                vet_next[v] = t + vet_kill_every
        if aim is None:
            alive_pack = [i for i, r in enumerate(pack) if r <= t]
            alive_shared = [i for i, r in enumerate(shared) if r <= t]
            if alive_pack:
                aim = ("pack", alive_pack[0], t + BLAST_TIME)
            elif alive_shared:
                aim = ("shared", rng.choice(alive_shared), t + BLAST_TIME)
        elif t >= aim[2]:
            kind, i, _ = aim
            pool = pack if kind == "pack" else shared
            if pool[i] <= aim[2] - BLAST_TIME and pool[i] <= t:   # still the same living monster when the hit lands
                pool[i] = t + (PERSONAL_RESPAWN if kind == "pack" else SHARED_RESPAWN)
                kills += 1
                if kills >= kills_needed:
                    return t
            aim = None
            t += 0.6                               # retarget
        t += dt
    return cap


def combo_avg(p):
    """Average combo multiplier on a PERFECT: stationary distribution of the +1 / -1 combo ladder."""
    pi = [1.0] * 5
    for i in range(1, 5):
        pi[i] = pi[i - 1] * (p / max(1e-9, 1 - p))
    tot = sum(pi)
    lv_before = [x / tot for x in pi]
    # a PERFECT moves the level up one before the multiplier applies
    return sum(w * COMBO[min(4, i + 1)] for i, w in enumerate(lv_before))


def clash(p, counter, hits, power_ratio, rng):
    """Beam clash (phase 3). Returns (win, seconds)."""
    meter = max(CLASH_FLOOR, CLASH_START - CLASH_HIT_COST * hits)
    t, next_counter = 0.0, CLASH_COUNTER_EVERY
    drift = CLASH_DRIFT * min(4.0, 1 / max(power_ratio, 0.05))
    while t < CLASH_TIMEOUT:
        t += BLAST_TIME
        meter -= drift * BLAST_TIME
        meter += CLASH_PERFECT if rng.random() < p else CLASH_OTHER
        if t >= next_counter:
            next_counter += CLASH_COUNTER_EVERY
            meter += CLASH_COUNTER_WIN if rng.random() < counter else -CLASH_COUNTER_LOSS
        if meter >= 100:
            return True, t
        if meter <= 0:
            return False, t
    return False, t


def egg_roll(rng):
    x, acc = rng.random(), 0.0
    for i, o in enumerate(ODDS):
        acc += o
        if x < acc:
            return i
    return 0


# ---------------- REPORT ----------------
def fmt(s):
    return f"{int(s // 60)}:{int(s % 60):02d}" if s is not None else "-"


def report():
    out = []
    P = out.append
    P("AURA CLASH v5.1 model results (python model.py)\n")
    P("1. Average player, first run, one seeded playthrough close to the median (seed 74; the CORE-LOOP 7 script)")
    pl = Player("average", 74, log=True).run()
    keys = [("tutorial", "tutorial meditation done"), ("first_sell", "first SELL"), ("first_hatch", "first hatch"),
            ("mut_tutorial", "tutorial Gold Shardling"), ("overdrive", "first Overdrive"),
            ("quest_z0_0", "quest 1 (Focus 20 s)"), ("bag1", "Bag Lv1"), ("mat1", "Mat Lv1"),
            ("first_level", "first pet level-up"), ("quest_z0_3", "quest 4 (10 Boars)"), ("boss1", "boss 1 beaten"),
            ("quest_z1_0", "zone 2 quest 1"), ("first_star", "first star fusion"), ("boss2", "boss 2 beaten")]
    for k, label in keys:
        P(f"   {label:28s} {fmt(pl.milestones.get(k))}")
    P("")
    P("2. Milestones over 200 players per profile (median [10th-90th percentile], minutes)")
    P("   profile   first sell   boss 1          boss 2            meditating share   pets' damage share")
    agg = {}
    for prof in PROFILES:
        rows = [Player(prof, r).run() for r in range(200)]
        def q(key):
            v = sorted(x.milestones.get(key, 4 * 3600) / 60 for x in rows)
            return v[len(v) // 2], v[len(v) // 10], v[9 * len(v) // 10]
        fs, b1, b2 = q("first_sell"), q("boss1"), q("boss2")
        med = st.mean(x.med_time / max(1, x.med_time + x.hunt_time) for x in rows)
        petd = st.mean(x.pet_dmg / max(1, x.pet_dmg + x.player_dmg) for x in rows)
        agg[prof] = dict(b1=b1, b2=b2, med=med, petd=petd, fs=fs)
        P(f"   {prof:8s}  {fs[0]:5.1f}       {b1[0]:5.1f} [{b1[1]:.1f}-{b1[2]:.1f}]   {b2[0]:5.1f} [{b2[1]:.1f}-{b2[2]:.1f}]   "
          f"{med * 100:5.0f}%             {petd * 100:5.0f}%")
    P("")
    P("3. Beam clash win rate (2,000 fights per cell; hits taken in phases 1-2 = 2)")
    P("   Power / recommended:    0.5     0.75    1.0     1.5     2.0")
    rng = random.Random(seed("clash"))
    for prof, pf in PROFILES.items():
        cells = []
        for ratio in (0.5, 0.75, 1.0, 1.5, 2.0):
            w = sum(clash(pf["p"], pf["counter"], 2, ratio, rng)[0] for _ in range(2000)) / 2000
            cells.append(f"{w * 100:5.0f}%")
        P(f"   {prof:8s}               " + "  ".join(cells))
    P("")
    P("4. Coins per minute by monster (zone 1, average player, 3 Common pets, no mutations)")
    for power in (50, 150, 400):
        pl = Player("average", 1)
        pl.power = power
        pl.pets = [Pet(0, 0, 0), Pet(0, 0, 1), Pet(0, 0, 0)]
        row = []
        for i, m in enumerate(MONSTERS[0]):
            sv, bv, gv = SHARD_VAL[0]
            val = m[2] * sv + m[3] * bv + m[4] * gv
            kt = m[1] / pl.exp_dps() + m[6]
            if i == 2:
                kt = max(kt, BIG_MIN_CYCLE)
            row.append(f"{m[0]} {val / kt * 60:6.0f}/min ({kt:4.1f} s/kill{', GREEN' if pl.green(0, i) else ''})")
        P(f"   Power {power:4d}: " + " | ".join(row))
    P("")
    mut_ev = sum(m[1] * (m[2] - 1) for m in MUTATIONS)
    P(f"5. Mutations add about +{mut_ev * 100:.0f}% to average shard value per kill (before their extra HP)")
    P("")
    P("6. Meditation (zone 1 Shrine, 3 Common pets, Mat Lv0)")
    pl = Player("average", 2)
    pl.pets = [Pet(0, 0, 0), Pet(0, 0, 1), Pet(0, 0, 0)]
    afk, foc = pl.med_rate(1.0), pl.med_rate(PROFILES["average"]["focus"])
    P(f"   AFK {afk:.2f}/s ({afk * 3600:,.0f} Power/hour); average Focus {foc:.2f}/s; "
      f"offline {afk * OFFLINE_X:.2f}/s, max {afk * OFFLINE_X * OFFLINE_CAP_H * 3600:,.0f} per 8 h")
    pl.zone = 1
    pl.slots = 5
    pl.pets = [Pet(1, 0, 0) for _ in range(5)]
    P(f"   zone 2 Shrine, 5 zone-2 Commons: AFK {pl.med_rate(1.0) * 3600:,.0f} Power/hour")
    P("")
    P("7. Crowded server: a beginner's \"Defeat 20 Shardlings\" next to veterans (median of 50 runs, seconds)")
    P("   veterans:                 0      3      6     10")
    for personal in (False, True):
        cells = [st.median(crowded_quest_time(v, personal, seed_=r) for r in range(50)) for v in (0, 3, 6, 10)]
        label = "with protected quest pack" if personal else "shared monsters only    "
        P("   " + label + "  " + "  ".join(f"{c:5.0f}" for c in cells))
    P("   (900 = never finished in 15 min. The protected pack keeps the beginner at the solo pace or better.)")
    P("")
    P("8. AFK-only player (never hunts): Power keeps growing, but the boss gate never opens")
    P("   (rank quests 2-4 need kills and hatches, which need coins, which only hunting gives).")
    return "\n".join(out), agg


if __name__ == "__main__":
    text, _ = report()
    print(text)
    open("RESULTS.txt", "w").write(text + "\n")
