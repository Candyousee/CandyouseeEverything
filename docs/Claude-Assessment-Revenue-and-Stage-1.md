# Assessment: Revenue research + Stage 1 template vs. the current pipeline

Assessed 2 October 2026 from the cloud session that built Stud Pets, the Stud Pet System, Stud Gear and the anime clip.
Compared against: `roblox-game-pipeline` (skill), `lean-path` (skill), and what actually happened on those four projects.
**Not seen:** OPERATOR-STATE.md, STANDING-RULES.md, PIPELINE.md, the library CATALOG and the MODEL-SPEC template (they live on the PC). Re-check every point below against them before changing anything; they stay the authority.

## Verdict in one paragraph

The research is accurate and careful: it doesn't invent revenue, it separates simulation from real evidence, it cites current Roblox docs, and it has good corrections (status separation, receipt contracts, map gate, paid-random-item policy). The main risk is **weight**. Used as written for every job, the Stage 1 template is far bigger than most of the owner's actual work (Creator Store packs and kits), and it would burn usage and delay results, which contradicts `lean-path`. Adopt it **by tier**, keep the existing one-review pipeline, and add the handful of lessons this session learned the hard way. The research has no way to know those.

## 1. Tier it (the most important change)

| Tier | Examples | What to require |
|---|---|---|
| **T0: asset pack** | Stud Pets 200 | 1-page brief, art references, one approved hero asset, in-Studio import check, store packaging rules (section 4) |
| **T1: drop-in system / kit** | Pet System, Stud Gear, Obby Kit | T0 + contracts for save / purchase / security / setup, an offline simulation harness, and the **Studio verification gate** (section 3) |
| **T2: full game** | a real experience the owner wants to grow and earn from | the full Stage 1 template, map correctness gate, economy model, analytics and commerce plan |

Pick the tier at intake and say it in one line, the same way the crew size is chosen. Never apply T2 paperwork to a T0/T1 job.

## 2. Already covered: keep as is

- No money / Robux / paid tools; never publish or change access (hard limits).
- One front-loaded owner review; brief + art bible; hero asset first; art review loops; two speeds (code fast, art reviewed).
- Reuse library first; crew size is a ceiling; serialize Studio/GPU work.
- After shipping: update the library and lessons.

The research itself says to preserve these. Agreed.

## 3. Adopt now (high value, low cost)

1. **Status separation.** Report five separate states: *spec complete / implemented / offline tests pass / verified in Studio by a human or Studio MCP / commercial results measured*. This session repeatedly said "works" based on offline tests, and the owner then found it broken in Studio (see section 5).
2. **Value classes**: LOCKED / DERIVED / TARGET / ILLUSTRATIVE / UNKNOWN on exact numbers. Cheap, and it stops guessed values from looking like decisions.
3. **Zero-spend purchase testing** with a receipt contract (dedupe, durable grant, retry, reconnect) proven by **fixtures**, never by real purchases. "Test mode" items can still cost real Robux.
4. **Dynamic prices only.** Never paint a price into an image. Use the current `GetProductInfoAsync`. **Action:** Stud Gear's stand labels still call the older `MarketplaceService:GetProductInfo` (`StudGear/src/client/StudGearClient/init.client.luau:47`); switch it.
5. **Paid random items policy.** If an egg can be bought with Robux, or with a currency that Robux can buy, the numerical odds must be disclosed and policy handling applies. The Stud Pet System already shows odds boards. Keep that, and note in its README that buyers who sell Coins for Robux take on the policy duties.
6. **Map correctness gate** for T2 games (zero known unintended overlaps, z-fighting, blocked routes, unsafe spawns in the tested matrix). For T0/T1 packs the equivalent is "**drops in tidy**": no pieces piled at the origin, nothing overlapping the buyer's map.
7. **Honest metrics vocabulary**: gross spend ≠ creator proceeds ≠ eligible Earned Robux ≠ cash. Use it in any sales talk with the owner.

