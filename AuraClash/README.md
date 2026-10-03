# Aura Clash: document map (v6, 3 October 2026)

*"Meditate to grow your aura, hunt crystal monsters with your pets, and become the strongest in the server."*

| File | What it is | Authority |
|---|---|---|
| `GAME-BIBLE.md` | **Everything in the game:** the loop, controls, meditation, hunting, mutations, the storm and SELL, pets (9 rarities, stars 0-5, XP), eggs, the shop, quests, bosses, the aura, HUD, then **all 8 zones one by one** (monsters, pets, quests, boss, rewards, expected progress), the endgame and later systems | **1st: wins on any game-rule conflict** |
| `MONETIZATION.md` | Everything sold (v2): the buff system, Power and Luck ladders, passes, products, two Exclusive Eggs, Limiteds (serials), Aura Pass, hourly / daily / group rewards, packs, pop-ups, Roblox compliance | 1st for monetization |
| `CORE-GAME.md` | Server authority, **saving and purchase safety**, **acceptance tests P1-P18**, **playtest #1 criteria**, performance, what the model covers | 2nd |
| `STYLE-SHEET.md` | The look: glossy toon anime | the art rules |
| `GAME-PLAN.md` | Market, pitch, research, concept test, **build order**, design targets | plan |
| `HANDOFF-WINTER.md` | Winter's start sheet | plan |
| `econ/model.py` | The balance model: plays the rules second by second with simulated players, zones 1-8, free and paid | the source of every number |
| `econ/tests.py` | 26 rule checks (`python tests.py`) | must pass |
| `econ/RESULTS.txt` | The model's output (`python model.py`) | |
| `archive/` | Old versions (v2.3 stone training, v4 crystal smashing, v5.1 core loop, the v2 model) | **history only, not rules** |

**One rule for edits:** change a number = change it in `econ/model.py` **and** `GAME-BIBLE.md` in the same commit, then re-run `python model.py` and `python tests.py`.
