# AURA CLASH: GAME BIBLE v9 (everything in the game, zone by zone)

**Authority:** this is the master document for every rule and number in the game.
- **Where the numbers come from:** every number comes from `econ/model.py`.
- **Part B is generated:** `econ/make_bible.py` writes it straight from the model, so it can't drift.
- **Checks:** `python tests.py` runs the 28 rule checks.

Change a number = change the model and re-run `python make_bible.py`.

**Other docs:**
- `MONETIZATION.md`: everything sold.
- `CORE-GAME.md`: server authority, saving, tests, playtest, performance.
- `STYLE-SHEET.md`: the look.
- `GAME-PLAN.md`: market and build order.

**v9 owner changes:** bosses are **server raids** (every 15 min, plus a solo Trial any time). Raid rewards need you to **fight actively** (your own blasts in half the raid) **and** deal 8% of the damage, a quarter of the median active fighter's, **or half of what your own build deals** (so active friends always share; taps never do). The endgame is the **Nexus Titan** (an always-respawning raid boss with huge coins), a **Weekly Limited Egg**, and **XP Shards** (food) with **Awakening** to level 50.

**v9 review fixes:**
- **Raid share:** you must be **active** (your own blasts in half the raid's 10-s windows) and deal 8% of the damage, a quarter of the median active fighter's, **or half your own build's output** (active friends of any strength share; a 100× player can't push anyone out; one-tap freeloaders never qualify).
- **Saving:** Robux receipts have a **permanent** ledger (`delivered` only; never cancelled, never pruned); hatch operations count as done only when stored `committed`, never just because the id exists.
- **Limited promise:** "Numbered. On sale for 7 days or until 1,000 sold. Every buyer gets a numbered copy." No substitute items.
- **Regional rules** now cover stored paid coins (two balances), paid-tagged eggs, gifts and eligibility changes (MONETIZATION 17.1).
- **Friction and longevity** (owner): friction rules (1.1) that **don't change** the controls, meditation or quest lists. Sub-goal eggs and paced meditation are simulated; times re-computed (free ~10 h 06, whale ~2 h 59; late eggs +15%). The after-clear plan is in section 25.
- **Pet hits:** +10% of Power per doubling of team Strength, **no hard cap** (the old cap was reached at Strength 25, so upgrades stopped adding hit by zone 2). Pets stay at about 46% of damage.
- **Fusion:** the Fusion Altar stops at ★2 until the Star Forge (zone 5), in the model too.
- **Times are partial-model estimates** (section 27 lists what is and isn't modeled); Huge Storm, Auto-Sell and Mutation Magnet are now modeled for the whale.
- **Serials and Limited sales** got an explicit ledger and recovery protocol (CORE-GAME 2.2): recovery restores only unfinished grants, never traded or fused pets; one purchase can never hold two serials.
- **Paid random items:** the regional rules now cover coin eggs, paid luck, enchant rolls, every random roll and trading (MONETIZATION 17).

**v8 owner changes (3 October 2026):**
- **Zones renamed** with one theme, a made-up "-ora" word plus a place: Lumora Grove, Pyrora Dojo, Glacora Peaks, Voltora Cliffs, Blossora Gardens, Nyxora Rift, Astora Throne, Seraphora Gate, Drakora Sanctum, Aurora Nexus. **Every zone now has a detailed art design** (Part B).
- **The hub** (Lumora Plaza) holds the leaderboards, the store and the rewards (section 12).
- **New machines unlock zone by zone** (section 13): Spirit Codex, Enchant Forge, Spirit Nursery (daycare), Star Forge, Mutation Reactor, Aura Forge, Relic Shrine, Infinity Tower, Ascension Gate.
- **Hatch ×3 is free again after boss 1.**
- **Secret and rarer pets scale with you:** Secret = your best pet, Divine ×10, Impossible ×100, Boundless ×1,000.
- **Bosses are server raids** (owner picked option B; section 9), with an activity + damage rule for rewards, plus the endgame **Nexus Titan**, the **Weekly Limited Egg** and **XP Shards** with Awakening (section 13.12).

**v7 owner changes:**
- **10 zones** (zones 9 and 10 added; now Drakora Sanctum and Aurora Nexus):
  - **free player:** about 11 h for a first run;
  - **whale:** about 3 h 15.
- **New rarity system:** Common, Uncommon, Rare, Epic, Legendary, Mythic, **Secret (1 in 1M+)**, **Divine (1 in 10M+)**, **Impossible (1 in 1B+)**, **Boundless (1 in 1T+, in every egg, a new one every month)**.
  - **Odds:** **every egg has its own odds**; a tier is defined by its odds band.
  - **Serials:** **Secret and rarer pets are serialized.**
- **Luck has no cap.**
- **Natural Mutation Storms** every 45 minutes.
- **Hatching:** Auto-Hatch is free; Hatch ×8 is a pass (in v7, Hatch ×3 was briefly a pass; v8 makes it free after boss 1 again).
- **Monetization v3** (MONETIZATION.md): a single 2× Boost ladder (Luck **and** Power), VIP 399 with hatch speed and Secret luck, +2 slot packs, coin packs, cheaper potions and packs, the Aura Pass at 799.

**Contents:**
- **Part A, how the game works:** sections 1-13 (12 = the hub, 13 = machines and unlocks).
- **Part B, zone by zone:** sections 14-24.
- **Part C, endgame and live updates:** sections 25-26.
- **Part D, money and fairness:** sections 27-28.

---

# PART A: HOW THE GAME WORKS

## 1. The game in one line, and the loop

*"Meditate to grow your aura, hunt crystal monsters with your pets, and become the strongest in the server."*

```
   MEDITATE (calm / AFK)                  HUNT (active)
   at the Shrine → POWER          blast crystal monsters → SHARDS → SELL → COINS
          └──────────► you hunt faster ◄──────────┘
                              │
                     COINS → EGGS → PETS
       every pet makes BOTH halves faster (fights + boosts meditation)
                              │
           all zone quests done + enough Power → BOSS → BOSS SHARDS → next zone
```

**The core rules:**
1. **Power only comes from meditating** (boosts multiply it).
2. **Coins come from selling shards** (monster shards and Boss Shards), **or from coin packs bought with Robux** (owner decision, MONETIZATION.md). Quests never give coins.
3. **Pets come from eggs** (coins, quest rewards, Exclusive Eggs) and speed up both halves.

**On screen:**

| Element | What it is |
|---|---|
| **Power** | your damage and aura size; never lost |
| **Coins** | the only currency |
| **Shard Storm counter** | 18 / 60 |
| **SELL button** | sells your storm |
| **Quest bar** | your current rank quest |
| **Pet bar** | your equipped pets |
| **Buffs, Store and Hourly reward buttons** | MONETIZATION.md |
| **Server leaderboard** | top Power |

### 1.1 Friction rules (owner's biggest concern: the loop must never feel like chores)

Familiar loops work when **every action feels good on its own** and **every upgrade visibly does its own job**. Gorgeous effects can't rescue chores. **These rules don't change the controls (section 2), meditation (section 3) or the quest lists (section 8 and Part B). They only add the items below.** If anything here seems to disagree with those sections, those sections win.

| Risk | Rule (consistent with sections 2, 3 and 8) |
|---|---|
| **Meditation feels like waiting** | **Meditation happens only on a mat** (section 3). To make that easy: a **Meditate button** on the HUD puts you on the **nearest free mat** of your zone (a 1-second teleport, like SELL). **AFK on a mat is full rate,** so Focus taps are an optional bonus. The aura **visibly grows** (a size pulse + "+POWER" pop every ~20 s). The quest bar shows a **Power pace marker**; when your Power falls behind the zone's pace, it suggests "Meditate ~2 min". |
| **Repeated timed blasts feel like busywork** | **The controls are unchanged:** hold to charge, release to fire; a quick tap under 0.5 s does nothing (section 2). What removes busywork: monsters with a **grey "one-hit" bar** (HP at most 0.5 × your Power) **die to any release**, even a too-late one, so they need no timing. Auto-aim moves to the next monster after a kill. Pets clear one-hit monsters too. **PERFECT timing is for green / Big / mutated monsters and bosses.** Every PERFECT has a distinct hit-stop, sound and shard burst. |
| **Quests feel like checklists** | **The quest lists are unchanged** (Focus steps stay 20 s in zone 1 up to 3 min in hard zones, shown with a timer; Focus is an active mini-game, not waiting). Quests count **everything you're already doing**, and the bar shows **estimated minutes left**. **New: a "hatch N" step is split into sub-goals of 5 hatches, and each sub-goal gives a free egg of that zone** (modeled; it's why late egg prices rose 15%). A step never asks you to go back to an old zone. |
| **Upgrades don't feel noticeable** | **Every upgrade shows its own intended benefit** on a 3-second before/after card, and the shop shows the predicted change before you buy. It never pretends an upgrade does something it doesn't. Examples: a pet "Hunting +34% · Meditation +20%"; a bag "100 → 150 shards: 33% fewer trips to SELL"; a mat "Power +25%/s"; a Surge "Overdrive 8 → 10 s". The playtest measures each one against its own job (CORE-GAME 3, #13). |
| **Dead stretches between rewards** | **Target: no stretch longer than ~5 min without a reward** (a hatch, a quest step or sub-goal, a star, a mutated kill, a boss win). The model measures it (`econ/RESULTS.txt` section 9), and so does the session log. |
| **Walking** | SELL and Meditate are teleports; the Shrine, egg and altar sit together; machines have hub teleport pads. |

**What the model says now** (RESULTS section 9, average free player; sub-goal eggs, paced meditation and the +15% egg prices included; all times re-computed):
- **Zones 1-3 pass:** the longest stretch with no reward is about 3-4 min, and the final Power wait is 2-3 min. **This is a model test** (`tests.py`), so the playtest build is covered.
- **Zones 4-10 don't pass yet.** Every hatch is a reward, and hatches land every few minutes even in zone 10. But the **final Power gate is still a 9-19 min wait**, and that's the longest rewardless stretch. The model's player already meditates in ≤ 3-min sittings to stay on pace; the rest comes from the gate itself.
- **Open decision before zones 4-10 ship** (re-tuned in the model, with times re-computed):
  - (a) Set the gate to **0.75× the recommended Power**. The model's average player still wins the clash 98% of the time there (RESULTS section 6). Late egg prices then rise to keep the 10-12 h free target.
  - (b) Or let a share of Power come from kills in that zone. This breaks the "Power only from meditation" rule, so (a) is preferred.
- **Current model times:** free ~10 h 06; whale ~2 h 59 (section 27).

## 2. Controls: the blast (the only attack)

| Platform | Aim | Charge |
|---|---|---|
| PC | the monster under the mouse | hold left mouse button or Space |
| Mobile | auto-aims at the nearest monster in front of you; tap one to switch | hold the big button |
| Gamepad | auto-aim; the right stick switches | hold R2 |

**Hold:** energy gathers in your fists and a ring shrinks around you over 1.2 s. One blast cycle is about 1.4 s.

**Release:**

| Release | Damage |
|---|---|
| Too early (0.5-1.0 s) | 0.6 × Power |
| **PERFECT** (the last 0.18 s, on the glow) | **2 × Power × combo**; a screen kick, and every pet pounces |
| Too late | 0.5 × Power plus a 0.5 s stagger |
| Quick tap (under 0.5 s) | nothing; auto-clickers are useless |

- **Combo:** each PERFECT steps it up: ×1 → 1.25 → 1.5 → 1.75 → 2. Any other release steps it down one level.
- **OVERDRIVE:** 5 PERFECTs in a row give **8 s of real time** (+2 s per Surge level).
  - **Timing:** the 8 s start when the 5th PERFECT lands, and keep running while you walk, sell, hatch or meditate.
  - **Effect:** every release counts as PERFECT at ×2, and also hits **at most 2 monsters next to your target for 50%**. Overkill is lost.
  - **Afterwards:** the combo sits at ×1.5.

## 3. Meditation (Power)

- **The Shrine:** every zone has one in its centre, a ring of glowing **communal** mats with room for a full server. The Sell Altar, egg stands, shop, Fusion Altar and the leaderboard stand around it.
- **Mats only:** you can only meditate on a mat.
- **What it looks like:** you sit and float, your aura rises like a slow flame, and your pets sit in a circle around you. Your Power ticks up and your aura grows.

| Mode | What you do | Multiplier |
|---|---|---|
| AFK | nothing | ×1 |
| **Focus** | a breathing ring grows and shrinks; tap when it's fullest. Good tap = +1 Focus level (max 5); a miss = −1 | up to ×3 (average about ×2.4) |

- **Power per second** = Shrine rate × Focus × (1 + 0.10 × equipped pets' total Strength) × (1 + 0.25 × Mat level) × your Power buffs (MONETIZATION.md).
- **Shrine rates:** **×4 per zone up to zone 4, then ×5 per zone**, from 0.5/s in Lumora Grove to 500,000/s in Aurora Nexus.
- **AFK in game:** full rate. Before Roblox's 20-minute idle kick, the game rejoins you to a server and sits you back on a mat.
- **Offline:** 25% of your AFK rate, for up to 8 h (the Offline+ pass: 50%, 16 h), timed by the server. On return: "WHILE YOU WERE AWAY: +X POWER".

## 4. Hunting (coins)

### 4.1 Crystal monsters
Every zone has **3 monster types**: small (packs of 3-4), middle (pairs) and big (alone).

- **Defeated monsters** crack, freeze and **shatter into shards**.

| Type | HP | Drops | XP to each equipped pet |
|---|---|---|---|
| Small | 20 × 16^(zone−1) | 1 Shard | 1 × 3^(zone−1) |
| Middle (charges a red lane) | 200 × 16^(zone−1) | 3 Shards + 20% chance of a Bright Shard | 4 × 3^(zone−1) |
| Big (slams a red circle) | 2,000 × 16^(zone−1) | 8 Shards + 2 Bright + 10% chance of a Gem | 15 × 3^(zone−1) |

- **Shard values:** Shard 3, Bright 40, Gem 250 in zone 1, **×10 every zone**.
- **Spawns:**
  - packs respawn in 5 s and pairs in 10 s;
  - **3 Big monsters per zone, each respawning in 30 s**;
  - at most about 30 monsters per zone.
- **Green HP bars:** an HP bar turns **green** when you'd beat the monster in about 3 blasts. That's the signal to hunt bigger.
- **They hit back lightly:** if you're knocked out, you reappear at the Shrine and keep everything.
- **Shared monsters, personal loot:** everyone whose hit lands gets their own full drop and quest credit.

### 4.2 Mutations
Each spawn makes **one roll**, so the shown chance is the real chance. 7.6% of spawns are mutated.

| Mutation | Chance | Shard value | HP | Look |
|---|---|---|---|---|
| Gold | 1 in 25 | ×5 | ×2 | gold crystals, a sparkle trail |
| Fire | 1 in 60 | ×10 | ×3 | burning crystals |
| Frost | 1 in 60 | ×10 | ×3 | icy crystals, mist |
| Rainbow | 1 in 400 | ×25 | ×4 | rainbow crystals + a light beam across the zone |
| Void | 1 in 2,000 | ×75 | ×6 | dark crystals that warp the air |
| Celestial | 1 in 10,000 | ×250 | ×8 | starry crystals, a halo, a server announcement |

- **Natural Mutation Storm:** **for 5 minutes every 45 minutes**, a storm rolls over every server. The sky darkens, the music changes, and **all mutation chances are ×2**, announced with a countdown. Players can also buy one (99 R$, MONETIZATION.md).
- **The shards keep the mutation:** they spin glowing in your storm, take 1 bag slot each, and sell with a bigger pop.
- **Tutorial:** a Gold Shardling is guaranteed about 1 minute in.

### 4.3 The Shard Storm (your bag) and SELL
- **The storm:** your shards spin around you, from dust to a ring to a tornado. When full, it turns **gold and pulses**: monsters still give XP, but drop no shards.
- **Capacity:** 60 to 500 (the Bag upgrades in section 7; the Huge Storm pass doubles it).
- **Lag-proof:** at most 12 shard meshes and 2 emitters for you, 1 emitter for others, plus a Low effects setting.
- **SELL** (button / G / gamepad Y; not in boss fights): teleport to the altar, coins roll up, teleport back (about 3 s). **"Stay"** keeps you at the Shrine. The Auto-Sell pass sells when full without the teleport.

## 5. Pets

### 5.1 The rarity tiers (a tier is defined by its odds)

Every egg has its own pets and its own odds (see each zone). **A pet's tier comes from its chance:**

| Tier | Chance band | Base Strength |
|---|---|---|
| Common | 25% or more | 1 |
| Uncommon | 10% to 25% | 1.5 |
| Rare | 2% to 10% | 2.5 |
| Epic | 0.5% to 2% | 4 |
| Legendary | 1 in 200 to 1 in 10,000 | 10 |
| Mythic | 1 in 10,000 to 1 in 1M | 25 |
| **Secret** | **1 in 1M+** | **= your best pet** |
| **Divine** | **1 in 10M+** | **10× your best pet** |
| **Impossible** | **1 in 1B+** | **100× your best pet** |
| **Boundless** | **1 in 1T+** | **1,000× your best pet** |

- **Egg layouts differ:** odd zones have **two Commons** (e.g. 35% / 34%); even zones have **three Commons** (e.g. 30% / 28% / 26%). Every zone has its own numbers for every tier.
- **Secret and rarer scale with you (owner):** their Strength is always measured against **your best normal pet** (your strongest Common-to-Mythic pet, including its zone, stars, level and pet mutation):
  - **Secret:** the same as your best pet;
  - **Divine:** 10×;
  - **Impossible:** 100×;
  - **Boundless:** 1,000×.

  This is live: when you get a better pet, all your Secret+ pets grow with it, so a Secret hatched in zone 1 is still top-tier in zone 10. Their own stars multiply on top; they don't need levels.
- **Boundless:** **every egg in the game** (zone eggs and Exclusive Eggs) has a 1 in 1T Boundless line. **A new Boundless pet every month,** the same in every egg.
- **Serials:** **every Secret, Divine, Impossible and Boundless pet is serialized**, shown on the card and over the pet ("Aurora Dragon #12 of 37").
- **Luck** (the 2× Boost ladder, potions, server boosts, group; MONETIZATION.md):
  - **No cap.** It works **hardest on the rarest tiers**: Legendary gets luck^0.3, Mythic luck^0.5, Secret luck^0.8, Divine luck^0.9, and Impossible and Boundless the full luck.
  - **Secret luck** (2× Secret Luck pass, VIP) multiplies Secret and rarer on top.
  - **Common to Epic** share what's left in their own ratio.
  - **The odds always add to 100%,** so Legendary-and-up together can never pass 90% of hatches. That's arithmetic, not a luck cap.
- **The egg card always shows the real odds at your current luck.**

### 5.2 Strength
**Strength (Common to Mythic) = tier base × zone (×2 for every zone after the first; a zone-10 pet is ×512) × stars × level × pet mutation (section 13.6) × Shiny 1.5 (section 13.4) × Might enchant (section 13.3).** Secret+ follow 5.1. The pet card shows only the final number.

### 5.3 What pets do

| Job | Rule |
|---|---|
| **Fight** | the team hits your target every 1.5 s (each pet with its own move; on your PERFECT they all strike at once) for **10% of your Power per doubling of the team's Strength**: Strength 1 → 10%, 3 → 20%, 7 → 30%, 63 → 60%, ~1,000 → 100%, ~1M → 200%. **No hard cap**, so a better pet always hits harder, but each doubling adds the same +10%, so pets stay below your blasts (model: 46% of damage). **The pet card shows both payoffs of an upgrade:** "+X% team hit" and "+Y% meditation" |
| **Tank** | monsters attack whatever is closest; a hit pet is **dazed for 2 s**. **Pets never die** |
| **Meditate** | **+10% meditation per point of equipped Strength.** No cap |

**Behaviour:**
- they follow you in a loose pack;
- they relax when you stand still;
- they snap into a battle stance when you charge;
- they attack only from your first blast on a target until it dies;
- they sit in a circle when you meditate.

- **Slots:**
  - **3** at the start;
  - **+7 from quests** (zones 1-5), for **10** in total;
  - **+1** with VIP;
  - **+2 per Slot Pack** (199 R$, up to 10 packs = +20).

  The maximum is **31**. **Equip Best** fills them by Strength.
- **Inventory:** 250 pets. **Auto-delete** (on by default for unequipped low tiers of earlier zones) and locks.

### 5.4 Stars (fusion), up to 5

| Stars | none | ★ | ★★ | ★★★ | ★★★★ | ★★★★★ |
|---|---|---|---|---|---|---|
| Strength | ×1 | ×2 | ×4 | ×8 | ×16 | ×32 |
| Copies of the same pet | 1 | 3 | 9 | 27 | 81 | 243 |

- **How it works:** 3 copies with the same stars → 1 of the next star. The new pet keeps the highest level, and **fusion never lowers your team**.
- **Looks:** each star adds a visible upgrade, up to a full animated halo at ★5.
- **Auto-fuse** (default): unequipped Commons, Uncommons and Rares.
- **Fusion Altar:** Epic and up.

### 5.5 Levels and XP (automatic)
- **XP:** every monster you defeat gives XP to **every equipped pet**: small 1, middle 4, big 15 in zone 1, **×3 every zone**.
- **Level cost:** n → n+1 costs 10 × n × 3^(pet's zone − 1) XP.
- **Maximum:** level 30 (+5% Strength per level, ×2.45 at level 30).

## 6. Eggs and hatching

- **Where:** each zone's egg stand sits by its Shrine.
- **Hatch modes:** Hatch ×1 and **Auto-Hatch are free**, and **Hatch ×3 unlocks free after boss 1**. **Hatch ×8 (399 R$)** is a pass, and the **2× Hatch Speed** pass (and VIP ×1.5) speeds up the animations.
- **Guarantees** (saved): the 1st hatch ever is the Light Fox; the 3rd hatch is a Rare (or better) if you have none.
- **The crack colour always shows the true tier.** No fake near-misses.

| Tier | Hatch |
|---|---|
| Common / Uncommon | a pop and a puff (1.5 s) |
| Rare | blue cracks, a glow burst (2 s) |
| Epic | purple cracks, levitation, lightning (3 s) |
| Legendary | gold cracks, the sky dims, a gold pillar, a **server announcement** (4 s) |
| Mythic | **cutscene** (6 s): the world freezes, a vortex, the pet forms from energy, a server announcement |
| **Secret** | **cutscene** (8 s): the screen cracks, silence, "???", the server's sky changes, a **global announcement**, the **serial number** reveal |
| **Divine** | **cutscene** (10 s): a golden sky floods **every server**, wings of light, a global announcement, the serial |
| **Impossible** | **cutscene** (12 s): reality shatters; **time freezes in every server** for the announcement; a permanent "IMPOSSIBLE" title; a statue at the Aurora Nexus |
| **Boundless** | **cutscene** (15 s): a **whole-game event**: every server's sky becomes that month's Boundless; a permanent animated "BOUNDLESS" title; a statue at spawn; the serial (the first of the month is #1) |

## 7. The shop (by every Shrine; account-wide upgrades)

**Bag** (storm capacity):

| Level | 1 | 2 | 3 | 4 | 5 | 6 | 7 |
|---|---|---|---|---|---|---|---|
| Capacity (from 60) | 100 | 150 | 200 | 250 | 300 | 400 | 500 |
| Price | 50 | 250 | 3K | 10K | 100K | 2M | 50M |

**Meditation Mat** (+25% per level):

| Level | 1 | 2 | 3 | 4 | 5 | 6 | 7 | 8 | 9 | 10 | 11 | 12 |
|---|---|---|---|---|---|---|---|---|---|---|---|---|
| Price | 100 | 400 | 4K | 12K | 150K | 1M | 20M | 400M | 10B | 250B | 4T | 60T |

**Surge** (+2 s Overdrive per level):

| Level | 1 | 2 | 3 | 4 | 5 |
|---|---|---|---|---|---|
| Price | 300 | 5K | 200K | 30M | 5B |

**Eggs:** priced per zone (see each zone). K = thousand, M = million, B = billion, T = trillion.

## 8. Rank quests

- **The gate:** a zone's boss gate opens when **all its quests are done**. The last quest is always "Reach X Power".
- **Rewards:** pet slots until you have 10, otherwise a free egg of that zone. Never coins or Power.
- **Difficulty:**

| Zones | Difficulty | Quests per zone |
|---|---|---|
| 1-3 | **very easy** | 5-6 |
| 4-6 | **easy** | 7 |
| 7-8 | **medium** | 8 |
| 9-10 | **hard** | 9 |

  (You wrote "very easy for the first 4, easy for 4-6", so zone 4 is easy. With 10 zones, medium now covers 7-8 and hard covers 9-10.)

## 9. Bosses: server raids (owner chose option B)

**Every zone boss is a server raid.**
- **When:** the boss spawns in the zone's arena **every 15 minutes** (a countdown shows on the HUD and over the arena). Everyone in the zone fights it together: dozens of auras, beams and pets at once, the biggest VFX moment in the game.
- **No group?** A **solo Trial** of the same boss (scaled to one player) can be started any time at the arena gate, so nobody is ever stuck waiting.
- **Your first win** of a zone's boss (raid or Trial) gives the **form**, the **Boss Shards** and **the next zone**. Later raids give Relic Shards, Enchant Crystals and a smaller Boss Shard drop.
- **HP:** scales with the number of fighters (about ×1 per player), so a full server and a small group both get a 60-90 s fight.

**Reward sharing (owner): you must do real damage.**
- **The rule:** you share a raid's rewards if you were **active** AND you did **any one** of:
  - **8% of the total damage**;
  - **a quarter of what the median active fighter dealt**;
  - **half of what your own build deals** in the time you fought (the server knows your Power and team, so it knows what "fighting at your own strength" looks like).
- **Active** = **your own blasts** (pets don't count) landed on the boss in **at least half of the raid's 10-second windows**, and in at least 3 of them (every window, if the raid was shorter). Fighting half the raid counts, so a mid-raid joiner qualifies; a last-10-seconds join, a single tap or a one-shot-then-AFK doesn't.
- **What this guarantees** (all model tests):
  - **active friends always share,** whatever their strength: two friends at 1,000 vs 1 damage who both fight the whole raid → both paid;
  - **freeloaders never do:** {strong 1,000, A 1, B 1} where A and B only tapped → only the strong player; someone in every window but dealing a tenth of what their own build can → not paid;
  - **a huge player can't push others out:** 20 active fighters, one at 100× → all 20; strengths from 1× to 100× plus 30 tappers → all 20 fighters, no tapper;
  - **taps can't drag the bar down:** the median counts active fighters only.
- The HUD shows a **"Reward share"** meter: an activity ring that fills as your blasts land in each window, and a ✔ once you qualify, so nobody is surprised.
- **So:** one tap with weak pets never qualifies, and everyone who really fights does. A bar on the HUD shows your share live.
- **Normal monsters are different:** any hit that lands still gives you the drop (section 4.1).

**The fight (raid and Trial):**
- **HP:** 6 armor plates and a body, scaled to the recommended Power R (and to the fighters).
- **Phases:**
  1. **Armor:** blast the plates off while walking out of the red slam circles. Each hit you take costs 5% of **your** starting beam meter.
  2. **Rage:** the boss's own mechanic (see each zone).
  3. **Beam clash:** **everyone's beams** push against the boss's beam on one shared meter:
     - each player's PERFECT +12% ÷ the number of fighters, other releases +6% ÷ the number of fighters;
     - tap the red flash: +5% (a miss: −8%) ÷ the number of fighters;
     - the boss pushes back 3%/s at R (×R ÷ the group's average Power, up to ×4);
     - win at 100%.

  The model simulates the solo Trial; a group raid is at least as fast.

**Model win rates** (2 hits taken):

| Power ÷ R | 0.5 | 0.75 | 1.0 | 1.5 |
|---|---|---|---|---|
| weak timing | 0% | 28% | 79% | 100% |
| average | 23% | 98% | 100% | 100% |
| strong | 97% | 100% | 100% | 100% |

- **First win:** you **transform** to the zone's form; **Boss Shards** (worth about 3 eggs of the next zone; they don't count against the bag cap) burst into your storm, and you sell them at that zone's altar; the next zone opens.
- **Lose:** you're told exactly why; retry in the next raid or start a Trial.

## 10. Your aura

- **Size:** radius = 2.5 + 0.5 × log10(Power) studs.

| Power | 10 | 300 | 10K | 1M | 1B | 1T | 30T |
|---|---|---|---|---|---|---|---|
| Radius (studs) | 3.0 | 3.7 | 4.5 | 5.5 | 7.0 | 8.5 | 9.2 |

- **Forms** (one per boss):

| Start | Z1 | Z2 | Z3 | Z4 | Z5 | Z6 | Z7 | Z8 | Z9 | Z10 |
|---|---|---|---|---|---|---|---|---|---|---|
| Spark | BLAZE | INFERNO | GLACIER | TEMPEST | BLOOM | ECLIPSE | COSMIC | RADIANT | DRAGONSOUL | **ASCENDED** |

- **Transformation:** a 2.5 s cutscene, a shockwave and the form's name.

## 11. HUD, settings, tutorial

- **HUD:**
  - Power, coins, the storm counter, SELL;
  - the blast button (mobile), the quest bar, the pet bar;
  - the **Buffs** button (every active boost and its timer);
  - the **R$ Store** button and the **Hourly Reward** bar;
  - the Focus ring, green HP bars, mutation names and the Mutation Storm countdown;
  - the "WHILE YOU WERE AWAY" card;
  - the **zone teleporter** (a tap opens any unlocked zone or machine);
  - everyone spawns in **Lumora Plaza** (section 12).
- **Settings:** Low effects, others' effects, show others' pets, camera shake, reduced flashing.
- **Tutorial:**
  - a pulsing hand points at the one next thing: MEDITATE → a Shardling → SELL → the egg → the quest bar;
  - labels are 1-3 words;
  - progress is saved;
  - the first meditation is a fixed +40 Power over 20 s.

## 12. The hub: Lumora Plaza (in Lumora Grove)

Everyone **spawns here**, and it's the social heart of the game. It's a raised round terrace around the zone 1 Shrine, under the glowing Lumora Tree.

| Ring | What's there |
|---|---|
| **Centre** | the Shrine's communal mats; the Sell Altar, shop, Lumora egg stand and Fusion Altar around it |
| **Leaderboard Wall** (north) | 6 big glowing boards, each switchable between **this server** and **global**: **Top Power · Most Secret+ pets · Boundless owners** (all time, with serials) **· Most eggs hatched · Highest Infinity Tower floor · Most mutated monsters defeated** |
| **Statues** (in front of the wall) | the global **top 3 Power** (refreshed daily) and **every Boundless owner of the month**, as glowing statues with their aura |
| **Store row** (east) | the Daily Exclusive Egg stand, the Shop Exclusive Egg stand (this month's pets spinning on pedestals) and the Verity stand (live counter) |
| **Rewards corner** (west) | the Daily Rewards pedestal, the Group Chest, the Aura Pass board, and the hourly-reward claim |
| **Teleporter ring** (south) | one portal per unlocked zone and one pad per unlocked machine (section 13) |
| **Trading booths** | open after boss 2 (section 13.11) |
| **Sky screen** | a giant hologram of this month's Boundless; it lights up the whole plaza when someone hatches one |

## 13. Machines and unlocks (what's new, and when)

New systems **unlock when you enter each new zone** (the Pet Simulator "new machine" pattern), so there's always something new, and each zone feels like a step up.

| Zone (unlocks on entering) | New thing | Where | Average free player gets it at |
|---|---|---|---|
| 1 Lumora Grove | the Shrine, shop, eggs, Fusion Altar (★1-★2), the hub | Lumora Plaza | 0:00 |
| 2 Pyrora Dojo | **Hatch ×3** (after boss 1), **Spirit Codex** | the Scroll Hall | ~5 min |
| 3 Glacora Peaks | **Enchant Forge**; **trading** in the hub | the Ice Forge | ~21 min |
| 4 Voltora Cliffs | **Spirit Nursery** (daycare) | the Sky Nest | ~41 min |
| 5 Blossora Gardens | **Star Forge** (★3-★5) | the Lantern Shrine | ~1 h 10 |
| 6 Nyxora Rift | **Mutation Reactor** | the Rift Reactor | ~1 h 50 |
| 7 Astora Throne | **Aura Forge** | the Star Anvil | ~2 h 34 |
| 8 Seraphora Gate | **Relic Shrine** | the Halo Vault | ~3 h 50 |
| 9 Drakora Sanctum | **Infinity Tower** | the Dragon Spire | ~5 h 17 |
| 10 Aurora Nexus | **Ascension Gate**, Boundless Hall | the Nexus Core | ~7 h 25 |
| After beating zone 10 | **the Nexus Titan** (an always-respawning raid boss), the **Weekly Limited Egg**, **XP Shards** and **Awakening** | the Heart of Aura | ~10 h 07 |

Every machine also gets a pad on the hub's teleporter ring once unlocked.

> **Model note:** the model doesn't simulate the Codex, enchants, the Nursery, pet mutations or relics yet. They make players stronger, so they'll shorten the times in Part B a little. Each one gets added to the model (and the gates re-tuned) when it's built.

### 13.1 Fusion Altar (zone 1) and Star Forge (zone 5)
- **Fusion Altar:** 3 copies → the next star, up to ★2. It sits by every Shrine.
- **Star Forge** (Blossora Gardens): unlocks ★3 to ★5. Five stone lanterns light up one by one as the stars are added; a ★5 fusion makes a pillar of light over the whole zone.

### 13.2 Spirit Codex (zone 2: the pet index)
- **What it is:** a book of every pet in the game. Pets you've owned show in full colour; the rest are silhouettes, and Secret+ show "???".
- **Rewards:**
  - **completing a zone's Common-to-Mythic page:** a permanent **+3% luck** and that zone's **Codex badge** (shown on your nameplate);
  - **every 10 new species:** a free **Daily Exclusive Egg**;
  - **owning any Secret+:** a gold page frame, with your serial.
- **Why:** a collection goal for every egg, so players keep hatching in earlier zones too.

### 13.3 Enchant Forge (zone 3)
- **Slots:** every pet has **1 enchant slot** (Mythic and Exclusive pets: 2; Secret+: 3).
- **Enchant Crystals** pay for enchants. They come from:
  - Big monsters (3% each; ×3 for mutated ones);
  - every first boss win (10);
  - Codex rewards and the Infinity Tower.
- **Rolling:** 1 crystal rolls a random enchant type and tier. Tier odds: I 50%, II 28%, III 15%, IV 6%, V 1%. Re-rolling replaces it. **Locking** one enchant (5 crystals) keeps it while you re-roll the others.
- **Enchants** (team bonuses while the pet is equipped; they add up):

| Enchant | I | II | III | IV | V |
|---|---|---|---|---|---|
| **Might** (this pet's Strength) | +5% | +10% | +15% | +25% | +40% |
| **Fortune** (luck) | +2% | +4% | +6% | +9% | +13% |
| **Greed** (coins) | +3% | +6% | +9% | +14% | +20% |
| **Wisdom** (pet XP) | +5% | +10% | +15% | +25% | +40% |
| **Calm** (meditation) | +3% | +6% | +10% | +15% | +22% |
| **Hunter** (mutation chance) | +2% | +4% | +6% | +9% | +13% |

- **Rare enchants** (1 in 200 rolls, always tier V): **Overdrive** (+1 s Overdrive), **Midas** (Gold mutations ×1.5 as likely), **Secret Sense** (+10% Secret luck).
- **Look:** an enchanted pet gets a rune circling it in the enchant's colour (Might red, Fortune green, Greed gold, Wisdom blue, Calm white, Hunter violet). Tier V runes are animated and leave a trail.

### 13.4 Spirit Nursery (zone 4: daycare)
- **Where:** the Sky Nest, a cosy cloud nest on a Voltora cliff, with a pad in the hub.
- **How it works:** put up to **3 unequipped pets** in the nest for **1, 4, 8 or 24 hours** (real time; offline counts).
- **What comes back:**
  - **XP:** as if the pet had hunted with you for half that time, so it levels up;
  - **Shiny chance:** each full hour has a **1.5% chance the pet comes back Shiny** (about 30% after 24 h). Shiny means **×1.5 Strength**, a sparkle coat and a "Shiny" tag. Shiny copies only fuse with Shiny copies;
  - **Nursery gift** (stays of 8 h or more): a potion, and a 5% chance of a Daily Exclusive Egg.
- **Rules:** pets in the nest can't be equipped or fused. A "your pets are ready" notification brings players back, which makes it a retention hook.

### 13.5 Star Forge (zone 5)
See 13.1.

### 13.6 Mutation Reactor (zone 6: pet mutations)
- **The choice:** mutated shards can now be **kept instead of sold**. The SELL screen gets a "Keep" toggle per mutation (Rainbow and rarer are kept by default) and they go to your **Shard Vault**. Sell for coins, or keep them for the Reactor: a real decision.
- **Infuse a pet** with a mutation:

| Mutation | Shards needed | Pet Strength | Look |
|---|---|---|---|
| Gold | 50 Gold shards | ×1.25 | a gold coat |
| Fire / Frost | 25 | ×1.5 | a flaming / icy coat |
| Rainbow | 10 | ×2 | a shifting rainbow coat |
| Void | 3 | ×3 | a dark coat with a starfield |
| Celestial | 1 | ×5 | a starry coat with a halo |

- **Rules:** one mutation per pet; a new one replaces the old.
- **Why:** this multiplies pet variety (every pet × 6 looks), the **visual flex** players chase.

### 13.7 Aura Forge (zone 7)
- **Customize your aura:** combine any unlocked form's **shape**, **colour** and **flame style**. Cosmetic only.
- **Earned aura colours:**
  - **Codex:** every completed zone page unlocks that zone's colour;
  - **Rainbow:** defeat 100 Rainbow monsters;
  - **Void:** defeat 25 Void monsters;
  - **Celestial:** defeat 1 Celestial monster.

### 13.8 Relic Shrine (zone 8)
- **What relics are:** every boss has a **Relic**. On unlocking the Shrine you get the relics of every boss you've beaten. **Equip 3** (the final boss's relic adds a 4th slot).

| Relic | Bonus |
|---|---|
| Golem Core | +15% damage to Big monsters |
| Oni Horn | Overdrive +1 s |
| Wyrm Scale | +5% luck |
| Roc Feather | +15% move speed |
| Ronin Blade | +10% PERFECT damage |
| Leviathan Eye | +5% mutation chance |
| Emperor's Star | +10% Boss Shards |
| Archangel Halo | +10% meditation |
| Dragon Pearl | +10% coins |
| Ascendant Heart | +1 relic slot |

- **Levels I-V:** boss **replays** drop Relic Shards that level relics up (each level adds the base bonus again), so replays are worth doing.
- **Look:** equipped relics float around you as small glowing objects.

### 13.9 Infinity Tower (zone 9)
- **What it is:** an endless tower in the Dragon Spire. Each floor is a short fight against an earlier boss, **×1.5 tougher per floor**.
- **Rewards per floor:** Enchant Crystals and potions, plus a **Daily Exclusive Egg every 10 floors**.
- **Leaderboard:** "Highest floor", on the hub wall.

### 13.10 Ascension Gate (zone 10: rebirth)
- **Ascending:** after beating the Ascendant, you can **Ascend**:
  - **reset:** Power, coins, zones and quests;
  - **keep:** pets, enchants, relics, the Codex and everything bought.
- **Each Ascension gives:**
  - **Ascension Stars:** a **permanent ×1.5 Power and +25% luck** each;
  - a new **halo tier**;
  - Ascended-only cosmetics.
- **The second run is much faster,** and it's where long-term players and the weekly zone updates live. Tuned in the model before it's built.

### 13.12 The endgame in Aurora Nexus (owner): the Nexus Titan, the Weekly Limited Egg, XP Shards

This is what players do while they wait for the weekly update.

**The Nexus Titan: an always-respawning raid boss.**
- **When:** after the Ascendant falls, the **Nexus Titan** (a colossal crystal giant made of every element) takes over the Heart of Aura. It **respawns 60 s after each death**, around the clock.
- **The fight:** a raid like any boss (section 9), with the same reward-share rule. Its HP and power grow each week with the update.
- **Rewards for every qualifying player:**
  - **huge Boss Shards:** about 3 eggs' worth of Aurora Nexus coins per kill, so a full storm of coins every few minutes;
  - **XP Shards** (below);
  - **Enchant Crystals** and **Relic Shards**;
  - a **weekly damage leaderboard** on the hub wall.

**The Weekly Limited Egg.**
- **Where:** in Aurora Nexus, for one week only. It disappears when the next update lands, and a new one arrives with it.
- **Cost:** **coins**, so the Titan's coins have something to buy.
- **Its pets:** every pet is **Limited (Week N)**, never available again, with Strength **×1.5 the Aurora Nexus table**, a preview of the next zone. It has its own table (all 10 tiers, plus the Boundless line), and **Secret+ from it are serialized "Week N #x"**.
- **Why:** a reason to grind the Titan every day of the week, and a weekly status item.

**XP Shards: pet food, back for the endgame.**
- **Where they come from:** the Titan (and every raid after a zone's first clear). They go into your **food pouch**, not the storm.
- **Feeding:** tap FEED on any pet (or Feed All). One XP Shard = a big chunk of XP that grows with each zone.
- **What they're for:**
  - **Instant levels:** new pets from the newest egg (or the Weekly Limited Egg) jump to level 30 fast, so you can min-max between updates.
  - **Awakening (levels 31-50):** **only XP Shards** can push a pet past level 30. Each Awakened level is +2% Strength (level 50 = ×1.4 on top of level 30), and the pet gets an Awakened glow that brightens every 5 levels.
- **XP from kills** (section 5.5) still works as before, up to level 30.

### 13.11 Trading (after boss 2, in the hub)
- **How it works:** a safe trade window. Both players confirm, there's a 3 s lock, and the server validates and logs every trade.
- **Rules:**
  - items for items only (no Robux);
  - **closed for players whose region doesn't allow trading paid items** (`IsPaidItemTradingAllowed` false; MONETIZATION 17);
  - Secret+ serials stay with the pet;
  - Limited serials show in the trade window.

---

# PART B: ZONE BY ZONE

**What "at the boss" means:** each zone ends with the average **free** player's state at that boss win. These are model medians, solo, so they're tuning targets, **not promises**.

<!-- ZONES:START (generated by econ/make_bible.py; don't edit by hand) -->

## 14. ZONE 1: LUMORA GROVE (Light) · quests: very easy

**The feel:** a sunrise meadow where everything glows softly: safe, welcoming, wow-on-arrival.

| Design | |
|---|---|
| Layout | **Lumora Plaza** (the game's hub) sits on a raised round terrace in the centre around the Shrine. Three hunting meadows fan out: **Shardling Meadow** (east: flower fields, gentle slopes), **Boar Hollow** (north: rolling hills with crystal-capped stones), **Brute Ridge** (west: a cliff ledge where the 3 Brutes stand against the sky). A path of glowing stepping stones leads south to the boss arena, the **Sunstone Ring**. The portal to Pyrora Dojo is a giant crystal archway, dark until the Golem falls, then it ignites orange |
| Landmarks | the **Lumora Tree**: a huge tree behind the Shrine whose leaves are light crystals, slowly dropping glowing petals; floating paper-lantern lights; a **waterfall of light** pouring off a floating rock into a pond |
| Materials | mint plastic grass mounds, cream stone paths with gold trim, round pastel rocks capped with cyan / violet crystals, soft white wood |
| Sky + light | a warm sunrise gradient (peach → sky blue), big soft clouds, god-rays through the Lumora Tree |
| Ambient VFX | drifting light motes, butterflies made of light, crystals pulsing gently, petals |
| Sound + music | birdsong and soft wind chimes; bright anime lo-fi music |
| Mutation Storm here | **Prism Shower:** rainbow light rain, the sky turns pastel rainbow |
| **New in this zone** | the Shrine, Sell Altar, shop, egg stand, **Fusion Altar** (★1-★2), and **the hub** (section 12): leaderboards, the store, rewards, teleporter |

**Numbers:** Shrine 0.5 Power/s · Egg 60 coins.

| Monster | Look | HP | Behaviour | Drops (coins) | XP per kill |
|---|---|---|---|---|---|
| **Shardling** | a round jelly slime with crystal spikes and huge cute eyes | 20 | hops in packs | 1 Shard (3) | 1 |
| **Crystal Boar** | a chunky boar with crystal tusks and glowing back plates | 200 | charges down a red lane | 3 Shards + 20% Bright (40) | 4 |
| **Crag Brute** | a rock gorilla-golem with crystal shoulders and a mossy back | 2,000 | slams a red circle | 8 Shards + 2 Bright + 10% Gem (250) | 15 |

**Egg: Lumora Grove pets** (Strength ×1; every Secret-or-rarer pet is serialized):

| Pet | Tier | Chance | Strength |
|---|---|---|---|
| Light Fox | Common | 35.05% | 1 |
| Glow Bunny | Common | 34% | 1 |
| Prism Owl | Uncommon | 18% | 1.5 |
| Sun Pup | Rare | 8% | 2.5 |
| Halo Lynx | Rare | 3.5% | 2.5 |
| Dawn Griffin | Epic | 1.2% | 4 |
| Solar Kirin | Legendary | 1 in 400 | 10 |
| Radiant Pegasus | Mythic | 1 in 25K | 25 |
| ??? (Aurora Dragon) | Secret | 1 in 2.5M | = your best pet |
| ??? (Prism Archangel) | Divine | 1 in 100M | 10× your best pet |
| ??? (Lumen the Endless) | Impossible | 1 in 10B | 100× your best pet |
| **Boundless** (this month's, the same in every egg) | Boundless | 1 in 1T | 1,000× your best pet |

**Quests:**

| # | Quest | Reward |
|---|---|---|
| 1 | Focus meditate for 20 s | +1 pet slot (4) |
| 2 | Defeat 20 Shardlings | free egg |
| 3 | Hatch 5 eggs here | free egg |
| 4 | Defeat 10 Crystal Boars | +1 pet slot (5) |
| 5 | Reach 300 Power | **boss gate opens** |

**Boss: STONE GOLEM** (recommended Power 300): a 3-storey rock giant with glowing cyan cracks and crystal plates on its chest and shoulders (the weak points). **Arena:** the Sunstone Ring, a hilltop stone circle at sunrise.
- **HP:** plates 6 × 990; body 6,000.
- **Rage:** rolls boulders down red lanes (0.8 s warning): dodge sideways, or **PERFECT a boulder to blast it back** for big damage.
- **Reward:** form **BLAZE** (orange anime flames); **Boss Shards worth 5,100 coins** (about 3 Pyrora Dojo eggs).

**The first 8 minutes** (one model run close to the median, `econ` seed 15):

| Time | What happens | Power |
|---|---|---|
| 0:00-0:20 | Spawn at the Shrine; a "MEDITATE" hand; the tutorial meditation | 10 → 50 |
| 0:20 | The hand points at the Shardlings; PERFECTs one-shot them | 50 |
| ~0:55 | First **Overdrive** (it varies: 0:30-3:30 depending on timing luck) | 50 |
| ~1:00 | The guaranteed **Gold Shardling**: "MUTATION!" | 50 |
| ~1:55 | Storm full, so the first **SELL** (about 850 coins). The first sell stays at the Shrine | 50 |
| ~2:00 | Eggs: the **Light Fox**, then the guaranteed Rare. **Bag Lv1 + Lv2, Mat Lv1** | 50 |
| ~2:05 | First ★ at the Fusion Altar | 50 |
| ~2:30 | Quest 1: Focus 20 s → +1 slot | ~100 |
| ~2:50 | First pet level-up (XP from kills) | ~100 |
| ~3:10 | Quests 2, 3 and 4 done (Shardlings, hatches, Boars) → eggs and +1 slot | ~100 |
| 3:10-4:50 | Quest 5: **sit and Focus meditate about 1.5 min** | ~315 |
| 4:50-5:30 | **Stone Golem** | |
| ~5:30 | **BLAZE.** Boss Shards sell for 4,500 → Bag Lv3, Mat Lv2, Surge Lv1. **Hatch ×3 unlocks.** Pyrora Dojo opens | ~315 |
| 5:35-7:05 | Zone 2 quest 1: Focus 60 s at the ×4 Shrine | ~1,700 |
| 7:05+ | Ember Slimes; Fire eggs (1,700) | |

**At the boss** (average free player, median):

| Time | Power | Slots | Best pet | Best stars | Best level | Bag |
|---|---|---|---|---|---|---|
| **~5 min** | 314 | 5 | Rare | ★★ | 2 | 200 |

## 15. ZONE 2: PYRORA DOJO (Fire) · quests: very easy

**The feel:** a dojo built inside a volcano: energetic, dramatic, glowing from below.

| Design | |
|---|---|
| Layout | The **Shrine** is a fire-meditation dais in the dojo courtyard. Hunting grounds: **Ember Terraces** (stepped lava terraces like rice paddies), **Hound Canyon** (an obsidian canyon with lava rivers and wooden rope bridges), **Brute Forge** (an ancient forge of giant anvils). The boss arena, **Caldera Ring**, is a fighting stage floating on a lava lake |
| Landmarks | a 5-storey **pagoda** hung with glowing orange lanterns; a giant bronze bell that rings on every boss win; lava falls down the crater walls |
| Materials | warm terracotta stone, **glossy black obsidian**, red lacquer wood; lava is a glossy orange-to-yellow gradient plastic (never realistic) |
| Sky + light | dusk orange-purple, ash flakes, the volcano's glow lighting everything from below |
| Ambient VFX | embers rising, heat shimmer over lava, lanterns flickering, lava bubbles popping |
| Sound + music | taiko drums and crackling fire; energetic taiko lo-fi music |
| Mutation Storm here | **Eruption:** the volcano erupts, harmless lava bombs arc across the sky |
| **New in this zone** | **Hatch ×3 (free)** and the **Spirit Codex** (the pet index; in the dojo's Scroll Hall) |

**Numbers:** Shrine 2 Power/s · Egg 1,700 coins.

| Monster | Look | HP | Behaviour | Drops (coins) | XP per kill |
|---|---|---|---|---|---|
| **Ember Slime** | a molten blob with an obsidian crust | 320 | packs; leaves short burning puddles | 1 Shard (30) | 3 |
| **Lava Hound** | a dog with magma veins and a flame mane | 3,200 | charges down a red lane | 3 Shards + 20% Bright (400) | 12 |
| **Obsidian Brute** | a sumo-sized obsidian giant with lava cracks | 32K | slams a red circle | 8 Shards + 2 Bright + 10% Gem (2,500) | 45 |

**Egg: Pyrora Dojo pets** (Strength ×2; every Secret-or-rarer pet is serialized):

| Pet | Tier | Chance | Strength |
|---|---|---|---|
| Ember Imp | Common | 30.06% | 2 |
| Cinder Pup | Common | 28% | 2 |
| Magma Toad | Common | 26% | 2 |
| Blaze Ferret | Uncommon | 11% | 3 |
| Lava Salamander | Rare | 3.6% | 5 |
| Inferno Wolf | Epic | 1% | 8 |
| Phoenix | Legendary | 1 in 300 | 20 |
| Sunforge Drake | Mythic | 1 in 15K | 50 |
| ??? (Volcano Titan) | Secret | 1 in 1.5M | = your best pet |
| ??? (Solar Behemoth) | Divine | 1 in 50M | 10× your best pet |
| ??? (Ignis Eternal) | Impossible | 1 in 5B | 100× your best pet |
| **Boundless** (this month's, the same in every egg) | Boundless | 1 in 1T | 1,000× your best pet |

**Quests:**

| # | Quest | Reward |
|---|---|---|
| 1 | Focus meditate for 60 s | +1 pet slot (6) |
| 2 | Defeat 50 Ember Slimes | free egg |
| 3 | Hatch 8 eggs here | free egg |
| 4 | Defeat 20 Lava Hounds | +1 pet slot (7) |
| 5 | Get a pet to level 10 | free egg |
| 6 | Reach 10K Power | **boss gate opens** |

**Boss: MAGMA ONI** (recommended Power 10K): a huge red oni with lava-crack skin, obsidian horns and a flaming club. **Arena:** the Caldera Ring over the lava lake.
- **HP:** plates 6 × 82.5K; body 500K.
- **Rage:** throws lava waves in a fan: step into the gap; a PERFECT on its glowing fist staggers it.
- **Reward:** form **INFERNO** (red-black flames, heat haze); **Boss Shards worth 87K coins** (about 3 Glacora Peaks eggs).

**At the boss** (average free player, median):

| Time | Power | Slots | Best pet | Best stars | Best level | Bag |
|---|---|---|---|---|---|---|
| **~21 min** | 10.3K | 7 | Epic | ★★ | 19 | 250 |

## 16. ZONE 3: GLACORA PEAKS (Ice) · quests: very easy

**The feel:** moonlit snowy peaks under an aurora: calm, magical, sparkling.

| Design | |
|---|---|
| Layout | The **Shrine** is an ice-crystal gazebo on a frozen lake. Hunting grounds: **Snowdrift Fields**, **Ram Ridge** (switchback mountain paths), **Titan Glacier** (at the foot of a giant glacier wall). The boss arena, **Frozen Crown**, is the summit plateau |
| Landmarks | an **ice palace** carved into the mountain; a **giant whale frozen inside the lake ice**, glowing faintly; aurora curtains overhead |
| Materials | snow-white plastic, pale-blue translucent ice with an inner glow, frosted silver trims |
| Sky + light | deep night blue with green and violet aurora ribbons and big stars |
| Ambient VFX | snowfall, aurora ripples, frosty breath, sparkling snow dust |
| Sound + music | soft wind and ice chimes; dreamy music box and synth |
| Mutation Storm here | **Blizzard:** a whiteout swirl, the aurora flares bright |
| **New in this zone** | the **Enchant Forge** (section 13.3); **trading booths** open in the hub (after boss 2) |

**Numbers:** Shrine 8 Power/s · Egg 29K coins.

| Monster | Look | HP | Behaviour | Drops (coins) | XP per kill |
|---|---|---|---|---|---|
| **Snowling** | a snowball slime with a tiny ice crown | 5,120 | packs; slides on ice | 1 Shard (300) | 9 |
| **Ice Ram** | a ram with crystal ice horns | 51.2K | charges a red lane, leaves an icy slick | 3 Shards + 20% Bright (4,000) | 36 |
| **Glacier Titan** | a yeti-titan with a glacier back | 512K | slams; a ring of ice spikes | 8 Shards + 2 Bright + 10% Gem (25K) | 135 |

**Egg: Glacora Peaks pets** (Strength ×4; every Secret-or-rarer pet is serialized):

| Pet | Tier | Chance | Strength |
|---|---|---|---|
| Snow Hare | Common | 37.07% | 4 |
| Frost Penguin | Common | 32% | 4 |
| Ice Fox | Uncommon | 18% | 6 |
| Glacier Seal | Rare | 8% | 10 |
| Crystal Yeti | Rare | 3.5% | 10 |
| Blizzard Owl | Epic | 1.2% | 16 |
| Frost Kirin | Legendary | 1 in 450 | 40 |
| Aurora Stag | Mythic | 1 in 30K | 100 |
| ??? (Glacial Leviathan) | Secret | 1 in 3M | = your best pet |
| ??? (Frostfall Empress) | Divine | 1 in 150M | 10× your best pet |
| ??? (Absolute Zero) | Impossible | 1 in 20B | 100× your best pet |
| **Boundless** (this month's, the same in every egg) | Boundless | 1 in 1T | 1,000× your best pet |

**Quests:**

| # | Quest | Reward |
|---|---|---|
| 1 | Focus meditate for 60 s | +1 pet slot (8) |
| 2 | Defeat 50 Snowlings | free egg |
| 3 | Hatch 8 eggs here | free egg |
| 4 | Defeat 20 Ice Rams | free egg |
| 5 | Get a pet to level 10 | free egg |
| 6 | Reach 200K Power | **boss gate opens** |

**Boss: FROST WYRM** (recommended Power 200K): a long serpent ice-dragon coiled around the summit, translucent wings, glowing blue core. **Arena:** the Frozen Crown summit.
- **HP:** plates 6 × 1.65M; body 10M.
- **Rage:** ice breath sweeps a cone (step out) and ice pillars crash on red circles: **PERFECT a pillar** to shatter it into the Wyrm.
- **Reward:** form **GLACIER** (icy crystal aura); **Boss Shards worth 1.38M coins** (about 3 Voltora Cliffs eggs).

**At the boss** (average free player, median):

| Time | Power | Slots | Best pet | Best stars | Best level | Bag |
|---|---|---|---|---|---|---|
| **~41 min** | 203K | 8 | Epic | ★★ | 26 | 300 |

## 17. ZONE 4: VOLTORA CLIFFS (Lightning) · quests: easy

**The feel:** floating islands in a permanent storm: electric, epic, fast.

| Design | |
|---|---|
| Layout | Floating cliff islands joined by **energy bridges**. The **Shrine** sits on a Tesla-coil spire. Hunting grounds: **Static Fields**, **Hawk Spires**, **Colossus Quarry**. The boss arena, **the Storm Eye**, is a platform in the calm eye of a cyclone |
| Landmarks | giant chrome-gold **lightning rods** that arc to each other; a storm cloud shaped like a sky-whale; rocks that float and slowly spin |
| Materials | slate-lilac rock with glowing yellow circuit lines, chrome-gold metal, glassy purple crystals |
| Sky + light | purple storm clouds with frequent soft lightning (safe with the reduced-flashing setting) |
| Ambient VFX | arcs between rods, static sparks, wind streaks, hair-raising particles near rods |
| Sound + music | thunder rolls and crackles; driving electro-anime music |
| Mutation Storm here | **Thunderstorm:** lightning everywhere, energy bridges overcharge and glow |
| **New in this zone** | the **Spirit Nursery** (pet daycare, section 13.4) in the **Sky Nest** |

**Numbers:** Shrine 32 Power/s · Egg 460K coins.

| Monster | Look | HP | Behaviour | Drops (coins) | XP per kill |
|---|---|---|---|---|---|
| **Spark Wisp** | a fizzing ball of static with a spark tail | 81.9K | packs; zips around | 1 Shard (3,000) | 27 |
| **Thunder Hawk** | a hawk with lightning-bolt feathers | 819K | dives down a red lane | 3 Shards + 20% Bright (40K) | 108 |
| **Storm Colossus** | a colossus with a coil heart and copper limbs | 8.19M | slams + a lightning ring | 8 Shards + 2 Bright + 10% Gem (250K) | 405 |

**Egg: Voltora Cliffs pets** (Strength ×8; every Secret-or-rarer pet is serialized):

| Pet | Tier | Chance | Strength |
|---|---|---|---|
| Static Mouse | Common | 31.11% | 8 |
| Volt Bat | Common | 27% | 8 |
| Thunder Pup | Common | 26% | 8 |
| Zap Lizard | Uncommon | 11% | 12 |
| Storm Falcon | Rare | 3.6% | 20 |
| Lightning Tiger | Epic | 1% | 32 |
| Thunderbird | Legendary | 1 in 350 | 80 |
| Tempest Dragon | Mythic | 1 in 20K | 200 |
| ??? (Raijin) | Secret | 1 in 2M | = your best pet |
| ??? (Storm Sovereign) | Divine | 1 in 80M | 10× your best pet |
| ??? (Thunder Infinite) | Impossible | 1 in 8B | 100× your best pet |
| **Boundless** (this month's, the same in every egg) | Boundless | 1 in 1T | 1,000× your best pet |

**Quests:**

| # | Quest | Reward |
|---|---|---|
| 1 | Focus meditate for 90 s | +1 pet slot (9) |
| 2 | Defeat 80 Spark Wisps | free egg |
| 3 | Hatch 12 eggs here | free egg |
| 4 | Defeat 40 Thunder Hawks | free egg |
| 5 | Defeat 5 Storm Colossi | free egg |
| 6 | Get a pet to level 15 | free egg |
| 7 | Reach 4M Power | **boss gate opens** |

**Boss: THUNDER ROC** (recommended Power 4M): a giant thunderbird whose wings crackle with lightning and whose eyes glow white. **Arena:** the Storm Eye.
- **HP:** plates 6 × 33M; body 200M.
- **Rage:** lightning markers chase you (keep moving) while 4 rods charge it: **blast the rods** to stun it.
- **Reward:** form **TEMPEST** (crackling lightning aura); **Boss Shards worth 21M coins** (about 3 Blossora Gardens eggs).

**At the boss** (average free player, median):

| Time | Power | Slots | Best pet | Best stars | Best level | Bag |
|---|---|---|---|---|---|---|
| **~1 h 10** | 4.03M | 9 | Epic | ★★ | 30 | 400 |

## 18. ZONE 5: BLOSSORA GARDENS (Nature) · quests: easy

**The feel:** a dreamy blossom garden at golden hour: beautiful, peaceful, colourful.

| Design | |
|---|---|
| Layout | The **Shrine** is a stone garden ringed by red torii gates. Hunting grounds: **Petal Meadows**, **Bamboo Grove**, **Treant Hollow**. The boss arena, the **Moonlit Bridge**, is a red arched bridge over a koi pond |
| Landmarks | a **colossal sakura tree** whose canopy covers the sky; koi ponds with glowing koi; floating lanterns |
| Materials | pink blossom canopies, moss-green mounds, red lacquer, white stone, glossy bamboo |
| Sky + light | golden afternoon fading to pink, petals in the air |
| Ambient VFX | drifting petals, fireflies, koi ripples, lantern glow |
| Sound + music | koto and wind through bamboo; calm lo-fi beats |
| Mutation Storm here | **Petal Storm:** a whirlwind of petals, the koi leap |
| **New in this zone** | the **Star Forge** (fusion to ★3-★5) |

**Numbers:** Shrine 160 Power/s · Egg 7M coins.

| Monster | Look | HP | Behaviour | Drops (coins) | XP per kill |
|---|---|---|---|---|---|
| **Petal Sprite** | a petal sprite riding a leaf | 1.31M | packs; floats on petals | 1 Shard (30K) | 81 |
| **Blossom Fox** | a white fox with blossom tails | 13.1M | dashes along a red lane | 3 Shards + 20% Bright (400K) | 324 |
| **Ancient Treant** | an ancient treant with a blossom crown | 131M | root-slam circle | 8 Shards + 2 Bright + 10% Gem (2.5M) | 1,215 |

**Egg: Blossora Gardens pets** (Strength ×16; every Secret-or-rarer pet is serialized):

| Pet | Tier | Chance | Strength |
|---|---|---|---|
| Petal Bunny | Common | 36.1% | 16 |
| Leaf Kit | Common | 33% | 16 |
| Koi Spirit | Uncommon | 17% | 24 |
| Bamboo Panda | Rare | 9% | 40 |
| Sakura Fox | Rare | 3.5% | 40 |
| Moss Golem | Epic | 1.2% | 64 |
| Kitsune | Legendary | 1 in 500 | 160 |
| Jade Dragon | Mythic | 1 in 35K | 400 |
| ??? (Celestial Koi) | Secret | 1 in 4M | = your best pet |
| ??? (Eternal Bloom Dragon) | Divine | 1 in 200M | 10× your best pet |
| ??? (World Tree Spirit) | Impossible | 1 in 30B | 100× your best pet |
| **Boundless** (this month's, the same in every egg) | Boundless | 1 in 1T | 1,000× your best pet |

**Quests:**

| # | Quest | Reward |
|---|---|---|
| 1 | Focus meditate for 90 s | +1 pet slot (10) |
| 2 | Defeat 80 Petal Sprites | free egg |
| 3 | Hatch 12 eggs here | free egg |
| 4 | Defeat 40 Blossom Foxs | free egg |
| 5 | Defeat 5 Ancient Treants | free egg |
| 6 | Get a pet to level 15 | free egg |
| 7 | Reach 60M Power | **boss gate opens** |

**Boss: BLOSSOM RONIN** (recommended Power 60M): a masked ronin made of blossom wood, with a glowing katana. **Arena:** the Moonlit Bridge.
- **HP:** plates 6 × 495M; body 3B.
- **Rage:** dash-slashes along red lines, then splits into petal clones: **only the real one has a shadow**.
- **Reward:** form **BLOOM** (swirling blossom aura); **Boss Shards worth 345M coins** (about 3 Nyxora Rift eggs).

**At the boss** (average free player, median):

| Time | Power | Slots | Best pet | Best stars | Best level | Bag |
|---|---|---|---|---|---|---|
| **~1 h 50** | 60.3M | 10 | Epic | ★★ | 30 | 500 |

## 19. ZONE 6: NYXORA RIFT (Void) · quests: easy

**The feel:** floating islands at the edge of reality: mysterious, glowing, a little scary (still colourful, never black).

| Design | |
|---|---|
| Layout | The **Shrine** is a ring of floating runestones. Hunting grounds: **Mite Shards** (broken floating platforms), **Stalker Maze** (rune corridors), **Behemoth Abyss** (the edge of the void). The boss arena, **the Event Horizon**, circles a black hole |
| Landmarks | a giant **cracked moon**; rifts that show glimpses of the other zones; tall rune pillars |
| Materials | deep plum stone with glowing magenta / cyan runes, glossy violet-black crystal |
| Sky + light | a purple nebula with the cracked moon |
| Ambient VFX | rift tears, particles swirling inward, pulsing runes |
| Sound + music | deep hums and whispers; dark-synth music with a heartbeat |
| Mutation Storm here | **Eclipse:** the moon covers the sun, runes blaze |
| **New in this zone** | the **Mutation Reactor** (section 13.6) |

**Numbers:** Shrine 800 Power/s · Egg 115M coins.

| Monster | Look | HP | Behaviour | Drops (coins) | XP per kill |
|---|---|---|---|---|---|
| **Void Mite** | a tiny void mite with glowing eyes | 21M | packs; blinks short distances | 1 Shard (300K) | 243 |
| **Shade Stalker** | a shadow panther that leaves afterimages | 210M | teleports, then pounces down a red lane | 3 Shards + 20% Bright (4M) | 972 |
| **Rift Behemoth** | a rift behemoth with a portal in its chest | 2.1B | slam + a pulling rift | 8 Shards + 2 Bright + 10% Gem (25M) | 3,645 |

**Egg: Nyxora Rift pets** (Strength ×32; every Secret-or-rarer pet is serialized):

| Pet | Tier | Chance | Strength |
|---|---|---|---|
| Shadow Cat | Common | 29.15% | 32 |
| Void Bat | Common | 29% | 32 |
| Rift Wisp | Common | 26% | 32 |
| Gloom Wolf | Uncommon | 11% | 48 |
| Shade Panther | Rare | 3.6% | 80 |
| Void Serpent | Epic | 1% | 128 |
| Eclipse Dragon | Legendary | 1 in 400 | 320 |
| Abyss Kraken | Mythic | 1 in 25K | 800 |
| ??? (Null Wyrm) | Secret | 1 in 2.5M | = your best pet |
| ??? (Abyssal Emperor) | Divine | 1 in 120M | 10× your best pet |
| ??? (The Void Itself) | Impossible | 1 in 12B | 100× your best pet |
| **Boundless** (this month's, the same in every egg) | Boundless | 1 in 1T | 1,000× your best pet |

**Quests:**

| # | Quest | Reward |
|---|---|---|
| 1 | Focus meditate for 90 s | free egg |
| 2 | Defeat 80 Void Mites | free egg |
| 3 | Hatch 12 eggs here | free egg |
| 4 | Defeat 40 Shade Stalkers | free egg |
| 5 | Defeat 5 Rift Behemoths | free egg |
| 6 | Get a pet to level 15 | free egg |
| 7 | Reach 1B Power | **boss gate opens** |

**Boss: VOID LEVIATHAN** (recommended Power 1B): a colossal void serpent-leviathan swimming through space around the arena. **Arena:** the Event Horizon.
- **HP:** plates 6 × 8.25B; body 50B.
- **Rage:** a black hole pulls you in (walk against it) and portals spit tentacles: **blast a portal** to send the tentacle back.
- **Reward:** form **ECLIPSE** (dark ring with violet fire); **Boss Shards worth 5.1B coins** (about 3 Astora Throne eggs).

**At the boss** (average free player, median):

| Time | Power | Slots | Best pet | Best stars | Best level | Bag |
|---|---|---|---|---|---|---|
| **~2 h 34** | 1.01B | 10 | Epic | ★★ | 30 | 500 |

## 20. ZONE 7: ASTORA THRONE (Cosmic) · quests: medium

**The feel:** a palace floating among planets: grand, royal, starry.

| Design | |
|---|---|
| Layout | The **Shrine** is a star-map dais. Hunting grounds: **Mote Belt** (asteroid rings), **Comet Run** (a long glowing track), **Nebula Halls**. The boss arena is the **Throne of Stars** |
| Landmarks | planets that visibly orbit; a sun on the horizon; constellations that draw themselves in the sky |
| Materials | navy marble with gold star inlays, crystal glass, glowing nebula fog |
| Sky + light | deep space with a purple-blue nebula and moving planets |
| Ambient VFX | shooting stars, nebula fog, orbit trails |
| Sound + music | choir pads and chimes; epic space-orchestra music |
| Mutation Storm here | **Meteor Shower:** the sky fills with falling stars |
| **New in this zone** | the **Aura Forge** (customize your aura; section 13.7) |

**Numbers:** Shrine 4,000 Power/s · Egg 1.7B coins.

| Monster | Look | HP | Behaviour | Drops (coins) | XP per kill |
|---|---|---|---|---|---|
| **Star Mote** | a star mote with a smiling face | 336M | packs; orbit each other | 1 Shard (3M) | 729 |
| **Comet Beast** | a comet beast with a fiery tail | 3.36B | charges with a fiery tail lane | 3 Shards + 20% Bright (40M) | 2,916 |
| **Nebula Giant** | a nebula giant full of stars | 33.6B | slam + a gravity well | 8 Shards + 2 Bright + 10% Gem (250M) | 10.9K |

**Egg: Astora Throne pets** (Strength ×64; every Secret-or-rarer pet is serialized):

| Pet | Tier | Chance | Strength |
|---|---|---|---|
| Star Puff | Common | 34.12% | 64 |
| Comet Pup | Common | 35% | 64 |
| Nebula Jelly | Uncommon | 17% | 96 |
| Meteor Fox | Rare | 9% | 160 |
| Galaxy Whale | Rare | 3.5% | 160 |
| Orbit Lion | Epic | 1.2% | 256 |
| Supernova Phoenix | Legendary | 1 in 550 | 640 |
| Cosmic Dragon | Mythic | 1 in 40K | 1,600 |
| ??? (Starborn Titan) | Secret | 1 in 5M | = your best pet |
| ??? (Galaxy Devourer) | Divine | 1 in 300M | 10× your best pet |
| ??? (Big Bang) | Impossible | 1 in 50B | 100× your best pet |
| **Boundless** (this month's, the same in every egg) | Boundless | 1 in 1T | 1,000× your best pet |

**Quests:**

| # | Quest | Reward |
|---|---|---|
| 1 | Focus meditate for 120 s | free egg |
| 2 | Defeat 150 Star Motes | free egg |
| 3 | Hatch 20 eggs here | free egg |
| 4 | Defeat 80 Comet Beasts | free egg |
| 5 | Defeat 15 Nebula Giants | free egg |
| 6 | Defeat 5 mutated monsters (any mutation) | free egg |
| 7 | Make a ★★ pet | free egg |
| 8 | Reach 15B Power | **boss gate opens** |

**Boss: STAR EMPEROR** (recommended Power 15B): a star-crowned emperor on a floating throne, cape made of galaxies. **Arena:** the Throne of Stars.
- **HP:** plates 6 × 124B; body 750B.
- **Rage:** meteor showers (many red circles) and constellation nodes: **blast the nodes in the shown order** to drop a meteor on him.
- **Reward:** form **COSMIC** (starfield aura with orbiting planets); **Boss Shards worth 87B coins** (about 3 Seraphora Gate eggs).

**At the boss** (average free player, median):

| Time | Power | Slots | Best pet | Best stars | Best level | Bag |
|---|---|---|---|---|---|---|
| **~3 h 50** | 15B | 10 | Epic | ★★★ | 30 | 500 |

## 21. ZONE 8: SERAPHORA GATE (Holy light) · quests: medium

**The feel:** temples in the clouds: radiant, heavenly, huge scale.

| Design | |
|---|---|
| Layout | The **Shrine** is a halo platform. Hunting grounds: **Halo Fields** (cloud meadows), **Knight Bridges** (marble bridges), **Guardian Steps** (a giant staircase). The boss arena is the **Gate of Light** |
| Landmarks | a **colossal golden gate**; angel statues; waterfalls of light pouring into the clouds |
| Materials | white marble, gold, fluffy cloud plastic |
| Sky + light | bright white-gold with soft light beams |
| Ambient VFX | light beams, drifting feathers, choir glow |
| Sound + music | choir and harp; heavenly orchestral music |
| Mutation Storm here | **Holy Rain:** golden rain and feathers |
| **New in this zone** | the **Relic Shrine** (section 13.8) |

**Numbers:** Shrine 20K Power/s · Egg 29B coins.

| Monster | Look | HP | Behaviour | Drops (coins) | XP per kill |
|---|---|---|---|---|---|
| **Halo Sprite** | a halo sprite with tiny wings | 5.37B | packs; spinning halos | 1 Shard (30M) | 2,187 |
| **Seraph Knight** | a seraph knight with a light lance | 53.7B | lance charge down a red lane | 3 Shards + 20% Bright (400M) | 8,748 |
| **Celestial Guardian** | a giant marble guardian with a ring of light | 537B | slam + a ring of light beams | 8 Shards + 2 Bright + 10% Gem (2.5B) | 32.8K |

**Egg: Seraphora Gate pets** (Strength ×128; every Secret-or-rarer pet is serialized):

| Pet | Tier | Chance | Strength |
|---|---|---|---|
| Halo Chick | Common | 33.17% | 128 |
| Angel Bunny | Common | 26% | 128 |
| Seraph Cat | Common | 26% | 128 |
| Wing Pup | Uncommon | 11% | 192 |
| Archon Owl | Rare | 2.6% | 320 |
| Seraph Lion | Epic | 1% | 512 |
| Celestial Kirin | Legendary | 1 in 450 | 1,280 |
| Holy Griffin | Mythic | 1 in 30K | 3,200 |
| ??? (The First Light) | Secret | 1 in 3M | = your best pet |
| ??? (Seraph Prime) | Divine | 1 in 200M | 10× your best pet |
| ??? (Eternal Halo) | Impossible | 1 in 20B | 100× your best pet |
| **Boundless** (this month's, the same in every egg) | Boundless | 1 in 1T | 1,000× your best pet |

**Quests:**

| # | Quest | Reward |
|---|---|---|
| 1 | Focus meditate for 120 s | free egg |
| 2 | Defeat 150 Halo Sprites | free egg |
| 3 | Hatch 20 eggs here | free egg |
| 4 | Defeat 80 Seraph Knights | free egg |
| 5 | Defeat 15 Celestial Guardians | free egg |
| 6 | Defeat 5 mutated monsters (any mutation) | free egg |
| 7 | Make a ★★ pet | free egg |
| 8 | Reach 200B Power | **boss gate opens** |

**Boss: ARCHANGEL SENTINEL** (recommended Power 200B): a six-winged archangel in gold armour with a giant spear. **Arena:** the Gate of Light.
- **HP:** plates 6 × 1.65T; body 10T.
- **Rage:** sweeping walls of light with one gap, and judgement circles that follow you: **PERFECT its raised spear** to break the wall.
- **Reward:** form **RADIANT** (white-gold aura with light wings); **Boss Shards worth 870B coins** (about 3 Drakora Sanctum eggs).

**At the boss** (average free player, median):

| Time | Power | Slots | Best pet | Best stars | Best level | Bag |
|---|---|---|---|---|---|---|
| **~5 h 17** | 201B | 10 | Epic | ★★★ | 30 | 500 |

## 22. ZONE 9: DRAKORA SANCTUM (Dragon) · quests: hard

**The feel:** a gold-and-jade dragon temple above the clouds: legendary, rich, powerful.

| Design | |
|---|---|
| Layout | The **Shrine** is a dragon-coil altar. Hunting grounds: **Hatchery Terraces**, **Wyvern Peaks**, **Elder Hall**. The boss arena is the **Dragon's Crown** |
| Landmarks | a **sleeping colossal dragon wrapped around the mountain** (its breathing moves the clouds); treasure hoards; dragon-bone bridges |
| Materials | jade, gold, red lacquer, glossy dragon scales |
| Sky + light | sunset over a sea of clouds |
| Ambient VFX | fire vents, gold coins glinting, lantern glow |
| Sound + music | deep drums and dragon roars; epic Asian-orchestral music |
| Mutation Storm here | **Dragonfire:** dragons fly overhead breathing harmless fire |
| **New in this zone** | the **Infinity Tower** entrance (endless boss floors; section 13.9) |

**Numbers:** Shrine 100K Power/s · Egg 290B coins.

| Monster | Look | HP | Behaviour | Drops (coins) | XP per kill |
|---|---|---|---|---|---|
| **Ember Drakelet** | a cute drakelet with ember breath | 85.9B | packs; small fire breaths | 1 Shard (300M) | 6,561 |
| **Crystal Wyvern** | a crystal wyvern | 859B | flies in and dives down a red lane | 3 Shards + 20% Bright (4B) | 26.2K |
| **Elder Dragon Golem** | an elder dragon golem made of jade and gold | 8.59T | tail-sweep circle + a fire breath cone | 8 Shards + 2 Bright + 10% Gem (25B) | 98.4K |

**Egg: Drakora Sanctum pets** (Strength ×256; every Secret-or-rarer pet is serialized):

| Pet | Tier | Chance | Strength |
|---|---|---|---|
| Dragon Hatchling | Common | 38.13% | 256 |
| Ember Wyrmling | Common | 31% | 256 |
| Jade Drakelet | Uncommon | 17% | 384 |
| Scale Pup | Rare | 9% | 640 |
| Crystal Wyvern | Rare | 3.5% | 640 |
| Storm Drake | Epic | 1.2% | 1,024 |
| Ancient Dragon | Legendary | 1 in 600 | 2,560 |
| Dragon King | Mythic | 1 in 50K | 6,400 |
| ??? (Primordial Dragon) | Secret | 1 in 6M | = your best pet |
| ??? (Dragon God) | Divine | 1 in 500M | 10× your best pet |
| ??? (Endless Wyrm) | Impossible | 1 in 100B | 100× your best pet |
| **Boundless** (this month's, the same in every egg) | Boundless | 1 in 1T | 1,000× your best pet |

**Quests:**

| # | Quest | Reward |
|---|---|---|
| 1 | Focus meditate for 180 s | free egg |
| 2 | Defeat 250 Ember Drakelets | free egg |
| 3 | Hatch 30 eggs here | free egg |
| 4 | Defeat 120 Crystal Wyverns | free egg |
| 5 | Defeat 30 Elder Dragon Golems | free egg |
| 6 | Defeat a **Rainbow, Void or Celestial** mutated monster | free egg |
| 7 | Make a ★★★ pet | free egg |
| 8 | Get a pet to level 25 | free egg |
| 9 | Reach 2.5T Power | **boss gate opens** |

**Boss: ELDER DRAGON EMPEROR** (recommended Power 2.5T): an ancient emperor dragon in gold armour. **Arena:** the Dragon's Crown.
- **HP:** plates 6 × 20.6T; body 125T.
- **Rage:** takes flight and rains fireballs on red circles, then breathes a sweeping cone: **PERFECT the fireballs** to bounce them back.
- **Reward:** form **DRAGONSOUL** (jade-gold aura with a dragon spirit); **Boss Shards worth 12T coins** (about 3 Aurora Nexus eggs).

**At the boss** (average free player, median):

| Time | Power | Slots | Best pet | Best stars | Best level | Bag |
|---|---|---|---|---|---|---|
| **~7 h 25** | 2.51T | 10 | Epic | ★★★ | 30 | 500 |

## 23. ZONE 10: AURORA NEXUS (Every aura) · quests: hard

**The feel:** the source of all auras: a prismatic void where every zone's light meets (the final wow).

| Design | |
|---|---|
| Layout | The **Shrine** is the **Nexus Core**, a giant floating aura sphere. Hunting grounds are floating fragments of the earlier worlds: **Wisp Prism**, **Knight Spectrum**, **Colossus Core**. The boss arena is the **Heart of Aura** |
| Landmarks | the 9 earlier zones floating in orbit as fragments; a river of rainbow aurora; statues of all 10 forms |
| Materials | prismatic glass and white stone, with every zone's accent colour shifting across it |
| Sky + light | a shifting rainbow aurora |
| Ambient VFX | rainbow shifts, everything glows in every colour, aura waves |
| Sound + music | every zone's theme woven together into one final track |
| Mutation Storm here | **Aurora Surge:** every zone's storm at once |
| **New in this zone** | the **Ascension Gate** (rebirth; section 13.10) and the **Boundless Hall** (statues of every Boundless owner). After the Ascendant: the **Nexus Titan** (an always-respawning raid boss), the **Weekly Limited Egg** and **XP Shards** with Awakening (section 13.12) |

**Numbers:** Shrine 500K Power/s · Egg 4T coins.

| Monster | Look | HP | Behaviour | Drops (coins) | XP per kill |
|---|---|---|---|---|---|
| **Aura Wisp** | an aura wisp that changes colour every second | 1.37T | packs; change colour every second | 1 Shard (3B) | 19.7K |
| **Prism Knight** | a prism knight | 13.7T | prism charge down a red lane | 3 Shards + 20% Bright (40B) | 78.7K |
| **Nexus Colossus** | a nexus colossus with rings in every element | 137T | slam + rings in every element | 8 Shards + 2 Bright + 10% Gem (250B) | 295K |

**Egg: Aurora Nexus pets** (Strength ×512; every Secret-or-rarer pet is serialized):

| Pet | Tier | Chance | Strength |
|---|---|---|---|
| Aura Sprite | Common | 30.2% | 512 |
| Prism Puff | Common | 30% | 512 |
| Spectrum Fox | Common | 25% | 512 |
| Halo Hound | Uncommon | 11% | 768 |
| Nexus Owl | Rare | 2.6% | 1,280 |
| Prism Tiger | Epic | 1% | 2,048 |
| Rainbow Kirin | Legendary | 1 in 500 | 5,120 |
| Aura Phoenix | Mythic | 1 in 40K | 12.8K |
| ??? (Spectrum Dragon) | Secret | 1 in 4M | = your best pet |
| ??? (Nexus Sovereign) | Divine | 1 in 300M | 10× your best pet |
| ??? (Aura Infinite) | Impossible | 1 in 40B | 100× your best pet |
| **Boundless** (this month's, the same in every egg) | Boundless | 1 in 1T | 1,000× your best pet |

**Quests:**

| # | Quest | Reward |
|---|---|---|
| 1 | Focus meditate for 180 s | free egg |
| 2 | Defeat 250 Aura Wisps | free egg |
| 3 | Hatch 30 eggs here | free egg |
| 4 | Defeat 120 Prism Knights | free egg |
| 5 | Defeat 30 Nexus Colossi | free egg |
| 6 | Defeat a **Rainbow, Void or Celestial** mutated monster | free egg |
| 7 | Make a ★★★ pet | free egg |
| 8 | Get a pet to level 25 | free egg |
| 9 | Reach 30T Power | **boss gate opens** |

**Boss: THE ASCENDANT** (recommended Power 30T): a figure of pure aura with wings of every element. **Arena:** the Heart of Aura.
- **HP:** plates 6 × 248T; body 1.5Qa.
- **Rage:** **every earlier boss's move in turn:** boulders, lava fans, ice pillars, lightning markers, light walls, petal clones, a black hole, meteors, fireballs. The beam clash is golden, against the whole sky.
- **Reward:** form **ASCENDED** (rainbow-white aura, wings of light, a halo); **Boss Shards worth 12T coins** (about 3 Aurora Nexus eggs).

**At the boss** (average free player, median):

| Time | Power | Slots | Best pet | Best stars | Best level | Bag |
|---|---|---|---|---|---|---|
| **~10 h 07** | 30.1T | 10 | Epic | ★★ | 30 | 500 |

## 24. Progression at a glance (average free player, solo, model medians)

| Zone | Name | Quests | Shrine /s | Egg | Boss (recommended Power) | Finished at | Power then |
|---|---|---|---|---|---|---|---|
| 1 | Lumora Grove | very easy | 0.5 | 60 | Stone Golem (300) | ~5 min | 314 |
| 2 | Pyrora Dojo | very easy | 2 | 1,700 | Magma Oni (10K) | ~21 min | 10.3K |
| 3 | Glacora Peaks | very easy | 8 | 29K | Frost Wyrm (200K) | ~41 min | 203K |
| 4 | Voltora Cliffs | easy | 32 | 460K | Thunder Roc (4M) | ~1 h 10 | 4.03M |
| 5 | Blossora Gardens | easy | 160 | 7M | Blossom Ronin (60M) | ~1 h 50 | 60.3M |
| 6 | Nyxora Rift | easy | 800 | 115M | Void Leviathan (1B) | ~2 h 34 | 1.01B |
| 7 | Astora Throne | medium | 4,000 | 1.7B | Star Emperor (15B) | ~3 h 50 | 15B |
| 8 | Seraphora Gate | medium | 20K | 29B | Archangel Sentinel (200B) | ~5 h 17 | 201B |
| 9 | Drakora Sanctum | hard | 100K | 290B | Elder Dragon Emperor (2.5T) | ~7 h 25 | 2.51T |
| 10 | Aurora Nexus | hard | 500K | 4T | The Ascendant (30T) | ~10 h 07 | 30.1T |

<!-- ZONES:END -->

---

# PART C: ENDGAME AND LIVE UPDATES

## 25. After zone 10: why players stay (owner's longevity concern)

A heavily upgraded player can clear the ten bosses in about **3 hours** (model: 2 h 59), and a free player in about **10** (10 h 06). That's fine **only if collecting, improving and showing off the team stays appealing afterwards.** This is the plan for every hour after the first clear.

**1. Improve the team (vertical, never "done"):**
- **★5 pets** (243 copies each), **Shiny** (Nursery), **pet mutations** (Reactor, up to ×5), **enchants** (I-V), **Awakening** to level 50 (XP Shards from the Titan), relics.
- Each layer **visibly changes the pet** (coat, halo, enchant glow, size at Awakening), so improving it is also showing it off.

**2. Collect (horizontal):**
- **Spirit Codex variants:** each species has collectable variants (★, Shiny, each mutation coat). Completing a variant page gives a permanent bonus + a nameplate badge.
- **Secret+ hunting** with its serials, the **monthly Boundless**, the **Weekly Limited Egg** (never again), Exclusive lines.

**3. Show off (the reason to collect):**
- **Showcase Plinths** in Lumora Plaza: your best 3 pets stand on your plinth for the whole server, with their serials, stars and coats.
- **Inspect** any player to see their team; **Admire** a team (one ⭐ per player per day) → a weekly **Most Admired Team** board and statue.
- Titles, halos, the ASCENDED form, the Leaderboard Wall (Power, Secret+, Boundless, Titan damage, Tower floor).

**4. Things to do every session:**
- **3 daily endgame goals** (e.g. "earn 3 Titan reward shares", "infuse a mutation", "clear 3 Tower floors") paying XP Shards, Enchant Crystals and Relic Shards;
- the **Nexus Titan** raid around the clock with its weekly damage board;
- the **Infinity Tower** (endless floors, leaderboard);
- **Ascension** (13.10): the long-term loop. Reset zones for permanent ×1.5 Power / +25% luck per Star and a new halo tier, keeping the team. Fast players are expected to Ascend, so a 3-hour first clear is the **start** of their game, not the end.

**5. Every week, something new** (section 26): a new zone, a new Weekly Limited Egg and a stronger Titan.

**How we'll know it works** (soft launch, not the model): the share of players who clear zone 10 and **still play 3+ more sessions**, time spent at the Codex / Showcase / Reactor / Enchant Forge after the clear, Ascension rate, and day-7 return of players who finished. If post-clear players drop fast, the fix goes into layers 1-3 **before** adding more zones.

## 26. Live updates (the plan after launch)

- **A new zone about every week** (11, 12, …), each with a new egg, monsters, a raid boss and a form. Each new zone adds roughly 2-4 hours for a free player and is tuned in the model first.
- **Every week:** a new **Weekly Limited Egg** and a stronger **Nexus Titan** (13.12), moved to the newest zone.
- **Every month:** a new Boundless pet, new Exclusive Egg themes, a new Aura Pass season, and new Limited drops like the Verity items.
- **Later systems** (each keeps the core rules):
  - **global events** on one clock;
  - **boss replays** with Boss Seals (eggs, not coins);
  - **Wild Spirits:** a rare roaming pet mini-boss;
  - **trading:** a safe window, unlocked after boss 2;
  - (the World Boss is covered by the raid bosses and the Nexus Titan).

---

# PART D: MONEY AND FAIRNESS

## 27. Monetization (summary; full plan in MONETIZATION.md v3)

- **The 2× Boost ladder:** every tier **doubles both Luck and Power**, permanently. 11 tiers, from 3 R$ (×2) to 999 R$ (×2,048).
- **Passes:**

| Pass | R$ |
|---|---|
| **VIP** (title over your head and in chat, ×1.5 coins / Power / hatch speed / Secret luck, +1 slot) | 399 |
| 2× Coins | 399 |
| 2× Secret Luck | 199 |
| 2× Hatch Speed | 399 |
| Hatch ×8 | 399 |
| Huge Storm | 199 |
| Auto-Sell | 199 |
| Offline+ | 99 |
| Mutation Magnet | 99 |

  **Auto-Hatch is free; Hatch ×3 is free after boss 1.**
- **Repeatable products:**
  - **+2 Pet Slots:** 199 R$, up to 10 times;
  - **potions:** Luck / Power / Coin 25 (5 for 99), XP 19, Mega 65;
  - **server boosts:** Mutation Storm 99, Server Luck Boost 199;
  - **coin packs:** 49 / 149 / 449 / 999.
- **Exclusive Eggs:**
  - **Daily Exclusive:** also free from rewards; 49 / 99 / 249;
  - **Shop Exclusive:** 99 / 279 / 849;
  - both use the tier system, with a Boundless line, and have no Huge or Titanic.
- **Limited:** only the Verity pet and aura for now (a meme, so no licence; our own art), numbered; on sale for 7 days or until 1,000 sold (every buyer gets a numbered copy; MONETIZATION 7).
- **Aura Pass:** 799 R$ (+799 to skip straight to the end).
- **Packs:** Starter 49, Zone 149, Comeback 99.
- **Free rewards:** hourly, daily (missed days never reset the cycle) and group rewards.
- **Pop-ups:** only two: the 3 R$ 2× Boost after your first meditation, and the Zone Pack when you enter a new zone.
- **What payers get (model, all 10 zones):**

| Spend | All 10 zones |
|---|---|
| free | ~10 h 06 |
| starter (31 R$) | 6 h 18 |
| VIP set (986 R$) | 3 h 13 |
| whale (7,164 R$) | 2 h 59 |

**What these times are (and aren't):** they come from `econ/model.py`, which simulates the **core loop**: blasts, Overdrive, mutations and storms, meditation, eggs and luck, pets (Strength, stars, levels, the Star Forge in zone 5), quests, bosses, the 2× Boost ladder, VIP, 2× Coins / Secret Luck / Hatch Speed, Hatch ×8, Huge Storm, Auto-Sell, Mutation Magnet and slot packs. **Not modeled yet:** enchants, pet mutations, the Nursery, relics, the Codex, Ascension, Exclusive and reward-track pets, potions, the Aura Pass, coin packs, Offline+ (the model plays in one sitting) and raid co-op. Almost all of those only speed a player up, so the real times are probably **shorter**, by an unknown amount. **These are partial-model estimates, not validated pacing**: playtest #1 and the soft launch measure the real times, and each machine is added to the model before it ships (GAME-PLAN 5b).

## 28. Fairness, safety and saving (details in CORE-GAME.md)

- **No losses:** nothing you own can be lost or stolen. A knockout costs time only.
- **Personal loot:** everyone whose hit lands gets their own drop and quest credit.
- **Server authority:** the server owns every number. Blasts, Focus taps, meditation, rewards and purchases are checked.
- **Saving has three outcomes:**
  - **confirmed saved:** you see the result;
  - **confirmed not saved:** "nothing was spent, try again";
  - **unknown:** the cost is held while the game checks.

  A result is never shown before it's safely saved. Serials are assigned inside that same save.
