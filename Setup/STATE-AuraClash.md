# STATE: right now (rewrite this file; never append history here. Keep it under 80 lines)

Updated: 2026-10-03 (set from the cloud design session; Winter updates it at the first milestone)

## Usage

- Plan limit status: unknown at handoff; check on first start.

## Active project

- **Aura Clash** (L), path: `C:\Users\Condo\Documents\Roblox\AuraClash\` (fix if different).
- Brief: `AuraClash\HANDOFF-WINTER.md`. Rules: `AuraClash\GAME-BIBLE.md` (wins on conflicts). Spec / model: `AuraClash\econ\`.
- Owner-approved: 2026-10-03 (gameplay direction GO; design v9).
- Status words: designed + model tests pass (35/35). **Nothing built yet.**

## Owner playtests (games)

- Done: none. Next: **#1 greybox** after build steps 1-5 (the fun gate), then #1 at representative quality after steps 1-11 (CORE-GAME 3).

## Running now

| Lane | Objective | Shell PID | Claude PID | Started | Hard stop | Brief |
|---|---|---|---|---|---|---|
| (none) | | | | | | |

## Waiting on the owner

- Approve the 9 target frames (art bible, STYLE-SHEET) once they're generated.
- Later, before monetization: OK the Verity Limited wording (MONETIZATION 7).

## Next steps (in order)

1. Install the Operator Playbook if not done (Setup/START-HERE.md step 1).
2. Read in the HANDOFF-WINTER order: README → GAME-BIBLE (Part A 1-12 + zones 1-2) → CORE-GAME → GAME-PLAN 5a → ONBOARDING → STYLE-SHEET → econ.
3. Run `python tests.py` (35/35) and `python model.py` on the PC.
4. Generate the 9 target frames on the GPU (ComfyUI) → owner approval.
5. Build steps 1-5 in **greybox** (timing core, monsters zones 1-2, storm + SELL + Lumora Plaza hub, meditation, minimal pets) → Winter's fun gate (incl. friction checks CORE-GAME 3 #12-#15) → owner playtest #1 greybox.
6. Then steps 6-11 at representative quality (eggs, pets, quests + tutorial + the onboarding funnel, bosses as raids + Trial, saving with the three-outcome contract, test tools).

## Parked projects (one line each; details in LOG/<project>.md)

- Stud Pets / Pet System / Stud Gear / AnimeClip: see the repo folders and LOG.

## Recent owner decisions (last 7 days; older ones move into RULES.md or LOG/)

- 10-03: free first run ~8-9 h ("make it like 8 hours ... or like 9"); whale ~3 h.
- 10-03: bosses are server raids (option B) + a solo Trial; raid rewards need real participation (8% rule, made fair for weak active players).
- 10-03: endgame = always-respawning Nexus Titan, Weekly Limited Egg (coins), XP Shards as food + Awakening to 50.
- 10-03: machine products approved (Enchant Crystals, Nursery+, Nursery Hurry, Relic Shards, XP Shards).
- 10-03: friction is the biggest risk, more than originality; longevity after the first clear must hold up.
- 10-03: onboarding funnel set up (ONBOARDING.md).
- 10-02/03: Hatch ×3 free after boss 1; Secret = best pet, Divine ×10, Impossible ×100, Boundless ×1,000; zones must look nothing alike; pets and VFX decide the game.
