# Aura Clash: document map (v5.1, 2 October 2026)

*"Meditate to grow your aura, hunt crystal monsters with your pets, and become the strongest in the server."*

| File | What it is | Authority |
|---|---|---|
| `CORE-LOOP.md` | **The core rules and numbers:** meditation, hunting, mutations, the bag / SELL, pets, Soul Food, the shop, rank quests, bosses, the first 8 minutes | **1st: wins on any conflict** |
| `CORE-GAME.md` | Everything around the core: eggs and hatches, the pet catalogue, aura, HUD, tutorial, server authority, **saving tests**, **playtest #1 criteria**, quality, later systems | 2nd |
| `STYLE-SHEET.md` | The look: glossy toon anime | the art rules |
| `GAME-PLAN.md` | Market, pitch, research, concept test, **build order**, design targets | plan |
| `HANDOFF-WINTER.md` | Winter's start sheet | plan |
| `econ/model.py` | The balance model: plays the rules second by second with simulated players | the source of every number in CORE-LOOP |
| `econ/tests.py` | 21 rule checks (`python tests.py`) | must pass |
| `econ/RESULTS.txt` | The model's output (`python model.py`) | |
| `archive/` | Old versions (v2.3 stone training, v4 crystal smashing, the v2 model) | **history only, not rules** |

**One rule for edits:** change a number = change it in `econ/model.py` **and** `CORE-LOOP.md` in the same commit, then re-run `python model.py` and `python tests.py`.
