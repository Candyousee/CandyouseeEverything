"""AURA CLASH v7 balance model: plays the rules second by second with simulated players, zones 1-10.

Meditation (AFK / Focus / offline), hunting crystal monsters with hold-release blasts (PERFECT, combo,
Overdrive chains), mutations, the capped Shard Storm + SELL, coins -> eggs / Bag / Mat / Surge,
pets (Strength = rarity x zone x stars x level, stars 0-5, XP from every kill to equipped pets),
fusion, rank quests (difficulty tiers), bosses (3 phases + beam clash) and their Boss Shard reward.

Run: python model.py   (prints RESULTS; seeded, reproducible; a few minutes)
Every constant below is a rule in CORE-LOOP.md / GAME-BIBLE.md. Change one = change the docs.
Monetization is NOT modelled: these are free-player numbers.
"""
import math, random, statistics as st, zlib

# ---------------- RULES: blasting ----------------
START_POWER, TUTORIAL_POWER, TUTORIAL_TIME = 10, 40, 20
BLAST_TIME, LATE_STAGGER = 1.4, 0.5            # 1.2 s hold + 0.2 s recovery; a late release staggers 0.5 s
EARLY_X, LATE_X, PERFECT_X = 0.6, 0.5, 2.0
COMBO = [1.0, 1.25, 1.5, 1.75, 2.0]            # PERFECT: +1 level; any other release: -1 level
OD_STREAK, OD_TIME, SURGE_STEP = 5, 8.0, 2.0   # 5 PERFECTs in a row -> Overdrive 8 s (+2 s per Surge level)
OD_CHAIN_N, OD_CHAIN_X, OD_AFTER = 2, 0.5, 2   # chains to 2 more monsters at 50%; combo after = level 2 (x1.5)

# ---------------- RULES: zones ----------------
ZONES = 10
ZONE_NAMES = ["Lumora Grove", "Pyrora Dojo", "Glacora Peaks", "Voltora Cliffs", "Blossora Gardens",   # naming theme:
              "Nyxora Rift", "Astora Throne", "Seraphora Gate", "Drakora Sanctum", "Aurora Nexus"]      # "-ora" + a place
MONSTER_NAMES = [("Shardling", "Crystal Boar", "Crag Brute"),
                 ("Ember Slime", "Lava Hound", "Obsidian Brute"),
                 ("Snowling", "Ice Ram", "Glacier Titan"),
                 ("Spark Wisp", "Thunder Hawk", "Storm Colossus"),
                 ("Petal Sprite", "Blossom Fox", "Ancient Treant"),
                 ("Void Mite", "Shade Stalker", "Rift Behemoth"),
                 ("Star Mote", "Comet Beast", "Nebula Giant"),
                 ("Halo Sprite", "Seraph Knight", "Celestial Guardian"),
                 ("Ember Drakelet", "Crystal Wyvern", "Elder Dragon Golem"),
                 ("Aura Wisp", "Prism Knight", "Nexus Colossus")]
HP_BASE, HP_STEP = (20, 200, 2000), 16         # monster HP x16 per zone
VAL_BASE, VAL_STEP = (3, 40, 250), 10          # Shard, Bright Shard, Gem coins x10 per zone
DROPS = [(1, 0.0, 0.0), (3, 0.2, 0.0), (8, 2.0, 0.1)]   # shards, bright (expected), gem chance
OVERHEAD = (0.6, 1.5, 3.0)                     # seconds to reach the next target
KILL_XP, XP_STEP = (1, 4, 15), 3               # XP to EVERY equipped pet per kill, x3 per zone
NEARBY = [3, 1, 0]                             # same-type monsters within chain range (packs / pairs / alone)
BIG_MIN_CYCLE = 10.0                           # 3 Brutes per zone, 30 s respawn -> at most one every ~10 s


def monster(z, i):
    """(name, hp, shards, bright, gem chance, overhead)"""
    sh, br, gem = DROPS[i]
    return (MONSTER_NAMES[z][i], HP_BASE[i] * HP_STEP ** z, sh, br, gem, OVERHEAD[i])


def shard_val(z):
    return tuple(v * VAL_STEP ** z for v in VAL_BASE)


SHRINE = [0.5 * 4 ** min(z, 3) * 5 ** max(0, z - 3) for z in range(ZONES)]   # Power / s, AFK: x4 per zone, x5 from zone 5
EGG_PRICE = [60, 1_500, 25_000, 400_000, 6_000_000, 100_000_000, 1_500_000_000, 25_000_000_000,
             250_000_000_000, 3_500_000_000_000]
BOSS = [dict(name="Stone Golem", rec=300, form="BLAZE"),
        dict(name="Magma Oni", rec=10_000, form="INFERNO"),
        dict(name="Frost Wyrm", rec=200_000, form="GLACIER"),
        dict(name="Thunder Roc", rec=4_000_000, form="TEMPEST"),
        dict(name="Blossom Ronin", rec=60_000_000, form="BLOOM"),
        dict(name="Void Leviathan", rec=1_000_000_000, form="ECLIPSE"),
        dict(name="Star Emperor", rec=15_000_000_000, form="COSMIC"),
        dict(name="Archangel Sentinel", rec=200_000_000_000, form="RADIANT"),
        dict(name="Elder Dragon Emperor", rec=2_500_000_000_000, form="DRAGONSOUL"),
        dict(name="The Ascendant", rec=30_000_000_000_000, form="ASCENDED")]
BOSS_HP_X = [1.0] + [2.5] * (ZONES - 1)
BOSS_SHARD_EGGS = 3                            # Boss Shards sell for about 3 eggs of the NEXT zone (the last: 3 of its own)
PLATES, PLATE_HP_X, BODY_HP_X = 6, 3.3, 20     # boss HP = these x recommended Power x BOSS_HP_X
BOSS_DODGE_SHARE = 0.4
CLASH_START, CLASH_HIT_COST, CLASH_FLOOR = 60, 5, 30
CLASH_PERFECT, CLASH_OTHER = 12, 6
CLASH_DRIFT = 3.0                              # boss push per second at Power = recommended (x rec / Power, max x4)
CLASH_COUNTER_EVERY, CLASH_COUNTER_WIN, CLASH_COUNTER_LOSS = 4.0, 5, 8
CLASH_TIMEOUT = 30.0
BOSS_RETRY_GAP = 20.0


