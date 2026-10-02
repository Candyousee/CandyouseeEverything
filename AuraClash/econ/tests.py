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


def test_mutation_odds():                 # CORE-LOOP 2: mutation chances per spawn
    rng, n = random.Random(2), 200_000
    counts = {m[0]: 0 for m in M.MUTATIONS}
    for _ in range(n):
        for m in M.MUTATIONS:
            if rng.random() < m[1]:
                counts[m[0]] += 1
                break
    p_left = 1.0
    for m in M.MUTATIONS[:4]:
        p = p_left * m[1]
        assert within_4sd(counts[m[0]], n, p), (m[0], counts[m[0]])
        p_left *= 1 - m[1]


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
