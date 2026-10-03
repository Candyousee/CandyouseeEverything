"""Rule checks for the v6 model (run: python tests.py). Each test maps to a rule in CORE-LOOP.md / GAME-BIBLE.md."""
import math, random, statistics as st
import model as M


def within_4sd(count, n, p):
    sd = math.sqrt(n * p * (1 - p))
    return abs(count - n * p) <= 4 * sd


# ---------- odds ----------
def test_every_egg_sums_to_one_and_tiers_match_their_bands():   # BIBLE 5.1: tiers are odds bands; eggs differ
    assert M.TIERS == ["Common", "Uncommon", "Rare", "Epic", "Legendary", "Mythic", "Secret", "Divine", "Impossible", "Boundless"]
    tables = set()
    for z, egg in enumerate(M.EGGS):
        assert abs(sum(p for _, _, p in egg) - 1) < 1e-12, z
        for name, t, p in egg:
            assert M.tier_of(p) == t, (z, name, t, p)
        assert egg[-1][1] == 9 and egg[-1][2] == M.BOUNDLESS_P == 1e-12      # Boundless (1 in 1T) in every egg
        tiers = [t for _, t, _ in egg]
        assert {0, 1, 2, 3, 4, 5, 6, 7, 8, 9} <= set(tiers), z            # every tier present
        tables.add(tuple(round(p, 12) for _, _, p in egg))
    assert len(tables) == M.ZONES                                           # no two eggs have the same odds
    assert M.tier_of(1e-6) == 6 and M.tier_of(1e-7) == 7 and M.tier_of(1e-9) == 8 and M.tier_of(1e-12) == 9


def test_exclusive_eggs_follow_the_tier_system():         # MONETIZATION 6: tiers by odds band, Boundless line, no Huge
    expected = {"Daily Exclusive (Neon)": [0, 1, 2, 2, 3, 4, 5, 6, 7, 8, 9],
                "Shop Exclusive (Royal)": [0, 0, 1, 2, 3, 4, 5, 6, 7, 8, 9]}
    for name, egg in M.EXCLUSIVE_EGGS.items():
        table = egg["table"]
        assert abs(sum(p for _, _, p in table) - 1) < 1e-12, name
        assert [t for _, t, _ in table] == expected[name], (name, [t for _, t, _ in table])
        assert table[-1][2] == M.BOUNDLESS_P
    assert M.EXCLUSIVE_EGGS["Daily Exclusive (Neon)"]["price"] == (49, 99, 249)
    assert M.EXCLUSIVE_EGGS["Shop Exclusive (Royal)"]["price"] == (99, 279, 849)


def test_egg_rolls_match_the_card():
    rng, n = random.Random(1), 400_000
    for z in (0, 1):
        counts = {}
        for _ in range(n):
            k = M.roll_species(rng, z)
            counts[k] = counts.get(k, 0) + 1
        for k, (name, t, p) in enumerate(M.EGGS[z]):
            if p > 1e-4:
                assert within_4sd(counts.get(k, 0), n, p), (z, name, counts.get(k, 0), n * p)


def test_luck_has_no_cap_and_odds_stay_valid():          # owner: no cap on luck
    prev = None
    for luck in (1, 2, 8, 64, 2048, 10_000, 10**6, 10**12):
        for sx in (1.0, 3.0):
            o = M.egg_odds(3, luck, sx)
            assert abs(sum(o) - 1) < 1e-9 and all(x > 0 for x in o), (luck, sx)
            assert sum(x for x, (_, t, _) in zip(o, M.EGGS[3]) if t >= 4) <= M.RARE_SHARE_MAX + 1e-12
        o = M.egg_odds(3, luck)
        if prev:
            boundless = len(o) - 1
            assert o[boundless] >= prev[boundless]                          # more luck always helps the rarest
        prev = o
    assert M.egg_odds(3, 10**6)[-1] > M.egg_odds(3, 10_000)[-1]            # no cap: x1,000,000 beats x10,000
    assert abs(M.egg_odds(0, 2048)[-1] - 2048 * 1e-12) < 1e-20              # luck works fully on Boundless


def test_ladder_doubles_luck_and_power_together():         # owner: one "2x Boost" ladder for both
    assert M.LADDER_PRICES == [3, 9, 19, 29, 49, 79, 149, 249, 399, 799, 999]
    assert M.ladder_cost(11) == 2_783
    for k in ("starter",):
        assert M.PAID[k]["luck"] == M.PAID[k]["med_x"] == 8
    assert M.PAID["whale"]["luck"] == 2048 and M.PAID["whale"]["med_x"] == 1.5 * 2048   # x VIP 1.5 on Power
    assert M.SLOT_PACK_PRICE == 199 and M.SLOT_PACK_MAX == 10