def boss_shard_value(z):
    return BOSS_SHARD_EGGS * EGG_PRICE[min(z + 1, ZONES - 1)]


# ---------------- RULES: pets ----------------
TIERS = ["Common", "Uncommon", "Rare", "Epic", "Legendary", "Mythic", "Secret", "Divine", "Impossible", "Boundless"]
RARITIES = TIERS
TIER_STR = [1, 1.5, 2.5, 4, 10, 25]                              # base Strength, Common .. Mythic
SECRET_MULT = {6: 1, 7: 10, 8: 100, 9: 1000}   # Secret+ = this x YOUR best normal pet (live, so it scales all game), x its stars
LUCK_EXP = [0, 0, 0, 0, 0.3, 0.5, 0.8, 0.9, 1.0, 1.0]           # luck works hardest on the rarest tiers
SECRET_TIERS = (6, 7, 8, 9)                                     # Secret and above: serialized; "Secret luck" applies
# A tier is DEFINED by its odds band (lower bound inclusive). "Secret 1 in 1M+", "Divine 1 in 10M+",
# "Impossible 1 in 1B+", "Boundless 1 in 1T+" (owner).
def tier_of(p):
    """Tier from the odds band: Common >= 25%, Uncommon >= 10%, Rare >= 2%, Epic >= 0.5%, Legendary >= 1 in 10K,
    Mythic rarer than that down to 1 in 1M; Secret 1 in 1M+, Divine 1 in 10M+, Impossible 1 in 1B+, Boundless 1 in 1T+."""
    for t, lo in enumerate((0.25, 0.10, 0.02, 0.005, 1e-4)):
        if p >= lo:
            return t
    for t, hi in ((5, 1e-6), (6, 1e-7), (7, 1e-9), (8, 1e-12)):
        if p > hi:
            return t
    return 9


BOUNDLESS_P = 1e-12                       # 1 in 1T: in EVERY egg; a new Boundless pet every month (global)
EGG_NAMES = [
    ["Light Fox", "Glow Bunny", "Prism Owl", "Sun Pup", "Halo Lynx", "Dawn Griffin", "Solar Kirin", "Radiant Pegasus", "Aurora Dragon", "Prism Archangel", "Lumen the Endless"],
    ["Ember Imp", "Cinder Pup", "Magma Toad", "Blaze Ferret", "Lava Salamander", "Inferno Wolf", "Phoenix", "Sunforge Drake", "Volcano Titan", "Solar Behemoth", "Ignis Eternal"],
    ["Snow Hare", "Frost Penguin", "Ice Fox", "Glacier Seal", "Crystal Yeti", "Blizzard Owl", "Frost Kirin", "Aurora Stag", "Glacial Leviathan", "Frostfall Empress", "Absolute Zero"],
    ["Static Mouse", "Volt Bat", "Thunder Pup", "Zap Lizard", "Storm Falcon", "Lightning Tiger", "Thunderbird", "Tempest Dragon", "Raijin", "Storm Sovereign", "Thunder Infinite"],
    ["Petal Bunny", "Leaf Kit", "Koi Spirit", "Bamboo Panda", "Sakura Fox", "Moss Golem", "Kitsune", "Jade Dragon", "Celestial Koi", "Eternal Bloom Dragon", "World Tree Spirit"],
    ["Shadow Cat", "Void Bat", "Rift Wisp", "Gloom Wolf", "Shade Panther", "Void Serpent", "Eclipse Dragon", "Abyss Kraken", "Null Wyrm", "Abyssal Emperor", "The Void Itself"],
    ["Star Puff", "Comet Pup", "Nebula Jelly", "Meteor Fox", "Galaxy Whale", "Orbit Lion", "Supernova Phoenix", "Cosmic Dragon", "Starborn Titan", "Galaxy Devourer", "Big Bang"],
    ["Halo Chick", "Angel Bunny", "Seraph Cat", "Wing Pup", "Archon Owl", "Seraph Lion", "Celestial Kirin", "Holy Griffin", "The First Light", "Seraph Prime", "Eternal Halo"],
    ["Dragon Hatchling", "Ember Wyrmling", "Jade Drakelet", "Scale Pup", "Crystal Wyvern", "Storm Drake", "Ancient Dragon", "Dragon King", "Primordial Dragon", "Dragon God", "Endless Wyrm"],
    ["Aura Sprite", "Prism Puff", "Spectrum Fox", "Halo Hound", "Nexus Owl", "Prism Tiger", "Rainbow Kirin", "Aura Phoenix", "Spectrum Dragon", "Nexus Sovereign", "Aura Infinite"],
]
# Two egg layouts so eggs differ (owner): odd zones "two Commons", even zones "three Commons". Every zone then
# gets its own numbers: (commons, rare tiers as 1-in-N).
EGG_ODDS = [   # zone: [11 chances in EGG_NAMES order]; the first Common takes the exact remainder
    [0.35, 0.34, 0.18, 0.08, 0.035, 0.012, 1 / 400, 1 / 25_000, 1 / 2_500_000, 1 / 100_000_000, 1 / 10_000_000_000],
    [0.30, 0.28, 0.26, 0.11, 0.036, 0.010, 1 / 300, 1 / 15_000, 1 / 1_500_000, 1 / 50_000_000, 1 / 5_000_000_000],
    [0.37, 0.32, 0.18, 0.08, 0.035, 0.012, 1 / 450, 1 / 30_000, 1 / 3_000_000, 1 / 150_000_000, 1 / 20_000_000_000],
    [0.31, 0.27, 0.26, 0.11, 0.036, 0.010, 1 / 350, 1 / 20_000, 1 / 2_000_000, 1 / 80_000_000, 1 / 8_000_000_000],
    [0.36, 0.33, 0.17, 0.09, 0.035, 0.012, 1 / 500, 1 / 35_000, 1 / 4_000_000, 1 / 200_000_000, 1 / 30_000_000_000],
    [0.29, 0.29, 0.26, 0.11, 0.036, 0.010, 1 / 400, 1 / 25_000, 1 / 2_500_000, 1 / 120_000_000, 1 / 12_000_000_000],
    [0.34, 0.35, 0.17, 0.09, 0.035, 0.012, 1 / 550, 1 / 40_000, 1 / 5_000_000, 1 / 300_000_000, 1 / 50_000_000_000],
    [0.33, 0.26, 0.26, 0.11, 0.026, 0.010, 1 / 450, 1 / 30_000, 1 / 3_000_000, 1 / 200_000_000, 1 / 20_000_000_000],
    [0.38, 0.31, 0.17, 0.09, 0.035, 0.012, 1 / 600, 1 / 50_000, 1 / 6_000_000, 1 / 500_000_000, 1 / 100_000_000_000],
    [0.30, 0.30, 0.25, 0.11, 0.026, 0.010, 1 / 500, 1 / 40_000, 1 / 4_000_000, 1 / 300_000_000, 1 / 40_000_000_000],
]


