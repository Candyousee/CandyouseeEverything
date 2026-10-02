# AURA CLASH: the core game (no monetization; the owner designs that)

## What it is

**A pet training simulator.**
- You train your power, hatch spirits (pets), and grow the biggest aura in the server.
- The only fighting is the boss clash that ends each zone.
- No player-vs-player.

**The fantasy:** *"I started with a spark; now my aura is a storm everyone stops to look at."*

## The 4 systems (the whole game)

1. **TRAIN:** gain power.
2. **SPIRITS:** pets that multiply your power and decide how your aura looks.
3. **ZONES:** 8 islands, each ending with a boss clash.
4. **ASCEND:** rebirth for a permanent boost and a new aura colour.

## The loop

```
Train → power + coins → hatch spirits → train faster → beat the boss → next zone
→ (after zone 4) Ascend → replay faster → push further
```

---

## 1. TRAIN

- **Where:** each zone has one **Training Stone**. Stand on it to train (off the stone you train at ×0.25).
- **The one button** (hold Mouse / Space, the CHARGE button on mobile, R2 on gamepad):
  1. **Hold:** you take a power stance, your aura swells, and a ring shrinks toward you over **1.2 s**.
  2. **Release** when the ring hits the glow band (**0.18 s window**) = **PERFECT**: ×2 power, a BOOM, a screen kick.
- **Other releases:**

| Release | Power |
|---|---|
| Early | ×0.6 |
| Held too long | ×0.5 + a 0.4 s stagger |
| Quick tap | ×0.3 |

- **Combo:** PERFECTs in a row go ×1.25 → ×1.5 → ×1.75 → ×2 ("ON FIRE"). Flames grow on your fists. Any miss resets it.
- **Every release gives:** power, plus coins (power ÷ 10).
- **Stone upgrades** (bought with coins in each zone):

| Level | Cost | Training power |
|---|---|---|
| Lv 2 | 25% of the boss's power, in coins | ×2 |
| Lv 3 | 60% | ×4 |

- **Power per release:**

```
stone base × stone level × release × combo × spirits × forms × ascension
```

- **Stone base** is ×6 per zone.

## 2. SPIRITS

- **Eggs:** each zone has an egg stand that costs coins. It shows every spirit inside and its odds.

| Rarity | Odds |
|---|---|
| Common | 60% |
| Rare | 28% |
| Epic | 10% |
| Legendary | 1.9% |
| Mythic | 0.1% |
| Shiny (on any hatch) | 1 in 100, ×1.2 |

- **Hatching:**
  1. The egg drops in front of you and wobbles 3 times.
  2. **The cracks glow in the rarity's colour** (blue Rare, purple Epic, gold Legendary, rainbow Mythic).
  3. It bursts, and the spirit appears with its name.
  4. Click to skip.
- **Each spirit has:**
  - a **power bonus**: e.g. zone 1 Common +10%, Mythic +400%; it rises about ×2.2 per zone;
  - an **element**: Fire, Frost, Storm, Nature, Light, Void or Cosmic (it matches the zone it comes from).
- **Equip slots:** 3 to start; +1 at zones 2, 4 and 6; +1 at Ascensions 1-3 (9 max). **"Equip Best"** is one button.
- **Spirit power** = 1 + the sum of the equipped bonuses.
- **Fusing:**
  - 5 identical spirits → **Gold** (×1.5);
  - 5 Gold → **Rainbow** (×2.5).

  Nothing hatched is ever useless.
- **Spirits ARE your aura:**
  - equipped spirits **orbit inside your aura** on 3 tilted rings that spin at different speeds;
  - when you charge they speed up; on every release, each one **fires a streak of energy into you** (you see them powering you up);
  - when you're idle, they wander around you, then snap back when you charge.
- **Your aura's look comes from your best spirit:**
  - its **element** sets the effect: Fire = flames, Frost = ice crystals, Void = dark tendrils, and so on;
  - its **rarity** sets how intense the effect is: Common = a soft glow, Mythic = full hero effects.

  Better spirits mean a visibly rarer aura.

## 3. YOUR AURA (what everyone sees)

| Part | Comes from |
|---|---|
| **Size** | your power: `3 + 4.2 × log10(1 + power/100)` studs (about +4 studs per zone, max 40) |
| **Look** | your best equipped spirit (element + rarity) |
| **Colour tier** | your Ascensions (white → gold → crimson → violet → void → prismatic) |
| **Form** | power milestones (below) |

**10 forms per Ascension:**
1. Spark
2. Flame
3. Blaze
4. Surge
5. Storm
6. Tempest
7. Nova
8. Eclipse
9. Titan
10. Ascended

- **Each form:**
  - a 2-second transformation (the camera pushes in, your aura implodes and explodes, the name slams on screen);
  - +5% power;
  - one more effect layer.
