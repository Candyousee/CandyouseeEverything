# GAMEPLAY: core loop, feel, progression, economy, onboarding, retention

## 1. Expand the owner's seed into one streamlined system

The owner gives seeds ("open the parcels", "speed coils that actually work"). First judge the seed (RULES 12), then expand it:

1. **One dead-simple loop:** do the core action → get a juicy reward → buy things that make the core action better / faster / cooler → repeat.
2. **Feed the core loop.** New mechanics are TOOLS for the one thing players do constantly, not separate modes or side systems.
3. **Think in systems, not items:** data-driven tables (families × designs × colours × rarity; tiers × unlocks × thresholds × prices). Variety then scales cheaply and can be gated by progression.
4. **Fewer, deeper things.** Flag:
   - overlapping concepts (modes vs zones vs tools);
   - extra currencies;
   - thin tiers;
   - text-heavy screens.
5. **Every action is a meaningful choice or a satisfying skill.** Animation and particles on an action with no decision and no skill won't hold players.
6. Tell the owner the expanded design in a short list (what, why, order), then build in phases. Each phase is fully playable before the next.

## 2. Feel (the hand)

- **Response:** input → visible / audible response in under 100 ms, every time. Predict on the client, confirm on the server.
- **Juice on every core action:**
  - a squash / stretch or punch-scale on the thing hit;
  - a particle burst;
  - a sound;
  - a number pop;
  - a small camera kick on big moments.
- **Weight:**
  - acceleration and deceleration curves (no instant full speed / instant stop);
  - landing impact on jumps;
  - hit-stop of 2-4 frames on strong hits.
- **Camera:**
  - comfortable default distance;
  - no clipping into walls;
  - consistent FOV (a brief punch only on dashes and big hits).
- **Controls on every platform:** keyboard + mouse, touch (thumb-reachable buttons, ≥ 44 px), gamepad (every action mapped, menus navigable with selection).
- **State pairs:** anything turned off for a mode (controls, camera, anchoring, input gates) is turned back on when leaving it. Test with real input: hold W and measure the distance moved.
- **The 50-repetitions test:** is the core action still satisfying the 50th time? If not, add variation, escalation or choice.

## 3. Progression

- **First minute:** a reward in the first minute; one obvious next action at all times.
- **First purchase offer** at about 3 minutes, never during the tutorial.
- **Unlock cadence:** the first unlock within 5 minutes, then every 10-20 minutes early, stretching later.
- **Tiers:** qualify by playing, then buy the next tier with the main currency. Each tier raises earnings AND unlocks one visible, playable headline thing.
- **Long game:**
  - prestige / rebirth;
  - collections for completionists;
  - rotating content that is truthfully limited.
- **Multi-session goals:** daily rewards with a reason to return tomorrow (a streak, a timer that finishes, a crop that grows). Know where content runs out, and what a player does then.
- **Social:** visible status (titles, auras, leaderboards), co-op or trading where it fits, and something better done with friends.

## 4. Economy maths (always do the numbers)

- Earn rate per minute at each stage, the price of each upgrade, and **payback time** (target 10-20 minutes early).
- Minutes to each unlock for a free player. A paid player is faster, never the only way.
- Check that no side activity out-earns the core loop, and that multipliers stack sanely (multiply vs add; caps).
- Check that every upgrade improves the actual bottleneck, and that rewards grow with progress.
- **Model outliers, not just averages:**
  - dry streaks (a 1% drop still leaves 36.6% of players empty-handed after 100 tries);
  - the 90th-percentile grinder;
  - stockpiling inflation.

  Use a small Python model (with a seeded RNG, simulating many players) for anything with currencies or odds.
- **Pity / bad-luck protection** on rare drops: a guaranteed drop by N tries.
- **Clamps:** decide whether a cap limits the count or the reward. Capping the count also caps leaderboards and features built on it.

## 5. Onboarding

- **Show, never lecture:** arrows / highlights on the next action; 1-3 word labels; icons + numbers.
- **Teach one mechanic at a time,** each solvable from what the player sees.
- **No popup chains;** offers wait until after the tutorial.
- **The noob gate:** the youngest target player (about 8 years old) knows what to do next on every screen, with no reading beyond 3 words.
- **Return session:** a returning player sees what changed (what's ready, what's new) in one glance.

## 6. Evidence

- **Bot or persona playtests** test clarity and find bugs. They are not proof of fun or demand: label them that way.
- **Autoplay soak** through the real input paths (20 minutes) for feel, leaks and stability, at zero operator time.
- **After launch,** real retention (D1 / D7), funnel drop-offs and purchase conversion replace persona scores (craft/MONETIZATION.md).

## Senses: what to catch

- [ ] Input latency is invisible; every action has juice.
- [ ] Controls work on keyboard, touch and gamepad; state pairs are restored after every mode.
- [ ] Satisfying at 50 repetitions.
- [ ] Reward in the first minute, offer at about 3 minutes, unlocks on cadence.
- [ ] The economy table balances: payback 10-20 min early, no dominant side activity, outliers modelled.
- [ ] One clear loop; nothing confusing for an 8-year-old.
- [ ] A reason to come back tomorrow.
