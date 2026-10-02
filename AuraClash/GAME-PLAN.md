# GAME PLAN: Aura Clash (draft v1, 2 October 2026; for owner approval)

Every system below answers two questions:
- **WHY** it makes players stay or pay;
- **HOW** it works.

The numbers come from `econ/model.py` and are tuned during the greybox.

---

## 0. Market check

- **Trending:**
  - Simulators are the top-grossing genre.
  - Anime fighters and aura games stay strong.
  - "Steal a" / "grow a" clones are saturated; we'd be late.
- **Proven demand:**
  - Aura Ascension: about 18K players online at once, about $156K a month (estimate).
  - Many smaller aura trainers (TRAIN YOUR AURA, +1 Aura for Anime, Max Your Aura).
- **Weakness of the field:** many look like "number goes up" with basic effects (from listings; check by playing the top 3 before greybox). Pet Simulator players complain about pay-to-win, too many systems and bad pacing.
- **The gap we fill:** the aura sim where your aura is a **spectacle** (level-5 VFX transformations the whole server sees), with a **skill moment** in every loop (charge-release + boss clashes) and clean pacing.
- **Verdict:** GO, provided the greybox proves the charge + clash loop is fun.

## 1. Pitch

- **One sentence:** *Train your aura, hatch spirits that power it, and clash bosses until you're the brightest player in the server.*
- **Who:** 8-14-year-olds who play anime fighters and simulators, and who love showing off.
- **Why it beats the field:** competitors sell a number. We sell a **transformation**: going from a spark to a screen-filling storm, with a cinematic moment every few minutes, plus a reason to use skill.

---

## 2. Core loop

```
CHARGE & RELEASE  →  POWER  →  AURA GROWS / TRANSFORMS  →  COINS → SPIRITS  →  CLASH BOSS  →  NEW ZONE
        ↑__________________________ stronger multipliers ______________________________|
```

### 2.1 The core action: charge and release (not just clicking)

- **WHY:** plain clicking dies by the 50th time; competitors are pure clicking. A tiny skill moment makes every tap feel earned, and it gives the player something to master.
- **HOW:**
  - **Tap** = a small gain.
  - **Hold** = your aura swells, and a ring closes around you.
  - **Release** when the ring hits the glow zone = a **PERFECT** burst: ×2 power, a big pop, a screen kick and a rising pitch.
  - **Combo:** perfect releases in a row climb ×2 → ×2.5 → ×3, and reset on a miss. The meter is drawn as the aura itself getting hotter (no text).
  - **Average gain** for a decent player is about ×1.25 (the model uses this).
  - **Auto-Train pass:** trains automatically at normal rate (no perfects). So skill always beats paying for raw speed, but paying lets you go AFK.
- **Feel:** <100 ms response, a squash on the character, number pops, a coin trickle into the HUD.

### 2.2 Power → visible aura

- **WHY:** the reward has to be SEEN. Big numbers mean nothing to an 8-year-old; a bigger, wilder aura means everything, and other players see it.
- **HOW:**
  - **Aura size** = log10(Power), so it keeps growing visibly even as numbers explode.
  - **10 transformations per Ascension** at power thresholds: Spark → Flame → Blaze → Surge → Storm → Tempest → Nova → Eclipse → Titan → Ascended.
  - Each transformation adds VFX layers (VFX ladder: early forms level 3, late forms level 5).
  - **Transformation moment (2 s):** time slows, the camera pushes in, the aura bursts outward, a shockwave ring, a sound sting, and the name slams on screen.
  - **Forms 6+ are announced** to the whole server ("Nik reached NOVA!"). That's social proof and envy.

### 2.3 Coins and spirits (the pets)

- **WHY:**
  - Spirits are the second, more personal collection; they reuse our tested Stud Pets system.
  - They multiply training, so they're the main thing coins are spent on.
  - Visually, they **orbit inside your aura and colour it**, so a rare spirit makes your whole aura look rarer.
- **HOW:**
  - **Coins:** training earns coins (1 coin per 10 power gained). Coins are the only soft currency.
  - **Eggs:** each zone has 2 coin eggs (common / premium-coin) and 1 Robux egg. Each zone's eggs are better than the last.
  - **Rarities:** Common / Rare / Epic / Legendary / Mythic (+ Secret, at 1 in 1M, in later zones). Each spirit gives a power multiplier.
  - **Equip slots:** start 3 → +1 at zones 3, 5 and 7 → +1 per Ascension 1-3 → passes add +2 (max 12).
  - **Fusion:**
    - 5 of the same spirit → **Gold** (×1.5);
    - 5 Gold → **Rainbow** (×2.5).

    WHY: duplicates are never wasted, so every hatch has value.
  - **Spirit fusion VFX:** fused spirits leave a trail and pulse with your perfect releases.
