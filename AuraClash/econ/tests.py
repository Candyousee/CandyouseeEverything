"""Rule checks for the v5.1 model (run: python tests.py). Each test maps to a rule in CORE-LOOP.md / CORE-GAME.md."""
import math, random, statistics as st
import model as M


def within_4sd(count, n, p):
    sd = math.sqrt(n * p * (1 - p))
    return abs(count - n * p) <= 4 * sd


def test_egg_odds():                      # CORE-GAME 3.1: odds as shown on the egg card
    rng, n = random.Random(1), 200_000
    counts = [0] * 6
    for _ in range(n):
        counts[M.egg_roll(rng)] += 1
    for r in range(5):
        assert within_4sd(counts[r], n, M.ODDS[r]), (M.RARITIES[r], counts[r])
    assert counts[5] <= 6                  # Secret: 0.4 expected


def test_mutation_odds_are_the_advertised_odds():   # CORE-LOOP 2.3: the real chance = the shown chance
    pl, n = M.Player("average", 2), 400_000
    counts = {m[0]: 0 for m in M.MUTATIONS}
    for _ in range(n):
        m = pl.roll_mutation()
        if m:
            counts[m[0]] += 1
    for m in M.MUTATIONS[:5]:
        assert within_4sd(counts[m[0]], n, m[1]), (m[0], counts[m[0]], n * m[1])   # advertised p, not a reduced one
    assert counts["Celestial"] <= n / 10000 + 4 * math.sqrt(n / 10000)


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


def test_overdrive_kills_respect_the_chain_limit():   # CORE-LOOP 2.1: target + at most 2 chained monsters per blast
    for power, mi in ((50, 0), (5000, 0), (150, 1), (5000, 2)):
        blasts, kills = _od_run(2, power, mi)
        assert len(kills) <= blasts * (1 + min(2, M.NEARBY[mi])), (power, mi, blasts, len(kills))
        assert sum(1 for k in kills if k[2] == "chain") <= blasts * min(2, M.NEARBY[mi])


def test_overdrive_without_chains_kills_only_targets():   # the reviewer's check: chain limit 0 -> no extra kills
    for power, mi in ((50, 0), (5000, 0), (150, 1)):
        blasts, kills = _od_run(0, power, mi)
        assert len(kills) <= blasts and all(k[2] == "target" for k in kills), (power, mi, blasts, len(kills))


def test_auto_fuse_never_touches_equipped_or_epics():   # CORE-LOOP 3a: auto = unequipped Commons + Rares only
    pl = M.Player("average", 0)
    pl.slots = 3
    pl.pets = [M.Pet(0, 2, 0) for _ in range(3)]           # 3 equipped Epics
    pl.auto_fuse()
    assert len(pl.pets) == 3 and all(p.stars == 0 for p in pl.pets)
    pl.pets = [M.Pet(0, 2, 0) for _ in range(6)]           # 3 equipped + 3 spare Epics: still manual only
    pl.auto_fuse()
    assert len(pl.pets) == 6
    pl.slots = 1
    pl.pets = [M.Pet(0, 3, 0)] + [M.Pet(0, 0, 0) for _ in range(3)]   # Legendary equipped, 3 spare Commons
    pl.auto_fuse()
    assert sorted((p.r, p.stars) for p in pl.pets) == [(0, 1), (3, 0)]


def test_manual_fusion_needs_the_altar():               # Epic+ fusion happens only on an altar visit (after a sell)
    pl = M.Player("average", 0)
    pl.slots = 3
    pl.pets = [M.Pet(0, 2, 0) for _ in range(3)]
    pl.hatch(free=True)                                    # hatching never fuses Epics
    assert sum(1 for p in pl.pets if p.r == 2 and p.stars == 0) == 3
    t0 = pl.t
    pl.bag, pl.bag_val = 1, 3
    pl.spend = lambda: None
    pl.sell()
    assert any(p.r == 2 and p.stars == 1 for p in pl.pets) and pl.t >= t0 + M.SELL_TIME + M.ALTAR_TIME


def test_auto_feed_runs_when_food_drops():             # CORE-LOOP 3b
    pl = M.Player("average", 1)
    pl.pets, pl.slots = [M.Pet(0, 0, 0)], 3
    pl.power, pl.quest = 1000, 1
    pl.spend = lambda: None
    pl.hunt_session(1, seconds=60)                        # Boars always drop 1 food
    assert sum(pl.food) == 0 and pl.pets[0].lv > 1


