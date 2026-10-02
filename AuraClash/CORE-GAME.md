# AURA CLASH: Core Game v2 (rules + one balance model)

**No monetization here:** the owner designs that separately.

**Every number in this document comes from one model in `econ/`, which plays these exact rules with simulated players:**

| File | What it covers | Saved output |
|---|---|---|
| `training.py` | training rates per player type | — |
| `clash_sim.py` | boss fights | `clash_results.txt` |
| `economy.py` | coins, prices, eggs, fusion, gates, first-run timelines | `RESULTS-economy.txt` |
| `ascension.py` | Ascension strategies and the first 2 hours | `RESULTS-ascension.txt` |

- **Change a rule here → change the constant in the model → re-run.** The numbers are only valid together.
- **All times are MODEL OUTPUTS** for simulated players. Real playtests replace them.
- **Assumptions the times depend on:**
  - players buy the upgrade with the best power gain per coin;
  - a hatch takes 2 s;
  - walking and menu time are not modelled (add about 10-15%).

## What v2 fixes (review points → where)

| # | Problem in v1 | Fix | Section |
|---|---|---|---|
| 1 | Stone upgrades cost more coins than reaching the boss earns | Coins defined explicitly (base units, not multiplied by spirits); all prices derived from the same coin income | 2.3, 7 |
| 2 | Ascension had no repeat rules; early-zone farming could win | The requirement grows ×5 per Ascension; shards reward building beyond it; reset/keep list is explicit; the strategies are simulated | 6 |
| 3 | Training was a precision grind; quick taps could win | Minimum hold 0.5 s, a recovery time, idle meditation, Overdrive (no-timing bursts); rates per player type | 2 |
| 4 | Counter impossible in a 1 s warning; clash maths missing | The counter is a separate TAP input in a strike window; full formulas plus the simulation attached | 5 |
| 5 | Fusion could lower team power | Gold = 6× (beats the 5 it consumes); favourites protected; a team-power preview | 3.4 |
| 6 | The aura could visually downgrade; layers fought; Ascension shrank it | A visual hierarchy, a wardrobe of earned looks, and size = a permanent part + a run part | 4 |
| 7 | No place for players to meet | Aura Plaza hub: all shared machines, a showcase stage, inspect, statues | 8 |
| 8 | Pacing had no data and impossible exact times | The full balance table, guarantees, and model timelines labelled as model output | 7, 9 |
| 9 | Return systems had no rules; 1% chase with no progress | Exact luck maths, incubator rules, Boss Seals (guaranteed by 25), endgame | 10, 11 |
| 10 | Vague quality bar and playtest | References, early / mid / end aura specs at gameplay distance, budgets, settings, observable test criteria | 12, 13 |

---

## 1. What the game is

- **A pet training simulator.** Train power, hatch spirits, beat each zone's boss, grow the biggest aura, Ascend, and go deeper.
- The only fighting is the boss clash. No player-vs-player.

**The 4 systems: TRAIN → SPIRITS → ZONES (boss gate) → ASCEND.**

---

## 2. TRAIN (exact rules)

### 2.1 The input (one button: hold Mouse/Space, the CHARGE button on mobile, R2 on gamepad)

Standing on your zone's **Training Stone**:

| Hold length | Result | Gain (base units) | Combo |
|---|---|---|---|
| under 0.5 s | **nothing** (in a clash this is the COUNTER tap) | 0 | unchanged |
| 0.5 - 1.02 s | **Early** | 0.6 × hold / 1.02 | resets |
| 1.02 - 1.20 s (the glow band) | **PERFECT** | 2 × combo | +1 step |
| over 1.20 s | **Overcharge** | 0.5, then a 0.4 s stagger | resets |

- **Timing:**
  - after every release there is a **0.25 s recovery**;
  - the ring closes over 1.2 s, and the glow band is its last 0.18 s.
- **Combo steps:** ×1 → ×1.25 → ×1.5 → ×1.75 → ×2.
- **Overdrive:**
  - **5 PERFECTs in a row** (the one at ×2) start **OVERDRIVE** for **8 s**;
  - during Overdrive every release of 0.5 s or more counts as a PERFECT at ×2. No timing needed: it's the reward burst;
  - afterwards the combo returns to ×1.5, so the next Overdrive needs only 3 more PERFECTs.
- **Meditation (idle):**
  - no input for 3 s while on the stone = **meditation**, at 0.4 base units per second;
  - you can AFK, slowly.
