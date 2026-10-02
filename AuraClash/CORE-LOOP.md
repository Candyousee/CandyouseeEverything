# AURA CLASH: Core Loop v5.1 (the rules and numbers of the two-zone test)

**Authority:** this file is the single source for the core rules and numbers. Every number here is a constant in `econ/model.py` (run `python model.py` for the results, `python tests.py` for the 19 rule checks). If you change a rule, change the model constant and this file in the same commit. Systems outside the core loop (eggs in detail, aura, saving, playtest, later content) are in `CORE-GAME.md`.

**v5.1 decisions (owner, 2 Oct 2026):**
- Power comes from **meditation** (the AFK half);
- you hunt **crystal monsters** (pets tank and fight);
- the bag is **capped** for mobile;
- **mutations** on monsters;
- **Soul Food** levels pets;
- **Bond and Force are cut**;
- pet fusion tiers are **stars**.

---

## 0. The core in one picture

```
        MEDITATE (calm / AFK)                    HUNT (active)
   sit at the Shrine → POWER grows      blast crystal monsters → SHARDS (+ Soul Food)
             │                                        │
             │  Power = your damage                   │  SELL → COINS
             └──────────────► you hunt faster ◄───────┘
                                    │
                            COINS → EGGS → PETS
                   each pet's STRENGTH boosts BOTH halves:
               faster meditation  +  it fights and tanks beside you
                                    │
          rank quests done + enough Power → BOSS → next zone
            (a 4× Shrine, tougher monsters, better loot, a new egg)
```

**The three rules that make it one loop:**
1. **Power only comes from meditating.** Hunting never gives Power.
2. **Coins only come from hunting** (selling shards). Meditating, quests and bosses never give coins.
3. **Pets come from coins and speed up both halves.**

So a meditate-only player has big Power but no new pets and can't finish the rank quests (they need kills and hatches). A hunt-only player has pets but can't reach the boss's Power. **The fastest way is to switch,** and each switch feels good: you come back from meditating and one-shot what was slow before.

| On your screen | What it is | Where it comes from |
|---|---|---|
| **POWER** | your blast damage; your aura's size | meditation only. Never spent, never lost |
| **Shard Storm** (18 / 60) | the shards you're carrying | monsters |
| **COINS** | the only currency | selling shards |
| **PETS** | each shows one number, **Strength** | eggs (coins), quest rewards |
| **Soul Food** (pouch) | levels up pets | monsters (never takes bag space) |

---

## 1. MEDITATE (where Power comes from)

**The Shrine:**
- one Shrine per zone, in its centre, with a ring of glowing **meditation mats** (enough for a full server);
- the **Sell Altar, egg stand and shop** stand around it, so the Shrine is the hub;
- you can **only meditate on a mat.**

**How it looks:** press **MEDITATE** on a mat:
- you sit cross-legged and float, and your aura rises like a slow flame;
- energy streams into you from the zone;
- **your pets sit in a circle around you, meditating in their own poses**;
- the Power counter ticks up and your aura swells.

**Two modes:**

| Mode | What you do | Multiplier |
|---|---|---|
| **AFK** | nothing | ×1 |
| **FOCUS** | a breathing ring grows and shrinks around you; **tap when it's fullest** (the same timing feel as a PERFECT). A good tap = +1 Focus level (max 5 = ×3); a miss = −1 level | up to **×3** (an average player holds about ×2.4) |