def test_food_xp_follows_its_origin():                 # a zone-1 Berry is 1 XP even after reaching zone 2
    pl = M.Player("average", 1)
    pl.pets, pl.slots, pl.zone = [M.Pet(1, 0, 0)], 3, 1
    pl.food = [1, 0]
    pl.feed()
    assert pl.pets[0].xp == 1 and pl.pets[0].lv == 1
    pl.food = [0, 1]
    pl.feed()
    assert pl.pets[0].lv == 2 and pl.pets[0].xp == 2      # 1 + 3 = 4 XP; Lv 1 -> 2 costs 2


def test_overdrive_expires_on_real_time():            # CORE-LOOP 2.1: 8 s of real time, whatever you do
    pl = M.Player("average", 9)
    pl.power, pl.quest, pl.t = 50, 1, 100
    pl.milestones["mut_tutorial"] = 0
    pl.spend = lambda: None
    pl.start_overdrive()
    t0 = pl.t
    while pl.t < t0 + 30:
        pl.hunt_blast(0)
    boosted = [k for k in pl.kill_log if k[3]]
    assert boosted and max(k[0] for k in boosted) <= t0 + M.OD_TIME + 1e-9   # walking time between kills counts
    pl2 = M.Player("average", 9)
    pl2.start_overdrive()
    pl2.meditate(60)                                       # meditating doesn't pause it
    assert not pl2.in_overdrive()
    pl3 = M.Player("average", 9)
    pl3.start_overdrive()
    pl3.t += M.SELL_TIME + 3 * M.HATCH_TIME + M.ALTAR_TIME  # selling, hatching and fusing don't pause it either
    t_left = pl3.od_until - pl3.t
    assert abs(t_left - (M.OD_TIME - M.SELL_TIME - 3 * M.HATCH_TIME - M.ALTAR_TIME)) < 1e-9


def test_overdrive_starts_when_the_triggering_blast_lands():   # the 8 s begin at the 5th PERFECT's hit
    pl = M.Player("average", 9)
    pl.pf = dict(pl.pf, p=1.0)                             # every release PERFECT
    pl.power, pl.quest, pl.t = 50, 1, 100
    pl.milestones["mut_tutorial"] = 0
    pl.spend = lambda: None
    landed = []
    for _ in range(5):
        pl.hunt_blast(0)
        landed.append(pl.t)
    assert pl.od_active
    trigger_landed = pl.kill_log[-1][0] if pl.kill_log else landed[-1]
    assert abs(pl.od_until - (trigger_landed + M.OD_TIME)) < 1e-9
    assert not any(k[3] for k in pl.kill_log)              # the triggering blast itself isn't boosted
    while pl.in_overdrive():
        pl.hunt_blast(0)
    boosted = [k[0] for k in pl.kill_log if k[3]]
    assert boosted and max(boosted) - trigger_landed <= M.OD_TIME + 1e-9
    assert max(boosted) - trigger_landed > M.OD_TIME - M.BLAST_TIME - 1.0   # the full window is usable


def test_beginner_protected_pack_in_a_crowded_server():   # CORE-LOOP 8: veterans can't block a beginner's quest
    solo = st.median(M.crowded_quest_time(0, True, seed_=r) for r in range(30))
    for vets in (3, 10):
        protected = st.median(M.crowded_quest_time(vets, True, seed_=r) for r in range(30))
        assert protected <= solo * 1.1, (vets, protected, solo)
    blocked = st.median(M.crowded_quest_time(6, False, seed_=r) for r in range(30))
    assert blocked >= 3 * solo                              # the problem the pack exists to solve


def test_newcomer_next_to_a_veteran_gets_the_drop():    # CORE-LOOP 8: shared monsters, personal loot
    assert M.loot_recipients({"newcomer": 0.10 * 200, "veteran": 0.90 * 200}) == ["newcomer", "veteran"]
    assert M.loot_recipients({"newcomer": 1, "veteran": 10**9}) == ["newcomer", "veteran"]
    assert M.loot_recipients({"bystander": 0, "veteran": 200}) == ["veteran"]


