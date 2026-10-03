# AURA CLASH: GAME BIBLE v7 (everything in the game, zone by zone)

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

**v7 owner changes (3 October 2026):**
- **10 zones** (Dragon Sanctum and Aura Nexus added):
  - **free player:** about 11 h for a first run;
  - **whale:** about 3 h 15.
- **New rarity system:** Common, Uncommon, Rare, Epic, Legendary, Mythic, **Secret (1 in 1M+)**, **Divine (1 in 10M+)**, **Impossible (1 in 1B+)**, **Boundless (1 in 1T+, in every egg, a new one every month)**.
  - **Odds:** **every egg has its own odds**; a tier is defined by its odds band.
  - **Serials:** **Secret and rarer pets are serialized.**
- **Luck has no cap.**
- **Natural Mutation Storms** every 45 minutes.
- **Hatching:** Auto-Hatch is free; Hatch ×3 and ×8 are passes; the free Hatch ×3 after boss 1 is gone.
- **Monetization v3** (MONETIZATION.md): a single 2× Boost ladder (Luck **and** Power), VIP 399 with hatch speed and Secret luck, +2 slot packs, coin packs, cheaper potions and packs, the Aura Pass at 799.

**Contents:**
- **Part A, how the game works:** sections 1-11.
- **Part B, zone by zone:** sections 12-22.
- **Part C, endgame and live updates:** sections 23-24.
- **Part D, money and fairness:** sections 25-26.

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
- **Shrine rates:** **×4 per zone up to zone 4, then ×5 per zone**, from 0.5/s in zone 1 to 500,000/s in zone 10.
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
| **Secret** | **1 in 1M+** | **100** |
| **Divine** | **1 in 10M+** | **400** |
| **Impossible** | **1 in 1B+** | **2,000** |
| **Boundless** | **1 in 1T+** | **100,000** (always the strongest pet in the game) |

- **Egg layouts differ:** odd zones have **two Commons** (e.g. 35% / 34%); even zones have **three Commons** (e.g. 30% / 28% / 26%). Every zone has its own numbers for every tier.
- **Boundless:** **every egg in the game** (zone eggs and Exclusive Eggs) has a 1 in 1T Boundless line. **A new Boundless pet every month,** the same in every egg; its Strength scales to your best zone.
- **Serials:** **every Secret, Divine, Impossible and Boundless pet is serialized**, shown on the card and over the pet ("Aurora Dragon #12 of 37").
- **Luck** (the 2× Boost ladder, potions, server boosts, group; MONETIZATION.md):
  - **No cap.** It works **hardest on the rarest tiers**: Legendary gets luck^0.3, Mythic luck^0.5, Secret luck^0.8, Divine luck^0.9, and Impossible and Boundless the full luck.
  - **Secret luck** (2× Secret Luck pass, VIP) multiplies Secret and rarer on top.
  - **Common to Epic** share what's left in their own ratio.
  - **The odds always add to 100%,** so Legendary-and-up together can never pass 90% of hatches. That's arithmetic, not a luck cap.
- **The egg card always shows the real odds at your current luck.**

### 5.2 Strength
**Strength = tier base × zone (×2 for every zone after the first; a zone-10 pet is ×512) × stars × level.** The pet card shows only the final number.

### 5.3 What pets do

| Job | Rule |
|---|---|
| **Fight** | each equipped pet hits your target every 1.5 s for **Strength × 4% of your Power**, with its own move. On your PERFECT they all strike at once. **The whole team's hit is capped at 100% of your Power**, so your blasts always matter |
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
- **Hatch modes:** Hatch ×1 and **Auto-Hatch are free**. **Hatch ×3 (99 R$)** and **Hatch ×8 (399 R$)** are passes, and the **2× Hatch Speed** pass (and VIP ×1.5) speeds up the animations.
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
| **Impossible** | **cutscene** (12 s): reality shatters; **time freezes in every server** for the announcement; a permanent "IMPOSSIBLE" title; a statue at the Aura Nexus |
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

