# AURA CLASH: the core loop (v5; starting numbers, tuned later in the model)

v5 changes (owner, 2 Oct): **Power comes from MEDITATION** (the AFK half). **Crystals become crystal MONSTERS** (pets tank and fight). **The bag is capped** for mobile. Force is cut. One stat, one currency, one pet number.

v5.1 (owner): **monster MUTATIONS** (Gold, Fire, Rainbow…: rarer, worth much more, their shards spin in your storm); **pets eat SOUL FOOD** dropped by monsters to level up; **Bond is cut**; pet fusion tiers renamed to **stars** (★, ★★) so "Gold" only means the mutation.

## 0. The core in one picture

```
        MEDITATE (calm / AFK)                    HUNT (active)
   sit at the Shrine → POWER grows      blast crystal monsters → SHARDS in your storm
             │                                        │
             │  Power = your damage + toughness       │  SELL → COINS
             └──────────────► you hunt harder ◄───────┘
                                    │
                            COINS → EGGS → PETS
                   each pet's STRENGTH boosts BOTH halves:
                 faster meditation  +  it fights beside you
                                    │
                    enough Power → BOSS → new zone:
             a stronger Shrine, tougher monsters, better loot, a new egg
```

**The rule that makes it a loop, not two separate games:**
- **Power only comes from meditating.** Hunting gives none.
- **Coins only come from hunting.** Meditating gives none.
- **Pets come from coins** and speed up **both** halves.

So a meditation-only player has big Power but no new pets (slow), and a hunting-only player has pets but can't beat the next zone's monsters (stuck). **The fastest way is to switch between them,** and each switch feels great: you come back from meditating and one-shot the monsters that were hard 10 minutes ago.

### The four things on your screen

| Thing | What it is | Where it comes from |
|---|---|---|
| **POWER** | your blast damage and toughness; your aura's size | **meditation only**; never spent, never lost |
| **SHARDS** (storm: 18 / 60) | loot you're carrying | monsters you defeat |
| **COINS** | the one currency | selling shards |
| **PETS** | each has one number, **Strength** | eggs (coins) |
| **SOUL FOOD** | levels up your pets | monsters drop it (straight into your pouch, never the bag) |

---

## 1. MEDITATE: where Power comes from

**Where:** the **Shrine** in the middle of each zone: a glowing ring of meditation mats. The Sell Altar, the egg stand and the shop are around it, so the Shrine is the hub. (Meditating works only on mats, so there's one calm, social spot per zone, where everyone sees everyone's aura.)

**How:** walk onto a mat and press **MEDITATE**:
- you sit cross-legged and float a little; your eyes close; your aura rises like a slow flame;
- energy streams in from the zone (leaves, sparks, light) into your chest;
- **your pets sit in a circle around you and meditate too** (each in its own cute pose);
- the Power counter ticks up, and your aura visibly swells.

**Two speeds:**

| Mode | What you do | Rate |
|---|---|---|
| **AFK** | nothing | ×1 |
| **FOCUS** (active) | a breathing ring around you grows and shrinks; **tap when it's fullest** (the same timing feel as a PERFECT). Each good tap adds a Focus level (max 5); a miss drops one | up to **×3** |

**Meditation rate = Shrine rate × Focus × (1 + 10% per point of equipped pets' Strength) × Mat upgrade.**
- Zone 1 Shrine: 0.5 Power/s; zone 2: 2/s; each zone about ×4.
- Example: zone 1, 3 Common pets (Strength 1 each), AFK: 0.5 × 1 × 1.3 = 0.65/s. With full Focus: 1.95/s.

**AFK and offline:**
- **In game:** AFK meditation runs at the full ×1 rate. Roblox kicks idle players after 20 minutes, so just before that the game rejoins you to a server and sits you back on a mat.
- **Offline:** you keep meditating at **25% of your AFK rate, up to 8 hours.** When you come back: a "WHILE YOU WERE AWAY: +4,210 POWER" screen with your aura bursting bigger, which is the return hook.

**Why it's fun, not boring:** it's calm after hunting, it's a show-off spot (everyone's sitting in one place with their auras flaring), active Focus is a satisfying rhythm, and you watch your aura grow.

