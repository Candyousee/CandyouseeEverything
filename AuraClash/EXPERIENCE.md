# AURA CLASH: Experience Design v3 (the CORE FEEL; for owner approval)

**Why this exists:** the owner said the core must be good, not just the maths. v2 had correct numbers and a weak experience: standing on a stone while a number goes up. This document fixes the *feel*. The economy model gets re-tuned to these rules **after** the owner approves them.

---

## 1. The core action: SMASH, don't "train"

**Old:** hold on a stone → power ticks up. Abstract, and nothing to look at.

**New:** every zone is full of **Energy Crystals**. You **charge your aura and blast them.**

### How a blast works
1. **Aim:** look or tap at a crystal (it gets a target ring). On mobile, auto-aim picks the nearest crystal.
2. **Hold:** your aura gathers into your fists, the ring closes, and the charge sound rises.
3. **Release in the glow = PERFECT:** a **big energy blast** flies into the crystal. It cracks, the screen shakes a little, and numbers pop.
4. **Crystal breaks:**
   - it **explodes** into shards;
   - a **coin fountain** sprays out and magnets to you;
   - **energy orbs** fly into your aura, which is your power gain. You *see* your aura drink the energy.

### Crystals have sizes (the decision in every loop)

| Crystal | HP | Pays | Feel |
|---|---|---|---|
| Shard | 1 blast | small | fast, snappy |
| Crystal | 3-4 blasts | medium | the bread and butter |
| Geode | 10+ blasts, ideal with spirits helping | big | "let's crack this" |
| **Crystal Heart** (one per zone, respawns every 3 min, server-wide) | huge; everyone nearby hits it together | **jackpot** + a rare egg drop | the social moment: players gather |

### Combo and Overdrive (where the grab comes from)
- **PERFECT chains:** each one makes the next blast bigger (×1 → ×2) and **visually escalates**: blast size, colour heat, the sound pitch climbing.
- **5 in a row = OVERDRIVE (8 s):**
  - your aura **erupts**;
  - every release becomes a **chain blast** that jumps to 3 nearby crystals;
  - the music gets a beat layer;
  - the field gets cleared.

  That's the dopamine burst. Get there, wreck everything, build it up again.
- **Why it's fun the 50th time:**
  - a target (pick a big or small crystal);
  - skill (timing);
  - escalation (the combo grows visibly);
  - a payoff (Overdrive clears the screen);
  - loot (coins and orbs flying at you).

**Coins come from the crystals you break.** Power comes from the energy you absorb. Both are visible objects flying at you, not a ticking number.

### Should you "sell" your aura? (considered, rejected)
- **The backpack-sell loop** (fill up → walk to a seller → sell; Mining Simulator style) adds a walking chore between the fun parts.
- **Modern top simulators** dropped it.
- **The good part of it,** the satisfaction of a big cash-in, comes back in a better form: **Overdrive and the Crystal Heart are the big cash-in moments**, with no walking.

---

## 2. Spirits: they FIGHT with you, not just float

- **Idle:** they orbit inside your aura, play, chase each other, and nap on your shoulder.
- **When you target a crystal, your spirits dive at it** and attack with **their own signature move.** This is real damage, not decoration:

| Spirit | Signature move |
|---|---|
| Fox (Light) | dashes through in a streak of light |
| Ember Imp (Fire) | spits fireballs |
| Frost Owl | ice-feather volley |
| Storm Eel | chain lightning |
| Koi (Nature) | water whip |
| Void Cat | blinks in and claws through a portal |
| Star Dragon (Cosmic) | breath beam |

- **On your PERFECT,** every spirit attacks at once: a **team strike.** That's the "my team is with me" feeling.
- **Rarer spirits:**
  - are **bigger**;
  - have **better moves** (a Common pokes, a Legendary unleashes an area attack);
  - carry **their own mini-aura**;
  - Mythics get a unique idle animation.
- **Gold and Rainbow** change the material: polished gold, or a shifting rainbow.
- **Design rule:** each spirit is a cute, chunky elemental creature with a readable silhouette at 30 studs and a clear element colour. GPU concept sheets come first, then Blender.

