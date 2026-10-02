# LESSONS: dated retros (the story behind the rules)

Format, one entry per owner correction or real miss:

`date | what broke | class (BRIEF / REVIEW / TOOL / TIMING / TASTE) | fix | where it's written now`

Once a lesson changes how work is done, the fix lives in RULES.md or a craft guide. This file keeps the story, so a rule's reason isn't lost.

**Metric** (the trend must go down): `owner-found defects per session | restarts | idle minutes`
- 2026-09-28/29 (ITP overnight): high | several | about 18 min lost between a handoff and a check

## Carried over from 2026-09-27 → 10-01

| Date | What broke | Class | Fix | Where now |
|---|---|---|---|---|
| 09-27 | Agents can't run the 3D Importer; skinned local .mesh crashed Studio | TOOL | EditableMesh route; test on a 2-bone bar | MODELING |
| 09-28 | Procedural splashes wasted 2 passes | REVIEW | FLUX for organic shapes | VFX |
| 09-28 | 70 ms spikes blamed on scripts; it was instance churn | TOOL | paused baseline first | VFX, SYSTEMS |
| 09-28 | Skinning faults guessed for 2 rounds | TOOL | read the bind pose and diff it first | MODELING |
| 09-28 | "Lag" was an unfocused Studio window | REVIEW | measure focused only | SYSTEMS |
| 09-28 | Owner kept finding small UI issues | REVIEW | the GUI gate + 2x crops | GUI |
| 09-28 | Wrong PIDs: kills missed, duplicate lanes | TOOL | PID by command line | RULES 42, PIPELINE 5 |
| 09-29 | Primitive-part models (brief didn't say Blender) | BRIEF | briefs name the tool | RULES 17, LANE-BRIEF |
| 09-29 | Pets / NPCs / hands missed by the Blender sweep | REVIEW | the sweep lists every model class | MODELING |
| 09-29 | "Shine" misread as static gloss | TASTE | sliding sweep only | GUI |
| 09-29 | Gantry feet overhung desk corners | TOOL + REVIEW | support audit, low back-corner shots | WORLD |
| 09-29 | Rail bars across a belt | TOOL | functional-surface audit | WORLD |
| 09-29 | A TikTok was sent with 2 known flaws | REVIEW | never send known flaws | RULES 13, VIDEO |
| 09-29 | A rejected tool call still launched a lane | TIMING | verify nothing started after a rejection | RULES 8 |
| 09-29 | Creator Hub blocked by the safety check | TOOL | click-list for the owner; Open Cloud later | RULES 5, MONETIZATION |
| 09-29 | A pass was granted without an ownership check | REVIEW | `UserOwnsGamePassAsync` first | SYSTEMS, MONETIZATION |
| 09-30 | Weekly plan limit hit; 2 lanes died | TIMING | check the limit before launching | RULES 38 |
| 09-30 | A hand-listed SCHEMAS enum dropped new upgrades | TOOL | derive lists from the catalog | SYSTEMS |
| 09-30 | Couldn't move after leaving a mode | REVIEW | restore state pairs; real input test | GAMEPLAY, SYSTEMS |
| 09-30 | Group move: audio silent, meshes invisible live | TOOL | upload with `-GroupId`; the live gate | PIPELINE 7, AUDIO |
| 10-01 | Offline WeldConstraints collapsed onto Part0 | TOOL | `Weld` + C0 | MODELING |
| 10-01 | Store package scripts missing when folders were nested | TOOL | find folders anywhere; on-screen errors | CREATOR-STORE |
| 10-01 | 2 s hatch freeze from `WaitForChild(optional, 2)` | REVIEW | `FindFirstChild` for optional objects | SYSTEMS |
| 10-01 | A scripted edit deleted working code | REVIEW | review the diff after scripted edits | SYSTEMS |
| 10-01 | The procedural anime clip was rejected | BRIEF | feasibility check at intake | PIPELINE 2, ANIMATION, VIDEO |
