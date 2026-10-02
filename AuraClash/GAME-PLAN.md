# AURA CLASH: Game Plan (v4, 2 October 2026)

**This file:** the market case, the pitch, and the build order for the **two-zone playable test**.

**Not in this file:**
- **All rules and numbers:** see **CORE-GAME.md** (backed by `econ/`, with `python tests.py` checks).
- **Monetization:** designed by the owner, and added only after playtest #1 passes. Nothing in this build depends on it.

## 1. Market check (October 2026)

- **Simulators are the top-grossing Roblox genre.** Aura / training simulators have proven demand (e.g. Aura Ascension: about 18K players online at once).
- **Pet RNG games are dominated by Big Games**, so we don't compete on "pets roll auras".
- **"Steal a" / "grow a" games are saturated.**
- **The gap:** the aura sim where your aura is a **spectacle**, with a **skill moment** in every action (charge / release, the boss counter), clean pacing, and **spirits that ARE your aura**.
- **Verdict:** go, provided the two-zone test passes (CORE-GAME section 13).

## 2. Pitch

*"Train your power, hatch spirits, and grow the biggest aura in the server."*

- **Who:** 8-14-year-olds who play simulators and anime games.
- **Identity:** a pet training simulator. The fighting is only the boss gate.

## 3. Build order: two-zone playable test (no monetization, no extra systems)

Everything gameplay-facing is built from scratch.

| Step | Build | Done when |
|---|---|---|
| 1 | Training stone: the charge / release rules exactly as CORE-GAME 2.1 (minimum hold, recovery + buffer, combo, Overdrive, meditation); power / coin formulas (2.3) | A server-side validation test matches the formulas; the hold timings feel right on PC, mobile and gamepad |
| 2 | Zone 1 + zone 2 eggs (CORE-GAME 3.1-3.2): the odds card, the honest crack-colour tell, first-run guarantees, the hatch sequence | 1,000-hatch odds test within tolerance; crack colour = result every time |
| 3 | Spirits: slots, Equip Best, orbiting inside the aura, energy streaks on release | 3-9 orbiters stable at 60 fps |
| 4 | Fusion: auto-fuse (Commons + Rares, unequipped), the Plaza altar with a preview, the "Fusion ready" badge, favourites, inventory 250 + mailbox | The rule tests mirror `econ/tests.py` |
| 5 | Aura: the layer hierarchy, the Wardrobe + "NEW LOOK" prompt, the size formula, forms 1-4 (FLAME tutorial, BLAZE on boss 1, SURGE on boss 2) | Early-aura spec (CORE-GAME 12) met at gameplay distance |
| 6 | Boss 1 + boss 2 clashes: the drift / push / counter rules, the tips card, Overpower | The win rates in a scripted bot test resemble `clash_results.txt` |
| 7 | Mini Plaza: spawn, 2 portals, the Fusion Altar, the Wardrobe Mirror, the Incubator (CORE-GAME 10.2), the Daily Board (streak) | All machines reachable within 10 s of spawn |
| 8 | Test tools: a cheat panel (set power / coins / zone), a session log (where the player went, what they bought, when they stopped) | The owner can run playtest #1 without help |

**Then:** Winter's fun gate, then **owner playtest #1 (two sessions, day 1 + day 2)** using the behaviour criteria in CORE-GAME 13.

**Only if it passes:**
- zones 3-8;
- Ascension;
- Infinity;
- the owner's monetization;
- art at full quality (GPU concepts → Blender), following the playbook.