## 9. Bosses (general rules)

- **Your own instance,** about 40-90 s. Pets fight too. No SELL during the fight.
- **HP:** 6 plates of 3.3 × R and a body of 20 × R (R = recommended Power); every boss after the Golem has ×2.5 HP.
- **Phases:**
  1. **Armor:** blast the plates off while walking out of the red slam circles. Each hit you take costs 5% of your starting beam meter.
  2. **Rage:** the boss's own mechanic (see each zone).
  3. **Beam clash:**
     - **start:** the meter starts at 60% minus 5% per hit (never below 30%);
     - **pushing:** PERFECT +12%, other releases +6%;
     - **push-back:** the boss pushes back 3%/s at R (×R ÷ your Power, up to ×4);
     - **counters:** tap the red flash: +5% (a miss: −8%);
     - **end:** win at 100%, lose at 0% or after 30 s.

**Model win rates** (2 hits taken):

| Power ÷ R | 0.5 | 0.75 | 1.0 | 1.5 |
|---|---|---|---|---|
| weak timing | 0% | 28% | 79% | 100% |
| average | 23% | 98% | 100% | 100% |
| strong | 97% | 100% | 100% | 100% |

- **Win:** you **transform** to the zone's form; **Boss Shards** (worth about 3 eggs of the next zone; they don't count against the bag cap) burst into your storm, and you sell them at that zone's altar; the next zone opens.
- **Lose:** you're told exactly why, and can retry instantly.
- **Replays:** Boss Shards come only from the first win.

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
  - the leaderboards at the Shrine.
- **Settings:** Low effects, others' effects, show others' pets, camera shake, reduced flashing.
- **Tutorial:**
  - a pulsing hand points at the one next thing: MEDITATE → a Shardling → SELL → the egg → the quest bar;
  - labels are 1-3 words;
  - progress is saved;
  - the first meditation is a fixed +40 Power over 20 s.

---

# PART B: ZONE BY ZONE

**What "at the boss" means:** each zone ends with the average **free** player's state at that boss win. These are model medians, solo, so they're tuning targets, **not promises**.

