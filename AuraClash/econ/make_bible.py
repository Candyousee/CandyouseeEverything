"""Writes GAME-BIBLE.md Part B (zone by zone) straight from model.py, so the numbers can never drift.
Run: python make_bible.py   (replaces the text between the ZONES markers in ../GAME-BIBLE.md; about 30 s)"""
import statistics as st
import model as M

ZONE_START = 14          # GAME-BIBLE section number of zone 1 (Part A ends at section 13)

TEXT = [  # per zone: element, the feel, layout, landmarks, materials, sky, ambient VFX, sound, storm, new unlock,
          # monster looks (small, middle, big), monster behaviours, boss look + arena, boss rage
    dict(element="Light", feel="a sunrise meadow where everything glows softly: safe, welcoming, wow-on-arrival",
         layout="**Lumora Plaza** (the game's hub) sits on a raised round terrace in the centre around the Shrine. Three hunting meadows fan out: **Shardling Meadow** (east: flower fields, gentle slopes), **Boar Hollow** (north: rolling hills with crystal-capped stones), **Brute Ridge** (west: a cliff ledge where the 3 Brutes stand against the sky). A path of glowing stepping stones leads south to the boss arena, the **Sunstone Ring**. The portal to Pyrora Dojo is a giant crystal archway, dark until the Golem falls, then it ignites orange",
         landmarks="the **Lumora Tree**: a huge tree behind the Shrine whose leaves are light crystals, slowly dropping glowing petals; floating paper-lantern lights; a **waterfall of light** pouring off a floating rock into a pond",
         materials="mint plastic grass mounds, cream stone paths with gold trim, round pastel rocks capped with cyan / violet crystals, soft white wood",
         sky="a warm sunrise gradient (peach → sky blue), big soft clouds, god-rays through the Lumora Tree",
         vfx="drifting light motes, butterflies made of light, crystals pulsing gently, petals",
         sound="birdsong and soft wind chimes; bright anime lo-fi music",
         storm="**Prism Shower:** rainbow light rain, the sky turns pastel rainbow",
         unlock="the Shrine, Sell Altar, shop, egg stand, **Fusion Altar** (★1-★2), and **the hub** (section 12): leaderboards, the store, rewards, teleporter",
         looks=("a round jelly slime with crystal spikes and huge cute eyes", "a chunky boar with crystal tusks and glowing back plates",
                "a rock gorilla-golem with crystal shoulders and a mossy back"),
         beh=("hops in packs", "charges down a red lane", "slams a red circle"),
         boss_look="a 3-storey rock giant with glowing cyan cracks and crystal plates on its chest and shoulders (the weak points). **Arena:** the Sunstone Ring, a hilltop stone circle at sunrise",
         rage="rolls boulders down red lanes (0.8 s warning): dodge sideways, or **PERFECT a boulder to blast it back** for big damage"),
    dict(element="Fire", feel="a dojo built inside a volcano: energetic, dramatic, glowing from below",
         layout="The **Shrine** is a fire-meditation dais in the dojo courtyard. Hunting grounds: **Ember Terraces** (stepped lava terraces like rice paddies), **Hound Canyon** (an obsidian canyon with lava rivers and wooden rope bridges), **Brute Forge** (an ancient forge of giant anvils). The boss arena, **Caldera Ring**, is a fighting stage floating on a lava lake",
         landmarks="a 5-storey **pagoda** hung with glowing orange lanterns; a giant bronze bell that rings on every boss win; lava falls down the crater walls",
         materials="warm terracotta stone, **glossy black obsidian**, red lacquer wood; lava is a glossy orange-to-yellow gradient plastic (never realistic)",
         sky="dusk orange-purple, ash flakes, the volcano's glow lighting everything from below",
         vfx="embers rising, heat shimmer over lava, lanterns flickering, lava bubbles popping",
         sound="taiko drums and crackling fire; energetic taiko lo-fi music",
         storm="**Eruption:** the volcano erupts, harmless lava bombs arc across the sky",
         unlock="**Hatch ×3 (free)** and the **Spirit Codex** (the pet index; in the dojo's Scroll Hall)",
         looks=("a molten blob with an obsidian crust", "a dog with magma veins and a flame mane", "a sumo-sized obsidian giant with lava cracks"),
         beh=("packs; leaves short burning puddles", "charges down a red lane", "slams a red circle"),
         boss_look="a huge red oni with lava-crack skin, obsidian horns and a flaming club. **Arena:** the Caldera Ring over the lava lake",
         rage="throws lava waves in a fan: step into the gap; a PERFECT on its glowing fist staggers it"),
    dict(element="Ice", feel="moonlit snowy peaks under an aurora: calm, magical, sparkling",
         layout="The **Shrine** is an ice-crystal gazebo on a frozen lake. Hunting grounds: **Snowdrift Fields**, **Ram Ridge** (switchback mountain paths), **Titan Glacier** (at the foot of a giant glacier wall). The boss arena, **Frozen Crown**, is the summit plateau",
         landmarks="an **ice palace** carved into the mountain; a **giant whale frozen inside the lake ice**, glowing faintly; aurora curtains overhead",
         materials="snow-white plastic, pale-blue translucent ice with an inner glow, frosted silver trims",
         sky="deep night blue with green and violet aurora ribbons and big stars",
         vfx="snowfall, aurora ripples, frosty breath, sparkling snow dust",
         sound="soft wind and ice chimes; dreamy music box and synth",
         storm="**Blizzard:** a whiteout swirl, the aurora flares bright",
         unlock="the **Enchant Forge** (section 13.3); **trading booths** open in the hub (after boss 2)",
         looks=("a snowball slime with a tiny ice crown", "a ram with crystal ice horns", "a yeti-titan with a glacier back"),
         beh=("packs; slides on ice", "charges a red lane, leaves an icy slick", "slams; a ring of ice spikes"),
         boss_look="a long serpent ice-dragon coiled around the summit, translucent wings, glowing blue core. **Arena:** the Frozen Crown summit",
         rage="ice breath sweeps a cone (step out) and ice pillars crash on red circles: **PERFECT a pillar** to shatter it into the Wyrm"),
    dict(element="Lightning", feel="floating islands in a permanent storm: electric, epic, fast",
         layout="Floating cliff islands joined by **energy bridges**. The **Shrine** sits on a Tesla-coil spire. Hunting grounds: **Static Fields**, **Hawk Spires**, **Colossus Quarry**. The boss arena, **the Storm Eye**, is a platform in the calm eye of a cyclone",
         landmarks="giant chrome-gold **lightning rods** that arc to each other; a storm cloud shaped like a sky-whale; rocks that float and slowly spin",
         materials="slate-lilac rock with glowing yellow circuit lines, chrome-gold metal, glassy purple crystals",
         sky="purple storm clouds with frequent soft lightning (safe with the reduced-flashing setting)",
         vfx="arcs between rods, static sparks, wind streaks, hair-raising particles near rods",
         sound="thunder rolls and crackles; driving electro-anime music",
         storm="**Thunderstorm:** lightning everywhere, energy bridges overcharge and glow",
         unlock="the **Spirit Nursery** (pet daycare, section 13.4) in the **Sky Nest**",
         looks=("a fizzing ball of static with a spark tail", "a hawk with lightning-bolt feathers", "a colossus with a coil heart and copper limbs"),
         beh=("packs; zips around", "dives down a red lane", "slams + a lightning ring"),
         boss_look="a giant thunderbird whose wings crackle with lightning and whose eyes glow white. **Arena:** the Storm Eye",
         rage="lightning markers chase you (keep moving) while 4 rods charge it: **blast the rods** to stun it"),
    dict(element="Nature", feel="a dreamy blossom garden at golden hour: beautiful, peaceful, colourful",
         layout="The **Shrine** is a stone garden ringed by red torii gates. Hunting grounds: **Petal Meadows**, **Bamboo Grove**, **Treant Hollow**. The boss arena, the **Moonlit Bridge**, is a red arched bridge over a koi pond",
         landmarks="a **colossal sakura tree** whose canopy covers the sky; koi ponds with glowing koi; floating lanterns",
         materials="pink blossom canopies, moss-green mounds, red lacquer, white stone, glossy bamboo",
         sky="golden afternoon fading to pink, petals in the air",
         vfx="drifting petals, fireflies, koi ripples, lantern glow",
         sound="koto and wind through bamboo; calm lo-fi beats",
         storm="**Petal Storm:** a whirlwind of petals, the koi leap",
         unlock="the **Star Forge** (fusion to ★3-★5)",
         looks=("a petal sprite riding a leaf", "a white fox with blossom tails", "an ancient treant with a blossom crown"),
         beh=("packs; floats on petals", "dashes along a red lane", "root-slam circle"),
         boss_look="a masked ronin made of blossom wood, with a glowing katana. **Arena:** the Moonlit Bridge",
         rage="dash-slashes along red lines, then splits into petal clones: **only the real one has a shadow**"),
    dict(element="Void", feel="floating islands at the edge of reality: mysterious, glowing, a little scary (still colourful, never black)",
         layout="The **Shrine** is a ring of floating runestones. Hunting grounds: **Mite Shards** (broken floating platforms), **Stalker Maze** (rune corridors), **Behemoth Abyss** (the edge of the void). The boss arena, **the Event Horizon**, circles a black hole",
         landmarks="a giant **cracked moon**; rifts that show glimpses of the other zones; tall rune pillars",
         materials="deep plum stone with glowing magenta / cyan runes, glossy violet-black crystal",
         sky="a purple nebula with the cracked moon",
         vfx="rift tears, particles swirling inward, pulsing runes",
         sound="deep hums and whispers; dark-synth music with a heartbeat",
         storm="**Eclipse:** the moon covers the sun, runes blaze",
         unlock="the **Mutation Reactor** (section 13.6)",
         looks=("a tiny void mite with glowing eyes", "a shadow panther that leaves afterimages", "a rift behemoth with a portal in its chest"),
         beh=("packs; blinks short distances", "teleports, then pounces down a red lane", "slam + a pulling rift"),
         boss_look="a colossal void serpent-leviathan swimming through space around the arena. **Arena:** the Event Horizon",
         rage="a black hole pulls you in (walk against it) and portals spit tentacles: **blast a portal** to send the tentacle back"),
    dict(element="Cosmic", feel="a palace floating among planets: grand, royal, starry",
         layout="The **Shrine** is a star-map dais. Hunting grounds: **Mote Belt** (asteroid rings), **Comet Run** (a long glowing track), **Nebula Halls**. The boss arena is the **Throne of Stars**",
         landmarks="planets that visibly orbit; a sun on the horizon; constellations that draw themselves in the sky",
         materials="navy marble with gold star inlays, crystal glass, glowing nebula fog",
         sky="deep space with a purple-blue nebula and moving planets",
         vfx="shooting stars, nebula fog, orbit trails",
         sound="choir pads and chimes; epic space-orchestra music",
         storm="**Meteor Shower:** the sky fills with falling stars",
         unlock="the **Aura Forge** (customize your aura; section 13.7)",
         looks=("a star mote with a smiling face", "a comet beast with a fiery tail", "a nebula giant full of stars"),
         beh=("packs; orbit each other", "charges with a fiery tail lane", "slam + a gravity well"),
         boss_look="a star-crowned emperor on a floating throne, cape made of galaxies. **Arena:** the Throne of Stars",
         rage="meteor showers (many red circles) and constellation nodes: **blast the nodes in the shown order** to drop a meteor on him"),
    dict(element="Holy light", feel="temples in the clouds: radiant, heavenly, huge scale",
         layout="The **Shrine** is a halo platform. Hunting grounds: **Halo Fields** (cloud meadows), **Knight Bridges** (marble bridges), **Guardian Steps** (a giant staircase). The boss arena is the **Gate of Light**",
         landmarks="a **colossal golden gate**; angel statues; waterfalls of light pouring into the clouds",
         materials="white marble, gold, fluffy cloud plastic",
         sky="bright white-gold with soft light beams",
         vfx="light beams, drifting feathers, choir glow",
         sound="choir and harp; heavenly orchestral music",
         storm="**Holy Rain:** golden rain and feathers",
         unlock="the **Relic Shrine** (section 13.8)",
         looks=("a halo sprite with tiny wings", "a seraph knight with a light lance", "a giant marble guardian with a ring of light"),
         beh=("packs; spinning halos", "lance charge down a red lane", "slam + a ring of light beams"),
         boss_look="a six-winged archangel in gold armour with a giant spear. **Arena:** the Gate of Light",
         rage="sweeping walls of light with one gap, and judgement circles that follow you: **PERFECT its raised spear** to break the wall"),
    dict(element="Dragon", feel="a gold-and-jade dragon temple above the clouds: legendary, rich, powerful",
         layout="The **Shrine** is a dragon-coil altar. Hunting grounds: **Hatchery Terraces**, **Wyvern Peaks**, **Elder Hall**. The boss arena is the **Dragon's Crown**",
         landmarks="a **sleeping colossal dragon wrapped around the mountain** (its breathing moves the clouds); treasure hoards; dragon-bone bridges",
         materials="jade, gold, red lacquer, glossy dragon scales",
         sky="sunset over a sea of clouds",
         vfx="fire vents, gold coins glinting, lantern glow",
         sound="deep drums and dragon roars; epic Asian-orchestral music",
         storm="**Dragonfire:** dragons fly overhead breathing harmless fire",
         unlock="the **Infinity Tower** entrance (endless boss floors; section 13.9)",
         looks=("a cute drakelet with ember breath", "a crystal wyvern", "an elder dragon golem made of jade and gold"),
         beh=("packs; small fire breaths", "flies in and dives down a red lane", "tail-sweep circle + a fire breath cone"),
         boss_look="an ancient emperor dragon in gold armour. **Arena:** the Dragon's Crown",
         rage="takes flight and rains fireballs on red circles, then breathes a sweeping cone: **PERFECT the fireballs** to bounce them back"),
    dict(element="Every aura", feel="the source of all auras: a prismatic void where every zone's light meets (the final wow)",
         layout="The **Shrine** is the **Nexus Core**, a giant floating aura sphere. Hunting grounds are floating fragments of the earlier worlds: **Wisp Prism**, **Knight Spectrum**, **Colossus Core**. The boss arena is the **Heart of Aura**",
         landmarks="the 9 earlier zones floating in orbit as fragments; a river of rainbow aurora; statues of all 10 forms",
         materials="prismatic glass and white stone, with every zone's accent colour shifting across it",
         sky="a shifting rainbow aurora",
         vfx="rainbow shifts, everything glows in every colour, aura waves",
         sound="every zone's theme woven together into one final track",
         storm="**Aurora Surge:** every zone's storm at once",
         unlock="the **Ascension Gate** (rebirth; section 13.10) and the **Boundless Hall** (statues of every Boundless owner)",
         looks=("an aura wisp that changes colour every second", "a prism knight", "a nexus colossus with rings in every element"),
         beh=("packs; change colour every second", "prism charge down a red lane", "slam + rings in every element"),
         boss_look="a figure of pure aura with wings of every element. **Arena:** the Heart of Aura",
         rage="**every earlier boss's move in turn:** boulders, lava fans, ice pillars, lightning markers, light walls, petal clones, a black hole, meteors, fireballs. The beam clash is golden, against the whole sky"),
]