---

## 2. HUNT: where coins come from

### The blast (the only attack)

| Platform | Aim | Charge |
|---|---|---|
| PC | the monster under your mouse (a white ring) | hold LMB or Space |
| Mobile | **auto-aim** at the nearest monster in front of you; tap to switch | hold the big button |
| Gamepad | auto-aim; the right stick switches | hold R2 |

Hold: energy gathers in your fists and a ring shrinks around you over 1.2 s. Release:

| Release | Damage |
|---|---|
| Too early (0.5-1.0 s) | 0.6 × Power |
| **PERFECT** (the glow, the last 0.18 s) | **2 × Power × combo**, a screen kick, and every pet pounces |
| Too late | 0.5 × Power + a short stagger |
| Quick tap (< 0.5 s) | nothing |

- **Combo:** PERFECTs in a row: ×1.25 → ×1.5 → ×1.75 → ×2. A non-PERFECT **drops one level** (not to zero; kinder to younger players).
- **OVERDRIVE:** 5 PERFECTs in a row = 8 s where every release is PERFECT ×2 and **chains to the 2 nearest monsters** at 50%.

### The monsters (zone 1, the Training Grove)

The grove's wildlife has been overgrown by crystals: **crystal monsters that shatter into shards.**

| Monster | HP | Behaviour | Drops |
|---|---|---|---|
| **Shardling** (a small crystal slime) | 20 | hops around in groups of 3-4; bumps you lightly | 1 Shard (sells for 3) |
| **Crystal Boar** (person-high) | 200 | wanders; when it spots you, **charges in a straight line** (a red lane, 0.8 s warning) | 3 Shards + 20% Bright Shard (40) |
| **Crag Brute** (house-high) | 2,000 | slow; **slams the ground** (a red circle, 1 s warning) | 8 Shards + 2 Bright + 10% **Gem** (250) |

- **Each monster's HP bar turns green** when you can beat it in about 3 of your blasts: the nudge to hunt bigger ones.
- **When one is defeated:** it cracks, freezes, and **shatters**; the shards spiral into your Shard Storm.
- **They fight back (lightly):**
  - you have a health bar; a monster hit takes 10-30% of it (less as your Power outgrows the zone); it regenerates quickly out of combat;
  - if you're knocked out: you reappear at the Shrine and **keep everything**, bag included. No loss, only lost time.
- **Respawn:** each monster type has fixed spawn points (Shardlings 5 s, Boars 10 s, Brutes 30 s), max about 30 monsters per zone.
- **Every monster also drops Soul Food** (section 3b): Shardling 10% chance of 1, Boar 1, Brute 3.

### Mutations (the jackpot layer)

Any monster can spawn **mutated**: same monster, a different crystal. Rarer mutations are worth far more.

| Mutation | Chance per spawn | Shard value | HP | How you spot it |
|---|---|---|---|---|
| **Gold** | 1 in 25 | ×5 | ×2 | shiny gold crystals, a gold sparkle trail |
| **Fire** | 1 in 60 | ×10 | ×3 | burning crystals, embers rising |
| **Frost** | 1 in 60 | ×10 | ×3 | icy blue crystals, cold mist |
| **Rainbow** | 1 in 400 | ×25 | ×4 | shifting rainbow crystals; a light beam above it visible across the zone |
| **Void** | 1 in 2,000 | ×75 | ×6 | dark purple crystals that warp the air; a deep hum |
| **Celestial** | 1 in 10,000 | ×250 | ×8 | starry crystals, a halo; **a server announcement** when it spawns and when it's defeated |

