# HANDOFF → Winter: build the Aura Clash two-zone playable test (v5.1)

> **GO (owner, 2 Oct 2026):** the gameplay direction is approved after the outside review. Build the two-zone test, **starting with the steps 1-5 greybox** and its fun gate. The saving contract (CORE-GAME 8.2) is a hard requirement for step 10.

**Status:**
- the design is v5.1 (meditation + crystal-monster hunting + pets);
- the numbers come from `econ/model.py`, and `python tests.py` passes 22/22;
- the art style is chosen (STYLE-SHEET).

**Don't rewrite the concept.** The next evidence must come from the real game.

## Read first (in this order)

1. **`README.md`:** the doc map.
2. **`CORE-LOOP.md`:** the core rules and numbers. **It wins on any conflict.**
3. **`CORE-GAME.md`:**
   - eggs, the pet catalogue, aura, HUD, tutorial, server authority;
   - **section 8 (saving tests P1-P14)** and **section 9 (playtest #1)** are the **acceptance criteria**.
4. **`GAME-PLAN.md` section 5:** the 11 build steps and the quality bar.
5. **`STYLE-SHEET.md`:** glossy toon anime.
6. **`econ/`:** the reference model.
   - `python tests.py` must keep passing.
   - If you change a rule while building, change the model constant, re-run both scripts, and update CORE-LOOP in the same commit.
7. **The playbook:** RULES section 0, PIPELINE 3a-3c (prove the concept, playtests, concept first), craft STYLE / VFX / GUI / SYSTEMS / GAMEPLAY.

**Ignore `archive/`:** old versions, not rules.

## Before step 1

- **Art bible:** the 9 target frames (STYLE-SHEET) generated on the GPU from STYLE-SHEET; the owner approves them once.
- **Greybox first:** steps 1-5 in grey boxes, **including the minimal pet loop** (earn → buy a pet → become stronger). Then **Winter's fun gate** (does blasting feel good, do you switch to meditation, does a new pet feel like getting stronger?) and owner playtest #1 greybox, before any art.
- **Concept sheets** (GPU → Blender):
  - 6 monsters + 6 mutation looks;
  - 16 pets (8 per zone; Secrets as silhouettes);
  - Spark / BLAZE / INFERNO;
  - the Shrine hub;
  - the Stone Golem, the Magma Oni;
  - the HUD.

## Rules that are easy to get wrong

- **Power only from meditation; coins only from selling shards.** No quest, boss, event or Later system may give coins or Power.
- **The bag counts shards, not value:** a mutated shard is 1 slot. The storm shows at most 12 meshes.
- **Soul Food never uses bag space.**
- **Pets never attack on their own** and **never die** (they get dazed).
- **The combo drops one level on a miss,** not to zero.
- **Fusion = stars,** keeps the highest level, and never lowers the team. "Gold" only ever means a mutation.
- **The crack colour always equals the result.** No fake near-misses.
- **Shared monsters, personal loot:** everyone whose hit landed gets their own full drop and quest credit. **New players also get a protected pack** only they can damage, until they beat that zone's boss.
- **Overdrive is 8 s of real time:** an expiry timestamp set **when the 5th PERFECT lands**, not a count of attack time. Walking, selling, hatching and meditating don't pause it.
- **Overdrive chains** hit at most 2 monsters next to the target; overkill damage is lost.
- **Mutation odds:** one roll per spawn against the table; the shown chances are the real chances.
- **Saving has three outcomes:** confirmed saved (show it), confirmed not committed (a later successful write finds no id and marks it cancelled, then undo), or **unknown**. While it's unknown: **hold** the cost (no refund, no spending), block conflicting transactions, keep reconciling, and never show the result. A committed but unrevealed operation plays on the next join (CORE-GAME 8.2).
- **The boss gate** = all zone quests done (the last one is the Power target).
- **Offline:** server time, 25% of AFK, 8 h cap, claimed once (confirmed save).
- **No Bond, no Force.** No monetization in this build.

## You have full access

You're entitled to every free tool, app and resource on the owner's PC, and to install new free ones, **without asking permission** (RULES P5 / rule 14).

**Hard limits still apply:**
- never spend money or Robux;
- never make the experience public or change its access;
- never print or write `ROBLOX_API_KEY`;
- never type passwords.

## Done means

- steps 1-11 built, at representative quality;
- tests P1-P14 pass **in the game**;
- the greybox fun gate and the seven-sense review passed;
- the owner runs playtest #1 (day 1 + invited day 2) with the cheat panel and session log ready.

Then report to the owner with the behaviour results from CORE-GAME 9.
