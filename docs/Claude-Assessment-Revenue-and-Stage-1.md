# Assessment v2: the pipeline files, the revenue research, and what to improve

Assessed 2 October 2026 (cloud session "Stud Pets / Pet System / Stud Gear / anime clip").

**Read:**
- roblox-game-pipeline (skill), OPERATOR-STATE.md, STANDING-RULES.md, CHECK-PLAN.md, GUI-QA-GATE.md, OVERNIGHT-2026-09-28/29.md, SENT-PHOTOS.txt;
- the Revenue and Stage 1 research, and the Stage 1 template.

**Not read:** PIPELINE.md and RobloxLibrary/CATALOG.md. Check sections C and D against them.

The owner's files stay the authority. Everything below is a proposal: add to them, don't replace them.

## Verdict

The system is strong and already learns from mistakes. The rules capture real owner taste, and there are concrete audits (overlap, support, functional surface, GUI gate), kaizen notes, save verification, PID-by-command-line checks and pruning. The biggest wins now are **not** more rules. They are:

1. **Clean the files** so a reload is short and has no contradictions (section A).
2. **Spend less usage on checking** (section B). The weekly limit was hit on 30 Sep and two Roadster lanes died.
3. **Fix ITP's live problems and start measuring real players.** ITP went PUBLIC on 30 Sep, so real data now beats persona scores (section C).
4. Use the research **selectively, by project size** (section D).

## A. File hygiene (do first; cheap; helps every future chat)

| Problem | Where | Fix |
|---|---|---|
| Stale hard-limits line: "no passes/products/live IDs" | OPERATOR-STATE line 10 | Replace with rules 2/15/56 wording (passes/products allowed; never spend; never change access). The header date is also stale (27 Sep). |
| Team-size rules contradict each other | STANDING-RULES 5 ("package count / 6"), 16 ("8 agents"), 26 ("ceilings") | Keep 26 as the single rule; reduce 5 and 16 to "see 26"; keep 16's lane roles as an example shape. |
| "Build first, test at the end" vs per-lane audits | Rule 1 vs 37, 47, 51, 55, 57, GUI-QA-GATE | Restate rule 1: *code builds fast with light checks; art, GUI and spatial audits run at the end of each lane that touches them; save / purchase / security correctness is tested when built (cheap fixtures), not only in final QA.* This matches what actually works in the logs. |
| Rule 11 missing; garbled characters (`â€”`, `Â±`) | STANDING-RULES | Renumber, or note "11 retired"; re-save the file as UTF-8. |
| OPERATOR-STATE is about 450 lines of history | The whole file | Split it into **STATE.md**: a short "now" file (under 80 lines: active projects, running lanes, waiting-on-owner, next steps, limits) that is rewritten, not appended. Plus **LOG/<project>.md** for history. The skill reloads STATE.md every compaction. A 450-line reload burns context and buries the current state. |
| CHECK-PLAN keeps finished ITP sections ("ignore below") | CHECK-PLAN.md | Move finished plans to LOG/; CHECK-PLAN holds only the active plan. |
| Owner taste is spread over rules 20, 28, 30-57 | STANDING-RULES | Fine as rules. Optionally add a 10-line "taste at a glance" summary at the top for briefs (cartoony, clean, no lookalikes, no grey chips, shine sweeps, things sit on surfaces, hype stays, about 10% less saturation, no flag props, Blender for visible props). |

## B. Spend less usage, with no drop in quality

1. **Event-driven checks instead of clock checks.** Most 10- and 20-minute checks find "alive, healthy", and each one re-reads the big state files. Run one small background watcher per lane. It exits (and wakes the operator) only when one of these happens: the HANDOFF file appears, a READY file appears, no file changes for 15 minutes with flat CPU, the process dies, or the hard-stop time arrives. Keep a long safety-net check (60-90 min). Owner-present spot checks stay as he likes.
2. **Check the plan limit before launching lanes.** This is already a kaizen note (30 Sep 13:08). Make it a launch-checklist line in the skill, not just a log entry.
3. **Short lane briefs, and a short STATE.md** (section A): every lane and every operator turn reads less.
4. **One Play session per batch of checks**: already rule 22. Keep enforcing it.

## C. Inspect the Package is LIVE: priorities that beat new features

