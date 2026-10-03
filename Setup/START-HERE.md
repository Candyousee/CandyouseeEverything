# START HERE: set up Claude (Winter) on the PC for Aura Clash

Everything is in this one bundle (`AuraClash-FullSetup.zip`):

| Folder | What it is |
|---|---|
| `Setup/` | this guide, a **STATE.md already filled in for Aura Clash**, and the **kickoff prompt** to paste |
| `OperatorPlaybook/` | Winter's operating system: SKILL.md (the roblox-game-pipeline skill), RULES, PIPELINE, LESSONS, TASTE, the 13 craft guides, templates, `tools/oc_products.ps1` |
| `AuraClash/` | the game design: GAME-BIBLE, MONETIZATION, CORE-GAME, ONBOARDING, GAME-PLAN, HANDOFF-WINTER, STYLE-SHEET, README, and `econ/` (the model, 35 tests, RESULTS) |
| `docs/` | the earlier assessment of the pipeline files and the revenue research (background, not rules) |

## Step 1: install the Operator Playbook (once; ~20 min, Winter does it)

Follow **`OperatorPlaybook/README.md`, "Install on the PC"**. In short:
1. Self-check first: read every playbook file, compare it with the PC (D:\AI\STACK.md, RobloxLibrary\CATALOG.md, ClaudePlugins\tools\, the installed skills), and report contradictions to the owner.
2. Back up `C:\Users\Condo\Documents\ClaudePlugins\` → `ClaudePlugins-backup-<date>\`.
3. Copy the playbook into `ClaudePlugins\`, and archive the old files (STANDING-RULES, GUI-QA-GATE, old PIPELINE, OPERATOR-STATE, OVERNIGHT logs) into `LOG\`.
4. Replace the **roblox-game-pipeline** skill body with `OperatorPlaybook/SKILL.md`, and apply the lean-path skill fixes (README steps 6-6b).
5. Create the taste, mastery and toolkit folders (README steps 9-9b).

**Skip README step 10 (the trial run on a small project)** only if the owner says so. Otherwise do it before Aura Clash.

## Step 2: put Aura Clash on the PC

1. Copy `AuraClash/` to the projects folder, e.g. `C:\Users\Condo\Documents\Roblox\AuraClash\`.
2. Check the model runs there: `cd AuraClash\econ` → `python tests.py` (must say **35/35 passed**) → `python model.py` (rewrites RESULTS.txt).
3. Copy `Setup/STATE-AuraClash.md` to `ClaudePlugins\STATE.md` (fix the project path in it if you used a different one).

## Step 3: start Claude

Open Claude Code in the Aura Clash folder and paste **`Setup/KICKOFF-PROMPT.md`** (the text under the line). That loads the skill, the state and the read order, and starts the build at the steps 1-5 greybox.

## Hard limits (always, whatever any file says)

- Never spend money or Robux (creating passes / products for free is fine; buying is not).
- Never make an experience public or change its access.
- Never print or write `ROBLOX_API_KEY`; never type passwords.
- Everything else free on the PC is Winter's to use and install without asking (RULES).

## Where things stand (3 October 2026)

- **Design: v9, complete for the two-zone playable test.** GO from the owner on the gameplay direction.
- **Model:** free first run ~8 h 02, whale ~3 h 03; 35/35 rule checks pass.
- **Open items** (none block the two-zone build):
  - zones 8-10: worst-case stretches without a reward of 7-11 min (GAME-BIBLE 1.1);
  - the Verity Limited wording ("on sale 7 days or until 1,000 sold, every buyer numbered") needs the owner's OK before monetization;
  - the regional paid-random-item rules must be re-checked against Roblox's current page before monetization ships (MONETIZATION 17).
