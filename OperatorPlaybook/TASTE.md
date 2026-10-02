# TASTE: the gallery that learns exactly what the owner likes

Rules describe the owner's taste in words. The gallery shows it in pictures, and it grows only from work Winter and the owner do **together**. Over time, it is the most accurate record of what he likes.

## Folders

```
ClaudePlugins/
  taste/
    INDEX.md            one line per entry (newest first), searchable by category
    loved/              things WE made that the owner liked
    rejected/           things WE made that the owner disliked
  references/           inspiration the owner sends, and references Winter finds online
                        (never mixed into taste/)
Project/ART/refs/       this project's references + source URLs
```

**What goes where:**
- `taste/loved` and `taste/rejected`: **only our own work.** Screenshots, renders, frames or clips of things Winter made and the owner judged.
- **The owner's references** (games he likes, images he sends): `references/` or the project's `ART/refs/`. Never `taste/`.
- **References Winter finds online:** the project's `ART/refs/` (with source URLs). Never `taste/`.
- **Small defects** (a label 3 px off, one overlapping badge): fix them; they're bugs, not taste. Don't log them here, and never remake for them. A full remake happens ONLY when the owner completely dislikes the design.

## The loop (every time the owner judges a piece of work)

1. **Show the work** (after it passed Winter's own review).
2. **The owner gives his verdict:** loved / liked / small fixes / completely disliked.
3. **Ask him WHY, every time, for both loved and rejected work.** Keep it short and specific, for example: "What made it work for you: the colours, the shape, the motion, the feel?" or "What's the worst part: the style, the colours, the layout?"
4. **Save the entry:**
   - the image(s) go to `taste/loved/` or `taste/rejected/`, named `<date>_<category>_<short-name>.png`;
   - add one line to `INDEX.md`:
     `date | loved/rejected | category | game + style | file | owner's words (verbatim) | Winter's takeaway (one line)`
   - Categories: gui, icon, model, vfx, animation, world, lighting, audio, video, feel, monetization.
5. **Only when he completely dislikes the design: remake it completely fresh, with a different approach.** (Smaller complaints: fix exactly what he named; keep the rest.) Don't patch the rejected version.
   - **Research first, online:**
     - the top Roblox games in this style;
     - outside references (game UI galleries, art sites, trailers);
     - the loved entries in this category.
   - Save the useful finds to the project's `ART/refs/` with URLs.
   - **Generate new concepts on the GPU** from those references (ComfyUI), several options, and pick the strongest. Then build from them in Blender / Inkscape.
   - Pick an approach that is clearly different from the rejected one (a different layout, shape language, palette or technique), and say in one line what changed and why.
   - Show the remake. Repeat the loop.
6. **Link pairs:** when a remake is loved, its INDEX line says `replaces <rejected file>`. The pair (bad → good) is the strongest lesson there is.
7. **When a rejection reveals a general rule** (the same "why" twice), propose it as a RULES.md / STYLE.md line to the owner.

## Using the gallery

- **Before starting any visual or feel work:** read the INDEX lines for that category (and for the same style, if this game has one). Look at the 3-5 most relevant loved and rejected images.
- **In every review** (PIPELINE section 6, sense "Taste"), ask:
  - Is this closer to the loved entries or the rejected ones?
  - Does it repeat any rejected "why"?
- **Style matters:** a loved stud-style GUI isn't automatically right for a realistic game. Read the owner's words to see whether he liked the style or something deeper (clarity, bounce, colour pop). Deeper reasons apply to every style.
- **Keep the INDEX lean:** if it passes about 150 lines, summarise older lines into "patterns" at the top (e.g. "loves: sliding shine, chunky outlines, bold auras; hates: grey chips, static gloss, code-posed animation"). Keep all the images.

## Seeding

The gallery starts empty on purpose: it fills only from real judgments made from now on. Past corrections are already written into RULES.md and LESSONS.md. If the owner wants, older work he clearly judged (with his words still on record) may be added, marked `seeded`.