- **Off the stone:** no training (the stone is where you train).

### 2.2 Training rates (model: `training.py`, 1 simulated hour each)

| Player type | Base units / s | vs idle | Releases / hour | Overdrives / hour |
|---|---|---|---|---|
| Idle (meditation) | 0.40 | 1.0× | 0 | 0 |
| Masher (always 0.5 s) | 0.39 | ~1.0× | 4,800 | 0 |
| Casual (40% PERFECT) | 1.06 | 2.7× | 2,706 | 18 |
| Average (60%) | 1.97 | 4.9× | 2,979 | 84 |
| Skilled (85%) | 3.42 | 8.6× | 3,519 | 218 |

- **Mashing gives no advantage over idling.** Good timing is 5-9× idle.
- **Precision load:** the average player spends about 19% of training time in Overdrive (no timing), the skilled player about 48%. So the precision part is roughly 2,100 timed releases an hour for an average player, broken up by Overdrive bursts, hatches, upgrades and fights.
- **This is the #1 thing playtest #1 must check** (section 13: does timing feel good, or tiring, after 10 minutes?).

### 2.3 Power and coins (explicit)

```
Power per release = gain × stone base(zone) × stone level × TEAM × FORM × ASCENSION
Coins per release = gain × stone base(zone) × stone level            (spirits, forms and Ascension do NOT boost coins)
```

| Factor | Value |
|---|---|
| **Stone base** | ×6 per zone: 1, 6, 36, 216, 1,296, 7,776, 46,656, 279,936 |
| **Stone level** | Lv1 ×1, Lv2 ×2, Lv3 ×4. Each zone has its own stone, bought with coins in that zone |
| **TEAM** | 1 + the sum of equipped spirits' bonuses (section 3) |
| **FORM** | 1 + 0.05 × (form − 1) (forms 1-10) |
| **ASCENSION** | 1 + 0.5 × shards |

- **Coins are a separate wallet:** spending coins never lowers power.
- **WHY coins skip the multipliers:** prices stay predictable per zone. Spirits make you *stronger*; the stone and your timing make you *richer*. That's also why the v1 maths broke and this doesn't.

---

## 3. SPIRITS (pets)

### 3.1 Eggs

- **One egg stand per zone**, which you pay for with coins. The stand shows every spirit inside, with its odds.

| Rarity | Odds |
|---|---|
| Common | 60% |
| Rare | 28% |
| Epic | 10% |
| Legendary | 1.9% |
| Mythic | 0.1% |
| **Shiny** (independent of rarity) | 1 in 100: ×1.5 bonus, a sparkle |

- **Guarantees** (first run only):
  - a **free egg** waits at the zone 1 stand (the tutorial);
  - the **1st hatch is a Common**, and the **3rd hatch is a Rare**.

  These are why "first Rare" happens at a predictable time.
- **Each zone's egg holds 5 species**, one per rarity, all of that zone's element.
- **Hatching** takes 2 s and can be skipped to 1 s:
  1. the egg drops;
  2. it wobbles 3 times;
  3. **the cracks glow in the rarity's colour** (blue / purple / gold / rainbow);
  4. it bursts.

### 3.2 Spirit bonuses (added to TEAM)

| Zone | Common | Rare | Epic | Legendary | Mythic |
|---|---|---|---|---|---|
| 1 | +0.10 | +0.25 | +0.60 | +1.50 | +4.00 |
| 2 | +0.25 | +0.62 | +1.50 | +3.75 | +10.0 |
| 3 | +0.62 | +1.56 | +3.75 | +9.38 | +25.0 |
| 4 | +1.56 | +3.91 | +9.38 | +23.4 | +62.5 |
| 5 | +3.91 | +9.77 | +23.4 | +58.6 | +156 |
| 6 | +9.77 | +24.4 | +58.6 | +146 | +391 |
| 7 | +24.4 | +61.0 | +146 | +366 | +977 |
| 8 | +61.0 | +153 | +366 | +916 | +2,441 |

**Rule:** each zone's spirits are ×2.5 the previous zone's.

### 3.3 Slots and equipping

- **3 slots to start.**
- **+1 the first time you ever reach zones 2, 4 and 6.** These are permanent and survive Ascension.
- **+1 at Ascensions 1, 2 and 3.**
- **Maximum 9.**
- **"Equip Best"** = the highest bonuses. It changes power only, **never your aura's look** (section 4).