- **Pacing check:** the model assumes the typical equipped spirit multiplier is ×1.5 in zone 1, rising to ×200 in zone 8.

### 2.4 Boss clash: the zone gate (the fighting moment)

- **WHY:**
  - Every zone needs a **visible goal and a climax**, not just a number wall.
  - The beam struggle is the most iconic anime moment there is: instantly understood, great on video, and it's where skill pays off.
- **HOW:**
  - Each zone's arena has a boss. Its gate shows a single number: the power needed. It glows green when you're ready.
  - **Clash (10-20 s):** your beam and the boss's beam meet in the middle. Charge-release perfects push your beam; holding steady keeps it.
  - **Push speed** = your Power ÷ the boss's Power, with perfects adding bursts. A skilled player can win at about **0.8×** the listed power; a weak one needs about 1.1×.
  - **Win:**
    - a slow-mo finish, the boss shatters, a coin explosion;
    - zone unlocked, and its theme music hits;
    - a "first clear" chest.
  - **Lose:** no penalty, plus a hint ("Need 20% more POWER"), and a pop-up offer for a 2× Power boost (a moment of want).
  - **Rematch daily** for coin rewards. That gives a reason to return.

### 2.5 Ascension (the rebirth meta-loop)

- **WHY:**
  - Long-term goals and a reason to replay zones faster.
  - The reset is turned into a **ceremony** that makes you look cooler, never a loss.
- **HOW:**
  - **Unlocks** after beating the zone 4 boss (about 50 minutes in on a first run).
  - **Resets:** power, zone access and coins.
  - **Keeps:** spirits, aura styles, passes and the index.
  - **Gives:**
    - a permanent **×(1 + 0.75·n)** power;
    - a new **aura colour tier** (white → gold → crimson → violet → void…) that is visible on every form;
    - +1 spirit slot (Ascensions 1-3);
    - an Ascension badge on your nameplate.
  - **Ceremony:** your aura implodes and re-ignites in the new colour; announced to the server.
  - **Replay speed** (model): zones 1-4 take 29 min at Ascension 1, 20 at A2, 15 at A3, 11 at A5. The replay keeps getting faster, which feels powerful.

### 2.6 Aura styles (the cosmetic RNG layer)

- **WHY:**
  - Styles are the paid-crate engine and the show-off layer: same power, different LOOK (fire, ice, lightning, void, galaxy, sakura, glitch…).
  - Styles stay cosmetic, plus a small index bonus, so whales look amazing without breaking the game.
- **HOW:**
  - Rolled from **aura crates**:
    - earned crates come from boss first-clears, daily streaks and playtime chests;
    - paid crates cost Robux.
  - **Rarity tiers** add VFX layers: a common style recolours your aura; a Mythic one adds unique particle shapes, sounds and a custom transformation burst.
  - **The style index:** collecting styles grants small permanent bonuses (+1% power per 5 styles). WHY: collectors keep rolling.

### 2.7 Retention hooks

| Hook | WHY | HOW |
|---|---|---|
| **Spirit incubator** | a reason to come back tomorrow | place one egg; it hatches in 8 h with ×2 luck; notifications on return |
| **Daily streak** | habit | day 1-7 rewards: coins, crates, a boost; day 7 = an earned aura crate |
| **Daily boss rematches** | play time with a purpose | each beaten boss pays coins once per day |
| **Weekly limited aura** | urgency + show-off | a real limited style: a stock count or a hard end date, shown in the shop and on owners |
| **Playtime chests** | longer sessions | a chest every 10 min online (stacking up to 1 h) |
| **New zone every ~2 weeks** | content runway | zones 9+ after launch; ~5-8 h first-run content at launch |

### 2.8 Social / show-off

- **WHY:** players pay to be SEEN. Every system feeds visibility.
- **HOW:**
  - **Hub leaderboard:** the top 3 players appear as giant statues with their live aura and style.
  - **Server announcements:** forms 6+, Mythic / Secret spirits, Mythic styles, Ascensions.
  - **Inspect:** tap any player to see their form, spirits and style. That makes people want them.
  - **Friendly clash (update 1):** challenge another player to a beam clash in the hub arena (no stakes). Huge video / YouTuber potential.

---

## 2b. Concept test (Winter's honest answers)

| Question | Answer | Confidence |
|---|---|---|
| 10-second hook | Your aura ignites on the first held charge, and a PERFECT release booms | high, once tuned |
| One picture | A tiny-aura player next to a giant galaxy-aura player | high |
| 50th time | Perfect-combo skill + a transformation every few minutes early + visible aura growth | **must prove in greybox** |
| Feeling | Power fantasy, anticipation (charging), pride (transforming), greed (crates), rivalry (clashes) | high |
| Want | The next form (the bar shows a silhouette of it), the next zone's boss, a rarer spirit | high |
| Spend | Look insane faster: crates, 2× Power, Auto-Train, limiteds | high |
| Show-off | Aura size + style + form announcements + statues | high |
| Return | Incubator, streak, daily rematches, weekly limited | medium-high |
| Beats top 3 | Spectacle + skill in the loop + clashes + pacing | medium: depends on execution quality |
| Simple | "Charge your aura, beat bosses, get the biggest aura" | high |
| Fun in grey boxes? | Unknown until playtest #1. **This is the gate** | — |