- **Its shards keep the mutation.** Mutated shards **spin in your Shard Storm** glowing in their colour (gold glints, fire shards trailing embers, rainbow shards shimmering), so everyone can see what you're carrying. They're always the ones shown first in the storm's 12 visible shards.
- **At the altar,** mutated shards sell with their own bigger pop ("RAINBOW ×25!").
- **Mutated monsters drop ×3 Soul Food.**
- **Why it works:** every spawn is a tiny lottery, so hunting never feels flat; spotting a Rainbow beam across the zone makes everyone run; and it's a natural hook for later events ("Fire mutations ×5 this hour") and the owner's luck items.
- **Rules:** the shared-damage rule applies (15% of its HP = the full drop), so racing to a Rainbow is a group moment, never a steal. The first Gold Shardling is guaranteed in the tutorial (around 1:10) to teach it.

### Why pets matter here (the reason for monsters)

- **Pets fight:** every pet attacks your target every 1.5 s for **Strength × 10% of your Power**, each with its signature move (the fox dash, the imp fireball).
- **Pets tank:** monsters attack whatever is closest, and that's often a pet. **A hit pet is dazed for 2 s** (stars over its head), then jumps back in. **Pets never die.** So more pets = fewer hits on you.
- **Pets team strike:** on your PERFECT, they all pounce at once.

You *feel* every new pet: monsters fall faster and you get hit less.

### The bag: the Shard Storm (capped for mobile)

- **Your shards spin around you as a storm.** It turns gold and pulses when full; then monsters still die but drop nothing, and the SELL button bounces.
- **Capacity is small on purpose:** 60 → 100 → 150 → 200 → **250 max**. (Bigger shards in later zones carry the value, not bigger bags.)
- **Lag-proof:** the storm has **4 fixed looks** (dust → ring → tornado → gold tornado) made of 1-2 particle emitters and **at most 12 shard meshes**, whatever the count. Other players' storms show only the ring emitter. **Settings → "Low effects"** shows yours as a simple ring.

### SELL

Press SELL (or G / gamepad Y) anywhere outside a boss fight:
1. you teleport to the Shrine's Sell Altar;
2. your storm unwinds into it while coins roll up (about 1.5 s; Gems get a "GEM!" pop);
3. you teleport straight back.

**"Stay"** keeps you at the Shrine instead: to shop, hatch, or **sit down and meditate.** That's the natural switch point between the two halves.

---

## 3. PETS: one number, two jobs

**Strength by rarity:**

| Rarity | Strength | In a fight (per 1.5 s) | Meditation boost |
|---|---|---|---|
| Common | 1 | 10% of your Power | +10% |
| Rare | 2 | 20% | +20% |
| Epic | 4 | 40% | +40% |
| Legendary | 10 | 100% | +100% |
| Mythic | 20 | 200% | +200% |
| Secret | 50 | 500% | +500% |