### 3.4 Fusion (exact)

| Recipe | Result | Bonus |
|---|---|---|
| 5 × the same species (normal) | 1 Gold | **6×** the normal bonus |
| 5 × the same Gold | 1 Rainbow | **36×** the normal bonus (6× Gold) |
| Shiny fuses only with Shiny | Shiny Gold / Shiny Rainbow | ×1.5 on top |

- **Fusion never lowers team power:**
  - 5 zone-1 Commons give +0.50 if all 5 are equipped;
  - the Gold gives +0.60 in ONE slot, and frees 4 slots.
- **Preview:** before you confirm, the Fusion Altar shows **"Team ×12.4 → ×13.1 (+5.6%)"**. If the number would drop, the button turns red and asks again.
- **Protection:**
  - **Favourited** (locked) spirits are never used by fusion or mass-delete;
  - equipped spirits are only used after a confirmation, and Equip Best re-runs afterwards.
- **Auto-fuse** is a toggle (default ON for Commons and Rares).
- **Old spirits:** a zone-1 Common is weak by zone 4, even fused. That's normal. Auto-delete settings per rarity per zone keep the inventory clean (200 spirits; favourites don't count).

---

## 4. YOUR AURA (visual rules: what controls what)

### 4.1 Layer hierarchy (each layer has exactly ONE source)

| Layer | Controls | Source |
|---|---|---|
| **Shape + motion** | flames / ice crystals / storm arcs / petals / light rays / void tendrils / starfield | the **element** of your chosen **Aura Look** |
| **Ornament** | how many extra effect layers (section 12) | the **rarity** of your chosen Aura Look |
| **Halo + edge trim** | a ring above your head + the aura's outer edge colour | your **Ascension tier** |
| **Size + intensity** | radius, brightness, pulse strength | your **form** (this run) + your **Ascensions** (permanent) |
| **Orbiters** | the spirits circling inside the aura | your **equipped** spirits |

### 4.2 The Aura Wardrobe (no downgrades)

- **Every look you've ever hatched is unlocked permanently:** element + rarity, e.g. "Void · Mythic".
- **Default = Auto:** your **rarest look ever unlocked** (ties go to the newest zone).
- **You can pick any unlocked look** at the Wardrobe Mirror in the Plaza.
- **Equip Best changes power only.** Your look never drops because a stronger Common got equipped.

### 4.3 Size

```
radius (studs) = 2.5 + 0.4 × min(Ascensions, 10) + 0.9 × (form − 1)
```

| Player | Radius |
|---|---|
| A0, form 1 | 2.5 |
| A3, form 6 | 8.2 |
| A10, form 10 | 14.6 (max) |

- **Ascension resets your form,** so the run part shrinks, but the **permanent Ascension part and the halo stay.** A veteran at form 1 is still visibly bigger and haloed.
- The reset is staged as a rebirth: you collapse into a point and re-ignite in the new colour.

### 4.4 Forms

| Form | Name | How you get it |
|---|---|---|
| 1 | Spark | start |
| 2 | Flame | reach 20% of boss 1's power (the tutorial transformation) |
| 3 | Blaze | **beat boss 1** |
| 4 | Surge | **beat boss 2** |
| 5 | Storm | **beat boss 3** |
| 6 | Tempest | **beat boss 4** |
| 7 | Nova | **beat boss 5** |
| 8 | Eclipse | **beat boss 6** |
| 9 | Titan | **beat boss 7** |
| 10 | Ascended | **beat boss 8** |

- **"Beat the boss → transform":** one combined celebration, with a 2 s cinematic.
- Forms 6+ are announced to the server.
- Forms reset on Ascension and are re-earned on every run.

---

## 5. BOSS CLASH (exact rules; model: `clash_sim.py`, 2,000 fights per cell)

1. **The boss gate** shows the boss's power. It turns gold at **1.1×** ("READY").
2. **The clash is solo and lasts up to 45 s.**
   - The meeting point **M** starts at 50. M = 100 wins; M = 0, or the time running out, loses.
3. **Drift every second:**

   ```
   12 × (√(yourPower ÷ bossPower) − 1)
   ```

   clamped to −12 … +12.
4. **Your releases:** the training input pushes M.