def _build_egg(z):
    odds = list(EGG_ODDS[z])
    odds[0] = 1 - sum(odds[1:]) - BOUNDLESS_P              # exact total of 1 including the Boundless line
    table = [(EGG_NAMES[z][k], tier_of(p), p) for k, p in enumerate(odds)]
    table.append(("Boundless (this month's)", 9, BOUNDLESS_P))
    return table


EGGS = [_build_egg(z) for z in range(ZONES)]

# Exclusive Eggs (MONETIZATION.md 6): same tier bands, a Boundless line, fixed odds (luck doesn't change paid eggs)
def _exclusive(names, chances):
    odds = [None] + list(chances)
    odds[0] = 1 - sum(chances)
    return [(n, tier_of(p), p) for n, p in zip(names, odds)]


EXCLUSIVE_EGGS = {
    "Daily Exclusive (Neon)": dict(price=(49, 99, 249), strength_x=5, table=_exclusive(
        ["Neon Cat", "Neon Wolf", "Neon Tiger", "Neon Fox", "Neon Dragon", "Neon Phoenix", "Neon Kirin", "Neon Seraph",
         "Neon Leviathan", "Neon Infinity", "Boundless (this month's)"],
        [0.22, 0.09, 0.045, 0.012, 1 / 350, 1 / 20_000, 1 / 2_000_000, 1 / 200_000_000, 1 / 20_000_000_000, BOUNDLESS_P])),
    "Shop Exclusive (Royal)": dict(price=(99, 279, 849), strength_x=10, table=_exclusive(
        ["Royal Corgi", "Royal Lion", "Royal Griffin", "Royal Phoenix", "Royal Dragon", "Royal Kirin", "Royal Seraph",
         "Royal Sovereign", "Royal Emperor", "Royal Infinity", "Boundless (this month's)"],
        [0.30, 0.20, 0.07, 0.019, 1 / 250, 1 / 12_000, 1 / 1_000_000, 1 / 50_000_000, 1 / 5_000_000_000, BOUNDLESS_P])),
}
STARTER_SPECIES = 0                                     # the tutorial Light Fox
PET_STEP = 2                                   # zone pets x2 Strength per zone
STAR = [1, 2, 4, 8, 16, 32]                    # stars 0-5: each star doubles; 3 copies -> 1 of the next star
MAX_STARS = 5
LEVEL_X, MAX_LEVEL = 0.05, 30                  # +5% Strength per level above 1
XP_TO_NEXT = lambda lv, pz: 10 * lv * XP_STEP ** pz   # a pet from zone pz needs this XP for lv -> lv+1
PET_HIT_EVERY, PET_HIT_X = 1.5, 0.04           # each pet hits every 1.5 s for Strength x 4% of Power ...
TEAM_HIT_CAP = 1.0                             # ... but the whole team's hit is capped at 100% of your Power
MED_PER_STR = 0.10                             # meditation +10% per point of equipped Strength
AUTO_FUSE_MAX_RARITY = 2                       # auto-fuse: Commons, Uncommons, Rares; unequipped copies only
BASE_SLOTS, INVENTORY = 3, 250

# ---------------- RULES: economy ----------------
MAT_STEP = 0.25
OFFLINE_X, OFFLINE_CAP_H = 0.25, 8
#             name        chance      value  HP
STORM_EVERY, STORM_LENGTH, STORM_X = 45 * 60, 5 * 60, 2.0   # natural Mutation Storms
MUTATIONS = [("Gold",      1 / 25,     5,  2),
             ("Fire",      1 / 60,    10,  3),
             ("Frost",     1 / 60,    10,  3),
             ("Rainbow",   1 / 400,   25,  4),
             ("Void",      1 / 2000,  75,  6),
             ("Celestial", 1 / 10000, 250, 8)]
BAG = [60, 100, 150, 200, 250, 300, 400, 500]
BAG_PRICE = [50, 250, 3_000, 10_000, 100_000, 2_000_000, 50_000_000]
MAT_PRICE = [100, 400, 4_000, 12_000, 150_000, 1_000_000, 20_000_000, 400_000_000, 10_000_000_000, 250_000_000_000,
             4_000_000_000_000, 60_000_000_000_000]
SURGE_PRICE = [300, 5_000, 200_000, 30_000_000, 5_000_000_000]
SELL_TIME, HATCH_TIME, ALTAR_TIME = 3.0, 2.0, 5.0

# ---------------- RULES: rank quests (difficulty tiers; owner) ----------------
TIER = ["very easy"] * 3 + ["easy"] * 3 + ["medium"] * 2 + ["hard"] * 2
TIER_QUESTS = {
    "very easy": lambda z: [("focus", 20 if z == 0 else 60), ("kill", 0, 20 if z == 0 else 50),
                            ("hatch", 5 if z == 0 else 8), ("kill", 1, 10 if z == 0 else 20)]
                           + ([("level", 10)] if z > 0 else []),
    "easy":      lambda z: [("focus", 90), ("kill", 0, 80), ("hatch", 12), ("kill", 1, 40), ("kill", 2, 5), ("level", 15)],
    "medium":    lambda z: [("focus", 120), ("kill", 0, 150), ("hatch", 20), ("kill", 1, 80), ("kill", 2, 15),
                            ("mutated", 0, 5), ("stars", 2)],
    "hard":      lambda z: [("focus", 180), ("kill", 0, 250), ("hatch", 30), ("kill", 1, 120), ("kill", 2, 30),
                            ("mutated", 3, 1), ("stars", 3), ("level", 25)],
}
QUESTS = [TIER_QUESTS[TIER[z]](z) + [("power", BOSS[z]["rec"])] for z in range(ZONES)]
SLOT_QUESTS = {(0, 0), (0, 3), (1, 0), (1, 3), (2, 0), (3, 0), (4, 0)}   # 3 + 7 = 10 slots max
# every other quest (except the last, which opens the boss gate) gives a free egg of that zone

