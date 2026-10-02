# ANIMATION: rigs, character animation, procedural motion, cutscene cameras

## The bar

Motion that feels intentional:
- anticipation before an action, snap through it, follow-through and settle after;
- weight that matches the size;
- hero moves that look hand-made, not interpolated.

**Script-generated poses are never acceptable for hero character moves.** They are fine for simple mechanical motion (doors, spinners, bobbing pickups, UI).

## Choose the route at intake (the feasibility check)

| Need | Route that reaches the bar |
|---|---|
| Locomotion, idles, common actions | Mixamo (the owner's Adobe login) → Blender retarget → hand polish → R15 |
| Hero / combat / signature moves | Mixamo base or video capture → **hand-keyed polish in Blender or the Studio Animation Editor**: anticipation, smears, holds |
| Custom move from a video | Roblox Studio Animation Capture (video → animation), free, then clean-up |
| Anime-style character + face | VRoid Studio model + VRM rig + blendshapes; keyed animation |
| Mechanical / prop motion | Code: TweenService, springs, `CFrame` maths |
| Cinematic shots | Real gameplay capture + scripted cameras. Don't code-pose characters for "anime" shots: that was rejected as "awful" |

If no free route reaches the bar, tell the owner before building and offer the trade-off. Example: "you key 3 poses, I build everything else".

## Rigging for Roblox

- **R15:** 15 parts, Motor6D joints. Map Mixamo / VRoid bones to R15 names. Keep the root at the HumanoidRootPart.
- **Custom rigs** (pets, vehicles, creatures): Bones in a skinned MeshPart, or Motor6Ds between MeshParts.
  - Bones bind only inside one assembly.
  - Keep the bone count lean (under about 50 for pets).
- Test deformation at extreme poses (arms overhead, crouch, twist) before animating.
- **Avatar compatibility:** if players' own avatars play your animations, test on R15 with a few body scales and on blocky / Rthro avatars.

## Animation craft (Blender or the Studio Animation Editor)

1. **Block in key poses** first (stepped interpolation): contact, down, pass, up for walks; anticipation, strike, recovery for actions.
2. **Timing and spacing:** fast in, slow out of impacts; ease in / out on heavy things; snappy for small things. On 30 fps reference, hits land in 2-4 frames.
3. **Arcs:** hands, heads and weapons travel on arcs, not straight lines.
4. **Overlap:** hair, tails, capes, ears and antennae lag behind the body by 2-4 frames.
5. **Holds:** hold the strongest pose briefly (3-6 frames) so the eye can read it.
6. **Smears / stretch:** exaggerate the 1-2 fastest frames, and pair them with a VFX smear or trail (craft/VFX.md).
7. **Loops:** the first and last frames match; check for a pop at the seam at 0.25x speed.

## In Roblox

- `Animator:LoadAnimation`, with priorities (Core < Idle < Movement < Action < Action2-4). Use the right priority so walks don't override attacks.
- Upload through the Animation Editor or the Open Cloud animation upload. Animation ids must be owned by the experience owner (the group), or they won't play live.
- **Procedural layering:** springs on accessories, a head look-at, foot IK (`IKControl`) on slopes. Small touches with a big "alive" gain.
- **Code poses:** `Motor6D.Transform` each frame (RenderStepped / PreSimulation) for procedural motion. Combine with played animations carefully: Transform is overwritten by the Animator.
- **Anything attaching on CharacterAdded** must wait for full replication (the baked descendant count), not just the first child.

## Cameras for cutscenes and trailers

- Plan shots as a list: duration, lens (FOV), framing, subject, motion.
- Keep a 3-shot minimum variety: wide / medium / close.
- **Camera clearance:** raycast the camera path against geometry; never fly through signs or skim walls.
- Ease every camera move; no linear starts or stops.
- Thirds composition, the subject's eyes in the upper third, room for the action direction.

## Senses: what to catch

- [ ] Every action has anticipation → action → settle. Nothing starts or stops dead.
- [ ] No foot sliding in walks or runs (feet locked on contact frames, matched to WalkSpeed).
- [ ] No interpenetration in extreme poses (a hand through the torso, a weapon through the leg).
- [ ] Loops are seamless at 0.25x.
- [ ] Silhouette readable in the key poses (a black-fill check of the hero frame).
- [ ] Weight matches size: big = slower, heavier settle; small = snappy.
- [ ] The animation plays live (asset ownership) and at the right priority over walking.
- [ ] Watched at game camera distance AND close; frame sheets reviewed before the owner sees it.

## Traps (from real misses)

- The procedural anime clip: 13 shots of code-posed avatars, rejected outright. Choose the hand-keyed or retargeted route at intake.
- Measured animation "lag" in an unfocused Studio window (about 15 fps). Measure only with the window focused.
- Stretching every trail when freezing stills made the sword's own trails look like flat panes. Only stretch your own effects.
