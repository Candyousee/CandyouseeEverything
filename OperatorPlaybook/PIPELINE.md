# PIPELINE: how Winter runs any project, from idea to shipped

This file covers the process. The craft detail lives in `craft/`, one guide per discipline. A lane brief includes only the craft guides that lane needs.

| Guide | Covers |
|---|---|
| craft/STYLE.md | **every game:** finding the game's style, the owner's taste constants, style profiles (stud, cartoony, anime, realistic, low-poly) |
| craft/MODELING.md | props, items, characters, pets, vehicles, environment meshes, textures |
| craft/ANIMATION.md | rigs, character animation, procedural motion, cameras for cutscenes |
| craft/VFX.md | particles, beams, trails, flipbooks, impacts, auras, screen effects |
| craft/WORLD.md | maps, level layout, lighting, atmosphere, colour grade, streaming |
| craft/GUI.md | HUD, shop, modals, icons, states, the GUI gate |
| craft/AUDIO.md | SFX, music, voice, mixing |
| craft/GAMEPLAY.md | core loop, feel, progression, economy, onboarding, retention |
| craft/SYSTEMS.md | code architecture, saves, remotes, security, performance, tests |
| craft/MONETIZATION.md | passes, products, receipts, pricing, Open Cloud, analytics, live ops |
| craft/VIDEO.md | trailers, TikToks, showcase clips, cinematics |
| craft/CREATOR-STORE.md | selling models, kits and systems on the Creator Store |

---

## 1. Size the project first (decides everything below)

| Size | Examples | Spec | Crew (ceiling) |
|---|---|---|---|
| **S: asset** | a model pack, an icon set, one VFX, a fix | 5-line brief + the MODEL-SPEC sheet for models | operator alone, or + 1 focused agent |
| **M: kit / system** | a GUI kit, a pet system, a gear pack, a vehicle | 1-page brief + contracts (save, purchase, setup) + an offline test harness | operator + 1-2 |
| **L: full game** | anything players live in | Stage 1 spec: loop, economy model, map plan, commerce, analytics, retention | lead + 2-4 lanes, grown only when a lane is blocked by workload |

Agents that share one GPU, one Studio or one Blender just queue. Run those serially. A second lane may write NEW files offline and integrate after the first lane's handoff.

## 2. Intake (≤ 15 minutes)

1. **Read** the owner's references and package (private, RULES 10).
2. **Judge the idea** (RULES 12): agree / change / disagree, plus a better version if there is one. Expand seeds into one streamlined system (craft/GAMEPLAY.md section 1).
3. **Market check (about 10 minutes, games and store products):**
   - what's trending on the Roblox charts and the Creator Store right now;
   - how crowded this genre is, and how good the top entries are;
   - what players complain about in the top games (reviews, comments, video comments);
   - the gap we fill.

   Write it into GAME-PLAN section 0. If the market says no, tell the owner before planning further.
4. **Online reference research:** the best examples of this game's style and genre, saved to ART/refs/ with URLs. Plus the TASTE.md INDEX lines for the categories this project touches.
5. **Feasibility check against the quality bar.** For each hero deliverable, name the route that can actually reach top-tier quality. If no free route reaches it, say so before building, not after. Examples:
   - code-posed animation can't reach "anime" quality; it needs Mixamo + polish, or hand-keyed animation;
   - procedural splashes lose to FLUX frames.
6. **Toolchain: the best tool for the job, always.**
   - Winter has access to ANY free tool or anything on the owner's PC.
   - For each part, find the best free tool (web-search if not verified in the last month: quality, licence, export formats).
   - **Install it if it's missing.**
   - Tell the owner in a small table: part → tool → why it's the best free option → any licence catch.
   - Never default to what's already installed if something free is better.
7. **Reuse:** check RobloxLibrary/CATALOG.md and D:\AI\STACK.md. Never rebuild what works.
8. **Check the usage meter / plan limit** before committing to a multi-lane plan.

## 3. Plan the game: the one approval round

**Nothing is built until the game is planned and the owner approves the plan.** Planning is the cheapest place to make the game great: a weak loop or bad monetization found here costs minutes; found after building, it costs days.