# ---------------- MONETIZATION (MONETIZATION.md): what a purchase changes ----------------
LADDER_PRICES = [3, 9, 19, 29, 49, 79, 149, 249, 399, 799, 999]   # "2x Boost" ladder: each tier doubles Luck AND Power


def ladder_cost(tiers):
    return sum(LADDER_PRICES[:tiers])


SLOT_PACK_PRICE, SLOT_PACK_MAX = 199, 10                         # +2 pet slots per purchase, up to 10 purchases
PASS_PRICES = dict(vip=399, coins2=399, secret2=199, hatch_speed2=399, hatch8=399,
                   huge_storm=199, auto_sell=199, offline_plus=99, mutation_magnet=99)

PAID = {   # what a spending profile changes (MONETIZATION.md); rs = what it costs in Robux
    "free":    dict(coin_x=1.0, med_x=1.0, luck=1.0, secret_x=1.0, hatch_x=1.0, multi=1, slots=0, rs=0),
    "starter": dict(coin_x=1.0, med_x=8.0, luck=8.0, secret_x=1.0, hatch_x=1.0, multi=1, slots=0,     # 3 ladder tiers
                    rs=ladder_cost(3)),
    "vip":     dict(coin_x=3.0, med_x=1.5 * 64, luck=64.0, secret_x=1.5, hatch_x=1.5, multi=1, slots=1,   # VIP + 2x Coins
                    rs=PASS_PRICES["vip"] + PASS_PRICES["coins2"] + ladder_cost(6)),  # + 6 ladder tiers
    "whale":   dict(coin_x=3.0, med_x=1.5 * 2048, luck=2048.0, secret_x=3.0, hatch_x=3.0, multi=8, slots=1 + 20,
                    rs=sum(PASS_PRICES.values()) + ladder_cost(11) + SLOT_PACK_PRICE * SLOT_PACK_MAX),
}

PROFILES = {  # perfect rate, Focus average multiplier, counter success, mean hits taken per boss
    "weak":    dict(p=0.35, focus=1.8, counter=0.40, hits=4.0),
    "average": dict(p=0.60, focus=2.4, counter=0.65, hits=2.0),
    "strong":  dict(p=0.80, focus=2.8, counter=0.90, hits=1.0),
}


def seed(*parts):
    return zlib.crc32("|".join(map(str, parts)).encode())


RARE_SHARE_MAX = 0.90       # NOT a luck cap: luck has no cap, but chances must add to 100%,
                            # so Legendary-and-up together can never pass 90% of hatches.
_ODDS_CACHE = {}


def egg_odds(z, luck=1.0, secret_x=1.0):
    """The real odds for zone z's egg at this luck (what the egg card shows). Tiers from Legendary up are
    multiplied by luck ** LUCK_EXP[tier] (Secret+ also by secret_x); lower tiers share the rest in their own ratio."""
    key = (z, luck, secret_x)
    if key in _ODDS_CACHE:
        return _ODDS_CACHE[key]
    luck = max(1.0, luck)
    rare_idx = [k for k, (_, t, _) in enumerate(EGGS[z]) if t >= 4]
    low_idx = [k for k, (_, t, _) in enumerate(EGGS[z]) if t < 4]
    odds = [p for _, _, p in EGGS[z]]
    for k in rare_idx:
        t = EGGS[z][k][1]
        odds[k] = EGGS[z][k][2] * luck ** LUCK_EXP[t] * (secret_x if t in SECRET_TIERS else 1.0)
    rare = sum(odds[k] for k in rare_idx)
    if rare > RARE_SHARE_MAX:
        for k in rare_idx:
            odds[k] *= RARE_SHARE_MAX / rare
        rare = RARE_SHARE_MAX
    base_low = sum(EGGS[z][k][2] for k in low_idx)
    for k in low_idx:
        odds[k] = EGGS[z][k][2] / base_low * (1 - rare)
    _ODDS_CACHE[key] = odds
    return odds


def roll_species(rng, z, luck=1.0, secret_x=1.0):
    odds = egg_odds(z, luck, secret_x)
    x, acc = rng.random(), 0.0
    for k, o in enumerate(odds):
        acc += o
        if x < acc:
            return k
    return 0


def egg_roll(rng, z=0):
    return EGGS[z][roll_species(rng, z)][1]





class Pet:
    __slots__ = ("z", "r", "sp", "stars", "lv", "xp")

    def __init__(self, z, r, sp):
        self.z, self.r, self.sp, self.stars, self.lv, self.xp = z, r, sp, 0, 1, 0

    def strength(self, best_normal=1.0):
        if self.r in SECRET_MULT:                         # Secret+: relative to your best normal pet
            return SECRET_MULT[self.r] * best_normal * STAR[self.stars]
        return TIER_STR[self.r] * PET_STEP ** self.z * STAR[self.stars] * (1 + LEVEL_X * (self.lv - 1))


