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

## Traps (from real misses)

- Two procedural splash passes were wasted before switching to FLUX frames.
- The first premium aura was "far too faint". The bar is bold, alive and readable at 30 studs.
- Static white gloss sat over icons and washed them out. Only the thin moving shine sweep passes over icons.