| Release | Push |
|---|---|
| PERFECT | **+(2.4 + 0.5 × combo step)**, steps 0-4 |
| Early | +0.5 × hold/1.02 |
| Overcharge | +0.3 |

   **No Overdrive in clashes.**
5. **Boss attacks:**
   - **every 5 s** (every **3.5 s** when M ≥ 70: **ENRAGED**);
   - each attack has a **1.0 s telegraph** (the boss glows) and then a **0.5 s strike window** (red flash);
   - **COUNTER = a quick TAP (under 0.5 s)** inside the strike window: **+4**;
   - no tap in the window → the strike hits: **−4**;
   - a tap cancels any charge in progress, so the skill is *"finish your PERFECT, then tap"*.

   **WHY a separate tap:** a full charge (1.2 s) can't fit a 1 s warning. A tap can.
6. **Overpower:** at **3× the boss's power or more**, there's no clash. It's an instant 2 s KO cinematic, so veterans replaying early zones aren't slowed down.

**Results** (assumes the player abandons the current charge at each telegraph and spends 1.5 s countering, the worst case):

| Your power ÷ boss | Casual (40% perfect / 40% counter) | Average (60% / 65%) | Skilled (85% / 90%) |
|---|---|---|---|
| 0.9× | 0% | 2% | **80%** |
| 1.0× | 1% | 40% | 100% |
| **1.1× (gold gate)** | 21% | **92%** | 100% |
| 1.25× | **93%** | 100% | 100% |
| 1.5× | 100% (19 s) | 100% (15 s) | 100% (13 s) |

**Meaning:**
- an average player at the gold gate wins about 9 fights in 10;
- skilled players can win early (0.9×);
- casual players win at 1.25×, a little more training.

Nobody is stuck.

- **Win:**
  - the next form;
  - **first-clear coins** (section 7);
  - a **free egg** of the next zone;
  - the next zone opens.
- **Lose:**
  - a card shows how far you got;
  - **one tip:** "Need ~15% more power", or "TAP on the red flash!";
  - retry in one tap.

---

## 6. ASCEND (exact repeat rules; model: `ascension.py`)

- **Requirement for Ascension n+1:**
  - boss 4 beaten in this run;
  - **AND** peak power this run ≥ boss 4's power × **5ⁿ** (n = Ascensions so far).
- **Reward:**
  - **shards = 1 + 1 per ×100 of power beyond the requirement**;
  - the ASCENSION multiplier = 1 + 0.5 × all shards ever earned.
- **The Ascend button** always shows **"Ascend now: +X shards. Next shard at Y power."** The choice is visible.

| Ascension | Power needed | About where that is |
|---|---|---|
| 1 | 170 M | zone 4 boss |
| 2 | 850 M | zone 4-5 |
| 3 | 4.2 B | zone 5 boss |
| 4 | 21 B | zone 5 → 6 |
| 5 | 110 B | zone 6 boss |
| 6 | 530 B | zone 6 → 7 |
| 7 | 2.7 T | zone 7 boss |
| 8 | 13 T | zone 7 → 8 |
| 9 | 66 T | zone 8 boss / Infinity 1 |
| 10 | 330 T | Infinity ~4 |
| 11 | 1.7 Q | Infinity ~8 |
| 12 | 8.3 Q | Infinity ~11 |

| Resets | Kept |
|---|---|
| power, coins, zone access (back to zone 1), stone levels, form | spirits, slots, shards, Wardrobe looks, index, Boss Seals, Egg Tickets, the incubator, streak |

**Also gives:**
- the next **Ascension tier**: halo + trim colour (gold → crimson → violet → void → prismatic; A6+ = prismatic ★1, ★2…, with no cap);
- **+1 slot** (A1-A3);
- the rebirth ceremony and a server announcement.

### 6.1 Strategy check (average player, 8 h of play, 24 simulated players each)

| Strategy | Ascensions | Shards | ASCENSION × | First boss 8 |
|---|---|---|---|---|
| Ascend as soon as allowed (1 shard) | 11 | 11 | 6.5 | 2.5 h |
| **Wait for 2 shards** | 8 | **16** | **9.0** | 2.4 h |
| Wait for 3 shards | 5 | 15 | 8.5 | 2.5 h |
| Wait for 4 shards | 2 | 8 | 5.0 | 2.7 h |

**Both paths are real:**
- **Ascending ASAP** gives more Ascensions: slots A1-A3 sooner, colours and halo tiers sooner, more rebirth moments;
- **waiting for 2** gives the most total power;
- **waiting too long** is worse.

