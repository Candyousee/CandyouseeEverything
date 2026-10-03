# AURA CLASH: GAME BIBLE v6 (everything in the game, zone by zone)

**Authority:** this is the master document for every rule and number in the game. Every number comes from `econ/model.py`; `python tests.py` runs the 25 rule checks. Change a number = change the model constant and this file in the same commit.

**Other docs:**
- `MONETIZATION.md`: everything that's sold.
- `CORE-GAME.md`: server authority, saving, tests, playtest, performance.
- `STYLE-SHEET.md`: the look.
- `GAME-PLAN.md`: market and build order.

**v6 owner changes (2 Oct 2026):**
- **Pets:**
  - pets go up to **5 stars**;
  - **XP goes automatically to equipped pets** (Soul Food is gone);
  - a new **Divine** rarity (1 in 10,000); Secret is now **1 in 1,000,000**.
- **Progress:**
  - **quest difficulty by zone:** very easy, easy, medium, hard;
  - **bosses drop Boss Shards** (sold for coins) instead of a free egg.
- **Removed:** the protected beginner pack. Monetization is now designed (MONETIZATION.md).

**Contents:**
- **Part A, how the game works:** sections 1-11.
- **Part B, zone by zone:** sections 12-20.
- **Part C, endgame and later:** sections 21-22.
- **Part D, money and fairness:** sections 23-24.

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

**The three core rules:**
1. **Power only comes from meditating.** Hunting never gives Power.
2. **Coins only come from selling shards.** Monster shards and Boss Shards both count. Quests never give coins.
3. **Pets come from coins (eggs) and quest rewards,** and speed up both halves.

**On screen:**

| Element | What it is |
|---|---|
| **Power** | your damage and aura size; never lost |
| **Coins** | the only currency |
| **Shard Storm counter** | 18 / 60 |
| **SELL button** | sells your storm |
| **Quest bar** | your current rank quest |
| **Pet bar** | your equipped pets |
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

- **Combo:** each PERFECT steps it up: ×1 → 1.25 → 1.5 → 1.75 → 2. Any other release steps it down one level. Flames on your fists show the level.
- **OVERDRIVE:** 5 PERFECTs in a row give **8 s of real time** (+2 s per Surge level).
  - **Timing:** the 8 s start when the 5th PERFECT lands, and they keep running while you walk, sell, hatch or meditate.
  - **Effect:** every release counts as PERFECT at ×2, and also hits **at most 2 monsters next to your target for 50%**. Damage beyond a monster's HP is lost.
  - **Afterwards:** the combo sits at ×1.5.

## 3. Meditation (Power)

- **The Shrine:** every zone has one in its centre, a ring of glowing mats with room for a full server. The Sell Altar, egg stand, shop, Fusion Altar and the server leaderboard stand around it.
- **Mats only:** you can only meditate on a mat.
- **What it looks like:** you sit and float, your aura rises like a slow flame, and energy streams in. Your pets sit in a circle around you. Your Power ticks up and your aura grows.

| Mode | What you do | Multiplier |
|---|---|---|
| AFK | nothing | ×1 |
| **Focus** | a breathing ring grows and shrinks; tap when it's fullest. Good tap = +1 Focus level (max 5); a miss = −1 | up to ×3 (an average player holds about ×2.4) |

