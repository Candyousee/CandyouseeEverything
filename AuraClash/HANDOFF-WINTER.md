# HANDOFF → Winter: build the Aura Clash two-zone playable test (v9)

> **GO (owner):** the gameplay direction is approved. Build the two-zone test, **starting with the steps 1-5 greybox** and its fun gate. The saving contract (CORE-GAME 2) is a hard requirement for step 10. **No monetization in this build** (it comes straight after playtest #1).

**Status:**
- the design is v9 (meditation + crystal-monster hunting + pets; 10 zones designed in detail, with machines unlocking zone by zone; server raid bosses; the Nexus Titan endgame);
- the numbers come from `econ/model.py`, and `python tests.py` passes 32/32;
- the art style is chosen (STYLE-SHEET).

**Don't rewrite the concept.** The next evidence must come from the real game.

## Read first (in this order)

1. **`README.md`:** the doc map.
2. **`GAME-BIBLE.md`:** every rule and number. **It wins on any conflict.** For this build: Part A sections 1-12 (the hub included: Leaderboard Wall with server boards, teleporter ring, store stands as art placeholders) + **zones 1-2 (sections 14-15), built to the zone design tables there**. Hatch ×1, Auto-Hatch, and **Hatch ×3 after boss 1**. Section 13 machines come later, except the Fusion Altar (★1-★2).
3. **`CORE-GAME.md`:**
   - server authority;
   - **section 2 (saving tests)** and **section 3 (playtest #1)** are the **acceptance criteria**.
4. **`GAME-PLAN.md` section 5a:** the 11 build steps and the quality bar.
5. **`STYLE-SHEET.md`:** glossy toon anime.
6. **`econ/`:** the reference model.
   - `python tests.py` must keep passing.
   - If you change a rule while building, change the model constant, re-run both scripts, and update GAME-BIBLE in the same commit.
7. **The playbook:** RULES section 0, PIPELINE 3a-3c, craft STYLE / VFX / GUI / SYSTEMS / GAMEPLAY.

`MONETIZATION.md` (v3) is for the next phase. Read it so the HUD leaves room for the Store, Buffs and Hourly Reward buttons. **Ignore `archive/`:** old versions, not rules.

## Before step 1

- **Art bible:** the 9 target frames (STYLE-SHEET) generated on the GPU; the owner approves them once.
- **Greybox first:** steps 1-5 in grey boxes, **including the minimal pet loop** (earn → buy a pet → become stronger). Then **Winter's fun gate** and owner playtest #1 greybox, before any art.
- **Concept sheets** (GPU → Blender):
  - 6 monsters + 6 mutation looks;
  - 22 pets (11 per zone; Secret, Divine and Impossible as silhouettes) + this month's Boundless;
  - **Lumora Grove and Pyrora Dojo key art from their design tables** (layout, landmarks, materials, sky, VFX), then Lumora Plaza (the hub);
  - Spark / BLAZE / INFERNO;
  - the Shrine hub;
  - the Stone Golem, the Magma Oni;
  - the HUD.

## The bar: pets and VFX decide this game (owner)

**After the core loop, the pets and the VFX are what make or break Aura Clash.** Treat every pet and every zone as a hero asset:
- **Pets:** follow the pet visual ladder in STYLE-SHEET. Every species gets its own attack, its own idle animations, and a rarity treatment you can read from across the zone.
- **Zones:** every zone must look completely different from the others. Build from its design table in GAME-BIBLE Part B (landmarks, sky, materials, ambient VFX).
- **Hero moments:** hatches, transformations and Mutation Storms run at VFX ladder level 5, plus a +1 pass.

## The other bar: no chores (owner)

**Friction, not originality, is the biggest risk.** Build to GAME-BIBLE 1.1:
- meditation never asks you to stand still;
- one-hit monsters are swept by holding the button, and timing is saved for monsters that matter;
- quest steps take at most ~8 min and show minutes left;
- every upgrade shows a before/after card and makes the next few minutes faster;
- something rewarding happens at least every ~3 min.

The greybox fun gate checks these (CORE-GAME 3, #12-#15) **before** any art.

## Rules that are easy to get wrong

- **Economy:**
  - **Power only from meditation; coins only from selling shards** (monster shards and Boss Shards). No quest, boss or system gives coins or Power directly.
  - **The bag counts shards, not value:** a mutated shard is 1 slot. The storm shows at most 12 meshes.
  - **Bosses give Boss Shards** (worth about 3 eggs of the next zone, sold at that zone's altar), **not a free egg**.
- **Pets:**
  - **XP is automatic:** every kill gives XP to every **equipped** pet. There is no food.
  - **Stars go to ★5** (×2 per star; 3 copies → the next star; ★3+ from zone 5). Fusion keeps the highest level and never lowers the team.
  - **Team hit = 10% of your Power per doubling of team Strength** (log2(1 + Strength)); no hard cap. Meditation's +10% per Strength is not capped either. The pet card shows both gains.
  - **The Fusion Altar stops at ★2;** ★3-★5 need the Star Forge (zone 5).
  - **Pets never attack on their own** and **never die** (they get dazed).
- **Odds:**
  - **10 tiers defined by odds band:** Common, Uncommon, Rare, Epic, Legendary, Mythic, **Secret 1 in 1M+**, **Divine 1 in 10M+**, **Impossible 1 in 1B+**, **Boundless 1 in 1T+** (in every egg; a new one every month).
  - **Every egg has its own table** (GAME-BIBLE Part B); the **Secret-and-rarer** tiers are **serialized**.
  - **Luck has no cap** and is weighted toward the rarest. The card shows the real odds at your current luck; the crack colour always equals the result.
  - **Mutation odds:** one roll per spawn against the table.
- **Combat:**
  - **The combo drops one level on a miss,** not to zero.
  - **Overdrive is 8 s of real time,** set when the 5th PERFECT lands. Chains hit at most 2 monsters next to the target, and overkill is lost.
  - **Shared monsters, personal loot:** everyone whose hit landed gets their own full drop and quest credit. (The protected beginner pack is **removed**, owner decision.)
- **Secret+ Strength is live:** Secret = your best normal pet, Divine ×10, Impossible ×100, Boundless ×1,000, recomputed when your best pet changes.
- **Progress:**
  - **Bosses are server raids** every 15 min, plus a solo Trial any time. Raid rewards need you to be **active** (your own blasts land in half the raid's 10-second windows, at least 3) **and** 8% of the damage, a quarter of the median active fighter's, **or half of their own build's expected output** (server-side logs and stats; active friends of any strength always share). The first win gives the form, the Boss Shards and the next zone.
  - **The boss gate** = all of that zone's quests done (the last one is the Power target). Quest difficulty: zones 1-3 very easy, 4-6 easy, 7 medium, 8 hard.
  - **Offline:** server time, 25% of AFK, 8 h cap, claimed once (confirmed save).
- **Receipts:** a permanent `delivered` ledger, never pruned, never cancelled; acknowledge only on confirmed `delivered`. Hatch ids count only when stored `committed`.
- **Saving has three outcomes:** confirmed saved (show it), confirmed not committed (a later successful write finds no id and marks it cancelled, then undo), or **unknown** (hold the cost, block conflicts, keep reconciling, never show the result). A committed but unrevealed operation plays on the next join (CORE-GAME 2.2).

## You have full access

You're entitled to every free tool, app and resource on the owner's PC, and to install new free ones, **without asking permission** (RULES P5 / rule 14).

**Hard limits still apply:**
- never spend money or Robux (creating passes / products for free is fine; buying is not);
- never make the experience public or change its access;
- never print or write `ROBLOX_API_KEY`;
- never type passwords.

## Done means

- steps 1-11 built, at representative quality;
- the step 10 tests pass **in the game**;
- the greybox fun gate and the seven-sense review passed;
- the owner runs playtest #1 (day 1 + invited day 2) with the cheat panel and session log ready.

Then report to the owner with the behaviour results from CORE-GAME 3.
