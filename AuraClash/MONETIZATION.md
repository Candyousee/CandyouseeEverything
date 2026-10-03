# AURA CLASH: Monetization v3 (final, owner-approved structure, 3 October 2026)

**Goal (owner):** money is the top priority. We **follow Roblox's rules**, because a removed game earns nothing.

**The principles:**
1. **Sell multipliers and exclusives.** Boosts multiply what you earn by playing, so payers keep playing and buying. (Coin packs are the one direct-resource item, an owner decision.)
2. **Free players can finish everything** (about 10 h for a first run in the model) and get exclusive eggs from hourly and daily rewards. They fill the servers payers show off in.
3. **Everything bought is visible:** titles, serial numbers, server-wide boosts that thank the buyer, global announcements.
4. **Odds, stock and timers are always real.**

---

## 1. The buff system

Every boost is **permanent**, **timed** or **server-wide**, and they all **multiply together. There is no cap.** The **Buffs panel** (by the Power counter) lists every active buff, its source and its timer, plus the total for each stat.

| Stat | Multiplied by |
|---|---|
| **Power gain** (meditation, incl. AFK and offline) | 2× Boost ladder × VIP 1.5 × Power potions × Aura Pass Premium 1.5 (that season) |
| **Luck** (zone-egg odds; GAME-BIBLE 5.1) | 2× Boost ladder × Luck potions × Server Luck Boost × group 1.1 × Aura Pass Premium 1.5 (that season) |
| **Secret luck** (Secret and rarer only, on top of luck) | VIP 1.5 × 2× Secret Luck |
| **Coins** (selling) | 2× Coins × VIP 1.5 × Coin potions × Premium 1.1 |
| **Hatch speed** | 2× Hatch Speed × VIP 1.5 (Hatch ×3 / ×8 add eggs per hatch) |
| **Mutation chance** | Mutation Storms (natural or bought) ×2 |

## 2. The 2× Boost ladder (one ladder: Luck **and** Power)

**Every tier doubles both Luck and Power, forever.** The player feels the Power right away, and discovers the luck when they hatch.

| Tier | 1 | 2 | 3 | 4 | 5 | 6 | 7 | 8 | 9 | 10 | 11 |
|---|---|---|---|---|---|---|---|---|---|---|---|
| Luck and Power | ×2 | ×4 | ×8 | ×16 | ×32 | ×64 | ×128 | ×256 | ×512 | ×1,024 | ×2,048 |
| Price (R$) | 3 | 9 | 19 | 29 | 49 | 79 | 149 | 249 | 399 | 799 | 999 |
| Total spent | 3 | 12 | 31 | 60 | 109 | 188 | 337 | 586 | 985 | 1,784 | 2,783 |

**What the model says** (average player, time to beat all 10 bosses):

| Spend | Profile | All 10 zones |
|---|---|---|
| 0 R$ | free | **~10 h 06** |
| 31 R$ | starter: 3 ladder tiers | **6 h 18** |
| 986 R$ | VIP + 2× Coins + 6 ladder tiers | **3 h 13** |
| 7,164 R$ | whale: every pass + all 11 tiers + 10 slot packs | **2 h 59** |

