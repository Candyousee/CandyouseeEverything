# AURA CLASH: the core loop, precisely (v4 detail; starting numbers, to be tuned in the model)

## The loop in one sentence

**Blast crystals → absorb their energy (POWER) and fill your bag with SHARDS → SELL the shards for coins → more Power breaks bigger crystals that drop better shards; coins buy a bigger bag, upgrades and eggs (spirits that fight with you) → beat the zone boss → a new zone with bigger crystals → repeat.**

### The three numbers you track

| Number | What it does | How you get it |
|---|---|---|
| **POWER** (shown above your head + as your aura size) | your blast damage | absorbing energy orbs from crystals you break. **Never spent, only grows** |
| **SHARDS** (bag: 12 / 50) | carried loot | crystals drop them; they fill your bag |
| **COINS** | spending money | **selling** shards at the Sell Altar |
| **TEAM** (your spirits) | extra damage that hits with you | eggs (coins) |

---

## 1. The blast (the only input)

| Platform | Aim | Charge |
|---|---|---|
| PC | the crystal under your mouse is targeted (a white ring); click to switch | hold LMB or Space |
| Mobile | **auto-aim** on the nearest crystal in front of you; tap a crystal to switch | hold the big button |
| Gamepad | auto-aim; the right stick switches target | hold R2 |

**One blast, step by step:**
1. **Hold.** Your character takes a stance; energy gathers in the fists; a ring shrinks around you over **1.2 s**.
2. **Release:**

| Release | Damage | What you see |
|---|---|---|
| Too early (0.5-1.0 s) | 0.6 × Power | a small blast |
| **PERFECT** (the glow, the last 0.18 s) | **2 × Power × combo** | a big blast, a screen kick, "PERFECT!", a rising sound |
| Too late | 0.5 × Power + a short stagger | a fizzle |
| Quick tap (< 0.5 s) | nothing | — |

3. **The blast flies to the target** (0.15 s) and hits. The damage number pops, and the crystal cracks more with each hit (3 visible crack stages).
4. **Combo:** PERFECTs in a row go ×1 → ×1.25 → ×1.5 → ×1.75 → ×2. Any non-PERFECT resets it. Flames on your fists show the level.
5. **The 5th PERFECT in a row = OVERDRIVE (8 s):**
   - every release counts as PERFECT ×2, with no timing needed;
   - **every blast chains to the 2 nearest other crystals** for 50% damage.

   After it ends, the combo drops to ×1.5.

---

## 2. Crystals (what you hit, and why you graduate)

**Zone 1, the Training Grove (starting numbers):**

| Crystal | HP | Drops | Energy (Power gained) | Respawn |
|---|---|---|---|---|
| **Small Crystal** (knee-high) | 4 | 1 Shard (sells for 3) | +0.5 | 5 s |
| **Crystal** (person-high) | 40 | 3 Shards + a 20% chance of a Bright Shard (sells for 10 / 40) | +5 | 10 s |
| **Geode** (house-high) | 400 | 8 Shards + 2 Bright Shards + a 10% chance of a **Gem** (sells for 250) | +55 | 30 s |

**Why you graduate:**
- **Bigger crystals drop better shards,** so each bag is worth more.
- **At Power 2:** a Small Crystal dies to one PERFECT, while a Crystal takes about 10 hits.
- **At Power 15:** a Crystal dies in 1-2 PERFECTs and fills the bag with much more value.
- **The nudge:** a crystal's HP bar turns **green** when you can break it in 3 hits or fewer.

**When a crystal breaks:**
1. it shatters;
2. **shards get sucked into your SHARD STORM** (section 2a): they spiral in like debris into a tornado, with a clink, and the bag counter ticks up;
3. **energy orbs fly into your chest**: your aura pulses and grows, and "+5 POWER" pops.

## 2a. The Shard Storm (your bag, made visible)

**Your bag isn't a menu: it's a tornado of shards spinning around you.**
- **Loose shards within 12 studs get pulled in** in a spiral, so you never walk to pick anything up.
- **The fuller the bag, the bigger the storm:**

| Bag | Storm |
|---|---|
| Empty | a faint swirl of dust at your feet |
| Half full | a waist-high ring of shards |
| Nearly full | a roaring, head-high tornado; Bright Shards and Gems glint inside it |
| **FULL** | the storm turns gold and pulses, and the SELL button bounces |