1. **Fix the parked bug now.** Belt parcels are invisible on live until they reach the station (likely 250 user-owned meshes under Asset Privacy in a group-owned game). On a public game this is player-facing. Fix: re-upload the meshes with `-GroupId` (the tool supports it) and `ApplyMesh` onto the templates. Then verify in a live server, not Studio.
2. **Start measuring real players** (free, built in; this is the research's most useful point for ITP right now):
   - Funnel events: join → first parcel → tutorial done → first license → first purchase prompt → first purchase.
   - Economy events on committed coin changes.
   - A few custom events (shift done, licence bought, boss cleared).
   - Then compare D1 and D7 retention and the drop-off points after a week of cohorts.

   The FUN1 persona score (8.5) was correctly caveated. Real cohorts replace it now.
3. **Audit prices and purchases against current APIs:**
   - `GetProductInfoAsync`, not the older `GetProductInfo`;
   - receipt handling: ProcessReceipt vs BindReceiptHandler; don't mix the two decision enums;
   - "test mode" products can still spend real Robux, so test with fixtures.
4. **Keep scarcity truthful.** The "THIS WEEK" label and the hard-capped legends are fine if they are literally true. Never use restarting timers or fake "last chance".

## D. The research and the Stage 1 template: adopt by project size

| Project size | Use |
|---|---|
| Asset / model pack, GUI kit | The current pipeline, plus "drops in tidy" (nothing piled at the origin) and the store packaging rules (E2). No Stage 1 template. |
| Drop-in system or kit | Plus contracts for save / purchase / security / setup, and an offline test harness with fake services. |
| Full game | The full Stage 1 template: spatial canon, economy model, analytics plan, commerce state machine, map gate. |

**Adopt for all:**
- **Status words kept separate:** spec complete / built / tests pass / verified in Studio / verified live / human-liked / earning.
- **Value labels:** LOCKED / DERIVED / TARGET / UNKNOWN.

**Already covered by the owner's rules, keep them:** the map gate (rules 47, 55, 57), the GUI states (37, 41, GUI-QA-GATE), security (SEC2), truthful offers (43, 56).

**Trial when needed:**
- a Python economy model for the next game with currencies or odds;
- NetworkX only for complex maps;
- native Experiments only past about 1,000 DAU.

**Skip:** OR-Tools, Penpot, DuckDB for now, price optimization (needs about 60k transactions in 30 days), rewarded ads (needs about 2,000 monthly visitors).

## E. Lessons from this session that the files don't have yet

1. **Lune / Rojo-built welded models:** `WeldConstraint`s saved offline lose their offsets, and every piece snaps onto Part0. Use `Weld` with a stored `C0`. (This cost about 4 rounds on Stud Gear.)
2. **Creator Store packaging:**
   - no self-installing or auto-moving scripts (flagged "Misusing Roblox Systems");
   - numbered drop-in folders, plus a README ModuleScript;
   - scripts find their folders even when buyers drag the whole folder in;
   - on-screen setup errors in Studio;
   - a tidy template layout.

   Test the buyer's setup in an empty place before every upload.
3. **Studio-only stalls:** DataStore with API access off (detect `IsStudio`, then play without saving), and `WaitForChild(optional, timeout)` in a hot path (a 2-second freeze every hatch).
4. **Video and cinematic work is a repeat weak spot.** ITP TikTok v1 and take 3 were rejected; the procedural anime clip was rejected. What the logs show works:
   - real gameplay capture;
   - validated camera clearance;
   - strict frame-sheet review before sending.

   Code-posed character animation is never at "anime" quality; hand-keyed or retargeted animation is needed (as with Veilblade's Mixamo + polish).

   **Rule:** pick the route that can reach the bar at intake. Never send a video with known flaws.
5. **Large automated edits can delete working code.** Review the diff after any multi-block scripted edit, before testing.

## F. Suggested order

1. A (file clean-up): 30 minutes, operator only.
2. C1 (live parcel bug) and C2 (analytics events) on ITP.
3. B (event-driven watcher) before the next multi-lane night.
4. E notes folded into PIPELINE.md and STANDING-RULES.md (as new rules or lean-path notes).
5. D: the full Stage 1 template only when the owner names the next real full game.
