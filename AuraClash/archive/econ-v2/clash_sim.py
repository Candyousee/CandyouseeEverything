"""Boss clash simulation (CORE-GAME v2 section 5). Every assumption is listed here.
Meeting point M: 0 = you lose, 100 = you win, starts at 50. Time limit 45 s.
  Drift per second   = clamp(12 x (sqrt(yourPower / bossPower) - 1), -12, +12)
  Your releases      = the training rules: PERFECT push = 2.4 + 0.5 x comboStep (step 0..4, x1..x2),
                       Early push = 0.5 x hold/1.02, Overcharge push = 0.3 (+0.4 s stagger). NO Overdrive in clashes.
  Boss attack        = telegraph 1.0 s (boss glows) + strike window 0.5 s (red flash).
                       COUNTER = a quick TAP (< 0.5 s press) inside the strike window: +4.
                       No tap in the window: the strike hits: -4. A tap cancels any charge in progress.
  Attack interval    = every 5.0 s; ENRAGED (M >= 70): every 3.5 s.
Player model (the assumptions the results depend on):
  p_perfect  = chance a normal charge lands PERFECT (else 70% Early / 30% Overcharge)
  p_counter  = chance the player taps inside the strike window
  When a telegraph starts the player abandons the current charge (worst case) and spends
  1.5 s on the counter; then resumes charging. The +4 / -4 applies INSIDE the strike window
  (a counter at a random moment 1.0-1.5 s after the tell; a missed strike at 1.5 s)."""
import math, random

T_LIMIT, DT = 45.0, 0.01
def clash(ratio, p_perfect, p_counter, rnd, trace=None):
    M, t, step = 50.0, 0.0, 0
    drift = max(-12.0, min(12.0, 12.0 * (math.sqrt(ratio) - 1.0)))
    next_attack, charge_end, busy_until, pending = 5.0, None, 0.0, None
    while t < T_LIMIT:
        if pending and t >= pending[0]:             # the counter / hit lands INSIDE the strike window (1.0-1.5 s after the tell)
            M += pending[1]
            if trace is not None: trace.append((t - pending[2], pending[1]))
            pending = None
        if t >= next_attack:                        # telegraph starts: player drops the charge and spends 1.5 s on the tap
            if rnd.random() < p_counter:
                pending = (t + rnd.uniform(1.0, 1.5), +4.0, t)   # successful tap somewhere in the 0.5 s window
            else:
                pending = (t + 1.5, -4.0, t)                  # no tap: the strike lands at the end of the window
            busy_until = t + 1.5; charge_end = None
            next_attack = t + (3.5 if M >= 70 else 5.0)
        elif t >= busy_until:
            if charge_end is None:                  # start a charge and decide its outcome
                r = rnd.random()
                if r < p_perfect:   kind, hold = "P", rnd.uniform(1.02, 1.20)
                elif r < p_perfect + (1 - p_perfect) * 0.7: kind, hold = "E", rnd.uniform(0.6, 1.0)
                else:               kind, hold = "O", rnd.uniform(1.2, 1.6)
                charge_end = t + hold
            if t >= charge_end:
                if kind == "P": M += 2.4 + 0.5 * step; step = min(step + 1, 4)
                elif kind == "E": M += 0.5 * hold / 1.02; step = 0
                else: M += 0.3; step = 0
                busy_until = t + 0.25 + (0.4 if kind == "O" else 0.0); charge_end = None
        M += drift * DT; t += DT                    # the beam drifts continuously, including recovery and counters
        if M >= 100: return True, t
        if M <= 0: return False, t
    return False, t

PLAYERS = {"casual (40% perf, 40% counter)": (0.40, 0.40),
           "average (60% / 65%)": (0.60, 0.65),
           "skilled (85% / 90%)": (0.85, 0.90)}
RATIOS = [0.6, 0.7, 0.8, 0.9, 1.0, 1.1, 1.25, 1.5, 2.0, 3.0]

def table(n=2000, seed=11):
    rnd = random.Random(seed); out = {}
    for name, (pp, pc) in PLAYERS.items():
        out[name] = []
        for r in RATIOS:
            res = [clash(r, pp, pc, rnd) for _ in range(n)]
            wins = [x for w, x in res if w]
            out[name].append((len(wins) / n, sum(wins) / len(wins) if wins else 0.0))
    return out

if __name__ == "__main__":
    out = table()
    print("power ratio | " + " | ".join(f"{k:>31}" for k in out))
    for i, r in enumerate(RATIOS):
        print(f"{r:>11} | " + " | ".join(f"{out[k][i][0]:>12.0%} win, {out[k][i][1]:>5.1f} s avg   " for k in out))