- **GAME-PLAN.md** (templates/GAME-PLAN.md), for every game:
  - the pitch and the best games in the genre studied;
  - the **core loop** spelled out second by second, and why it's fun the 50th time;
  - a **minute-by-minute paper playthrough** (first 30 s, first minute, 3 / 5 / 20 minutes, 1 hour, day 2, day 7);
  - progression;
  - the **monetization plan** (every pass and product, price, why it's worth it);
  - the economy numbers;
  - the build plan;
  - **Winter's honest opinion**, including what should change.

  If any section can't be filled in, the game isn't understood yet: fix the plan, not the build. Kits and assets use the short version: what it does, how a buyer uses it, why it beats the alternatives.
- **STYLE-SHEET.md** (templates/STYLE-SHEET.md + craft/STYLE.md): this game's look in the owner's taste.
- **Brief** (1-2 pages, for the lanes):
  - the core loop and feel;
  - exact numbers;
  - scope and non-goals;
  - platforms;
  - hero assets;
  - crew and why;
  - risks.
- **Art bible** (part of the style sheet): 5-10 target images (the owner's references + local FLUX / SDXL / Qwen frames). It also sets:
  - the palette (≈10% under first instinct);
  - the shape language;
  - the material rules;
  - the lighting target.
- **Spec sheets:**
  - MODEL-SPEC.xlsx per hero model;
  - the GUI concept (HUD + shop front + one modal);
  - the economy table for L-size projects.

The owner approves once: plan + style sheet + brief + art bible. Start only when he says it's final (RULES 11). If he asks for something during the build that doesn't fit the plan or won't make the game better, say so first (RULES 12).

## 4. Build: two speeds, gates per lane

- **Code:**
  - Build fast with light checks: compiles, runs, one smoke test.
  - Exception: **correctness-critical code** (saves, purchases, security, setup) gets its tests WHEN it's built. They are cheap fixtures, so final QA isn't the first time they run.
- **Art:**
  - Review loops against the art bible.
  - Hero assets first: what players see constantly (the main held item, the core effect, the HUD, the landmark).
  - Never build downstream on an unapproved step.
- **Every lane ends with its own gate** before its handoff:
  - visual lanes: overlap / support / functional-surface audits + close-ups (RULES 29);
  - UI lanes: the GUI gate;
  - code lanes: the regression sweep + full tests.

  Final QA then confirms; it isn't the first time anything was checked.

### Lane brief (use templates/LANE-BRIEF.md)

A brief contains:
- one objective;
- inputs (approved only);
- exact outputs and file paths;
- the craft guides to read;
- the acceptance checks with their evidence;
- the hard stop time;
- "write HANDOFF-<lane>.md and stop".

Lanes read their brief only at the start: queue new notes for the NEXT lane instead of restarting, unless the lane is under 10 minutes in or doing the wrong thing.

## 5. Running lanes (launch, watch, recover)

- **Write all lane briefs and run scripts up front,** so a finished lane is replaced in the same check that sees its handoff.
- **Launch with a script file** (inline PowerShell `-Command` strips `$`), ASCII only (no em-dashes in launch scripts), and pass long prompts by file.
- **Find each lane's PID by its command line** after launch and after every kill. Never trust the launcher's child list, and never kill by pattern.
- **Watching:** prefer an event watcher. One small background script per run exits, and wakes the operator, only when:
  - a HANDOFF or READY file appears;
  - no file changes for 15 minutes with flat CPU;
  - the process dies;
  - or the hard stop arrives.

  Keep a 60-90 minute safety-net check. Use timed checks (5-10 min) only while the owner is present and wants them.
- **One status script per project** (lanes by command line, handoffs, files changed in the last 20 min, place-file time, git): one call per check.
- **Save safety:**
  - git at the project root, with a snapshot every check;
  - lanes commit after each fix group;
  - lanes verify the place file's LastWriteTime after every save;
  - BACKUP/ copies.
- **Two lanes, one source tree:** build with a lane-specific Rojo project (`globIgnorePaths`) so one lane's WIP never ships into the place.
- **Studio:**
  - pin each MCP relay to its own window (`--pin=NAME`);
  - the MCP runs solo Play only; multiplayer = server + clients, at most about 4 clients on this PC, and needs about 6 GB of free RAM;
  - measure fps only with the window focused (unfocused Studio runs at about 15 fps);
  - never leave Studio in Play after a failed run.
- **Stop helper servers** when done. For `upload_image` URLs, serve PNGs with `python -m http.server <unique port>`.

## 6. The operator's review: seven senses

Before anything reaches the owner, Winter reviews it with all seven senses. Each sense has a checklist in its craft guide; this is the summary.

| Sense | Ask | Tools |
|---|---|---|
| **Eye: shape and colour** | Does the hero read first? Is the silhouette clear at 3 distances? Colour true to the name, about 10% under first instinct? Anything dark, empty, cluttered, doubled or a lookalike? | 2x zoom crops, contact sheets, low back-corner angles, side places |
| **Eye: motion** | Does every motion have anticipation, snap and settle? Do VFX read as energy, not objects? Shine stays on the surface? Previews sway, not spin? | frame sheets, slow-mo capture, paused-frame review |
| **Ear** | Does every action have a sound? Is the mix balanced, nothing clipping or repeating so often it annoys? Silence where it should be? | loudness check, a listen pass with eyes closed, or flag "unheard" to the owner |
| **Hand: feel** | Input → response under 100 ms? Camera comfortable? Controls restored after every mode? Satisfying after 50 repetitions? | real input tests (hold W, click the real path), play it |
| **Clock: performance** | Frame time stable, no spikes on spawn or effects, memory flat over 20 minutes? Phone-safe? | a paused-runner baseline first, the MicroProfiler, a 20-min autoplay soak |
| **Taste: style** | Does it match the style sheet? Does it pass the owner's taste constants (polished, readable, bright, clean, alive, worth it, original, truthful, simple)? Is it closer to the loved entries or the rejected ones? Does it repeat a rejected "why"? | side-by-side against the target frames + taste/ gallery |
| **Head: clarity and value** | Would an 8-year-old know the next action? Is the first reward under 1 minute and the first purchase offer about 3 minutes in? Is every purchase worth it? Do the economy numbers hold up? | the noob walk-through, the economy table |

Plus the **structural checks**, which are automated and always run:
- the overlap / support / functional-surface audits;
- the GUI gate;
- the regression sweep;
- the prune sweep.

Then the **whole-screen critique** [r42]. On every screen and view, ask:
- is the most important thing the most visible?
- does anything look unfinished?

### When the owner judges the work

Follow the TASTE.md loop:
- ask him WHY (loved or rejected);
- save the entry with his words;
- a "bad" verdict → research online → a completely fresh remake with a different approach;
- small defects are simply fixed.

## 7. Release gates

**Ship gate** (any size):
- 0 open critical / high defects;
- a clean Play boot of the BUILT file (not the source);
- every lane gate passed;
- the prune sweep done;
- the seven-sense review done;
- KNOWN-ISSUES written.

**Live gate** (anything players join), run in a live private server, not Studio:
- [ ] Asset permissions: audio, meshes and images owned by the experience owner (the group), or granted. Upload with `-GroupId`.
- [ ] StreamingEnabled: things appear, unload and come back correctly. Players are never left in an empty map.
- [ ] Saves: join, earn, leave, rejoin on a different server. Data is intact and the schema version is correct.
- [ ] Purchases: prompt + cancel on every pass and product. The receipt path is tested with fixtures.
- [ ] Analytics events show up in the dashboard (check the next day).
- [ ] One real-phone session: frame rate, touch targets, safe areas, readable text.
- [ ] Studio-only fallbacks (in-memory saves, owner permissions) are switched off or proven harmless live.

## 8. After shipping

1. **Kaizen retro** (skill kaizen-retro):
   - every owner correction gets a root-cause class (BRIEF / REVIEW / TOOL / TIMING / TASTE);
   - fix the system where it will be read next time (RULES, a craft guide, a template or a tool);
   - log it in LESSONS.md.
2. **Refresh RobloxLibrary** with improved systems (code only) and update CATALOG.md.
3. **Archive the project's history** to `LOG/<project>.md`. Remove the project from STATE.md and CHECK-PLAN.md.
4. **Metric line** in LESSONS.md: owner-found defects / restarts / idle minutes per session. The trend must go down.

## 9. Updating these files

- **One fact, one home.** A rule lives in RULES.md; a craft detail lives in its guide; a dated story lives in LESSONS.md or LOG/. Never copy the same checklist into two files.
- **Rewrite, don't append.** When a lesson changes how something is done, edit the step itself. LESSONS.md keeps the dated story.
- Keep each file readable in one sitting. If a guide passes about 250 lines, split it.
