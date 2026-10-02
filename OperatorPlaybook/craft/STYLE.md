# STYLE: every game gets its own style, always in the owner's taste

Games differ: a stud / brick pet game, a cartoony simulator, an anime fighter, a realistic car game. Winter adapts to whatever style the game calls for. Inside that style, the result must still be **how the owner likes things**.

So every game has two layers:
1. **The owner's taste constants:** they never change, whatever the style.
2. **The game's style sheet:** this game's look, written once at planning and approved with the brief.

Every craft guide's "bar" means the bar **in this game's style sheet**. Where a craft guide says "cartoony", that is the default, used only when no style sheet says otherwise.

## 1. The owner's taste constants (every style, every game)

These came from his corrections. They apply to brick, cartoon, anime and realistic games alike:

- **Polished and finished.** Nothing looks placeholder, cheap, empty or unfinished. Quality is consistent everywhere, side places included.
- **Readable at a glance.** The hero thing is the most visible; silhouettes are clear; no two items look alike; colours match their names.
- **Bright and appealing, never washed out or blown out.** About 10% less saturated than a first instinct, but still lively. The world never looks dark or muddy unless the style sheet says moody.
- **Clean.** No overlap that hurts, no floating or sinking, nothing over functional surfaces, no seams or leftovers.
- **Alive.** Idle motion on focal things, juice on every action, sliding shine sweeps on buttons, hype that's big and bouncy.
- **Worth it.** Premium items look and feel premium (hero effects); plain items stay plain but well made.
- **Original.** Fresh art for every project; no free models; no generic flag props or filler banners.
- **Truthful.** Hype is real; no fake urgency.
- **Simple to understand.** Icons + numbers + 1-3 word labels; an 8-year-old knows what to do next.

## 2. Find the style (planning step, before the brief is approved)

1. **Ask what the game is,** and what the owner pictures. If he hasn't said, propose 2-3 style directions with one frame each (local FLUX / SDXL) and recommend one.
2. **Study the best games in that style.** Look at the top 3-5 Roblox games (and outside references) that nail it. Write down what makes them work:
   - shape language;
   - palette;
   - materials;
   - lighting;
   - UI feel;
   - effects;
   - sound.
3. **Write the style sheet** (`templates/STYLE-SHEET.md`) and build 5-10 target frames for the art bible.
4. **The owner approves it once,** with the brief. After that, every lane brief quotes the style sheet's key lines.
5. **Check it holds:** every review compares against the style sheet AND the taste constants. If a lane drifts toward the default cartoony style in a non-cartoony game, that's a defect.

## 3. Style profiles (starting points; the style sheet adapts them)

### Stud / brick / classic Roblox (e.g. Stud Pets, Stud Gear)

- **Shapes:** chunky brick forms, visible studs on top surfaces, classic proportions, bright primary + candy colours.
- **Materials:** plastic with a soft specular highlight; studs as real geometry or a crisp stud texture, never a blurry decal.
- **Build route:** Blender like every style: brick forms, real modeled studs and bevelled plastic edges, from GPU concept sheets. The clean-geometry, support and joinery rules apply strictly.
- **Effects:** brick-shaped or stud-shaped particles, confetti, pop bursts; classic Roblox sounds re-imagined (not ripped).
- **UI:** bold blocky font, brick-plate panels with studs, chunky outlines.

### Cartoony simulator (the default)

- Chunky rounded forms, real bevels, cel-shaded candy colours, thick outlines on UI and icons, rainbow hype.
- Everything in craft/GUI.md section 1 applies as written.

### Stylised / anime

- **Characters:** VRoid / VRM with real anime faces, hair and eyes, plus hand-keyed animation. Never code-posed.
- **Look:** cel or toon shading where possible, rim light, strong line-like silhouettes.
- **Effects:** ink / energy / speed lines, smears on fast frames, painted flipbooks.
- **UI:** cleaner, sharper panels, dynamic angled shapes, impact-frame flashes for hero moments.

### Realistic / semi-realistic (vehicles, horror, sims)

- **Models:** measured from photos (overlay checks within about 2%); PBR materials with real roughness / metalness; proper panel gaps.
- **Lighting:** Future, physically sensible values, subtle grade.
- **UI:** minimal, readable, modern. The candy style is wrong here; the taste constants still apply (readable, alive, clean, hype where it sells).
- **Sound:** recorded / layered real sounds; engine sounds with RPM-based pitch and layers.

### Low-poly / minimal

- Flat or gradient shading, strong silhouettes, a limited palette (8-12 colours), clean geometry with no bevel noise.
- Effects: simple shapes done perfectly. Timing and colour carry the effect.

## 4. Mixing styles

A game may mix styles (a cartoony UI on a realistic car, studs on a cartoony world). Write the mix into the style sheet:
- which parts use which style;
- what ties them together (a shared palette, a shared outline weight, a shared motion feel).

## Senses: what to catch

- [ ] Every asset matches the style sheet; nothing drifts toward a different style.
- [ ] Every asset passes the taste constants.
- [ ] The style is consistent across models, UI, effects, sound and video.
- [ ] Compared side by side against the target frames, not from memory.