**Rate (Power per second) = Shrine rate × Focus × (1 + 0.10 × your equipped pets' total Strength) × (1 + 0.25 × Mat level)**

| | Zone 1 (Training Grove) | Zone 2 (Lava Dojo) |
|---|---|---|
| Shrine rate (AFK) | 0.5 / s | 2 / s |
| Example | 3 Commons, AFK: 0.65 / s (2,340 / hour); with average Focus 1.56 / s | 5 zone-2 Commons, AFK: 4 / s (14,400 / hour) |

You meditate at the Shrine of the zone you're in.

**AFK in game:**
- full AFK rate, for as long as you like;
- Roblox kicks idle players after 20 minutes, so when the idle warning fires, the game rejoins you to a server and sits you back on a mat.

**Offline:**
- you keep meditating at **25% of your AFK rate, for up to 8 hours** (server time; your device clock can't change it);
- on return you see **"WHILE YOU WERE AWAY: +4,210 POWER"** and your aura bursts bigger.

**Why it isn't boring:**
- it's the calm half after hunting;
- it's the social, show-off spot, with everyone's aura flaring in one place;
- Focus is a satisfying rhythm;
- you watch your aura grow.

---

## 2. HUNT (where coins come from)

### 2.1 The blast (the only attack)

| Platform | Aim | Charge |
|---|---|---|
| PC | the monster under your mouse (a white ring); click to switch | hold LMB or Space |
| Mobile | **auto-aim** at the nearest monster in front of you; tap one to switch | hold the big button |
| Gamepad | auto-aim; the right stick switches | hold R2 |

**Hold:** energy gathers in your fists and a ring shrinks around you over **1.2 s**. Then release:

| Release | Damage | What you see |
|---|---|---|
| Too early (0.5-1.0 s) | 0.6 × Power | a small blast |
| **PERFECT** (the glow: the last 0.18 s) | **2 × Power × combo** | a big blast, a screen kick, "PERFECT!", **every pet pounces** |
| Too late | 0.5 × Power, plus a 0.5 s stagger | a fizzle |
| Quick tap (under 0.5 s) | nothing | (auto-clickers are useless) |

- **Combo:** each PERFECT moves it up one level: ×1 → ×1.25 → ×1.5 → ×1.75 → ×2. Any other release moves it **down one level** (not to zero). Flames on your fists show the level.
- **OVERDRIVE:**
  - **5 PERFECTs in a row** = **8 s** (+2 s per Surge level) where **every release counts as PERFECT at ×2**;
  - each blast also hits **at most 2 other monsters next to your target, for 50% each** (a pack of Shardlings has up to 3 nearby, Boars usually 1, Brutes stand alone). Damage beyond a monster's HP is lost: it never turns into extra kills;
  - afterwards the combo sits at ×1.5.
- **One blast cycle is about 1.4 s** (hold + recovery).

### 2.2 Crystal monsters

The animals in each zone have been overgrown by crystals. When defeated they **crack, freeze and shatter into shards.**

**Zone 1, the Training Grove** (shards: Shard 3 coins, Bright Shard 40, Gem 250):

| Monster | HP | Behaviour | Drops | Soul Food |
|---|---|---|---|---|
| **Shardling** (a small crystal slime) | 20 | hops in packs of 3-4; bumps you lightly | 1 Shard | 10% chance of 1 |
| **Crystal Boar** (person-high) | 200 | wanders; when it spots you it **charges down a straight red lane** (0.8 s warning) | 3 Shards + 20% chance of a Bright Shard | 1 |
| **Crag Brute** (house-high) | 2,000 | slow; **slams the ground** (a red circle, 1 s warning) | 8 Shards + 2 Bright + 10% chance of a **Gem** | 3 |

**Zone 2, the Lava Dojo** (shards: Ember Shard 30, Bright 400, Gem 2,500):

| Monster | HP | Behaviour | Drops | Soul Food |
|---|---|---|---|---|
| **Ember Slime** | 400 | packs; leaves short burning puddles | 1 Shard | 10% chance of 1 |
| **Lava Hound** | 4,000 | charges down a red lane | 3 Shards + 20% Bright | 1 |
| **Obsidian Brute** | 40,000 | slams a red circle | 8 Shards + 2 Bright + 10% Gem | 3 |

**Spawns:**
- fixed spawn points: Shardling-type packs respawn every 5 s and Boar-types every 10 s;
- **3 Brutes per zone, each respawning after 30 s**;
- about 30 monsters per zone at most.

**Green HP bars:** a monster's HP bar turns **green** when you'd beat it in about 3 of your blasts (your pets included). That's the nudge to hunt bigger ones.

**They fight back, lightly:**
- you have a health bar; a monster hit takes 10-30% of it (less as your Power outgrows the zone), and it refills fast out of combat;
- **knocked out:** you reappear at the Shrine and **keep everything**, bag included.

**Coins per minute** (model, zone 1, average player, 3 Common pets, no mutations):

| Power | Shardling | Crystal Boar | Crag Brute |
|---|---|---|---|
| 50 | 220 | 276 | 311 (not green, slow) |
| 150 | 267 | 457 | 751 |
| 400 | 287 | 575 | 774 (green; capped by Brute respawns) |

The bigger the monster you can handle, the better the money.

### 2.3 Mutations (the jackpot layer)

Any monster can spawn **mutated**: the same monster with different crystals. A mutated monster is tougher and worth far more.

| Mutation | Chance per spawn | Shard value | HP | How you spot it |
|---|---|---|---|---|
| **Gold** | 1 in 25 | ×5 | ×2 | shiny gold crystals, a gold sparkle trail |
| **Fire** | 1 in 60 | ×10 | ×3 | burning crystals, rising embers |
| **Frost** | 1 in 60 | ×10 | ×3 | icy blue crystals, cold mist |
| **Rainbow** | 1 in 400 | ×25 | ×4 | shifting rainbow crystals + a light beam visible across the zone |
| **Void** | 1 in 2,000 | ×75 | ×6 | dark purple crystals that warp the air; a deep hum |
| **Celestial** | 1 in 10,000 | ×250 | ×8 | starry crystals, a halo; **a server announcement** when it spawns and when it's defeated |

- **Its shards keep the mutation:**
  - they **spin in your Shard Storm in their colour** (gold glints, ember trails, rainbow shimmer), and they're always the first shown among the storm's 12 visible shards;
  - each still takes **1 bag slot**;
  - they sell with a bigger pop ("RAINBOW ×25!").
- **Mutated monsters drop 3× Soul Food.**
- **Odds are exact:** each spawn makes **one roll** against the table, so every mutation's real chance is exactly the shown chance (7.6% of spawns are mutated in total).
- **On average,** mutations add about **+58%** to shard value per kill.
- **Tutorial:** a **Gold Shardling is guaranteed** about 1 minute in, to teach mutations.
- **Later hook:** events can raise mutation chances ("Fire ×5 this hour").

### 2.4 The Shard Storm (your bag, capped for mobile)

- **What it is:** the shards you carry **spin around you as a storm.**

| Bag | Storm |
|---|---|
| Empty | dust at your feet |
| Half | a waist-high ring |
| Nearly full | a head-high tornado |
| **FULL** | **it turns gold and pulses.** Monsters still die (and still drop Soul Food) but drop no shards; the SELL button bounces |

- **Capacity:** **60 → 100 → 150 → 200 → 250 maximum.** Later zones' shards are worth more; bags don't grow huge.
- **Lag-proof:**
  - 4 fixed looks, each 1-2 particle emitters and **at most 12 shard meshes**, whatever the count;
  - other players' storms show only the ring emitter;
  - **Settings → Low effects** turns yours into a simple ring too.
- **Pull radius:** loose shards within 12 studs spiral in. Shards from monsters you earned (pet kills, Overdrive chains) always reach you, however far away they were.

### 2.5 SELL

Press **SELL** (G / gamepad Y) anywhere except a boss fight:
1. you teleport to your zone's Sell Altar;
2. the storm unwinds into the altar while coins roll up (about 1.5 s; Gems and mutations get bigger pops);
3. you teleport straight back.

It takes about 3 s in total.

**"Stay"** keeps you at the Shrine instead, to shop, hatch or **sit down and meditate.** That's the natural switch point between the halves. The first sell always stays (the tutorial shows the shop).

---

## 3. PETS (one number, two jobs)

**Strength = rarity × zone × stars × level**
- **Rarity:**

| Common | Rare | Epic | Legendary | Mythic | Secret |
|---|---|---|---|---|---|
| 1 | 2 | 4 | 10 | 20 | 50 |

- **Zone:** zone 1 pets ×1, zone 2 pets ×2.
- **Stars (fusion):** none ×1, ★ ×3, ★★ ×9.
- **Level:** +5% per level above 1 (level 30 = ×2.45).

The pet card shows only the final Strength.

| Job | Rule |
|---|---|
| **Fight** | each equipped pet hits your target every 1.5 s for **Strength × 4% of your Power**, with its signature move. On your PERFECT, every pet also strikes at once (the team strike) |
| **Tank** | monsters attack whatever is closest, often a pet. A hit pet is **dazed for 2 s** (stars over its head). **Pets never die** |
| **Meditate** | **+10% meditation per point of Strength** equipped |

**Their share of the damage** grows from about 10% early to about half by the end of zone 2 (model: about 41% on average over a first run). Your blasts always matter.

**Behaviour:**

| Moment | What they do |
|---|---|
| Walking | follow you in a loose pack: small ones hop, fliers bob |
| Standing still (2 s+) | huddle around you and relax: sit, nap, play (2-3 idle animations per species) |
| You start charging | perk up into a battle stance |
| Fighting | from your first blast on a target until it dies: dash in, hit, run back. They never attack on their own |
| Meditating | sit in a circle around you |
| SELL teleport | poof along with you |

**Slots:** 3 at the start. Rank quests add 2 in zone 1 and 2 in zone 2 (**7 by the end of zone 2**). **Equip Best** fills them by Strength.

### 3a. Fusion: stars

- **3 copies of the same pet (same species, same stars) → its ★ version: ×3 Strength**, a star badge and a brighter glow.
- **3 ★ copies → ★★: ×9 Strength**, two stars and a sparkling outline.
- **The fused pet keeps the highest level** of the three.
- **Fusion never lowers your team's total Strength.**
- **Auto-fuse** (on by default) fuses unequipped Commons and Rares. Epic and up are fused by hand at the **Fusion Altar** by the Shrine, with a before / after preview.

### 3b. Soul Food (pet levels)

- **Drops:** monsters drop glowing treats in the zone's flavour (**Crystal Berries** in the Grove, **Magma Peppers** in the Dojo). They fly into your **food pouch** (no cap, never the bag).
- **Feeding:**
  - tap **FEED** on a pet, or **Feed All** (shared across your equipped team, lowest level first);
  - **Auto-feed** (on by default) feeds equipped pets as food arrives;
  - the pet gobbles it with a bounce and hearts, and a level-up bursts with "Lv 7!".
- **XP:**
  - 1 Crystal Berry = 1 XP, 1 Magma Pepper = 3 XP (a food's XP depends on the food, wherever you feed it);
  - level n → n+1 costs **2 × n XP**;
  - level 30 (the maximum) is 870 XP in total.
- **Why it matters:**
  - every kill feeds your team;
  - your favourite pet grows with you;
  - early Commons stay useful;
  - it's another reason to hunt the biggest monster you can.

### 3c. Eggs

- **Price:** Zone 1 egg 60 coins; Zone 2 egg 1,500.
- **Odds** (on the egg card): Common 60% / Rare 28% / Epic 10% / Legendary 1.9% / Mythic 0.1% / **??? Secret 1 in 500,000**.
- **Tutorial guarantees:**
  - the **1st hatch is the Light Fox** (Common);
  - **the 3rd hatch is a Rare** if you don't have one yet.
- **Hatches escalate by rarity**, and **the crack colour always shows the true rarity** (details: CORE-GAME 3).

---

## 4. COINS: the shop (by the Shrine)

| Item | Prices | Effect | Helps |
|---|---|---|---|
| **Egg** | 60 (zone 1), 1,500 (zone 2) | a pet | both halves |
| **Bag** (4 levels) | 50, 250, 3,000, 10,000 | 60 → 100 → 150 → 200 → 250 | hunting |
| **Meditation Mat** (5 levels) | 100, 400, 4,000, 12,000, 30,000 | +25% meditation per level | meditating |
| **Surge** (3 levels) | 300, 5,000, 15,000 | +2 s of Overdrive per level | hunting |

Upgrades are account-wide. The cheap levels fit zone 1, and the rest are zone 2 goals.

---

## 5. RANK QUESTS (always one clear next task)

They alternate between the halves and teach the rhythm. **The boss gate opens when all of a zone's quests are done.** Rewards are slots, eggs and food, **never coins or Power.**

| Zone 1 | Reward | Zone 2 | Reward |
|---|---|---|---|
| 1. Focus meditate for 20 s | +1 pet slot | 1. Focus meditate for 60 s | +1 pet slot |
| 2. Defeat 20 Shardlings | a free egg | 2. Defeat 50 Ember Slimes | a free egg |
| 3. Hatch 5 pets | 10 Soul Food | 3. Hatch 8 zone-2 pets | 30 Soul Food |
| 4. Defeat 10 Crystal Boars | +1 pet slot | 4. Defeat 20 Lava Hounds | +1 pet slot |
| 5. Reach 300 Power | **boss gate opens** | 5. Get a pet to level 10 | a free egg |
| | | 6. Reach 10,000 Power | **boss gate opens** |

---

## 6. THE BOSSES (your own instance; about 40-60 s; pets fight too)

Boss HP scales with its **recommended Power (R)**:
- **6 plates of 3.3 × R** each;
- a **body of 20 × R**;
- the Magma Oni has ×2.5 HP.

| Boss | R | Plates | Body |
|---|---|---|---|
| **Stone Golem** (zone 1) | 300 | 6 × 990 | 6,000 |
| **Magma Oni** (zone 2) | 10,000 | 6 × 82,500 | 500,000 |

1. **Armor:** only plate hits count. Every 4 s it **slams**: a red circle for 1 s, then the hit. **Walk out.**
2. **Rage:** the boss's own move:
   - **Golem:** rolls boulders down red lanes (0.8 s warning). Dodge sideways, or **PERFECT a boulder to blast it back** for big damage.
   - **Oni:** throws lava waves in a fan. Jump the gap; a PERFECT on the Oni's glowing fist staggers it.
3. **Beam clash** (the finisher at 0 HP): your beam against its beam.
   - **Start:** the meter starts at **60%, minus 5% per hit you took** in phases 1-2 (never below 30%).
   - **Each blast pushes your beam:** **each PERFECT +12%**, any other release +6%.
   - **The boss pushes back 3% per second** at R. This is scaled by R ÷ your Power, up to 4×, so being under-powered hurts.
   - **Red flash every 4 s:** **TAP in time = +5%**, a miss = −8%.
   - **Win at 100%; lose at 0%** or after 30 s.

**Win rates (model, 2 hits taken):**

| Power ÷ R | 0.5 | 0.75 | 1.0 | 1.5 |
|---|---|---|---|---|
| weak timing | 0% | 28% | 79% | 100% |
| average | 23% | 98% | 100% | 100% |
| strong | 97% | 100% | 100% | 100% |

So a weak player can always win by meditating a bit more.

- **Win:** slow motion, your beam swallows the boss, it shatters. You **transform** (**Spark → BLAZE** from the Golem, **→ INFERNO** from the Oni). The next zone opens and a **free egg** of the new zone waits.
- **Lose:** "You got hit 4 times: dodge the red circles!" (or "Meditate to Power 300 first"), and an instant retry.

---

## 7. THE FIRST 8 MINUTES (model playthrough, average player)

| Time | What happens | Power | Pets |
|---|---|---|---|
| 0:00 | Spawn at the Training Grove Shrine. A glowing mat and a **MEDITATE** hand | 10 | 0 |
| 0:00-0:20 | **Tutorial meditation:** Focus taps, the aura swells, "+40 POWER!" | 50 | 0 |
| 0:20 | The hand points at the Shardlings. First blast; PERFECTs one-shot them | 50 | 0 |
| ~1:00 | The guaranteed **Gold Shardling**: "MUTATION!". Gold shards spin in the storm | 50 | 0 |
| ~1:55 | **Storm full** → first **SELL** (about 400 coins with the gold shards). The first sell stays at the Shrine | 50 | 0 |
| ~2:00 | Eggs: the **Light Fox** first (it hops to your side), the 3rd egg is a guaranteed Rare; a 4th egg. **Bag Lv1 + Mat Lv1** | 50 | 4 |
| ~2:10 | The tutorial points at the **Fusion Altar**: 3 Light Foxes → a **★ Light Fox** | 50 | 2 |
| ~2:30 | Quest 1: Focus meditate for 20 s → +1 slot | ~95 | 2 |
| 2:30-3:15 | Shardlings, then Crystal Boars (the pets tank the charges). First **Overdrive** (strong players get it in the first minute). Quest 2 (20 Shardlings) → a free egg; Soul Food levels the team | ~95 | 3 |
| ~3:15 | Quest 3 (hatch 5 → 10 food) and quest 4 (10 Boars → +1 slot) | ~95 | 3 |
| 3:15-4:50 | Quest 5 needs 300 Power: **sit and Focus meditate about 1.5 min** | ~315 | 3 |
| ~4:50 | **Boss gate opens** | | |
| 4:50-5:40 | **Stone Golem** (about 45 s) | | |
| ~5:40 | KO → **BLAZE**. The Lava Dojo opens with a free Fire egg | ~315 | 4 |
| 5:40-6:40 | Zone 2 quest 1: Focus meditate for 60 s at the 4× Shrine | ~1,100 | 4 |
| 6:40-8:00 | Ember Slimes; Magma Peppers; quest 2 (50 Ember Slimes) → a free Fire egg | ~1,100 | 5 |

This is one seeded run close to the median (`econ` seed 74). Single runs vary: the first Overdrive comes anywhere from 0:30 to 3:30, depending on timing luck.

**Model medians (200 players per profile):**

| Player | First sell | Boss 1 | Boss 2 | Time meditating | Pets' damage share |
|---|---|---|---|---|---|
| weak | 2.6 min | 8.8 min | 30 min | 27% | 52% |
| **average** | **1.7 min** | **5.8 min** | **23 min** | **27%** | **41%** |
| strong | 1.4 min | 4.9 min | 19 min | 27% | 36% |

These are **model targets, not promises**: the playtest decides. The model plays solo (crowded servers pay faster; see 8).

**A normal session after the tutorial:**
1. hunt until the storm is full, then sell;
2. hatch, upgrade and feed;
3. meditate when the next monster isn't green yet (Focus, or AFK while you do something else);
4. hunt again, stronger.

Log off on a mat to keep meditating offline.

---

## 8. RULES THAT CLOSE THE GAPS

| Question | Rule |
|---|---|
| Several players hit the same monster? | **Shared monsters, personal loot:** everyone who damaged it gets **their own full drop** (shards, food, the mutation) **and quest credit**. Nothing is split, so a newcomer next to a veteran never loses a kill or quest progress. (Helping is rewarded: in a crowded zone everyone earns a bit faster. The model plays solo, so it's conservative; watch it in playtests) |
| Shards from far away (pets, chains)? | They always reach you; the 12-stud pull is only the visual spiral |
| Where can I meditate? | Only on Shrine mats |
| Do pets attack on their own? | No: only from your first blast on a target until it dies |
| Who judges PERFECT / Focus timing? | Your device (lag never ruins it); the server checks it's humanly possible (CORE-GAME 7) |
| SELL in a boss fight? | No: it's greyed out |
| Bag full during Overdrive? | Overdrive continues (Soul Food still drops); the storm turns gold |
| Do mutated shards take more space? | No: 1 shard = 1 slot |
| Does AFK skip the game? | No: AFK gives Power only. Quests need kills and hatches (coins come only from hunting); bosses must be played |
| Are coins ever given for free? | No. Coins come only from selling shards (quests and bosses give slots, eggs and food) |

## 9. LAG BUDGET (mobile first)

- About 30 monsters per zone; simple server logic (move, telegraph, hit), animation on the client.
- Pets are client-side visuals; the server computes their damage as numbers.
- **Storm:**
  - yours is at most 12 meshes + 2 emitters, with mutated shards shown first;
  - others' storms are 1 emitter each;
  - a Low effects option.
- **Mutations:** one emitter per mutated monster; the Rainbow+ light beam is a single beam part.
- **Others' pets at a distance:** a simple follow, no idle animations.
- **Target:** 60 fps on a mid-range phone with a full server at the Shrine.

## 10. WHY THE LOOP HOLDS

| Second to second | Minute to minute | 5-10 minutes | Days |
|---|---|---|---|
| PERFECT timing, combo, Overdrive chains, pets pouncing, monsters shattering, a mutation sparkling into view | storm full → SELL → hatch / upgrade / feed; the next monster turns green | meditate → come back stronger → boss → new zone | offline meditation, ★★ goals, level 30 pets, Secret hunting, new zones |

**Still to prove in playtest #1 (CORE-GAME 9):**
- whether blasting monsters feels great for 20+ minutes;
- **whether players switch between hunting and meditating on their own** (if they only hunt: raise the Shrine rate; if they only sit: raise the monster loot);
- whether Focus meditation is enjoyable, not a chore;
- whether the SELL rhythm feels like a cash-in, not an interruption.
