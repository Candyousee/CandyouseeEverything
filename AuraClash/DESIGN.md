# AURA CLASH: full mechanics design (v2, 2 October 2026)

This document says exactly what the player does, what happens, why it matters, and the numbers behind it. Everything is built **from scratch**: spirits, the hatching, the aura, the clash. No existing systems are reused.

The numbers come from simulations:
- `econ/model.py`: pacing and crate odds;
- `econ/clash_sim.py`: the boss clash, 2,000 simulated fights per row.

All of it gets re-tuned in the greybox.

---

## 0. WHAT IS THE POINT?

**The fantasy:** *"I started as a nobody with a spark, and now my aura is a storm that the whole server stops to look at, and I beat every boss to prove it."*

The goals stack so there's always a next one at every time scale:

| Time scale | Goal | What the player sees |
|---|---|---|
| **1 second** | Land a PERFECT release | the ring hits the glow → BOOM, a combo flame grows |
| **1 minute** | Reach the next aura form; afford the next egg | the form bar fills with the next form's silhouette; the egg price turns green |
| **5-20 minutes** | Beat this zone's boss → unlock the next zone | the boss gate's power number turns gold when you're ready |
| **1 hour** | Ascend → a new aura colour + a permanent multiplier | the Ascend button appears with a preview of your new colour |
| **1 day** | Incubator hatch, daily boss rewards, streak, ranked chest | a "ready!" glow on return |
| **1 week** | Climb the clash rank; get the weekly limited aura | a rank badge on your nameplate; the limited style's stock dropping |
| **Forever** | Be on the hub statues; complete the spirit and style index | your statue with your live aura, in the hub |

**Why players spend:** everything you buy makes you **look** more powerful or **get there** faster. Aura size, style, colour, spirits and rank are all visible to everyone.

---

## 1. Controls (every platform)

| Action | PC | Phone / tablet | Gamepad |
|---|---|---|---|
| Charge | hold Left Mouse or Space | hold the big CHARGE button (bottom right, 120 px) | hold R2 |
| Release | let go | let go | let go |
| Quick tap | click | tap | tap R2 |
| Move | WASD | thumbstick | left stick |
| Hatch | E at an egg | the HATCH button at an egg | X |
| Menus | HUD buttons / hotkeys 1-5 | HUD buttons | D-pad |

One button does everything in training and clashes: **hold and release**. An 8-year-old learns it in 5 seconds.

---

## 2. TRAINING: how you get power

### 2.1 Where you train