- **Bigger bag upgrades = a bigger possible storm.** A 1,500-shard storm is a show-off on its own: everyone can see you're carrying a fortune.
- **On SELL,** the whole storm unwinds into the altar in one stream; the coins roll up while it drains.
- **Built for performance:** the storm is a few layered particle rings and swirl textures plus at most ~40 real shard meshes (the glinting ones; Gems always shown), not one part per shard. Other players' storms render at lower density.

## 2b. The bag and selling (the cash-in rhythm)

- **The bag** holds **50 shards** to start (a counter by your character: "38 / 50").
- **When it's full:**
  - the counter flashes **FULL**;
  - crystals still give Power, but drop no more shards;
  - the **SELL button** on the HUD bounces.
- **The SELL button** (HUD, always available; key: G / gamepad Y):
  1. you **teleport to the zone's Sell Altar** (a quick flash);
  2. your Shard Storm **unwinds into the altar in one stream** while the coin counter **rolls up**, with a cha-ching and a coin burst (about 1.5 s; Gems get their own bigger "GEM!" pop);
  3. **you're teleported straight back** to where you were.

  **No walking:** about 2-3 s total, and the cash-in moment stays.
- **The shop and egg stand** are next to the altar. A **"Stay"** toggle on the sell screen keeps you there to shop; otherwise you go straight back.
- **Why it works:** a rhythm (fill → sell → spend), a clear decision ("one more Geode before I sell?"), and a natural moment to shop ("Stay"), with **zero walking**.

## 3. Spirits (they fight with you)

**Where they live: the eye of the storm.** Your spirits circle you on an inner ring at shoulder height, inside the Shard Storm, like guardians riding the wind. Your **Bonded** spirit floats above your head as the crown of the storm.
- **To attack,** a spirit **launches out of the storm** at your target, hits with its signature move, and **slingshots back** into its orbit.
- **On a PERFECT,** they all burst out at once (the team strike) and snap back together.
- **When idle,** they slow down and play their own idle animations (the fox chases its tail, the imp juggles a fireball).
- **Why here:** they're always visible and never lost behind you, they don't block your aim, and you, the spirits and the storm read as **one picture**.

- **Each equipped spirit** attacks **every 1.5 s** for **its % of your Power**:

| Rarity | Damage (% of your Power) |
|---|---|
| Common | 20% |
| Rare | 35% |
| Epic | 60% |
| Legendary | 100% |
| Mythic | 180% |
| Secret | 300% |

- **On your PERFECT,** every spirit also strikes instantly (a **team strike**: one shared flash, a big combined hit).
- **Slots:** 3 to start, more from rank quests.
- **Why they matter:**
  - **at Power 15 with 3 Commons,** your spirits add about 9 damage per 1.5 s, which is +25-35% speed;
  - **with Epics,** spirits are close to half your damage.

  You *feel* a new spirit. Crystals pop faster.
- **Each species has one signature attack animation** (the fox dash, the imp fireball…). Rarer spirits are bigger, with bigger attack effects.
- **Bond (your look):**
  - in the spirit menu, tap **BOND** on any spirit: it floats above your head as the crown of the storm, and **your aura and storm take its element and rarity look** (fire tints the storm with embers, light makes it sparkle);
  - bonding is cosmetic only, so it never lowers damage;
  - the first time you hatch a new element, a prompt asks "Bond it?".

---

## 4. Coins: what you spend them on (zone 1; the shop + egg stand sit beside the Sell Altar)

| Item | Price | What it does |
|---|---|---|
| **Zone 1 Egg** | 60 | a spirit (odds on the card: Common 60 / Rare 28 / Epic 10 / Legendary 1.9 / Mythic 0.1 / **??? Secret 1 in 500,000**) |
| **Bag** (5 levels) | 40, 150, 500, 1,500, 4,000 | 50 → 100 → 200 → 400 → 800 → 1,500 shards: fewer trips |
| **Force** (5 levels) | 50, 150, 400, 1,000, 2,500 | +20% blast damage per level |
| **Surge** (3 levels) | 200, 800, 2,000 | Overdrive +2 s per level |

**Everything visibly makes the loop better:** bigger hits, fewer trips, longer Overdrive, more spirits attacking.