---

## 3. Your aura = your BONDED spirit (simpler than v2's Wardrobe)

- **One spirit is your Bonded spirit,** your partner. It rides your shoulder or floats above you, and **your aura takes its element and rarity look:**
  - bond a Void Cat → dark tendrils and purple sparks;
  - bond a Mythic Phoenix → flames and phoenix wings.
- **You choose the bond** in one tap from the spirit menu. **Auto-bond** picks your rarest spirit.
- **Power and looks are separate:** your best power team and your favourite look never fight. Bonding never lowers power.
- **What the aura layers mean:**
  - **size** = your power;
  - **halo** = your Ascensions;
  - **look** = your bonded spirit.

Simple: *"pick your partner, become their element."*

---

## 4. Eggs: insane hatches, crazier by rarity

| Result | What happens |
|---|---|
| **Common** (1.5 s) | the egg pops, a puff, the spirit hops out |
| **Rare** (2 s) | blue cracks, a glow burst, a happy jingle |
| **Epic** (3 s) | purple cracks, the egg levitates, lightning arcs, a thunder clap |
| **Legendary** (4 s) | gold cracks; **the sky dims around you**; a golden pillar of light; the egg shatters in slow motion; the spirit roars; **server announcement** |
| **Mythic: CUTSCENE** (6 s, unskippable the first time) | the world freezes, the camera orbits; the egg rises into a vortex of the zone's element; it splits; **the spirit forms from raw energy**; a shockwave across the zone; **a rainbow beam visible from every zone**; a server announcement with your name |
| **Secret: CUTSCENE** (8-10 s, unskippable the first time) | the screen cracks; music cuts to silence; a "???" title card; the sky over the WHOLE server changes for 10 s; a unique entrance animation per Secret; **a global announcement in every server**; a permanent "Secret Holder" title |

**The crack colour always shows the true rarity** (no fake near-misses).

### Secrets
- **What:** every zone has **one Secret spirit:** the strongest and rarest in that zone, with a unique creature, a unique aura look and a unique hatch.
- **The odds card shows "??? : 1 in 500,000".** The *chance* is always visible; only the *identity* is hidden until someone hatches it. Afterwards, the card shows its silhouette and "First hatched by ___ on ___".
  - Showing the chance keeps it honest, and it's required if eggs are ever sold for Robux.
- **Secret events** boost Secret odds ×5 for 10 minutes, server-wide, so players have a reason to be online:
  - a **Blood Moon** over the Void Rift;
  - a **Meteor Shower** in the Galaxy Throne;
  - a **Sakura Storm** in the Sakura Realm.

---

## 5. Why Ascend? (it has to FEEL worth it)

**Ascension = AWAKENING.** You reset your run, but you keep your spirits and gain:
1. a **permanent multiplier** (shards);
2. a **new halo colour**;
3. **one Awakening perk** per Ascension, picked from a small tree. Each perk *changes how you play*:

| Perk | What it does |
|---|---|
| Twin Blast | every release also fires at a second crystal |
| Magnet | coins and orbs fly to you from much farther away |
| Long Overdrive | Overdrive lasts 12 s |
| Spirit Frenzy | spirits attack twice as fast |
| Crit Core | 10% of blasts crit for ×5, with a special effect |
| Auto-Hatch | the egg stand hatches while you're nearby |
| Overdrive Start | each new zone starts you in Overdrive |
| Lucky Aura | ×1.5 egg luck |

**Why it feels good:** you come back *stronger and different*. Early zones get demolished in seconds with your new perks. It's a power fantasy, not a punishment.

---

## 6. Boss fights: a real fight, with the beam clash as the finisher

The v2 beam clash alone was one-note. Each boss is now a **3-phase arena fight** using the same blast verb:

1. **Armor phase:**
   - the boss is covered in **crystal armor plates**; you blast them off (the core verb, now under pressure);
   - your spirits attack;
   - the boss throws **telegraphed attacks** (glowing ground circles, sweeping beams) that you **dodge by moving**.