**Early-zone farming is impossible:** after Ascension 2 the requirement is beyond zone 4's power, so every run must go deeper. Earlier versions of these rules produced 166-364 Ascensions in 8 h, and the model caught it. The rules here produce 2-11.

---

## 7. BALANCE TABLE (model: `economy.py`)

**Prices** = seconds of an **average** player's Lv1 coin income in that zone:
- egg = 15 s;
- stone Lv2 = 40 s;
- stone Lv3 = 120 s;
- first-clear coins = 30 s of the **next** zone's income.

**Boss power** was derived from the target zone times (minutes: 3, 5, 8, 12, 18, 25, 35, 50) by simulating 60 average players.

| Zone (element) | Stone base | Egg | Stone Lv2 | Stone Lv3 | Boss power | Gold gate (1.1×) | First-clear coins |
|---|---|---|---|---|---|---|---|
| 1 Training Grounds (Light) | 1 | 29 | 79 | 240 | 1,100 | 1,200 | 350 |
| 2 Lava Dojo (Fire) | 6 | 180 | 470 | 1,400 | 78,000 | 86,000 | 2,100 |
| 3 Frozen Peak (Frost) | 36 | 1,100 | 2,800 | 8,500 | 4.1 M | 4.5 M | 13,000 |
| 4 Storm Temple (Storm) | 216 | 6,400 | 17,000 | 51,000 | 170 M | 190 M | 76,000 |
| 5 Sakura Realm (Nature) | 1,296 | 38,000 | 100,000 | 310,000 | 4.3 B | 4.7 B | 460,000 |
| 6 Sky Sanctuary (Light) | 7,776 | 230,000 | 610,000 | 1.8 M | 110 B | 120 B | 2.8 M |
| 7 Void Rift (Void) | 46,656 | 1.4 M | 3.7 M | 11 M | 2.6 T | 2.9 T | 17 M |
| 8 Galaxy Throne (Cosmic) | 279,936 | 8.3 M | 22 M | 66 M | 58 T | 64 T | — |
| Infinity tier k | (zone 8 stone) | (zone 8 egg) | — | — | 58 T × 1.6ᵏ | ×1.1 | — |

**Check of the v1 problem:** in zone 1 an average player earns about 2 coins/s at Lv1. Stone Lv2 (79) takes about 40 s; Lv3 (240) about 60 s at Lv2; an egg (29) about 15 s. All of it is affordable well before the 1,200-power gate, which the model reaches at about 3.6 min.

---

## 8. AURA PLAZA (where players meet)

- **Everyone spawns in the Plaza** on join, and returns through it. **Zone portals ring the Plaza** (8 arches + the Infinity Gate), each showing locked or unlocked and your best clear.
- **Every shared machine is ONLY in the Plaza:**
  - the **Fusion Altar**;
  - the **Incubator**;
  - the **Wardrobe Mirror**;
  - the **Daily Board** (streak, Boss Seals, rematches);
  - the **Spirit Index wall**.

  So every player passes through several times per session.
- **The Showcase Stage:**
  - step on it to get a spotlight, a camera orbit, and a banner: "★ Nik is showing off ★";
  - anyone nearby can inspect you.
- **Inspect anyone** (tap or click a player anywhere). Their card shows:
  - Ascension tier;
  - form;
  - power;
  - Aura Look;
  - all 9 equipped spirits (Gold, Rainbow, Shiny visible);
  - best Infinity tier.
- **Statues:** the top 3 players by best Infinity tier stand in the Plaza as statues with their **live** Aura Look and halo. Their names are on the plinth.
- **Veterans pass beginners naturally:** every Ascension replays zones 1-4 in minutes (the model shows bosses 1-4 cleared within 3 min after A1). Huge haloed auras blast through the zones where new players are training.

---

## 9. THE FIRST 2 HOURS (model output, not a promise)

Average player, one representative simulated player, "wait for 2 shards" strategy. The p10-p90 spread for first-run bosses is in the next table.

