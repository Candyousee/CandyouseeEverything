# AURA CLASH: Core Game v2.2 (rules + one balance model, audited)

**No monetization here:** the owner designs that separately.

**Every number here comes from the model in `econ/`. It ships WITH this file:** the AuraClash zip contains this document plus `econ/`.

| File | What it covers | Saved output |
|---|---|---|
| `training.py` | training rates | — |
| `clash_sim.py` | boss fights | `clash_results.txt` |
| `economy.py` | prices, gates, eggs, fusion, first-run timelines | `RESULTS-economy.txt` |
| `ascension.py` | Ascension strategies and the first 2 hours | `RESULTS-ascension.txt` |
| `tests.py` | 7 rule checks that tie the model to this document | `python tests.py` → 7 passed |

- **Verify:** `python tests.py && python economy.py && python ascension.py` (Python 3, standard library only, about 2 minutes). Seeds are fixed, so the results are identical on every run.
- **Change a rule → change its constant → re-run.**
- **All times are model outputs** for simulated players.
- **Assumptions the times depend on:**
  - players buy the upgrade with the best power gain per coin;
  - a hatch takes 2 s;
  - walking and menus are not modelled (add about 10-15%);
  - INDEX bonuses are not modelled (at most +50%, so the times are conservative).

## Changes in v2.2 (audit: the model must follow the written rules)

| # | Audit finding | Fix (model + doc) | Test |
|---|---|---|---|
| 1 | The beam didn't move during recovery; the 2 s Overpower took about 6.6 s | The drift now runs continuously (recovery, counters); Overpower = exactly 2 s in the model | `test_drift_continues_during_recovery`, `test_overpower_is_two_seconds` |
| 2 | The model auto-fused every rarity, including equipped spirits | Auto-fuse = Commons + Rares, unequipped copies only. Everything else is a manual fusion at the Plaza altar (+15 s trip), and only when it raises team power | `test_auto_fuse_rules`, `test_manual_fusion_never_lowers_power` |
| 3 | The buyer ignored fusions an egg would complete | The egg value is now the exact expected team gain **including the fusion it completes** | `test_egg_value_counts_fusion` |
| 4 | The Fire-look playtest contradicted the Wardrobe | The new-look prompt + choosing the look at the Wardrobe Mirror is now what the playtest checks (4.2, 13) | — |
| 5 | GAME-PLAN.md had an outdated build plan, monetization steps and a false "gold cracks → Epic" cue | GAME-PLAN.md is rewritten as market + pitch + the two-zone build only; **crack colour always equals the result** (3.1); old drafts deleted | — |
| small | Unstable seeds; minimum shard; incubator / overflow details | Stable CRC seeds; the shard formula floors at 1; incubator / mailbox rules (10.2, 3.6) | `test_stable_seeds`, `test_min_one_shard` |

**Effect on results:**
- boss powers shifted slightly (boss 1 is now 820);
- the average first run to boss 8 is still about 2.7 h;
- the Ascension strategy picture is unchanged.

## Changes in v2.1 (second review)

| # | Issue | Decision | Section |
|---|---|---|---|
| 1 | Fusion beat rarity (a z8 Rainbow Rare beat a Mythic); "old spirits are weak even fused" was false | **Fusion is now 3 → 1 at ×3 / ×9.** It's the *reliable* path, but a Mythic still beats any Rainbow below Epic. The claims are corrected | 3.4 |
| 2 | "AFK" timelines implied automation | Renamed **meditation + manual management**; true unattended progress defined and measured | 2.4 |
| 3 | The incubator reward was too small | **A guaranteed Legendary+ of your deepest zone, a chance at an exclusive Dream variant, and 3 Boss Seals** | 10.2 |
| 4 | Ascension power-vs-depth contradiction; first-clear scope | Ascension needs **depth** (bosses, then Infinity tiers) with an exact shard formula; **first-clear rewards are once per account** | 5, 6 |
| 5 | Not verifiable; INDEX missing from the formula | The model ships with the doc; INDEX is in the formula with a stacking rule | 2.3 |
| 6 | Counter, inventory, auto-fusion and boss-look rules | All defined | 3.5, 3.6, 4.2, 5 |
| 7 | The playtest used content the rules don't allow; weak criteria | Uses the zone-2 egg + Rare ornament; **behaviour-based** pass criteria, including a real next-day return | 13 |