- **Power per second** = Shrine rate × Focus × (1 + 0.10 × your equipped pets' total Strength) × (1 + 0.25 × Mat level).
- **Shrine rates** (AFK): ×4 per zone, from 0.5/s in zone 1 to 8,192/s in zone 8 (see each zone).
- **AFK in game:** full rate. Before Roblox's 20-minute idle kick, the game rejoins you to a server and sits you back on a mat.
- **Offline:** 25% of your AFK rate, for up to 8 hours, timed by the server. On return: "WHILE YOU WERE AWAY: +X POWER" and an aura burst.

## 4. Hunting (coins)

### 4.1 Crystal monsters
Every zone has **3 monster types**: small (packs of 3-4), middle (pairs) and big (alone).

- **Defeated monsters** crack, freeze and **shatter into shards**.

| Type | Behaviour | HP | Drops | XP to each equipped pet |
|---|---|---|---|---|
| Small | hops in packs; bumps lightly | 20 × 16^(zone−1) | 1 Shard | 1 × 3^(zone−1) |
| Middle | charges down a red lane (0.8 s warning) | 200 × 16^(zone−1) | 3 Shards + 20% chance of a Bright Shard | 4 × 3^(zone−1) |
| Big | slams a red circle (1 s warning) | 2,000 × 16^(zone−1) | 8 Shards + 2 Bright + 10% chance of a Gem | 15 × 3^(zone−1) |

- **Shard values** (coins): Shard 3, Bright Shard 40, Gem 250 in zone 1, **×10 every zone**.
- **Spawns:**
  - packs respawn in 5 s and pairs in 10 s;
  - **3 Big monsters per zone, each respawning in 30 s**;
  - at most about 30 monsters per zone.
- **Green HP bars:** a monster's HP bar turns **green** when you'd beat it in about 3 of your blasts (pets included). That's the signal to hunt bigger.
- **They hit back lightly:**
  - a hit takes 10-30% of your health, which refills fast out of combat;
  - **if you're knocked out:** you reappear at the Shrine and keep everything.
- **Shared monsters, personal loot:** everyone whose hit lands gets **their own full drop and quest credit**. Nothing is split. (The protected beginner pack is removed, owner decision. If playtests ever show beginners being crowded out, the fix is more spawn points.)

### 4.2 Mutations (same in every zone)
Each spawn makes **one roll** against this table, so the shown chance is the real chance. 7.6% of spawns are mutated.

| Mutation | Chance | Shard value | HP | Look |
|---|---|---|---|---|
| Gold | 1 in 25 | ×5 | ×2 | shiny gold crystals, a gold sparkle trail |
| Fire | 1 in 60 | ×10 | ×3 | burning crystals, embers |
| Frost | 1 in 60 | ×10 | ×3 | icy blue crystals, mist |
| Rainbow | 1 in 400 | ×25 | ×4 | shifting rainbow crystals + a light beam visible across the zone |
| Void | 1 in 2,000 | ×75 | ×6 | dark purple crystals that warp the air; a deep hum |
| Celestial | 1 in 10,000 | ×250 | ×8 | starry crystals, a halo; a **server announcement** on spawn and defeat |

- **The shards keep the mutation:** they spin glowing in your storm and are always shown first. Each still takes 1 bag slot.
- **Selling:** they sell with a bigger pop ("RAINBOW ×25!").
- **On average,** mutations add about **+58%** to shard value.
- **Tutorial:** a **Gold Shardling** is guaranteed about 1 minute in.

### 4.3 The Shard Storm (your bag) and SELL
- **The storm:** your shards spin around you, growing from dust to a ring to a tornado. When full, it turns **gold and pulses**: monsters still die and still give XP, but drop no shards.
- **Capacity:** 60 at the start, up to **500** with Bag upgrades (section 7).
- **Lag-proof:** 4 fixed looks, at most 12 shard meshes and 2 emitters for you, 1 emitter for other players. A "Low effects" setting turns yours into a simple ring.
- **SELL** (button, G, or gamepad Y; not in boss fights):
  1. you teleport to the Sell Altar;
  2. the storm pours in while the coins roll up (about 3 s in total);
  3. you teleport back.

  **"Stay"** keeps you at the Shrine to shop, hatch, fuse or meditate.

## 5. Pets

### 5.1 Rarities and egg odds (the same in every zone's egg)

| Rarity | Chance | Base Strength |
|---|---|---|
| Common | 60% | 1 |
| Rare | 28% | 2 |
| Epic | 10% | 4 |
| Legendary | 1.8899% | 10 |
| Mythic | 0.1% (1 in 1,000) | 20 |
| **Divine** | **0.01% (1 in 10,000)** | **40** |
| **Secret** | **0.0001% (1 in 1,000,000)**, shown as "???" | **100** |

The odds above add to exactly 100%. Luck boosts (MONETIZATION.md) multiply Legendary-and-up and take the difference from Common; the egg card always shows your current real odds.

### 5.2 Strength (the one number on every pet card)

**Strength = base × zone × stars × level**
- **Zone:** zone 1 pets ×1, and **×2 for every zone after** (a zone-8 pet is ×128).
- **Stars:** see 5.4.
- **Level:** +5% per level above 1 (level 30 = ×2.45).

### 5.3 What pets do

| Job | Rule |
|---|---|
| **Fight** | each equipped pet hits your target every 1.5 s for **Strength × 4% of your Power**, with its own move. On your PERFECT they all strike at once. **The whole team's hit is capped at 100% of your Power**, so your blasts always matter |
| **Tank** | monsters attack whatever is closest; a hit pet is **dazed for 2 s**. **Pets never die** |
| **Meditate** | **+10% meditation per point of equipped Strength.** No cap: this is where big pets keep paying off |

**Behaviour:**
- they follow you in a loose pack;
- they relax and play when you stand still;
- they snap into a battle stance when you charge;
- they attack only from your first blast on a target until it dies;
- they sit in a circle when you meditate;
- they poof along when you SELL.

- **Slots:** 3 at the start, up to **10** from rank quests (5 after zone 1, 7 after zone 2, then +1 in each of zones 3, 4 and 5). **Equip Best** fills them by Strength.
- **Inventory:** 250 pets. **Auto-delete** (a setting, on by default for unequipped Commons and Rares of earlier zones) keeps room. Lock favourites to protect them.

### 5.4 Stars (fusion), up to 5

| Stars | Strength | Copies needed (of the same pet) |
|---|---|---|
| none | ×1 | 1 |
| ★ | ×2 | 3 |
| ★★ | ×4 | 9 |
| ★★★ | ×8 | 27 |
| ★★★★ | ×16 | 81 |
| ★★★★★ | ×32 | 243 |

- **How it works:** 3 copies of the same pet with the same stars make 1 of the next star. The new pet **keeps the highest level** of the three. **Fusion never lowers your team.**
- **Looks:** each star adds a visible upgrade (a star badge, a brighter glow, a sparkling outline, a crown, then a full animated star halo at ★5).
- **Auto-fuse** (on by default): unequipped Commons and Rares.
- **Fusion Altar** (by the Shrine): Epic and up, with a before / after preview.

### 5.5 Levels and XP (no food)

- **XP is automatic:** every monster you defeat gives XP to **every equipped pet**: small 1, middle 4, big 15 in zone 1, **×3 every zone**.
- **Level cost:** n → n+1 costs **10 × n × 3^(pet's zone − 1)** XP, so later-zone pets need more but earn more in their own zone.
- **Maximum:** level 30. A level-up shows a sparkle burst and "Lv 7!", and leveled pets look slightly bigger and brighter.
- **Model check:** an average player's best pets reach level 30 by zone 3.

## 6. Eggs and hatching

- **Where and how much:** each zone's egg stand sits by its Shrine. The price rises every zone (see each zone).
- **Hatch counts:** Hatch ×1 to start; **Hatch ×3** unlocks free after boss 1; Hatch ×8 and Auto-Hatch are a pass (MONETIZATION.md).
- **Guarantees** (saved, so they can't repeat or be skipped by rejoining):
  - the **1st hatch ever is the Light Fox**;
  - the **3rd hatch is a Rare** if you have none.
- **The crack colour always shows the true rarity.** No fake near-misses.

| Result | Hatch |
|---|---|
| Common (1.5 s) | pop, puff, the pet hops out |
| Rare (2 s) | blue cracks, a glow burst |
| Epic (3 s) | purple cracks, the egg levitates, lightning |
| Legendary (4 s) | gold cracks, the sky dims around you, a gold pillar, a **server announcement** |
| Mythic (6 s, unskippable the first time) | **cutscene:** the world freezes, a vortex, the pet forms from raw energy, a shockwave, a server announcement with your name |
| **Divine (8 s, unskippable the first time)** | **cutscene:** a golden sky floods the **whole server**, angelic choir, wings of light, a **global announcement in every server** |
| **Secret (10 s, unskippable the first time)** | **cutscene:** the screen cracks, silence, a "???" card, the server's sky changes for 10 s, a unique entrance, a global announcement, and a permanent "Secret Holder" title |

- **Secrets:** the egg card shows "??? 1 in 1,000,000". After the first hatch anywhere, it shows the silhouette and "First hatched by ___".

## 7. The shop (by every Shrine; account-wide upgrades)

**Bag** (storm capacity):

| Level | 1 | 2 | 3 | 4 | 5 | 6 | 7 |
|---|---|---|---|---|---|---|---|
| Capacity (from 60) | 100 | 150 | 200 | 250 | 300 | 400 | 500 |
| Price | 50 | 250 | 3K | 10K | 100K | 2M | 50M |

**Meditation Mat** (+25% meditation per level):

| Level | 1 | 2 | 3 | 4 | 5 | 6 | 7 | 8 | 9 | 10 |
|---|---|---|---|---|---|---|---|---|---|---|
| Price | 100 | 400 | 4K | 12K | 150K | 1M | 20M | 400M | 10B | 250B |

**Surge** (+2 s Overdrive per level):

| Level | 1 | 2 | 3 | 4 | 5 |
|---|---|---|---|---|---|
| Price | 300 | 5K | 200K | 30M | 5B |

**Eggs:** priced per zone (see each zone).

Number short forms: K = thousand, M = million, B = billion, T = trillion.

## 8. Rank quests (always one clear next task)

- **The gate:** a zone's boss gate opens when **all its quests are done**. The last quest is always "Reach X Power".
- **Rewards:** **pet slots** (until you have 10), otherwise **a free egg of that zone**. Never coins or Power.
- **Difficulty by zone (owner):**

| Zones | Difficulty | Quests per zone |
|---|---|---|
| 1-3 | **very easy** | 5-6 |
| 4-6 | **easy** | 7 |
| 7 | **medium** | 8 |
| 8 | **hard** | 9 |

> **Note:** you wrote "very easy for the first 4 zones, easy for 4-6". I read that as **very easy 1-3, easy 4-6, medium 7, hard 8**. If you meant zone 4 to be very easy too, it's a one-line change.

The full quest list is in each zone below.

## 9. Bosses (general rules)

- **Your own instance,** about 40-90 s. Your pets fight too. No SELL during the fight.
- **HP scales with the boss's recommended Power (R):**
  - **6 armor plates of 3.3 × R** each, and a **body of 20 × R**;
  - every boss after the Golem has **×2.5 HP**.
- **Phases:**
  1. **Armor:** only plate hits count. Every 4 s it **slams** a red circle: walk out. Each hit you take costs 5% of your starting beam meter.
  2. **Rage:** the boss's own mechanic (see each zone).
  3. **Beam clash:**
     - **start:** the meter starts at **60%, minus 5% per hit** taken (never below 30%);
     - **pushing:** **PERFECT +12%**, any other release +6%;
     - **push-back:** the boss pushes back **3%/s** at R (×R ÷ your Power, up to ×4);
     - **counters:** a red flash every 4 s: tap in time **+5%**, miss −8%;
     - **end:** win at 100%, lose at 0% or after 30 s.

**Model win rates** (2 hits taken):

| Power ÷ R | 0.5 | 0.75 | 1.0 | 1.5 |
|---|---|---|---|---|
| weak timing | 0% | 28% | 79% | 100% |
| average | 23% | 98% | 100% | 100% |
| strong | 97% | 100% | 100% | 100% |

- **Win:**
  - slow motion, the boss shatters, and you **transform** to the zone's form;
  - **Boss Shards burst into your storm** (they don't count against the bag cap), worth about **3 eggs of the next zone**. You sell them at that zone's altar like any shards;
  - the next zone's portal opens.
- **Lose:** you're told exactly why ("You got hit 4 times: dodge the red circles!" or "Meditate to Power X first") and can retry instantly.
- **Replays:** bosses can be replayed, but Boss Shards come only from the first win (replay rewards are Later, section 22).

## 10. Your aura

- **Size:** radius = 2.5 + 0.5 × log10(Power) studs.

| Power | 10 | 300 | 10K | 1M | 1B | 400B |
|---|---|---|---|---|---|---|
| Radius (studs) | 3.0 | 3.7 | 4.5 | 5.5 | 7.0 | 8.3 |

- **Effects:** meditation makes it pulse; every ×10 Power gives a burst.
- **Forms** (one per boss; each changes the shape, colour and flame style):

| Start | Z1 | Z2 | Z3 | Z4 | Z5 | Z6 | Z7 | Z8 |
|---|---|---|---|---|---|---|---|---|
| Spark | BLAZE | INFERNO | GLACIER | TEMPEST | BLOOM | ECLIPSE | COSMIC | **ASCENDED** |

- **Transformation:** a 2.5 s cutscene, a shockwave and the form's name in big letters.

## 11. HUD, settings, tutorial

- **HUD:**
  - Power (top centre), coins, the storm counter, SELL;
  - the blast button (mobile), the quest bar, the pet bar;
  - the Focus ring while meditating, and green HP bars;
  - mutation names over mutated monsters;
  - the "WHILE YOU WERE AWAY" card;
  - the server leaderboard (top Power) at the Shrine.
- **Menus:**
  - Pets (Equip Best, auto-fuse / auto-delete toggles, locks, Fuse);
  - Shop; Egg card (real odds); Store (MONETIZATION.md); Settings.
- **Settings:** Low effects, others' effects, show others' pets, camera shake, reduced flashing.
- **Tutorial:**
  - a pulsing hand points at the one next thing: MEDITATE → a Shardling → SELL → the egg → the quest bar;
  - labels are 1-3 words;
  - progress is saved, so a rejoin resumes it;
  - the first meditation is a fixed +40 Power over 20 s.

---

# PART B: ZONE BY ZONE

**What "at the boss" means:** each zone ends with the average player's state at that boss win. These are model medians for a free player playing solo (`econ/RESULTS.txt` section 4). They're targets for tuning, **not promises**.

## 12. ZONE 1: TRAINING GROVE (Light) · quests: very easy

**Look:** mint grass, a warm path, soft light, crystal-overgrown animals. **Shrine:** 0.5 Power/s. **Egg:** 60 coins.

| Monster | HP | Behaviour | Drops (coins) | XP per kill |
|---|---|---|---|---|
| **Shardling** (small crystal slime) | 20 | hops in packs | 1 Shard (3) | 1 |
| **Crystal Boar** | 200 | charges a red lane | 3 Shards + 20% Bright (40) | 4 |
| **Crag Brute** | 2,000 | slams a red circle | 8 Shards + 2 Bright + 10% Gem (250) | 15 |

**Egg: Light pets** (Strength ×1):

| Rarity | Pet(s) | Strength |
|---|---|---|
| Common | **Light Fox** (tutorial), Glow Bunny | 1 |
| Rare | Prism Owl, Sun Pup | 2 |
| Epic | Halo Lynx | 4 |
| Legendary | Dawn Griffin | 10 |
| Mythic | Solar Kirin | 20 |
| Divine | Radiant Pegasus | 40 |
| Secret | ??? (Aurora Dragon) | 100 |

**Quests:**

| # | Quest | Reward |
|---|---|---|
| 1 | Focus meditate for 20 s | +1 pet slot (4) |
| 2 | Defeat 20 Shardlings | free egg |
| 3 | Hatch 5 eggs | free egg |
| 4 | Defeat 10 Crystal Boars | +1 pet slot (5) |
| 5 | Reach 300 Power | boss gate opens |

**Boss: STONE GOLEM** (R = 300):
- **HP:** plates 6 × 990; body 6,000.
- **Rage:** rolls boulders down red lanes (0.8 s warning). Dodge sideways, or **PERFECT a boulder to blast it back** for big damage.
- **Reward:** form **BLAZE**; **Boss Shards worth 4,500 coins** (3 Lava Dojo eggs).

**The first 8 minutes** (one model run close to the median, `econ` seed 189):

| Time | What happens | Power |
|---|---|---|
| 0:00-0:20 | Spawn at the Shrine; a "MEDITATE" hand; the tutorial meditation | 10 → 50 |
| 0:20 | The hand points at the Shardlings; PERFECTs one-shot them | 50 |
| ~1:00 | The guaranteed **Gold Shardling**: "MUTATION!" | 50 |
| ~1:25 | First **Overdrive** (it varies: 0:30-3:30 depending on timing luck) | 50 |
| ~1:47 | Storm full, so the first **SELL** (about 365 coins). The first sell stays at the Shrine | 50 |
| ~1:50 | Eggs: the **Light Fox**, then the guaranteed Rare. **Bag Lv1 + Mat Lv1** | 50 |
| ~2:15 | Quest 1: Focus 20 s → +1 slot | ~90 |
| ~2:35 | First pet level-up (XP from kills) | ~90 |
| ~2:55 | Quest 2 (20 Shardlings) → a free egg | ~90 |
| 3:00-4:45 | Crystal Boars (pets tank the charges). Sell 2 → Bag Lv2, Surge Lv1, eggs. First ★ at the altar | ~90 |
| ~4:48 | Quests 3 and 4 done (+1 slot) | ~90 |
| 4:50-5:35 | Quest 5: **sit and Focus meditate about 45 s** | ~325 |
| 5:35-6:05 | **Stone Golem** | |
| ~6:05 | **BLAZE.** Boss Shards sell for 4,500 → Bag Lv3, Mat Lv2. The Lava Dojo opens | ~325 |
| 6:10-7:25 | Zone 2 quest 1: Focus 60 s at the ×4 Shrine | ~2,200 |
| 7:25+ | Ember Slimes; Fire eggs (1,500) | |

**At the boss (average, median):**

| Time | Power | Slots | Best pet | Best stars | Best level | Bag | Eggs hatched here |
|---|---|---|---|---|---|---|---|
| **~6 min** | ~320 | 5 | Epic | ★1 | 5 | 200 | ~24 |

## 13. ZONE 2: LAVA DOJO (Fire) · quests: very easy

**Look:** warm stone, dark rock, rivers of lava, a dojo on a volcano. **Shrine:** 2 Power/s. **Egg:** 1,500 coins.

| Monster | HP | Behaviour | Drops (coins) | XP |
|---|---|---|---|---|
| **Ember Slime** | 320 | packs; leaves short burning puddles | 1 Shard (30) | 3 |
| **Lava Hound** | 3,200 | charges a red lane | 3 Shards + 20% Bright (400) | 12 |
| **Obsidian Brute** | 32,000 | slams a red circle | 8 + 2 Bright + 10% Gem (2,500) | 45 |

**Egg: Fire pets** (Strength ×2):

| Rarity | Pet(s) | Strength |
|---|---|---|
| Common | Ember Imp, Cinder Pup | 2 |
| Rare | Magma Toad, Blaze Ferret | 4 |
| Epic | Lava Salamander | 8 |
| Legendary | Inferno Wolf | 20 |
| Mythic | Phoenix | 40 |
| Divine | Sunforge Drake | 80 |
| Secret | ??? (Volcano Titan) | 200 |

**Quests:**

| # | Quest | Reward |
|---|---|---|
| 1 | Focus meditate for 60 s | +1 slot (6) |
| 2 | Defeat 50 Ember Slimes | free egg |
| 3 | Hatch 8 eggs here | free egg |
| 4 | Defeat 20 Lava Hounds | +1 slot (7) |
| 5 | Get a pet to level 10 | free egg |
| 6 | Reach 10,000 Power | boss gate |

**Boss: MAGMA ONI** (R = 10,000):
- **HP:** plates 6 × 82,500; body 500,000.
- **Rage:** throws lava waves in a fan. Step into the gap; a PERFECT on its glowing fist staggers it.
- **Reward:** form **INFERNO**; **Boss Shards 75,000** (3 Frost eggs).

**At the boss:**

| Time | Power | Slots | Best pet | Best stars | Best level | Bag |
|---|---|---|---|---|---|---|
| **~20 min** | ~10K | 7 | Legendary | ★2 | 19 | 250 |

## 14. ZONE 3: FROST PEAKS (Ice) · quests: very easy

**Look:** snowy pastel peaks, ice crystals, aurora sky. **Shrine:** 8/s. **Egg:** 25,000.

| Monster | HP | Behaviour | Drops (coins) | XP |
|---|---|---|---|---|
| **Snowling** | 5.12K | packs; slides on ice | 1 Shard (300) | 9 |
| **Ice Ram** | 51.2K | charges a red lane, leaves an icy slick | 3 + 20% Bright (4K) | 36 |
| **Glacier Titan** | 512K | slams; ice spikes ring | 8 + 2 Bright + 10% Gem (25K) | 135 |

**Egg: Ice pets** (×4):

| Rarity | Pet(s) | Strength |
|---|---|---|
| Common | Snow Hare, Frost Penguin | 4 |
| Rare | Ice Fox, Glacier Seal | 8 |
| Epic | Crystal Yeti | 16 |
| Legendary | Blizzard Owl | 40 |
| Mythic | Frost Kirin | 80 |
| Divine | Aurora Stag | 160 |
| Secret | ??? (Glacial Leviathan) | 400 |

**Quests:**

| # | Quest | Reward |
|---|---|---|
| 1 | Focus 60 s | +1 slot (8) |
| 2 | Defeat 50 Snowlings | egg |
| 3 | Hatch 8 here | egg |
| 4 | Defeat 20 Ice Rams | egg |
| 5 | Get a pet to level 10 | egg |
| 6 | Reach 200K Power | gate |

**Boss: FROST WYRM** (R = 200K):
- **HP:** plates 6 × 1.65M; body 10M.
- **Rage:** ice breath sweeps a cone (step out of it), and ice pillars crash down on red circles. **PERFECT a pillar** to shatter it into the Wyrm.
- **Reward:** **GLACIER**; Boss Shards **1.2M** (3 Storm eggs).

**At the boss:**

| Time | Power | Slots | Best pet | Best stars | Best level | Bag |
|---|---|---|---|---|---|---|
| **~38 min** | ~206K | 8 | Legendary | ★2 | 30 | 300 |

## 15. ZONE 4: STORM CLIFFS (Lightning) · quests: easy

**Look:** floating cliffs, purple storm clouds, lightning rods. **Shrine:** 32/s. **Egg:** 400K.

| Monster | HP | Behaviour | Drops (coins) | XP |
|---|---|---|---|---|
| **Spark Wisp** | 81.9K | packs; zips around | 1 Shard (3K) | 27 |
| **Thunder Hawk** | 819K | dives down a red lane | 3 + 20% Bright (40K) | 108 |
| **Storm Colossus** | 8.19M | slams + a lightning ring | 8 + 2 Bright + 10% Gem (250K) | 405 |

**Egg: Storm pets** (×8):

| Rarity | Pet(s) | Strength |
|---|---|---|
| Common | Static Mouse, Volt Bat | 8 |
| Rare | Thunder Pup, Zap Lizard | 16 |
| Epic | Storm Falcon | 32 |
| Legendary | Lightning Tiger | 80 |
| Mythic | Thunderbird | 160 |
| Divine | Tempest Dragon | 320 |
| Secret | ??? (Raijin) | 800 |

**Quests:**

| # | Quest | Reward |
|---|---|---|
| 1 | Focus 90 s | +1 slot (9) |
| 2 | Defeat 80 Spark Wisps | egg |
| 3 | Hatch 12 here | egg |
| 4 | Defeat 40 Thunder Hawks | egg |
| 5 | Defeat 5 Storm Colossi | egg |
| 6 | Get a pet to level 15 | egg |
| 7 | Reach 4M Power | gate |

**Boss: THUNDER ROC** (R = 4M):
- **HP:** plates 6 × 33M; body 200M.
- **Rage:** lightning strike markers chase you (keep moving); 4 lightning rods charge it. **Blast the rods** to stun it.
- **Reward:** **TEMPEST**; Boss Shards **18M** (3 Sakura eggs).

**At the boss:**

| Time | Power | Slots | Best pet | Best stars | Bag |
|---|---|---|---|---|---|
| **~1 h 01** | ~4M | 9 | Legendary | ★3 | 400 |

## 16. ZONE 5: SAKURA REALM (Nature) · quests: easy

**Look:** pink blossom forest, koi ponds, torii gates. **Shrine:** 128/s. **Egg:** 6M.

| Monster | HP | Behaviour | Drops (coins) | XP |
|---|---|---|---|---|
| **Petal Sprite** | 1.31M | packs; float on petals | 1 Shard (30K) | 81 |
| **Blossom Fox** | 13.1M | dashes along a red lane | 3 + 20% Bright (400K) | 324 |
| **Ancient Treant** | 131M | root-slam circle | 8 + 2 Bright + 10% Gem (2.5M) | 1,215 |

**Egg: Blossom pets** (×16):

| Rarity | Pet(s) | Strength |
|---|---|---|
| Common | Petal Bunny, Leaf Kit | 16 |
| Rare | Koi Spirit, Bamboo Panda | 32 |
| Epic | Sakura Fox | 64 |
| Legendary | Moss Golem | 160 |
| Mythic | Kitsune | 320 |
| Divine | Jade Dragon | 640 |
| Secret | ??? (Celestial Koi) | 1,600 |

**Quests:**

| # | Quest | Reward |
|---|---|---|
| 1 | Focus 90 s | +1 slot (**10, the maximum**) |
| 2 | Defeat 80 Petal Sprites | egg |
| 3 | Hatch 12 here | egg |
| 4 | Defeat 40 Blossom Foxes | egg |
| 5 | Defeat 5 Ancient Treants | egg |
| 6 | Get a pet to level 15 | egg |
| 7 | Reach 80M Power | gate |

**Boss: BLOSSOM RONIN** (R = 80M):
- **HP:** plates 6 × 660M; body 4B.
- **Rage:** dash-slashes along red lines, and splits into petal clones. **Only the real one has a shadow:** blast it.
- **Reward:** **BLOOM**; Boss Shards **300M** (3 Void eggs).

**At the boss:**

| Time | Power | Slots | Best pet | Best stars |
|---|---|---|---|---|
| **~1 h 42** | ~80M | 10 | Legendary | ★3 |

## 17. ZONE 6: VOID RIFT (Void) · quests: easy

**Look:** floating dark islands, purple rifts, glowing runes. **Shrine:** 512/s. **Egg:** 100M.

| Monster | HP | Behaviour | Drops (coins) | XP |
|---|---|---|---|---|
| **Void Mite** | 21M | packs; blink short distances | 1 Shard (300K) | 243 |
| **Shade Stalker** | 210M | teleports, then pounces down a red lane | 3 + 20% Bright (4M) | 972 |
| **Rift Behemoth** | 2.1B | slam + a pulling rift | 8 + 2 Bright + 10% Gem (25M) | 3,645 |

**Egg: Void pets** (×32):

| Rarity | Pet(s) | Strength |
|---|---|---|
| Common | Shadow Cat, Void Bat | 32 |
| Rare | Rift Wisp, Gloom Wolf | 64 |
| Epic | Shade Panther | 128 |
| Legendary | Void Serpent | 320 |
| Mythic | Eclipse Dragon | 640 |
| Divine | Abyss Kraken | 1,280 |
| Secret | ??? (Null Wyrm) | 3,200 |

**Quests** (slots are maxed, so quest 1 now gives an egg):

| # | Quest | Reward |
|---|---|---|
| 1 | Focus 90 s | egg |
| 2 | Defeat 80 Void Mites | egg |
| 3 | Hatch 12 here | egg |
| 4 | Defeat 40 Shade Stalkers | egg |
| 5 | Defeat 5 Rift Behemoths | egg |
| 6 | Get a pet to level 15 | egg |
| 7 | Reach 1.6B Power | gate |

**Boss: VOID LEVIATHAN** (R = 1.6B):
- **HP:** plates 6 × 13.2B; body 80B.
- **Rage:** a black hole pulls you in (walk against it), and portals spit tentacles. **Blast a portal** to send the tentacle back.
- **Reward:** **ECLIPSE**; Boss Shards **4.5B** (3 Galaxy eggs).

**At the boss:**

| Time | Power | Slots | Best pet |
|---|---|---|---|
| **~2 h 36** | ~1.6B | 10 | Legendary ★2-3, level 30 |

## 18. ZONE 7: GALAXY THRONE (Cosmic) · quests: **medium**

**Look:** a throne room in space, nebula skies, orbiting planets. **Shrine:** 2,048/s. **Egg:** 1.5B.

| Monster | HP | Behaviour | Drops (coins) | XP |
|---|---|---|---|---|
| **Star Mote** | 336M | packs; orbit each other | 1 Shard (3M) | 729 |
| **Comet Beast** | 3.36B | charges with a fiery tail lane | 3 + 20% Bright (40M) | 2,916 |
| **Nebula Giant** | 33.6B | slam + a gravity well | 8 + 2 Bright + 10% Gem (250M) | 10,935 |

**Egg: Cosmic pets** (×64):

| Rarity | Pet(s) | Strength |
|---|---|---|
| Common | Star Puff, Comet Pup | 64 |
| Rare | Nebula Jelly, Meteor Fox | 128 |
| Epic | Galaxy Whale | 256 |
| Legendary | Orbit Lion | 640 |
| Mythic | Supernova Phoenix | 1,280 |
| Divine | Cosmic Dragon | 2,560 |
| Secret | ??? (Starborn Titan) | 6,400 |

**Quests (medium):**

| # | Quest | Reward |
|---|---|---|
| 1 | Focus 120 s | egg |
| 2 | Defeat 150 Star Motes | egg |
| 3 | Hatch 20 here | egg |
| 4 | Defeat 80 Comet Beasts | egg |
| 5 | Defeat 15 Nebula Giants | egg |
| 6 | Defeat 5 mutated monsters (any mutation) | egg |
| 7 | Make a ★★ pet | egg |
| 8 | Reach 25B Power | gate |

**Boss: STAR EMPEROR** (R = 25B):
- **HP:** plates 6 × 206B; body 1.25T.
- **Rage:** meteor showers (many red circles at once). Constellation nodes appear: **blast them in the shown order** to drop a meteor on him.
- **Reward:** **COSMIC**; Boss Shards **75B** (3 Celestial eggs).

**At the boss:**

| Time | Power | Best pet |
|---|---|---|
| **~4 h 14** | ~25B | Legendary ★2, level 30 |

## 19. ZONE 8: CELESTIAL GATE (Divine light) · quests: **hard**

**Look:** white-gold cloud temples, halos, giant gates of light. **Shrine:** 8,192/s. **Egg:** 25B.

| Monster | HP | Behaviour | Drops (coins) | XP |
|---|---|---|---|---|
| **Halo Sprite** | 5.37B | packs; halo spins | 1 Shard (30M) | 2,187 |
| **Seraph Knight** | 53.7B | lance charge down a red lane | 3 + 20% Bright (400M) | 8,748 |
| **Celestial Guardian** | 537B | slam + a ring of light beams | 8 + 2 Bright + 10% Gem (2.5B) | 32,805 |

**Egg: Celestial pets** (×128):

| Rarity | Pet(s) | Strength |
|---|---|---|
| Common | Halo Chick, Angel Bunny | 128 |
| Rare | Seraph Cat, Wing Pup | 256 |
| Epic | Archon Owl | 512 |
| Legendary | Seraph Lion | 1,280 |
| Mythic | Celestial Kirin | 2,560 |
| Divine | Divine Griffin | 5,120 |
| Secret | ??? (The First Light) | 12,800 |

**Quests (hard):**

| # | Quest | Reward |
|---|---|---|
| 1 | Focus 180 s | egg |
| 2 | Defeat 300 Halo Sprites | egg |
| 3 | Hatch 40 here | egg |
| 4 | Defeat 150 Seraph Knights | egg |
| 5 | Defeat 40 Celestial Guardians | egg |
| 6 | Defeat a **Rainbow, Void or Celestial** mutated monster | egg |
| 7 | Make a ★★★ pet | egg |
| 8 | Get a pet to level 25 | egg |
| 9 | Reach 400B Power | gate |

**Boss: THE ASCENDANT** (R = 400B; the final boss):
- **HP:** plates 6 × 3.3T; body 20T.
- **Rage:** mixes every earlier boss's move in turn: boulders, lava fans, ice pillars, lightning markers, petal clones, a black hole, a meteor shower.
- **Beam clash:** golden, against the whole sky.
- **Reward:** **ASCENDED** (the final form: a white-gold aura with wings of light); Boss Shards **75B**; a server-wide announcement; the **"Ascended" title**.

**At the boss:**

| Time | Power | Team Strength | Best pet |
|---|---|---|---|
| **~7 h 11** (weak ~10 h, strong ~6 h 15) | ~400B | ~16.7K | Legendary ★3, level 30 |

## 20. Progression at a glance (average free player, solo, model medians)

| Zone | Name | Difficulty | Shrine /s | Egg | Boss (R) | Finished at | Power then |
|---|---|---|---|---|---|---|---|
| 1 | Training Grove | very easy | 0.5 | 60 | Stone Golem (300) | 6 min | 320 |
| 2 | Lava Dojo | very easy | 2 | 1.5K | Magma Oni (10K) | 20 min | 10K |
| 3 | Frost Peaks | very easy | 8 | 25K | Frost Wyrm (200K) | 38 min | 206K |
| 4 | Storm Cliffs | easy | 32 | 400K | Thunder Roc (4M) | 1 h 01 | 4M |
| 5 | Sakura Realm | easy | 128 | 6M | Blossom Ronin (80M) | 1 h 42 | 80M |
| 6 | Void Rift | easy | 512 | 100M | Void Leviathan (1.6B) | 2 h 36 | 1.6B |
| 7 | Galaxy Throne | medium | 2,048 | 1.5B | Star Emperor (25B) | 4 h 14 | 25B |
| 8 | Celestial Gate | hard | 8,192 | 25B | The Ascendant (400B) | 7 h 11 | 400B |

**Shape of the run:**
- **Fast early:** zones 1-3 in 38 minutes, where the "hook" matters.
- **Steady middle:** zones 4-6 at about 20-55 min each.
- **Long, hard finish:** zones 7-8 at 1.5-3 h each, where long-term players (and payers) live.

**Across the full run:**
- **Meditating:** about 39% of play time.
- **Pet damage:** about 37% (capped below half).
- **Boss Shards:** about 12% of all coins.

**Paid boosts shorten it** (section 23): with the VIP pass zone 8 is done at about 4 h 56; with the full bundle at about 2 h 53.

---

# PART C: ENDGAME AND LATER

## 21. After zone 8 (endgame)

- **★5 pets** (243 copies), level-30 teams, and **Divine / Secret hunting**.
- **Mutation hunting:** Celestial monsters are 1 in 10,000.
- **The leaderboard:** top Power in the server and globally; the top 3 get statues at the Celestial Gate.
- **Show-off:** the ASCENDED form, the Secret Holder title, ★5 halos, and a full-storm Rainbow tornado.

## 22. Later (after the two-zone playtest passes; each keeps the core rules)

| System | Idea |
|---|---|
| **Ascension** | reset Power and zones for a permanent meditation multiplier and a halo; keep pets |
| Global events (one clock, all servers) | "Fire mutations ×5", Secret odds ×5, a Blood Moon… (they change chances only) |
| Boss replays | Boss Seals: a daily replay reward (eggs, not coins) |
| Wild Spirits | a rare roaming pet mini-boss; the final PERFECT catches it |
| Trading | safe trade window, both confirm, 3 s lock, server-validated (unlocks after boss 2) |
| World Boss | server-wide every 30 min; rewards eggs |
| Infinity Tower | endless boss floors |
| Daily streak | eggs / potions / Focus boosts, not coins |
| Sanctum | display your pets and trophies (no income) |

---

# PART D: MONEY AND FAIRNESS

## 23. Monetization (summary; full plan in MONETIZATION.md)

**Sold:**
- **Passes:** VIP, 2× Coins, 2× Meditation, Lucky / Super Lucky, +3 Slots, Hatch ×8 + Auto-Hatch, Huge Storm, Auto-Sell, Offline+.
- **Potions:** coins, luck, meditation, mutation.
- **Server boosts and paid eggs:** Server Luck boosts; **Robux eggs** with exclusive pets (odds shown).
- **Limited pets:** real stock caps.
- **Packs and season:** a Starter Pack, Zone Packs, the **Aura Pass** season, aura cosmetics.
- **Pop-up offers:** at real "want" moments, with a cap on how often.

**The rules that keep it working:**
- **Boosts multiply what you earn by playing.** They never hand out raw coins or Power, so the two-halves loop stays intact.
- **Odds are always shown,** and paid eggs are gated by Roblox's `PolicyService`.
- **Free players can finish everything** (7 h 11 for an average player). Payers get there faster.

## 24. Fairness, safety and saving (details in CORE-GAME.md)

- **No losses:** nothing you own can be lost, stolen or destroyed. A knockout costs time only.
- **Personal loot:** everyone whose hit lands gets their own drop and quest credit.
- **Server authority:** the server owns every number. Blasts, Focus taps and meditation are checked, so auto-clickers and fake hits fail.
- **Saving has three outcomes:**
  - **confirmed saved:** you see the result;
  - **confirmed not saved:** "nothing was spent, try again";
  - **unknown:** your cost is held while the game checks.

  A result is never shown before it's safely saved. A hatch that saved but whose server crashed plays on your next join.
