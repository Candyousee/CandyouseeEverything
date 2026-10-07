# Master prompt: continue Stud Deco: Halloween in a new cloud session

Paste everything below the line into a new Claude Code cloud session that has the GitHub repo **candyousee/candyouseeeverything** connected.

---

You're continuing a Roblox Creator Store asset pack for me: **Stud Deco: Halloween**, 100-120 Halloween decorations that I sell on the Creator Store. My first pack, Stud Pets, is already selling at $2.99. Halloween is 31 October and developers buy in the first half of October, so speed matters, **but quality matters more: I will not ship anything ugly.**

## Read first

The repo is `candyousee/candyouseeeverything`. Start from branch `claude/keen-ptolemy-kjwpm5`; if your session gives you its own branch, base it on that one.
- `StudDeco/HALLOWEEN-PLAN.md`: the 120-item list. Each item has a reference code like "1.1 #6": reference-sheet row.column, item number.
- `StudDeco/reference/halloween_refs.jpg`: **my reference sheet. This is the quality bar.**
  - Layout: 2000×1361 px, 6 rows × 5 columns of panels. Each panel is ~400×227 px, with 2 lines of 5 items: #1-5 on the top line, #6-10 on the bottom.
  - Each item stands next to a grey blocky avatar for scale.
  - Crop and zoom panels with PIL to study them.
- `StudDeco/preview/heroes_v1.png` and `heroes_v2_brick.png`: **two failed attempts. I said they look awful.** Don't repeat them:
  - v1 built shapes from smooth Roblox primitives (spheres, cylinders): too plain and too smooth;
  - v2 built everything from stepped studded blocks: crude, like a Minecraft voxel, nothing like the references.
- `StudDeco/build/`: the old parts-based kit, `build.luau` (Lune) and `render.py` (Blender). Reuse the renderer's ideas, not the modelling approach.

## What the references actually look like (match this)

- **Sculpted, chunky, toy-like models:**
  - soft rounded bevels on everything;
  - slightly irregular, hand-made clay / plastic shapes;
  - **small round studs scattered on surfaces** (that's the "stud" look: studs as surface detail, not a voxel grid).
- **Rich detail on every item:**
  - bases of dirt, moss, roots, grass tufts and little rocks;
  - pumpkin ribs, stems with curls and leaves;
  - wood grain planks, iron bands, rivets;
  - cobwebs, drips, chains.
- **Glow:** jack-o'-lantern faces, flames, potions and crystals emit warm orange, purple or toxic green light.
- **Palette:** pumpkin orange, witch purple, toxic green, bone cream, slate stone, dark wood, near-black, gold accents.

## How to build it (the method)

1. **Model in Blender with Python (`bpy`; `pip install bpy==5.0.1` if missing).** Use real modelling:
   - bevel and subdivision modifiers, lathe / screw for round things;
   - booleans for carved faces;
   - array or instancing for studs;
   - small displacement / jitter so it doesn't look machine-perfect.
   - One reusable function per common element: pumpkin, skull, stone base with moss, stud scatter, flame, candle, plank, chain.
2. **Export per item for Roblox:**
   - an FBX (or OBJ);
   - **≤ 10,000 triangles per item (aim for 2-5k)**, ≤ 3 materials, colours in materials or vertex colours;
   - glowing parts as a separate mesh named `*_Glow`, so they get Neon material + a PointLight in Studio;
   - the pivot at the base centre, real Roblox scale (an avatar is ~5 studs tall).
   - I'll import them into Studio myself with the 3D Importer (free). **Don't open or touch Studio, and don't upload anything.**
3. **Render every item** next to a grey 5-stud blocky avatar on a dark backdrop with warm key light, like the reference sheet.
   - **Make a side-by-side image: your render next to the crop of its reference item.**
   - Be brutally honest: if it isn't close to the reference, iterate before showing me.

## Process

1. **First, just 3 items:**
   - Classic Jack-o'-Lantern (ref 1.1 #1);
   - Skull Headstone (ref 1.2 #3);
   - Bubbling Cauldron (ref 2.1 #1).
   - Iterate until each side-by-side genuinely holds up next to the reference, then send me the side-by-sides and **wait for my OK**.
2. After my OK, build the rest in batches of 10-15 by category, sending a contact sheet per batch. Keep a running checklist in `StudDeco/PROGRESS.md`.
3. Commit and push after every batch. Put builds in `StudDeco/blender/`, exports in `StudDeco/export/` and renders in `StudDeco/preview/`.
4. At the end:
   - a contact sheet of everything;
   - a thumbnail scene (the hero items together at night);
   - the Creator Store listing text from HALLOWEEN-PLAN section 4;
   - a zip of all exports.

## Hard limits

- Never spend money or Robux.
- Never make anything public or change access.
- Never print or write API keys.
- Don't open Studio or touch my PC. I'm working on a game there.
- Work only in the cloud session and the repo.

Be efficient with usage: plan the modelling functions once, reuse them, and don't re-render everything for small tweaks.
