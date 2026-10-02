# Assessment v2: the pipeline files, the revenue research, and what to improve

Assessed 2 October 2026 (cloud session "Stud Pets / Pet System / Stud Gear / anime clip").

**Read:**
- roblox-game-pipeline (skill), OPERATOR-STATE.md, STANDING-RULES.md, CHECK-PLAN.md, GUI-QA-GATE.md, OVERNIGHT-2026-09-28/29.md, SENT-PHOTOS.txt;
- the Revenue and Stage 1 research, and the Stage 1 template;
- the toolkit: gui_audit.luau (+ selftest, runner example, crops / zoom scripts), oc_upload.ps1, oc_products.ps1, MODEL-SPEC-TEMPLATE.xlsx;
- the persistent-game-studio plugin: SKILL.md, the six reference protocols, marketplace.json, studio.test.mjs (41 tests; the plugin's scripts and role files were not sent).

- PIPELINE.md (section I).

**Not read:** RobloxLibrary/CATALOG.md, the lean-path skill.

The owner's files stay the authority. Everything below is a proposal: add to them, don't replace them.

## Verdict

The system is strong and already learns from mistakes. The rules capture real owner taste, and there are concrete audits (overlap, support, functional surface, GUI gate), kaizen notes, save verification, PID-by-command-line checks and pruning. The biggest wins now are **not** more rules. They are:

0. **Pick one operating system** (section G). The roblox-game-pipeline skill and the persistent-game-studio plugin are two full systems with rules that contradict each other.
1. **Clean the files** so a reload is short and has no contradictions (section A).
2. **Spend less usage on checking** (section B). The weekly limit was hit on 30 Sep and two Roadster lanes died.
3. **A live-game checklist that every game goes through before it goes public**, plus real-player measurement after launch (section C).
4. Use the research **selectively, by project size** (section D).

## A. File hygiene (do first; cheap; helps every future chat)

| Problem | Where | Fix |
|---|---|---|
| Stale hard-limits line: "no passes/products/live IDs" | OPERATOR-STATE line 10 | Replace with rules 2/15/56 wording (passes/products allowed; never spend; never change access). The header date is also stale (27 Sep). |
| Team-size rules contradict each other | STANDING-RULES 5 ("package count / 6"), 16 ("8 agents"), 26 ("ceilings") | Keep 26 as the single rule; reduce 5 and 16 to "see 26"; keep 16's lane roles as an example shape. |
| "Build first, test at the end" vs per-lane audits | Rule 1 vs 37, 47, 51, 55, 57, GUI-QA-GATE | Restate rule 1: *code builds fast with light checks; art, GUI and spatial audits run at the end of each lane that touches them; save / purchase / security correctness is tested when built (cheap fixtures), not only in final QA.* This matches what actually works in the logs. |
| Rule 11 missing; garbled characters (`â€”`, `Â±`) | STANDING-RULES | Renumber, or note "11 retired"; re-save the file as UTF-8. |
| OPERATOR-STATE is about 450 lines of history | The whole file | Split it into **STATE.md**: a short "now" file (under 80 lines: active projects, running lanes, waiting-on-owner, next steps, limits) that is rewritten, not appended. Plus **LOG/<project>.md** for history. The skill reloads STATE.md every compaction. A 450-line reload burns context and buries the current state. |
| CHECK-PLAN keeps finished ITP sections ("ignore below") | CHECK-PLAN.md | Move finished plans to LOG/ (ITP is finished: archive all of it); CHECK-PLAN holds only the active plan. |
| Owner taste is spread over rules 20, 28, 30-57 | STANDING-RULES | Fine as rules. Optionally add a 10-line "taste at a glance" summary at the top for briefs (cartoony, clean, no lookalikes, no grey chips, shine sweeps, things sit on surfaces, hype stays, about 10% less saturation, no flag props, Blender for visible props). |

## B. Spend less usage, with no drop in quality

1. **Event-driven checks instead of clock checks.** Most 10- and 20-minute checks find "alive, healthy", and each one re-reads the big state files. Run one small background watcher per lane. It exits (and wakes the operator) only when one of these happens: the HANDOFF file appears, a READY file appears, no file changes for 15 minutes with flat CPU, the process dies, or the hard-stop time arrives. Keep a long safety-net check (60-90 min). Owner-present spot checks stay as he likes.
2. **Check the plan limit before launching lanes.** This is already a kaizen note (30 Sep 13:08). Make it a launch-checklist line in the skill, not just a log entry.
3. **Short lane briefs, and a short STATE.md** (section A): every lane and every operator turn reads less.
4. **One Play session per batch of checks**: already rule 22. Keep enforcing it.

## C. Live-game checklist (every game, before it goes public)

The owner decides when a game goes public. These checks make it ready when he does.

1. **Verify in a live server, not just Studio.** Some failures only show live:
   - asset permissions in group games (upload with `-GroupId`);
   - StreamingEnabled loading and unloading;
   - analytics events actually reaching the dashboard;
   - real-phone performance (one real-phone check per release; the owner's phone, free).
2. **Measure real players** (free, built in):
   - funnel events from join to the first purchase;
   - economy events on committed currency changes;
   - a few custom milestones;
   - compare D1 and D7 retention after a week of cohorts.

   Persona and bot scores test clarity, not demand. Label them that way.
3. **Purchases:**
   - `GetProductInfoAsync`, not the older `GetProductInfo`;
   - one receipt handler, without mixing `ProcessReceipt` and `BindReceiptHandler` enums;
   - check ownership before granting a pass;
   - a support path that re-grants a missing purchase from the receipt log, without hand-editing DataStores;
   - double-tap and in-flight purchase states in the UI;
   - test with fixtures, never real Robux.
4. **Saves:**
   - every save carries a schema version, and old saves migrate on load;
   - old and new servers running at the same time never corrupt each other's saves;
   - trades and gifts that touch two players' records need a recovery step (one DataStore write is not atomic across records);
   - Studio with API access off plays without saving instead of stalling.
5. **Paid random items:** if a crate or roll is bought with Robux, or with currency Robux can buy:
   - show the odds;
   - gate it with `PolicyService` (`ArePaidRandomItemsRestricted`).
6. **Truthful scarcity:** time-limited or capped labels must be literally true. Never use restarting timers.
7. **Player text:** anything players type that others see goes through `TextService` filtering.

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

0. I (PIPELINE.md clean-up) together with A.
0. G1 (decide pipeline vs studio plugin, and write the decision into both): 10 minutes, owner + operator.
1. A (file clean-up): 30 minutes, operator only.
2. C (live-game checklist) written into PIPELINE.md as a pre-public gate; the analytics events go into the reusable library.
3. B (event-driven watcher) before the next multi-lane night.
4. E notes folded into PIPELINE.md and STANDING-RULES.md (as new rules or lean-path notes).
5. D: the full Stage 1 template only when the owner names the next real full game.

## G. The toolkit and the studio plugin

### G1. Two systems, conflicting rules (the main finding)

| Topic | Pipeline skill / STANDING-RULES | persistent-game-studio plugin |
|---|---|---|
| Crew size | Counts are ceilings; "down to the operator alone" (rules 16, 26; skill section 0) | Nine Opus roles by default; a package roster is an **exact** count that hooks enforce |
| Usage | Rules 22-25 and lean-path: least usage; the weekly limit was hit on 30 Sep | Every role on the top model at medium effort; "never switch to a cheaper model"; a full team each session |
| State | OPERATOR-STATE.md, CHECK-PLAN.md, overnight logs (hand-written markdown) | `.game-studio/` canonical JSON + ledgers, written only by scripts |
| Done | Operator review + GUI gate + owner (rule 42) | Sentinel ACCEPTED + evidence on disk + `complete-check` |

If both load in the same session, the operator gets two answers to "how many agents?" and "where is the truth?".

**Proposal:**
- Pipeline skill = master and default for packs, kits, fixes and live-game work.
- The studio plugin only for a new full game, started by the owner with `/studio start`.
- Inside it, rule 26 still caps the roster (use a smaller roster JSON, e.g. lead + engineer + sentinel), and STANDING-RULES are imported as canon.
- Add one line to each: "the other system defers to this rule when both apply".

### G2. What the plugin gets right, to copy into the pipeline either way

- **Status lifecycle with evidence:** BACKLOG ... READY_FOR_SENTINEL → ACCEPTED → DONE. This is the status separation from section D, already built.
- **Independent acceptance:** the builder never accepts its own work. The pipeline's version is "operator reviews lanes", but the operator also builds in the endgame takeover (skill section 5). Then a fresh subagent should check against the rules.
- **Measurable acceptance criteria:** a command, a threshold or exact steps, each with an evidence kind.
- **Kept failures:** FAILED / HARMFUL strategies stay listed so they aren't retried. The pipeline's kaizen notes in OPERATOR-STATE do this informally and get buried.
- **Memory limit:** 120 lines, highest value first. The same reason as the STATE.md split in section A.
- **Licence intake record** before any external asset (source, author, licence, resale rights).

### G3. GUI audit tools

- **Strong:**
  - 18 check ids covering every defect class in GUI-QA-GATE, plus hover growth, cramped text, small text, knobs and icon wash;
  - a self-test with a CLEAN control that must give 0 findings;
  - approvals that need a written reason.

  This is better than most studios have.
- **Gap 1, viewport sizes:** the gate says 1366x768 AND 844x390, but the audit measures whatever the current viewport is. Make the runner record the viewport size in the report header and fail if it doesn't match the label.
- **Gap 2, the self-test runs only in Play:** run it once per Studio session before trusting a 0-findings report (a tool edit can silently break a check).
- **Gap 3, stale approval patterns:** they match by path, so a renamed element loses its approval (noisy) or a broad pattern hides a new real overlap (dangerous). In each report, list approvals that matched nothing, and anything that matched more than about 3 elements.

### G4. Open Cloud scripts

- **Good:**
  - the key comes only from the user env var and is passed through a temp header file that is deleted in `finally`;
  - `oc_products` skips ids it already has, so a re-run doesn't duplicate products;
  - `oc_upload` supports `-GroupId`.
- **Fix in `oc_products.ps1`:**
  - The key file is written *before* the `try`, so an error between write and `try` leaves it on disk. Move the write inside the `try`.
  - "Pass vs product" is decided by row number (`N <= 9`). Adding a 10th pass silently creates a dev product. Put an explicit Kind column in MORNING-PRODUCTS.md.
  - Write the ids to `PRODUCT-IDS.json` after each item (already done), and also log the FAIL lines to a file. A re-run then shows what failed without scrolling.
- **Group games:** `oc_upload` defaults to the owner's **user** id. For a group-owned game, pass `-GroupId`, or the asset needs permission granted (meshes can be invisible on live). Make group the default whenever the target universe is group-owned.

### G5. Model spec workbook

Very good: every acceptance row cites the rule it came from, and the gate is a formula.

Two additions:
- an **"Verified in live server"** row for anything in a group or public game (asset permission problems only show live);
- a **"Studio-only primitives OK?"** row for kits sold on the Creator Store, since rule 45 (Blender only) can over-apply to simple functional kit parts like stands and pads.

The same format would work as **GUI-SPEC** and **SYSTEM-SPEC** templates (save / purchase / remote contracts + the test that proves each).

## H. A second opinion (Gemini), sorted

Most of it restates the same Revenue / Stage 1 research, so it is not independent confirmation. Sorted for general games:

| Point | Verdict |
|---|---|
| Recovery: stuck players, missing purchases, rollback | **Adopt:** in section C3. |
| Save migration, mixed-version servers, multi-record trades | **Adopt:** in section C4. |
| Paid random items + PolicyService | **Adopt:** in section C5. |
| Studio isn't live (analytics, streaming, phones) | **Adopt:** in section C1. |
| UI states: loading / empty / error / pending / cancelled, double-taps, interrupted tweens, stacked modals | **Add to GUI-QA-GATE.** Rule 37 covers hover / disabled / owned / locked only. |
| Prices or countdowns baked into images | **Add to GUI-QA-GATE:** dynamic text is always a TextLabel. |
| Economy outliers (a 1% drop is still 0/100 for 36.6% of players) | **Adopt in the economy model** (section D): report dry streaks and the 90th percentile, not only averages. |
| Core loop alone isn't the game: multi-session goals, return reasons, content runs out | **Add to the full-game brief:** what brings a player back tomorrow, and when content runs out. |
| Overlap screening, collision, travel time | Already covered by rules 47, 55 and 57. Add one note: never "fix" clipping by turning collision off broadly. |
| Bots aren't real demand; statuses kept separate | Already covered (section D statuses). |
| Earnings accounting, localization, near-empty servers | Later. Matters at real revenue or international scale. |

## I. PIPELINE.md

It is the best of the files: the overnight "what made this efficient" section and the dated hindsight notes are real, reusable lessons. Its problems are the same as the other files: it was appended to, never rewritten.

### Contradictions and stale text

| Where | Problem | Fix |
|---|---|---|
| Header | "Read with STANDING-RULES (rules 1-19)"; there are 57 | "Read with STANDING-RULES" (no range). |
| Section 2, team shape | Still says "8 agents: lead + 4 ART + 3 CODE"; the Crew size section at the bottom overrides it | Delete section 2's count; keep the 7 lane roles as a menu to pick from; move Crew size up into its place. |
| Section 3 + section 6 | "One big QA at the end" vs the per-lane gates that actually worked | Same restatement as rule 1 (section A). |
| Section 4, models | "Optional Hunyuan3D-2 base mesh" vs the model spec's "never shipped geometry in sale packs" | Add "shape guide only; never shipped in sale packs". |
| Section 5 vs the overnight section | "Hourly" art checks vs "every 5 min awake / 25-30 min overnight" | One cadence, event-driven where possible (section B). |
| Three GUI checklists | The "UI/art QA gate" block here, GUI-QA-GATE.md and rules 31-41 say similar things differently | Keep GUI-QA-GATE.md as the one checklist (merge any line it lacks), and replace the PIPELINE block with "every UI brief includes GUI-QA-GATE.md". |
| Three audit-tool names | `interaction_audit.luau` (here), `gui_audit.luau` (GUI-QA-GATE), LIB-UI-08 (skill) | Use one name everywhere, and say whether the old one is retired. |

### Structure

The hindsight notes sit between sections in date order (Veilblade notes are in the middle of Crew size). A lane brief can't pull "just the mesh lessons" without reading everything. Regroup them under topic headings:
- Studio / MCP / agents;
- Meshes and import;
- VFX;
- GUI;
- Saves and backups;
- Uploads and Open Cloud;
- Video;
- Launch and monitoring.

Keep the date on each line. Then a brief says "include PIPELINE: Meshes, GUI".

### What is still missing (from sections C and E)

None of these are in PIPELINE.md yet:
- offline-built WeldConstraint offsets;
- Creator Store packaging rules;
- Studio-only stalls (DataStore with API access off, `WaitForChild` timeouts);
- the video and cinematic route choice;
- a diff review after scripted edits;
- the live-game checklist (C).

Section 6's "Released is not done until 0 open defects and a clean Play boot" should become: **0 open defects, a clean Play boot, and (for anything live) the section C checks done in a live server.**