2. **Rage phase:** with the armor gone, the boss uses its **unique mechanic:**

| Boss | Unique mechanic |
|---|---|
| Stone Golem | rolling boulders: dodge and blast them back |
| Magma Oni | the floor turns to lava pools: stand on the safe rocks |
| Frost Yeti | the cold freezes you unless you keep charging (charging keeps you warm) |
| Thunder Tengu | lightning rings expand: jump through the gaps |

3. **Finisher: the BEAM CLASH** (5-10 s): the iconic anime moment.
   - The push uses your remaining power plus PERFECTs.
   - **Tap on the red flash** to counter.
   - Win → a slow-motion KO, the boss shatters, a loot explosion.
- **Length:** 60-90 s total, so it feels like an event.
- **Losing** shows exactly which phase beat you.
- **Bosses stay solo,** so every player gets their moment, but nearby players can **jump in and assist** (extra damage, shared loot).

### World Boss (Plaza, every 30 min)
- A giant boss lands in the Plaza. **Everyone in the server fights it together.**
- Rewards depend on the damage you dealt.
- It's the main "everyone sees everyone's auras" moment.

---

## 7. The endgame (what you chase forever)

1. **Infinity Tower:** endless boss floors, each harder, with a new boss **combination** every 10 floors. Best floor = leaderboard and Plaza statues.
2. **Secret hunting:** 8 Secrets, plus Rainbow Secrets as the ultimate flex. Global "first hatch" fame.
3. **Awakening tree:** max out every perk across many Ascensions. The halo gains stars forever.
4. **Collection:** the Spirit Index (every spirit, Gold, Rainbow, Shiny, Secret), Boss Spirits, and Bonded looks.
5. **World Boss ranks:** weekly damage leaderboards.
6. **Live content:** a **new zone every 2-4 weeks** (new crystals, spirits, boss and Secret), plus seasonal events. (The owner designs monetization around these.)

---

## 8. The first 3 minutes (what a new player feels)

| Time | Moment |
|---|---|
| 0:00 | spawn in a glowing grove full of small crystals; a pulsing "HOLD" hand |
| 0:05 | first PERFECT: the crystal **explodes**, coins fly into you, your aura **drinks the energy** and flickers bigger |
| 0:30 | a 5-PERFECT chain → **OVERDRIVE**: chain blasts wipe the grove, coins everywhere ("WHOA") |
| 0:45 | the free tutorial egg: an Epic-style hatch even though it's a Common (first-hatch exception: the tutorial is dramatic once) |
| 1:00 | your first spirit **dives at a crystal with you.** Bond it, and your aura turns its element |
| 2:00 | the Crystal Heart spawns; other players gather; a group smash; a jackpot |
| 3:00 | the boss gate glows: "READY". The Stone Golem fight: armor, boulders, then the BEAM CLASH, a slow-motion KO, transform to BLAZE |

---

## 9. What changes vs v2 (owner decisions)

| Area | v2 | v3 (proposed) |
|---|---|---|
| Core action | hold on a stone | **charge-blast crystals** (targets, explosions, loot) |
| Coins | from releases | **from breaking crystals** |
| Spirits | orbit + feed energy | **fight beside you** with signature moves + team strikes |
| Aura look | Wardrobe | **the Bonded spirit** |
| Eggs | colour tell, 2 s | **a hatch ladder up to Mythic / Secret cutscenes** |
| Secrets | none | **1 per zone, odds shown as ???, Secret events** |
| Ascension | multiplier + halo | **+ an Awakening perk that changes play** |
| Bosses | beam clash only | **3 phases: armor → unique mechanic → beam finisher**, plus an hourly **World Boss** |
| Endgame | Infinity tiers | **Infinity Tower + Secrets + perk tree + World Boss ranks + new zones** |

**What stays from v2:**
- the charge / PERFECT / Overdrive timing;
- fusion;
- zones;
- the honesty rules;
- saving;
- the playtest method.

**After approval:** re-tune `econ/` to these rules (crystal HP / payouts, spirit damage, boss phases), then build the two-zone test with **these** moments.
