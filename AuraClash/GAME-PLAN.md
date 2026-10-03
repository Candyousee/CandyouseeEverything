# AURA CLASH: Game Plan v8 (3 October 2026)

**This file:** the market case, the pitch, the research, the concept test, and the **build order**.

**Rules and numbers:**
- `GAME-BIBLE.md`: everything in the game, zone by zone;
- `MONETIZATION.md`: everything that's sold;
- `CORE-GAME.md`: saving, tests, playtest;
- `STYLE-SHEET.md`: the look.

## 1. Market check (October 2026)

- **Simulators are the top-grossing Roblox genre.** Aura / training simulators have proven demand.
- **Pet simulators are proven but dominated by Big Games,** so we compete on **feel**: a skill blast, a visible aura, pets that act alive, and a calm / active rhythm.
- **"Steal a" / "grow a" games are saturated.** We borrow their best systems (mutations, show-off, global events) without the loss / griefing.
- **The gap:** the pet sim where **you** are the hero:
  - your aura is the spectacle;
  - every blast has a timing skill;
  - your pets fight and tank beside you;
  - an AFK-friendly meditation half grows your Power while you're away.
- **Verdict:** go, provided playtest #1 passes (CORE-GAME 3).

## 2. Pitch

*"Meditate to grow your aura, hunt crystal monsters with your pets, and become the strongest in the server."*

- **Who:** 8-14-year-olds who play simulators and anime games.
- **Identity:** a pet simulator with two halves: **meditate (Power)** and **hunt (coins → pets)**.
- **Scope:**
  - 10 zones at launch (GAME-BIBLE Part B), then a new zone about every 1-2 weeks;
  - a first full run of about 7 hours for an average free player (about 4 h 17 with 62 R$ of ladder tiers, about 2 h 22 with 1,274 R$).

## 3. Research: what we take (owner: "we don't need to be original")

