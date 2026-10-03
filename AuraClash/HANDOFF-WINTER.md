# HANDOFF → Winter: build the Aura Clash two-zone playable test (v6)

> **GO (owner):** the gameplay direction is approved. Build the two-zone test, **starting with the steps 1-5 greybox** and its fun gate. The saving contract (CORE-GAME 2) is a hard requirement for step 10. **No monetization in this build** (it comes straight after playtest #1).

**Status:**
- the design is v6 (meditation + crystal-monster hunting + pets; 8 zones designed);
- the numbers come from `econ/model.py`, and `python tests.py` passes 25/25;
- the art style is chosen (STYLE-SHEET).

**Don't rewrite the concept.** The next evidence must come from the real game.

## Read first (in this order)

1. **`README.md`:** the doc map.
2. **`GAME-BIBLE.md`:** every rule and number. **It wins on any conflict.** For this build: Part A (sections 1-11) + zones 1-2 (sections 12-13).
3. **`CORE-GAME.md`:**
   - server authority;
   - **section 2 (saving tests)** and **section 3 (playtest #1)** are the **acceptance criteria**.
4. **`GAME-PLAN.md` section 5a:** the 11 build steps and the quality bar.
5. **`STYLE-SHEET.md`:** glossy toon anime.
6. **`econ/`:** the reference model.
   - `python tests.py` must keep passing.
   - If you change a rule while building, change the model constant, re-run both scripts, and update GAME-BIBLE in the same commit.
7. **The playbook:** RULES section 0, PIPELINE 3a-3c, craft STYLE / VFX / GUI / SYSTEMS / GAMEPLAY.

`MONETIZATION.md` is for the next phase. Read it so the HUD leaves room for the Store button. **Ignore `archive/`:** old versions, not rules.

## Before step 1

- **Art bible:** the 9 target frames (STYLE-SHEET) generated on the GPU; the owner approves them once.
- **Greybox first:** steps 1-5 in grey boxes, **including the minimal pet loop** (earn → buy a pet → become stronger). Then **Winter's fun gate** and owner playtest #1 greybox, before any art.
- **Concept sheets** (GPU → Blender):
  - 6 monsters + 6 mutation looks;
  - 18 pets (9 per zone; Divine and Secret as silhouettes);
  - Spark / BLAZE / INFERNO;
  - the Shrine hub;
  - the Stone Golem, the Magma Oni;
  - the HUD.

## Rules that are easy to get wrong

- **Economy:**
  - **Power only from meditation; coins only from selling shards** (monster shards and Boss Shards). No quest, boss or system gives coins or Power directly.
  - **The bag counts shards, not value:** a mutated shard is 1 slot. The storm shows at most 12 meshes.
  - **Bosses give Boss Shards** (worth about 3 eggs of the next zone, sold at that zone's altar), **not a free egg**.
- **Pets:**
  - **XP is automatic:** every kill gives XP to every **equipped** pet. There is no food.
  - **Stars go to ★5** (×2 per star; 3 copies → the next star). Fusion keeps the highest level and never lowers the team.
  - **The team's hit is capped at 100% of your Power.** Meditation's +10% per Strength is not capped.
  - **Pets never attack on their own** and **never die** (they get dazed).
- **Odds:**
  - **7 rarities:** Common 60 / Rare 28 / Epic 10 / Legendary 1.8899 / Mythic 0.1 / **Divine 0.01** / **Secret 0.0001** %. The card shows the real odds; the crack colour always equals the result.
  - **Mutation odds:** one roll per spawn against the table.
- **Combat:**
  - **The combo drops one level on a miss,** not to zero.
  - **Overdrive is 8 s of real time,** set when the 5th PERFECT lands. Chains hit at most 2 monsters next to the target, and overkill is lost.
  - **Shared monsters, personal loot:** everyone whose hit landed gets their own full drop and quest credit. (The protected beginner pack is **removed**, owner decision.)
- **Progress:**
  - **The boss gate** = all of that zone's quests done (the last one is the Power target). Quest difficulty: zones 1-3 very easy, 4-6 easy, 7 medium, 8 hard.
  - **Offline:** server time, 25% of AFK, 8 h cap, claimed once (confirmed save).
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
