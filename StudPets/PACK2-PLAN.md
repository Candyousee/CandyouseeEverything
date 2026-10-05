# Stud Pets 2: MYTHICS (plan)

**The pitch:** 100 **original** fantasy creatures in the same blocky, studded Stud Pets style, but **glowing**: neon cores, crystal horns, flame tails, storm manes, each with its own small particle effect. Every creature is animated straight from code, like pack 1.

**Why this pack:**
- **Pack 1 sold** (2 sales in 12 h after a quiet first 3 days). Buyers clearly want blocky animated pets.
- Pack 1 already covers the real animals and the classic myths (Unicorn, Pegasus, Alicorn, Griffin, Kitsune, Jackalope, Hellhound, Frost Wolf, Qilin, Yeti, Phoenix, three Dragons). **Pack 2 reuses none of them.** Every creature here is new and made up, so the two packs don't compete; they sell each other.
- **Glow + effects** is what pet-simulator developers want for their rare pets. Pack 1 is the commons and uncommons; pack 2 is the legendaries.
- **Drop-in compatible:** same `PetAnimator` API, same animation names (`Idle`, `Walk`, `Run`, `Sit`, `Jump`, `Sleep`, trick), same package layout. A game using pack 1 can add pack 2 with no code changes.

## 1. What's in it

- **100 creatures** in **10 elemental families of 10**. Each family has one **Legendary**: a big hero creature (1.8-2.2× size) with the best effects.
- **Body plans** reuse pack 1's four animation sets: four-legged, flyer, swimmer, two-legged. Winged four-legged creatures use the dragon wing animation.
- **Glow:** chosen parts use Neon (cracks, cores, eyes, horn tips, runes).
- **One signature effect per creature** (at most 2 particle emitters): flames, embers, snow, sparks, bubbles, petals, shimmer, smoke, stars, steam or sprinkles. Effects have a **Low / Off switch**, because pet simulators show many pets at once.
- **A new trick, `Power`,** for every creature: a short elemental burst (the flame flares, the storm crackles, the crystals flash). Each creature keeps its usual trick too.
- **Optional: Shiny variants.** Each creature also gets an automatic Shiny palette (gold-and-rainbow trim, a brighter glow): **100 creatures, 200 models**. It's cheap to make, because the palette is generated, and "200 variants" matches pack 1's headline. **Owner's call** (section 6).

## 2. The 100 creatures

Plan: Q = four-legged, F = flyer, S = swimmer, B = two-legged, QW = four-legged with wings. ★ = Legendary.

### 2.1 EMBER (fire and lava): charcoal and black bodies, orange-yellow neon

| Creature | Plan | Look | Glow / effect | Trick |
|---|---|---|---|---|
| Cinderpup | Q, small | a charcoal pup with glowing lava cracks along its back | cracks glow, sparks from the tail | Spin |
| Moltusk | Q, large | a stocky boar of cooled lava with magma tusks | tusks and belly glow, smoke puffs | Roar |
| Blazehorn | Q | a ram whose curled horns burn at the tips | flames on the horn tips | Rear |
| Flarecat | Q | a sleek cat with flame ear-tufts and tail tip | flame tufts | Stretch |
| Scorchling | B, tiny | an imp-lizard with an ember crest | crest glows, ember hops | Dance |
| Ashwing | F | an ash-grey bird with glowing wingtips | spark trail when flying | Loop |
| Kilnback | Q | a tortoise whose shell is a tiny volcano | the crater glows, smoke rises | Spin |
| Sparkmite | F, tiny | an ember beetle | glowing abdomen | Loop |
| Lavaline | S | a lava eel that swims through the air | glowing stripe | Flip |
| ★ **Infernox** | Q, 1.9× | a towering ox with a molten core in its chest and burning horns | the core pulses; flame horns, heat shimmer | Roar |

### 2.2 FROST (ice and snow): white and pale blue, icy cyan neon

| Creature | Plan | Look | Glow / effect | Trick |
|---|---|---|---|---|
| Snowpuff | Q, tiny | a round snowball body on tiny legs, with frost blush | sparkling snow | Spin |
| Glacibex | Q | an ibex with ice-crystal horns | the horns glow | Rear |
| Rimewhisker | Q | an arctic otter-cat with frosted whiskers | frost breath | Stretch |
| Shiverwing | F | a swallow with icicle feathers | snowflake trail | Loop |
| Frostling | B | a little ice sprite with a crystal cap | the cap glows | Dance |
| Permafang | Q, large | a woolly sabre-cat with ice fangs | the fangs glow | Roar |
| Floe | S | an ice-plated manta | the plate edges glow | Flip |
| Hailmoth | F, tiny | a moth with frosted lace wings | snow dust | Loop |
| Blizzbun | Q, small | a rabbit with cloud-puff ears that snow | snow falls from the ears | Spin |
| ★ **Glaciarch** | Q, 1.9× | a mammoth-sized ice stag with aurora antlers | aurora-gradient antlers, snowfall | Roar |