---

## 1. What the game is

**A pet training simulator:** train → hatch spirits → beat each zone's boss → grow your aura → Ascend → go deeper. The only fighting is the boss clash.

---

## 2. TRAIN

### 2.1 Input (one button, on your zone's Training Stone)

| Hold | Result | Gain | Combo |
|---|---|---|---|
| under 0.5 s | nothing (a TAP; see the counter rule, section 5) | 0 | unchanged |
| 0.5 - 1.02 s | **Early** | 0.6 × hold / 1.02 | resets |
| 1.02 - 1.20 s | **PERFECT** | 2 × combo | +1 step |
| over 1.20 s | **Overcharge** | 0.5 + a 0.4 s stagger | resets |

- **Recovery** of 0.25 s after every release. **Presses during recovery are buffered** and start when it ends.
- **Combo:** ×1 → ×1.25 → ×1.5 → ×1.75 → ×2.
- **Overdrive:** 5 PERFECTs in a row start **OVERDRIVE** (8 s):
  - every release of 0.5 s or more counts as PERFECT ×2;
  - afterwards the combo returns to ×1.5.
- **Meditation:** no input for 3 s on the stone = 0.4 per second. It works **only while you're in the game** (not offline).

### 2.2 Rates (`training.py`)

| Player | Units / s | vs meditation | Releases / h | Overdrives / h |
|---|---|---|---|---|
| Meditation only | 0.40 | 1.0× | 0 | 0 |
| Masher (0.5 s holds) | 0.39 | ~1.0× | 4,800 | 0 |
| Casual (40% PERFECT) | 1.06 | 2.7× | 2,706 | 18 |
| Average (60%) | 1.97 | 4.9× | 2,979 | 84 |
| Skilled (85%) | 3.42 | 8.6× | 3,519 | 218 |

### 2.3 Power and coins

```
Power per release = gain × STONE BASE × STONE LEVEL × TEAM × FORM × ASCENSION × INDEX
Coins per release = gain × STONE BASE × STONE LEVEL
```

| Factor | Value |
|---|---|
| **STONE BASE** | 1, 6, 36, 216, 1,296, 7,776, 46,656, 279,936 (zones 1-8) |
| **STONE LEVEL** | ×1 / ×2 / ×4 |
| **TEAM** | 1 + the sum of equipped spirit bonuses |
| **FORM** | 1 + 0.05 × (form − 1) |
| **ASCENSION** | 1 + 0.5 × shards |
| **INDEX** | 1 + 0.05 × (completed zone rows) + 0.10 if all 8 Boss Spirits are owned. It's additive inside, so the maximum is ×1.50 |

**Coins skip the multipliers on purpose:** prices stay predictable per zone.

### 2.4 What "AFK" means (honest definitions)

- **Unattended (nobody at the keyboard):**
  - you meditate on your current stone, banking **power and coins**;
  - **nothing is automated:** no buying, hatching, clashing or zone changes;
  - **8 h unattended ≈ 1.6 h of average active training** on that stone. You come back to a big coin bank to spend, which is part of the return loop.
- **The "idle" column** in the timelines (section 9) = **meditation + manual management**: someone who never times releases, but buys, hatches and fights when they check in.
- **Any automation** (auto-train, auto-hatch) would be a product decision for the owner, not part of the core game.

---

## 3. SPIRITS

### 3.1 Eggs

- **One stand per zone,** paid in coins. **5 species** (one per rarity), all of the zone's element.

| Rarity | Odds |
|---|---|
| Common | 60% |
| Rare | 28% |
| Epic | 10% |
| Legendary | 1.9% |
| Mythic | 0.1% |
| **Shiny** (independent) | 1 in 100, ×1.5 |

- **First-run guarantees:**
  - a free tutorial egg;
  - the 1st hatch is a Common;
  - the 3rd hatch is a Rare.
