# AURA CLASH: Monetization v2 (owner rework, 3 October 2026)

**Goal (owner):** money is the top priority. Paid eggs, Limiteds, pop-ups and big ladders are all in. We **follow Roblox's rules**, because a removed game earns nothing.

**The four principles:**
1. **Sell multipliers and exclusives, not raw resources.** Boosts multiply what you earn by playing, so payers keep playing (and keep buying). Coins still only come from selling shards, and Power only from meditating.
2. **Free players can finish everything,** and get exclusive eggs from hourly and daily rewards. They fill the servers payers show off in.
3. **Everything bought is visible:** titles over heads, serial numbers, server-wide boosts that thank the buyer, announcements.
4. **Odds, stock and timers are always real.**

---

## 1. The buff system (rework)

Every boost in the game is one of three kinds, and they **multiply together**. The **Buffs panel** (a button by the Power counter) lists each active buff with its source and timer, plus the **total** for each stat.

| Kind | Examples | Lasts |
|---|---|---|
| **Permanent** | Power ladder, Luck ladder, VIP, 2× Coins, 2× Secret Luck, 2× Hatch Speed, group, Roblox Premium | forever |
| **Timed** | Luck / Coin / Power / XP / Mega potions (bought, or from hourly and daily rewards) | 5-60 min, and buying more stacks the time |
| **Server-wide** | Server Luck Boost, Mutation Storm (bought by any player), events (Later) | 10-15 min, for everyone in the server |

**The four stats buffs touch:**

| Stat | Multiplied by | Cap |
|---|---|---|
| **Power gain** (meditation, incl. AFK and offline) | Power ladder × VIP 1.5 × Power potions | none |
| **Coins** (from selling) | 2× Coins × VIP 1.5 × Coin potions × Premium 1.1 | none |
| **Luck** (normal eggs) | Luck ladder × Luck potions × Server Luck × group 1.1 | **×10,000 total** |
| **Secret luck** (the three Secret tiers only) | the Luck total above, then × 2× Secret Luck pass | (inside the luck cap) |

Also: **Hatch speed** (2× Hatch Speed pass), **XP** (XP potions).

## 2. The two ladders: Power and Luck (the core of the store)

Each ladder is a row of permanent upgrades. **Each tier doubles the stat, forever.** You buy them in order.

| Tier | 1 | 2 | 3 | 4 | 5 | 6 | 7 | 8 | 9 | 10 | 11 |
|---|---|---|---|---|---|---|---|---|---|---|---|
| Multiplier | ×2 | ×4 | ×8 | ×16 | ×32 | ×64 | ×128 | ×256 | ×512 | ×1,024 | ×2,048 |
| Price (R$) | 3 | 9 | 19 | 29 | 49 | 79 | 149 | 249 | 399 | 799 | 999 |
| Total spent | 3 | 12 | 31 | 60 | 109 | 188 | 337 | 586 | 985 | 1,784 | 2,783 |

- **Power ladder:** multiplies Power gained from meditation (also AFK and offline).
- **Luck ladder:** multiplies egg luck (section 4).

**Why it works:**
- **The 3 R$ first tier** is the easiest "first purchase" possible. A player who has bought once buys again far more readily, so this is the best conversion hook in the game.
- **Every tier is a clear, visible doubling,** and the next tier always waits one tap away.

**What the model says** (average player, time to beat all 8 bosses):

| Spend | Profile | All 8 zones |
|---|---|---|
| 0 R$ | free | **7 h 13** |
| 62 R$ | starter: 3 tiers of each ladder | **4 h 17** |
| 1,274 R$ | VIP + 2× Coins + 6 tiers of each ladder | **2 h 22** |
| 7,511 R$ | whale: everything permanent | **2 h 19** |

**Important:** past about ×64, more Power barely speeds up the game, because coins and quests become the limit (that's intended: payers can't skip the game entirely). So the top tiers sell **status and luck**:
- **Power tiers:** a big Power number on the **server and global leaderboard** and the biggest aura in the server (aura size grows with Power).
- **Luck tiers:** hunting the crazy-rare Secrets (section 4).