### 2.3 STORM (lightning and wind): slate and purple bodies, electric yellow neon

| Creature | Plan | Look | Glow / effect | Trick |
|---|---|---|---|---|
| Zapkit | Q, small | a static-charged kitten with spiky fur | crackling sparks | Spin |
| Thunderhoof | Q, large | a storm horse with a cloud mane and bolt markings | the mane flickers with lightning | Rear |
| Joltferret | Q, small | a long ferret with a lightning-bolt tail | the tail glows | Stretch |
| Stormcrest | F | a hawk with a lightning crest | arcs on the crest | Loop |
| Cloudpup | Q | a puppy made of storm cloud | drizzle and tiny flashes | Spin |
| Thunderbug | F, tiny | a beetle with a glowing battery back | pulse | Loop |
| Gustling | B | a wind sprite with swirling scarf ribbons | wind swirl | Dance |
| Staticray | S | an electric ray floating in the air | crackling edges | Flip |
| Voltram | Q | a ram with coiled copper horns | arcs jump between the horns | Roar |
| ★ **Skyrend** | QW, 1.9× | a thunder lion with storm wings | lightning wings, a little rain cloud | Roar |

### 2.4 TIDE (ocean and the deep): teal and navy bodies, bioluminescent cyan neon

| Creature | Plan | Look | Glow / effect | Trick |
|---|---|---|---|---|
| Bubblepup | Q | a seal-dog with a bubble collar | bubbles | Spin |
| Coralhorn | Q | a deer whose antlers are pink coral | the coral glows | Rear |
| Lanternfin | S | a fish with glowing lantern fins | the fins glow | Flip |
| Shellguard | Q | a crab-turtle with a spiral shell | the shell spiral glows | Spin |
| Ripplejelly | F (floats) | a floating jellyfish | pulsing glow | Loop |
| Tidewyrm | S | a sea serpent | glowing fin ridge | Flip |
| Pearlpaw | Q | an otter with a glowing pearl on its forehead | the pearl glows | Stretch |
| Reefling | B | a fish-frog sprite with fin ears | water drips | Dance |
| Gloomsquid | S | a squid with glowing spots | the spots glow | Spin |
| ★ **Leviathorn** | S, 2.2× | a huge horned whale-serpent with glowing lines | the lines glow; water spray | Flip |

### 2.5 BLOOM (nature and flowers): greens and pinks, soft yellow-green neon

| Creature | Plan | Look | Glow / effect | Trick |
|---|---|---|---|---|
| Mossbun | Q, small | a rabbit with a moss coat and a flower on its head | drifting petals | Spin |
| Blossomkit | Q | a kitten with petal ears | the petals glow softly | Stretch |
| Thornback | Q | a hedgehog-boar with thorn quills | thorn tips glow | Roar |
| Sproutling | B, tiny | a walking sprout with leaf arms | leaves sway | Dance |
| Mushpup | Q | a puppy with a mushroom cap | glowing cap spots | Spin |
| Vineserpent | S (floats) | a floating vine snake with flowers | blooms glow | Flip |
| Pollenwing | F | a butterfly-bird | pollen trail | Loop |
| Oakhorn | Q, large | a moose with branch antlers and leaves | falling leaves | Rear |
| Lilytoad | Q | a frog with a lily pad on its back and a flower | the flower glows | Spin |
| ★ **Elderroot** | Q, 2.0× | an ancient tree-turtle with a glowing tree growing on its shell | the tree glows; floating spores | Roar |

### 2.6 CRYSTAL (gems): stone grey bodies, gem-coloured neon

| Creature | Plan | Look | Glow / effect | Trick |
|---|---|---|---|---|
| Shardpup | Q, small | a puppy with gem shards on its back | the shards glow | Spin |
| Prismcat | Q | a glass-crystal cat | rainbow shimmer | Stretch |
| Amethorn | Q | a stag with amethyst antlers | the antlers glow | Rear |
| Quartzbill | F | a toucan-like bird with a crystal beak | the beak glows | Loop |
| Geodillo | Q, small | an armadillo whose shell opens into a geode | the geode inside glows | Spin |
| Rubyscale | Q | a lizard with ruby scales | the scales glint | Roar |
| Opalmoth | F | a moth with opal wings | colour-shifting shimmer | Loop |
| Glassfin | S | a see-through fish with a gem heart | the heart glows | Flip |
| Pebbleguard | B | a small stone golem with crystal fists | the fists glow | Dance |
| ★ **Diamane** | Q, 1.9× | a diamond lion with a prism mane | the mane throws sparkles | Roar |

