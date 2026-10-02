# AURA CLASH: Game Plan v5.1 (2 October 2026)

**This file:** the market case, the pitch, the research we borrowed from, the concept test, and the build order for the **two-zone playable test**.

- **Rules and numbers:** `CORE-LOOP.md` (core) and `CORE-GAME.md` (everything around it).
- **Look:** `STYLE-SHEET.md`.
- **Monetization:** the owner designs it after playtest #1. Nothing in this build depends on it.

## 1. Market check (October 2026)

- **Simulators are the top-grossing Roblox genre.** Aura / training simulators have proven demand.
- **Pet simulators are proven but dominated by Big Games,** so we don't compete on "more pets". We compete on **feel**: a skill blast, a visible aura, pets that act alive, and a calm / active rhythm.
- **"Steal a" / "grow a" games are saturated.** We borrow their best systems (mutations, a show-off place, global events) without the loss / griefing.
- **The gap:** the pet sim where **you** are the hero:
  - your aura is the spectacle;
  - every blast has a timing skill;
  - your pets fight and tank beside you;
  - an AFK-friendly meditation half grows your Power while you're away.
- **Verdict:** go, provided playtest #1 passes (CORE-GAME 9).

## 2. Pitch

*"Meditate to grow your aura, hunt crystal monsters with your pets, and become the strongest in the server."*

- **Who:** 8-14-year-olds who play simulators and anime games.
- **Identity:** a pet simulator with two halves: **meditate (Power)** and **hunt (coins → pets)**.

## 3. Research: what we take (owner: "we don't need to be original")

| System | Taken from | In Aura Clash |
|---|---|---|
| Pets fight beside you, constant loot stream | Pet Simulator 99 | pets fight and tank crystal monsters |
| Gold / Rainbow pet machines | Pet Simulator 99 | star fusion (★ ×3, ★★ ×9) |
| Rank quests | Pet Simulator 99 | 5-6 per zone; the boss gate opens when they're done |
| Stat training + AFK progress | Anime Fighting Simulator | meditation (AFK / Focus / offline) |
| Mutations raise value | Grow a Garden | monster mutations (Gold → Celestial) |
| Rarity cutscenes | Sol's RNG | the hatch ladder, Mythic / Secret cutscenes |
| Backpack → sell rhythm | Mining Simulator | the Shard Storm + a one-button teleport SELL (no walking) |
| Server announcements, statues | Pet Simulator 99 and others | Legendary+ hatches, Celestial mutations |

**What players hate, and our rule for each:**

| Complaint | Our rule |
|---|---|
| Shallow, repetitive loops | two halves that feed each other; mutations; 3-phase bosses |
| Becomes an "AFK sim" | AFK gives Power only; coins, quests and bosses need active play |
| Walking chores | SELL is a 3 s teleport; the Shrine is the hub |
| Permanent loss / griefing | nothing you own can be lost; knockouts cost only time; shared kills (15% rule) |
| Scams / dupes | server-authoritative everything; unique pet ids; safe trading later |
| Lag on mobile | a capped bag, a capped storm, monster and particle budgets |
| Pay-to-win pressure on kids | the owner's call; flagged: free players must still progress |

## 4. Concept test (PIPELINE 3a)

| Question | Answer |
|---|---|
| 10-second hook | sit, Focus-tap, and your aura flares up with "+40 POWER!"; seconds later your first PERFECT shatters a crystal slime |
| One picture | a glowing anime kid in a tornado of shards, pets pouncing on a crystal boar |
| The 50th time | timing skill (PERFECT / combo / Overdrive), mutations (any spawn could be a jackpot), the next monster turning green |
| Feeling | power (the aura grows), greed (a full gold storm), surprise (mutations, hatches), calm (meditation) |
| Want | always visible: green HP bars, the egg stand, the quest bar, the boss gate |
| Show-off | aura size, form, rare pets, ★★ pets, a mutated storm, Secret titles |
| Return | the offline meditation gain, pets to level, ★★ goals, Secret hunting |
| Simple | "Meditate to get strong, beat monsters for money, buy pets." |
| Strong in grey boxes? | the blast timing + switching halves must be fun with grey boxes. **Checked in step 1-4 greybox before art** |

