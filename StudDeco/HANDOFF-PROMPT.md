# Stud Deco: Halloween, a self-contained handoff

**How to use:** upload this zip to Claude (the regular claude.ai chat is fine) and paste the prompt below. Claude writes one script per item. You paste each script into Roblox Studio's **Command Bar** (View > Command Bar, then Enter) and the model builds itself in front of the camera. Send Claude a screenshot to review.

**What's in the zip:**

| File | What it is |
|---|---|
| `style/studpets_hero.jpg`, `style/studpets_sheet.jpg` | **THE STYLE: my Stud Pets pack, which sells.** Copy this look exactly |
| `style/pumpkin_target_style.jpg` | a jack-o'-lantern already built in that style (day and night) |
| `studio/StudDecoBuilder.lua` | the builder script; Claude fills in the item data |
| `studio/JackOLantern_PetStyle.lua` | that pumpkin as a finished, working script (the worked example) |
| `HALLOWEEN-PLAN.md` | the 120 items to make, each with a reference code |
| `reference/items/R.C_NN.jpg` | the 300 reference items, cropped and zoomed. Code "1.1 #6" = file `1.1_06.jpg`. **Use these for WHAT each item is and its details, not for the look** |
| `failed_attempts/` | two rejected tries. Don't make these |

---

## PROMPT (paste this)

You're making a Roblox Creator Store pack for me: **Stud Deco: Halloween**, 100-120 Halloween decorations at $2.99. Everything you need is in the uploaded zip.

**The look = my Stud Pets pack (`style/`), exactly.** It sells, and the decorations must match it. The reference crops in `reference/items/` only tell you *what* each item is (a skull headstone, a cauldron, a lamp post) and its key details. **Translate each one into the Stud Pets style; don't copy the references' smooth clay look.**

### The Stud Pets style rules (study `style/` first)

1. **A few big, chunky boxes.** The main shape is 1-3 large blocks with simple, cute proportions. **Not** stepped layers, **not** voxel staircases, **not** spheres or cylinders.
2. **Studs on top.** The top face of every main block gets Roblox's Studs surface (`studs = true`). The studs are big and visible: that's the signature.
3. **Details are thin flat plates stuck on the faces** (0.1-0.15 thick), like the pets' eyes, muzzles, patches and stripes. Faces, ribs, planks, moss patches, bands and runes are all plates. Small wedges for ears, leaves, horns and triangle eyes.
4. **Flat, clean, saturated colours,** 3-5 per item. A darker shade of the main colour for detail plates. Matte Plastic.
5. **Glow:** carved faces, flames, potions and crystals are thin `neon = true` plates (warm yellow-orange, purple or toxic green) plus one PointLight.
6. **Small and cute:** most items are 2-5 studs wide, 10-40 parts. Readable from far away. Nothing thin or fiddly under 0.1.
7. **Scale:** a Roblox avatar is about 5 studs tall. A pumpkin reaches the knee, a lamp post about 1.5 avatars, an arch is walk-through.

### How to make each item

- Copy `studio/StudDecoBuilder.lua` and replace `--ITEM_DATA--` with the item table, exactly as in `studio/JackOLantern_PetStyle.lua`.
- Each part is `{ kind, name, {size}, {position}, {rotation in degrees}, {r,g,b}, studs = bool, neon = bool }`. Y is up, the item faces -Z, and its bottom sits at Y = 0.
- Give me **one complete script per item, in a code block**, ready to paste. Keep every part's size ≥ 0.1. No other scripts or instances.
- Before writing each item, check the parts in your head:
  - nothing floating;
  - plates sit 0.05 in front of the face they're on;
  - nothing overlaps on the same plane with the same colour (it flickers in Roblox);
  - studs only on top faces.

### Process

1. **First 3 items only:**
   - Skull Headstone (`1.2_03.jpg`);
   - Bubbling Cauldron (`2.1_01.jpg`);
   - Pumpkin Lamp Post (`3.1_01.jpg`).

   I'll paste them into Studio and send you screenshots. **Wait for my OK**, and fix anything I point out.
2. Then work through `HALLOWEEN-PLAN.md` in batches of about 10 by category, one script per item, with a short checklist of what's done.
3. Stay in the style. If an item can't be made cute and readable in a few boxes, tell me and suggest a swap.

### Rules

- Never spend money.
- Never ask for passwords or keys.
- The scripts only build models: no other code, no internet, no players, no saving.