class Player:
    def __init__(self, profile, run=0, log=False, paid="free"):
        self.pf, self.name = PROFILES[profile], profile
        self.paid = PAID[paid]
        self.rng = random.Random(seed(profile, run))
        self.t, self.power, self.coins = 0.0, START_POWER, 0
        self.bag, self.bag_val = 0, 0
        self.bag_lv = self.mat_lv = self.surge_lv = 0
        self.pets, self.slots, self.hatches, self.zone_hatches = [], BASE_SLOTS + self.paid["slots"], 0, {}
        self.zone, self.quest, self.kills, self.mut_kills = 0, 0, {}, {}
        self.combo, self.streak = 0, 0
        self.od_until, self.od_active = -1.0, False   # Overdrive ends at a TIMESTAMP: real time keeps running
        self.field, self.last_big = [], -1e9
        self.kill_log = []
        self.log_on, self.events = log, []
        self.hunt_time = self.med_time = self.player_dmg = self.pet_dmg = 0.0
        self.coins_earned = self.mut_coins = self.boss_coins = 0
        self.sells_since_med = 0
        self.milestones = {}
        self.zone_stats = {}
        self._team = None

    # ---------- helpers ----------
    def note(self, key, text=None):
        self.milestones.setdefault(key, self.t)
        if self.log_on and text:
            self.events.append((self.t, text))

    def dirty(self):
        self._team = None

    def team(self):
        if self._team is None:
            bn = max((q.strength() for q in self.pets if q.r not in SECRET_MULT), default=1.0)
            team = sorted(self.pets, key=lambda p: -p.strength(bn))[: self.slots]
            self._team = (team, sum(p.strength(bn) for p in team))
        return self._team[0]

    def team_str(self):
        self.team()
        return self._team[1]

    def med_rate(self, focus):
        return (SHRINE[self.zone] * focus * (1 + MED_PER_STR * self.team_str()) * (1 + MAT_STEP * self.mat_lv)
                * self.paid["med_x"])

    def exp_blast(self):
        p = self.pf["p"]
        return self.power * (p * PERFECT_X * combo_avg(p) + (1 - p) * 0.75 * EARLY_X + (1 - p) * 0.25 * LATE_X)

    def team_hit_x(self):
        """The team's combined hit as a share of your Power (each pet Strength x 4%, capped at 100% in total)."""
        return min(TEAM_HIT_CAP, self.team_str() * PET_HIT_X)

    def exp_dps(self):
        return self.exp_blast() / BLAST_TIME + self.team_hit_x() * self.power / PET_HIT_EVERY

    def green(self, z, i):
        """HP bar is green when the monster dies to about 3 of your blasts (pets included)."""
        return monster(z, i)[1] <= 3 * BLAST_TIME * self.exp_dps()

    # ---------- meditation ----------
    def meditate(self, seconds, focus=True):
        f = self.pf["focus"] if focus else 1.0
        gain = self.med_rate(f) * seconds
        self.power += gain
        self.t += seconds
        self.med_time += seconds
        self.sells_since_med = 0
        return gain

    def meditate_until(self, target, cap=None):
        need = max(0.0, target - self.power)
        secs = need / self.med_rate(self.pf["focus"]) + 5   # +5 s to sit down and build Focus
        if cap:
            secs = min(secs, cap)
        self.meditate(secs)
        self.note(f"meditate_z{self.zone}", f"meditates to Power {self.power:.0f}")

    # ---------- hunting ----------
    def blast(self):
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
        z, best, best_rate = self.zone, 0, -1
        sv = shard_val(z)
        for i in range(3):
            name, hp, sh, br, gem, over = monster(z, i)
            if not self.green(z, i) and hp / self.exp_dps() > 6:
                continue
            value = sh * sv[0] + br * sv[1] + gem * sv[2]
            kt = hp / self.exp_dps() + over
            if i == 2:
                kt = max(kt, BIG_MIN_CYCLE)
            if value / kt > best_rate:
                best, best_rate = i, value / kt
        return best

    def in_mutation_storm(self):
        """A natural Mutation Storm hits every server for 5 min every 45 min (mutation chances x2)."""
        return self.t % STORM_EVERY < STORM_LENGTH

    def roll_mutation(self):
        """ONE roll against exclusive bands, so each mutation's real chance is exactly its advertised chance
        (doubled during a Mutation Storm)."""
        x, acc = self.rng.random(), 0.0
        mx = STORM_X if self.in_mutation_storm() else 1.0
        for m in MUTATIONS:
            acc += m[1] * mx
            if x < acc:
                return m
        return None

    def spawn(self, mi):
        mut = self.roll_mutation()
        if self.milestones.get("mut_tutorial") is None and self.zone == 0 and self.t > 60:
            mi, mut = 0, MUTATIONS[0]                        # the guaranteed tutorial Gold Shardling
            self.note("mut_tutorial", "the tutorial Gold Shardling")
        return {"mi": mi, "hp": monster(self.zone, mi)[1] * (mut[3] if mut else 1), "mut": mut}

    def fill_field(self, mi):
        want = 1 + NEARBY[mi]
        while len(self.field) < want:
            self.field.append(self.spawn(mi))
        del self.field[want:]

    def start_overdrive(self):
        self.od_until = self.t + OD_TIME + SURGE_STEP * self.surge_lv
        self.od_active = True
        self.note("overdrive", "first OVERDRIVE")

    def in_overdrive(self):
        if self.od_active and self.t + BLAST_TIME > self.od_until:
            self.od_active = False
            self.combo, self.streak = OD_AFTER, 0
        return self.od_active

    def loot(self, mon, cause, in_od=False):
        z, mi, mut = self.zone, mon["mi"], mon["mut"]
        name, hp, sh, br, gem, over = monster(z, mi)
        sv = shard_val(z)
        n_bright = int(br) + (1 if self.rng.random() < br - int(br) else 0)
        n_gem = 1 if self.rng.random() < gem else 0
        vx = mut[2] if mut else 1
        for val, n in ((sv[0], sh), (sv[1], n_bright), (sv[2], n_gem)):
            for _ in range(n):
                if self.bag < BAG[self.bag_lv]:          # 1 shard = 1 slot, whatever its mutation
                    self.bag += 1
                    self.bag_val += val * vx
                    if mut:
                        self.mut_coins += val * (vx - 1)
        self.give_xp(KILL_XP[mi] * XP_STEP ** z)        # XP goes straight to every equipped pet
        self.kills[(z, mi)] = self.kills.get((z, mi), 0) + 1
        if mut:
            rank = MUTATIONS.index(mut)
            self.mut_kills[(z, rank)] = self.mut_kills.get((z, rank), 0) + 1
        self.kill_log.append((self.t, name, cause, in_od))

    def give_xp(self, xp):
        for pet in self.team():
            if pet.lv >= MAX_LEVEL:
                continue
            pet.xp += xp
            while pet.lv < MAX_LEVEL and pet.xp >= XP_TO_NEXT(pet.lv, pet.z):
                pet.xp -= XP_TO_NEXT(pet.lv, pet.z)
                pet.lv += 1
                self.note("first_level", "first pet level-up")
                self.dirty()

    def hunt_blast(self, mi):
        """One blast at the field's target. Overdrive chains hit at most OD_CHAIN_N nearby monsters for 50%.
        Excess damage is lost (it never carries over into extra kills)."""
        self.fill_field(mi)
        trigger_od = False
        if self.in_overdrive():
            d, dt, perf = self.power * PERFECT_X * COMBO[4], BLAST_TIME, True
            in_od = True
        else:
            d, dt, perf = self.blast()
            in_od = False
            trigger_od = self.streak >= OD_STREAK      # the 5th PERFECT in a row triggers Overdrive ...
        pet_d = self.team_hit_x() * self.power * (dt / PET_HIT_EVERY + (1 if perf else 0))
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
        if trigger_od:                                 # ... and its 8 s start when that blast lands
            self.start_overdrive()
            self.streak = 0
        dead = [m for m in self.field if m["hp"] <= 0]
        target_died = target["hp"] <= 0
        for m in dead:
            self.field.remove(m)
            self.loot(m, "target" if m is target else "chain", in_od)
            if self.bag >= BAG[self.bag_lv]:
                self.sell()
        if target_died:
            over = OVERHEAD[mi]
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
    def sell(self, extra=0):
        self.t += SELL_TIME
        gained = int((self.bag_val + extra) * self.paid["coin_x"])
        self.coins += gained
        self.coins_earned += gained
        self.note("first_sell", f"first SELL: {gained} coins")
        self.milestones["_sells"] = self.milestones.get("_sells", 0) + 1
        self.bag, self.bag_val = 0, 0
        self.sells_since_med += 1
        self.spend()
        if self.fuse(dry_run=True):                    # "Stay" at the Shrine and use the Fusion Altar
            self.t += ALTAR_TIME
            self.fuse()

    def next_upgrade(self):
        options = []
        for kind, table, lv in (("bag", BAG_PRICE, self.bag_lv), ("mat", MAT_PRICE, self.mat_lv),
                                ("surge", SURGE_PRICE, self.surge_lv)):
            if lv < len(table):
                options.append((table[lv], kind))
        return min(options) if options else (None, None)

    def spend(self):
        egg = EGG_PRICE[self.zone]
        while True:
            if len(self.pets) < self.slots and self.coins >= egg:
                self.hatch()
                continue
            cost, kind = self.next_upgrade()
            if kind and self.coins >= cost:
                self.coins -= cost
                setattr(self, kind + "_lv", getattr(self, kind + "_lv") + 1)
                self.note(f"{kind}{getattr(self, kind + '_lv')}")
                continue
            if kind and cost <= 3 * egg:
                return                                 # save for the next upgrade
            if self.coins >= egg:
                self.hatch()
                continue
            return

    def hatch(self, free=False):
        z = self.zone
        if not free:
            self.coins -= EGG_PRICE[z]
        multi = max(self.paid["multi"], 3 if self.milestones.get("boss1") is not None else 1)   # x3 free after boss 1; x8 pass
        self.t += HATCH_TIME / multi / self.paid["hatch_x"]
        self.hatches += 1
        self.zone_hatches[z] = self.zone_hatches.get(z, 0) + 1
        if self.hatches == 1:
            sp = STARTER_SPECIES if z == 0 else 0           # the tutorial Light Fox
        elif self.hatches == 3 and not any(p.r >= 2 for p in self.pets):
            sp = next(k for k, (_, t, _) in enumerate(EGGS[z]) if t == 2)   # guaranteed Rare on the 3rd hatch
        else:
            sp = roll_species(self.rng, z, self.paid["luck"], self.paid["secret_x"])
        self.pets.append(Pet(z, EGGS[z][sp][1], sp))
        self.note("first_hatch", "first hatch")
        self.dirty()
        self.auto_fuse()
        if len(self.pets) > INVENTORY:                       # auto-delete the weakest unequipped pets
            keep = set(map(id, self.team()))
            spare = sorted((p for p in self.pets if id(p) not in keep and p.r not in SECRET_MULT),   # Secret+ auto-locked
                           key=lambda p: p.strength())
            for p in spare[: len(self.pets) - INVENTORY]:
                self.pets.remove(p)
            self.dirty()

    def auto_fuse(self):
        """Auto-fuse (on by default): Commons + Rares, UNEQUIPPED copies only. Never touches the team."""
        changed = True
        while changed:
            changed = False
            team = set(map(id, self.team()))
            groups = {}
            for p in self.pets:
                if p.r <= AUTO_FUSE_MAX_RARITY and p.stars < MAX_STARS and id(p) not in team:
                    groups.setdefault((p.z, p.r, p.sp, p.stars), []).append(p)
            for (z, r, sp, s), lst in groups.items():
                if len(lst) >= 3:
                    lst.sort(key=lambda p: -p.lv)
                    for p in lst[:3]:
                        self.pets.remove(p)
                    new = Pet(z, r, sp)
                    new.stars, new.lv = s + 1, lst[0].lv
                    self.pets.append(new)
                    self.dirty()
                    self.note("first_star", "first star fusion")
                    changed = True
                    break

    def fuse(self, dry_run=False):
        """Manual fusion at the Fusion Altar: any rarity, equipped copies allowed, only if the team gets stronger
        (or a quest needs the stars)."""
        need_stars = self.quest_need_stars()
        did, changed = False, True
        while changed:
            changed = False
            groups = {}
            for p in self.pets:
                groups.setdefault((p.z, p.r, p.sp, p.stars), []).append(p)
            for (z, r, sp, s), lst in groups.items():
                if len(lst) < 3 or s >= MAX_STARS:
                    continue
                lst.sort(key=lambda p: -p.lv)
                before = self.team_str()
                keep = lst[:3]
                for p in keep:
                    self.pets.remove(p)
                new = Pet(z, r, sp)
                new.stars, new.lv = s + 1, keep[0].lv
                self.pets.append(new)
                self.dirty()
                better = self.team_str() > before + 1e-9 or (need_stars and s + 1 <= need_stars)
                if dry_run or not better:
                    self.pets.remove(new)
                    self.pets.extend(keep)
                    self.dirty()
                    if dry_run and better:
                        return True
                    continue
                self.note("first_star", "first star fusion")
                did = changed = True
                break
        return did

    # ---------- quests + bosses ----------
    def quest_need_stars(self):
        z = self.zone
        if self.quest < len(QUESTS[z]) and QUESTS[z][self.quest][0] == "stars":
            return QUESTS[z][self.quest][1]
        return 0

    def quest_check(self):
        """Advance rank quests; returns True when the current hunt should stop (a quest needs something else)."""
        z = self.zone
        while self.quest < len(QUESTS[z]):
            q = QUESTS[z][self.quest]
            if q[0] == "focus":
                return True
            if q[0] == "kill":
                done = self.kills.get((z, q[1]), 0) >= q[2]
            elif q[0] == "hatch":
                done = self.zone_hatches.get(z, 0) >= q[1]
            elif q[0] == "level":
                done = any(p.lv >= q[1] for p in self.team())
            elif q[0] == "mutated":
                done = sum(n for (mz, rank), n in self.mut_kills.items() if mz == z and rank >= q[1]) >= q[2]
            elif q[0] == "stars":
                done = any(p.stars >= q[1] for p in self.pets)
                if not done and self.fuse(dry_run=True):
                    self.t += ALTAR_TIME
                    self.fuse()
                    done = any(p.stars >= q[1] for p in self.pets)
            elif q[0] == "power":
                done = self.power >= q[1]
            if not done:
                return False
            self.quest_reward(z, self.quest)
            self.quest += 1
        return True

    def quest_reward(self, z, i):
        self.note(f"quest_z{z}_{i}")
        if (z, i) in SLOT_QUESTS:
            self.slots += 1
            self.dirty()
        elif i < len(QUESTS[z]) - 1:
            self.hatch(free=True)

    def boss_fight(self):
        z = self.zone
        rec = BOSS[z]["rec"]
        dps = self.exp_dps()
        hx = BOSS_HP_X[z]
        p1 = PLATES * PLATE_HP_X * rec * hx / (dps * (1 - BOSS_DODGE_SHARE))
        p2 = BODY_HP_X * rec * hx / (dps * (1 - BOSS_DODGE_SHARE))
        hits = min(6, int(self.rng.expovariate(1 / self.pf["hits"]) + 0.5))
        win, t3 = clash(self.pf["p"], self.pf["counter"], hits, self.power / rec, self.rng)
        self.t += p1 + p2 + t3
        return win, p1 + p2 + t3

    def record_zone(self, z):
        self.zone_stats[z] = dict(t=self.t, power=self.power, slots=self.slots, team=self.team_str(),
                                  hatches=self.zone_hatches.get(z, 0), coins=self.coins_earned,
                                  bag=BAG[self.bag_lv], mat=self.mat_lv, surge=self.surge_lv,
                                  best=max((p.r for p in self.team()), default=0),
                                  stars=max((p.stars for p in self.team()), default=0),
                                  lv=max((p.lv for p in self.team()), default=1))

    def run(self, until_zone=ZONES, max_t=24 * 3600):
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
                    self.boss_coins += boss_shard_value(z)
                    self.sell(extra=boss_shard_value(z))     # Boss Shards, sold at this zone's altar
                    self.record_zone(z)
                    self.zone += 1
                    self.quest = 0
                    self.field = []
                    continue
                self.t += BOSS_RETRY_GAP
                continue
            q = QUESTS[z][self.quest] if self.quest < len(QUESTS[z]) else None
            if q and q[0] == "power" and self.quest == len(QUESTS[z]) - 1:
                self.meditate_until(q[1])
                continue
            mi = self.pick_monster()
            nxt = mi + 1
            if self.sells_since_med >= 2 and nxt < 3 and not self.green(z, nxt):
                target = monster(z, nxt)[1] / (3 * BLAST_TIME) / max(1e-9, self.exp_dps() / self.power)
                self.meditate_until(target, cap=120)
                continue
            if q and q[0] == "kill" and self.kills.get((z, q[1]), 0) < q[2]:
                if q[1] <= mi or self.green(z, q[1]):
                    mi = q[1]
                else:                                         # the quest monster is too tough: meditate first
                    target = monster(z, q[1])[1] / (3 * BLAST_TIME) / max(1e-9, self.exp_dps() / self.power)
                    self.meditate_until(target, cap=300)
                    continue
            self.hunt_session(mi, seconds=30)
        return self