def test_paid_player_is_faster_but_free_player_finishes():   # targets: free ~10-12 h, whale ~3 h
    free = st.median(M.Player("average", 3000 + r).run().milestones[f"boss{M.ZONES}"] for r in range(8)) / 3600
    whale = st.median(M.Player("average", 3000 + r, paid="whale").run().milestones[f"boss{M.ZONES}"] for r in range(8)) / 3600
    assert 9.5 <= free <= 12.5, free
    assert 2.5 <= whale <= 4.0, whale


def test_natural_mutation_storm_doubles_chances():      # MONETIZATION 5: storms also happen naturally
    pl, n = M.Player("average", 3), 200_000
    pl.t = 60                                                # inside a storm (first 5 min of every 45)
    assert pl.in_mutation_storm() and M.STORM_EVERY == 2700 and M.STORM_LENGTH == 300
    gold = sum(1 for _ in range(n) if (m := pl.roll_mutation()) and m[0] == "Gold")
    assert within_4sd(gold, n, 2 / 25)


def test_mutation_odds_are_the_advertised_odds():
    pl, n = M.Player("average", 2), 400_000
    pl.t = 1000                                              # outside a Mutation Storm
    assert not pl.in_mutation_storm()
    counts = {m[0]: 0 for m in M.MUTATIONS}
    for _ in range(n):
        m = pl.roll_mutation()
        if m:
            counts[m[0]] += 1
    for m in M.MUTATIONS[:5]:
        assert within_4sd(counts[m[0]], n, m[1]), (m[0], counts[m[0]], n * m[1])


# ---------- Overdrive ----------
def _od_run(chain_n, power, mi):
    old = M.OD_CHAIN_N
    M.OD_CHAIN_N = chain_n
    try:
        pl = M.Player("average", 9)
        pl.power, pl.quest, pl.t = power, 1, 100
        pl.milestones["mut_tutorial"] = 0
        pl.spend = lambda: None
        pl.start_overdrive()
        n0, blasts = len(pl.kill_log), 0
        while pl.in_overdrive():
            pl.hunt_blast(mi)
            blasts += 1
        return blasts, pl.kill_log[n0:]
    finally:
        M.OD_CHAIN_N = old


def test_overdrive_kills_respect_the_chain_limit():
    for power, mi in ((50, 0), (5000, 0), (150, 1), (5000, 2)):
        blasts, kills = _od_run(2, power, mi)
        assert len(kills) <= blasts * (1 + min(2, M.NEARBY[mi])), (power, mi, blasts, len(kills))


def test_overdrive_without_chains_kills_only_targets():
    for power, mi in ((50, 0), (5000, 0), (150, 1)):
        blasts, kills = _od_run(0, power, mi)
        assert len(kills) <= blasts and all(k[2] == "target" for k in kills)


def test_overdrive_expires_on_real_time():
    pl = M.Player("average", 9)
    pl.power, pl.quest, pl.t = 50, 1, 100
    pl.milestones["mut_tutorial"] = 0
    pl.spend = lambda: None
    pl.start_overdrive()
    t0 = pl.t
    while pl.t < t0 + 30:
        pl.hunt_blast(0)
    boosted = [k for k in pl.kill_log if k[3]]
    assert boosted and max(k[0] for k in boosted) <= t0 + M.OD_TIME + 1e-9
    pl2 = M.Player("average", 9)
    pl2.start_overdrive()
    pl2.meditate(60)
    assert not pl2.in_overdrive()


def test_overdrive_starts_when_the_triggering_blast_lands():
    pl = M.Player("average", 9)
    pl.pf = dict(pl.pf, p=1.0)
    pl.power, pl.quest, pl.t = 50, 1, 100
    pl.milestones["mut_tutorial"] = 0
    pl.spend = lambda: None
    for _ in range(5):
        pl.hunt_blast(0)
    trigger_landed = pl.kill_log[-1][0]
    assert pl.od_active and abs(pl.od_until - (trigger_landed + M.OD_TIME)) < 1e-9
    assert not any(k[3] for k in pl.kill_log)


