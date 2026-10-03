# STYLE SHEET: Aura Clash

Owner's direction (2 Oct 2026): **cartoony anime, extremely polished. Smooth "plastic" ground, not realistic. Highlights and outlines on things. Colourful, but good.** Every lane brief quotes the key lines below.

## Style in one line

**"Glossy toon anime": soft, rounded cartoon shapes with anime faces and effects, smooth candy-plastic surfaces with crisp highlights and clean dark outlines, saturated colour on calm bases.** Think a premium toy that came to life in an anime.

## What "colourful yet good" means (the rule that makes it work)

Colourful games look cheap when everything is loud. Ours stays good because of **colour hierarchy**:
1. **Bases are calm:** ground, rocks and buildings use soft, slightly muted pastels (saturation about 40-60%).
2. **Things that matter are loud:** crystal monsters, shards, pets, auras, the SELL button and eggs get the fully saturated colour and the glow.
3. **One hero colour per object** plus one accent; no rainbow objects except Rainbow spirits.
4. **Value contrast first:** in a greyscale screenshot, the player, the target monster and the pets must still pop out from the ground.

So the screen is colourful everywhere, but your eye always lands on the loot and the action.

## Best-in-style references (what we take from each)

| Reference | What it nails | What we take |
|---|---|---|
| Pet Simulator 99 | spotless, glossy, readable pets and breakables | the cleanliness and the plastic gloss on loot |
| Brawl Stars / Squad Busters | toy-like shapes, thick outlines, chunky polish | the outline weight, rounded silhouettes, juicy UI |
| Genshin Impact / Zelda: Breath of the Wild | anime cel shading, painterly skies | cel-style light bands, stylised skies and clouds |
| Anime Defenders / Anime Fighting Simulator | anime auras and energy on Roblox | aura shapes, speed lines, impact frames |
| Kirby / Fall Guys | soft plastic ground and props | the smooth, glossy "toy-world" ground |

Winter researches the current top games in this style online before the concept pass, and saves the finds to `ART/refs/` with source URLs.

## Target frames (art bible)

`ART/bible/01-09.png`, generated on the GPU and approved by the owner once:
1. the player in the Training Grove with a full Shard Storm and pets lounging around them;
2. a PERFECT blast shattering a Crag Brute, pets pouncing;
3. Overdrive chaining across a pack of Shardlings, one of them a Gold mutation;
4. the Sell Altar cash-in;
5. a Legendary hatch;
6. the Stone Golem beam clash;
7. the Lava Dojo overview;
8. the HUD over gameplay;
9. meditation at the Shrine: players sitting on mats, auras flaring, pets in circles around them.

## Look

