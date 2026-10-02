# AURA CLASH: Core Game v5.1 (everything around the core loop)

**Doc map (what wins on a conflict):**
1. **`CORE-LOOP.md`:** the core rules and numbers (meditation, hunting, mutations, bag / SELL, pets, Soul Food, shop, quests, bosses, first 8 minutes). Backed by `econ/model.py` + `econ/tests.py`.
2. **This file:** eggs and hatches in detail, the pet catalogue, the aura, the HUD, the tutorial, server authority, **saving (acceptance tests)**, **playtest #1 (acceptance criteria)**, the quality bar, and what comes later.
3. **`STYLE-SHEET.md`:** the look (glossy toon anime).
4. **`GAME-PLAN.md`:** the market case and the build order. **`HANDOFF-WINTER.md`:** Winter's start sheet.

Old versions (v2.3 stone training, v4 crystal smashing) are in `archive/`, for history only. **Nothing in `archive/` is a rule.**

---

## 1. What the game is

*"Meditate to grow your aura, hunt crystal monsters with your pets, and become the strongest in the server."*

A **pet simulator with two halves:**
- **meditation** (calm, AFK-friendly) grows **Power**;
- **hunting** (active, skill-based hold-release blasts) earns **coins** that buy **pets**;
- pets make both halves faster.

**Who:** 8-14-year-olds who play simulators and anime games.

**Monetization:** designed by the owner after playtest #1. The core has no dependency on it.

## 2. Zones

| # | Zone | Element | Status |
|---|---|---|---|
| 1 | **Training Grove** | Light | two-zone test |
| 2 | **Lava Dojo** | Fire | two-zone test |
| 3-8 | (e.g. Frost Peaks, Storm Cliffs, Sakura Realm, Void Rift, Galaxy Throne, Celestial Gate) | one element each | later, after playtest #1 |

**Each zone has:**
- a Shrine hub (mats, Sell Altar, egg stand, shop, Fusion Altar);
- 3 monster types with that zone's mutations;
- its own egg (8 species), Soul Food and boss;
- 5-6 rank quests;
- a portal to the next zone that opens when its boss is beaten.