| System | Taken from | In Aura Clash |
|---|---|---|
| Pets fight beside you, constant loot stream | Pet Simulator 99 | pets fight and tank crystal monsters |
| Gold / Rainbow pet machines | Pet Simulator 99 | star fusion up to ★5 |
| Rank quests | Pet Simulator 99 | 5-9 per zone, very easy → hard; the boss gate opens when they're done |
| Paid eggs, Limiteds, server boosts | Pet Simulator 99 | Daily + Shop Exclusive Eggs, numbered Limiteds (Verity meme items), Server Luck, Mutation Storms |
| Luck ladders, crazy-rare tiers, serials | RNG games (Sol's RNG) | the 2× Boost ladder, Secret → Divine → Impossible → monthly Boundless, serialized |
| Hourly and daily rewards | most top sims | a 60-minute hourly track and a 7-day login cycle with exclusive eggs |
| Stat training + AFK progress | Anime Fighting Simulator | meditation (AFK / Focus / offline) |
| Mutations raise value | Grow a Garden | monster mutations (Gold → Celestial) |
| Rarity cutscenes | Sol's RNG | the hatch ladder with Mythic / Divine / Secret cutscenes |
| Backpack → sell rhythm | Mining Simulator | the Shard Storm + a one-button teleport SELL (no walking) |
| Season pass | many top games | the Aura Pass |

**What players hate, and our rule for each:**

| Complaint | Our rule |
|---|---|
| Shallow, repetitive loops | two halves that feed each other; mutations; a unique boss mechanic per zone |
| Becomes an "AFK sim" | AFK gives Power only; coins, quests and bosses need active play |
| Walking chores | SELL is a 3 s teleport; the Shrine is the hub |
| Permanent loss / griefing / kill-stealing | nothing you own can be lost; knockouts cost only time; shared monsters with personal loot |
| Scams / dupes | server-authoritative everything; unique pet ids; safe trading later |
| Lag on mobile | a capped storm visual, monster and particle budgets |
| Pay-to-win pressure | boosts multiply play, never replace it; free players finish everything (MONETIZATION.md) |

## 4. Concept test (PIPELINE 3a)

| Question | Answer |
|---|---|
| 10-second hook | sit, Focus-tap, and your aura flares up with "+40 POWER!"; seconds later your first PERFECT shatters a crystal slime |
| One picture | a glowing anime kid in a tornado of shards, pets pouncing on a crystal boar |
| The 50th time | timing skill (PERFECT / combo / Overdrive), mutations (any spawn could be a jackpot), the next monster turning green |
| Feeling | power (the aura grows), greed (a full gold storm), surprise (mutations, hatches), calm (meditation) |
| Want | always visible: green HP bars, the egg stand, the quest bar, the boss gate |
| Show-off | aura size and form, rare pets, ★5 halos, a mutated storm, Secret / Ascended titles, Limited serials |
| Return | the offline meditation gain, levels and stars, Divine / Secret hunting, the Aura Pass |
| Simple | "Meditate to get strong, beat monsters for money, buy pets." |
| Strong in grey boxes? | blast timing + switching halves + "a new pet makes me stronger" must be fun in grey boxes. **Checked in the steps 1-5 greybox before art** |

## 5. Build order

### 5a. Two-zone playable test (no monetization, no Later systems)

Everything gameplay-facing is built from scratch. **Steps 1-5 are first proved in greybox** (PIPELINE 3a: fun gate). The greybox includes a **minimal pet loop** (step 5), so the gate tests **earn → buy a pet → become stronger**.

| Step | Build | Done when |
|---|---|---|
| 1 | **Timing core:** hold-release blast, combo ±1, Overdrive (8 s timestamp from the 5th PERFECT's hit) + chains, auto-aim; the **Focus ring** (GAME-BIBLE 2-3) | Server validation matches the rules; it feels right on PC, mobile and gamepad |
| 2 | **Monsters zones 1-2:** 3 types each, AI (wander, telegraph, hit), green HP bars, spawns + the Big cap, knockout to Shrine, **mutations** (one exact roll per spawn), shared monsters with personal loot (GAME-BIBLE 4.1-4.2, 14-15) | P9, P11 pass; ≤ 30 monsters, 60 fps on mobile |
| 3 | **Shard Storm + SELL + the Lumora Plaza hub:** storm (4 looks, ≤ 12 meshes), SELL teleport + Stay, the shop (Egg / Bag / Mat / Surge), **the hub with the Leaderboard Wall (server boards), the teleporter ring, and empty store stands as art placeholders** (GAME-BIBLE 4.3, 7, 12) | P10, P12 pass |
| 4 | **Meditation:** mats, AFK, Focus, the rate formula, offline from server time, AFK idle-rejoin (GAME-BIBLE 3) | Rates match the model |
| 5 | **Minimal pets (greybox):** the zone 1 egg (real odds, a simple pop); 3 slots + Equip Best; pets follow, attack (team hit capped at 100% of Power), get dazed, boost meditation; **XP from kills**. No fusion, cutscenes or idle animations yet | Hunt → sell → buy an egg → the pet visibly speeds up hunting **and** meditation. **Greybox fun gate on steps 1-5**, then owner playtest #1 greybox (PIPELINE 3b) |
| 6 | **Eggs (full):** odds card (each egg's own table, 10 tiers), honest cracks, guarantees, the hatch ladder incl. the Mythic-to-Boundless cutscenes, serials for Secret+, Hatch ×3 free after boss 1 (GAME-BIBLE 5.1, 6) | P6-P8 pass |
| 7 | **Pets (full):** tank AI, idle / charge / meditate behaviours, stars 0-2 at the Fusion Altar (★3-★5 come with the Star Forge in zone 5), auto-fuse, Secret+ scaling to your best pet, levels 1-30 with XP bars, inventory 250 + auto-delete + locks + mailbox (GAME-BIBLE 5) | Model rule tests mirrored in-game; 10 pets × full server at 60 fps |
| 8 | **Rank quests + tutorial** (zones 1-2 lists; the first 8 minutes; the hand pointer) (GAME-BIBLE 8, 11, 14) | A new player reaches boss 1 unaided |
| 9 | **Bosses:** Stone Golem + Magma Oni (3 phases, beam clash), **Boss Shards**, forms Spark → BLAZE → INFERNO (GAME-BIBLE 9, 10, 14-15). **The boss format is under review** (GAME-BIBLE 9: options A-D); build the chosen one | Scripted-bot win rates resemble `econ/RESULTS.txt` section 6 |
| 10 | **Saving** with the three-outcome contract (CORE-GAME 2) | P1-P8, P10-P12, P14 pass in the real game |
| 11 | **Test tools:** cheat panel, session log, Low effects | The owner can run playtest #1 without help |

**Quality bar for the test: representative art, not greybox** (after the step 5 fun gate):
- one finished pet per rarity for zones 1-2 (Divine / Secret as silhouettes);
- all 6 monsters + 6 mutation looks;
- Spark / BLAZE / INFERNO;
- the real hatch, storm and transformation VFX;
- HUD + egg card + shop + pet menu at GUI-gate quality.

All of it follows STYLE-SHEET (GPU concepts → Blender, outlines, smooth plastic).

**Then:** Winter's seven-sense review, then **owner playtest #1** (day 1 + invited day 2) with the criteria in CORE-GAME 3.

### 5b. After playtest #1 passes (to launch)

1. **Monetization** (MONETIZATION.md v3): the buff system and the 2× Boost ladder, store, passes, slot packs, coin packs, both Exclusive Eggs + PolicyService gating, the Verity Limiteds (our own art), packs, Aura Pass, hourly / daily / group rewards, the two pop-ups. Tests P13, P15-P20.
2. **Zones 3-10** (GAME-BIBLE 16-23), one at a time, each through the art pipeline and the model, **each with its machine** (GAME-BIBLE 13: Codex, Enchant Forge, Nursery, Star Forge, Reactor, Aura Forge, Relic Shrine, Infinity Tower, Ascension). Each machine is added to the model before it ships.
3. **Full art pass**, then a **private soft launch** (the owner decides access; Winter never changes it), then the live plan (GAME-BIBLE 26).

## 6. Design targets (checked by `econ/tests.py`)

These are **model targets for a free player playing solo, not promises.** The simulations check that the rules hang together and the pacing is sane; **they say nothing about retention or revenue.** Only playtests and live data can. The session logs measure the real values, and the model is re-tuned to them.

| Target | Model (average player) |
|---|---|
| Boss 1 at 4-9 min | ~5.5 min |
| Boss 2 at 15-30 min | ~24 min |
| Every zone takes longer than the one before | yes |
| **Free first run (boss 10) in about 10-12 h** (owner) | **10 h 34** |
| **Whale first run about 3 h** (owner) | **3 h 14** |
| Pets 30-50% of damage (never more than your blasts) | 37% |
| Average player wins the clash ≥ 90% at recommended Power; weak ≥ 60%; under-powered (½) average ≤ 40% | 100% / 79% / 23% |