**What these times are (and aren't):** they come from `econ/model.py`, which simulates the **core loop**: blasts, Overdrive, mutations and storms, meditation, eggs and luck, pets (Strength, stars, levels, the Star Forge in zone 5), quests, bosses, the 2× Boost ladder, VIP, 2× Coins / Secret Luck / Hatch Speed, Hatch ×8, Huge Storm, Auto-Sell, Mutation Magnet and slot packs. **Not modeled yet:** enchants, pet mutations, the Nursery, relics, the Codex, Ascension, Exclusive and reward-track pets, potions, the Aura Pass, coin packs, Offline+ (the model plays in one sitting) and raid co-op. Almost all of those only speed a player up, so the real times are probably **shorter**, by an unknown amount. **These are partial-model estimates, not validated pacing**: playtest #1 and the soft launch measure the real times, and each machine is added to the model before it ships (GAME-PLAN 5b). In the whale's 7,164 R$, Offline+ (99) is counted but has no effect in a one-sitting run.

**Why this shape works:**
- **The 3 R$ first tier** is the easiest first purchase possible, and after one purchase players buy again far more readily.
- **Past about ×64,** more Power barely speeds the game up (coins and quests become the limit; that's intended). So the top tiers sell **luck for the Secret+ tiers** and **status:** a leaderboard Power number and the biggest aura in the server.

## 3. Game passes (one-time)

| Pass | R$ | What it does |
|---|---|---|
| **VIP** | **399** | an animated **"VIP" title over your head and in chat**; **×1.5 coins, ×1.5 Power, ×1.5 hatch speed, ×1.5 Secret luck**; +1 pet slot |
| **2× Coins** | 399 | everything you sell ×2 |
| **2× Secret Luck** | 199 | doubles Secret, Divine, Impossible and Boundless chances |
| **2× Hatch Speed** | 399 | hatch animations twice as fast |
| **Hatch ×8** | 399 | 8 eggs per hatch |
| **Huge Storm** | 199 | ×2 bag capacity (the visual stays capped) |
| **Auto-Sell** | 199 | sells automatically when full, no teleport |
| **Offline+** | 99 | offline meditation at 50%, up to 16 h |
| **Mutation Magnet** | 99 | your mutated shards are worth ×1.5 |

- **Auto-Hatch is free for everyone, and Hatch ×3 is free after boss 1.**
- **Bundle:** VIP + 2× Coins + 2× Secret Luck + 2× Hatch Speed for **1,099** (instead of 1,396).

## 4. Repeatable products

| Product | R$ | What it does |
|---|---|---|
| **+2 Pet Slots** | **199 each, up to 10 times** (+20 slots) | 2 more equipped pets. The biggest repeat earner: each pack is a visible +2 team |
| **Luck Potion** | 25 (5 for 99) | ×2 luck, 15 min (time stacks) |
| **Power Potion** | 25 (5 for 99) | ×2 Power gain, 15 min |
| **Coin Potion** | 25 (5 for 99) | ×2 coins, 15 min |
| **XP Potion** | 19 | ×2 pet XP, 15 min |
| **Mega Potion** | 65 | all four, 15 min |
| **Mutation Storm** | **99** | starts a Mutation Storm (×2 mutation chances) in the server for 10 min, with a "Thanks to [buyer]!" banner. Storms also happen **naturally** for 5 min every 45 min |
| **Server Luck Boost** | 199 | everyone in the server ×2 luck for 15 min, with the buyer thanked |
| **Coin packs ("buy gold")** | 49 / 149 / 449 / 999 | coins worth about 15 min / 1 h / 4 h / 12 h of the model's average hunting income **in your current zone** (it scales, so it's always useful) |
| **Aura Pass skip** | 799 | jumps the Aura Pass straight to the last tier (section 10) |

**Removed:** Treasure Shards.

> "Buy gold" is read as **buying coins**. If you meant something else (e.g. guaranteed Gold-mutation monsters), tell me.

## 5. Luck, by the numbers

Luck has **no cap**. It works hardest on the rarest tiers (GAME-BIBLE 5.1), and the odds always add to 100%.

**Lumora Grove egg** (from the model):

| Luck | Legendary | Mythic | Secret | Divine | Impossible | Boundless |
|---|---|---|---|---|---|---|
| ×1 (free) | 1 in 400 | 1 in 25K | 1 in 2.5M | 1 in 100M | 1 in 10B | 1 in 1T |
| ×8 (31 R$) | 1 in 214 | 1 in 8,839 | 1 in 474K | 1 in 15.4M | 1 in 1.25B | 1 in 125B |
| ×64 + VIP | 1 in 115 | 1 in 3,125 | 1 in 59,828 | 1 in 1.58M | 1 in 104M | 1 in 10.4B |
| ×2,048 + VIP + 2× Secret Luck | 2.46% | 1 in 552 | 1 in 1,870 | 1 in 34,888 | 1 in 1.63M | 1 in 163M |

Add potions, Server Luck and the group bonus, and a maxed player can realistically chase Impossibles. **Boundless stays a once-a-month, game-wide event.**

## 6. Exclusive Eggs (tier system: no Huge / Titanic)

Both eggs use the **same tier bands** as zone eggs, so a 1-in-2M exclusive is a real Secret, and both have the **Boundless** line. **Secret and rarer follow the game-wide rule** (GAME-BIBLE 5.1): Secret = your best pet, Divine ×10, Impossible ×100, Boundless ×1,000, so they're the same in every egg and never go out of date.

- **Strength (Common to Mythic):** exclusive pets are much stronger than zone pets of the same tier, and **scale to your best zone**, so they never go out of date:
  - **Daily Exclusive:** ×5 the tier's base;
  - **Shop Exclusive:** ×10.
- **Looks:** exclusives are the best-looking pets in the game: animated neon / holographic / royal bodies, their own attacks and trails.
- **New themes every month.** Old ones never return.

### 6.1 Daily Exclusive Egg ("Neon Spirits", month 1)
**Free** from hourly, daily and group rewards and the Aura Pass, **or 49 R$ / 3 for 99 / 10 for 249.**

| Pet | Tier | Chance | Strength (× your best zone's scale) |
|---|---|---|---|
| Neon Cat | Common | 63.009% | 5 |
| Neon Wolf | Uncommon | 22% | 7.5 |
| Neon Tiger | Rare | 9% | 12.5 |
| Neon Fox | Rare | 4.5% | 12.5 |
| Neon Dragon | Epic | 1.2% | 20 |
| Neon Phoenix | Legendary | 1 in 350 | 50 |
| Neon Kirin | Mythic | 1 in 20,000 | 125 |
| Neon Seraph | Secret | 1 in 2M | = your best pet |
| Neon Leviathan | Divine | 1 in 200M | 10× your best pet |
| Neon Infinity | Impossible | 1 in 20B | 100× your best pet |
| Boundless (this month's) | Boundless | 1 in 1T | 1,000× your best pet |

### 6.2 Shop Exclusive Egg ("Royal Spirits", month 1)
**Shop only: 99 R$ / 3 for 279 / 10 for 849** (also on the Aura Pass premium track).

| Pet | Tier | Chance | Strength (× your best zone's scale) |
|---|---|---|---|
| Royal Corgi | Common | 40.692% | 10 |
| Royal Lion | Common | 30% | 10 |
| Royal Griffin | Uncommon | 20% | 15 |
| Royal Phoenix | Rare | 7% | 25 |
| Royal Dragon | Epic | 1.9% | 40 |
| Royal Kirin | Legendary | 1 in 250 | 100 |
| Royal Seraph | Mythic | 1 in 12,000 | 250 |
| Royal Sovereign | Secret | 1 in 1M | = your best pet |
| Royal Emperor | Divine | 1 in 50M | 10× your best pet |
| Royal Infinity | Impossible | 1 in 5B | 100× your best pet |
| Boundless (this month's) | Boundless | 1 in 1T | 1,000× your best pet |

- **Guarantees:**
  - every 10-pack contains at least one **Epic or better**;
  - every 100 Shop hatches without a Legendary-or-better guarantees one (the counter shows on the card).
- **Fixed odds:** luck does **not** change paid-egg odds, so the card is always exactly what you buy.
- **Roblox rules for paid random items:**
  - **odds on the card before purchase;**
  - **`PolicyService` check:** if `ArePaidRandomItemsRestricted`, the player can't buy these eggs and sees a **direct-buy shop** instead (the exact pet, fixed price). Section 17 covers everything else (coin eggs, paid luck, enchants, packs, trading):

    | Tier | Daily Exclusive pet | Shop Exclusive pet |
    |---|---|---|
    | Common | 49 | 149 |
    | Uncommon | 99 | 299 |
    | Rare | 149 | 499 |
    | Epic | 299 | 999 |
    | Legendary | 799 | 2,499 |

    Mythic and rarer are never sold directly;
  - **free eggs from rewards still work** for restricted players (they're not purchases);
  - **no cash-out:** paid items trade only for items, never for Robux.

## 7. Limited items (only Verity for now)

| Item | R$ | Stock |
|---|---|---|
| **Verity aura** | 99 | numbered; on sale 7 days or until 1,000 sold |
| **Verity pet** (Shop Exclusive strength, Mythic tier) | 399 | numbered; on sale 7 days or until 1,000 sold |

- **Serial:** shown on the item ("#0042"). The counter on the stand is real; when it sells out, the sale is over.
- **The exact promise (store text): "Numbered Limited. On sale for 7 days or until 1,000 sold. Every buyer gets a numbered copy."** We never say "only 1,000 will ever exist". Roblox can deliver a paid receipt at any later join, so a hard total can't be guaranteed. A rare late payment gets the next number (#1,001…), and the final edition size is shown honestly. Every buyer always gets the advertised numbered item; there is no substitute (CORE-GAME 2.2).
- **On hold:** titles, other skins and aura colours, as you asked.

> **Verity is a meme, so no licence is needed.** One rule: Winter makes **our own** Verity aura and pet art in our style. Never upload someone else's image or video of the meme, since the original picture can still be someone's copyright.

## 8. Gifting
Every pass, product, egg pack and Limited has a **Gift** button for a friend in the server, with a big "🎁 from [name]" animation.

## 9. Free rewards (massive, for retention)

### 9.1 Hourly rewards (playtime, AFK counts; resets after 60 min)

| Minute | 1 | 3 | 5 | 10 | 20 | 30 | 45 | **60** |
|---|---|---|---|---|---|---|---|---|
| Reward | Luck Potion (5 min) | Coin Potion (5 min) | XP Potion (10 min) | Mega Potion (5 min) | 3 eggs of your zone | Luck Potion (15 min) | Mega Potion (15 min) | **Daily Exclusive Egg** |

### 9.2 Daily login (7-day cycle, server date)

| Day | Reward |
|---|---|
| 1 | 3 Luck + 3 Power Potions |
| 2 | **3 Daily Exclusive Eggs** |
| 3 | 2 Mega Potions + 1 h ×2 Power |
| 4 | **5 Daily Exclusive Eggs** |
| 5 | a **Server Luck Boost** token + 3 Mega Potions |
| 6 | **1 Shop Exclusive Egg** |
| 7 | **8 Daily Exclusive Eggs** + a **guaranteed Legendary-or-better Daily Exclusive pet** |

- **Each new week:** +1 egg on days 2, 4 and 7.
- **Day 28:** a **guaranteed Mythic** Daily Exclusive pet.
- **Missing days never resets anything:** each time you log in on a new day you claim the **next** day of the cycle (claim day 1 on Monday, come back Wednesday, and you claim day 2). One claim per server day.
- **Roblox Premium members get double daily rewards.**

### 9.3 Group and Premium
- **Group:** +10% luck, plus a **group chest** every 24 h (1 Daily Exclusive Egg + 1 Mega Potion).
- **Roblox Premium:** +10% coins and double daily rewards. Their playtime also earns us **Premium Payouts**.

## 10. Aura Pass (season, 30 days): 799 R$, "even more OP"

**50 tiers,** earned with Pass XP from daily and weekly challenges:
- defeat 300 monsters;
- meditate 15 min;
- hatch 50 eggs;
- defeat 5 mutated monsters;
- beat a boss;
- log in 5 days.

| Track | Price | What's in it |
|---|---|---|
| **Free** | free | a reward every 2 tiers: potions, **15 Daily Exclusive Eggs**, an exclusive **Legendary-tier pass pet** at tier 25 and a **Mythic-tier pass pet** at tier 50 |
| **Premium** | **799 R$** | a reward **every tier**: **60 Daily Exclusive Eggs + 10 Shop Exclusive Eggs** (about **2,340 R$ of eggs** at 10-pack prices); exclusive **Mythic-tier pass pets at tiers 10, 20, 30 and 40** (Shop Exclusive strength); a **serialized Secret-tier season pet at tier 50**; the season's exclusive aura; **+50% luck and +50% Power for the whole season** |
| **Skip to the end** | **+799 R$** | unlocks every tier instantly (needs Premium) |

Season pets and rewards are never sold again.

## 11. Packs (half the old price, 50% more inside; real timers)

| Pack | Offered | Contents | R$ |
|---|---|---|---|
| **Starter Pack** (once per account) | in the store with a "NEW" badge after your first egg; for 48 h (not a pop-up) | exclusive **Starter Spirit** (Epic tier, Shop Exclusive strength) + **5 Daily Exclusive Eggs** + **5 Mega Potions** + **2× Boost tier 1** | **49** |
| **Zone Pack** | on entering a new zone; for 24 h | **15 eggs of that zone + 5 Daily Exclusive Eggs + 2 Mega Potions** | **149** |
| **Comeback Pack** | in the store with a badge after 3+ days away; for 24 h (not a pop-up) | **8 Daily Exclusive Eggs + 5 Mega Potions** | **99** |

## 12. Pop-up offers (only two)

| Trigger | Offer |
|---|---|
| **Your first meditation ends** | **"2× Boost: ×2 Power and ×2 Luck forever, 3 R$"** (tier 1 of the ladder: the best first-purchase hook) |
| **Entering a new zone** | **Zone Pack** (24 h, real timer) |

- **Rules:** never during a boss, a hatch reveal or a cutscene; always a big ✕; no fake timers or discounts.
- **Everything else** lives in the R$ Store, where players go looking for it.

## 13. Where the store lives

- **The HUD:** the **R$ Store**, **Buffs** and **Hourly Reward** buttons.
- **At every Shrine:**
  - the Daily and Shop Exclusive Egg stands, with this month's pets on pedestals;
  - the Verity stand with its live counters;
  - the leaderboards (Power, Secrets, Boundless).
- **Mats are communal.**

## 14. Expected best sellers (genre pattern, not a forecast)

1. The 2× Boost ladder (the cheap tiers sell to almost every payer).
2. Exclusive Eggs.
3. +2 Pet Slots (repeatable).
4. VIP and the ×2 passes.
5. The Aura Pass.
6. Potions, Mutation Storms, coin packs, and the machine products (Enchant Crystals, XP Shards, Raid Summons).

**Track:** payer %, revenue per daily player, D1 / D7 retention, best sellers, and the two pop-ups' conversion.

## 15. Machine and endgame products (owner: yes)

Each goes live when its machine ships (GAME-BIBLE 13).

| Product | R$ | What it does | Type |
|---|---|---|---|
| **Enchant Crystals** | 10 for 49 · 50 for 199 | rolls at the Enchant Forge | repeatable |
| **Nursery+** | 199 | 5 nests in the Spirit Nursery instead of 3 | pass |
| **Nursery Hurry** | 25 | finishes one nest's stay now (its full Shiny chance and gift still roll) | repeatable |
| **Relic Shards** | 49 · 199 | levels relics at the Relic Shrine | repeatable |
| **XP Shards** | 49 · 199 | about 10 / 50 levels' worth of pet food (endgame min-maxing, Awakening) | repeatable |
| **Raid Summon** | 99 | starts the zone's raid boss **now** for the whole server, with a "Thanks to [buyer]!" banner | repeatable |

- **The Weekly Limited Egg** is bought with **coins** (the Nexus Titan's coins), not Robux, so the endgame grind has a goal. Coin packs (section 4) still help, since they scale to your zone.
- **The reward-share rule** (fight actively, and deal 8% of the damage, a quarter of the median active fighter's, or half of your own build's output; GAME-BIBLE 9) means a Raid Summon buyer can't carry players who don't fight, and a strong buyer can't push real fighters out.

## 16. Build timing and checks

- **Not in the two-zone playtest build.** Built straight after playtest #1, before zones 3-10 go live.
- **Before launch (CORE-GAME tests):**
  - every odds card adds to 100% and matches the rolls at the player's luck;
  - `PolicyService` gating for every item in section 17 (fail-safe: restricted until known);
  - Limited counters with two servers buying at once;
  - every Robux purchase granted exactly once;
  - serial numbers never duplicated.

## 17. Regional rules for paid random items (PolicyService)

Roblox doesn't let some players (by region / age policy) **buy random items with Robux**. That includes random items bought with **anything Robux can buy**, such as coins from coin packs. `PolicyService:GetPolicyInfoForPlayerAsync(player)` says who:
- **`ArePaidRandomItemsRestricted`**: this player can't pay for random results;
- **`IsPaidItemTradingAllowed`**: whether this player may trade items bought with Robux.

> **Source:** Roblox's *Paid random items policy guidelines* (creator-docs, read from the official GitHub mirror). It says paid random items include those bought with **in-game currency purchasable with Robux**, and also **probability modifiers** (luck boosts, pity systems, enhanced resource drops). Restricted users must get one of these treatments: an earnable free path, a fixed disclosed order, direct purchase of the outcome, removal or hiding, or a blocked purchase with a message. `IsPaidItemTradingAllowed` false means they must not trade paid items or the results of paid random items. Re-check the page before monetization ships, in case it has changed.

**The principle for a restricted player:** nothing they pay Robux for may be **spent on a random result** or **improve the odds** of one, directly or through a currency or item Robux can buy. Free play stays fully random and fully playable.

| Thing | Why it's a paid random item | For a restricted player |
|---|---|---|
| **Daily / Shop Exclusive Eggs** | bought with Robux, random pet | not sold; the **direct-buy shop** (section 6) sells the exact pet |
| **Zone eggs and the Weekly Limited Egg** (coins) | coins can be bought with Robux, so a coin egg could be Robux-funded | **coins must stay 100% earned:** coin packs, the coins in packs, Coin Potions and the coin parts of 2× Coins and VIP are **not sold or not applied**. Then coin eggs are free random items and stay open |
| **Paid luck:** 2× Boost ladder (its luck half), 2× Secret Luck, VIP's Secret luck, Luck / Mega Potions, Server Luck Boost, the Aura Pass's +50% luck | improves the odds of a random roll for Robux | not sold / not applied. The ladder is shown as a **2× Power ladder** (same prices, Power only). A **Server Luck Boost bought by someone else** still applies (they paid, not this player) |
| **Enchant Crystal packs** | random enchant rolls for Robux | not sold; crystals earned in play still roll |
| **Mutation Storm (product), Mutation Magnet** | changes the chance / value of random mutations for Robux | not sold; natural storms still happen |
| **Nursery+ and Nursery Hurry** | more or faster Shiny rolls for Robux | not sold |
| **Raid Summon** | starts a raid whose drops include random items | not sold (others' summons still apply) |
| **Packs** (Starter, Zone, Comeback) | contain eggs and coins | a **restricted version**: the eggs become fixed pets of the same tier (the direct-buy prices' worth), the coins become Power Potions |
| **Aura Pass** | gives Exclusive Eggs | the eggs become fixed pets of the same tier; no luck bonus |
| **Fixed items** (slot packs, Power / XP Potions, Hatch ×8, 2× Hatch Speed, Huge Storm, Auto-Sell, Offline+, Relic Shards, XP Shards, the Verity Limiteds) | deterministic | sold normally |

- **Already-owned passes:** a pass bought before a player became restricted keeps its **non-random** parts. Its luck and coin parts don't apply while restricted, and the pass page says so.
- **Trading:** if `IsPaidItemTradingAllowed` is false, the **trading booths are closed for that player** (a clear message). For everyone, trades are items for items, never Robux.
- **Odds before every random roll** that can involve anything paid: egg cards, enchant tiers (I 50% / II 28% / III 15% / IV 6% / V 1%), Shiny chance, mutation chances, Titan and raid drop tables.
- **Fail-safe:** the policy is fetched on join and retried. **Until it's known, or if it fails, the player is treated as restricted.**

### 17.1 What a player already owns (stored paid value)

Turning off future purchases isn't enough: coins, eggs and boosts bought **before** a player became restricted are still paid value. So every account tracks **where its value came from, for everyone, all the time**, and the rules apply **when value is used**, not when it was bought.

- **Two coin balances:**
  - **Earned coins:** selling shards at ×1, quests and rewards;
  - **Paid coins:** coin packs, pack coins, gifts of coins, and the **extra** part of any paid coin multiplier (2× Coins, VIP, Coin / Mega Potions). For example, a 2× Coins sale of 100 adds 50 earned + 50 paid.
  - The HUD shows one total. The wallet screen shows the split.
  - **Spending order for everyone:** deterministic purchases (bag, mat and Surge upgrades) spend **paid coins first**; random purchases (eggs, the Weekly Limited Egg, the Reactor if it ever rolls) spend **earned coins first**. That keeps a player's earned coins free for random items.
  - **For a restricted player:** random purchases may use **earned coins only**. Paid coins still buy every deterministic thing. Nothing is deleted or frozen beyond that.
- **Tagged items:** every egg in the inventory, every Enchant Crystal, Shard Vault mutation shard and boost carries a source tag: **free** (rewards, quests, the Titan, hatch rewards) or **paid** (bought with Robux, from a pack or the Aura Pass, gifted by another player, or bought with paid coins).
  - **Restricted player, paid-tagged unopened eggs:** they can't be opened. The player chooses to **keep them locked** (they open if eligibility returns) or **exchange each one now** for a fixed pet from the direct-buy table worth **at least** the egg's price (the Daily Exclusive Egg → the 49 R$ Common Daily pet, upgraded to the Uncommon pet for a 3-pack or 10-pack egg). The exchange is shown with the exact pet before confirming.
  - **Paid Enchant Crystals:** same choice: locked, or exchanged 1:1 for **Relic Shards** (deterministic).
  - **Active paid luck boosts** (potions, the ladder's luck): their **luck part is paused** (the timer stops, so nothing is lost). Power and other fixed parts keep running.
  - **Free-tagged items always work.**
- **Gifts:** the Gift button checks the **recipient's** policy on the server before the prompt opens. A restricted recipient (or one whose policy isn't known yet) can only receive deterministic items: no eggs, coins, Enchant Crystals or luck. Gifts already received before the change follow the tag rules above.
- **Pets already hatched** from paid eggs are **kept and usable**. They are tagged **paid-origin** and can't be traded while `IsPaidItemTradingAllowed` is false.
- **Eligibility changes either way:** the policy is read on **every join** and applied to every use, not cached on the account.
  - Restricted → allowed: locked eggs and crystals unlock, paused luck resumes, and paid coins can be used on anything again.
  - Allowed → restricted: the rules above apply from that join on. Nothing already used is undone.
- **Odds disclosure** (everyone): every random roll that can involve anything paid has a **"Details" button with a word, not just an (i)**, listing every outcome as a percentage. They sum to exactly 100% (rounded values carry the "Probabilities are rounded" note), and the shown odds update live with your active luck.

- **Tests:** CORE-GAME P16 (a-i).