- Each zone has **3 Training Stones**: Small, Big and Giant. They're glowing rocks, each with a platform.
- Stand on a stone's platform to train there. Off a stone, you can still train at ×0.25, so there's never a dead moment.
- **Stone multipliers** inside a zone: Small ×1, Big ×3 (needs 10% of the zone's boss power), Giant ×8 (needs 40%).
  - **WHY:** a mini-goal inside every zone. You see the Giant stone glowing and want to reach it.
- **Stones are shared** (any number of players), so training is social: you see others' auras flare next to yours.

### 2.2 The charge-release (the core action)

While on a stone:

1. **HOLD:**
   - your character drops into a power stance, fists clenched;
   - your aura starts swelling, and a **ring** appears on the ground, shrinking toward you over **1.2 seconds**;
   - a rising hum plays.
2. Near the end, a **glow band** appears where the ring meets your feet. That's the **PERFECT window: 0.18 s** wide.
3. **RELEASE.** The result depends on timing:

| Release | When | Power gained | Feedback |
|---|---|---|---|
| **Quick tap** | released in < 0.3 s | ×0.3 | small puff, tick sound |
| **Early** | before the window | ×0.6 | a medium flare |
| **PERFECT** | inside the window | ×2.0 × combo | the aura BOOMS outward, a shockwave ring, a screen kick, a rising pitch, "PERFECT!" in big text, spirits flash |
| **Overcharge** | held past the window | ×0.5 + a 0.4 s stagger | the aura fizzles, a dull pop |

### 2.3 Combo

- Each consecutive PERFECT raises the combo: ×1 → ×1.25 → ×1.5 → ×1.75 → **×2 (max, "ON FIRE")**.
- The combo is shown as **flames on the character's fists and feet** that get bigger. No number needed, though a small ×1.5 floats above.
- Anything that isn't a PERFECT resets it. At max combo the aura turns white-hot and the music gets a beat layer.
- **WHY:** a rhythm. Good players get into a flow state ("ON FIRE"), while average players still progress fine.
- **Expected average:** a casual player averages about ×1.25 versus pure tapping; a skilled player about ×3.

### 2.4 The power formula (server-side)

```
gain = stoneBase(zone, stone) × releaseMult × comboMult × spiritMult × formBonus × ascensionMult × passes × boosts
```

| Factor | Value |
|---|---|
| `stoneBase` | zone 1 Small = 1, ×6 per zone, × the stone multiplier |
| `formBonus` | +5% per aura form reached in this Ascension (max +45%) |
| `ascensionMult` | 1 + 0.75 × Ascensions |
| `passes` | 2× Power pass = ×2 |
| `boosts` | 30-min boost = ×2 (passes and boosts multiply, total cap ×4) |

**Coins:** every release also earns coins = gain ÷ 10 (shown as a coin trickle into the HUD counter).

### 2.5 Auto-Train (the pass)

- A toggle button: your character keeps charging and releasing automatically, at **Early-level quality** (×0.6, no combo), one cycle per second.
- **WHY:** idle play and AFK farming (the top reason people buy it), while skill still beats it (a skilled player earns about 5× more per minute than Auto-Train). Being there and playing well always matters.

### 2.6 Anti-cheat

- The client sends release events with timestamps. The server checks them:
  - cycle length ≥ 0.3 s;
  - at most 4 releases a second;
  - the PERFECT window is checked against the server's own record of when the hold started (±80 ms latency allowance).
- Perfect rate above 97% over 200 releases → flagged as a bot, removed from leaderboards, and the PERFECT multiplier is capped for that session.
- Auto-clickers gain nothing: quick taps are only ×0.3.

---

## 3. THE AURA: how it works

Your aura is made of **four separate layers**. Each comes from a different system, so every system visibly changes how you look:

| Layer | Comes from | Controls |
|---|---|---|
| **Size** | Power | how big: from a 3-stud glow to a 40-stud storm |
| **Form** | power milestones (10 per Ascension) | how many VFX layers, and their behaviour |
| **Colour tier** | Ascension count | the base palette (white → gold → crimson → violet → void → prismatic) |
| **Style** | crates / limiteds | the flavour of the particles: fire, ice, lightning, sakura, galaxy, glitch… |

Plus **spirits**, which orbit inside it (section 4).

### 3.1 Size

`radius = 3 + 4.2 × log10(1 + power / 100)` studs, capped at 40.

**WHY log10:** power goes from 10 to trillions, but the aura must keep growing visibly every session. Log10 adds about 4 studs per ×10 power, and ×10 power takes about one zone, so every zone your aura is clearly bigger.

### 3.2 The 10 forms (reached by power; thresholds set per Ascension)

| # | Form | Unlocks at (first run) | New layer added |
|---|---|---|---|
| 1 | Spark | start | a soft glow + a few rising motes |
| 2 | Flame | 150 power (~30 s) | wisps rising (flipbook) |
| 3 | Blaze | 1.5K (~3 min) | a ground ring + heat shimmer |
| 4 | Surge | 15K (~9 min) | arcs crawling over the body |
| 5 | Storm | 150K (~20 min) | orbiting debris (rocks lifting off the ground) |
| 6 | Tempest | 1.5M (~38 min) | **power surges** (a burst every 4 s) + server announcement |
| 7 | Nova | 15M (~60 min) | a sky beam on each PERFECT |
| 8 | Eclipse | 150M (~90 min) | dark halo + a corona |
| 9 | Titan | 1.5B (~2.5 h) | a ground crack decal + a camera hum near you |
| 10 | Ascended | 15B (~3.5 h) | wings / crown of light (depends on style) + every PERFECT shakes nearby screens slightly |

- **Transformation moment (2 s):**
  - your character freezes in a pose; time slows locally;
  - the camera pushes in;
  - the aura implodes, then explodes into the new form;
  - the form name slams on screen with a sound sting.

  Forms 6+ get a server-wide announcement and a beam visible from anywhere on the map.
- **Each form gives +5% power,** so it's a real reward, not just looks.
- **After Ascension** the thresholds scale up (×10 per Ascension), so you transform all over again on every run, in your new colour.

### 3.3 Performance

- **Your own aura:** full layers.
- **Other players' auras:** full within 60 studs; reduced layers 60-150; size + colour only beyond that.
- Particle rates follow the quality settings (High / Med / Low / Off + reduced flash).

---

## 4. SPIRITS: the pets, from scratch

### 4.1 What a spirit is

- A small creature made of **light and energy**: a fox, a dragon, an owl, a koi, a lion, a tanuki, a phoenix…
- Every zone has its own family of spirits matching the zone theme: lava spirits in the Lava Dojo, frost spirits on the Frozen Peak.
- Each spirit has:
  - **a rarity:** Common, Rare, Epic, Legendary, Mythic, Secret;
  - **a Power bonus:** e.g. +20%;
  - **one Trait** (section 4.4);
  - **a variant:** Normal, or Shiny (1 in 100 on hatch, sparkle + ×1.2).

### 4.2 Hatching (the egg sequence, built new)

1. **Walk up to an egg stand.** It has a display: the egg spins slowly, with **all the possible spirits and their exact odds** shown on a card above it. The price is green if you can afford it.
2. **Press HATCH** (×1, or ×3 with the Triple Hatch pass). The camera frames the egg in front of you, everything else dims, and the egg drops in.
3. **Shake phase:**
   - the egg wobbles 3 times, each harder;
   - cracks glow in the colour of the rarity (**the colour is the tell**: blue = Rare, purple = Epic, gold = Legendary, rainbow = Mythic);
   - higher rarities shake longer and add a light beam and a drumroll.
4. **Burst:**
   - the egg explodes into light;
   - the spirit forms in a pose, with its name and rarity banner;
   - "NEW!" if you've never had it;
   - Legendary+ get a server announcement and a short fanfare.
5. **Click / tap to skip** at any time. Fast Hatch skips the shake.

**WHY the colour tell:** the tension of the wobble ("is it gold?!") is the moment that makes hatching addictive and sells crates.

### 4.3 How the orbit works

- **Equipped spirits** (3 at the start, up to 12) live **inside your aura**, on **three tilted rings**:
  - an inner ring of 4 slots at radius 0.45 × aura size, tilted 20°;
  - a middle ring of 4 at 0.7×, tilted −35°;
  - an outer ring of 4 at 0.95×, tilted 60°.

  Each ring spins at a different speed, and the rings grow as your aura grows.
- Spirits **bob and turn to face the way they travel**. Each one leaves a short light trail in its own colour, and tints the aura around it. Many rare spirits = a visibly richer, multicoloured aura.
- **When you train:**
  - spirits speed up while you charge;
  - on release, each spirit **fires a streak of energy into your chest**. That's literally the "spirit feeds your aura" multiplier, made visible;
  - on a PERFECT, they all flash.
- **In a clash,** spirits with the Clash trait fly out and fire bolts at the beam meeting point.
- **When idle,** spirits peel off and wander around you (play, sniff, nap), then snap back into orbit when you charge. WHY: they feel alive and yours.
- **Tech:**
  - orbit positions are computed on the client each frame (CFrame maths, no physics);
  - the server only stores which spirits are equipped;
  - other players' spirits are drawn from that list at reduced detail by distance;
  - each spirit is one MeshPart + one trail + one small particle emitter.

### 4.4 Traits (the decision when picking a team)

Each spirit has ONE trait. **WHY:** "equip the strongest" alone is no decision. Traits make you choose a team for what you're doing.

| Trait | Effect |
|---|---|
| **Might** | +Power bonus counts double (pure training) |
| **Focus** | the PERFECT window is +0.02 s wider (stacks to +0.08) |
| **Fury** | +1 max combo step (stacks to +2: ×2.25, ×2.5) |
| **Clash** | fires assist bolts in clashes (+0.4 push/s each) |
| **Fortune** | +coins |
| **Luck** | + egg and crate luck |

There's an **"Equip Best"** button with modes: Training / Clash / Coins / Luck. Kids just press it; min-maxers build teams.

### 4.5 Spirit Power and fusing

- **Total spirit multiplier** = 1 + the sum of equipped spirits' Power bonuses (×2 for Might spirits).
- **Fusing:**
  - 5 identical spirits → **Gold** (×1.5 its bonus, a gold shimmer);
  - 5 Gold → **Rainbow** (×2.5, a rainbow shimmer).

  The fusion machine in the hub shows the result first and plays a short fusion animation.
- **Inventory:**
  - 200 spirits (more via a pass);
  - "Delete all Common", plus auto-delete settings per rarity.

### 4.6 Boss spirits

- Each boss has a **1% drop** of its unique **Boss Spirit** (Mythic, with the Clash trait) on each daily rematch win.
- **WHY:** a reason to rematch every day and to show off ("I have the Lava King spirit").

---

## 5. BOSS CLASHES: how you defeat a boss

### 5.1 The arena

- At the end of each zone is a **boss arena** behind a gate. The gate shows the boss's portrait and its **Boss Power**.
- **Readiness colour:**
  - red when your power is below 0.7× the boss's;
  - orange from 0.7× to 1.1×;
  - **gold at 1.1× or more** ("READY").
- Walk through the gate to start. The fight is solo, in your own instance of the arena.

### 5.2 The fight

1. **Intro (3 s):** the boss lands, roars, and its name slams on screen. The camera sets up a side view: you on the left, the boss on the right.
2. **The beam clash (up to 45 s):**
   - both beams fire and meet in the middle;
   - a **clash bar** at the top shows where the meeting point is (50% at the start). Push it to the boss's side (100%) to win. If it reaches your side (0%) or time runs out, you lose.
   - **Base drift:** every second the meeting point moves by `8 × (√(yourPower/bossPower) − 1)`. Stronger than the boss = it drifts toward the boss; weaker = toward you.
   - **Your attacks:** the same hold-release as training. A **PERFECT** shoves the beam +1.8%, plus 0.5% per combo step. An Early release gives +0.5%.
   - **Boss surges:**
     - every 5 s the boss glows red, its eyes flash, and a warning sound plays (a 1-second tell);
     - then it surges;
     - if you land a PERFECT during the surge, you **counter**: +3% and a big spark burst;
     - if you don't, it hits: −5%;
     - below 25% of its side left (meeting point past 75%), the boss goes **enraged**: surges come every 3 s.
   - **Clash-trait spirits** fly out and fire bolts at the meeting point (+0.4%/s each).
3. **Win:**
   - the meeting point hits the boss; slow-mo; your beam swallows it; the boss shatters into light;
   - a coin explosion and the first-clear chest (coins + an aura crate + the next zone's first egg free);
   - the next zone's teleporter lights up, and its theme music plays.
4. **Lose:**
   - you're knocked back with a "so close" camera shake;
   - a result card shows how far you got ("84%") and **one tip**: "Need ~15% more POWER", or "Counter the red surges with a PERFECT!";
   - a 2× Power boost offer button (closable);
   - retry in one tap.

### 5.3 Is it fair? (simulated, 2,000 fights per row)

| Your power vs the boss's | Weak player (25% perfects, 20% counters) | Average (55% / 50%) | Skilled (85% / 85%) |
|---|---|---|---|
| 0.7× | 0% | 0% | **62% win** |
| 0.8× | 0% | 1% | 96% |
| 1.0× | 0% | **47%** | 100% |
| 1.1× (gold "READY") | 0% | **83%** | 100% |
| 1.25× | 18% | 100% | 100% |
| 1.5× | **99%** | 100% | 100% |

- **What this means:**
  - a skilled player can beat a boss at 70-80% of its power (skill matters);
  - an average player wins most of the time once the gate turns gold;
  - a weak player just trains a bit longer and always wins at 1.5×.

  Nobody is ever stuck. A fight lasts 20-40 s.
- **Daily rematch:** each beaten boss pays a coin reward once a day, plus the 1% Boss Spirit chance.

---

## 6. BATTLING OTHER PLAYERS: Clash Arena (at launch)

### 6.1 How it works

- The **hub arena** has two pads. Stand on one; anyone can step on the other, or you can challenge a player directly (tap their nameplate → CLASH).
- **Same beam clash, player vs player:** both of you hold-release; surges come from both sides (each player's PERFECT combo of 3 triggers a surge on the opponent, who counters with a PERFECT).
- **Fairness:** drift uses `√(powerRatio)`, capped at a 3× ratio. A player up to about 1.5× weaker can win with better skill; beyond 3×, the stronger always wins.
- **Spectators** watch from the stands. The clash bar is shown above the arena for everyone. **WHY:** crowds = show-off = spending.

### 6.2 Ranked Clash

- A queue button matches you with someone within ±30% of your power.
- **Ranks:** Bronze → Silver → Gold → Platinum → Diamond → Champion (top 100). Win = +rank points; lose = − (less than a win gives).
- A rank badge on your nameplate and an aura nameplate frame.
- **Weekly season:** a rank chest by tier (coins, crates, an exclusive rank aura frame).
- **WHY:** it gives late-game players something to do with their power, and a skill ladder that money can't fully buy (power helps, skill decides close fights).

### 6.3 Stakes

No items or currency are ever bet. You win rank, a streak flame on your nameplate, and bragging rights. (It's safe and simple, and avoids gambling issues.)

---

## 7. ASCENSION: how the rebirth works

- **Unlocks** after beating the zone 4 boss.
- **The Ascend button** shows a preview of what you'll get: your aura in the next colour tier, the new multiplier and the new slot.
- **Resets:** power, forms, zone access, coins.
- **Keeps:** spirits, styles, passes, index, rank, incubator.
- **Gives:**
  - ×(1 + 0.75 × n) power;
  - the next colour tier;
  - +1 spirit slot (Ascensions 1-3);
  - an Ascension number on your nameplate.
- **Ceremony (4 s):** you rise into the air, your aura collapses into a point of light, then bursts out in the new colour. Server announcement.
- **Replays get faster** (model): zones 1-4 take about 29 min at A1, 20 at A2, 15 at A3, 11 at A5.
- **WHY it's fun, not a punishment:** you instantly look cooler (the new colour) and blast through the early zones in minutes. Pure power fantasy.

---

## 8. AURA STYLES: crates, from scratch

- **The crate shrine** in the hub: a giant floating crystal. Crates can be opened ×1 or ×10.
- **Opening sequence:**
  - the crystal cracks; the rarity colour tell (same as eggs);
  - the style is revealed **on your own character**, so you see yourself wearing it;
  - "EQUIP NOW" button.
- **Odds, shown on the shrine before buying:**

| Rarity | Odds |
|---|---|
| Common | 60% |
| Rare | 28% |
| Epic | 9% |
| Legendary | 2.5% |
| Mythic | 0.5% |

- **Pity:** a Legendary or better by 50 opens; a Mythic by 300. A visible pity counter on the shrine.
- **Styles change the look only,** plus the index bonus (+1% power per 5 styles collected). Mythic styles also change the transformation burst and add a unique sound.
- **Where crates come from:**
  - earned: boss first-clears, day 7 of the streak, ranked chests, playtime chests;
  - paid: Robux (PolicyService-restricted regions see direct-buy styles instead).

---

## 9. DAILY AND WEEKLY

| System | How it works | WHY |
|---|---|---|
| **Incubator** | put 1 egg in the hub incubator → it hatches in 8 h with ×2 luck. Skippable for Robux | you leave with a reason to come back |
| **Streak** | daily login days 1-7; day 7 = an earned aura crate; missing a day resets it | habit |
| **Daily rematches** | each beaten boss pays once per day + a 1% Boss Spirit chance | purposeful play every day |
| **Playtime chests** | one every 10 min online (up to 6) | longer sessions |
| **Weekly limited aura** | 1 new style a week: a real stock count (e.g. 5,000) or a 7-day end date, shown in the shop and on owners | urgency + show-off |
| **Ranked season** | resets weekly with chests by rank | competitive return |

---

## 10. Edge cases

- **Leaving mid-clash:** counts as a loss for ranked; nothing is lost for bosses.
- **Disconnect mid-hatch:** the server already rolled and saved the spirit before the animation, so nothing is lost.
- **Full inventory:** hatching is blocked, with a "Delete Commons?" one-tap prompt.
- **Very weak player in ranked:** the queue only matches within ±30% power.
- **Exploits:**
  - all rolls are made on the server;
  - releases are validated (section 2.6);
  - the clash meeting point is simulated on the server from validated releases, and the client only displays it.
