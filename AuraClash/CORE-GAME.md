# AURA CLASH: Core Game v8 (server authority, saving, tests, playtest, performance)

**Doc map (what wins on a conflict):**
1. **`GAME-BIBLE.md`:** every game rule and number, zone by zone. Backed by `econ/model.py` + `econ/tests.py`. **Wins on any game-rule conflict.**
2. **`MONETIZATION.md`:** everything that's sold.
3. **This file:** how the game is made safe and correct (server authority, saving, purchases), the **acceptance tests**, **playtest #1**, and the performance bar.
4. **`STYLE-SHEET.md`:** the look. **`GAME-PLAN.md`:** market and build order. **`HANDOFF-WINTER.md`:** Winter's start sheet.

Old versions are in `archive/`, for history only. **Nothing in `archive/` is a rule.**

---

## 1. Server authority and anti-cheat

- **The server owns:** Power, coins, bag contents, pets (with their XP), quest progress, purchases and every reward. The client only sends inputs.
- **Blasts:**
  - the client reports hold start / release;
  - the server checks the hold length (at least 0.5 s), a blast rate of at most one per 1.4 s (plus a small buffer), the range to the target, and that the target exists;
  - PERFECT is judged on the client (so lag doesn't ruin it), within a server-checked plausible window;
  - an impossible streak rate gets flagged.
- **Meditation:**
  - the server checks you're on a mat;
  - Focus taps are limited to one per breath;
  - Focus can't exceed ×3;
  - offline gains use server timestamps only.
- **Loot:** the server rolls mutations, drops and eggs. Shared monsters use the server's damage log: **every player whose hit landed gets their own full drop and quest credit** (GAME-BIBLE 4.1).
- **Pets:** each pet has a unique id. Fusion is one server transaction (3 removed + 1 added in the same save). XP is added by the server on each kill.
- **Luck:** total luck (2× Boost ladder × potions × server boosts × group × Aura Pass Premium; Secret luck × VIP × 2× Secret Luck) has **no cap** and is applied by tier weight (GAME-BIBLE 5.1). The egg card shows the real odds at the player's current luck, computed by the **same server function that rolls**.
- **Serials:** every Secret, Divine, Impossible and Boundless hatch (and every Verity Limited) gets the next number from a global counter (DataStore `UpdateAsync` on the species counter) **inside the hatch's confirmed save**. Numbers are never reused or duplicated.
- **Rewards:** hourly-reward progress counts server time in the game (AFK included, one session at a time). Daily login uses the server's UTC date, and each day can be claimed once (a confirmed save).

## 2. Saving and purchases (build requirement for the two-zone test)

### 2.1 What's saved (one profile per player, session-locked)

| Saved | Includes |
|---|---|
| Progress | Power, coins, zone access, bosses beaten, form, quest progress per zone |
| Bag | shard counts by type and mutation; unsold Boss Shards |
| Pets | every pet (id, species, zone, stars 0-5, level, XP, favourite / lock, Exclusive / Limited serial), equipped list, auto-fuse / auto-delete settings, mailbox |
| Upgrades | Bag, Mat, Surge levels; pet slots |
| Tutorial / guarantees | tutorial step, **lifetime hatch count**, guaranteed-Rare used, Boss Shards claimed per boss, Shop Exclusive pity counters |
| Purchases + rewards | owned passes, **2× Boost ladder tier**, **slot packs bought (0-10)**, active potion end times (server time), Starter Pack used, Aura Pass season / tier / XP, daily-cycle day (1-7) + week + last claim date, hourly-reward progress, group-chest time, Limited serials owned, processed `PurchaseId`s (MONETIZATION.md) |
| Offline | `lastSeen` (server time), `offlineClaimId` |
| Operations | each critical operation's id → `committed` (with `revealed` yes/no) or `cancelled`, kept 30 days (2.2) |
| Settings | effects, camera, flashing, Low effects |

### 2.2 Rules

- **Session lock:** one server at a time per profile, so two servers can never both grant.
- **Ordinary progress** (Power, coins, bag, kills, XP, normal hatches): queued save + an autosave every 60 s, on leave and on server shutdown (`BindToClose`). **Honest limit:** if a server crashes, up to the last ~60 s of ordinary progress can be lost. That's accepted for ordinary progress; it's why the critical operations below use confirmed saving.
- **Confirmed saving: three outcomes, never two.** Roblox documents that a request can fail on the game server's side **after** the write has committed (https://create.roblox.com/docs/cloud-services/data-stores/error-codes-and-limits). So a failed or timed-out response proves nothing. Every critical operation ends in exactly one of three states:

  | State | How the server knows | What happens |
  |---|---|---|
  | **1. CONFIRMED SAVED** | the `UpdateAsync` call returned success, **or** a later successful `UpdateAsync` finds the operation id in the stored profile | show the result (play the cutscene / the fused pet / the offline gain); never apply it again |
  | **2. CONFIRMED NOT COMMITTED** | a later **successful** `UpdateAsync` finds the id absent, and in that same write stores the id as **cancelled** (so a delayed original write can never apply afterwards: its version is stale and the id is now taken) | undo it in memory (the coins are released, the pets stay unfused) and say "Not saved, nothing was spent. Try again." |
  | **3. UNKNOWN** | the write errored or timed out, and no later `UpdateAsync` has succeeded yet | **don't show the result, don't refund, don't say "cancelled".** Hold the operation as **pending** (below) and keep reconciling |

  **While an operation is UNKNOWN (pending):**
  - its cost is **held**, neither spent nor refunded. The coins show as "held" in the HUD and can't be spent; the pets involved are locked;
  - **conflicting transactions are blocked:** no other purchase, hatch, fusion or sell that touches the same coins or pets, and no second critical operation, until it resolves. The UI shows "Saving…";
  - **safe play continues:** hunting, meditating and quests keep working as ordinary progress;
  - the server retries the reconcile with backoff (2, 4, 8, 16… s, capped at 60 s), and resolves to state 1 or 2 on the first successful `UpdateAsync`;
  - **every later write is also a reconcile:** the autosave, the leave save and the shutdown save all run inside `UpdateAsync`, which first resolves pending ids against the stored profile. If the id is present, the stored effect is kept; if it's absent, it's marked cancelled. **No save ever writes the "refunded" or "spent" coins on a guess.**

  **If the server crashes while an operation is UNKNOWN:** the pending memory is gone, but storage holds exactly one truth:
  - **committed:** the profile already contains the cost, the result and the id, with `revealed = false`. On the next join (any server), the game finds the unrevealed operation and **plays it then** ("Your Mythic hatch finished saving!"), then marks it revealed;
  - **not committed:** the profile has neither the cost nor the result, so nothing was spent and nothing was gained. The first save of the next session writes the id as cancelled.

  **Each critical operation is ONE write that contains everything:** the cost, the result, the operation id and `revealed = false`. The result is never shown before state 1, so a player can't see a bad roll and force a crash to re-roll it.

  **Used for:**
  - the offline meditation claim;
  - Mythic-or-rarer hatches (with the serial for Secret+) and every Exclusive Egg hatch (the cost and the rolled result, saved before the cutscene);
  - fusion to ★2 or higher, and fusion of Epic+ pets;
  - the Boss Shard reward (once per boss);
  - **every Robux purchase** (below).

  The operation ids (including cancelled ones) are kept in the profile for 30 days, then pruned.

- **Offline gain:**
  - computed once per session from `lastSeen` to now (server time, capped at 8 h), in **one write** with a new `offlineClaimId`;
  - it follows the three outcomes above: shown only when confirmed saved. If it's confirmed not committed, `lastSeen` is unchanged, so the same span is offered again; while it's unknown, the gain is held, not shown;
  - a rejoin can't claim the same span twice;
  - the device clock does nothing.
- **AFK rejoin:** the rejoin teleport saves first, then puts you back on a mat (the gain continues).
- **Robux purchases (developer products):** Roblox calls `MarketplaceService.ProcessReceipt` and retries it until we answer `PurchaseGranted`. So:
  - the receipt's **`PurchaseId` is the operation id**: grant + record the id in **one** `UpdateAsync`;
  - return `PurchaseGranted` **only** when that write is **confirmed saved** (state 1), or when a reconcile finds the id already stored;
  - on state 3 (unknown), return `NotProcessedYet`: Roblox will call again, and the id check makes the retry grant exactly once;
  - Robux is never charged without the item, and the item is never granted twice.
- **Game passes** are checked with `UserOwnsGamePassAsync` on join (and `PromptGamePassPurchaseFinished` during play); their effects are never stored as a substitute for that check.
- **Limited pets:** the global stock is decremented in a MemoryStore / DataStore transaction **before** the purchase prompt. If the count is 0, the prompt never opens. A failed purchase returns the reserved unit after 2 min. Never oversold.
- **Paid random items:** buying the Daily or Shop Exclusive Egg is offered only when `PolicyService:GetPolicyInfoForPlayerAsync(player).ArePaidRandomItemsRestricted` is false; otherwise the direct-buy shop is shown (MONETIZATION.md 6). Eggs earned from rewards can always be hatched.
- **Studio without API access:** play without saving, with a "NOT SAVING" banner. Never stall.
- **Follow Roblox's data store guidance:** https://create.roblox.com/docs/cloud-services/data-stores/best-practices

### 2.3 Tests (all must pass in the real game before playtest #1; none has been run yet)

| # | Test | Pass |
|---|---|---|
| P1 | Play 5 min, leave, rejoin another server | everything in 2.1 identical |
| P2 | Log off 1 h, rejoin twice quickly (two servers) | offline Power granted exactly once |
| P3 | Change the device clock ±1 day | no effect on offline gains |
| P4 | Kill the server during a Mythic hatch (forced shutdown) | after rejoin: the Mythic is there exactly once |
| P5 | Studio mock of the data store: (a) the write fails before committing; (b) **the write commits, then the call reports a timeout**; (c) the store is down for 2 min after an unknown write | (a) a later successful reconcile finds no id: "nothing spent, try again", the id is stored as cancelled; (b) the reconcile finds the id: the result is shown once, **never refunded**; (c) during the outage the coins are **held** (not refunded, not spendable), conflicting purchases / fusions / hatches are blocked, and hunting / meditating still work; when the store recovers it resolves to (a) or (b) exactly once |
| P6 | Rejoin before the 3rd hatch and after the tutorial egg | the guarantees happen exactly once, in order |
| P7 | **Odds test:** 1,000,000 automated server-side hatches of the zone 1 and zone 2 eggs at ×1 luck | every pet Common-Legendary within ±4 standard deviations of its card chance; Mythic and rarer 0-few (e.g. Mythic 1 in 25K: 40 expected, accepted 15-65) |
| P8 | Crack colour vs result over the same 1,000,000 hatches | 100% match |
| P9 | **Mutation test:** 200,000 automated spawns | each mutation within ±4 SD of its chance (GAME-BIBLE 4.2) |
| P10 | Fill the bag in Overdrive with mutated shards | never above capacity; every mutated shard sells at its multiplier |
| P11 | A newcomer (10% of the damage) and a veteran (90%) hit one monster | **both** get their own full drop and quest credit |
| P12 | Spam SELL / Fuse / Hatch (20 clicks), and two devices at once | exactly one sale, fusion and hatch each |
| P13 | **Robux product:** buy a Luck Potion with the data store mocked to (a) fail, (b) commit then time out | (a) `NotProcessedYet`, then exactly one grant when Roblox retries; (b) the reconcile finds the `PurchaseId`: granted once, never twice |
| P14 | Studio mock: every save fails during a Mythic hatch attempt, then the server is shut down | rejoin with the write **not committed**: no Mythic and no coins spent. Rejoin with the write **committed** (response lost): the Mythic and its cost are both there once, and the cutscene plays on join ("finished saving"). No path refunds coins for a committed hatch or shows a result that isn't stored |
| P15 | **Limited stock:** two servers buy the last 5 units at once (20 buyers) | exactly 5 sold; nobody is charged without receiving one |
| P16 | **Paid random items:** a test account with `ArePaidRandomItemsRestricted = true` | can't buy either Exclusive Egg; sees the direct-buy shop; can still hatch reward eggs |
| P17 | **Luck + odds card:** stack 2× Boost ×2,048 + VIP + Luck Potion + Server Luck + group + 2× Secret Luck | no cap applied; the card's odds add to 100% and equal the rolled odds over 1,000,000 hatches (±4 SD for Legendary and Mythic) |
| P19 | **Serials:** 3 servers hatch Secrets of the same species at the same moment (forced test odds) | numbers 1, 2, 3 each used once; a failed save never burns or duplicates a number |
| P20 | **Slot packs:** buy +2 Pet Slots 11 times | 10 succeed (+20 slots); the 11th prompt never opens |
| P21 | **Machines (as each ships):** Nursery stays use server time and can't be collected twice; enchant rolls, Reactor infusions and relic levels happen on the server, each consuming its cost in the same save as its result | no duplicate collects, no free rolls, no lost shards |
| P22 | **Secret+ scaling:** get a better normal pet while owning a Secret and a Boundless | their Strength updates to ×1 and ×1,000 of the new best pet, immediately and after a rejoin |
| P18 | **Daily login:** claim, change the device clock, rejoin another server; skip 2 days, then log in | one claim per server (UTC) day; after the skip you claim the **next** day of the cycle (nothing resets) |

## 3. PLAYTEST #1 (behaviour first)

**Build:**
- zones 1-2, complete per GAME-BIBLE Part A + zones 1-2 (no monetization);
- the tutorial;
- the cheat panel (set Power / coins / zone / spawn a mutation);
- a session log (where the player went, what they bought, how long they meditated vs hunted, when they stopped).

**Two sessions:** day 1 (free play, no instructions) and **day 2** (invited back). Day 2 tests the **return experience** (the offline gain, the next goals). It doesn't test real retention, which is measured later, unprompted.

| # | We watch (behaviour) | Pass |
|---|---|---|
| 1 | First PERFECT, unaided | under 30 s |
| 2 | Sells without being told after the first (tutorial) sell | yes |
| 3 | **Chooses to meditate without a quest telling them to** | at least once on day 1 |
| 4 | **Switches between hunting and meditating on their own** | 3+ switches on day 1 |
| 5 | Taps the red flash in the beam clash without being told | by the 2nd boss attempt |
| 6 | Notices and chases a mutated monster | yes |
| 7 | Makes a ★ pet at the Fusion Altar without being told after the tutorial | yes |
| 8 | Keeps playing after boss 1 with no prompt | 10+ min |
| 9 | Logs off on a mat (or asks about offline) | yes, or explained in one line |
| 10 | **Day 2:** sees the offline gain and keeps playing after it | 10+ min |
| 11 | Timing behaviour at 15+ min: still aiming for PERFECTs, using Overdrive | not abandoning timing |

**What they say counts less than what they do:**
- secondary: fun 1-10, the best and the most boring moment;
- an answer only breaks a tie.

**If #1, #4 or #11 fails, fix the core before any more art.**

**If #4 fails:**
- only hunting → raise the Shrine rate or the Power gates;
- only sitting → raise the monster loot or make Focus faster.

## 4. Quality and performance target

- **Look:** STYLE-SHEET.md (glossy toon anime, outlines, smooth plastic, calm bases + loud loot).
- **Aura:** early forms (Spark / BLAZE / INFERNO) 3.0-4.5 studs, 2 layers, ≤ 40 particles; later forms up to 8.3 studs, ≤ 4 layers, ≤ 120 particles at gameplay distance.
- **Others' auras and pets:** full within 40 studs, reduced at 40-100, hidden or a billboard beyond.
- **Per client:** ≤ 1,500 particles, ≤ 4 overlapping transparent layers.
- **Storm and mutations:** budgets in GAME-BIBLE 4.3 (≤ 12 shard meshes + 2 emitters for you, 1 emitter for others).
- **Roblox guidance:** https://create.roblox.com/docs/performance-optimization/improve
- **60 fps** on a mid-range phone with a full server at the Shrine.
- **Settings:** Low effects, others' effects, camera shake, reduced flashing, show others' pets.

## 5. What the model does and doesn't cover

- **It covers:**
  - meditation (AFK / Focus / offline);
  - blasts with PERFECT / combo / Overdrive chains;
  - all 10 zones: 30 monsters, mutations (with natural storms), the bag cap and SELL, Boss Shards;
  - shop spending, every egg's own table (10 tiers by odds band, Boundless) and guarantees, stars 0-5, automatic XP and levels, the team-hit cap;
  - rank quests by difficulty tier, boss HP and the beam clash;
  - the effect of the 2× Boost ladder and the passes (VIP, 2× Coins, 2× Secret Luck, 2× Hatch Speed, Hatch ×3 / ×8, slot packs).
- **It doesn't cover:**
  - monsters hitting the player (only time lost, assumed small);
  - other players sharing monsters (personal loot means crowded servers pay faster than the model);
  - walking between areas (beyond a per-kill overhead);
  - coin packs, potions, Exclusive Eggs, the Aura Pass;
  - saving and purchases (tests P1-P22 are for the real game).
- **Decisions** (like when to meditate) follow a simple "average player" policy. **The playtest is the real test.**
