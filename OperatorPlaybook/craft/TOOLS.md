# TOOLS: master every tool, and prove the best method instead of guessing

Picking the best free tool is only half the job. Winter must also use each tool **at its fullest**: the advanced features, the settings pros use, the workflows that give the best look in the least time.

This guide covers how Winter learns a tool, how it picks the best method for a task, and how that knowledge builds up across projects.

## 1. Mastery cards (one per tool, kept on the PC)

`ClaudePlugins/mastery/<tool>.md` (start from templates/TOOL-CARD.md). Each card holds:
- **What it's best at** (and what it's bad at; use another tool for those).
- **Full-power features:** the advanced features that make the biggest quality difference, with how to drive them from a script (Blender Python, the ComfyUI API, the CLI).
- **Proven recipes:** exact settings / node graphs / scripts that produced work the owner loved, linked to the taste gallery entry.
- **Speed tricks:** batching, headless runs, templates, presets.
- **Traps:** what crashed, what looked bad, and why.
- **Sources:** the official docs + the best tutorials found (URLs), and the version the card was written for.

**Read the card before using the tool. Update it after every task that taught something.** A card that grows every project is how Winter gets better at a tool over time.

## 2. Learning a tool properly (first use, or when the card is thin)

1. **Read the official docs** for the features this task needs (manual, API reference, release notes for the installed version).
2. **Study the best:** find 2-3 top tutorials or breakdowns of the exact result wanted (e.g. "stylised anime aura VFX", "Blender toon flipbook explosion"). Pull out the techniques, not just the settings.
3. **Drill:** do a 10-20 minute small test of each new technique on a throwaway file before using it on real work (e.g. one flipbook frame, one bake, one node graph).
4. **Write the card:** what worked, the exact settings, and a screenshot.

## 3. Choosing the method: the bake-off

When there's more than one way to make something (and there usually is), don't guess:

1. **List 2-3 candidate methods.** Example for a fire aura:
   - (a) FLUX-generated flipbook;
   - (b) a Blender Mantaflow sim rendered to a flipbook;
   - (c) a hand-painted Krita flipbook.
2. **Timebox a small sample of each** (about 15-30 minutes each): one frame or one short loop, at the real size, in the real engine.
3. **Compare side by side** in Studio, at gameplay distance, against the reference and the taste gallery.
4. **Pick on result first, then time:** the best look wins. If two look equally good, the faster one wins.
5. **Record the winner and why** on the mastery card, so next time there's no bake-off for the same kind of task.

Skip the bake-off when a card already has a proven recipe for this exact kind of asset.

## 4. Starting knowledge (core tools; cards grow from here)

### ComfyUI (local; concepts, textures, VFX frames)

- **FLUX.1** for concept art and organic shapes. **SDXL** where ControlNet / IP-Adapter support is better. **Qwen-Image** where text or layout matters.
- **IP-Adapter:** style from reference images (match a top game's look without copying it).
- **ControlNet** (canny / depth / lineart / openpose): lock a shape or pose from a sketch, a Blender render or a greybox screenshot.
- **img2img at low-medium denoise:** refine your own Blender renders into polished concepts.
- **Turnarounds:** a consistent seed + ControlNet from a simple Blender blockout at front / side / back.
- **Textures:** seamless / tiling options for materials. Then cleanup in Krita.
- **VFX frames:** generate on pure black backgrounds, convert luminance to alpha (or use additive blending) so edges stay clean.
- **Upscale** (Real-ESRGAN), and **rembg** for cutouts.
- **Batch through the API / queue:** many variations per run while doing other work, with seeds saved.

### Blender (models, bakes, VFX frames, renders)

- **Script everything repeatable** with Blender Python, run headless (`blender -b -P script.py`).
- **Modeling:**
  - modifiers (Bevel, Mirror, Array, Solidify, Weighted Normal) kept live until export;
  - **Geometry Nodes** for families and variations (one setup, many versions).
- **Concepts as background references:** image empties / reference images in the front / side views.
- **Baking:** Cycles bake for normal / AO / curvature; a palette atlas for stylised packs.
- **VFX frames:**
  - EEVEE (fast) with **Bloom / Glare** (compositor), transparent film, emission shaders driven by noise textures animated over time;
  - **Simulation Nodes / Mantaflow** for smoke, fire and liquid;
  - an orthographic camera + a frame range → render the sequence → pack it into a flipbook.
- **Toon look:** Shader-to-RGB + a colour ramp (EEVEE) for cel-shaded renders; Freestyle or inverted-hull outlines.
- **Export:** FBX / glTF with the Roblox add-on conventions (scale, front axis); check every export in Studio.

### Roblox VFX system (in-engine)

- ParticleEmitter, Beam, Trail, Attachments, PointLight, Highlight, ColorCorrection / Bloom (full detail in craft/VFX.md).
- **Driven from code:**
  - `:Emit()` bursts;
  - NumberSequence / ColorSequence curves built in code from a preset table;
  - pooled instances;
  - quality tiers.
- **A VFX preview tool in the project:** a test place / plugin that plays every effect on a dummy, at gameplay distance, with a slow-mo toggle. All effects are judged here.

### Krita / Inkscape

- **Krita:** hand-painted flipbook frames, texture cleanup, alpha work; brush presets for wisps / smoke / sparkles; animation timeline for flipbooks.
- **Inkscape:** vector icons (traced from GPU concepts, then cleaned); consistent outline widths; batch PNG export at several sizes via the CLI.

### Audio (ACE-Step, SoX, ffmpeg)

- **ACE-Step:** generate several variations per mood, then pick and loop-cut.
- **SoX:** layering, pitch variants, normalisation, fades, all scripted for batches.
- **ffmpeg:** conversions (`-vn`), loudness normalisation, video assembly.

## 5. Efficiency rules for every tool

- **Script it** if it'll be done more than twice.
- **Run long renders and generations in the background** while working on something else (one GPU job at a time, so they don't fight).
- **Template it:** starter .blend files, ComfyUI workflows and Studio test places per asset type, saved and reused.
- **Measure:** note how long each step took on the card. The next estimate is better, and slow steps get attention.
- **Re-check every tool's options quarterly,** or when a step felt slow: a new version or a better free tool may exist (lean-path).