FORM_LOOK = {"BLAZE": "orange anime flames", "INFERNO": "red-black flames, heat haze", "GLACIER": "icy crystal aura",
             "TEMPEST": "crackling lightning aura", "BLOOM": "swirling blossom aura", "ECLIPSE": "dark ring with violet fire",
             "COSMIC": "starfield aura with orbiting planets", "RADIANT": "white-gold aura with light wings",
             "DRAGONSOUL": "jade-gold aura with a dragon spirit", "ASCENDED": "rainbow-white aura, wings of light, a halo"}


def chance(p):
    if p >= 0.01:
        return f"{p * 100:.4g}%"
    n = 1 / p
    for v, suf in ((1e12, "T"), (1e9, "B"), (1e6, "M"), (1e3, "K")):
        if n >= v:
            return f"1 in {n / v:.3g}{suf}"
    return f"1 in {n:,.0f}"


def num(x):
    if x >= 10_000:
        return M.big(x)
    if x >= 10 or x == int(x):
        return f"{round(x):,}"
    return f"{x:g}"


def quest_text(z, q):
    kind = q[0]
    if kind == "focus":
        return f"Focus meditate for {q[1]} s"
    if kind == "kill":
        name = M.MONSTER_NAMES[z][q[1]]
        plural = name[:-2] + "i" if name.endswith("us") else name if name.endswith("s") else name + "s"
        return f"Defeat {q[2]} {plural if q[2] > 1 else name}"
    if kind == "hatch":
        return f"Hatch {q[1]} eggs here"
    if kind == "level":
        return f"Get a pet to level {q[1]}"
    if kind == "mutated":
        return ("Defeat 5 mutated monsters (any mutation)" if q[1] == 0 else
                "Defeat a **Rainbow, Void or Celestial** mutated monster")
    if kind == "stars":
        return f"Make a {'★' * q[1]} pet"
    if kind == "power":
        return f"Reach {num(q[1])} Power"


