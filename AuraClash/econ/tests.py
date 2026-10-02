"""Rule checks for the model (run: python tests.py). Each test maps to a CORE-GAME rule or an audit finding."""
import random, json
import clash_sim, economy as E

gates = json.load(open("gates.json"))["gates"]

def fresh(slots_extra=0):
    p = E.Player("average", gates, 1); p.inv = {}; p._mult = None
    p.slots_zone = set(list(E.SLOT_ZONES)[:slots_extra]); return p

def test_egg_value_counts_fusion():          # audit 3: buying must see the fusion a hatch completes
    p = fresh(); p.inv = {(0, 2, 0, False): 2, (0, 1, 0, False): 1}; p._mult = None   # 2 Epics + 1 Rare, 3 slots
    with_fusion = p.egg_value()
    eq = p.equipped(); weakest = eq[-1]
    naive = sum(pr * max(0, E.bonus(0, r) - weakest) for r, pr in enumerate(E.ODDS)) / p.spirit_mult()
    # if the hatch is the 3rd Epic, fusing gives Gold (1.8) + Rare (0.25) = team 3.05 instead of 2.80 without fusion
    expected_extra = E.ODDS[2] * (3.05 - 2.80) / p.spirit_mult()
    assert abs((with_fusion - naive) - expected_extra) < 1e-9, (with_fusion, naive, expected_extra)

def test_auto_fuse_rules():                  # audit 2: auto-fuse only enabled rarities and only unequipped copies
    p = fresh(); p.inv = {(0, 2, 0, False): 3}; p._mult = None
    p.auto_fuse(); assert p.inv == {(0, 2, 0, False): 3}            # Epics are manual-only
    p.inv = {(0, 0, 0, False): 3}; p._mult = None                    # 3 Commons, all equipped (3 slots)
    p.auto_fuse(); assert p.inv == {(0, 0, 0, False): 3}            # equipped copies are not used automatically
    p.inv = {(0, 0, 0, False): 6}; p._mult = None                    # 3 equipped + 3 spare
    p.auto_fuse(); assert p.inv[(0, 0, 1, False)] == 1

def test_manual_fusion_never_lowers_power():
    p = fresh(); p.inv = {(0, 2, 0, False): 3, (0, 0, 0, False): 4}; p._mult = None
    before = p.spirit_mult(); p.manual_fuse(); assert p.spirit_mult() >= before

def test_drift_continues_during_recovery():  # audit 1: beam keeps moving in recovery / counters
    rnd = random.Random(3)
    won, t = clash_sim.clash(2.0, 0.0, 0.0, rnd)     # never PERFECT, never counters: drift alone must still win at 2x
    assert won, t

def test_overpower_is_two_seconds():         # audit 1: Overpower KO = 2 s, no clash
    p = fresh(); p.cleared_ever = {0}; p.power = gates[0] * 3.5; t0 = p.t      # replay: no first-clear egg
    assert p.boss() and abs((p.t - t0) - E.OVERPOWER_TIME) < 1e-9

def test_min_one_shard():                    # small fix: beating the required boss below its power still pays 1
    assert E.SHARDS(0.8 * 1000, 1000) == 1 and E.SHARDS(1000, 1000) == 1 and E.SHARDS(100_000, 1000) == 2

def test_stable_seeds():                     # small fix: identical results run to run
    a = E.first_run("average", gates, 42, stop_after_boss=2).ev
    E._CL.clear()
    b = E.first_run("average", gates, 42, stop_after_boss=2).ev
    assert a == b

if __name__ == "__main__":
    n = 0
    for name, fn in list(globals().items()):
        if name.startswith("test_"):
            fn(); n += 1; print("PASS", name)
    print(f"{n} tests passed")