| Time | Event |
|---|---|
| 0:00 | free tutorial egg → a Common spirit orbiting you |
| 0:42 | stone Lv2 |
| 1:00 | 3rd hatch: guaranteed **Rare** |
| 1:12 | **form 2: FLAME** (20% of boss 1) |
| 2:30 | first **Gold fusion** (5 zone-1 Commons) |
| 3:30 | **Boss 1** → BLAZE, zone 2, 4th slot |
| 8:18 | first **Rainbow** fusion |
| 9:36 | **Boss 2** → SURGE |
| 17:54 | **Boss 3** → STORM, zone 4, 5th slot |
| 30:54 | **Boss 4** → TEMPEST. Ascension available (1 shard); this player waits for 2 |
| 48:54 | **Boss 5** → NOVA, zone 6, 6th slot |
| 52:48 | **Ascension 1** (2 shards, ×2.0): gold halo, 7th slot |
| 53-60 | bosses 1-5 again in about 7 min |
| 67:24 | **Ascension 2** |
| 84:42 | **Ascension 3** (9th slot) |
| 97:54 | **Ascension 4** |
| 110:18 | **Boss 7** (first time) |
| 113:18 | **Ascension 5** |

**First run** (no Ascension), median [p10-p90] of 120 simulated players per type:

| Event | Casual | Average | Skilled | Idle (AFK) |
|---|---|---|---|---|
| First Rare | 1.8 m | 1.0 m | 0.6 m | 4.6 m |
| First Gold fusion | 4.4 m | 2.5 m | 1.6 m | 11.3 m |
| Boss 1 | 6.0 m | 3.6 m [3.4-4.1] | 2.3 m | 14.3 m |
| Boss 2 | 15 m | 9.2 m [8.4-9.7] | 6.2 m | 36 m |
| Boss 3 | 30 m | 17.7 m [16.6-18.8] | 11.5 m | 73 m |
| Boss 4 | 56 m | 30.8 m [29.3-32.9] | 19 m | 2.3 h |
| Boss 5 | 92 m | 49.5 m | 29 m | — |
| Boss 8 | 5.3 h | 2.7 h [2.5-2.9] | 1.5 h | — |

Walking and menus aren't modelled, so add about 10-15%. **Idle players** progress at about a fifth of the average player's speed. AFK is real but slow, by design.

---

## 10. RETURN SYSTEMS (exact)

### 10.1 Luck

"×N luck" = **every Rare-or-better weight × N, then renormalised** (Commons absorb the difference).

| Rarity | Normal | ×2 luck | ×3 luck |
|---|---|---|---|
| Common | 60% | 42.9% | 33.3% |
| Rare | 28% | 40.0% | 46.7% |
| Epic | 10% | 14.3% | 16.7% |
| Legendary | 1.9% | 2.71% | 3.17% |
| Mythic | 0.1% | 0.143% | 0.167% |

Shiny odds are unchanged by luck.

### 10.2 Incubator (Plaza)