## 3. Game passes (one-time)

| Pass | R$ | What it does |
|---|---|---|
| **VIP** | 499 | **"VIP" title over your head and in chat** (gold, animated), ×1.5 coins, ×1.5 Power, +1 pet slot, access to VIP-only Limited cosmetic drops. (Mats stay **communal**: no VIP floor mats) |
| **2× Coins** | 399 | everything you sell ×2 |
| **2× Secret Luck** | 199 | doubles your chance of **Secret, Ultra Secret and Infinity Secret** pets |
| **2× Hatch Speed** | 399 | hatch animations play twice as fast (more eggs per minute) |
| **+3 Pet Slots** | 449 | 3 more equipped pets (above the 10 from quests) |
| **Hatch ×8 + Auto-Hatch** | 349 | hatch 8 at once; auto-hatch keeps buying the selected egg |
| **Huge Storm** | 249 | ×2 bag capacity (the storm visual stays capped: no lag) |
| **Auto-Sell** | 199 | the storm sells itself when full: no teleport, full value |
| **Offline+** | 199 | offline meditation at 50% (not 25%), up to 16 h (not 8) |
| **Mutation Magnet** | 299 | your mutated shards are worth ×1.5 |

**Removed (replaced by the ladders):** Lucky, Super Lucky, 2× Meditation.

**Bundle:** VIP + 2× Coins + 2× Secret Luck + 2× Hatch Speed for **1,099** (instead of 1,496), shown in the store as "Best value".

## 4. Luck and the crazy-rare Secrets

**Every zone egg now has 9 rarities.** Two new tiers sit above Secret, and in practice only high-luck players will ever see them:

| Rarity | Base chance | Base Strength | How much luck helps |
|---|---|---|---|
| Common / Rare / Epic | 60% / 28% / 10% | 1 / 2 / 4 | they shrink as luck grows (keeping their 60:28:10 ratio) |
| Legendary | 1.88989798% | 10 | a little (luck^0.3) |
| Mythic | 1 in 1,000 | 20 | some (luck^0.5) |
| Divine | 1 in 10,000 | 40 | a lot (luck^0.7) |
| Secret | 1 in 1,000,000 | 100 | most (luck^0.85) |
| **Ultra Secret** | **1 in 50,000,000** | **400** | almost fully (luck^0.95) |
| **Infinity Secret** | **1 in 1,000,000,000** | **2,000** | fully (luck^1) |

**Why luck is weighted like this:** if luck simply multiplied every rare chance, ×2,048 luck would push past 100% and every egg would be Mythic or better. Weighting it toward the rarest tiers keeps eggs exciting at every luck level. The odds always add to 100%, and Legendary-and-up can never exceed 90%.

**What players actually see** (from the model):

| Luck | Legendary | Mythic | Divine | Secret | Ultra Secret | Infinity Secret |
|---|---|---|---|---|---|---|
| ×1 (free) | 1.89% | 1 in 1,000 | 1 in 10,000 | 1 in 1M | 1 in 50M | 1 in 1B |
| ×8 (31 R$) | 3.53% | 1 in 354 | 1 in 2,333 | 1 in 171K | 1 in 6.9M | 1 in 125M |
| ×64 (188 R$) | 6.58% | 1 in 125 | 1 in 544 | 1 in 29K | 1 in 962K | 1 in 15.6M |
| ×2,048 + 2× Secret Luck | 18.61% | 4.53% | 2.08% | 1 in 766 | 1 in 17,872 | 1 in 244,141 |

- **The egg card always shows your current real odds,** with your active buffs applied.
- **Every egg has its own Ultra Secret and Infinity Secret** (names in GAME-BIBLE Part B). They're hidden as "???" until someone hatches one.
- **Their hatches:** the Ultra Secret plays a 12 s cutscene; the Infinity Secret plays a **15 s cutscene that pauses every server** for a global announcement and gives a permanent animated "INFINITY" title.

