# AURA CLASH: GAME BIBLE v8 (everything in the game, zone by zone)

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

**v8 owner changes (3 October 2026):**
- **Zones renamed** with one theme, a made-up "-ora" word plus a place: Lumora Grove, Pyrora Dojo, Glacora Peaks, Voltora Cliffs, Blossora Gardens, Nyxora Rift, Astora Throne, Seraphora Gate, Drakora Sanctum, Aurora Nexus. **Every zone now has a detailed art design** (Part B).
- **The hub** (Lumora Plaza) holds the leaderboards, the store and the rewards (section 12).
- **New machines unlock zone by zone** (section 13): Spirit Codex, Enchant Forge, Spirit Nursery (daycare), Star Forge, Mutation Reactor, Aura Forge, Relic Shrine, Infinity Tower, Ascension Gate.
- **Hatch ×3 is free again after boss 1.**
- **Secret and rarer pets scale with you:** Secret = your best pet, Divine ×10, Impossible ×100, Boundless ×1,000.
- **Boss fights are under review** (section 9 lists the options).

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

## 9. Bosses (general rules: under review)

> **Under review (owner isn't 100% sold on the fight).** Below is the current design, which the model uses. Options to pick from, all keeping "beat the boss → form + Boss Shards → next zone":
> - **A. Keep it:** a solo 3-phase fight with the beam clash.
> - **B. Server raid:** everyone in the zone fights the boss together, every 15 min. It's huge on spectacle (dozens of auras and pets at once), you get rewards for taking part, and first clears are per player.
> - **C. Big-monster hunt:** no beam clash; the boss is a giant crystal monster you fight with normal blasting, dodging its telegraphs.
> - **D. Beam clash only:** a short, cinematic timing duel, as the finisher of the zone.
>
> **My pick: B for the final fight of each zone, with a short solo version for players who can't find a group.** Decide after the greybox playtest.

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
| 3 Glacora Peaks | **Enchant Forge**; **trading** in the hub | the Ice Forge | ~23 min |
| 4 Voltora Cliffs | **Spirit Nursery** (daycare) | the Sky Nest | ~43 min |
| 5 Blossora Gardens | **Star Forge** (★3-★5) | the Lantern Shrine | ~1 h 15 |
| 6 Nyxora Rift | **Mutation Reactor** | the Rift Reactor | ~1 h 53 |
| 7 Astora Throne | **Aura Forge** | the Star Anvil | ~2 h 39 |
| 8 Seraphora Gate | **Relic Shrine** | the Halo Vault | ~3 h 57 |
| 9 Drakora Sanctum | **Infinity Tower** | the Dragon Spire | ~5 h 31 |
| 10 Aurora Nexus | **Ascension Gate**, Boundless Hall | the Nexus Core | ~7 h 40 |

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

### 13.11 Trading (after boss 2, in the hub)
- **How it works:** a safe trade window. Both players confirm, there's a 3 s lock, and the server validates and logs every trade.
- **Rules:**
  - items for items only (no Robux);
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
- **Reward:** form **BLAZE** (orange anime flames); **Boss Shards worth 4,500 coins** (about 3 Pyrora Dojo eggs).

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
| 5:35-7:05 | Zone 2 quest 1: Focus 60 s at the ×4 Shrine | ~1,500 |
| 7:05+ | Ember Slimes; Fire eggs (1,500) | |

**At the boss** (average free player, median):

| Time | Power | Slots | Best pet | Best stars | Best level | Bag |
|---|---|---|---|---|---|---|
| **~5 min** | 315 | 5 | Rare | ★★ | 2 | 200 |

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

**Numbers:** Shrine 2 Power/s · Egg 1,500 coins.

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
- **Reward:** form **INFERNO** (red-black flames, heat haze); **Boss Shards worth 75K coins** (about 3 Glacora Peaks eggs).

**At the boss** (average free player, median):

| Time | Power | Slots | Best pet | Best stars | Best level | Bag |
|---|---|---|---|---|---|---|
| **~23 min** | 10.3K | 7 | Epic | ★★ | 18 | 250 |

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

**Numbers:** Shrine 8 Power/s · Egg 25K coins.

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
- **Reward:** form **GLACIER** (icy crystal aura); **Boss Shards worth 1.2M coins** (about 3 Voltora Cliffs eggs).

**At the boss** (average free player, median):

| Time | Power | Slots | Best pet | Best stars | Best level | Bag |
|---|---|---|---|---|---|---|
| **~43 min** | 203K | 8 | Epic | ★★ | 28 | 300 |

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

**Numbers:** Shrine 32 Power/s · Egg 400K coins.

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
- **Reward:** form **TEMPEST** (crackling lightning aura); **Boss Shards worth 18M coins** (about 3 Blossora Gardens eggs).

**At the boss** (average free player, median):

| Time | Power | Slots | Best pet | Best stars | Best level | Bag |
|---|---|---|---|---|---|---|
| **~1 h 15** | 4.03M | 9 | Epic | ★★★ | 30 | 400 |

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

**Numbers:** Shrine 160 Power/s · Egg 6M coins.

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
- **Reward:** form **BLOOM** (swirling blossom aura); **Boss Shards worth 300M coins** (about 3 Nyxora Rift eggs).

**At the boss** (average free player, median):

| Time | Power | Slots | Best pet | Best stars | Best level | Bag |
|---|---|---|---|---|---|---|
| **~1 h 53** | 60.4M | 10 | Epic | ★★★ | 30 | 500 |

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

**Numbers:** Shrine 800 Power/s · Egg 100M coins.

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
- **Reward:** form **ECLIPSE** (dark ring with violet fire); **Boss Shards worth 4.5B coins** (about 3 Astora Throne eggs).

**At the boss** (average free player, median):

| Time | Power | Slots | Best pet | Best stars | Best level | Bag |
|---|---|---|---|---|---|---|
| **~2 h 39** | 1B | 10 | Epic | ★★★ | 30 | 500 |

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

**Numbers:** Shrine 4,000 Power/s · Egg 1.5B coins.

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
- **Reward:** form **COSMIC** (starfield aura with orbiting planets); **Boss Shards worth 75B coins** (about 3 Seraphora Gate eggs).

**At the boss** (average free player, median):

| Time | Power | Slots | Best pet | Best stars | Best level | Bag |
|---|---|---|---|---|---|---|
| **~3 h 57** | 15.1B | 10 | Epic | ★★★ | 30 | 500 |

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

**Numbers:** Shrine 20K Power/s · Egg 25B coins.

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
- **Reward:** form **RADIANT** (white-gold aura with light wings); **Boss Shards worth 750B coins** (about 3 Drakora Sanctum eggs).

**At the boss** (average free player, median):

| Time | Power | Slots | Best pet | Best stars | Best level | Bag |
|---|---|---|---|---|---|---|
| **~5 h 31** | 201B | 10 | Legendary | ★★★ | 30 | 500 |

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

**Numbers:** Shrine 100K Power/s · Egg 250B coins.

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
- **Reward:** form **DRAGONSOUL** (jade-gold aura with a dragon spirit); **Boss Shards worth 10.5T coins** (about 3 Aurora Nexus eggs).

**At the boss** (average free player, median):

| Time | Power | Slots | Best pet | Best stars | Best level | Bag |
|---|---|---|---|---|---|---|
| **~7 h 40** | 2.51T | 10 | Epic | ★★★ | 30 | 500 |

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
| **New in this zone** | the **Ascension Gate** (rebirth; section 13.10) and the **Boundless Hall** (statues of every Boundless owner) |

**Numbers:** Shrine 500K Power/s · Egg 3.5T coins.

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
- **Reward:** form **ASCENDED** (rainbow-white aura, wings of light, a halo); **Boss Shards worth 10.5T coins** (about 3 Aurora Nexus eggs).

**At the boss** (average free player, median):

| Time | Power | Slots | Best pet | Best stars | Best level | Bag |
|---|---|---|---|---|---|---|
| **~10 h 34** | 30.1T | 10 | Epic | ★★ | 30 | 500 |

## 24. Progression at a glance (average free player, solo, model medians)

| Zone | Name | Quests | Shrine /s | Egg | Boss (recommended Power) | Finished at | Power then |
|---|---|---|---|---|---|---|---|
| 1 | Lumora Grove | very easy | 0.5 | 60 | Stone Golem (300) | ~5 min | 315 |
| 2 | Pyrora Dojo | very easy | 2 | 1,500 | Magma Oni (10K) | ~23 min | 10.3K |
| 3 | Glacora Peaks | very easy | 8 | 25K | Frost Wyrm (200K) | ~43 min | 203K |
| 4 | Voltora Cliffs | easy | 32 | 400K | Thunder Roc (4M) | ~1 h 15 | 4.03M |
| 5 | Blossora Gardens | easy | 160 | 6M | Blossom Ronin (60M) | ~1 h 53 | 60.4M |
| 6 | Nyxora Rift | easy | 800 | 100M | Void Leviathan (1B) | ~2 h 39 | 1B |
| 7 | Astora Throne | medium | 4,000 | 1.5B | Star Emperor (15B) | ~3 h 57 | 15.1B |
| 8 | Seraphora Gate | medium | 20K | 25B | Archangel Sentinel (200B) | ~5 h 31 | 201B |
| 9 | Drakora Sanctum | hard | 100K | 250B | Elder Dragon Emperor (2.5T) | ~7 h 40 | 2.51T |
| 10 | Aurora Nexus | hard | 500K | 3.5T | The Ascendant (30T) | ~10 h 34 | 30.1T |

<!-- ZONES:END -->

---

# PART C: ENDGAME AND LIVE UPDATES

## 25. After zone 10 (endgame)

- **Ascension** (section 13.10), the **Infinity Tower** (13.9), ★5 pets (243 copies), level-30 Shiny, mutated, enchanted teams.
- **Secret+ hunting:** Secret, Divine, Impossible and the monthly **Boundless**, each with its serial.
- **Mutation hunting:** Celestial monsters are 1 in 10,000; Mutation Storms double the chances.
- **Leaderboards:** top Power, most Secrets and Boundless owners, each in the server and globally; the top 3 get statues.
- **Show-off:** the ASCENDED form, the Impossible / Boundless titles, ★5 halos, and a full Rainbow storm.

## 26. Live updates (the plan after launch)

- **A new zone about every 1-2 weeks** (11, 12, …), each with a new egg, monsters, a boss and a form. Each new zone adds roughly 2-4 hours for a free player and is tuned in the model first.
- **Every month:** a new Boundless pet, new Exclusive Egg themes, a new Aura Pass season, and new Limited drops like the Verity items.
- **Later systems** (each keeps the core rules):
  - **global events** on one clock;
  - **boss replays** with Boss Seals (eggs, not coins);
  - **Wild Spirits:** a rare roaming pet mini-boss;
  - **trading:** a safe window, unlocked after boss 2;
  - a **World Boss** (if option B in section 9 isn't chosen).

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
- **Limited:** only the Verity pet and aura for now (a meme, so no licence; our own art), serialized to #1,000.
- **Aura Pass:** 799 R$ (+799 to skip straight to the end).
- **Packs:** Starter 49, Zone 149, Comeback 99.
- **Free rewards:** hourly, daily (missed days never reset the cycle) and group rewards.
- **Pop-ups:** only two: the 3 R$ 2× Boost after your first meditation, and the Zone Pack when you enter a new zone.
- **What payers get (model, all 10 zones):**

| Spend | All 10 zones |
|---|---|
| free | ~10 h 35 |
| starter (31 R$) | 6 h 25 |
| VIP set (986 R$) | 3 h 22 |
| whale (7,164 R$) | 3 h 14 |

## 28. Fairness, safety and saving (details in CORE-GAME.md)

- **No losses:** nothing you own can be lost or stolen. A knockout costs time only.
- **Personal loot:** everyone whose hit lands gets their own drop and quest credit.
- **Server authority:** the server owns every number. Blasts, Focus taps, meditation, rewards and purchases are checked.
- **Saving has three outcomes:**
  - **confirmed saved:** you see the result;
  - **confirmed not saved:** "nothing was spent, try again";
  - **unknown:** the cost is held while the game checks.

  A result is never shown before it's safely saved. Serials are assigned inside that same save.
