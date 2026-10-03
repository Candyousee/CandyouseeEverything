# AURA CLASH: Monetization v1

**Goal (owner):** money is the top priority. Paid crates, limiteds and pop-ups are all allowed. We **follow Roblox's rules**, because breaking them gets games removed, and that costs more than any sale.

**How we make money without breaking the game:**
1. **Sell multipliers, not resources.** A 2× Coins pass doubles what you earn by playing. It doesn't hand out coins, so payers still play the loop and stay longer, which is where the money is.
2. **Free players must be able to finish.** They fill servers, and payers need an audience to show off to. Model: an average free player beats all 8 bosses in about **7 h 11**.
3. **Every paid item should be seen in use by others:**
   - VIP mats are gold;
   - Robux-egg hatches get server announcements;
   - Server Luck boosts thank the buyer by name;
   - Limiteds show their serial number.
4. **Odds, stock and timers are always real.**

---

## 1. What paying changes (model, average player, time to beat each boss)

| Zone | Free | VIP pass | Full bundle (VIP + 2× Coins + 2× Meditation + Lucky + 3 Slots) |
|---|---|---|---|
| 1 | 5:30 | 4:31 | 3:59 |
| 2 | 21:44 | 17:37 | 12:03 |
| 3 | 38:20 | 28:34 | 22:26 |
| 4 | 59:52 | 45:06 | 36:26 |
| 5 | 1:41:25 | 1:12:10 | 50:45 |
| 6 | 2:34:37 | 1:48:38 | 1:10:31 |
| 7 | 4:11:15 | 2:58:08 | 1:44:12 |
| 8 | **7:13:26** | **4:55:58** | **2:52:53** |