def stats(n=40):
    rows = [M.Player("average", 1000 + r).run() for r in range(n)]
    out = []
    for z in range(M.ZONES):
        s = [x.zone_stats[z] for x in rows if z in x.zone_stats]
        m = lambda k: st.median(v[k] for v in s)
        out.append(dict(t=m("t"), power=m("power"), slots=m("slots"), best=M.TIERS[int(m("best"))],
                        stars=m("stars"), lv=m("lv"), bag=m("bag"), team=m("team")))
    return out


def fmt_t(sec):
    h, m = int(sec // 3600), int(sec % 3600 // 60)
    return f"~{h} h {m:02d}" if h else f"~{m} min"


def zone_section(z, s, slots_running):
    T, B = TEXT[z], M.BOSS[z]
    sv = M.shard_val(z)
    L = []
    L.append(f"## {ZONE_START + z}. ZONE {z + 1}: {M.ZONE_NAMES[z].upper()} ({T['element']}) · quests: {M.TIER[z]}\n")
    L.append(f"**The feel:** {T['feel']}.\n")
    L.append("| Design | |\n|---|---|")
    for key, label in (("layout", "Layout"), ("landmarks", "Landmarks"), ("materials", "Materials"), ("sky", "Sky + light"),
                       ("vfx", "Ambient VFX"), ("sound", "Sound + music"), ("storm", "Mutation Storm here"),
                       ("unlock", "**New in this zone**")):
        L.append(f"| {label} | {T[key]} |")
    L.append(f"\n**Numbers:** Shrine {num(M.SHRINE[z])} Power/s · Egg {num(M.EGG_PRICE[z])} coins.\n")
    L.append("| Monster | Look | HP | Behaviour | Drops (coins) | XP per kill |\n|---|---|---|---|---|---|")
    for i in range(3):
        name, hp, sh, br, gem, _ = M.monster(z, i)
        drops = [f"1 Shard ({num(sv[0])})", f"3 Shards + 20% Bright ({num(sv[1])})",
                 f"8 Shards + 2 Bright + 10% Gem ({num(sv[2])})"][i]
        L.append(f"| **{name}** | {T['looks'][i]} | {num(hp)} | {T['beh'][i]} | {drops} | {num(M.KILL_XP[i] * M.XP_STEP ** z)} |")
    L.append(f"\n**Egg: {M.ZONE_NAMES[z]} pets** (Strength ×{M.PET_STEP ** z}; every Secret-or-rarer pet is serialized):\n")
    L.append("| Pet | Tier | Chance | Strength |\n|---|---|---|---|")
    for name, t, p in M.EGGS[z]:
        shown = f"??? ({name})" if t >= 6 and t < 9 else name
        if t == 9:
            shown = "**Boundless** (this month's, the same in every egg)"
        strength = (num(M.TIER_STR[t] * M.PET_STEP ** z) if t not in M.SECRET_MULT else
                     ("= your best pet" if M.SECRET_MULT[t] == 1 else f"{M.SECRET_MULT[t]:,}× your best pet"))
        L.append(f"| {shown} | {M.TIERS[t]} | {chance(p)} | {strength} |")
    L.append("\n**Quests:**\n\n| # | Quest | Reward |\n|---|---|---|")
    for i, q in enumerate(M.QUESTS[z]):
        if (z, i) in M.SLOT_QUESTS:
            slots_running[0] += 1
            reward = f"+1 pet slot ({slots_running[0]})"
        elif i == len(M.QUESTS[z]) - 1:
            reward = "**boss gate opens**"
        else:
            reward = "free egg"
        L.append(f"| {i + 1} | {quest_text(z, q)} | {reward} |")
    R = B["rec"] * M.BOSS_HP_X[z]
    nxt = M.ZONE_NAMES[z + 1] if z + 1 < M.ZONES else M.ZONE_NAMES[z]
    L.append(f"\n**Boss: {B['name'].upper()}** (recommended Power {num(B['rec'])}): {T['boss_look']}.")
    L.append(f"- **HP:** plates 6 × {num(M.PLATE_HP_X * R)}; body {num(M.BODY_HP_X * R)}.")
    L.append(f"- **Rage:** {T['rage']}.")
    L.append(f"- **Reward:** form **{B['form']}** ({FORM_LOOK[B['form']]}); **Boss Shards worth "
             f"{num(M.boss_shard_value(z))} coins** (about 3 {nxt} eggs).")
    L.append(f"\n**At the boss** (average free player, median):\n")
    L.append("| Time | Power | Slots | Best pet | Best stars | Best level | Bag |\n|---|---|---|---|---|---|---|")
    L.append(f"| **{fmt_t(s['t'])}** | {num(s['power'])} | {s['slots']:.0f} | {s['best']} | "
             f"{'★' * int(s['stars']) or 'none'} | {s['lv']:.0f} | {s['bag']:.0f} |\n")
    return "\n".join(L)


FIRST_MINUTES = """**The first 8 minutes** (one model run close to the median, `econ` seed 15):

| Time | What happens | Power |
|---|---|---|
| 0:00-0:20 | Spawn at the Shrine; a "MEDITATE" hand; the tutorial meditation | 10 → 50 |
| 0:20 | The hand points at the Shardlings; PERFECTs one-shot them | 50 |
| ~0:55 | First **Overdrive** (it varies: 0:30-3:30 depending on timing luck) | 50 |
| ~1:00 | The guaranteed **Gold Shardling**: "MUTATION!" | 50 |
| ~1:55 | Storm full, so the first **SELL** (about 850 coins). The first sell stays at the Shrine | 50 |
| ~2:00 | Eggs: the **Light Fox**, then the guaranteed Rare. **Bag Lv1 + Lv2, Mat Lv1** | 50 |
| ~2:05 | First ★ at the Fusion Altar | 50 |
| ~2:30 | Quest 1: Focus 20 s → +1 slot | ~100 |
| ~2:50 | First pet level-up (XP from kills) | ~100 |
| ~3:10 | Quests 2, 3 and 4 done (Shardlings, hatches, Boars) → eggs and +1 slot | ~100 |
| 3:10-4:50 | Quest 5: **sit and Focus meditate about 1.5 min** | ~315 |
| 4:50-5:30 | **Stone Golem** | |
| ~5:30 | **BLAZE.** Boss Shards sell for 4,500 → Bag Lv3, Mat Lv2, Surge Lv1. **Hatch ×3 unlocks.** Pyrora Dojo opens | ~315 |
| 5:35-7:05 | Zone 2 quest 1: Focus 60 s at the ×4 Shrine | ~1,500 |
| 7:05+ | Ember Slimes; Fire eggs (1,500) | |
"""


def summary(st_):
    L = [f"## {ZONE_START + M.ZONES}. Progression at a glance (average free player, solo, model medians)\n",
         "| Zone | Name | Quests | Shrine /s | Egg | Boss (recommended Power) | Finished at | Power then |",
         "|---|---|---|---|---|---|---|---|"]
    for z in range(M.ZONES):
        L.append(f"| {z + 1} | {M.ZONE_NAMES[z]} | {M.TIER[z]} | {num(M.SHRINE[z])} | {num(M.EGG_PRICE[z])} | "
                 f"{M.BOSS[z]['name']} ({num(M.BOSS[z]['rec'])}) | {fmt_t(st_[z]['t'])} | {num(st_[z]['power'])} |")
    return "\n".join(L) + "\n"


def build():
    st_ = stats()
    slots = [M.BASE_SLOTS]
    parts = []
    for z in range(M.ZONES):
        sec = zone_section(z, st_[z], slots)
        if z == 0:
            sec = sec.replace("\n**At the boss**", "\n" + FIRST_MINUTES + "\n**At the boss**", 1)
        parts.append(sec)
    parts.append(summary(st_))
    return "\n".join(parts)


if __name__ == "__main__":
    path = "../GAME-BIBLE.md"
    text = open(path).read()
    a, b = "<!-- ZONES:START (generated by econ/make_bible.py; don't edit by hand) -->", "<!-- ZONES:END -->"
    i, j = text.index(a) + len(a), text.index(b)
    open(path, "w").write(text[:i] + "\n\n" + build() + "\n" + text[j:])
    print("GAME-BIBLE.md Part B regenerated")