# ---------- pets ----------
def test_stars_go_to_five_and_double_each_time():   # BIBLE 3.4: 3 copies -> next star, up to 5 stars
    assert M.STAR == [1, 2, 4, 8, 16, 32] and M.MAX_STARS == 5
    pl = M.Player("average", 0)
    pl.slots = 1
    pets = [M.Pet(0, 4, 6) for _ in range(3)]               # Legendary
    for p in pets:
        p.stars = 4
    pets[2].lv = 12
    pl.pets = pets
    pl.fuse()
    assert len(pl.pets) == 1 and pl.pets[0].stars == 5 and pl.pets[0].lv == 12
    five = [M.Pet(0, 4, 6) for _ in range(3)]
    for p in five:
        p.stars = 5
    pl.pets = five
    pl.dirty()
    pl.fuse()
    assert len(pl.pets) == 3                                  # nothing above 5 stars


def test_auto_fuse_never_touches_equipped_or_epics():
    pl = M.Player("average", 0)
    pl.slots = 3
    pl.pets = [M.Pet(0, 3, 5) for _ in range(6)]             # 3 equipped + 3 spare Epics: manual only
    pl.dirty()
    pl.auto_fuse()
    assert len(pl.pets) == 6
    pl.slots = 1
    pl.pets = [M.Pet(0, 4, 6)] + [M.Pet(0, 0, 0) for _ in range(3)]   # Legendary equipped, 3 spare Commons
    pl.dirty()
    pl.auto_fuse()
    assert sorted((p.r, p.stars) for p in pl.pets) == [(0, 1), (4, 0)]


def test_manual_fusion_needs_the_altar():
    pl = M.Player("average", 0)
    pl.slots = 3
    pl.pets = [M.Pet(0, 3, 5) for _ in range(6)]             # 3 equipped + 3 spare Epics
    pl.dirty()
    pl.hatch(free=True)
    assert sum(1 for p in pl.pets if p.r == 3 and p.stars == 0) == 6   # hatching never fuses Epics
    t0 = pl.t
    pl.bag, pl.bag_val = 1, 3
    pl.spend = lambda: None
    pl.sell()
    assert any(p.r == 3 and p.stars == 1 for p in pl.pets) and pl.t >= t0 + M.SELL_TIME + M.ALTAR_TIME


def test_xp_goes_automatically_to_equipped_pets_only():   # BIBLE 3.5: no food; kills give XP to the team
    pl = M.Player("average", 1)
    pl.slots = 1
    eq, spare = M.Pet(0, 4, 6), M.Pet(0, 0, 0)
    pl.pets = [eq, spare]
    pl.dirty()
    pl.power, pl.quest = 1000, 1
    pl.spend = lambda: None
    pl.hunt_session(1, seconds=120)
    assert eq.lv > 1 and spare.lv == 1 and spare.xp == 0
    assert not hasattr(pl, "food")


def test_xp_scales_with_zone():
    assert M.KILL_XP[0] * M.XP_STEP ** 7 == 2187
    assert M.XP_TO_NEXT(1, 0) == 10 and M.XP_TO_NEXT(1, 7) == 10 * 3 ** 7


def test_team_hit_is_capped_at_your_power():             # BIBLE 3.3: your blasts always matter
    pl = M.Player("average", 1)
    pl.slots = 10
    pl.pets = [M.Pet(7, 9, 11) for _ in range(10)]
    pl.dirty()
    assert pl.team_hit_x() == M.TEAM_HIT_CAP == 1.0
    pl.pets = [M.Pet(0, 0, 0)]
    pl.dirty()
    assert abs(pl.team_hit_x() - 0.04) < 1e-12


def test_level_and_strength():
    p = M.Pet(2, 6, 8)                                       # zone 3 Secret
    p.stars, p.lv = 5, 30
    assert abs(p.strength() - 100 * 4 * 32 * (1 + 0.05 * 29)) < 1e-6
    assert M.TIER_STR == [1, 1.5, 2.5, 4, 10, 25, 100, 400, 2_000, 100_000]


# ---------- economy rules ----------
def test_power_only_from_meditation_coins_only_from_hunting():
    pl = M.Player("average", 3)
    pl.power, pl.quest = 100, 1
    pl.pets = [M.Pet(0, 0, 0)]
    pl.dirty()
    p0, c0 = pl.power, pl.coins_earned
    pl.hunt_session(0, seconds=120)
    assert pl.power == p0 and pl.coins_earned > c0
    c1 = pl.coins_earned
    pl.meditate(60)
    assert pl.power > p0 and pl.coins_earned == c1
    c2, h2 = pl.coins_earned, pl.hatches
    pl.quest_reward(0, 1)                                    # a quest reward: an egg, never coins
    assert pl.coins_earned == c2 and pl.hatches == h2 + 1