### 2.7 SHADOW (void and spooky): black and indigo bodies, violet neon

| Creature | Plan | Look | Glow / effect | Trick |
|---|---|---|---|---|
| Gloomkit | Q, small | a black kitten with a smoke tail | violet eyes, smoke | Stretch |
| Umbrafang | Q | a wolf made of smoke, with void cracks | the cracks glow | Roar |
| Hexbat | F | a bat with rune-marked wings | the runes glow | Loop |
| Nullmoth | F | a moth with glowing eye-patterns on its wings | the patterns glow | Loop |
| Wraithling | B | a hooded little ghost-imp | it floats; wisps | Dance |
| Duskstag | Q, large | a stag with smoke antlers | smoke trails | Rear |
| Voidray | S (floats) | a manta with a starry void skin | stars twinkle | Flip |
| Bonepup | Q | a skeleton puppy with glowing ribs | the ribs glow | Spin |
| Phantomare | Q, large | a see-through ghost horse | a ghostly trail | Rear |
| ★ **Oblivore** | QW, 1.9× | a void beast with a portal in its chest | the portal swirls; smoke wings | Roar |

### 2.8 CELESTIAL (stars and space): deep blue bodies, gold and starlight neon

| Creature | Plan | Look | Glow / effect | Trick |
|---|---|---|---|---|
| Starpup | Q, small | a puppy with star-shaped spots | the stars twinkle | Spin |
| Moonhare | Q | a hare with crescent-moon ears | the ears glow | Spin |
| Cometail | F | a bird with a comet tail | a comet trail | Loop |
| Nebulacat | Q | a cat with galaxy-patterned fur | stardust | Stretch |
| Ringtoad | Q | a toad with rings that orbit it like a planet's | the rings orbit | Spin |
| Starwhale | S | a small whale with constellation skin | the constellations glow | Flip |
| Sunmane | Q | a golden lion-pony with a sun halo | the halo glows | Rear |
| Lunamoth | F | a moon-pale moth | silver shimmer | Loop |
| Meteorling | B | a rock sprite with a glowing crater | the crater glows | Dance |
| ★ **Aurorion** | QW, 2.0× | a celestial lion-pegasus with nebula wings | the wings glow; stars orbit it | Roar |

### 2.9 MECHA (robots and clockwork): steel and brass bodies, blue or red neon

| Creature | Plan | Look | Glow / effect | Trick |
|---|---|---|---|---|
| Robopup | Q, small | a boxy robot puppy with an antenna | the screen-face and antenna glow | Spin |
| Gearcat | Q | a clockwork cat with a spinning gear tail | the gears turn | Stretch |
| Brassowl | F | a brass owl with lens eyes | the lenses glow | Loop |
| Drillmole | Q, small | a mole with a drill nose | the drill spins | Spin |
| Hoverdrone | F | a pet drone with propeller ears | thruster glow | Loop |
| Tanktortle | Q | a tortoise with a turret shell | the turret light glows | Roar |
| Mechaptor | B | a robot raptor | glowing joints | Roar |
| Subfin | S | a submarine fish with portholes | the portholes glow; bubbles | Flip |
| Steamstride | Q, large | a horse with steam pipes | steam puffs | Rear |
| ★ **Omegatron** | B, 2.0× | a mech gorilla with a reactor core | the core pulses; vent steam | Roar |

### 2.10 SWEETS (candy): pastel bodies, glossy, candy-pink and mint neon

| Creature | Plan | Look | Glow / effect | Trick |
|---|---|---|---|---|
| Gummybear | Q | a see-through gummy bear | glossy shine | Spin |
| Sprinklepup | Q, small | a frosted puppy with sprinkle spots | sprinkles fall | Spin |
| Cupcakitten | Q, small | a kitten with a cupcake-wrapper body and a cherry on top | the cherry glows | Stretch |
| Lollibird | F | a bird with lollipop-swirl wings | swirl shimmer | Loop |
| Mallowsheep | Q | a marshmallow sheep | soft puffs | Spin |
| Mintdeer | Q | a deer with candy-cane antlers | mint sparkle | Rear |
| Jellyfin | S | a jelly-bean fish | glossy shine | Flip |
| Cocobun | Q, small | a chocolate bunny with a foil bow | glints | Spin |
| Flossling | B | a cotton-candy cloud sprite | floss wisps | Dance |
| ★ **Sugarwyrm** | QW, 1.9× | a candy dragon with rock-candy spikes | the spikes glow; sprinkle trail | Roar |