<!-- ZONES:START (generated by econ/make_bible.py; don't edit by hand) -->

## 12. ZONE 1: TRAINING GROVE (Light) · quests: very easy

**Look:** mint grass, a warm path, soft light, crystal-overgrown animals. **Shrine:** 0.5 Power/s. **Egg:** 60 coins.

| Monster | HP | Behaviour | Drops (coins) | XP per kill |
|---|---|---|---|---|
| **Shardling** | 20 | hops in packs | 1 Shard (3) | 1 |
| **Crystal Boar** | 200 | charges down a red lane | 3 Shards + 20% Bright (40) | 4 |
| **Crag Brute** | 2,000 | slams a red circle | 8 Shards + 2 Bright + 10% Gem (250) | 15 |

**Egg: Training Grove pets** (Strength ×1; every Secret-or-rarer pet is serialized):

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
| ??? (Aurora Dragon) | Secret | 1 in 2.5M | 100 |
| ??? (Prism Archangel) | Divine | 1 in 100M | 400 |
| ??? (Lumen the Endless) | Impossible | 1 in 10B | 2,000 |
| **Boundless** (this month's, the same in every egg) | Boundless | 1 in 1T | 100K |

**Quests:**

| # | Quest | Reward |
|---|---|---|
| 1 | Focus meditate for 20 s | +1 pet slot (4) |
| 2 | Defeat 20 Shardlings | free egg |
| 3 | Hatch 5 eggs here | free egg |
| 4 | Defeat 10 Crystal Boars | +1 pet slot (5) |
| 5 | Reach 300 Power | **boss gate opens** |

**Boss: STONE GOLEM** (recommended Power 300)
- **HP:** plates 6 × 990; body 6,000.
- **Rage:** rolls boulders down red lanes (0.8 s warning): dodge sideways, or **PERFECT a boulder to blast it back** for big damage.
- **Reward:** form **BLAZE** (orange anime flames); **Boss Shards worth 4,500 coins** (about 3 Lava Dojo eggs).

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
| ~5:30 | **BLAZE.** Boss Shards sell for 4,500 → Bag Lv3, Mat Lv2, Surge Lv1. The Lava Dojo opens | ~315 |
| 5:35-7:05 | Zone 2 quest 1: Focus 60 s at the ×4 Shrine | ~1,500 |
| 7:05+ | Ember Slimes; Fire eggs (1,500) | |

**At the boss** (average free player, median):

| Time | Power | Slots | Best pet | Best stars | Best level | Bag |
|---|---|---|---|---|---|---|
| **~6 min** | 315 | 5 | Rare | ★★ | 2 | 200 |

## 13. ZONE 2: LAVA DOJO (Fire) · quests: very easy

**Look:** warm stone, dark rock, rivers of lava, a dojo on a volcano. **Shrine:** 2 Power/s. **Egg:** 1,500 coins.

| Monster | HP | Behaviour | Drops (coins) | XP per kill |
|---|---|---|---|---|
| **Ember Slime** | 320 | packs; leaves short burning puddles | 1 Shard (30) | 3 |
| **Lava Hound** | 3,200 | charges down a red lane | 3 Shards + 20% Bright (400) | 12 |
| **Obsidian Brute** | 32K | slams a red circle | 8 Shards + 2 Bright + 10% Gem (2,500) | 45 |

**Egg: Lava Dojo pets** (Strength ×2; every Secret-or-rarer pet is serialized):

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
| ??? (Volcano Titan) | Secret | 1 in 1.5M | 200 |
| ??? (Solar Behemoth) | Divine | 1 in 50M | 800 |
| ??? (Ignis Eternal) | Impossible | 1 in 5B | 4,000 |
| **Boundless** (this month's, the same in every egg) | Boundless | 1 in 1T | 200K |

**Quests:**

| # | Quest | Reward |
|---|---|---|
| 1 | Focus meditate for 60 s | +1 pet slot (6) |
| 2 | Defeat 50 Ember Slimes | free egg |
| 3 | Hatch 8 eggs here | free egg |
| 4 | Defeat 20 Lava Hounds | +1 pet slot (7) |
| 5 | Get a pet to level 10 | free egg |
| 6 | Reach 10K Power | **boss gate opens** |

**Boss: MAGMA ONI** (recommended Power 10K)
- **HP:** plates 6 × 82.5K; body 500K.
- **Rage:** throws lava waves in a fan: step into the gap; a PERFECT on its glowing fist staggers it.
- **Reward:** form **INFERNO** (red-black flames, heat haze); **Boss Shards worth 75K coins** (about 3 Frost Peaks eggs).

**At the boss** (average free player, median):

| Time | Power | Slots | Best pet | Best stars | Best level | Bag |
|---|---|---|---|---|---|---|
| **~25 min** | 10.3K | 7 | Epic | ★★ | 18 | 250 |

## 14. ZONE 3: FROST PEAKS (Ice) · quests: very easy

**Look:** snowy pastel peaks, ice crystals, an aurora sky. **Shrine:** 8 Power/s. **Egg:** 25K coins.

| Monster | HP | Behaviour | Drops (coins) | XP per kill |
|---|---|---|---|---|
| **Snowling** | 5,120 | packs; slides on ice | 1 Shard (300) | 9 |
| **Ice Ram** | 51.2K | charges a red lane, leaves an icy slick | 3 Shards + 20% Bright (4,000) | 36 |
| **Glacier Titan** | 512K | slams; a ring of ice spikes | 8 Shards + 2 Bright + 10% Gem (25K) | 135 |

**Egg: Frost Peaks pets** (Strength ×4; every Secret-or-rarer pet is serialized):

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
| ??? (Glacial Leviathan) | Secret | 1 in 3M | 400 |
| ??? (Frostfall Empress) | Divine | 1 in 150M | 1,600 |
| ??? (Absolute Zero) | Impossible | 1 in 20B | 8,000 |
| **Boundless** (this month's, the same in every egg) | Boundless | 1 in 1T | 400K |

**Quests:**

| # | Quest | Reward |
|---|---|---|
| 1 | Focus meditate for 60 s | +1 pet slot (8) |
| 2 | Defeat 50 Snowlings | free egg |
| 3 | Hatch 8 eggs here | free egg |
| 4 | Defeat 20 Ice Rams | free egg |
| 5 | Get a pet to level 10 | free egg |
| 6 | Reach 200K Power | **boss gate opens** |

**Boss: FROST WYRM** (recommended Power 200K)
- **HP:** plates 6 × 1.65M; body 10M.
- **Rage:** ice breath sweeps a cone (step out) and ice pillars crash on red circles: **PERFECT a pillar** to shatter it into the Wyrm.
- **Reward:** form **GLACIER** (icy crystal aura); **Boss Shards worth 1.2M coins** (about 3 Storm Cliffs eggs).

**At the boss** (average free player, median):

| Time | Power | Slots | Best pet | Best stars | Best level | Bag |
|---|---|---|---|---|---|---|
| **~45 min** | 203K | 8 | Epic | ★★ | 27 | 300 |

## 15. ZONE 4: STORM CLIFFS (Lightning) · quests: easy

**Look:** floating cliffs, purple storm clouds, lightning rods. **Shrine:** 32 Power/s. **Egg:** 400K coins.

| Monster | HP | Behaviour | Drops (coins) | XP per kill |
|---|---|---|---|---|
| **Spark Wisp** | 81.9K | packs; zips around | 1 Shard (3,000) | 27 |
| **Thunder Hawk** | 819K | dives down a red lane | 3 Shards + 20% Bright (40K) | 108 |
| **Storm Colossus** | 8.19M | slams + a lightning ring | 8 Shards + 2 Bright + 10% Gem (250K) | 405 |

**Egg: Storm Cliffs pets** (Strength ×8; every Secret-or-rarer pet is serialized):

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
| ??? (Raijin) | Secret | 1 in 2M | 800 |
| ??? (Storm Sovereign) | Divine | 1 in 80M | 3,200 |
| ??? (Thunder Infinite) | Impossible | 1 in 8B | 16K |
| **Boundless** (this month's, the same in every egg) | Boundless | 1 in 1T | 800K |

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

**Boss: THUNDER ROC** (recommended Power 4M)
- **HP:** plates 6 × 33M; body 200M.
- **Rage:** lightning markers chase you (keep moving) while 4 rods charge it: **blast the rods** to stun it.
- **Reward:** form **TEMPEST** (crackling lightning aura); **Boss Shards worth 18M coins** (about 3 Sakura Realm eggs).

**At the boss** (average free player, median):

| Time | Power | Slots | Best pet | Best stars | Best level | Bag |
|---|---|---|---|---|---|---|
| **~1 h 18** | 4.03M | 9 | Epic | ★★★ | 30 | 400 |

## 16. ZONE 5: SAKURA REALM (Nature) · quests: easy

**Look:** a pink blossom forest, koi ponds, torii gates. **Shrine:** 160 Power/s. **Egg:** 6M coins.

| Monster | HP | Behaviour | Drops (coins) | XP per kill |
|---|---|---|---|---|
| **Petal Sprite** | 1.31M | packs; floats on petals | 1 Shard (30K) | 81 |
| **Blossom Fox** | 13.1M | dashes along a red lane | 3 Shards + 20% Bright (400K) | 324 |
| **Ancient Treant** | 131M | root-slam circle | 8 Shards + 2 Bright + 10% Gem (2.5M) | 1,215 |

**Egg: Sakura Realm pets** (Strength ×16; every Secret-or-rarer pet is serialized):

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
| ??? (Celestial Koi) | Secret | 1 in 4M | 1,600 |
| ??? (Eternal Bloom Dragon) | Divine | 1 in 200M | 6,400 |
| ??? (World Tree Spirit) | Impossible | 1 in 30B | 32K |
| **Boundless** (this month's, the same in every egg) | Boundless | 1 in 1T | 1.6M |

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

**Boss: BLOSSOM RONIN** (recommended Power 60M)
- **HP:** plates 6 × 495M; body 3B.
- **Rage:** dash-slashes along red lines, then splits into petal clones: **only the real one has a shadow**.
- **Reward:** form **BLOOM** (swirling blossom aura); **Boss Shards worth 300M coins** (about 3 Void Rift eggs).

**At the boss** (average free player, median):

| Time | Power | Slots | Best pet | Best stars | Best level | Bag |
|---|---|---|---|---|---|---|
| **~2 h 03** | 60.4M | 10 | Epic | ★★★ | 30 | 500 |

## 17. ZONE 6: VOID RIFT (Void) · quests: easy

**Look:** floating dark islands, purple rifts, glowing runes (darker, never black). **Shrine:** 800 Power/s. **Egg:** 100M coins.

| Monster | HP | Behaviour | Drops (coins) | XP per kill |
|---|---|---|---|---|
| **Void Mite** | 21M | packs; blinks short distances | 1 Shard (300K) | 243 |
| **Shade Stalker** | 210M | teleports, then pounces down a red lane | 3 Shards + 20% Bright (4M) | 972 |
| **Rift Behemoth** | 2.1B | slam + a pulling rift | 8 Shards + 2 Bright + 10% Gem (25M) | 3,645 |

**Egg: Void Rift pets** (Strength ×32; every Secret-or-rarer pet is serialized):

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
| ??? (Null Wyrm) | Secret | 1 in 2.5M | 3,200 |
| ??? (Abyssal Emperor) | Divine | 1 in 120M | 12.8K |
| ??? (The Void Itself) | Impossible | 1 in 12B | 64K |
| **Boundless** (this month's, the same in every egg) | Boundless | 1 in 1T | 3.2M |

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

**Boss: VOID LEVIATHAN** (recommended Power 1B)
- **HP:** plates 6 × 8.25B; body 50B.
- **Rage:** a black hole pulls you in (walk against it) and portals spit tentacles: **blast a portal** to send the tentacle back.
- **Reward:** form **ECLIPSE** (dark ring with violet fire); **Boss Shards worth 4.5B coins** (about 3 Galaxy Throne eggs).

**At the boss** (average free player, median):

| Time | Power | Slots | Best pet | Best stars | Best level | Bag |
|---|---|---|---|---|---|---|
| **~2 h 49** | 1B | 10 | Epic | ★★★ | 30 | 500 |

## 18. ZONE 7: GALAXY THRONE (Cosmic) · quests: medium

**Look:** a throne room in space, nebula skies, orbiting planets. **Shrine:** 4,000 Power/s. **Egg:** 1.5B coins.

| Monster | HP | Behaviour | Drops (coins) | XP per kill |
|---|---|---|---|---|
| **Star Mote** | 336M | packs; orbit each other | 1 Shard (3M) | 729 |
| **Comet Beast** | 3.36B | charges with a fiery tail lane | 3 Shards + 20% Bright (40M) | 2,916 |
| **Nebula Giant** | 33.6B | slam + a gravity well | 8 Shards + 2 Bright + 10% Gem (250M) | 10.9K |

**Egg: Galaxy Throne pets** (Strength ×64; every Secret-or-rarer pet is serialized):

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
| ??? (Starborn Titan) | Secret | 1 in 5M | 6,400 |
| ??? (Galaxy Devourer) | Divine | 1 in 300M | 25.6K |
| ??? (Big Bang) | Impossible | 1 in 50B | 128K |
| **Boundless** (this month's, the same in every egg) | Boundless | 1 in 1T | 6.4M |

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

**Boss: STAR EMPEROR** (recommended Power 15B)
- **HP:** plates 6 × 124B; body 750B.
- **Rage:** meteor showers (many red circles) and constellation nodes: **blast the nodes in the shown order** to drop a meteor on him.
- **Reward:** form **COSMIC** (starfield aura with orbiting planets); **Boss Shards worth 75B coins** (about 3 Celestial Gate eggs).

**At the boss** (average free player, median):

| Time | Power | Slots | Best pet | Best stars | Best level | Bag |
|---|---|---|---|---|---|---|
| **~4 h 07** | 15.1B | 10 | Epic | ★★★ | 30 | 500 |

## 19. ZONE 8: CELESTIAL GATE (Holy light) · quests: medium

**Look:** white-gold cloud temples, halos, giant gates of light. **Shrine:** 20K Power/s. **Egg:** 25B coins.

| Monster | HP | Behaviour | Drops (coins) | XP per kill |
|---|---|---|---|---|
| **Halo Sprite** | 5.37B | packs; spinning halos | 1 Shard (30M) | 2,187 |
| **Seraph Knight** | 53.7B | lance charge down a red lane | 3 Shards + 20% Bright (400M) | 8,748 |
| **Celestial Guardian** | 537B | slam + a ring of light beams | 8 Shards + 2 Bright + 10% Gem (2.5B) | 32.8K |

**Egg: Celestial Gate pets** (Strength ×128; every Secret-or-rarer pet is serialized):

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
| ??? (The First Light) | Secret | 1 in 3M | 12.8K |
| ??? (Seraph Prime) | Divine | 1 in 200M | 51.2K |
| ??? (Eternal Halo) | Impossible | 1 in 20B | 256K |
| **Boundless** (this month's, the same in every egg) | Boundless | 1 in 1T | 12.8M |

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

**Boss: ARCHANGEL SENTINEL** (recommended Power 200B)
- **HP:** plates 6 × 1.65T; body 10T.
- **Rage:** sweeping walls of light with one gap, and judgement circles that follow you: **PERFECT its raised spear** to break the wall.
- **Reward:** form **RADIANT** (white-gold aura with light wings); **Boss Shards worth 750B coins** (about 3 Dragon Sanctum eggs).

**At the boss** (average free player, median):

| Time | Power | Slots | Best pet | Best stars | Best level | Bag |
|---|---|---|---|---|---|---|
| **~5 h 43** | 201B | 10 | Epic | ★★★ | 30 | 500 |

## 20. ZONE 9: DRAGON SANCTUM (Dragon) · quests: hard

**Look:** a gold-and-jade dragon temple on clouds, giant scales, treasure hoards. **Shrine:** 100K Power/s. **Egg:** 250B coins.

| Monster | HP | Behaviour | Drops (coins) | XP per kill |
|---|---|---|---|---|
| **Ember Drakelet** | 85.9B | packs; small fire breaths | 1 Shard (300M) | 6,561 |
| **Crystal Wyvern** | 859B | flies in and dives down a red lane | 3 Shards + 20% Bright (4B) | 26.2K |
| **Elder Dragon Golem** | 8.59T | tail-sweep circle + a fire breath cone | 8 Shards + 2 Bright + 10% Gem (25B) | 98.4K |

**Egg: Dragon Sanctum pets** (Strength ×256; every Secret-or-rarer pet is serialized):

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
| ??? (Primordial Dragon) | Secret | 1 in 6M | 25.6K |
| ??? (Dragon God) | Divine | 1 in 500M | 102K |
| ??? (Endless Wyrm) | Impossible | 1 in 100B | 512K |
| **Boundless** (this month's, the same in every egg) | Boundless | 1 in 1T | 25.6M |

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

**Boss: ELDER DRAGON EMPEROR** (recommended Power 2.5T)
- **HP:** plates 6 × 20.6T; body 125T.
- **Rage:** takes flight and rains fireballs on red circles, then breathes a sweeping cone: **PERFECT the fireballs** to bounce them back.
- **Reward:** form **DRAGONSOUL** (jade-gold aura with a dragon spirit); **Boss Shards worth 10.5T coins** (about 3 Aura Nexus eggs).

**At the boss** (average free player, median):

| Time | Power | Slots | Best pet | Best stars | Best level | Bag |
|---|---|---|---|---|---|---|
| **~7 h 58** | 2.51T | 10 | Epic | ★★★ | 30 | 500 |

## 21. ZONE 10: AURA NEXUS (Every aura) · quests: hard

**Look:** a rainbow void where every zone's light meets; floating pieces of all 9 worlds. **Shrine:** 500K Power/s. **Egg:** 3.5T coins.

| Monster | HP | Behaviour | Drops (coins) | XP per kill |
|---|---|---|---|---|
| **Aura Wisp** | 1.37T | packs; change colour every second | 1 Shard (3B) | 19.7K |
| **Prism Knight** | 13.7T | prism charge down a red lane | 3 Shards + 20% Bright (40B) | 78.7K |
| **Nexus Colossus** | 137T | slam + rings in every element | 8 Shards + 2 Bright + 10% Gem (250B) | 295K |

**Egg: Aura Nexus pets** (Strength ×512; every Secret-or-rarer pet is serialized):

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
| ??? (Spectrum Dragon) | Secret | 1 in 4M | 51.2K |
| ??? (Nexus Sovereign) | Divine | 1 in 300M | 205K |
| ??? (Aura Infinite) | Impossible | 1 in 40B | 1.02M |
| **Boundless** (this month's, the same in every egg) | Boundless | 1 in 1T | 51.2M |

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

**Boss: THE ASCENDANT** (recommended Power 30T)
- **HP:** plates 6 × 248T; body 1.5Qa.
- **Rage:** **every earlier boss's move in turn:** boulders, lava fans, ice pillars, lightning markers, light walls, petal clones, a black hole, meteors, fireballs. The beam clash is golden, against the whole sky.
- **Reward:** form **ASCENDED** (rainbow-white aura, wings of light, a halo); **Boss Shards worth 10.5T coins** (about 3 Aura Nexus eggs).

**At the boss** (average free player, median):

| Time | Power | Slots | Best pet | Best stars | Best level | Bag |
|---|---|---|---|---|---|---|
| **~10 h 57** | 30.1T | 10 | Epic | ★★ | 30 | 500 |

## 22. Progression at a glance (average free player, solo, model medians)

| Zone | Name | Quests | Shrine /s | Egg | Boss (recommended Power) | Finished at | Power then |
|---|---|---|---|---|---|---|---|
| 1 | Training Grove | very easy | 0.5 | 60 | Stone Golem (300) | ~6 min | 315 |
| 2 | Lava Dojo | very easy | 2 | 1,500 | Magma Oni (10K) | ~25 min | 10.3K |
| 3 | Frost Peaks | very easy | 8 | 25K | Frost Wyrm (200K) | ~45 min | 203K |
| 4 | Storm Cliffs | easy | 32 | 400K | Thunder Roc (4M) | ~1 h 18 | 4.03M |
| 5 | Sakura Realm | easy | 160 | 6M | Blossom Ronin (60M) | ~2 h 03 | 60.4M |
| 6 | Void Rift | easy | 800 | 100M | Void Leviathan (1B) | ~2 h 49 | 1B |
| 7 | Galaxy Throne | medium | 4,000 | 1.5B | Star Emperor (15B) | ~4 h 07 | 15.1B |
| 8 | Celestial Gate | medium | 20K | 25B | Archangel Sentinel (200B) | ~5 h 43 | 201B |
| 9 | Dragon Sanctum | hard | 100K | 250B | Elder Dragon Emperor (2.5T) | ~7 h 58 | 2.51T |
| 10 | Aura Nexus | hard | 500K | 3.5T | The Ascendant (30T) | ~10 h 57 | 30.1T |

<!-- ZONES:END -->

---

# PART C: ENDGAME AND LIVE UPDATES

## 23. After zone 10 (endgame)

- **★5 pets** (243 copies) and level-30 teams.
- **Secret+ hunting:** Secret, Divine, Impossible and the monthly **Boundless**, each with its serial.
- **Mutation hunting:** Celestial monsters are 1 in 10,000; Mutation Storms double the chances.
- **Leaderboards:** top Power, most Secrets and Boundless owners, each in the server and globally; the top 3 get statues.
- **Show-off:** the ASCENDED form, the Impossible / Boundless titles, ★5 halos, and a full Rainbow storm.

## 24. Live updates (the plan after launch)

- **A new zone about every 1-2 weeks** (11, 12, …), each with a new egg, monsters, a boss and a form. Each new zone adds roughly 2-4 hours for a free player and is tuned in the model first.
- **Every month:** a new Boundless pet, new Exclusive Egg themes, a new Aura Pass season, and new Limited drops like the Verity items.
- **Later systems** (each keeps the core rules):
  - **Ascension:** reset for a permanent multiplier; keep pets;
  - **global events** on one clock;
  - **boss replays** with Boss Seals (eggs, not coins);
  - **Wild Spirits:** a rare roaming pet mini-boss;
  - **trading:** a safe window, unlocked after boss 2;
  - **World Boss** and the **Infinity Tower**.

---

# PART D: MONEY AND FAIRNESS

## 25. Monetization (summary; full plan in MONETIZATION.md v3)

- **The 2× Boost ladder:** every tier **doubles both Luck and Power**, permanently. 11 tiers, from 3 R$ (×2) to 999 R$ (×2,048).
- **Passes:**

| Pass | R$ |
|---|---|
| **VIP** (title over your head and in chat, ×1.5 coins / Power / hatch speed / Secret luck, +1 slot) | 399 |
| 2× Coins | 399 |
| 2× Secret Luck | 199 |
| 2× Hatch Speed | 399 |
| Hatch ×3 | 99 |
| Hatch ×8 | 399 |
| Huge Storm | 199 |
| Auto-Sell | 199 |
| Offline+ | 99 |
| Mutation Magnet | 99 |

  **Auto-Hatch is free.**
- **Repeatable products:**
  - **+2 Pet Slots:** 199 R$, up to 10 times;
  - **potions:** Luck / Power / Coin 25 (5 for 99), XP 19, Mega 65;
  - **server boosts:** Mutation Storm 99, Server Luck Boost 199;
  - **coin packs:** 49 / 149 / 449 / 999.
- **Exclusive Eggs:**
  - **Daily Exclusive:** also free from rewards; 49 / 99 / 249;
  - **Shop Exclusive:** 99 / 279 / 849;
  - both use the tier system, with a Boundless line, and have no Huge or Titanic.
- **Limited:** only the Verity pet and aura for now (a meme, so no licence; our own art), serialized to #1,000.
- **Aura Pass:** 799 R$ (+799 to skip straight to the end).
- **Packs:** Starter 49, Zone 149, Comeback 99.
- **Free rewards:** hourly, daily (missed days never reset the cycle) and group rewards.
- **Pop-ups:** only two: the 3 R$ 2× Boost after your first meditation, and the Zone Pack when you enter a new zone.
- **What payers get (model, all 10 zones):**

| Spend | All 10 zones |
|---|---|
| free | ~10 h 50 |
| starter (31 R$) | 6 h 41 |
| VIP set (1,085 R$) | 3 h 23 |
| whale (7,263 R$) | 3 h 14 |

## 26. Fairness, safety and saving (details in CORE-GAME.md)

- **No losses:** nothing you own can be lost or stolen. A knockout costs time only.
- **Personal loot:** everyone whose hit lands gets their own drop and quest credit.
- **Server authority:** the server owns every number. Blasts, Focus taps, meditation, rewards and purchases are checked.
- **Saving has three outcomes:**
  - **confirmed saved:** you see the result;
  - **confirmed not saved:** "nothing was spent, try again";
  - **unknown:** the cost is held while the game checks.

  A result is never shown before it's safely saved. Serials are assigned inside that same save.