def test_boss_gives_boss_shards_not_a_free_egg():          # owner: no free egg for a boss
    pl = M.Player("average", 5).run(until_zone=1)
    s = pl.zone_stats[0]
    assert pl.boss_coins == M.boss_shard_value(0) == 3 * M.EGG_PRICE[1]
    assert pl.zone_hatches.get(1, 0) == 0                   # nothing hatched in zone 2 for free


def test_bag_cap():
    pl = M.Player("average", 4)
    pl.power, pl.quest = 1000, 1
    pl.spend = lambda: None
    biggest = 0
    orig = pl.sell
    def sell(extra=0):
        nonlocal biggest
        biggest = max(biggest, pl.bag)
        orig(extra)
    pl.sell = sell
    pl.hunt_session(2, seconds=600)
    assert 0 < biggest <= M.BAG[0]


def test_afk_only_never_opens_the_gate():
    pl = M.Player("average", 5)
    pl.quest = 1
    pl.meditate(8 * 3600, focus=False)
    assert pl.power > 10_000 and pl.quest_check() is False and pl.quest == 1


def test_guarantees():
    pl = M.Player("average", 6)
    pl.coins, pl.slots = 10_000, 10
    pl.hatch(); pl.hatch(); pl.hatch()
    assert pl.pets[0].r == 0 or any(p.stars for p in pl.pets)
    assert any(p.r >= 1 for p in pl.pets)


def test_quest_difficulty_tiers():                          # zones 1-3 very easy, 4-6 easy, 7-8 medium, 9-10 hard
    assert M.TIER == ["very easy"] * 3 + ["easy"] * 3 + ["medium"] * 2 + ["hard"] * 2
    lengths = [len(q) for q in M.QUESTS]
    assert lengths[0] <= lengths[3] <= lengths[6] <= lengths[8]
    assert all(q[-1] == ("power", M.BOSS[z]["rec"]) for z, q in enumerate(M.QUESTS))


def test_newcomer_next_to_a_veteran_gets_the_drop():
    assert M.loot_recipients({"newcomer": 20, "veteran": 180}) == ["newcomer", "veteran"]
    assert M.loot_recipients({"bystander": 0, "veteran": 200}) == ["veteran"]


# ---------- bosses + pacing ----------
def test_clash_targets():
    rng = random.Random(7)
    def rate(prof, ratio):
        pf = M.PROFILES[prof]
        return sum(M.clash(pf["p"], pf["counter"], 2, ratio, rng)[0] for _ in range(2000)) / 2000
    assert rate("average", 1.0) >= 0.90 and rate("weak", 1.0) >= 0.60
    assert rate("average", 0.5) <= 0.40 and rate("weak", 1.5) >= 0.90


def test_pacing_targets():                                  # GAME-PLAN design targets (free player, solo)
    rows = [M.Player("average", 1000 + r).run() for r in range(30)]
    t = [st.median(x.milestones[f"boss{z + 1}"] / 60 for x in rows) for z in range(M.ZONES)]
    assert 4 <= t[0] <= 9 and 15 <= t[1] <= 30, t
    assert all(b > a for a, b in zip(t, t[1:]))              # every zone takes longer to finish
    assert 570 <= t[-1] <= 750, t                            # first full run (free): about 10-12 hours
    med = st.mean(x.med_time / (x.med_time + x.hunt_time) for x in rows)
    pet = st.mean(x.pet_dmg / (x.pet_dmg + x.player_dmg) for x in rows)
    assert 0.15 <= med <= 0.50 and 0.30 <= pet <= 0.50, (med, pet)   # pets never out-damage your blasts


def test_reproducible():
    assert M.Player("average", 11).run(until_zone=3).milestones == M.Player("average", 11).run(until_zone=3).milestones


if __name__ == "__main__":
    tests = [v for k, v in sorted(globals().items()) if k.startswith("test_")]
    failed = 0
    for t in tests:
        try:
            t()
            print("PASS", t.__name__)
        except AssertionError as e:
            failed += 1
            print("FAIL", t.__name__, e)
    print(f"\n{len(tests) - failed}/{len(tests)} passed")
    raise SystemExit(1 if failed else 0)