**Scaling per zone:** monster HP and shard values ×10, the Shrine ×4, zone pets ×2 Strength (zones 3-8 will be tuned in the model before they're built).

## 3. Eggs, hatches and the pet catalogue

### 3.1 Species (8 per zone)

| Rarity | Zone 1: Light | Zone 2: Fire |
|---|---|---|
| Common | **Light Fox** (tutorial), Glow Bunny | Ember Imp, Cinder Pup |
| Rare | Prism Owl, Sun Pup | Magma Toad, Blaze Ferret |
| Epic | Halo Lynx | Lava Salamander |
| Legendary | Dawn Griffin | Inferno Wolf |
| Mythic | Solar Kirin | Phoenix |
| Secret | ??? | ??? |

- Each species has **one signature attack** (the fox dash, the imp fireball, the griffin dive…) and **2-3 idle animations**.
- Rarer pets are bigger, with bigger effects.

### 3.2 The odds card and the honest-crack rule

- **The egg card shows all odds:** Common 60% / Rare 28% / Epic 10% / Legendary 1.9% / Mythic 0.1% / **??? 1 in 500,000**.
- **Secrets:** the *chance* is always shown; only the *identity* is hidden. After someone hatches it, the card shows its silhouette and "First hatched by ___".
- **The crack colour always equals the true rarity.** There are no fake near-misses anywhere.
- **Guarantees** (saved, so rejoining can't repeat or skip them):
  - the 1st hatch ever is the Light Fox;
  - the 3rd hatch is a Rare if you have none;
  - each boss's first clear gives one free egg of the next zone.

### 3.3 The hatch ladder

| Result | Hatch |
|---|---|
| Common (1.5 s) | the egg pops, a puff, the pet hops out |
| Rare (2 s) | blue cracks, a glow burst, a happy jingle |
| Epic (3 s) | purple cracks, the egg levitates, lightning, a thunder clap |
| Legendary (4 s) | gold cracks; **the sky dims around you**; a gold pillar; a slow-motion shatter; **a server announcement** |
| **Mythic: CUTSCENE** (6 s; unskippable the first time) | the world freezes, the camera orbits, the egg rises into a vortex of the zone's element, **the pet forms from raw energy**, a shockwave across the zone, a server announcement with your name |
| **Secret: CUTSCENE** (8-10 s; unskippable the first time) | the screen cracks, the music cuts to silence, a "???" title card, **the whole server's sky changes for 10 s**, a unique entrance, **a global announcement in every server**, a permanent "Secret Holder" title |

- **Multi-hatch** (Hatch 3, unlocks after boss 1): plays the best result's hatch.
- **Skip:** after you've seen a rarity's hatch once, a skip button appears for it.

### 3.4 Inventory

- **Capacity:** 250 pets.
- **Locks:** favourite (lock) a pet so it's never auto-fused.
- **Auto-fuse:** Commons + Rares, unequipped only (CORE-LOOP 3a).
- **When full:** new hatches go to a **mailbox** (claim later); they're never deleted.

## 4. Your aura

- **Size grows with Power:** **2.5 + 0.5 × log10(Power) studs** of radius.

| Power | Radius |
|---|---|
| 10 | 3.0 |
| 300 | 3.7 |
| 10,000 | 4.5 |
| 1,000,000 | 5.5 |

  Meditation makes it pulse and swell; a Power milestone (×10) gives a burst.
- **Forms** (from bosses; each changes the shape, colour and flame style):

| Form | From | Look |
|---|---|---|
| **Spark** | start | white-gold light flickers, soft |
| **BLAZE** | Stone Golem | orange anime flames, rising embers |
| **INFERNO** | Magma Oni | red-black flames, a heat haze, a flame crown |
| zones 3-8 | later bosses | one per element |

- **Transformation:** a short cutscene (2.5 s), a shockwave and a "BLAZE!" title.
- **No Bond:** the aura shows your form only. (Aura cosmetics are a possible owner monetization item.)

## 5. HUD (mobile first; see the GUI guide)

**Always on screen:**
- **Power** (big, top centre);
- **coins**;
- the **storm counter** (18 / 60) by your character;
- **SELL** (bottom right, bounces when full);
- the **blast button** (mobile);
- the **quest tracker** (one line + a progress bar);
- a **pet bar** (equipped pets, Feed badge).

**Context:**
- the **Focus ring** while meditating;
- monster HP bars (green when easy);
- the mutation name over mutated monsters;
- the "WHILE YOU WERE AWAY" card.

**Menus:**
- Pets (Equip Best, Feed All, auto toggles, fuse);
- Shop;
- Egg card;
- Settings:
  - Low effects;
  - others' effects;
  - camera shake;
  - reduced flashing;
  - show others' pets.

## 6. Tutorial (the first 8 minutes; CORE-LOOP 7)

- **A pulsing hand** points at the one next thing: MEDITATE → a Shardling → SELL → the egg → Feed → the quest tracker.
- **No text walls:** labels of 1-3 words.
- **Steps are saved** (14.1), so a rejoin resumes the tutorial instead of repeating it.
- **The tutorial meditation** is a fixed +40 Power over 20 s, so the first moment is the aura bursting, not waiting.

## 7. Server authority and anti-cheat

- **The server owns:** Power, coins, bag contents, food, pets, quest progress and every reward. The client only sends inputs.
- **Blasts:**
  - the client reports hold start / release;
  - the server checks the hold length (at least 0.5 s), a blast rate of at most one per 1.4 s (plus a small buffer), the range to the target, and that the target exists;
  - PERFECT is judged on the client (so lag doesn't ruin it), within a server-checked plausible window;
  - an impossible streak rate gets flagged.
- **Meditation:**
  - the server checks you're on a mat;
  - Focus taps are limited to one per breath;
  - Focus can't exceed ×3;
  - offline gains use server timestamps only.
- **Loot:** the server rolls mutations, drops and eggs. Shared monsters use the server's damage log: **every player who damaged a monster gets their own full drop and quest credit** (CORE-LOOP 8).
- **Pets:** each pet has a unique id. Fusion is one server transaction (3 removed + 1 added in the same save).

## 8. Saving (build requirement for the two-zone test)

### 8.1 What's saved (one profile per player, session-locked)

| Saved | Includes |
|---|---|
| Progress | Power, coins, zone access, bosses beaten, form, quest progress per zone |
| Bag + food | shard counts by type and mutation, the food pouch |
| Pets | every pet (id, species, zone, stars, level, XP, favourite), equipped list, auto-fuse / auto-feed settings, mailbox |
| Upgrades | Bag, Mat, Surge levels; pet slots |
| Tutorial / guarantees | tutorial step, **lifetime hatch count**, guaranteed-Rare used, first-clear eggs claimed |
| Offline | `lastSeen` (server time), `offlineClaimId` |
| Settings | effects, camera, flashing, Low effects |

### 8.2 Rules

- **Session lock:** one server at a time per profile, so two servers can never both grant.
- **Ordinary progress** (Power, coins, bag, kills, normal hatches, feeding): queued save + an autosave every 60 s, on leave and on server shutdown (`BindToClose`). **Honest limit:** if a server crashes, up to the last ~60 s of ordinary progress can be lost. That's accepted for ordinary progress; it's why the critical operations below use confirmed saving.
- **Confirmed saving** (write first, show second):
  1. the server writes the change with `UpdateAsync`, together with a unique **operation id**;
  2. **success →** show the reward;
  3. **error or timeout → the result is UNKNOWN, not "nothing granted".** Roblox warns that a failed response can follow a write that actually succeeded. So the server shows "Saving…" and **reconciles**: it reads the profile (inside the next `UpdateAsync`) and checks whether the operation id is already stored:
     - **id found →** the write landed: show the reward, and never apply it again;
     - **id not found →** apply it in that same `UpdateAsync` (so it can't land twice);
  4. up to 3 attempts with backoff;
  5. **if every attempt fails, the operation is cancelled in this session:** the server undoes it in memory (the egg's coins are back, the pets are unfused) and says **"Couldn't save, so nothing happened. Try again."** It never promises the reward is safe, because an operation that exists only in server memory is lost if the server crashes.
     - The one exception is a write that **did** land but reported failure. It's already in the saved profile, so the reconcile check (step 3) finds its operation id on the next access, **including the next join on another server**, and shows it then. It's never applied twice.

  **What this guarantees:** an operation is either saved exactly once, or it never happened. The player never sees a result that isn't saved, so there's nothing to lose and nothing to re-roll. (A crash before any save can't lose a reward the player was shown.)

  **Each critical operation is ONE write that contains everything:** the cost, the result and the operation id together. That way, a failed hatch never keeps the coins without the pet, or the pet without the coins.

  
  Used for:
  - the offline meditation claim;
  - Mythic / Secret hatches: the egg's cost and the result are saved in one write **before** the cutscene plays. If the save fails, the hatch is cancelled and the coins are kept; the result was never shown, so it can't be re-rolled on purpose;
  - fusion of ★★ or Epic+ pets.
- **Offline gain:**
  - computed once per session from `lastSeen` to now (server time, capped at 8 h), in **one write** with a new `offlineClaimId`;
  - if that write fails, the gain isn't shown and `lastSeen` is unchanged, so the same span is offered again later (nothing is lost);
  - a rejoin can't claim the same span twice;
  - the device clock does nothing.
- **AFK rejoin:** the rejoin teleport saves first, then puts you back on a mat (the gain continues).
- **Studio without API access:** play without saving, with a "NOT SAVING" banner. Never stall.
- **Follow Roblox's data store guidance:** https://create.roblox.com/docs/cloud-services/data-stores/best-practices

### 8.3 Tests (all must pass in the real game before playtest #1; none has been run yet)

| # | Test | Pass |
|---|---|---|
| P1 | Play 5 min, leave, rejoin another server | everything in 8.1 identical |
| P2 | Log off 1 h, rejoin twice quickly (two servers) | offline Power granted exactly once |
| P3 | Change the device clock ±1 day | no effect on offline gains |
| P4 | Kill the server during a Mythic hatch (forced shutdown) | after rejoin: the Mythic is there exactly once |
| P5 | Studio mock: (a) the save fails before writing; (b) **the save writes, then reports a timeout**; (c) the data store is down for 2 min | (a) the retry grants once; (b) reconciliation finds the operation id and shows the reward **without granting it again**; (c) after 3 failed attempts the operation is cancelled with "nothing happened, try again": no reward shown, nothing spent |
| P6 | Rejoin before the 3rd hatch and after the tutorial egg | the guarantees happen exactly once, in order |
| P7 | **Odds test:** 200,000 automated server-side hatches | each rarity within ±4 standard deviations (Mythic: 200 expected, accepted 144-256) |
| P8 | Crack colour vs result over the same 200,000 hatches | 100% match |
| P9 | **Mutation test:** 200,000 automated spawns | each mutation within ±4 SD of its chance (CORE-LOOP 2.3) |
| P10 | Fill the bag in Overdrive with mutated shards | never above capacity; every mutated shard sells at its multiplier |
| P11 | A newcomer (10% of the damage) and a veteran (90%) hit one monster | **both** get their own full drop and quest credit |
| P12 | Spam SELL / Feed / Fuse (20 clicks), and two devices at once | exactly one sale, feed and fusion each |
| P13 | A new player does zone 1 quests 2 and 4 in a full server next to veterans who kill everything shared | the quests complete at the solo pace or faster, thanks to the protected pack (CORE-LOOP 8). The model simulates this (`econ/RESULTS.txt` section 7); it must also be run in the game |
| P14 | Studio mock: every save fails, then the server is shut down mid-session after a Mythic hatch attempt | on rejoin there's no Mythic and no coins spent (it was cancelled and never shown); with a write that landed but reported failure, the Mythic and the cost are both there exactly once |

## 9. PLAYTEST #1 (behaviour first)

**Build:**
- zones 1-2, complete per CORE-LOOP;
- the tutorial;
- the cheat panel (set Power / coins / zone / spawn a mutation);
- a session log (where the player went, what they bought, how long they meditated vs hunted, when they stopped).

**Two sessions:** day 1 (free play, no instructions) and **day 2** (invited back). Day 2 tests the **return experience** (the offline gain, the next goals). It doesn't test real retention, which is measured later, unprompted.

| # | We watch (behaviour) | Pass |
|---|---|---|
| 1 | First PERFECT, unaided | under 30 s |
| 2 | Sells without being told after the first (tutorial) sell | yes |
| 3 | **Chooses to meditate without a quest telling them to** | at least once on day 1 |
| 4 | **Switches between hunting and meditating on their own** | 3+ switches on day 1 |
| 5 | Taps the red flash in the beam clash without being told | by the 2nd boss attempt |
| 6 | Notices and chases a mutated monster | yes |
| 7 | Feeds a pet / makes a ★ without being told after the tutorial | yes |
| 8 | Keeps playing after boss 1 with no prompt | 10+ min |
| 9 | Logs off on a mat (or asks about offline) | yes, or explained in one line |
| 10 | **Day 2:** sees the offline gain and keeps playing after it | 10+ min |
| 11 | Timing behaviour at 15+ min: still aiming for PERFECTs, using Overdrive | not abandoning timing |

**What they say counts less than what they do:**
- secondary: fun 1-10, the best and the most boring moment;
- an answer only breaks a tie.

**If #1, #4 or #11 fails, fix the core before any more art.**

**If #4 fails:**
- only hunting → raise the Shrine rate or the Power gates;
- only sitting → raise the monster loot or make Focus faster.

## 10. Quality and performance target

- **Look:** STYLE-SHEET.md (glossy toon anime, outlines, smooth plastic, calm bases + loud loot).
- **Early aura** (Spark / Blaze / Inferno): 3.0-4.5 studs, 2 layers, ≤ 40 particles at gameplay distance.
- **Others' auras and pets:** full within 40 studs, reduced at 40-100, hidden or a billboard beyond.
- **Per client:** ≤ 1,500 particles, ≤ 4 overlapping transparent layers.
- **Storm and mutations:** budgets in CORE-LOOP 9.
- **Roblox guidance:** https://create.roblox.com/docs/performance-optimization/improve
- **60 fps** on a mid-range phone with a full server at the Shrine.
- **Settings:** Low effects, others' effects, camera shake, reduced flashing, show others' pets.

## 11. Later (only after playtest #1 passes)

Each must keep the core rules (**Power only from meditation, coins only from hunting**) or be an explicit owner decision.

| System | Idea | Core-rule note |
|---|---|---|
| Zones 3-8 | new monsters, eggs, bosses, forms | tuned in the model first |
| Ascension | reset Power and zones for a permanent meditation multiplier + a halo; keep pets | pets kept, so the reset is fast and feels powerful |
| Global events (one clock for all servers) | Fire mutations ×5, Secret odds ×5, a Blood Moon… | change chances only |
| Wild Spirits | a rare roaming pet mini-boss; the final PERFECT catches it; everyone who helped gets a reward | |
| Trading | safe trade window, both confirm, 3 s lock, server-validated, logged | unlocks after boss 2 |
| Sanctum | your own island to **display** pets and trophies | **display only, no coin income** (that would break rule 2) |
| World Boss | server-wide, every 30 min | rewards eggs / food, not coins |
| Infinity Tower | endless boss floors | |
| Daily streak / incubator | return rewards | eggs / food / Focus boosts, not coins |
| **Monetization** | the owner's design | owner decides |

## 12. What the model does and doesn't cover

- **It covers:**
  - meditation (AFK / Focus / offline);
  - blasts with PERFECT / combo / Overdrive chains;
  - the 6 monsters, mutations, the bag cap and SELL;
  - shop spending, eggs with real odds and guarantees, star fusion, Soul Food levels;
  - rank quests, boss HP and the beam clash.
- **It doesn't cover:**
  - monsters hitting the player (only time lost, assumed small);
  - other players sharing monsters (personal loot means crowded servers pay faster than the model);
  - walking between areas (beyond a per-kill overhead);
  - saving (tests P1-P14 are for the real game).
- **Decisions** (like when to meditate) follow a simple "average player" policy. **The playtest is the real test.**