def loot_recipients(damage_log):
    """Shared monsters, personal loot: EVERY player whose hit landed gets their own full drop and quest credit."""
    return sorted(pid for pid, dmg in damage_log.items() if dmg > 0)


RAID_SHARE = 0.08          # raid bosses: you need 8% of the damage to share the rewards ...


def raid_recipients(damage_log):
    """... or half of an equal share when the raid is crowded (with 20 players nobody could otherwise all reach 8%).
    One tap with weak pets never qualifies."""
    total = sum(damage_log.values())
    fighters = sum(1 for d in damage_log.values() if d > 0)
    if total <= 0 or fighters == 0:
        return []
    need = min(RAID_SHARE, 0.5 / fighters)
    return sorted(pid for pid, d in damage_log.items() if d / total >= need)


def combo_avg(p):
    """Average combo multiplier on a PERFECT: stationary distribution of the +1 / -1 combo ladder."""
    pi = [1.0] * 5
    for i in range(1, 5):
        pi[i] = pi[i - 1] * (p / max(1e-9, 1 - p))
    tot = sum(pi)
    return sum((x / tot) * COMBO[min(4, i + 1)] for i, x in enumerate(pi))


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


# ---------------- REPORT ----------------
def fmt(s):
    if s is None:
        return "-"
    s = int(s)
    return f"{s // 3600}:{s % 3600 // 60:02d}:{s % 60:02d}" if s >= 3600 else f"{s // 60}:{s % 60:02d}"


