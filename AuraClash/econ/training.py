"""Training-rate model: plays the exact release rules for 1 simulated hour per profile.
Rules (CORE-GAME v2 section 2):
  hold < 0.5 s            -> nothing (in a clash, a quick tap is the COUNTER input)
  0.5 .. 1.02 s (Early)   -> 0.6 x hold/1.02, combo resets
  1.02 .. 1.20 s (PERFECT)-> 2 x combo[step], step += 1
  > 1.20 s (Overcharge)   -> 0.5 and a 0.4 s stagger, combo resets
  recovery after every release 0.25 s
  combo steps x1, x1.25, x1.5, x1.75, x2 ; the 5th perfect in a row (x2) starts OVERDRIVE (8 s):
     every release >= 0.5 s counts as PERFECT x2 ; after Overdrive the combo returns to step 2 (x1.5)
  IDLE: no input for 3 s on a stone -> 0.40 per second (no combo)
Output: gain per second in 'base units' (coins use the same units, see economy.py)."""
import random

COMBO = [1.0, 1.25, 1.5, 1.75, 2.0]
REC, MIN_HOLD, PERF_LO, PERF_HI = 0.25, 0.5, 1.02, 1.20

def rate(p_perfect=0.0, mode="active", seconds=3600, seed=1):
    rnd = random.Random(seed)
    if mode == "idle":
        return 0.40, 0, 0
    t, step, od_end, gain, releases, overdrives = 0.0, 0, -1.0, 0.0, 0, 0
    while t < seconds:
        if t < od_end:                              # Overdrive: quick releases all count as PERFECT x2
            hold = rnd.uniform(0.5, 0.65); gain += 2 * 2.0; t += hold + REC; releases += 1
            if t >= od_end: step = 2
            continue
        if mode == "mash":                          # releases at the minimum hold
            hold = 0.5; gain += 0.6 * hold / PERF_LO; t += hold + REC; releases += 1
            continue
        r = rnd.random()
        if r < p_perfect:
            hold = rnd.uniform(PERF_LO, PERF_HI); gain += 2 * COMBO[step]
            if step == 4:
                od_end = t + hold + REC + 8.0; overdrives += 1
            step = min(step + 1, 4)
            t += hold + REC
        elif r < p_perfect + (1 - p_perfect) * 0.7:
            hold = rnd.uniform(0.6, 1.0); gain += 0.6 * hold / PERF_LO; step = 0; t += hold + REC
        else:
            hold = rnd.uniform(1.2, 1.6); gain += 0.5; step = 0; t += hold + REC + 0.4
        releases += 1
    return gain / seconds, releases, overdrives

PROFILES = {"idle (no input)": (0.0, "idle"), "masher (min hold)": (0.0, "mash"),
            "casual (40% perfect)": (0.40, "active"), "average (60%)": (0.60, "active"),
            "skilled (85%)": (0.85, "active")}

if __name__ == "__main__":
    base = None
    print(f"{'profile':<22}{'gain/s':>8}{'x idle':>8}{'releases/h':>12}{'overdrives/h':>14}")
    for name, (p, mode) in PROFILES.items():
        g, rel, od = rate(p, mode)
        base = base or g
        print(f"{name:<22}{g:>8.2f}{g/base:>8.1f}{rel:>12}{od:>14}")