(`econ/RESULTS.txt` section 5. Potions, paid eggs and Limiteds come on top of this and aren't modelled.)

**Why this is the right shape:** passes feel worth it (about 1.5× to 2.5× faster), and nobody is locked out.

---

## 2. Game passes (one-time purchases)

| Pass | Price (R$) | What it does |
|---|---|---|
| **VIP** | 499 | ×1.5 coins from selling, ×1.5 meditation (offline too), +1 pet slot, a **gold VIP mat** at every Shrine, VIP chat tag and name colour |
| **2× Coins** | 399 | everything you SELL is worth ×2 (stacks with VIP: ×3) |
| **2× Meditation** | 349 | Power from meditation ×2, including AFK and offline |
| **Lucky** | 299 | ×2 luck on eggs: Legendary, Mythic, Divine and Secret chances doubled (the egg card shows your real odds) |
| **Super Lucky** | 699 (needs Lucky) | ×3 luck in total |

**Luck stacking:** passes × potions × Server Luck multiply, **capped at ×10 in total**. The egg card always shows the odds at your current luck.

| **+3 Pet Slots** | 449 | 3 more equipped pets (above the 10 from quests) |
| **Hatch ×8 + Auto-Hatch** | 349 | hatch 8 at once; auto-hatch keeps buying the selected egg |
| **Huge Storm** | 249 | ×2 bag capacity (the storm visual stays capped, so no lag) |
| **Auto-Sell** | 199 | your storm sells itself the moment it's full, with no teleport and full value |
| **Offline+** | 199 | offline meditation at 50% (not 25%) and up to 16 h (not 8) |
| **Mutation Magnet** | 299 | your mutated shards are worth ×1.5 |

**Bundle offer:** VIP + 2× Coins + 2× Meditation + Lucky for **1,199** instead of 1,546. It's shown in the store as "Best value". Model: the bundle plus +3 Slots is the "full bundle" in section 1.

## 3. Developer products (buy again and again)

| Product | Price (R$) | What it does |
|---|---|---|
| **Coin Potion** | 49 (5 for 199) | ×2 sell value for 15 min (time stacks) |
| **Luck Potion** | 49 (5 for 199) | ×2 egg luck for 15 min (stacks with Lucky) |
| **Meditation Potion** | 49 (5 for 199) | ×2 meditation for 15 min |
| **XP Potion** | 39 | ×2 pet XP for 15 min |
| **Mega Potion** | 129 | all four for 15 min |
| **Server Luck Boost** | 199 | **everyone in the server** gets ×2 egg luck for 15 min. A big banner reads "Thanks to [buyer]!" (social pressure, and the buyer is a hero) |
| **Mutation Storm** | 299 | **everyone in the server** gets ×2 monster mutation chance for 10 min |
| **Treasure Shards** | 49 / 199 | a sack of the current zone's shards dropped into your storm, worth about 10 / 50 minutes of average hunting. You sell them like any shards (the most "pay-to-skip" item: kept, because the owner wants every lever, but never shown in pop-ups) |
| **Exclusive Egg** (paid random item, section 4) | 99 / 3 for 279 / 10 for 849 | exclusive pets |
| **Limited pet** (section 5) | 1,499 | a numbered pet with real, capped stock |
| **Starter Pack** (one-time) | 99 | section 6 |
| **Zone Pack** | 299 | section 6 |
| **Aura cosmetics** | 99-399 | aura colours, fist trails, storm skins (sakura petals, galaxy dust…). Looks only |

**Gifting:** every pass and product has a **Gift** button that sends it to a friend in the server.

## 4. Exclusive Eggs (paid random items: the biggest earner in pet sims)

- **The egg:** a rotating **Exclusive Egg** (a new theme every month), sold for Robux at a glowing stand by the zone 1 Shrine, visible from spawn.
- **Its pets:** exclusive pets that **scale to your best unlocked zone**, so they stay useful all game.
  - **Odds:** Epic 70% / Legendary 25% / Mythic 4.5% / Divine 0.45% / **Huge 0.05%**.
  - **Huge:** a giant version with its own 10 s hatch and a global announcement.
- **Strength:** the same rarity table as normal pets ×1.5, at your best zone's scale (an "Exclusive" badge). A **Huge** has base Strength 150 (×1.5 a Secret) and is 3× the size.
- **Roblox rules for paid random items (required):**
  1. **The odds are shown on the egg card before purchase.** They add to 100% and are the real odds; Lucky and potions do **not** change paid-egg odds, so the card never lies.
  2. **Regional restrictions:** on join, the server calls `PolicyService:GetPolicyInfoForPlayerAsync(player)`. If `ArePaidRandomItemsRestricted` is true, that player **never sees the Exclusive Egg**. They see a **direct-buy shop** instead (pick the exact exclusive pet, at a fixed price: Epic 149, Legendary 399, Mythic 999).
  3. **No cash-out:** paid pets can only be traded for items, never sold for Robux.
- **Pity** (honest): every 50 Exclusive hatches without a Mythic or better guarantees one. The counter is shown on the card.

## 5. Limited pets (real scarcity)

- **What:** one **Limited** pet a month (for example the "Founder's Phoenix"), **5,000 copies worldwide**, 1,499 R$ each, numbered #1-#5,000.
- **The counter is real:** a global count kept on the server (MemoryStore + DataStore), with a live counter on the stand. When it hits 0, it's gone forever.
- **The end date is real.** Leftover stock after 30 days is retired, never quietly restocked.
- **Status:** the serial number shows on the pet card and over the pet ("#0042"). Low numbers are status, and tradable later (item-for-item).

## 6. Packs (offered at the right moments)

| Pack | When it's offered | Contents | Price |
|---|---|---|---|
| **Starter Pack** (once per account) | after your first egg (about 2 min); available for 48 real hours | exclusive **Starter Spirit** pet (Epic, scales to your zone), 3 Luck + 3 Coin Potions, 1 h 2× Meditation | **99 R$** (shows "worth 400 R$") |
| **Zone Pack** | when you enter a new zone; for 24 real hours | 5 eggs of that zone + a Mega Potion + a zone-themed aura trail | 299 R$ |
| **Comeback Pack** | after 3+ days away | 3 Mega Potions + 1 Exclusive Egg | 199 R$ |

## 7. Aura Pass (season, every 30 days)

- **Tiers:** 50, earned with Pass XP from daily and weekly challenges (defeat 200 monsters, meditate 10 min, hatch 30 eggs, defeat 3 mutated monsters…).
- **Free track:** potions, eggs, a title at tier 50.
- **Premium track** (**499 R$**, or **1,199 R$ with 15 tiers skipped**):
  - an exclusive season pet (scales);
  - an exclusive aura colour and fist trail;
  - storm skins and Exclusive Eggs;
  - a "Season X Champion" title.
- **Tier skips:** 79 R$ each.
- **Why it earns:** it pays well and pulls players back daily (retention is revenue).

## 8. Pop-up offers (allowed, with hard limits so they don't drive players away)

| Trigger (a real "want" moment) | Offer |
|---|---|
| Storm full twice within 2 minutes | Huge Storm / Auto-Sell |
| First Legendary-or-better hatch | Lucky pass ("Double your chances") |
| Boss lost twice in a row | 2× Meditation / a Meditation Potion. **Always alongside the free tip** "or meditate about N more minutes" |
| Entering a new zone | Zone Pack (24 h, real timer) |
| After the first egg | Starter Pack (48 h, real timer) |
| The "while you were away" screen | Offline+ |
| A Rainbow or better mutation spawns | Mutation Storm ("Make it rain mutations for everyone!") |
| Inventory full | +3 Pet Slots / Hatch ×8 |

**Limits:**
- **Frequency:** at most 1 pop-up per 10 minutes and 4 per session, and none in the first 2 minutes (except the Starter Pack after the first egg).
- **Never** during a boss fight, a hatch reveal or a cutscene.
- **Always a clear, easy-to-hit ✕.** Closing it never costs anything.
- **No fake timers, fake stock or fake discounts.** Every "worth X" is the real sum of the parts at store prices.

## 9. Free growth levers (they bring players who later pay)

- **Group reward:** join the Roblox group for +5% egg luck, permanently.
- **Roblox Premium members:** +10% coins. This keeps them playing, which earns Premium engagement payouts.
- **Private servers:** 100 R$/month (players farm mutations in peace).
- **Daily reward:** a small potion each day, so it feeds the potion habit.

## 10. Where the store lives

- **Store button:** on the HUD (a glowing **R$ Store** button).
- **Stands at every Shrine:** the Exclusive Egg stand (glowing, with the current pets spinning on pedestals) and the Limited stand with its live counter.
- **VIP mats** are gold and sit at the front of the Shrine ring, where everyone sees them.

## 11. Expected best sellers (genre pattern, not a forecast)

In pet simulators, most revenue usually comes from:
1. paid eggs;
2. luck items (Lucky passes, Luck Potions, Server Luck);
3. ×2 passes;
4. Limiteds;
5. season passes.

Our plan covers all five. Real numbers come only from live data:
- **Track:** payer %, revenue per daily player, best-selling items, and conversion of each pop-up trigger.
- **Rule:** cut any pop-up that drops session length.

## 12. Build timing

- **Not in the two-zone playtest build.** The playtest must prove the game is fun on its own first.
- **Built straight after playtest #1 passes,** before zones 3-8 go live, so launch has the full store. Stubs (the Store button and stands) can be placed early as art.
- **Before launch, check:** every odds card adds to 100%; PolicyService gating is tested in Studio with a restricted test account; Limited counters are tested with two servers buying at once (never oversold).
