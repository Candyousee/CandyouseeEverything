# HANDOFF → Winter: build the Aura Clash two-zone playable test

> **ON HOLD (2 Oct):** the owner is reviewing EXPERIENCE.md (core feel v3: crystal smashing, fighting spirits, Bonded aura, hatch cutscenes, Secrets, 3-phase bosses). Don't start building until he approves it and the model is re-tuned.

**Status:** planning is done and audited. Three external reviews passed; the model passes 9/9 checks and reproduces. **Don't rewrite the concept.** The next evidence must come from the real game.

## Read first

1. `CORE-GAME.md`: all rules + numbers. Its sections 13 (playtest) and 14 (persistence) are **acceptance criteria**.
2. `GAME-PLAN.md` section 3: the 9 build steps and the representative-quality bar.
3. `econ/`: the reference model.
   - `python tests.py` must keep passing.
   - If you change a rule while building, change the model constant, re-run it, and update CORE-GAME in the same commit.
4. The playbook: RULES section 0, PIPELINE section 3a-3c (prove the concept, playtests, concept first), craft/STYLE, VFX, GUI, SYSTEMS.

## Before step 1

- **Style sheet** (templates/STYLE-SHEET.md) for Aura Clash. Ask the owner: anime cel-shaded or chunky simulator?
- **GPU concept sheets:**
  - aura forms 1-4 (Light + Fire);
  - 10 spirits (5 rarities × zones 1-2);
  - the HUD + egg card + Fusion Altar + Wardrobe UI;
  - the zone 1, zone 2 and Plaza key art.

## Rules that are easy to get wrong (all in CORE-GAME)

- **Coins** never get the spirit / form / Ascension multipliers (2.3).
- **Auto-fuse** = Commons + Rares, unequipped copies only. The altar's "Fuse All" follows whole chains (3.5).
- **The crack colour always equals the result** (3.1). There are no fake near-miss cues anywhere.
- **The counter** is a separate tap inside the strike window. The beam drifts continuously (5).
- **Equip Best never changes the look.** The "NEW LOOK: wear it?" prompt does (4.2).
- **Incubator / claims:** confirmed saving with operation ids (14.2b). The tutorial flags and lifetime hatch count are saved (14.1).
- **No monetization** in this build. The owner designs it after playtest #1.

## Done means

- steps 1-9 built at representative quality;
- tests P1-P7 pass **in the game**;
- Winter's fun gate passed;
- the owner runs playtest #1 (day 1 + invited day 2) with the cheat panel and session log ready.

Then report to the owner with the behaviour results from section 13.
