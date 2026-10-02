# Operator Playbook v2: install guide

This is a cleaned-up rebuild of Winter's whole operating system, written for **any game**. It merges:
- STANDING-RULES (57 rules);
- PIPELINE.md;
- GUI-QA-GATE;
- the lean-path, regression-sweep and kaizen-retro skills;
- the model spec sheet;
- the overnight logs;
- the lessons from the Stud Pets / Stud Gear / anime-clip sessions.

Every rule and lesson was kept. Duplicates were merged, contradictions fixed, and project-specific history moved out.

## Files

| File | What | Replaces |
|---|---|---|
| `SKILL.md` | the roblox-game-pipeline skill: the loader | the old skill body |
| `RULES.md` | the owner's rules, grouped (limits, operator, taste, quality, efficiency, memory) | STANDING-RULES.md |
| `PIPELINE.md` | process: sizing, intake, approval, build, running lanes, six-sense review, gates, retro | PIPELINE.md + the process parts of OPERATOR-STATE / CHECK-PLAN |
| `craft/*.md` | 11 deep guides: MODELING, ANIMATION, VFX, WORLD, GUI, AUDIO, GAMEPLAY, SYSTEMS, MONETIZATION, VIDEO, CREATOR-STORE | GUI-QA-GATE.md (now craft/GUI.md) and the scattered craft notes |
| `LESSONS.md` | dated retros + the metric | the lessons buried in OPERATOR-STATE / PIPELINE |
| `templates/STATE.md` | the short "right now" file (under 80 lines) | OPERATOR-STATE.md (about 450 lines) |
| `templates/LANE-BRIEF.md` | the brief + handoff template | ad-hoc briefs |
| `templates/MODEL-SPEC-TEMPLATE.xlsx` | unchanged copy of the owner's model spec | — |
| `tools/oc_products.ps1` | generic version: `-Root` / `-Universe`, an explicit Kind column, the key file inside `try`, a fail log, `-WhatIf` | the ITP-specific version |

## Install on the PC (Winter does this; about 15 minutes)

1. **Back up:** copy `C:\Users\Condo\Documents\ClaudePlugins\` to `ClaudePlugins-backup-<date>\`.
2. **Copy** this folder's contents into `ClaudePlugins\`.
3. **Archive the old files.** Move STANDING-RULES.md, GUI-QA-GATE.md and the old PIPELINE.md into `ClaudePlugins\LOG\old\`.
   - Move OPERATOR-STATE.md and the OVERNIGHT logs into `LOG\` too.
   - Make a fresh `STATE.md` from `templates\STATE.md`, with only what is live right now.
4. **CHECK-PLAN.md:** keep only the active plan. Move finished sections into `LOG\<project>.md`.
5. **The skill:** replace the body of the `roblox-game-pipeline` skill with `SKILL.md`.
6. **Fix the lean-path skill's last line.** It says "never create real products for the owner", which contradicts the owner's 09-29 decision (RULES 1). Change it to "create passes / products for free via Open Cloud; never buy".
7. **Update path references in tools and briefs.** Anything pointing at `GUI-QA-GATE.md` now points at `craft/GUI.md`; `STANDING-RULES.md` → `RULES.md`; `OPERATOR-STATE.md` → `STATE.md`.
8. **Pick one audit-tool name:** keep `tools/gui_audit.luau`. If `interaction_audit.luau` is older, retire it, or note what it still does that gui_audit doesn't.

## The persistent-game-studio plugin

It is a second full operating system, with rules that clash with these (nine Opus roles by default; exact roster counts enforced by hooks).

**Recommendation:**
- This playbook is the default for everything.
- Use `/studio` only when the owner starts a brand-new L-size game and wants its sentinel and evidence machinery.
- When you do, give it a small roster JSON (e.g. lead + engineer + sentinel). RULES 36 (agent counts are ceilings) still applies.
- Never load both for the same project.

## What changed vs the old files (the important ones)

- **Rule 1 restated:** build fast, but correctness-critical code (saves, purchases, security, setup) is tested when built, and every lane ends with its own gate.
- **Team-size rules merged** into one ceiling rule (old rules 5, 16 and 26 contradicted each other).
- **The stale "no passes / products" line removed.**
- **Six-sense review added:** eye (shape), eye (motion), ear, hand, clock, head.
- **New gates:**
  - a feasibility check at intake;
  - the live-server gate;
  - status words kept apart;
  - a diff review after scripted edits;
  - Creator Store packaging rules;
  - every UI state (pending / failed / double-tap);
  - the asset-ownership check for group games.
- **Checks:** event-driven watching instead of constant timed checks, to save usage.