## 5. Build order: two-zone playable test (no monetization, no Later systems)

Everything gameplay-facing is built from scratch. **Steps 1-4 are first proved in greybox** (PIPELINE 3a: fun gate); art follows only if they feel good.

| Step | Build | Done when |
|---|---|---|
| 1 | **Timing core:** hold-release blast (early / PERFECT / late / tap), combo ±1, Overdrive + chains, auto-aim on mobile / gamepad; the **Focus ring** sharing the same timing feel (CORE-LOOP 1, 2.1) | Server validation matches the rules; it feels right on PC, mobile and gamepad |
| 2 | **Monsters zones 1-2:** 3 types each, AI (wander, telegraph, hit), green HP bars, spawns + the Brute cap, light damage + knockout to Shrine, **mutations** with their looks, shared-kill 15% rule (CORE-LOOP 2.2-2.3) | P9 + P11 pass; ≤ 30 monsters, 60 fps on mobile |
| 3 | **Shard Storm + SELL + Shrine hub:** the capped bag (4 looks, ≤ 12 meshes), SELL teleport + Stay, the shop (Egg / Bag / Mat / Surge) (CORE-LOOP 2.4-2.5, 4) | P10 + P12 pass |
| 4 | **Meditation:** mats, AFK, Focus, the rate formula, offline (server time, once), AFK idle-rejoin (CORE-LOOP 1) | P2, P3, P5 pass; **greybox fun gate on steps 1-4** |
| 5 | **Eggs:** odds card, honest cracks, guarantees, the hatch ladder incl. Mythic / Secret cutscenes (CORE-GAME 3) | P6-P8 pass |
| 6 | **Pets:** follow / idle / charge / fight / tank / meditate behaviour, Strength, slots + Equip Best, star fusion + the Fusion Altar, Soul Food + Feed / Auto-feed, inventory + mailbox (CORE-LOOP 3) | Model rule tests mirrored in-game; 7 pets × full server at 60 fps |
| 7 | **Rank quests + tutorial** (the first 8 minutes; the hand pointer) (CORE-LOOP 5, 7; CORE-GAME 6) | A new player reaches boss 1 unaided |
| 8 | **Bosses:** Stone Golem + Magma Oni (3 phases, beam clash), forms Spark → BLAZE → INFERNO, transformation cutscenes (CORE-LOOP 6; CORE-GAME 4) | Scripted-bot win rates resemble `econ/RESULTS.txt` section 3 |
| 9 | **Saving** (CORE-GAME 8) | P1-P12 pass in the real game |
| 10 | **Test tools:** cheat panel, session log, Low effects | The owner can run playtest #1 without help |

**Quality bar for the test: representative art, not greybox** (after the step 4 fun gate):
- one finished pet per rarity for zones 1-2 (Secrets as silhouettes);
- all 6 monsters + 6 mutation looks;
- Spark / BLAZE / INFERNO;
- the real hatch, storm and transformation VFX;
- HUD + egg card + shop + pet menu at GUI-gate quality.

All of it follows STYLE-SHEET (GPU concepts → Blender, outlines, smooth plastic).

**Then:** Winter's seven-sense review, then **owner playtest #1** (day 1 + invited day 2) with the behaviour criteria in CORE-GAME 9.

**Only if it passes:** zones 3-8, Ascension, the Later systems (CORE-GAME 11), the owner's monetization, full-quality art for everything.

## 6. Design targets (checked by `econ/tests.py`)

| Target | Model (average player) |
|---|---|
| Boss 1 at 4-9 min | 5.9 min |
| Boss 2 at 18-35 min | 23 min |
| 15-40% of play time meditating | 24% |
| Pets 30-60% of damage over the run | 44% |
| Average player wins the clash ≥ 90% at recommended Power; weak player ≥ 60%; under-powered (½) average ≤ 40% | 100% / 79% / 23% |
