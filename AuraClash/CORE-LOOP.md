# AURA CLASH: the core loop, precisely (v4 detail; starting numbers, to be tuned in the model)

## The loop in one sentence

**Blast crystals → absorb their energy (POWER) and coins → more Power breaks bigger crystals that pay more; coins hatch spirits that fight with you → you break even bigger crystals, faster → beat the zone boss → a new zone with bigger crystals → repeat.**

### The three numbers you track

| Number | What it does | How you get it |
|---|---|---|
| **POWER** (shown above your head + as your aura size) | your blast damage | absorbing energy orbs from crystals you break. **Never spent, only grows** |
| **COINS** | spending money | coins that burst out of crystals |
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

| Crystal | HP | Coins | Energy (Power gained) | Respawn |
|---|---|---|---|---|
| **Shard** (knee-high) | 4 | 3 | +0.5 | 5 s |
| **Crystal** (person-high) | 40 | 35 | +5 | 10 s |
| **Geode** (house-high) | 400 | 400 | +55 | 30 s |
| **Crystal Heart** (giant, one per server, every 3 min) | 30,000, shared by everyone hitting it | split by damage dealt, plus a guaranteed egg for every hitter | +300 | 3 min |

**Why you graduate:** bigger crystals pay **more per hit**, once you can break them quickly.
- **At Power 2:** a Shard dies to one PERFECT (4 damage). A Crystal takes about 10 hits, which isn't worth it yet.
- **At Power 15:** a Crystal dies in 1-2 PERFECTs and pays 12× a Shard. You naturally move up.
- **The game nudges you:** a crystal's HP bar turns **green** when you can break it in 3 hits or fewer.

**When a crystal breaks:**
1. it shatters into shards (a physics burst, a crack sound);
2. **coins burst out** and magnet to you, with a coin "ching";
3. **energy orbs** in the zone's colour fly into your chest;
4. your aura **pulses** as it absorbs them: the "drinking" moment.

**The Power counter ticks up** and your aura grows (size comes from Power). A "+5 POWER" pops.

---

## 3. Spirits (they fight with you)

- **Each equipped spirit** flies at your current target and attacks **every 1.5 s** for **its % of your Power**:

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
  - in the spirit menu, tap **BOND** on any spirit: it rides your shoulder, and **your aura takes its element and rarity look**;
  - bonding is cosmetic only, so it never lowers damage;
  - the first time you hatch a new element, a prompt asks "Bond it?".

---

## 4. Coins: what you spend them on (zone 1)

| Item | Price | What it does |
|---|---|---|
| **Zone 1 Egg** | 60 | a spirit (odds on the card: Common 60 / Rare 28 / Epic 10 / Legendary 1.9 / Mythic 0.1 / **??? Secret 1 in 500,000**) |
| **Aura Forge: Force** (5 levels) | 50, 150, 400, 1,000, 2,500 | +20% blast damage per level |
| **Aura Forge: Magnet** (3 levels) | 100, 400, 1,200 | wider coin / orb pickup, so you can keep blasting without walking |
| **Aura Forge: Surge** (3 levels) | 200, 800, 2,000 | Overdrive +2 s per level |

**Everything visibly makes the blasting better:** a bigger hit, less walking, a longer Overdrive, more spirits attacking.

---

## 5. THE FIRST 5 MINUTES (exact script; average player)

| Time | What happens | Numbers |
|---|---|---|
| 0:00 | Spawn in the Training Grove. Shards everywhere, a Crystal or two, one Geode in the middle (a visible goal). A pulsing **HOLD** hand over the nearest Shard | Power 2, Coins 0 |
| 0:03 | First hold-release (probably early): the Shard cracks. Second: it breaks. Coins + an orb fly in. "+0.5 POWER" | — |
| 0:10 | First PERFECT: a big blast, "PERFECT!", and the Shard dies in one hit. The hand moves to the next Shard | — |
| 0:10-0:40 | Smashing Shards (each about 1.4 s). The combo flames grow | ~20 Shards → Power ~12, Coins ~60 |
| ~0:30 | First **OVERDRIVE** (5 PERFECTs): chain blasts wipe 8-10 Shards in 8 s. Coins everywhere | a big jump |
| 0:40 | **The egg stand glows** (60 coins). The hand points at it | — |
| 0:45 | First hatch (the tutorial egg is always dramatic: lightning, levitation): a **Light Fox** | it's equipped, and you're asked "Bond it?" |
| 0:50 | The Fox dashes at your target with you. The **Crystals' HP bars turn green**, and the hand points to a Crystal | Power ~13 |
| 0:50-2:00 | Crystals: 2 PERFECTs + the Fox each. 35 coins and +5 Power per Crystal | Power ~60, Coins ~500 |
| ~1:10 | First **rank quest:** "Break 30 crystals → +1 spirit slot" | — |
| ~1:20 | **Aura Forge** (Force Lv1, 50 coins). The hand points at it | — |
| ~1:40 | 2nd and 3rd eggs. Guaranteed **Rare** on the 3rd hatch: a blue crack and a glow burst | 3 spirits |
| 2:00 | **CRYSTAL HEART** spawns (server alert + a beam). You and other players hit it together | a jackpot: coins + a free egg |
| 2:30 | Geodes turn green. One Geode = +55 Power, 400 coins | Power ~150 |
| 3:00 | **The boss gate turns gold** (recommended Power 150) | — |
| 3:00-4:15 | **Stone Golem** (below) | — |
| 4:15 | KO → transform to **BLAZE** (a 2 s cinematic, the aura grows a layer). The zone 2 portal opens. A **free Zone-2 egg** waits | — |
| 4:30 | **Lava Dojo:** bigger crystals (Ember Crystal HP 300, pays 250), Fire spirits, and a **Forge cap raise** (Force levels 6-10) | — |

---

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
| timing (PERFECT), combo flames, Overdrive bursts, hits popping, loot flying | the next crystal size turns green; the next egg; the next Forge level; the next rank quest | the boss | zone 2, Wild Spirits, events, Sanctum, Ascension |

Something always finishes soon, and the next bigger thing is always **visible** (green HP bars, the glowing egg stand, the gold gate).

**Still to prove in playtest #1:**
- whether hold-release blasting feels great for 20+ minutes;
- whether graduating crystal sizes feels like progress.

If it doesn't, we adjust the timing and HP **before** art.
