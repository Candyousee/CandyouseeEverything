# AURA CLASH: Game Plan v3 (streamlined; 2 October 2026; for owner approval)

v1 and v2 are in archive/. This replaces both.

- **Pacing numbers:** `econ/model.py`.
- **Boss fight numbers:** `econ/clash_sim.py`.

---

## 1. WHAT THIS GAME IS (one identity)

**Aura Clash is a pet training SIMULATOR.** Not a fighting game.

- The fighting (the boss clash) is only the **gate at the end of each zone**: a 20-40 second moment that proves you got stronger.
- **Player-vs-player is cut from launch.** It's a possible update later, only if the numbers say players want it.

**One sentence:** *Train your power, hatch spirits, and grow the biggest aura in the server.*

### Why it felt weird before, and the fix

- **The problem:** v2 had two separate collections fighting for attention: spirits (pets) AND aura styles (crates). That left two RNG systems, two inventories, and no clear answer to "what am I collecting?"
- **The fix: one collection.** **Spirits ARE your aura.** Your aura's size comes from your power. Its colour, element and effects come from the spirits you equip:
  - equip fire spirits → a fire aura;
  - equip a Mythic void dragon → a void aura with dragon wisps.

So the pets and the aura are the same thing seen two ways. Collect better spirits, and your aura visibly becomes rarer.

### The whole game is 4 systems

| # | System | What it does |
|---|---|---|
| 1 | **TRAIN** | charge and release to gain power |
| 2 | **SPIRITS** | hatch, equip, fuse → multiply power + change your aura's look |
| 3 | **ZONES** | 8 zones, each ending in a boss clash gate |
| 4 | **ASCEND** | rebirth: reset for a permanent multiplier + a new aura colour |

Nothing else at launch. Everything else (daily systems, the pass, the shop) is a **reason to do these 4**, not a fifth system.

---

## 2. THE EXACT CORE LOOP

```
TRAIN (gain power + coins) → HATCH SPIRITS with coins → equip → train faster
   → hit the boss's power → CLASH → next zone (better stones, better eggs) → repeat
   → after zone 4: ASCEND → faster replay, new aura colour, push further
```

### 2.1 Train: the action (what your hands do)

- Stand on the zone's **Training Stone**.
- **Hold** your one button: a ring shrinks toward you over 1.2 s, and your aura swells.
- **Release** inside the glow (a 0.18 s window) for a **PERFECT**: ×2 power and a BOOM.
- **Chain PERFECTs** for a combo: ×1.25 → ×1.5 → ×1.75 → ×2. It's shown as flames on your fists.
- **Other releases:**

| Release | Power |
|---|---|
| Early | ×0.6 |
| Overcharge | ×0.5 + a short stagger |
| Quick tap | ×0.3 (auto-clickers gain nothing) |

