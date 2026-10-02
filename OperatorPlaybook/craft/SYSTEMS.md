# SYSTEMS: code architecture, saves, remotes, security, performance, tests

## Architecture

- **Start from the library:** RobloxLibrary/CATALOG.md + LAYOUT.md.
  - Server backbone: LIB-CORE-01 + DATA-01/02 + COMM-01/02 + NET-01 + SEC-*.
  - UI kit: LIB-UI-01..08. Presentation: LIB-VFX-01/02 + AUD-01. QA: LIB-TEST-01.
  - Fix the library's must-fix list on first reuse; send improvements back after shipping.
- **Rojo** project; source on disk is the truth; git at the project root.
- **Linting:** selene + StyLua. `--!strict` where practical.
- **The server owns all state.** The client renders and requests. Shared rules (prices, unlock checks, formulas) live in ONE `shared/` module used by both sides, so displays never drift from the server.
- **Derive lists from the source of truth.** Schemas, whitelists and icon maps are built from the catalog by kind, never hand-listed. (A hand-listed enum silently dropped new upgrades.)
- **Config is data:** a catalog / config table drives items, tiers and prices, so a balance change is one edit.

## Saves

- **Session-locked profiles** (the library DATA module, or a proven open-source profile library, licence checked). Use `UpdateAsync`, never `SetAsync`, for player data.
- **Schema version** in every save, with a migration function per version bump. Old saves migrate on load; never wipe.
- **Mixed versions:** during an update, old and new servers both run. New fields must be optional, and an old server must not strip fields it doesn't know.
- **Autosave** on an interval and on leave, plus `game:BindToClose` with a time budget.
- **Multi-record changes** (trades, gifts) aren't atomic across two players' records. Use an escrow / journal step that can be replayed or rolled back.
- **In Studio with API access off:** detect it (`RunService:IsStudio()` + a failed first call), warn, and play without saving. Never stall the game.
- **Never edit live data by hand.** Support actions (re-grant, restore) go through an admin tool that logs who did what.

## Remotes and security

- **Few remotes;** each one has a schema:
  - type and range checks;
  - rate limits per player;
  - a sequence / nonce check where replay matters.
- **Never trust the client:**
  - for ownership (check `UserOwnsGamePassAsync` before granting a pass);
  - for positions (server sanity checks / snap-back);
  - for timing (server-side minimum action times);
  - for answers (don't send answer-deciding data before it's needed).
- **Bounded everything:** logs, tables and queues built from client input have caps.
- **Bot-aware:** a violation score with thresholds (flag → off leaderboards → kick at a high score that normal players never approach).
- **Debug hooks only in Studio;** tests are stripped from live builds.
- **Text players type** that others see goes through `TextService` filtering.
- Re-run the security scan after every server or remote change.

## Performance

- **Measure first:** a baseline with the feature paused, then with it on. MicroProfiler for spikes.
- **Instance churn** (create / destroy per frame or per hit) is the usual spike. Pool parts, emitters and GUI.
- **Write properties only on change;** cache expensive lookups (e.g. the camera body-hide was 35x faster cached).
- **Distance-cull** effects and animations; throttle per-frame work on far objects.
- **Phone budget:** test on Low graphics and a real phone. Watch memory over a 20-minute soak (it should be flat).
- **Unfocused Studio** runs at about 15 fps. Measure only when focused.

## Tests

- **Offline harness** (Lune + fake services with a virtual clock) for logic: saves, purchases, economy, setup. Fast, and runs on every change.
- **In-Studio test runner** for engine-dependent behaviour; the full suite before every handoff.
- **Real input tests** with a **control:** hold W and measure the distance; press the real button path (the remote with its schema), not a debug shortcut. The control proves the check can fire.
- **Siblings:** when adding one item of a kind, exercise every sibling of that kind once.
- **A failing old test** is either a regression (fix the code) or a stale expectation (update it with the reason and date). Never delete it.
- **Review the diff after any scripted or multi-block edit,** before testing. A large automated edit once deleted working code.

## Regression sweep (skill regression-sweep)

Before editing, map the blast radius:
- readers of the value;
- hand-written lists;
- clamps;
- displays;
- dependent features;
- on/off state pairs;
- asset ownership.

After editing, re-check each item. Write the "impacted:" list into CHECK-PLAN before coding.

## Studio and drop-in traps

- `WaitForChild(optional, timeout)` in a hot path freezes for the full timeout each time. Use `FindFirstChild` for optional objects.
- `fs.readFile` inside Lune coroutines yields badly. Preload sources.
- Lune's `CFrame.lookAt` can return NaN or a wrong facing when pointing straight up or down. Build frames with `CFrame.fromMatrix`.
- A disabled server script in a package looks like "nothing works". Check the Enabled flags in the built file.
