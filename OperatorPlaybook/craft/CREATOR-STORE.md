# CREATOR STORE: selling models, kits and systems

Check the current Roblox Creator Store selling rules before each new product type. They change.

## What sells

- **Underserved niches with demand:** things many creators need that rarely work well (e.g. obby gear that actually works, a pet system that drops in).
- **Drop-in, works in 2 minutes,** looks better than the free alternatives, and is configurable from one Config module.
- **A clear thumbnail and a 10-15 s showcase video** of the real product working (craft/VIDEO.md).

## Packaging rules (moderation and buyer success)

1. **No self-installing or auto-moving scripts.** Scripts that move themselves into services, or run setup code on insert, get flagged as "Misusing Roblox Systems".
2. **Numbered drop-in folders:** `1 - Put in ReplicatedStorage`, `2 - Put in ServerScriptService`, and so on. Plus a README ModuleScript with the setup in 3-5 steps.
3. **Scripts find their own folders anywhere** under the target service (a recursive search), because buyers drag whole numbered folders in.
4. **On-screen setup errors in Studio:** if something is missing, show a clear red note in Studio saying what and where. Never fail silently.
5. **Studio-safe:** works with Studio API access off (no DataStore stall; it plays without saving and warns).
6. **No `WaitForChild` on optional objects** (e.g. PlayerModule). Find them, or skip them.
7. **Every script is enabled in the built file;** check the Enabled flags.
8. **A tidy layout:** templates sit in neat rows behind the demo stands, facing the camera. Nothing piled at the origin.
9. **Original assets only** (made in Blender, fresh icons). No free models. Licences recorded for every source.
10. **Welds built offline use `Weld` + C0,** not WeldConstraints (craft/MODELING.md).
11. **Optional extras** (a test course, demo stands) go in their own numbered folder, so buyers can skip them.

## Before every upload

- **Fresh empty place test,** following ONLY the README: insert → drag the folders → Play. It works first time, with zero errors in Output.
- **The full offline test harness** passes (fake services, a virtual clock).
- **In-Studio check of every item:** looks (first and third person for gear), works, sounds.
- **Title:** short (under the store limit), with the key search words first. **Description:** what it does, the features list, setup in 3 steps, configuration notes.
- **Price:** free products build reputation; paid ones need a clear edge over free alternatives.

## Senses: what to catch

- [ ] A buyer with zero knowledge gets it working from the README alone.
- [ ] Nothing moderation-risky (self-moving scripts, require-by-id loaders, obfuscation).
- [ ] Templates are tidy; the demo place is a plain Baseplate.
- [ ] The showcase video shows only polished behaviour.