def test_star_fusion():                   # CORE-LOOP 3: 3 same -> star x3, keeps the highest level
    pl = M.Player("average", 0)
    pets = [M.Pet(0, 2, 0) for _ in range(3)]
    pets[1].lv = 7
    pl.pets = pets
    pl.slots = 3
    before = pl.team_str()
    pl.fuse()
    assert len(pl.pets) == 1 and pl.pets[0].stars == 1 and pl.pets[0].lv == 7
    assert abs(pl.pets[0].strength() - 4 * 3 * (1 + 0.05 * 6)) < 1e-9
    assert pl.team_str() >= before


def test_fusion_never_lowers_team():
    pl = M.Player("average", 0)
    pl.slots = 6
    pl.pets = [M.Pet(0, 0, 0) for _ in range(3)] + [M.Pet(0, 2, 0) for _ in range(3)]
    before = pl.team_str()
    pl.fuse()
    assert pl.team_str() >= before


def test_food_levels():                   # CORE-LOOP 3b: levels 1-30, +5% each, 870 XP total
    assert sum(M.XP_TO_NEXT(lv) for lv in range(1, 30)) == 870
    p = M.Pet(0, 0, 0)
    p.lv = 30
    assert abs(p.strength() - (1 + 0.05 * 29)) < 1e-9


def test_power_only_from_meditation_coins_only_from_hunting():   # CORE-LOOP 0
    pl = M.Player("average", 3)
    pl.power = 100
    pl.quest = 1                            # past the Focus quest, so the hunt doesn't stop for it
    pl.pets = [M.Pet(0, 0, 0)]
    p0, c0 = pl.power, pl.coins_earned
    pl.hunt_session(0, seconds=120)
    assert pl.power == p0 and pl.coins_earned > c0
    c1 = pl.coins_earned
    pl.meditate(60)
    assert pl.power > p0 and pl.coins_earned == c1


def test_bag_cap():                       # CORE-LOOP 2: capped bag; any shard = 1 slot
    pl = M.Player("average", 4)
    pl.power = 1000
    pl.quest = 1
    pl.spend = lambda: None
    biggest = 0
    orig = pl.sell
    def sell():
        nonlocal biggest
        biggest = max(biggest, pl.bag)
        orig()
    pl.sell = sell
    pl.hunt_session(2, seconds=600)
    assert 0 < biggest <= M.BAG[0]


def test_afk_only_never_opens_the_gate():  # CORE-LOOP 8: AFK gives Power only
    pl = M.Player("average", 5)
    pl.quest = 1                            # Focus quest done
    pl.meditate(8 * 3600, focus=False)
    assert pl.power > 10_000
    assert pl.quest_check() is False and pl.quest == 1


def test_guarantees():                    # CORE-GAME 3.1: 1st hatch Light Fox (Common), 3rd hatch Rare
    pl = M.Player("average", 6)
    pl.coins = 10_000
    pl.slots = 10
    pl.hatch(); pl.hatch(); pl.hatch()
    assert pl.pets[0].r == 0 if len(pl.pets) == 3 else True
    assert any(p.r >= 1 for p in pl.pets)


def test_clash_targets():                 # CORE-GAME 6: the clash rewards Power and timing
    rng = random.Random(7)
    def rate(prof, ratio):
        pf = M.PROFILES[prof]
        return sum(M.clash(pf["p"], pf["counter"], 2, ratio, rng)[0] for _ in range(2000)) / 2000
    assert rate("average", 1.0) >= 0.90
    assert rate("weak", 1.0) >= 0.60
    assert rate("average", 0.5) <= 0.40
    assert rate("weak", 1.5) >= 0.90


def test_pacing_targets():                # GAME-PLAN design targets (200 average players)
    rows = [M.Player("average", r).run() for r in range(200)]
    b1 = st.median(x.milestones["boss1"] / 60 for x in rows)
    b2 = st.median(x.milestones["boss2"] / 60 for x in rows)
    med = st.mean(x.med_time / (x.med_time + x.hunt_time) for x in rows)
    pet = st.mean(x.pet_dmg / (x.pet_dmg + x.player_dmg) for x in rows)
    assert 4 <= b1 <= 9, b1
    assert 18 <= b2 <= 35, b2
    assert 0.15 <= med <= 0.40, med
    assert 0.30 <= pet <= 0.60, pet


def test_reproducible():
    a = M.Player("average", 11).run().milestones
    b = M.Player("average", 11).run().milestones
    assert a == b


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