**Fusion: stars** (so "Gold" and "Rainbow" only ever mean monster mutations):
- **3 copies of the same pet → the ★ version: ×3 Strength**, a star badge and a brighter glow.
- **3 ★ copies → the ★★ version: ×9 Strength**, two stars and a sparkling outline.
- The fused pet keeps the **highest level** of the three (section 3b), so no feeding is wasted.
- It turns duplicates into progress and gives a goal for every pet, even Commons. (Auto-fuse for Commons and Rares that aren't equipped; manual for the rest.)

**How pets behave:**

| Moment | What they do |
|---|---|
| Walking | follow you in a loose pack; small ones hop, fliers bob |
| Standing still (2 s+) | huddle around you and relax: sit, nap, play |
| Charging a blast | perk up into a battle stance |
| Fighting | dash in, hit, run back; get dazed when hit; all pounce on PERFECT |
| Meditating | sit in a circle around you, meditating in their own pose |

- **Slots:** 3 to start; rank quests add more (up to 6 in the first two zones).
- **No Bond** (cut). Your aura's look comes from your **transformations** (Spark → Blaze → …) earned from bosses.

### 3b. Soul Food (pet levels)

- **Monsters drop Soul Food:** glowing little treats in the zone's flavour (Crystal Berries in the Grove, Magma Peppers in the Lava Dojo). They fly into a **food pouch**, not your bag, so they never fill the storm.
- **Feeding:** in the pet menu, tap **FEED** on a pet (or **Feed All** to share it across your equipped team). The pet gobbles it with a happy bounce and hearts; its XP bar fills; a level-up gives a sparkle burst and "Lv 7!".
- **Levels 1-30.** Each level gives **+5% Strength** (Lv 30 = about ×2.5). Higher zones' food gives more XP.
- **One number stays one number:** the pet card shows a single **Strength** = rarity × stars × level. Pets also look a bit bigger and brighter as they level.
- **Why it's good:**
  - every monster kill now feeds your team, not just your wallet;
  - your favourite pet grows with you, which builds attachment;
  - Commons and Rares stay useful early, since you can level them while you hunt for better eggs;
  - it's a second reason to hunt the biggest monsters you can (Brutes drop the most food).

**Eggs:** each zone's egg: Common 60 / Rare 28 / Epic 10 / Legendary 1.9 / Mythic 0.1 / **??? Secret 1 in 500,000.** The hatch grows with rarity (a pop → a blue glow → lightning → a gold pillar + server announcement → a **Mythic cutscene** → a **10-second Secret cutscene** that changes the server's sky). **The crack colour always shows the true rarity.**

---

## 4. COINS: what you spend them on (the shop around the Shrine)

| Item | Price (zone 1) | Effect | Which half it helps |
|---|---|---|---|
| **Egg** | 60 | a pet | both |
| **Bag** (4 levels) | 50, 200, 600, 1,500 | 60 → 100 → 150 → 200 → 250 | hunting |
| **Meditation Mat** (5 levels) | 100, 300, 800, 2,000, 5,000 | +25% meditation each | meditation |
| **Surge** (3 levels) | 200, 800, 2,000 | +2 s Overdrive each | hunting |

Coins are the only currency, and everything they buy makes the next loop visibly faster.

---

## 5. RANK QUESTS (always one clear next task)

They alternate between the halves, which teaches the rhythm:
1. "Meditate with Focus for 20 s" → +1 pet slot
2. "Defeat 15 Shardlings" → a free egg
3. "Hatch 3 pets" → Bag level 1
4. "Defeat 5 Crystal Boars" → +1 pet slot
5. "Reach 150 Power" → the boss gate opens

---

## 6. THE FIRST 8 MINUTES (target script; tuned in the model)

| Time | What happens | Numbers |
|---|---|---|
| 0:00 | Spawn at the Training Grove Shrine. A glowing mat and a "MEDITATE" hand | Power 10 |
| 0:05 | **Tutorial meditation** (boosted ×10 for 20 s): Focus taps; the aura swells; "Power 10 → 50!" | Power 50 |
| 0:30 | The hand points at Shardlings. First blast; first PERFECT one-shots | — |
| 1:00 | First Overdrive chains through a Shardling pack | — |
| ~1:10 | A guaranteed **Gold Shardling** sparkles nearby: "MUTATION!". It drops gold shards that spin in your storm | — |
| 1:30 | **Storm full** (60). SELL → coins roll up. The first sell stays at the Shrine | Coins ~180 |
| 1:40 | First egg (the tutorial egg is always dramatic): **Light Fox** (equipped instantly; it hops to your side). Then 2 more eggs (guaranteed Rare on the 3rd) | 3 pets |
| 2:00 | Rank quest 1: Focus meditate for 20 s with 3 pets → +1 slot | Power ~75 |
| 2:30-5:00 | Hunting with 4 pets: Shardlings, then Boars (the pets tank the charges). Power stays put while hunting (it only comes from meditating). Two sells → Bag Lv1, Mat Lv1, 1-2 more eggs. First **FEED**: the Fox eats Crystal Berries → Lv 3 | Power ~75, coins spent |
| 5:00 | The Boars feel slow now. Sit at the Shrine and Focus meditate for about 1 minute (Mat Lv1, 4-5 pets) | Power ~150 |
| 6:00 | **The boss gate opens** (rank quest 5) | — |
| 6:00-7:30 | **Stone Golem** (below) | — |
| 7:30 | KO → transform to **BLAZE**. The zone 2 portal opens; a free Zone 2 egg | — |
| 8:00 | **Lava Dojo:** a 4× Shrine, Magma monsters, Fire pets | — |