## 5. Developer products (buy any number)

| Product | R$ | What it does |
|---|---|---|
| **Luck Potion** | 49 (5 for 199) | ×2 luck for 15 min |
| **Coin Potion** | 49 (5 for 199) | ×2 coins for 15 min |
| **Power Potion** | 49 (5 for 199) | ×2 Power gain for 15 min |
| **XP Potion** | 39 | ×2 pet XP for 15 min |
| **Mega Potion** | 129 | all four for 15 min |
| **Server Luck Boost** | 199 | **everyone in the server** gets ×2 luck for 15 min, with a banner: "Thanks to [buyer]!" |
| **Mutation Storm** | 299 | **everyone in the server** gets ×2 mutation chance for 10 min |
| **Streak Saver** | 29 | restores a missed daily-login streak (section 9) |
| **Aura Pass tier skip** | 49 | +1 tier |
| **Treasure Shards** | 49 / 199 | a sack of the current zone's shards (about 10 / 50 min of average hunting), sold like any shards. **Never shown in pop-ups** |

## 6. Exclusive Eggs (two kinds)

| | **Daily Exclusive Egg** | **Shop Exclusive Egg** |
|---|---|---|
| **How you get it** | **free** from hourly and daily rewards, the group chest and the Aura Pass, **or** buy it | **shop only** (also as Aura Pass premium rewards) |
| **Price** | **49**, 3 for **99**, 10 for **249** | **99**, 3 for **279**, 10 for **849** |
| **Odds** | Epic 70% / Legendary 25% / Mythic 4.5% / Divine 0.49% / **Huge 0.01%** | Legendary 75% / Mythic 20% / Divine 4.5% / **Huge 0.45%** / **Titanic 0.05%** |
| **Strength** | the normal rarity table **×2**, scaled to your best unlocked zone (it never goes out of date) | the normal table **×4**, scaled to your best zone. **Huge** base 200, **Titanic** base 800 |
| **Guarantee** | none | every 10-pack contains at least one Mythic or better; every 50 hatches without a Divine+ guarantees one (the counter shows on the card) |
| **Luck** | doesn't change paid-egg odds (the card never changes) | same |

- **"Crazy pets":** exclusives are the best-looking pets in the game.
  - **Animated bodies:** neon, holographic, flaming.
  - **Their own attack animations** and a particle trail.
  - **Huge pets** are 3× size and **Titanic pets** are 6× size, with a ground-shaking walk.
  - **Every Huge or Titanic hatch is a global announcement.**
- **New theme every month.** Month 1 examples:
  - **Daily: "Neon Spirits":** Neon Cat (Epic), Neon Wolf (Legendary), Neon Dragon (Mythic), Neon Phoenix (Divine), **Huge Neon Dragon**.
  - **Shop: "Royal Spirits":** Royal Lion (Legendary), Royal Griffin (Mythic), Royal Phoenix (Divine), **Huge Royal Lion**, **Titanic Royal Dragon**.
- **Old themes never come back.** Owners keep them forever, which makes them valuable for trading later.
- **Roblox rules for paid random items (required):**
  - **odds on the card before purchase,** adding to 100%;
  - **`PolicyService` check:** if `ArePaidRandomItemsRestricted`, that player can't buy either egg and sees a **direct-buy shop** instead (pick the exact exclusive pet: Epic 99, Legendary 249, Mythic 699);
  - **free eggs still work for them:** eggs from rewards aren't purchases, so they can still hatch those;
  - **no cash-out:** paid items trade only for items, never for Robux.

## 7. Limited items (serials up to #1,000)

Every cosmetic and every Limited pet is a **numbered Limited**: at most **1,000 copies**, with the serial shown on it ("#0042"). When it sells out, it's gone forever, and the counter on the stand is real.