- **Every release earns power + coins** (coins = power ÷ 10).
- **Each zone has ONE stone** (simpler than v2's three), and it **levels up** as you buy upgrades with coins:

| Stone level | Cost (coins) | Training power |
|---|---|---|
| Lv 1 | free | ×1 |
| Lv 2 | 25% of the zone gate | ×2 |
| Lv 3 | 60% of the zone gate | ×4 |

**WHY:** a tiny goal in the middle of every zone, and a second thing to spend coins on, so coins always have a use.

### 2.2 Spirits: the collection that is also your aura

- **Eggs:** every zone has a **Coin Egg** and a **Robux Egg** (section 5).
- **Hatching:**
  - the egg drops in front of you and wobbles 3 times;
  - the cracks glow in the rarity's colour: blue = Rare, purple = Epic, gold = Legendary, rainbow = Mythic;
  - it bursts and the spirit appears;
  - you can skip by clicking.
- **Each spirit has:** a rarity, a **power bonus** (e.g. +40%), and an **element** (Fire, Frost, Storm, Nature, Void, Light, Cosmic).
- **Equip slots:** 3 to start; +1 at zones 2, 4 and 6; +1 per Ascension (up to 3); the pass adds +3 (max 12).
- **Power multiplier** = 1 + the sum of equipped bonuses.
- **"Equip Best"** is one button. No traits at launch (v2 had them; cut for simplicity).
- **How spirits make your aura:**
  - equipped spirits **orbit inside your aura** on 3 tilted rings that spin at different speeds;
  - the rings scale with the aura's size;
  - on every release, each spirit **fires a streak of energy into you**, so the power boost is visible.
  - **Aura element** = the element of your highest-rarity equipped spirit (Fire → flames, Frost → snow and ice crystals, Void → dark tendrils…).
  - **Aura effects tier** = that spirit's rarity: Common = a plain glow; Mythic = full hero VFX with a unique burst.
  - **Huge spirits** (section 5) add a signature effect on top (e.g. wings, a halo, a meteor shower).
- **Fusion:**
  - 5 of the same spirit → **Gold** (×1.5 bonus);
  - 5 Gold → **Rainbow** (×2.5).

  Duplicates are never wasted.
- **Shiny:** 1 in 100 on any hatch (sparkles, ×1.2).

### 2.3 Aura size and forms (visual milestones, not a separate system)

- **Size:** `radius = 3 + 4.2 × log10(1 + power/100)`. About +4 studs per zone, so you can see yourself grow.
- **10 forms**, reached by power: Spark → Flame → Blaze → Surge → Storm → Tempest → Nova → Eclipse → Titan → Ascended. Each one is:
  - a **2-second transformation moment** (a camera push, an implode and explode, the name slam);
  - **+5% power**;
  - one more VFX layer.
- Forms 6+ are announced to the server.

### 2.4 Zones and the boss clash (the gate)

- **Each zone:** one island with the stone, 2 egg stands, and the boss gate at the end.
- **The boss gate** shows one number: the boss's power. It glows **gold when you're at 1.1×** (ready).
- **The clash (20-40 s, solo):**
  - your beam and the boss's beam meet in the middle;
  - your power pushes the beam (the drift);
  - **PERFECT releases shove it harder**;
  - every 5 s the boss **glows red** (a 1 s warning): release a PERFECT right then to **counter** (+3%), or take the hit (−5%);
  - push the beam all the way to the boss to win.
- **Fairness (2,000 simulated fights each):**

| Player | Wins most fights at |
|---|---|
| Skilled | 0.8× the boss's power |
| Average | 1.1× (when the gate turns gold): 83% wins |
| Weak | 1.5× |

  Nobody gets stuck.
- **Win:**
  - the boss shatters, coins explode;
  - you get a **first-clear chest**: the next zone's first egg free + coins;
  - the next zone opens.
- **Lose:** "Need ~15% more power" or "Counter the red!" + a 2× Power offer; retry in one tap.

### 2.5 Ascend (rebirth)

- **Unlocks** after the zone 4 boss (about 34 minutes for a free player).
- **Resets:** power, forms, coins, zones.
- **Keeps:** spirits, passes, index, trades.
- **Gives:**
  - ×(1 + 0.75 × Ascensions) power;
  - the next **aura colour tier**, applied on top of your element (white → gold → crimson → violet → void → prismatic);
  - +1 slot (A1-A3).
- **Ceremony:** you rise, your aura collapses into a point and bursts out in the new colour. Announced to the server.
- **Replays get faster:** zones 1-4 take ~19 min after A1, ~14 after A2, ~10 after A3.

---

## 3. EXACT PROGRESSION: the first hour, minute by minute (free player)

Something new happens **at least every 2 minutes** in the first 30.

| Time | Unlock / event | What the player wants next (shown on screen) |
|---|---|---|
| 0:00 | spawn on the zone 1 stone; a pulsing "HOLD" hand | the first PERFECT |
| 0:10 | the first PERFECT: BOOM | a combo |
| 0:30 | **Form 2: FLAME** transformation | the egg (its price is filling) |
| 1:00 | first Coin Egg hatch → a spirit orbits you | a second spirit |
| 1:45 | 3 spirits equipped; the aura is tinted by the element | stone Lv 2 |
| 2:15 | **Stone Lv 2** (×2) | the boss gate turning gold |
| 3:00 | **Zone 1 boss clash** → win → Zone 2 + a free egg | the starter pack appears (once, closable) |
| 3:30 | **Form 3: BLAZE** | the zone 2 egg (better spirits) |
| 5:00 | first Rare+ spirit → the aura element changes (a visible upgrade) | the 4th slot |
| 6:00 | **4th slot** (zone 2 unlock reward) | stone Lv 2-3 |
| 7:30 | first **fusion** (5 commons → Gold) | the zone 2 boss |
| 9:00 | **Zone 2 boss** → Zone 3 | Form 4 |
| 11:00 | **Form 4: SURGE** | the daily streak claim (if returning) |
| 14:00 | first Epic chance in zone 3 eggs; playtime chest #1 | — |
| 19:00 | **Zone 3 boss** → Zone 4 | the 5th slot |
| 20:00 | **5th slot**; **Form 5: STORM** | the zone 4 boss |
| 27:00 | first Legendary chance (zone 4 Coin Egg 0.5%) | — |
| 34:00 | **Zone 4 boss** → **ASCEND unlocked**, with a preview of the gold aura | Ascend |
| 35:00 | **Ascension 1:** gold aura, ×1.75, a slot. Trading unlocks | replay faster |
| 35-54 | zones 1-4 again in ~19 min, now with a gold aura and better spirits | Zone 5 |
| 54:00 | **Zone 5 (new)** | Form 6 + the server announcement |
| 60:00 | the incubator (put an egg in before leaving) | come back tomorrow |

**Full first run** (zones 1-8): about 4 h 10 min for a free player, about 2 h with 2× Power. Ascensions make every replay faster.

---

## 4. RETURN HOOKS (all feed the 4 systems)

| Hook | How | Feeds |
|---|---|---|
| **Incubator** | 1 egg hatches in 8 h with ×2 luck | spirits |
| **Daily streak** | days 1-7 → coins, a luck potion; day 7 = a free Robux-Egg hatch | spirits |
| **Daily boss rematch** | each beaten boss pays coins once a day; 1% chance of that boss's **Boss Spirit** (Mythic, unique) | spirits + zones |
| **Playtime chests** | every 10 min online (up to 6) | coins / potions |
| **Aura Pass quests** | 3 daily + 5 weekly quests ("Land 200 PERFECTS", "Hatch 50 eggs", "Beat 3 bosses") → pass XP | all |
| **Weekly limited spirit** | a real stock count (e.g. 10,000) or a 7-day end date | spirits + trading |

---

## 5. MONETIZATION (rebuilt; money is the top priority)

### 5.0 The holes in v2 (fixed here)

| # | The hole | Why it lost money | The fix |
|---|---|---|---|
| 1 | **No season pass** | the #1 recurring earner in modern Roblox sims, and it monetizes daily play | **Aura Pass** (5.3) |
| 2 | **No server boosts** | the best social purchase: one buyer, a whole server sees their name, others copy | **Server Luck / Power boosts** (5.4) |
| 3 | **Robux eggs were an afterthought (29-99 R$, no exclusives)** | paid eggs are THE pet-sim money engine | **Robux Eggs with exclusives + Huge spirits** (5.2) |
| 4 | **Cosmetic-only aura crates** | cosmetics with no power sell far worse in sims | removed; the look comes from spirits, which carry power |
| 5 | **No trading** | limiteds and Huges are only worth something if they can be traded; trading drives egg spending | **Trading** at Ascension 1 (5.6) |
| 6 | **Only one starter offer** | the first purchase is the hardest; the second sells easily | **an offer ladder + daily deals** (5.5) |
| 7 | **The Auto-Train pass was weak (×0.6)** | a weak pass means low conversion | Auto-Train at ×0.8 (in-game AFK) |

### 5.1 Game passes (one-time)

| Pass | R$ | What it gives | Why they buy |
|---|---|---|---|
| **2× Power** | 299 | permanent ×2 training | the biggest speed-up |
| **Auto-Train** | 349 | trains automatically at ×0.8 while you're AFK (in-game) | idle farming |
| **+3 Spirit Slots** | 399 | 3 more equipped spirits (more power + a richer aura) | direct power + looks |
| **Lucky** | 299 | ×1.5 rare odds on every egg | collectors |
| **Triple Hatch** | 199 | hatch 3 at once | speed |
| **Fast Hatch** | 99 | skip the animation | grinders |
| **VIP** | 499 | VIP aura trim, chat tag, +15% coins, the VIP stone (×1.25) in every zone | status |
| **+500 Inventory** | 99 | more storage | collectors |

### 5.2 Robux Eggs (the main RNG revenue)

- **Every zone has a Robux Egg:** 1 hatch = 79 R$, 3 hatches = 199 R$, 10 hatches = 599 R$.
- **It contains:**
  - **exclusive spirits** that never appear in Coin Eggs (better power than that zone's coin spirits);
  - a **Huge spirit** chance.

**Robux Egg odds (shown on the egg's card before purchase):**

| Rarity | Odds |
|---|---|
| Epic | 70% |
| Legendary | 25% |
| Mythic | 4.75% |
| **Huge** | 0.25% (1 in 400) |

- **Huge spirits:**
  - the spirit is 3× size and orbits outside your aura;
  - a signature aura effect;
  - announced to the server;
  - tradeable.
- **Pity:** a Huge is guaranteed by **600 hatches**. Mean opens until a Huge: 311 (model). 22% of players reach pity.
- **Policy:** in regions where `PolicyService` restricts paid random items, players see a **direct-buy Exclusive Spirit** (fixed, non-random) instead.

### 5.3 Aura Pass (season pass, every 30 days)

- **50 tiers**, earned with pass XP from quests and from playing.
- **Free track:** coins, potions, 1 Rare spirit.
- **Premium track (499 R$):** an exclusive Mythic spirit at tier 1, potions, Robux-Egg hatches, a **Huge at tier 50**, an exclusive aura trim.
- **Premium+ (1,299 R$):** premium + skip 15 tiers + a bonus exclusive spirit.
- **WHY:** recurring monthly revenue that also drives daily play (quests).

### 5.4 Boosts (products)

| Boost | R$ | Effect |
|---|---|---|
| **Server Luck ×2** | 149 | **the whole server** gets ×2 egg luck for 15 min. A banner shows: "★ Nik boosted the server! ★" |
| **Server Power ×2** | 149 | the whole server trains ×2 for 15 min, with a banner |
| Personal 2× Power | 39 (30 min) | stacks with the pass |
| Personal Luck Potion | 29 (15 min) | ×1.5 luck |

- **Server boosts stack in duration** (two buys = 30 min).
- **WHY:**
  - the buyer gets fame;
  - everyone else gets free value, so the server stays full and active;
  - others copy the purchase to get the banner;
  - and it creates hatch frenzies where people buy Robux Eggs during the boosted luck.

### 5.5 The offer ladder + daily deals

- **Starter Pack (49 R$, once):** offered at 3:00 after the zone 1 boss. An Epic exclusive spirit + 3 Robux-Egg hatches + 2× Power 30 min.
- **Second offer (149 R$, once):** shown 24 h after the first purchase, or at Ascension 1. A Legendary exclusive + Triple Hatch for 24 h.
- **Big Bundle (499 R$, once):** shown at zone 5. A Mythic exclusive + 10 Robux-Egg hatches + a 2× Power pass discount.
- **Daily Deals:** 3 rotating offers in the shop, refreshing every 24 h with a real timer (e.g. "Robux Egg 10-pack −20%", "Legendary spirit 199").

### 5.6 Trading

- **Unlocks** at Ascension 1, to stop alt-account abuse and scams on new accounts.
- **How it works:** a trade window with both sides' spirits, a 3-second confirm countdown, then server-side validation.
- **Untradeable:** passes and boosts.
- **WHY:** Huge and limited spirits get real value, which makes players hatch more.

### 5.7 Weekly limited spirit

- One new limited spirit a week in the shop (299-799 R$).
- A **real stock count**, live in the shop (e.g. "4,212 / 10,000 left"), or a real 7-day end date.
- It's tradeable, so its value rises after it sells out. That drives the next week's sales.

### 5.8 Pop-up offers (at moments of want; at most 1 every 3 min, never chained, always closable)

| Moment | Offer |
|---|---|
| Lost a boss clash by <25% | 2× Power 30 min (39) |
| Robux Egg reveal: the cracks glowed gold but landed Epic ("so close") | the 3-pack (199) |
| Someone else hatched a Huge (server announcement) | a toast with "Hatch Robux Egg" |
| A server boost runs out | "Extend the boost? 149" for the whole server |
| Just ascended | VIP or +3 Slots |
| Inventory full | +500 Inventory (99) |

### 5.9 Free-player check

- A free player finishes the first run in about 4 h, ascends, hatches coin-egg spirits and fuses them.
- They get Boss Spirits from daily rematches and free Robux-Egg hatches from the streak and the pass free track.
- They can trade their way up after Ascension 1.

So servers stay full, and payers have an audience.

---

## 6. CONCEPT TEST (honest)

| Question | Answer | Confidence |
|---|---|---|
| What is it? | A pet training simulator. One identity | high |
| 10-second hook | Hold → ring → PERFECT → BOOM, your aura flares | must prove in greybox |
| One picture | A tiny-aura player next to a giant void-dragon aura with a Huge orbiting | high |
| 50th time | Combo rhythm + a new unlock every ≤2 min early + visible aura growth | must prove in greybox |
| Spend | Robux Eggs (Huges), the pass, server boosts, 2× / Auto / Slots, limiteds | high |
| Show-off | Aura size + element + Huge + Ascension colour + announcements | high |
| Return | Incubator, streak, rematches, pass quests, weekly limited | high |
| Simple | "Train, hatch, grow the biggest aura" | high |
| Fun in grey boxes? | Unknown until playtest #1. This is the gate | — |

---

## 7. BUILD ORDER

1. **Greybox (1-3 h):**
   - the stone + charge-release + combo;
   - one coin egg with 5 placeholder spirits orbiting;
   - aura size growth;
   - one boss clash;
   - zone 2 unlock.

   Then the **fun gate + owner playtest #1.**
2. **Vertical slice:**
   - zones 1-2 with real art and VFX (forms 1-4, 3 elements);
   - Robux Egg + Huge (with the odds UI and pity);
   - the starter pack;
   - the HUD.

   Then **playtest #2.**
3. **Zones 3-4 + Ascension + trading + the incubator + the streak + server boosts.** Then **playtest #3.**
4. **Zones 5-8 + forms 5-10 + the Aura Pass + daily deals + the weekly limited + all passes + the live gate.** Then **playtest #4.**

**Everything gameplay-facing is built from scratch.**

## 8. Decisions for the owner

1. Approve the identity: **a pet training simulator; fighting is only the boss gate; no PvP at launch.**
2. **Style direction:** anime cel-shaded (sharper, "anime fighter" appeal), or chunky simulator (rounder, like top pet sims)?
3. **Name:** "Aura Clash" still fits (the boss clashes). The alternative is a pet-forward name, e.g. "Spirit Aura Simulator".