- **Hatch:** 2 s (skippable to 1 s), with the coloured-crack tell. **The crack colour is ALWAYS the real result's rarity.** No fake "almost" cues, ever.

### 3.2 Bonuses (normal spirits; each zone ×2.5 the last)

| Zone | Common | Rare | Epic | Legendary | Mythic |
|---|---|---|---|---|---|
| 1 | 0.10 | 0.25 | 0.60 | 1.50 | 4.00 |
| 2 | 0.25 | 0.62 | 1.50 | 3.75 | 10.0 |
| 3 | 0.62 | 1.56 | 3.75 | 9.38 | 25.0 |
| 4 | 1.56 | 3.91 | 9.38 | 23.4 | 62.5 |
| 5 | 3.91 | 9.77 | 23.4 | 58.6 | 156 |
| 6 | 9.77 | 24.4 | 58.6 | 146 | 391 |
| 7 | 24.4 | 61.0 | 146 | 366 | 977 |
| 8 | 61.0 | 153 | 366 | 916 | 2,441 |

### 3.3 Slots

- 3 to start;
- +1 the first time you ever reach zones 2, 4 and 6 (permanent);
- +1 at Ascensions 1, 2 and 3;
- **maximum 9.**

"Equip Best" changes power only, never your look.

### 3.4 Fusion: an intentional "reliable path" vs the "lucky path"

| Recipe | Result | Bonus | Ingredients from hatches (avg) |
|---|---|---|---|
| 3 × the same normal spirit | **Gold** | ×3 | — |
| 3 × the same Gold | **Rainbow** | ×9 | 9 of that species |
| Shiny fuses only with Shiny | Shiny Gold / Rainbow | ×1.5 on top | — |

**Zone 8, what to chase:**

| Spirit | Bonus | Hatches needed (avg) |
|---|---|---|
| Rainbow Common | 549 | 15 |
| Rainbow Rare | 1,373 | 32 |
| **Normal Mythic** | **2,441** | **1,000** |
| Rainbow Epic | 3,296 | 90 |
| Rainbow Legendary | 8,240 | 474 |
| Rainbow Mythic | 21,972 | 9,000 |

- **Design intent:** fusion lets steady grinders keep up (a Rainbow Epic beats one lucky Mythic).
- **Mythics stay special:**
  - they're the strongest *single* hatch;
  - they unlock the **Mythic Wardrobe tier** (the biggest visual);
  - they're **announced to the server**;
  - a Rainbow Mythic is the endgame chase.
- **Never a loss:** 3 spirits → 1 Gold = the same total bonus in one slot, plus 2 slots freed.
- **Old spirits fade:** a zone-1 Rainbow Common (+0.9) is beaten by a zone-4 Common (+1.56). Fused or not, old-zone spirits are outclassed about 2 zones later.

### 3.5 Where fusion happens

- **Auto-fuse:** a toggle, **default ON for Commons and Rares**. It runs **anywhere**, instantly, but only on spirits that are **unequipped and unfavourited**.
- **Manual fusion** (any rarity, including equipped spirits) happens **only at the Fusion Altar in the Plaza**. It shows the team-power preview ("Team ×12.4 → ×13.1") and asks for confirmation.
- **When manual fusion is possible,** the Spirits button shows a "Fusion ready" badge, so players know a Plaza trip is worth it.
- **How the model plays it:** a trip to the altar (15 s) whenever any fusion would raise team power, doing every such fusion on that trip.
- **Favourited spirits** are never used by fusion or deletion.

### 3.6 Inventory

- **Hard limit: 250 spirits**, favourites included.
- **When it's full:**
  - hatching is blocked, with a one-tap "Delete all unequipped Commons from old zones?" prompt;
  - **auto-delete rules** (per zone × rarity) clean up as you hatch;
  - rewards that would overflow (incubator, tickets, Boss Spirits) wait in a **Plaza mailbox** (up to 50) until there's space;
  - **if the mailbox is also full,** the incubator keeps its finished reward (shown as "Ready, make space") and doesn't start a new egg. Nothing is ever deleted automatically.

---

## 4. YOUR AURA

### 4.1 Layer hierarchy (each has ONE source)