| Item | R$ | Notes |
|---|---|---|
| **Limited pet of the month** | 399 | e.g. "Founder's Phoenix" (Shop Exclusive strength, Divine tier) |
| **Limited aura of the month** | 149 | a unique aura style (shape + colour + particles) |
| **Aura colours** | 25-49 | every colour is a numbered Limited run |
| **Fist trails** | 49 | |
| **Storm skins** (sakura petals, galaxy dust, gold coins…) | 79 | |
| **Titles** | 25 | e.g. "Storm Chaser" |
| **Creator collab skin** (e.g. Verity) | 99 | **only with a signed collab or licence** (see the note) |
| **Creator collab pet** (e.g. Verity) | 399 | same |

> **⚠ Verity (correcting you on this one):** if Verity is a real creator or brand, selling a "Verity" skin or pet **without their written permission** breaks Roblox's rules on using other people's names and likeness, and it can get the items **or the whole game taken down**. Do it as an **official collab**: reach out, agree a revenue share, and they'll promote it to their audience, which is worth far more than the sales. Until there's a signed deal, sell an original design inspired by the trend, with no name, logo or likeness.

**How the stock counter works:** the global stock is reserved on the server **before** the purchase prompt opens, so it's never oversold (CORE-GAME 2.2).

## 8. Gifting

Every pass, product, egg pack and Limited has a **Gift** button for a friend in the server. The gift arrives with a big "🎁 from [name]" animation.

## 9. Free rewards (retention: "massive")

### 9.1 Hourly rewards (playtime, AFK counts)

A reward track that fills while you're in the game. At 60 minutes it resets and starts again.

| Minute | 1 | 3 | 5 | 10 | 20 | 30 | 45 | **60** |
|---|---|---|---|---|---|---|---|---|
| Reward | Luck Potion (5 min) | Coin Potion (5 min) | XP Potion (10 min) | Mega Potion (5 min) | 3 eggs of your zone | Luck Potion (15 min) | Mega Potion (15 min) | **Daily Exclusive Egg** |

**Why it works:** there's always a reward a few minutes away, and **every hour played is an exclusive egg**. AFK counts, so players leave the game running, which raises concurrent players, and that raises our place in Roblox's recommendations.

### 9.2 Daily login (7-day cycle, by server date)

| Day | Reward |
|---|---|
| 1 | 3 Luck + 3 Coin Potions |
| 2 | **3 Daily Exclusive Eggs** |
| 3 | 2 Mega Potions + 1 h ×2 Power |
| 4 | **5 Daily Exclusive Eggs** |
| 5 | a **Server Luck Boost** token (use any time, for everyone) + 3 Mega Potions |
| 6 | **1 Shop Exclusive Egg** |
| 7 | **8 Daily Exclusive Eggs** + a **guaranteed Mythic-or-better Daily Exclusive pet** + a "Week N" title |

- **Each new week:** +1 egg on days 2, 4 and 7.
- **Day 28:** a **guaranteed Huge** Daily Exclusive pet.
- **Missing a day** resets you to day 1, unless you use the **Streak Saver** (29 R$, offered the next time you join).
- **Roblox Premium members get double daily rewards.**

### 9.3 Group rewards

