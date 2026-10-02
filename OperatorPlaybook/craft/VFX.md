# VFX: particles, beams, trails, flipbooks, impacts, auras, screen effects

## The bar

Effects that read as **energy**: flowing, wispy, translucent, additive. Never as objects.
- Good VFX = great textures on a few well-tuned emitters, not many plain ones.
- An effect has a shape over time (a build-up, a peak, a dissipation) and a clear silhouette at gameplay distance.
- Premium items get effects at hero quality in the game's own style; plain items get none (RULES 22).

**Never:**
- visible primitive shapes (blocks, cylinders, rings, squares);
- flat sticker cards that pop in and out;
- effects that block the gameplay view.

## Why VFX matter so much

In fighting games and pet / aura games, **effects are the reward**. Players grind for the aura, the move that explodes the screen, the pet that glows. Insane effects are why people come back and why they buy. So the VFX bar is the highest bar in the playbook, for hero effects especially.

## The VFX ladder (aim hero effects at level 5)

| Level | What it looks like |
|---|---|
| 1 | One emitter, default sparkle. Reads as "free model" |
| 2 | A few emitters, custom texture, but static and flat: everything starts on the same frame |
| 3 | Layered with timing offsets, shaped curves, colour matched. **"Solid"**: the crown aura was here |
| 4 | Level 3 + motion variety (orbit, rise, pulse), a light flash, secondary sparks, ground interaction, a state change when moving / idle |
| 5 | Level 4 + **"whoa" moments**: periodic power surges, screen-presence (bloom-catching cores, a subtle screen shake on big moves), unique silhouette shapes, a rarity escalation that makes higher tiers obviously insane. People stop and stare at it |

**The +1 pass:** when an effect looks finished, do one more pass aimed one level higher:
- more contrast;
- one more layer of motion;
- a stronger peak;
- a better silhouette.

The crown aura was solid and still needed more. This pass is the habit that closes that gap.

## Study the best first (every hero effect)

1. Find showcase videos of the top games for this effect type: top anime fighting games for moves; top pet / aura simulators for auras; VFX artists' reels.
2. **Frame-step them** (0.25x or frame by frame). Write down:
   - the layers;
   - the timing of each layer;
   - the colours;
   - the shapes;
   - how long the peak lasts;
   - the camera / screen effects.
3. Copy the **structure and timing**, never the art. Then make it fresh in this game's style.

## Hero aura recipe (pets, players, premium items)

Layers (each with its own timing; most loop at slightly different lengths so the whole never looks repetitive):