**Mix:** 59 four-legged (4 of them winged), 17 flyers, 13 swimmers and 11 two-legged. Pack 1's four animation sets cover every one.

## 3. What the build needs (new kit features)

Pack 1's kit (`build/rigs/Kit.luau`, `Animals.luau`) already has most parts: horns, antlers, wings, shells, quills, crests, manes, multiple tails, glowing eyes and a glowing tail tip. New for pack 2:

| Feature | Use | Notes |
|---|---|---|
| **`glow = { parts }`** | Neon material on any named part (cracks, cores, horn tips, runes, spots) | generalises the existing `eyeGlow` / `glowTail` |
| **`crystals`** | clusters of angled gem blocks (backs, antlers, fists) | a few presets: back, horns, mane |
| **`effect = "<preset>"`** | one signature particle effect (+ an optional second) on attachments | a preset library: Flame, Embers, Snow, Sparks, Bubbles, Petals, Shimmer, Smoke, Stars, Steam, Sprinkles. Low rates by default |
| **`orbit`** | parts that circle the pet (Ringtoad's rings, Aurorion's stars) | animated in `PetAnimator:Step` |
| **`see-through`** | glass, ghost, gummy and jelly bodies | transparency per part, readable on light and dark backgrounds |
| **`Power` trick** | a short burst of the creature's effect (and its glow flaring) | works for all four plans |
| **Effects switch** | `PetAnimator.SetEffects("Full" / "Low" / "Off")`, and a model attribute | for games showing many pets |
| **Shiny palette** (if chosen) | an automatic gold-and-rainbow trim + a brighter glow from each creature's own colours | one switch in the build |

**Budget per creature:** about as many parts as pack 1's bigger pets, **at most 2 particle emitters**, and Neon only on details (never a whole body).

## 4. Build order (using the pack 1 pipeline)

1. **Kit features** (section 3), tested on 3 creatures from different families (Cinderpup, Ripplejelly, Omegatron). Review the look and the effects before going wider.
2. **One full family end to end** (Ember): all 10 entries, rendered contact sheet, in-game follow test. **Owner look-check.**
3. **The other 9 families**, a few at a time, each with a contact sheet.
4. **QA** (pack 1's tests + new ones):
   - every creature plays all 8 animations (incl. `Power`);
   - effects respect the Low / Off switch;
   - no emitter leaks when a pet is destroyed;
   - 50 pets on screen at 60 fps with effects on Low;
   - the attach check.
5. **Package:** `StudPets2_CreatorStore.rbxm` (no running scripts; the same two-folder layout as pack 1), with a demo place where all 100 stand on pedestals by family.
6. **Previews:** see section 5.

## 5. The listing (what sells it)

- **Title:** `Stud Pets 2: MYTHICS - 100 Glowing Fantasy Pets (Animated)`. With Shiny: `... 100 Mythic Pets + 100 Shinies (Animated)`.
- **Thumbnail:** the 10 Legendaries lined up on a dark background, glowing, with "100 MYTHIC PETS" in big text.
- **Gallery images:**
  1. all 100 in a grid by family;
  2. each family's lineup (10 images);
  3. a close-up of the effects;
  4. the size lineup (tiny Sparkmite to the giant Leviathorn);
  5. "works with Stud Pets 1".
- **Video:** a 30-45 s showcase. Each family walks on with its effect, the Legendaries roar, then a pet-simulator scene with a mixed team following a player.
- **Description:** the feature list (100 original creatures, 10 families, 7+1 animations, glow + effects with a Low / Off switch, no asset IDs, no setup, drop-in compatible with Stud Pets 1), plus a short code example.
- **Cross-sell:** each listing's description links to the other pack, and pack 1's thumbnail stays untouched for now (it's selling).
- **Price:** start at **$2.99**, the price that's already proven. Consider a higher price later only if it sells as well as pack 1.
- **Names:** before publishing, search each of the 100 names to make sure none belongs to a famous game or brand. Swap any that do. (They were picked as made-up compounds, but check.)

## 6. Owner decisions

1. **Shiny variants** (100 creatures + 100 Shinies, one switch in the build): yes or no?
2. **Families:** keep all 10, or swap one (e.g. Sweets for Spirits / Ghosts, or Mecha for Dinosaurs-Mythic)?
3. **Price:** $2.99 like pack 1 (recommended), or higher because of the effects?