Join the Aura Clash Roblox group to get:
- **+10% luck** (permanent while you're in the group);
- a **group chest** every 24 h with **1 Daily Exclusive Egg** + 1 Mega Potion.

### 9.4 Roblox Premium

- **The perks:** +10% coins and double daily rewards.
- **Why it pays:** it keeps Premium members playing longer, and Roblox's **Premium Payouts** pay us for the time they spend.

## 10. Aura Pass (season pass, 30 days, "extremely good")

**50 tiers,** earned with Pass XP from daily and weekly challenges:
- defeat 300 monsters;
- meditate 15 min;
- hatch 50 eggs;
- defeat 5 mutated monsters;
- beat a boss;
- log in 5 days.

| Track | Price | What's in it |
|---|---|---|
| **Free** | free | a reward every 2 tiers: potions, **10 Daily Exclusive Eggs** in total, an exclusive **Epic pass pet** at tier 25 and an exclusive **Legendary pass pet** at tier 50 |
| **Premium** | **499 R$** | a reward **every tier** on top of the free track: **45 Daily Exclusive Eggs + 5 Shop Exclusive Eggs** (more than 1,600 R$ of eggs at store prices); **Mythic-tier exclusive pets at tiers 10, 20, 30 and 40**; a **Huge season pet** at tier 50; the season's exclusive aura, storm skin and title; **+25% luck for the whole season** |
| **Premium+** | **1,499 R$** | everything in Premium, **25 tiers unlocked instantly**, an extra exclusive Premium+ pet, and a gold season title |

Every season's pets and cosmetics are never sold again.

## 11. Packs (real timers)

| Pack | Offered | Contents | R$ |
|---|---|---|---|
| **Starter Pack** (once per account) | after your first egg; for 48 h | exclusive **Starter Spirit** (Epic, scales with your zone) + 3 Daily Exclusive Eggs + 3 Mega Potions + **Power ladder tier 1** | 99 |
| **Zone Pack** | when you enter a new zone; for 24 h | 10 eggs of that zone + 3 Daily Exclusive Eggs + a Mega Potion | 299 |
| **Comeback Pack** | after 3+ days away; for 24 h | 5 Daily Exclusive Eggs + 3 Mega Potions | 199 |

Every pack shows what it contains and its real store value, with no inflated "worth" claims.

## 12. Pop-up offers (reworked)

| Trigger (a real "want" moment) | Offer |
|---|---|
| **Your first meditation ends** | **"×2 Power forever: 3 R$"** (Power ladder tier 1, the best first-purchase hook) |
| First Legendary-or-better hatch | the next Luck ladder tier |
| Boss lost twice | the next Power ladder tier (**always alongside the free tip** "or meditate about N more minutes") |
| Hourly reward reaches 60 min (a free Daily Exclusive Egg hatched) | a Shop Exclusive Egg 3-pack |
| Day 7 of the login streak | the Aura Pass |
| A missed day | Streak Saver |
| Entering a new zone | Zone Pack |
| Storm full twice within 2 minutes | Auto-Sell / Huge Storm |
| A Rainbow-or-better mutation spawns | Mutation Storm |
| Inventory full | +3 Pet Slots / Hatch ×8 |

**Limits:**
- **Frequency:** at most 1 pop-up per 10 minutes and 4 per session.
- **Never** during a boss, a hatch reveal or a cutscene.
- **Always a big, easy ✕.**
- **No fake timers, stock or discounts.**

## 13. Where the store lives

- **The HUD:** the **R$ Store** button (glowing), the **Buffs** button, and the **Hourly Reward** bar with its countdown.
- **At every Shrine:**
  - the Daily Exclusive Egg stand and the Shop Exclusive Egg stand, each with this month's pets spinning on pedestals;
  - the Limited stand with live counters;
  - the leaderboards (top Power, most Secrets).
- **Mats stay communal:** VIPs are seen through their title, not a floor mat.

## 14. Expected best sellers (genre pattern, not a forecast)

1. Exclusive eggs (both kinds).
2. The Luck and Power ladders (the cheap tiers sell to almost every payer, the top tiers to whales).
3. ×2 passes and VIP.
4. Limiteds (serials).
5. The Aura Pass.
6. Potions and server boosts.

**Track:** payer %, revenue per daily player, D1 / D7 retention, best sellers, and each pop-up's conversion. Cut any pop-up that shortens sessions.

## 15. Build timing

- **Not in the two-zone playtest build.** The game must prove it's fun first.
- **Built straight after playtest #1,** before zones 3-8 go live, so launch has the full store.
- **Before launch, check (CORE-GAME tests):**
  - every odds card adds to 100% and matches the rolls at the player's current luck;
  - `PolicyService` gating;
  - Limited counters with two servers buying at once;
  - every Robux purchase granted exactly once.