---

## 3. Paper playthrough

| Time | Sees | Does | Gets | Feels |
|---|---|---|---|---|
| 0:00 | a spark aura, a glowing training stone, a pulsing "HOLD" hand icon | holds, releases | the first PERFECT: a boom | "whoa" |
| 0:30 | the aura flickers bigger; the next-form silhouette fills | charges a few times | **FLAME** transformation (2 s cinematic) | power |
| 1:00 | a coin egg near the stone, the price filled | hatches | the first spirit orbits inside the aura | "mine" |
| 2:00 | a second spirit; the aura is tinted by the spirits | hatches, equips | ×1.5 training | faster |
| 3:00 | the starter pack (after the tutorial) | buys or closes | 3 spirits + a crate + 2× for 15 min | — |
| 4:00 | the boss gate glows green | enters the clash | beam struggle → wins | hype |
| 5-13 | zone 2 (new look, new eggs, BLAZE form) | trains, hatches, fuses the first Gold | progress every 1-2 min | flow |
| ~13 | zone 2 boss: loses narrowly | — | "Need 15% more POWER" + a 2× offer | want |
| 28-50 | zones 3-4, forms up to STORM, the first Mythic chance | — | a server announcement for someone else's Mythic | envy |
| ~50 | **Ascension** unlocked | ascends | ceremony, gold aura, ×1.75 | prestige |
| 1 h+ | a faster replay; the incubator placed before leaving | — | — | "come back" |
| Day 2 | the incubator is hatched, the streak is on day 2, the daily boss pays | — | — | reward on return |
| Day 7 | Ascension 3-5, zone 6+, a style collection going | aims for a weekly limited | — | invested |

---

## 4. Progression numbers (model v0)

First run, free player (3 taps/s, ×1.25 skill):

| Zone | Theme | Power/s | Minutes in zone | Boss gate (power) | Cumulative |
|---|---|---|---|---|---|
| 1 | Training Grounds | 6 | 4 | 1.35K | 4 min |
| 2 | Lava Dojo | 68 | 9 | 36K | 13 |
| 3 | Frozen Peak | 810 | 15 | 729K | 28 |
| 4 | Storm Temple | 9.7K | 22 | 12.8M | 50 (Ascension unlocks) |
| 5 | Sakura Spirit Realm | 121K | 35 | 255M | 85 |
| 6 | Neon City | 1.46M | 50 | 4.4B | 135 |
| 7 | Void Rift | 17.5M | 75 | 79B | 210 |
| 8 | Galaxy Throne | 210M | 110 | 1.39T | 320 (~5.3 h) |

- With 2× Power: about 2.7 h. Ascensions shorten replays (×1.75 → ×4.75 by A5).
- **Early unlock cadence:** something new (a form, a zone, a spirit) every 1-3 minutes in the first 15 minutes, every 5-10 minutes after. This meets the playbook's targets.

---

## 5. Monetization plan

| Item | Type | R$ | What it gives | WHY they want it |
|---|---|---|---|---|
| Starter Pack | product (once) | 49 | 3 Epic spirits + 1 aura crate + 2× Power 15 min | cheap first purchase at 3 min = a payer for life |
| 2× Power | pass | 299 | permanent ×2 training | the biggest progress boost |
| Auto-Train | pass | 249 | trains while AFK | idle play, overnight farming |
| +2 Spirit Slots | pass | 199 | 2 more equipped spirits | direct power + more aura colour |
| Lucky Hatch | pass | 249 | ×2 rare odds on eggs | collectors |
| Fast Hatch + Triple Hatch | pass | 149 | hatch 3 at once, skip the animation | grinders |
| VIP | pass | 399 | VIP aura trail, chat tag, +10% coins, a VIP lounge on the hub | status |
| Aura Crate | product | 49 / 10-pack 399 | random aura style (odds below) | the main RNG revenue |
| Premium spirit egg (per zone) | product | 29-99 | Robux egg with better odds + exclusive spirits | collection + power |
| Weekly Limited Aura | product | 499-999 | a real limited style (stock count or end date) | urgency + show-off |
| Power Boost 30 min | product | 25 | ×2 for 30 min (stacks with the pass) | an impulse buy after a lost clash |
| Coin packs | product | 25 / 99 / 249 | coins scaled to the current zone | can't afford the next egg |
| Incubator skip | product | 19 | hatch the incubator now | impatience |