After that, a typical session: **hunt until the storm is full → sell → hatch / upgrade → meditate a while (Focus or AFK) → hunt again with more Power.** Log off on a mat: offline meditation.

---

## 7. THE BOSS (Stone Golem; recommended Power 150; your own instance)

1. **Armor (~25 s):** 6 glowing crystal plates (80 HP each); only plate hits count. Every 4 s it slams: a red circle on the ground for 1 s. Each hit you take costs 10% of your clash meter.
2. **Rage (~25 s):** it rolls boulders down red lanes (0.8 s warning): dodge sideways, or PERFECT one to blast it back for big damage. HP 600 (your blasts + pets).
3. **Beam clash (~10 s):** your beam vs its beam. Each PERFECT +6%; tap on the red flash to counter (+4%, a miss −4%). The meter starts at 50% minus the hits you took.

Win: slow motion, the beam swallows it, it shatters into loot, you **transform**. Lose: "You got hit 4 times: dodge the red circles!", and retry instantly. Pets fight too (they can be dazed by the slam).

---

## 8. RULES THAT CLOSE THE GAPS

| Question | Rule |
|---|---|
| Several players hit the same monster? | Monsters are shared. **Everyone who dealt at least 15% of its HP gets the full drop** |
| Shards from far away (pets, chains)? | Always fly to you; the 12-stud pull is just the visual spiral |
| Meditate anywhere? | Only on Shrine mats (one calm, social hub per zone; enough mats for a full server) |
| Do pets attack on their own? | Only from your first blast on a target until it dies; standing still is always calm |
| Who judges PERFECT / Focus timing? | Your device (lag never ruins it); the server checks it's possible |
| SELL in a boss fight? | No (greyed out) |
| Bag full mid-Overdrive? | Overdrive keeps going; the storm turns gold |
| Do mutated shards take more bag space? | No: 1 shard = 1 slot, whatever its mutation |
| Does Soul Food fill the bag? | No: it goes to the food pouch (no cap) |
| Does AFK skip the game? | No: AFK gives Power only. Pets, upgrades and zones need coins (hunting) and bosses (active) |

## 9. LAG BUDGET (mobile first)

- Max ~30 monsters per zone; simple server logic (move, telegraph, hit), animations on the client.
- Pets are client-side visuals; the server computes their damage as numbers.
- Storm: max 12 meshes + 2 emitters for you (mutated shards shown first); 1 emitter for others; "Low effects" option.
- Mutation effects: one emitter per mutated monster; the Rainbow+ light beams are a single beam part each.
- Other players' pets at a distance: simple follow, no idle animations.
- Target: 60 fps on a mid-range phone with a full server at the Shrine.

## 10. WHY THE LOOP HOLDS

| Second to second | Minute to minute | 5-10 minutes | Session / days |
|---|---|---|---|
| PERFECT timing, combo, Overdrive chains, pets pouncing, monsters shattering, **a mutation sparkling into view** | storm full → SELL → hatch / upgrade / **feed**; the next monster turns green | meditate → come back stronger → boss | offline meditation, the next zone, fusion goals, Secret hunting |

**Still to prove in playtest #1:**
- whether blasting monsters feels great for 20+ minutes;
- **whether players actually switch** between hunting and meditating (if they only hunt: raise the Shrine rate; if they only sit: raise the monster loot);
- whether active Focus meditation is enjoyable or a chore;
- whether the SELL rhythm feels like a cash-in, not an interruption.