- **Forms 6+** are announced to the whole server.

## 4. ZONES + BOSS CLASH

| Zone | Theme / element | Boss | Clear time (first run) |
|---|---|---|---|
| 1 | Training Grounds / Light | Stone Golem | 3 min |
| 2 | Lava Dojo / Fire | Magma Oni | 6 min |
| 3 | Frozen Peak / Frost | Frost Yeti | 10 min |
| 4 | Storm Temple / Storm | Thunder Tengu | 15 min (**Ascend unlocks**) |
| 5 | Sakura Realm / Nature | Kitsune Queen | 25 min |
| 6 | Sky Sanctuary / Light | Sun Phoenix | 40 min |
| 7 | Void Rift / Void | Void Titan | 60 min |
| 8 | Galaxy Throne / Cosmic | Star Emperor | 90 min |

- **Each zone is one island:** the stone, the egg stand, and the boss gate at the far end. Walking from spawn to the gate takes under 15 s.
- **The boss gate** shows one number: the boss's power. It turns **gold when you have 1.1×** that power.
- **The clash (solo, 20-40 s):**
  - your beam and the boss's beam meet in the middle, with a bar at the top showing where;
  - **your power** slowly pushes the beam toward the boss (or the boss pushes it toward you, if it's stronger);
  - **PERFECT releases** shove it harder, and more so with a combo;
  - **every 5 s the boss glows red** (a 1-second warning): land a PERFECT right then to **counter** (shove +3%); miss and it **hits** (−5%);
  - near the end, the boss gets **enraged**: red surges every 3 s;
  - beam to the boss = **win**; beam to you, or 45 s pass = **lose**.
- **Fairness** (2,000 simulated fights each):

| Player | Wins at |
|---|---|
| Skilled | 0.8× the boss's power |
| Average | 1.1× (gold gate), about 83% of fights |
| Weak | 1.5× |

- **Win:** the boss shatters; a coin explosion; a free egg for the next zone; the next zone opens.
- **Lose:** "Need ~15% more power" or "Counter the red!"; retry in one tap.

## 5. ASCEND

- **Unlocks** after the zone 4 boss.
- **Resets:** power, forms, coins, zones.
- **Keeps:** spirits.
- **Gives:**
  - **×(1 + 0.75 × Ascensions)** power, for good;
  - the next **aura colour**;
  - +1 slot (A1-A3).
- **Ceremony:** you rise, your aura collapses to a point, then bursts out in the new colour. Announced to the server.
- **Replays get faster:** zones 1-4 take ~19 min after A1, ~14 after A2, ~10 after A3. Each run you push further into zones 5-8.

## 6. THE FIRST HOUR (exact)

| Time | What happens |
|---|---|
| 0:00 | spawn on the stone; a pulsing "HOLD" hand |
| 0:10 | first PERFECT |
| 0:30 | **FLAME** form |
| 1:00 | first spirit hatched, orbiting you |
| 1:45 | 3 spirits; the aura is tinted by their element |
| 2:15 | stone Lv 2 |
| 3:00 | **Boss 1 beaten** → zone 2 |
| 3:30 | **BLAZE** form |
| 5:00 | first Rare+ → the aura's look changes |
| 6:00 | 4th slot |
| 7:30 | first fusion (Gold) |
| 9:00 | **Boss 2** → zone 3 |
| 11:00 | **SURGE** form |
| 19:00 | **Boss 3** → zone 4 |
| 20:00 | 5th slot, **STORM** form |
| 34:00 | **Boss 4** → **Ascend** unlocks |
| 35:00 | Ascension 1: gold aura, ×1.75 |
| ~54:00 | zone 5, for the first time |

- **First full run:** about 4 h 10 min of play.
- **Something new at least every 2 minutes** in the first 30.

## 7. Reasons to come back (core only)

- **Incubator:** put in 1 egg; it hatches in 8 h with ×2 luck.
- **Daily streak:** days 1-7, with rewards rising.
- **Daily boss rematch:** coins, plus a 1% **Boss Spirit** (a unique Mythic per boss).
- **Playtime chests:** every 10 minutes online.

## 8. HUD (5 buttons max, no text tutorials)

- **Buttons:** Spirits, Eggs (teleport to the stand), Teleport (zones), Ascend (it appears when available), Settings.
- **Always on screen:**
  - the power counter;
  - the next-form bar (with the next form's silhouette);
  - coins.
- **Teaching is visual:**
  - a pulsing hand on "hold";
  - a glowing path to the egg;
  - the gate turns gold when you're ready.

## 9. The test that decides everything

**Greybox first** (1-3 h):
- the stone + charge/release + combo;
- 1 egg with 5 spirits orbiting;
- the aura growing;
- 1 boss clash;
- zone 2.

Then **your playtest #1.** If the hold-release and the clash aren't fun in grey boxes, we change them before any art.