### Aura crate odds (shown in the crate UI)

| Rarity | Odds |
|---|---|
| Common | 60% |
| Rare | 28% |
| Epic | 9% |
| Legendary | 2.5% |
| Mythic | 0.5% |

**Pity:** Legendary+ guaranteed by 50 opens; Mythic by 300.

| Crate | Mean opens | Mean cost | Opens until pity |
|---|---|---|---|
| Legendary+ | 26 | ≈1,040 R$ | 22% of players reach it |
| Mythic | 156 | ≈6,200 R$ | 22% of players reach it |

**Policy (required):**
- odds shown in the crate UI before purchase;
- `PolicyService` restricted regions get direct-buy styles instead.

### Pop-up offers (at moments of want; at most 1 per 3 min, never chained, always closable)

| Trigger | Offer |
|---|---|
| Lost a clash by <25% | 2× Power boost (25) |
| Can't afford the zone egg | coin pack |
| Crate near-miss (Epic when Legendary was 1 step away on the reveal) | 10-pack |
| After Ascension | VIP / Lucky Hatch |
| Someone in the server pulls a Mythic | the crate shop opens one tap away (the toast is a button) |

### Free-player check

A free player reaches zone 8 in about 5.3 h of play (multi-session) and ascends normally. Payers get there faster and look rarer: a full server of free players is the audience payers show off to.

---

## 6. Economy outliers (model)

- **Dry streaks:** pity caps the worst case; no one opens more than 50 crates without a Legendary+.
- **Spirit luck:** coin eggs use the same pity idea (a Legendary by 200 hatches per zone egg).
- **Multiplier stacking:** total = zone × spirits × Ascension × passes × boost. Boosts multiply only once (passes ×2 and boost ×2 = ×4 max, never ×8). Checked in the model before each update.
- **Inflation:** coins reset on Ascension, so no stockpiling.

---

## 7. World and screens

- **Hub:** spawn, the leaderboard statues, the crate shop (a big glowing shrine), the incubator, the friendly-clash arena (update 1).
- **Zones:**
  - one themed island each: a training area with 3 stone tiers, egg stands and a boss arena;
  - walking time from spawn to the boss gate is under 15 s;
  - teleport pads between unlocked zones.
- **HUD (max 5 buttons):** Spirits, Crates, Shop, Teleport, Ascend (it appears when available).
  - A Power counter under the player name.
  - A next-form silhouette bar.
  - A coins counter.
- **No text tutorial:** a pulsing hand on "hold", a glowing path to eggs, the boss gate glowing when ready.

---

## 8. Build plan

- **Size:** L.
- **Crew:**
  - operator + 2 lanes (art / VFX lane; systems lane);
  - VFX is the hero lane, so it gets the most time.
- **Reuse:**
  - the Stud Pets system → spirits (hatch sequence, followers, inventory, save, fuse);
  - the library backbone (data, remotes, security, UI kit).
- **Style:** stylised anime simulator (STYLE-SHEET to write: chunky cel-shaded characters-and-world, glowing additive VFX, bold UI).
- **Phases:**
  1. **Greybox (1-3 h):**
     - charge-release + perfect combo;
     - aura scaling with 3 placeholder forms;
     - one coin egg + 3 spirits;
     - one boss clash;
     - **fun gate + owner playtest #1.**
  2. **Zone 1-2 vertical slice:**
     - real VFX forms 1-5;
     - real spirits;
     - two bosses;
     - the HUD;
     - the starter pack;
     - **playtest #2.**
  3. **Zones 3-4, Ascension, crates + odds UI, incubator, streak.** Then **playtest #3.**
  4. **Zones 5-8, forms 6-10 (level-5 VFX), all passes / products, limiteds, polish, live gate.** Then **playtest #4.**
- **Risks + feasibility:**
  - **Hero VFX for 10 forms × style variants:** build forms as layered presets so styles recolour / reshape the layers (no 10×N hand-builds). Concept frames are made on the GPU first.
  - **Clash fun:** the greybox decides.
  - **Trend fatigue on "aura":** the clash + spectacle angle gives the TikTok hook.

## 9. Winter's honest opinion

- **Strong:**
  - a visible, show-off-driven progression;
  - a skill moment in both the core action and the gate;
  - every money mechanic hooked to a real moment of want;
  - reuses our pet system and our VFX focus.
- **Weak / risky:**
  - the genre is crowded;
  - success depends on VFX quality and a fun charge-release.

  If either feels flat in the greybox, we change it before spending art time.
- **What I'd still decide with you:**
  1. The style direction (anime cel-shaded vs a chunkier simulator look).
  2. Whether friendly clashes (PvP-lite) ship at launch or in update 1.
  3. The final name. "Aura Clash" fits the clashes; an alternative is "Aura Clash!" with the boss as the thumbnail star.