| Area | Rule for this game |
|---|---|
| **Shape language** | Round, soft and chunky: bevelled edges everywhere (no sharp 90° corners on props), slightly oversized heads and paws on pets, big readable silhouettes. The crystals on monsters are the only sharp shapes, so they stand out as the thing you hit |
| **Palette** | Zone 1 Training Grove: mint grass `#8EE3B0`, warm path `#F5D9A8`, sky `#9FD8FF`, crystals cyan/violet `#4FE6FF` `#B36BFF`. Zone 2 Lava Dojo: warm stone `#E8A07A`, dark rock `#5B3A4A`, lava `#FF6A2B`, crystals red/gold `#FF3D5A` `#FFC93D`. Shards cyan `#5FF0FF`, Bright Shards gold `#FFD84A`, Gems magenta `#FF4FD8`. Bases 40-60% saturation; hero objects 85-100% |
| **Materials** | **Smooth plastic everywhere:** low roughness (0.2-0.35), no realistic textures (no grass blades, dirt or rock photos). Surfaces get **soft gradients** (lighter on top, darker at the base) and baked ambient occlusion in the colour. Crystals are glossy and slightly see-through with an inner glow. Pets are soft-matte plastic with a gloss highlight on the head |
| **Ground** | Sculpted, smooth meshes (not Roblox terrain): rounded grass mounds, bevelled paths and soft rock blobs, with gentle gradient colour and painted-in shadow. Small decoration is simple shapes (lollipop trees, round bushes, pebble clusters) |
| **Outlines** | Clean dark outlines on characters, pets, crystal monsters, eggs and key props, built in Blender as an **inverted-hull mesh** (a slightly bigger back-faced shell in a darker shade of the object's own colour, never pure black). Thickness scales with object size. Ground and background get none or thin ones, so foreground pops. **Don't use Roblox Highlight instances for outlines** (there's a limit of 31 and they cost performance); Highlight is only for the selected target ring |
| **Highlights** | A crisp specular "shine" on every glossy object (a baked highlight shape on top + engine specular), plus a **rim light** on characters and spirits so they separate from the background |
| **Lighting + grade** | Future lighting, bright and warm. Soft shadows, light blue ambient (not grey), gentle bloom (only bright crystals and auras bloom), slight colour correction (saturation +0.1, contrast +0.05). A stylised gradient sky with big soft clouds. Each zone has its own light mood |
| **Concept generation (GPU)** | ComfyUI on the owner's GPU: an anime / toon model (an SDXL anime checkpoint or FLUX with a toon LoRA), prompts with "glossy toon, cel shaded, thick clean outlines, smooth plastic, pastel base, saturated accents", the reference images above as inputs. Several options per asset; the best go to the owner once |
| **Build route for visible models** | Blender, from the approved concept sheets: smooth bevelled models, gradient vertex colour or small painted textures, the inverted-hull outline, baked AO and highlight → Roblox |
| **UI** | Chunky rounded panels with a thick dark outline and a soft inner gradient; a bold rounded font (e.g. Fredoka One or Lilita One) with a dark stroke; glossy candy buttons with a white highlight strip and a press-down animation; icons are glossy 3D-looking renders of the real items with an outline. Numbers pop and bounce |
| **VFX** | Anime energy: bold shapes with hard edges (not wispy smoke), 2-3 colour bands per effect (a white-hot core, a saturated middle, a darker edge), speed lines, impact frames (a 1-2 frame flash on PERFECT), sparkle stars, and shards that glint. Auras flicker like anime flames. Crazy at hero moments (ladder level 5), readable in normal play |
| **Sound** | Bright and satisfying: glassy crystal clinks and shatters, deep "thoom" blasts, a rising pitch on combos, a coin cha-ching cascade, upbeat anime-pop / lo-fi music per zone, big orchestral hits for hatches and bosses |
| **Motion** | **Snappy and bouncy:** squash and stretch on hits and UI, overshoot then settle, fast anticipation then a big release. Pets are bouncy and cute when idle, sharp when attacking |

## Zone palettes (zones 3-8, same rules: calm pastel bases, loud loot)

| Zone | Bases | Accent / crystals | Light mood |
|---|---|---|---|
| 3 Frost Peaks | snow white `#EEF6FF`, pale blue rock `#BFD7EA` | ice cyan `#7FE7FF`, aurora green `#7DFFB2` | cool, crisp, aurora sky |
| 4 Storm Cliffs | slate lilac `#9A90B8`, cloud grey-blue `#C9CDE6` | electric yellow `#FFE34D`, violet `#9B5CFF` | dramatic, flickering lightning |
| 5 Sakura Realm | blossom pink `#F7C6D9`, moss green `#9ED39A` | hot pink `#FF5FA2`, jade `#2FD6A0` | soft golden afternoon |
| 6 Void Rift | deep plum `#3B2A55`, dusk violet `#5C4A80` (darker zone, still never black) | void magenta `#E04BFF`, rune cyan `#4BF0FF` | moody, glowing runes |
| 7 Galaxy Throne | navy space `#1E2A5A`, nebula purple `#4B3C8C` | star gold `#FFD86B`, comet blue `#6BC8FF` | starry, planets in the sky |
| 8 Celestial Gate | cloud white `#FFF8EC`, soft gold `#F2DFA6` | pure gold `#FFC93D`, halo white `#FFFFFF` with prism edges | radiant, heavenly bloom |

## Never in this game

- No realistic textures: no photo grass, dirt, bark, rock or wood grain.
- No Roblox terrain for visible ground (it looks realistic and can't be outlined).
- No pure-black outlines or harsh black shadows.
- No grey, muddy or desaturated hero objects.
- No everything-at-full-saturation screens (calm bases, loud loot).
- No thin, wispy, realistic smoke or fire: anime shapes only.
- No default Roblox fonts or flat, outline-less UI.

## Taste constants (always, from craft/STYLE.md section 1)

Polished • readable at a glance • bright, about 10% under first instinct • clean • alive • worth it • original • truthful • simple to understand
