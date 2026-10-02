"""Beam clash tuning. Meeting point M: 0 = you lose, 100 = you win, start 50. Time limit T."""
import random, math
random.seed(3)
T = 45.0; DT = 0.05
BASE = 8.0            # push units / s at equal power
CYCLE = 1.3           # seconds per charge-release cycle
PERFECT_PUSH = 1.8    # + 0.5 per combo step
COMBO_MAX = 3         # +1 push per combo step, capped
SURGE_EVERY = 5.0; SURGE_HIT = 5.0; SURGE_COUNTER = 3.0

def clash(r, p_perfect, p_counter):
    M, t, combo, next_rel, next_surge = 50.0, 0.0, 0, CYCLE, SURGE_EVERY
    drift = BASE * (math.sqrt(r) - 1.0)
    while t < T:
        M += drift * DT
        if t >= next_rel:
            next_rel += CYCLE
            if random.random() < p_perfect:
                combo = min(combo + 1, COMBO_MAX); M += PERFECT_PUSH + combo * 0.5
            else:
                combo = 0; M += 0.5
        if t >= next_surge:
            next_surge += SURGE_EVERY * (0.6 if M > 75 else 1.0)   # phase 2: faster surges
            M += SURGE_COUNTER if random.random() < p_counter else -SURGE_HIT
        if M >= 100: return True, t
        if M <= 0: return False, t
        t += DT
    return False, t

players = {"weak (25%/20%)": (0.25, 0.20), "average (55%/50%)": (0.55, 0.50), "skilled (85%/85%)": (0.85, 0.85)}
print(f"{'power ratio':>11} | " + " | ".join(f"{k:>20}" for k in players))
for r in [0.6, 0.7, 0.8, 0.9, 1.0, 1.1, 1.25, 1.5, 2.0]:
    row = []
    for pp, pc in players.values():
        res = [clash(r, pp, pc) for _ in range(2000)]
        wins = [t for w, t in res if w]
        row.append(f"{len(wins)/len(res):5.0%} win, {(sum(wins)/len(wins) if wins else 0):4.0f}s")
    print(f"{r:>11} | " + " | ".join(f"{c:>20}" for c in row))