| Layer | Source |
|---|---|
| **Shape + motion** | the chosen Aura Look's **element**, or its **Signature** for boss looks |
| **Ornament** (extra layers, section 12) | the chosen look's **rarity** |
| **Halo + edge trim** | your **Ascension tier** |
| **Size + intensity** | **form** (this run) + **Ascensions** (permanent) |
| **Orbiters** | your **equipped** spirits |

### 4.2 Wardrobe (no downgrades) + Signature looks

- **Every element × rarity you've ever hatched** is unlocked forever. **Auto** = the rarest one unlocked (ties go to the newest zone).
- **New-look prompt:** the first time a hatch unlocks a look you don't have, the hatch card shows **"NEW LOOK: wear it?"** (one tap, or ignore). Saying yes sets that look (manual mode), and you can return to Auto at the Wardrobe Mirror.

  This is how a player gets the Fire look from a zone-2 Common even though they already own a Light Rare: **they choose it**. Auto would keep the rarer Light Rare.
- **Boss Spirits unlock Signature looks:** 8 unique shapes, separate from the element looks, with Mythic-level ornament:

| Boss | Signature look |
|---|---|
| Stone Golem | orbiting rune-stones |
| Magma Oni | a horned flame mask + ember rain |
| Frost Yeti | a blizzard swirl + ice spikes |
| Thunder Tengu | lightning wings |
| Kitsune Queen | nine fox-fire tails |
| Sun Phoenix | a phoenix silhouette + a rising sun halo |
| Void Titan | a void rift crown |
| Star Emperor | a galaxy cape + constellations |

  Signature looks occupy the shape layer, so they never collide with ordinary Mythic looks.
- **Dream variants** (incubator only, section 10.2) unlock a **Dream** version of any look: pastel, plus a starlight shimmer.

### 4.3 Size

```
radius = 2.5 + 0.4 × min(Ascensions, 10) + 0.9 × (form − 1)    (maximum 14.6 studs)
```

Ascension resets the form part. The permanent part and the halo stay.

### 4.4 Forms

| Form | Name | Earned at |
|---|---|---|
| 1 | Spark | start |
| 2 | Flame | 20% of boss 1's power |
| 3 | Blaze | beat boss 1 |
| 4 | Surge | beat boss 2 |
| 5 | Storm | beat boss 3 |
| 6 | Tempest | beat boss 4 |
| 7 | Nova | beat boss 5 |
| 8 | Eclipse | beat boss 6 |
| 9 | Titan | beat boss 7 |
| 10 | Ascended | beat boss 8 |

---

## 5. BOSS CLASH (`clash_sim.py`)

**Gate:** shows the boss's power; turns gold at 1.1×. The meeting point M starts at 50 (100 = win; 0, or 45 s passing, = loss).

| Rule | Value |
|---|---|
| Drift / s | 12 × (√(you ÷ boss) − 1), clamped to ±12 |
| PERFECT push | 2.4 + 0.5 × combo step |
| Early push | 0.5 × hold/1.02 |
| Overcharge push | 0.3 |
| Overdrive | none in clashes |
| Attack | every 5 s (**3.5 s when M ≥ 70**, enraged): a 1.0 s telegraph, then a 0.5 s strike window |
| **Overpower** | at 3× the boss's power or more: an instant 2 s KO, no clash |

### Counter rules (exact)

- **A counter** is a press that **starts and ends inside the strike window** and lasts **under 0.5 s**. It gives **+4** (no tap gives **−4**).
- **Recovery never blocks a counter.** A tap during recovery still counts.
- **If you're already holding when the window opens,** releasing that hold is a *normal* release (Early / PERFECT), **not** a counter. You must release, then tap.

  That's the skill: *finish your PERFECT before the flash, then tap*.
- **Only one counter per attack.** Extra taps in the window do nothing.

### Results (2,000 fights per cell; assumes the player abandons their charge at each telegraph, the worst case)

| You ÷ boss | Casual (40% / 40%) | Average (60% / 65%) | Skilled (85% / 90%) |
|---|---|---|---|
| 0.9× | 0% | 2% | 74% |
| 1.0× | 1% | 41% | 100% |
| **1.1× (gold)** | 29% | **94%** | 100% |
| 1.25× | **98%** | 100% | 100% |
| 1.5× | 100% (16 s) | 100% (14 s) | 100% (12 s) |
| 3.0× and above | Overpower: 2 s KO | 2 s | 2 s |