1. **Ground ring:** a decal or flat beam circle under the feet, rotating slowly and pulsing.
2. **Rising wisps:** a flipbook energy texture rising and swirling, additive, fading at the top.
3. **Orbiters:** 2-4 bright sparks or symbols (stars, crowns, hearts, in the game's style) orbiting on tilted paths (attachments + code, or a beam ring).
4. **Core glow:** a soft glow at the chest / centre, Brightness high enough to catch bloom.
5. **Sparkle field:** small twinkles appearing and fading around the body.
6. **Power surge:** every 3-6 s, a burst (a ring shockwave + a sparkle pop + a brief light flash). This is the "whoa" beat.
7. **Movement state:** while moving, a trail and the wisps stretch behind; while idle, the full aura.
8. **Rarity escalation:** each rarity tier adds layers or intensity (common: 2 layers; legendary: 5-6 layers + a surge + colour cycling). The top tier must look obviously insane next to the one below it.

Readable at 30 studs, beautiful at 5 studs, and never hides the character's silhouette.

## Fighting move recipe (attacks, abilities, ultimates)

1. **Anticipation (0.1-0.4 s):** energy gathering inward, a glow building, a sound rising.
2. **Release:** a 1-2 frame core flash + the main shape (a slash arc, a beam, a projectile), with a smear on the character's motion.
3. **Impact:**
   - hit-stop (2-4 frames frozen);
   - an impact frame on ultimates (a brief high-contrast / inverted flash on hits);
   - a shockwave ring;
   - debris / sparks with gravity;
   - a camera shake + an FOV punch;
   - a ground crack / scorch decal.
4. **Aftermath:** smoke / embers fading over 0.5-2 s, lingering residue.
5. **Escalation:** basic < skill < ultimate. The ultimate takes over the screen briefly (lighting shift, a ColorCorrection tint, slow-mo), always within the reduced-flash rules.

## Toolchain (free)

| Need | Tool |
|---|---|
| Organic shapes (splashes, smoke, fire, energy wisps) | **FLUX frames in ComfyUI, straight away.** Procedural organic passes were wasted twice |
| Controlled shapes (crescents, slashes, trails, rings, waves) | Blender (procedural / geometry nodes) rendered to frames, or painted in Krita |
| Simulation (smoke, liquid) | Blender Mantaflow → render frames |
| Flipbook sheets | ImageMagick `montage` into a 2x2 / 4x4 / 8x8 grid |
| Clean-up / alpha | rembg, Krita; premultiply-aware edges (no dark fringes) |

## Building blocks in Roblox

- **ParticleEmitter:**
  - `Texture` + `FlipbookLayout` (Grid2x2 / 4x4 / 8x8) + `FlipbookMode` (OneShot for impacts, Loop for auras);
  - `LightEmission` 0.5-1 for energy (additive feel); `LightInfluence` 0 for glowing effects;
  - `Brightness` for bloom-catching cores;
  - Size and Transparency curves always shaped: grow fast, fade slow, never linear on/off;
  - `Squash` for stretch, `Drag` + `Acceleration` for weight, `SpreadAngle`, `Rotation` / `RotSpeed` randomised;
  - `ZOffset` to sit in front of / behind the character.
- **Beam:** lightning, lasers, ropes, slash arcs. `Segments` + `CurveSize0/1`, `TextureSpeed` for flow, `FaceCamera` for ribbons, `Width0/1` tapered.
- **Trail:** swings and dashes. `Lifetime` 0.1-0.3, `WidthScale` tapering to 0, `MinLength` small, a gradient Transparency.
- **Bursts:** `:Emit(n)` for impacts, not `Enabled = true` + wait.
- **Lights:** a short PointLight flash on big impacts (≤ 0.15 s), then off.
- **Screen effects:** a camera shake (small, decaying, under 0.3 s), a brief FOV punch, a ColorCorrection flash for hero moments only.

## Concept first

Generate a frame sheet of the effect's key moments on the GPU (anticipation, peak, dissipation) from online references (top games, VFX reels) before building any emitter. Then build the textures and emitters to match it.

## Anatomy of a hero effect (layers, in order)

1. **Anticipation:** a small charge / gather (particles pulled inward, a glow rising).
2. **Core flash:** 1-3 frames, the brightest, smallest.
3. **Main shape:** the readable silhouette (a slash arc, a burst ring of wisps, a splash crown).
4. **Secondary:** sparks / debris / droplets with gravity and drag.
5. **Dissipation:** smoke / wisps fading and slowing.
6. **Residue (optional):** a ground decal or scorch that fades over a few seconds.

Each layer has its own timing offset. If they all start on the same frame, it reads as one flat pop.

## Quality tiers and accessibility

- Ship **High / Medium / Low / Off** profiles (particle Rate and count multipliers, flipbook off on Low).
- A **reduced-flash** option: no full-screen flashes; capped brightness pulses.
- Effects are cosmetic: gameplay never depends on seeing a particle.

## Performance

- Measure frame spikes with the effect runner **paused first** (a baseline). Instance churn under the character, not script time, caused about 70 ms spikes.
- **Pool** emitters and parts; reuse with `:Emit()`. Never create and destroy per hit.
- **Cap particles alive:** about 200-500 per effect on High, far fewer on Low.
- **Distance-cull:** disable effects beyond about 150 studs or off-screen.
- Rewrite properties only when they change (no per-frame writes of an unchanged value).

## Build every hero effect with a bake-off (craft/TOOLS.md section 3)

For a new effect type, sample 2-3 methods (e.g. FLUX frames vs a Blender sim vs Krita painting) for 15-30 minutes each. Compare in the VFX preview place and keep the winner's recipe on the mastery card.

## Senses: what to catch

- [ ] Reads at gameplay distance in a single frame (pause at the peak frame: is the shape clear?).
- [ ] Timing has build-up, peak and dissipation. No pop-in / pop-out.
- [ ] No visible geometric primitives; no hard card edges or square alpha borders.
- [ ] No dark fringes on additive textures; no flipbook "jump" between loops.
- [ ] Colour matches the item / element and the game palette; brightness doesn't wash out the scene.
- [ ] Shines and glints stay ON the surface (never sticking out past the silhouette).
- [ ] Doesn't block the gameplay focus or UI; reduced-flash mode works.
- [ ] Frame time stable during a 10x spam test; the Low profile looks intentional, not broken.
- [ ] Premium auras are bold and readable at 30 studs. A too-faint aura was sent back and rebuilt.
- [ ] Hero effects are at ladder level 5, and the +1 pass was done.
- [ ] Rarity tiers escalate obviously: the top tier is clearly insane next to the tier below.
- [ ] Compared side by side with frame-stepped references from top games.

## Traps (from real misses)

- Two procedural splash passes were wasted before switching to FLUX frames.
- The crown aura was solid (level 3-4) but needed more: no power surge, too little motion variety. Hence the ladder and the +1 pass.
- The first premium aura was "far too faint". The bar is bold, alive and readable at 30 studs.
- Static white gloss sat over icons and washed them out. Only the thin moving shine sweep passes over icons.