def big(x):
    for v, suf in ((1e15, "Qa"), (1e12, "T"), (1e9, "B"), (1e6, "M"), (1e3, "K")):
        if abs(x) >= v:
            return f"{x / v:.3g}{suf}"
    return f"{x:.3g}"


def report(n_full=40, n_two=200):
    out = []
    P = out.append
    P("AURA CLASH v7 model results (python model.py). Free player, no monetization.\n")
    P("1. Average player, one seeded playthrough of zones 1-2 (seed 15, close to the median; the GAME-BIBLE zone 1 script)")
    pl = Player("average", 15, log=True).run(until_zone=2)
    for k, label in [("tutorial", "tutorial meditation done"), ("mut_tutorial", "tutorial Gold Shardling"),
                     ("first_sell", "first SELL"), ("first_hatch", "first hatch"), ("first_star", "first star fusion"),
                     ("quest_z0_0", "quest 1 (Focus 20 s)"), ("overdrive", "first Overdrive"),
                     ("first_level", "first pet level-up"), ("quest_z0_3", "quest 4 (10 Boars)"),
                     ("boss1", "boss 1 beaten"), ("quest_z1_0", "zone 2 quest 1"), ("boss2", "boss 2 beaten")]:
        P(f"   {label:28s} {fmt(pl.milestones.get(k))}")
    P("")
    P(f"2. Zones 1-2, {n_two} players per profile (median minutes)")
    P("   profile   first sell   boss 1   boss 2   meditating   pets' damage")
    for prof in PROFILES:
        rows = [Player(prof, r).run(until_zone=2) for r in range(n_two)]
        med = lambda k: st.median(x.milestones.get(k, 1e9) / 60 for x in rows)
        ms = st.mean(x.med_time / max(1, x.med_time + x.hunt_time) for x in rows)
        pd = st.mean(x.pet_dmg / max(1, x.pet_dmg + x.player_dmg) for x in rows)
        P(f"   {prof:8s}  {med('first_sell'):6.1f}     {med('boss1'):6.1f}   {med('boss2'):6.1f}     "
          f"{ms * 100:4.0f}%        {pd * 100:4.0f}%")
    P("")
    P(f"3. All {ZONES} zones, {n_full} players per profile: time to beat each boss (median h:mm:ss)")
    P("   zone  " + "".join(f"{p:>12s}" for p in PROFILES))
    full = {prof: [Player(prof, 1000 + r).run() for r in range(n_full)] for prof in PROFILES}
    for z in range(ZONES):
        cells = []
        for prof in PROFILES:
            v = st.median(x.milestones.get(f"boss{z + 1}", 24 * 3600) for x in full[prof])
            cells.append(f"{fmt(v):>12s}")
        P(f"   {z + 1}     " + "".join(cells))
    P("")
    P("4. Average player at each boss win (medians)")
    P("   zone  Power      team Str  slots  best rarity  stars  pet lv  Bag  Mat  Surge  coins earned  zone eggs")
    avg = full["average"]
    for z in range(ZONES):
        s = [x.zone_stats[z] for x in avg if z in x.zone_stats]
        if not s:
            continue
        m = lambda k: st.median(v[k] for v in s)
        P(f"   {z + 1}     {big(m('power')):9s} {big(m('team')):9s} {m('slots'):5.0f}  {RARITIES[int(m('best'))]:11s}  "
          f"{m('stars'):5.0f}  {m('lv'):6.0f}  {m('bag'):4.0f} {m('mat'):4.0f} {m('surge'):5.0f}  "
          f"{big(m('coins')):12s}  {m('hatches'):5.0f}")
    pd = st.mean(x.pet_dmg / max(1, x.pet_dmg + x.player_dmg) for x in avg)
    ms = st.mean(x.med_time / max(1, x.med_time + x.hunt_time) for x in avg)
    bc = st.mean(x.boss_coins / max(1, x.coins_earned) for x in avg)
    P(f"   over all {ZONES} zones: meditating {ms * 100:.0f}% of play time; pets {pd * 100:.0f}% of damage; "
      f"Boss Shards {bc * 100:.0f}% of all coins")
    P("")
    P(f"5. What purchases change (average player, {n_full // 2} players each; time to beat each boss, h:mm:ss)")
    P("   profiles: " + "; ".join(f"{k} = {v['rs']:,} R$" for k, v in PAID.items()))
    P("   zone   " + "".join(f"{k:12s}" for k in PAID))
    paid_rows = {k: [Player("average", 2000 + r, paid=k).run() for r in range(n_full // 2)] for k in PAID}
    for z in range(ZONES):
        cells = [fmt(st.median(x.milestones.get(f"boss{z + 1}", 24 * 3600) for x in paid_rows[k])) for k in PAID]
        P(f"   {z + 1}      " + "".join(f"{c:12s}" for c in cells))
    P("   Lumora Grove egg odds at each profile's luck (Legendary / Mythic / Secret / Divine / Impossible / Boundless):")
    for k, v in PAID.items():
        o = egg_odds(0, v["luck"], v["secret_x"])
        P(f"   {k:8s} " + " / ".join(("1 in " + f"{1 / x:,.0f}") if x < 0.01 else f"{x * 100:.2f}%" for x in o[6:]))
    P("")
    P("6. Beam clash win rate (2,000 fights per cell; 2 hits taken in phases 1-2)")
    P("   Power / recommended:    0.5     0.75    1.0     1.5     2.0")
    rng = random.Random(seed("clash"))
    for prof, pf in PROFILES.items():
        cells = []
        for ratio in (0.5, 0.75, 1.0, 1.5, 2.0):
            w = sum(clash(pf["p"], pf["counter"], 2, ratio, rng)[0] for _ in range(2000)) / 2000
            cells.append(f"{w * 100:5.0f}%")
        P(f"   {prof:8s}               " + "  ".join(cells))
    P("")
    mut_ev = sum(m[1] * (m[2] - 1) for m in MUTATIONS)
    P(f"7. Mutations add about +{mut_ev * 100:.0f}% to average shard value per kill; "
      f"{sum(m[1] for m in MUTATIONS) * 100:.1f}% of spawns are mutated (x2 during the natural 5-min Mutation Storm "
      f"every 45 min)")
    P("")
    P("8. AFK-only player (never hunts): Power keeps growing, but the boss gate never opens")
    P("   (rank quests need kills and hatches, which need coins, which only hunting gives).")
    return "\n".join(out)


if __name__ == "__main__":
    text = report()
    print(text)
    open("RESULTS.txt", "w").write(text + "\n")