## 5. THE FIRST 5 MINUTES (exact script; average player)

| Time | What happens | Numbers |
|---|---|---|
| 0:00 | Spawn in the Training Grove. Small Crystals everywhere, a few Crystals, one Geode in view (a visible goal). A pulsing **HOLD** hand over the nearest Small Crystal | Power 2, Bag 0/50, Coins 0 |
| 0:03 | First hold-release (probably early): it cracks. Second: it breaks; a shard flies into the bag, an orb into you. "+0.5 POWER" | — |
| 0:10 | First PERFECT: a big blast, a one-hit kill | — |
| ~0:30 | First **OVERDRIVE**: chain blasts wipe 8-10 crystals in 8 s; the storm swells | — |
| ~0:45 | **Bag FULL** (50 shards). The SELL button bounces; the hand points at it | Power ~14 |
| 0:50 | **First SELL:** teleport, shards stream out, the storm unwinds into the altar, coins roll up, cha-ching. The first time, you stay (the tutorial shows the shop) | Coins ~150 |
| 0:55 | The egg stand glows (60). The hand points at it. First hatch (the tutorial egg is always dramatic): a **Light Fox**. "Bond it?" | — |
| 1:00 | The hand points at the shop: **Bag Lv1** (40) → 100 capacity | — |
| 1:05-2:00 | The Crystals' HP bars are green; you smash Crystals with the Fox. Bright Shards. Two more sells | Power ~70 |
| ~1:30 | First rank quest: "Break 30 crystals → +1 spirit slot". **Force** Lv1. 2nd + 3rd egg (guaranteed **Rare** on the 3rd: a blue crack + a glow burst) | 3 spirits |
| 2:30 | Geodes turn green. The first **Gem** drop ("GEM!") | Power ~150 |
| 3:00 | **The boss gate turns gold** (recommended Power 150) | — |
| 3:00-4:15 | **Stone Golem** (below) | — |
| 4:15 | KO → transform to **BLAZE**. The zone 2 portal opens. A **free Zone-2 egg** waits | — |
| 4:30 | **Lava Dojo:** a new altar, bigger crystals, Fire spirits, a Bag / Force cap raise | — |

## 6. The boss fight, exactly (Stone Golem; recommended Power 150)

**The arena:** a round stone ring. The boss has 3 phases (≈60-90 s total). Your spirits fight too.

**1. Armor (≈25 s):**
- the Golem is covered in **6 glowing crystal plates** (80 HP each), and only plate hits do damage;
- every 4 s it **slams**: a **red circle** appears on the ground for 1 s, then the hit. **Walk out of it** (a hit costs 10% of your clash meter, see phase 3).

**2. Rage (≈25 s):**
- plates gone, it **rolls boulders** at you (a red lane is telegraphed 0.8 s before);
- **dodge sideways**;
- or **blast a boulder** (one PERFECT) to send it back for big damage (that's the skill play);
- the Golem's HP bar (600) drains from your blasts and spirits.

**3. Finisher, the BEAM CLASH (≈10 s):**
- at 0 HP it roars and fires a beam; you auto-fire back, and the beams meet;
- **hold-release PERFECTs** push your beam forward (each PERFECT = +6%);
- **red flash = TAP** to counter (+4%, or −4% if you miss);
- your **clash meter** starts at 50%, minus the hits you took in phases 1-2. Reach 100% to win.

**Win:** slow motion, the beam swallows the Golem, it shatters into loot. You **transform**.

**Lose:** "You got hit 4 times: dodge the red circles!", and retry instantly.

---

## 7. Why the loop holds

| Second to second | Minute to minute | 5-10 minutes | Session |
|---|---|---|---|
| timing (PERFECT), combo flames, Overdrive bursts, the Shard Storm growing | bag full → **SELL** cash-in; the next crystal size turns green; the next egg / Bag / Force level; the next rank quest | the boss | zone 2, then later Ascension |

Something always finishes soon, and the next bigger thing is always **visible** (green HP bars, the glowing egg stand, the gold gate).

**Still to prove in playtest #1:**
- whether hold-release blasting feels great for 20+ minutes;
- whether graduating crystal sizes feels like progress;
- whether the bag / SELL rhythm feels satisfying, not like an interruption (if not: bigger bags sooner).

If it doesn't, we adjust the timing and HP **before** art.