The beam drifts continuously, including during recovery and counters (v2.2 fix).

### Clear rewards

| Reward | When |
|---|---|
| Next form | **every run** |
| **First-clear coins + free next-zone egg** | **once per account** (replays don't repeat them) |

---

## 6. ASCEND (exact; `ascension.py`)

- **Requirement for Ascension n+1:** clear depth **D(n)** in this run:

| Ascension | 1 | 2 | 3 | 4 | 5 | 6 | 7 | 8 | 9 | 10 | 11 | 12 | … |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| Clear | boss 4 | boss 5 | boss 5 | boss 6 | boss 6 | boss 7 | boss 7 | boss 8 | boss 8 | Infinity 1 | Infinity 2 | Infinity 3 | one more tier each |

- **Shards:**

  ```
  shards = 1 + floor( log₁₀₀( max(peak run power, B) ÷ B ) )      B = power of the boss at D(n)
  ```

  The `max` means a skilled player who beats the required boss **below** its power still gets exactly 1 shard.

  That's 1 for meeting the requirement, +1 for each ×100 beyond it. The Ascend button always shows "+X now; next at Y power".
- **Why early-zone farming is impossible:** the requirement is a boss or tier you must clear, not a power number. From Ascension 2 on it's beyond zone 4, and from Ascension 10 on it **requires Infinity tiers**.

| Resets | Kept |
|---|---|
| power, coins, zone access, stone levels, form | spirits, slots, shards, Wardrobe, index, seals, tickets, incubator, streak, first-clear history |

**Also gives:**
- a halo tier (gold → crimson → violet → void → prismatic, then prismatic ★1, ★2…);
- +1 slot (A1-A3);
- the rebirth ceremony.

**Strategy check** (average player, 8 h, 24 simulated players each):

| Strategy | Ascensions | Shards | ASCENSION × | First boss 8 |
|---|---|---|---|---|
| Ascend ASAP (1 shard) | 15 | 15 | 8.5 | 2.6 h |
| Wait for 2 shards | 7 | 14 | 8.0 | 2.1 h |
| Wait for 3 shards | 5 | 15 | 8.5 | 2.6 h |
| Wait for 4 shards | 1 | 4 | 3.0 | 2.6 h |

**Both paths work:**
- **ASAP:** more Ascensions, so more slots, halos and ceremonies;
- **waiting a little:** reaches boss 8 sooner;
- **hoarding:** loses.

---

## 7. BALANCE TABLE (`economy.py`)

- **Prices** = seconds of an average player's Lv1 coin income in that zone: egg 15 s, Lv2 40 s, Lv3 120 s, first-clear = 30 s of the next zone.
- **Boss power** is derived from the target zone times (3, 5, 8, 12, 18, 25, 35, 50 min) over 60 simulated average players.

| Zone (element) | Stone base | Egg | Stone Lv2 | Stone Lv3 | Boss power | Gold gate | First-clear coins (once) |
|---|---|---|---|---|---|---|---|
| 1 Training Grounds (Light) | 1 | 29 | 79 | 240 | 820 | 900 | 350 |
| 2 Lava Dojo (Fire) | 6 | 180 | 470 | 1,400 | 56,000 | 62,000 | 2,100 |
| 3 Frozen Peak (Frost) | 36 | 1,100 | 2,800 | 8,500 | 2.7 M | 3.0 M | 13,000 |
| 4 Storm Temple (Storm) | 216 | 6,400 | 17,000 | 51,000 | 120 M | 130 M | 76,000 |
| 5 Sakura Realm (Nature) | 1,296 | 38,000 | 100,000 | 310,000 | 3.5 B | 3.9 B | 460,000 |
| 6 Sky Sanctuary (Light) | 7,776 | 230,000 | 610,000 | 1.8 M | 89 B | 98 B | 2.8 M |
| 7 Void Rift (Void) | 46,656 | 1.4 M | 3.7 M | 11 M | 2.0 T | 2.2 T | 17 M |
| 8 Galaxy Throne (Cosmic) | 279,936 | 8.3 M | 22 M | 66 M | 46 T | 51 T | — |
| Infinity tier k | (zone 8) | (zone 8) | — | — | 46 T × 1.6ᵏ | ×1.1 | — |

---

## 8. AURA PLAZA (where players meet)

- **Spawn and return point:** zone portals ring the Plaza, plus the Infinity Gate.
- **Only in the Plaza:**
  - the Fusion Altar (manual fusion);
  - the Incubator;
  - the Wardrobe Mirror;
  - the Daily Board (streak, rematches, seals);
  - the Index wall;
  - the mailbox.
- **Showcase Stage:** a spotlight, a camera orbit and a banner.
- **Inspect any player.** Their card shows:
  - Ascension tier;
  - form;
  - power;
  - look;
  - the 9 equipped spirits;
  - best Infinity tier.
- **Statues** of the top 3 best Infinity tiers, wearing their live looks.
- **Veterans replay zones 1-4 within minutes** of each Ascension (model: bosses 1-4 cleared in about 4 min after A1), so they pass straight through where new players train.

---

## 9. TIMELINES (model output)

**First run, median [p10-p90] of 120 simulated players:**

| Event | Casual | Average | Skilled | Meditation + manual mgmt |
|---|---|---|---|---|
| First Rare | 1.8 m | 1.0 m | 0.6 m | 4.6 m |
| First Gold | 2.6 m | 1.6 m | 1.1 m | 6.1 m |
| Boss 1 | 5.8 m | 3.5 m [3.0-3.8] | 2.3 m | 13 m |
| Boss 2 | 14 m | 9.0 m [8.2-9.7] | 6.4 m | 32 m |
| Boss 3 | 28 m | 17.4 m [15.8-18.4] | 12.2 m | 64 m |
| Boss 4 | 51 m | 29.9 m [27.7-31.6] | 20 m | 2.0 h |
| Boss 5 | 87 m | 48 m | 31 m | — |
| Boss 8 | 5.2 h | 2.7 h [2.4-2.9] | 1.5 h | — |

**First 2 hours** (average player, one seed, waits for 2 shards):

| Time | Event |
|---|---|
| 0:00 | free egg |
| 1:00 | Rare (guaranteed) |
| 1:06 | FLAME |
| 1:24 | first Gold (auto-fuse, 3 Commons) |
| 3:18 | boss 1 + 4th slot |
| 6:24 | first Rainbow |
| 9:24 | boss 2 |
| 16:18 | boss 3 + 5th slot |
| 28:12 | boss 4 |
| 47:48 | boss 5 + 6th slot |
| 51:24 | **Ascension 1** |
| 70:36 | **Ascension 2** |
| 80:12 | **Ascension 3** |
| 96:36 | **Ascension 4** |
| 106:30 | **Ascension 5** |

---

## 10. RETURN SYSTEMS

### 10.1 Luck

"×N luck" = every Rare-or-better weight × N, then renormalised.

| Rarity | Normal | ×2 luck | ×3 luck |
|---|---|---|---|
| Common | 60% | 42.9% | 33.3% |
| Rare | 28% | 40.0% | 46.7% |
| Epic | 10% | 14.3% | 16.7% |
| Legendary | 1.9% | 2.71% | 3.17% |
| Mythic | 0.1% | 0.143% | 0.167% |

### 10.2 Incubator (Plaza; built to be worth coming back for)

- **Start:** pay one egg price of your deepest zone **unlocked in the current run**. It runs **8 h of real time** (counts offline). One slot.
- **The reward is fixed when you START it** (zone = that deepest zone). Ascending while it runs doesn't change it.
- **Collect:**
  1. **one guaranteed Legendary-or-better** spirit of your deepest zone (Legendary 95% / Mythic 5%);
  2. a **20% chance it's a Dream variant:** ×1.25 bonus + the exclusive Dream Wardrobe look (only obtainable here);
  3. **3 Boss Seals** for a boss of your choice (more than 10% of a guaranteed Boss Spirit).
- **Why it matters:** a Legendary normally takes about 53 hatches. Combined with the seals and the Dream look, it advances two long-term collections every day.

### 10.3 Daily streak

Persistent rewards (Tickets = a free hatch of your deepest egg; Charms = ×2 luck for 10 min).

| Day | Reward |
|---|---|
| 1 | 1 Ticket |
| 2 | 1 Charm |
| 3 | 2 Tickets |
| 4 | 1 Charm |
| 5 | 3 Tickets |
| 6 | 2 Charms |
| 7 | 3 Tickets + a ×3-luck Ticket |

A missed day resets the streak.

### 10.4 Rematches + Boss Seals

- **Each beaten boss, once a day:** usually an instant Overpower KO.
- **Each win gives:** +1 Seal, a 1% Boss Spirit chance, and 60 s of that zone's coin income.
- **25 Seals craft the Boss Spirit.** With the incubator's 3 seals a day, one boss can be finished in **about 7 days** instead of 25.

### 10.5 Playtime chests

One every 10 min online (up to 6 a day), each 1 Ticket.

---

## 11. ENDGAME

- **The Infinity Gate:** tier k = 46 T × 1.6ᵏ. These tiers are **required** for Ascension 10+.
- **Leaderboards:** server + global, with the top-3 statues in the Plaza.
- **Halo stars never cap.**
- **Collections:**
  - the Index: 40 zone spirits + 8 Boss Spirits + variants;
  - the Wardrobe: 35 element looks + 8 Signatures + Dream versions;
  - Rainbow Mythics.

---

## 12. QUALITY TARGET (unchanged from v2)

- **Early / mid / end aura specs** at gameplay distance:
  - early: 2.5-4.3 studs, 2 layers, ≤ 40 particles;
  - mid: 5-9 studs, 4-5 layers, ≤ 120;
  - end: 10-15 studs, 6-7 layers + Signature / Mythic extras, ≤ 220.
- **References:**
  - anime power-up auras;
  - Sol's RNG high-rarity auras;
  - Pet Simulator 99 hatch reveals.
- **Budgets** for others' auras: full within 40 studs, reduced at 40-100, a billboard beyond that; ≤ 1,500 particles per client; ≤ 4 overlapping transparent layers. Based on Roblox's performance guidance: https://create.roblox.com/docs/performance-optimization/improve
- **Settings:** others' effects, camera shake, reduced flashing, show others' auras.

---

## 13. PLAYTEST #1 (real content, behaviour first)

**Build:**
- zone 1 + zone 2;
- the stone, charge / release, combo, Overdrive and meditation;
- the zone 1 egg (Light) and the zone 2 egg (Fire);
- spirits orbiting;
- **Auto look upgrades when the first Rare arrives** (the ornament step: Light Common → Light Rare);
- **the first zone-2 hatch shows "NEW LOOK: wear it?"** for Fire. The player can wear it, or pick it later at the Wardrobe Mirror;
- boss 1 with the counter → BLAZE;
- auto-fuse + the Fusion Altar;
- the incubator.

**Two sessions:** day 1 (free play, no instructions), then **day 2** (we just invite them back).

| # | We watch (behaviour) | Pass |
|---|---|---|
| 1 | First PERFECT, unaided | under 30 s |
| 2 | Buys a stone upgrade **without being told** | yes, before boss 1 |
| 3 | Taps on the red flash **without being told** | by the 2nd clash |
| 4 | Keeps playing after boss 1 with no prompt | 10+ min |
| 5 | Opens the zone-2 egg, **chooses to wear the Fire look** (via the prompt or the Mirror) and lets Equip Best upgrade power | yes, without being told |
| 6 | Starts the incubator before leaving day 1 | yes |
| 7 | **Day 2: comes back and collects** the incubator / streak, then keeps playing | yes, 10+ min |
| 8 | Timing behaviour at 10+ min: still aiming for PERFECTs, using Overdrive, idling when tired | not abandoning timing |

**What they say counts less than what they do:**
- secondary: fun 1-10, best and most boring moment;
- an answer only breaks a tie.

**If #1, #3 or #8 fails, fix the input before any art.**