## 4. Trial only when there is a real need

- A small Python economy model: worth it the first time a game has currencies, egg odds or offline income (quantiles and dry streaks, not averages).
- NetworkX route graphs: only for maps with many zones or branching routes.
- Native Experiments / price optimization: only with real traffic (the docs say about 1,000 DAU for experiments, and about 60,000 transactions in 30 days for price optimization). Not relevant until a game has players.
- Rewarded ads: only after eligibility (public, verified, about 2,000 monthly visitors).

## 5. Skip by default

OR-Tools, Penpot, DuckDB (no data to query yet), giant procedural maps, a second UI styling system, paid or unverified skill bundles, and any new tool that duplicates the installed stack. Keep the research's own "one-task trial before adoption" rule.

## 6. What the research misses: lessons from real failures this session

These matter more than anything above, because they actually cost the owner time.

1. **Studio verification gate (T1+).** Offline tests and Blender previews do not prove in-game behaviour. Bugs that only showed up in Studio:
   - **WeldConstraints built offline (Lune/rbxm) lose their offsets**, so every piece snaps onto Part0. That piled the coils, grapple and jetpack into the hand and cost about 4 rounds of "redesigns". Build welded models with `Weld` + stored `C0`.
   - DataStore calls stall in Studio when API access is off (load retries, then kick). Detect `RunService:IsStudio()` and play without saving.
   - `WaitForChild("PlayerModule", 2)` added a 2-second freeze to every hatch. Never wait on optional objects in a hot path.
   - Buyers drag whole folders (`1_PutInReplicatedStorage` ends up *inside* ReplicatedStorage). Scripts must find their folders anywhere and show on-screen setup errors.

   **Rule:** nothing is "done" until it has been seen working in Studio (Studio MCP solo Play on the PC, or the owner's screenshot). Say "untested in Studio" plainly until then.
2. **Creator Store packaging rules.** No self-installing or auto-moving scripts (flagged as "Misusing Roblox Systems"). Plain numbered folders, a README ModuleScript, forgiving lookups, tidy template layout, server script enabled but inert until set up. Test the pack by doing the buyer's setup in an empty place before every upload.
3. **Owner taste file (`TASTE.md`).** Record concrete likes and dislikes with quotes, and cite it in every art bible. From this session:
   - wants stud style, but each item clearly distinct ("they just needed to look different")
   - generic designs are rejected
   - sound effects only if genuinely good ("get rid of the sound effects they arent good")
   - no purple backgrounds or spiral rays
   - confetti in the rarity colours
   - classic Roblox gear look (coil wrapping the arm)
   - hates clutter and things floating or clipping
4. **Feasibility check against the quality bar, before building.** The anime clip was built with code poses, which can't reach anime-quality motion, and the owner called the result awful. If the quality bar needs hand-keyed animation, real art or an editor (CapCut/AE), say so at intake and plan that route instead.
5. **Edit safety.** A large scripted edit silently deleted working code (the confetti rewrite removed the pet / shard / label code). After any automated or multi-block edit, review the diff before testing.
6. **Session hygiene.** One chat per project or task, with OPERATOR-STATE and a handoff updated at milestones. This session ran through several compactions and showed the usual drift: re-checking settled things, and edit slips.

## 7. Suggested next steps for the other Claude

1. Merge sections 1, 3 and 6 into PIPELINE.md and STANDING-RULES.md (keep the originals' authority and wording; add, don't replace).
2. Create `TASTE.md` from 6.3 and link it from the art-bible step.
3. Add the offline-simulation harness pattern (fake services + virtual clock, as in `StudPets/build/test_server_sim.luau` and `StudGear/build/test_gear_sim.luau`) to the library as the T1 test standard. It must always be followed by the Studio gate.
4. Fix `GetProductInfo` → `GetProductInfoAsync` in Stud Gear before uploading it.
5. Use the full Stage 1 template only when the owner names an actual T2 game.
