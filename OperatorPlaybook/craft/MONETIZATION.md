# MONETIZATION: passes, products, receipts, pricing, Open Cloud, analytics, live ops

## Principles

- **Worth buying:** every item IS what its name says and is worth its price.
- **Never pay-to-win:** sell cosmetics, convenience, Robux exclusives and bundles. Progression tiers are never sold directly.
- **Monetization never goes down:** a redesign keeps or raises selling power. BUY ME ribbons and hype stay.
- **Truthful only:** real countdowns, real rotations, real caps. No fake LIMITED, restarting timers or fake LAST CHANCE: these break kid-audience guidelines and risk moderation (zero income).
- **No paid random items.** If a random reward can be bought with Robux, or with currency Robux can buy:
  - show the odds;
  - gate it with `PolicyService:GetPolicyInfoForPlayerAsync(player).ArePaidRandomItemsRestricted`.

  Default: don't sell random items at all.

## What to create on every game (required, free)

- Game passes: permanent perks and cosmetics.
- Developer products: consumables, currency packs, boosts.
- Each one gets a name, a price, a description (kid-friendly, clear, truthful), and an icon in the project's cartoon style (512 px, square, round-safe).
- Prices sit on familiar steps: 25 / 49 / 99 / 199 / 399 / 799 Robux. Have a cheap entry item and a hero bundle with a clearly better per-unit value.

## Open Cloud (the operator may create these; never buy)

- `ClaudePlugins/tools/oc_products.ps1` creates passes and products from a products table and merges the ids into `PRODUCT-IDS.json`.
  - It skips ids it already has, so it is safe to re-run.
  - **Put an explicit Kind column** (pass / product) in the table. Don't infer the kind from row numbers.
  - Write the key file inside the `try`, so `finally` always deletes it.
- `ClaudePlugins/tools/oc_upload.ps1` uploads audio / decal / model assets. Use `-GroupId` for group-owned games.
- Show the owner the item list in chat when creating. Ids are written into source; no Studio-only edits.
- If the key lacks a scope for a new API, ask the owner to add it. Never work around it.

## Code

- **One receipt handler** for developer products:
  - grant idempotently (keyed by the receipt's purchase id);
  - save BEFORE returning success;
  - return "not processed yet" on any failure so Roblox retries;
  - follow the current Roblox docs for the handler API and its decision enum, and never mix the old and new APIs.
- **Passes:** grant only after `UserOwnsGamePassAsync` confirms ownership. The purchase-finished event alone is not proof.
- **Product info:** use the current async API (`GetProductInfoAsync`), and cache the results.
- **Test with fixtures** (a fake MarketplaceService in the harness), and with real prompts cancelled. Never complete a real purchase; even "test" products can spend real Robux.
- **Support path:** an admin tool re-grants a missing purchase from the receipt log. It never hand-edits a DataStore.

## Shop design (with craft/GUI.md)

- A hero banner with the best offer; few tabs; one price button per card; a product modal with ONE buy button.
- A starter pack offered once, after the tutorial (about 3 minutes in), never during it.
- A "next buy" nudge: show the next affordable upgrade, filling up as the player earns.
- Celebrate purchases: a burst, a sound, the item shown equipped.
- Hype ribbons on 1-2 focal items per screen, not everywhere.

## Analytics (free, built in; add to every game from day one)

- **Funnel:** `AnalyticsService:LogOnboardingFunnelStepEvent` / `LogFunnelStepEvent`, covering join → first action → tutorial done → first unlock → first offer seen → first purchase.
- **Economy:** `LogEconomyEvent` on every committed currency source and sink.
- **Custom:** `LogCustomEvent` for a few key milestones.
- **Verify events arrive in the live dashboard,** checked the next day. Studio firing proves nothing.
- **After a week of cohorts:** D1 / D7 retention, the drop-off step, offer → purchase conversion. Fix the biggest drop first.
- **Native Experiments** (A/B) only once the game has enough daily players to read a result (about 1,000+ DAU).

## Live ops (once a game is public; the owner makes it public)

- **Update cadence** the team can sustain; each update has one headline thing.
- **Before every update:** the save migration is tested, mixed-version safety is checked, and the live gate re-run (PIPELINE section 7).
- **Incident:** a broken update gets rolled back by republishing the previous version, never by editing live data. Write up what happened in LESSONS.md.
- **Events and limited items** use real dates and real caps.

## Senses: what to catch

- [ ] Every item is worth its price and is what it says; premium items carry hero effects.
- [ ] Every pass and product is created, priced, iconed and wired; the prompt is tested by cancelling.
- [ ] The receipt handler is idempotent and saves before success (fixture test).
- [ ] No pay-to-win, no fake urgency, no unguarded paid random items.
- [ ] Analytics events seen in the live dashboard.
- [ ] Shop changes didn't lower selling power.