- **1 slot.** Put in an egg from any zone you've unlocked this run, paying its normal coin price.
- It hatches **8 h later in real time** (it counts while you're offline), with **×2 luck**.
- The result is rolled when you collect it.
- **Survives Ascension.**
- **Its job:** the last thing you do before leaving, and the first thing you collect on return.

### 10.3 Daily streak (Daily Board)

Every reward is **persistent** (it survives Ascension):
- **Egg Tickets** = one free hatch of your current deepest zone's egg;
- **Luck Charms** = ×2 luck for 10 min.

| Day | Reward |
|---|---|
| 1 | 1 Ticket |
| 2 | 1 Charm |
| 3 | 2 Tickets |
| 4 | 1 Charm |
| 5 | 3 Tickets |
| 6 | 2 Charms |
| 7 | 3 Tickets + 1 **Lucky Ticket** (a ×3-luck hatch) |

Missing a day resets the streak to day 1.

### 10.4 Daily boss rematch + Boss Seals

- **Each boss you've ever beaten** can be rematched **once a day** from the Daily Board. It's at its normal power, so it's usually an instant Overpower KO for veterans: about 2 s each.
- **Each rematch win gives:**
  - **1 Boss Seal** of that boss (persistent);
  - a **1% chance** of its unique **Boss Spirit** (Mythic-tier for that zone ×1.5, with a unique look and element);
  - coins = 60 s of that zone's Lv1 income.
- **25 Seals of one boss craft its Boss Spirit,** guaranteed in at most 25 days per boss.
  - Chance of getting the drop before then: 1 − 0.99²⁴ ≈ 21%.
  - With 8 bosses, the daily routine is about 8 quick rematches, so every attempt is progress.

### 10.5 Playtime chests

One every **10 min** online (up to 6 a day). Each = 1 Egg Ticket.

---

## 11. ENDGAME (after zone 8)

- **Infinity Gate (Plaza):** endless boss tiers; tier k = 58 T × 1.6ᵏ. They count as depth for Ascension requirements (Ascension 9+ needs Infinity tiers, see section 6).
- **Plaza statues** = the top 3 best Infinity tiers. There's also a server and global leaderboard.
- **Ascension tiers never end:** prismatic ★1, ★2, … The halo gains stars.
- **Collection goals:**
  - the **Spirit Index**: 40 zone spirits + 8 Boss Spirits, plus Gold / Rainbow / Shiny variants;
  - **completing a zone's row** gives a permanent +5% power;
  - the **Wardrobe**: 7 elements × 5 rarities = 35 looks.
- **Model check:** an average player is at Infinity tier 4-7 after 8 h. The wall rises ×1.6 per tier while power grows with shards and spirits, so progress slows smoothly instead of ending.

---

## 12. QUALITY TARGET (aura at gameplay distance)

**References.** Winter collects 10-second clips into `ART/refs/` before concepting:
- anime power-up auras: the flame-column shape, the pulse, the ground debris;
- Sol's RNG high-rarity auras: the Roblox endgame bar for layered aura VFX;
- Pet Simulator 99 hatch reveals and Huge announcements: the hatch tension, the colour tell.

**Judge at the default camera** (18-25 studs), plus from across the Plaza (60+ studs):

| Stage | Radius | Layers | Particles alive (own) | Must read as |
|---|---|---|---|---|
| **Early** (forms 1-3, Common / Rare look) | 2.5-4.3 | 2: soft glow + rising motes / element wisps | ≤ 40 | a warm glow in the element's colour |
| **Mid** (forms 4-7, Epic / Legendary, A1-A3) | 5-9 | 4-5: + a flipbook element shape, a ground ring, orbit sparks, a halo | ≤ 120 | a coloured column visible at 60 studs |
| **End** (forms 8-10, Mythic, A5+) | 10-15 | 6-7: + a signature (wings / creature-silhouette wisps), a pulse every 4 s | ≤ 220 | "stop and stare": readable from across the Plaza |

**Performance budgets** (Roblox's performance guidance: overlapping transparent layers are expensive; see https://create.roblox.com/docs/performance-optimization/improve):
- **Other players' auras:**
  - full within 40 studs (max 120 particles each);
  - reduced at 40-100 studs (max 30, no beams);
  - beyond 100 studs, a glow billboard only.
- **Total aura particles per client ≤ 1,500.**
- **At most 4 overlapping transparent layers** at the screen centre.
- **Low graphics:** half rates, no flipbooks.

**Settings:**

| Setting | Options |
|---|---|
| Others' effects | High / Medium / Low / Off |
| Camera shake | Full / Low / Off |
| Reduced flashing | toggle |
| Show others' auras | All / Friends / None |

---

## 13. PLAYTEST #1 (what's in it, what we watch)

**In the build:**
- the stone + charge / release + combo + Overdrive + meditation;
- 1 egg with 5 spirits, **one of them with a distinct element look**;
- spirits orbiting and feeding the aura;
- the Wardrobe change on that hatch;
- aura growth + **one transformation** (boss 1 → BLAZE);
- boss 1 clash with the counter;
- zone 2 unlocked;
- the Fusion Altar with a preview.

**Watch a fresh player** (no instructions) and record:

| # | Observation | Pass if |
|---|---|---|
| 1 | Time to the first PERFECT, unaided | under 30 s |
| 2 | "What did that spirit do?" | they say it made them stronger AND / OR changed their aura |
| 3 | Do they understand the red flash → TAP? | by their 2nd fight |
| 4 | After boss 1, do they keep playing without being asked? | 5+ more minutes |
| 5 | Do they show wanting the next spirit or form? | they point at, ask about, or walk to the egg / gate |
| 6 | Timing fatigue after 10 min | they don't say "tiring" / "annoying"; they use Overdrive and idle naturally |
| 7 | "If you came back tomorrow, what would you do first?" | they name a concrete action |
| 8 | Fun 1-10, best moment, most boring moment | fun 7+ |

**If #1, #3 or #6 fails,** fix the input timing before ANY art (e.g. widen the glow band, shorten the charge, or add more Overdrive).
