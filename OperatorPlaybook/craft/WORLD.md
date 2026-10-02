# WORLD: maps, level layout, lighting, atmosphere, colour grade, streaming

## The bar

- The world makes the core loop obvious: the eye goes to where the player should go.
- Lighting is bright, saturated and toy-like (about 10% under first instinct).
- Every surface a player touches is clean: nothing floats, sinks, overlaps, or sits on a belt or path.

## Layout

0. **Concept first:** a GPU key-art painting of each zone (ComfyUI) from online references + the style sheet, plus a lighting / mood frame. Build the zone to match it.
1. **Start from the loop.** Mark the places the player spends 80% of their time (the station, the arena, the hub). Build those first at full quality; everything else supports them.
2. **Spawn:**
   - safe (no hazards, never inside geometry or another player);
   - facing the first action;
   - the first goal visible from spawn.
3. **Paths:**
   - wide enough for crowds (at least 8 studs for main routes);
   - clear landmarks at decision points;
   - no dead ends without a reward.
4. **Measure real travel time,** walked with the avatar along the route: turns, jumps, slopes, crowding. Not the straight-line distance. Keep core-loop trips under about 10 s, or give a shortcut or teleport.
5. **Landmarks:** one tall readable landmark per zone, visible from the hub; each zone has its own colour accent.
6. **Readability:**
   - interactables get a consistent visual language (a glow, a colour, a prompt);
   - decoration never looks interactable;
   - functional surfaces are clear of clutter.
7. **Scale:** doors, steps and seats fit a 5-stud R15 avatar. Big heroes sit at about 2-4x avatar height for impact.

## Lighting and atmosphere (Studio)

- **`Lighting.Technology = Future`** for the best quality; check performance on Low.
- **Sun:** set `ClockTime` / `GeographicLatitude` for shadows that describe form: about 30-50° elevation, not straight overhead.
- **`Atmosphere`:**
  - Density low (0.2-0.35) for bright games;
  - Haze for depth;
  - a Color / Decay tint that matches the palette.
- **Post effects:**
  - **Bloom:** low intensity; threshold high enough that only emissive cores glow.
  - **ColorCorrection:** a small saturation lift or cut to hit the "10% under" target; a contrast nudge; a tint toward the art-bible temperature.
  - **SunRays:** subtle.
  - **DepthOfField:** only for menus / cutscenes, never during gameplay.
- **Ambient:**
  - `Ambient` and `OutdoorAmbient` lift the shadows so nothing goes muddy;
  - `EnvironmentDiffuseScale` / `EnvironmentSpecularScale` at about 0.5-1 so PBR materials read.
- **Lights:** a few purposeful PointLights / SurfaceLights for focal areas. Turn shadows on only where it matters (cost).
- **Lighting must be stable from the first frame.** No "brightens 5 s after join": set it in the place file, not a late script.
- **Skybox and clouds** in the art bible's mood; `Clouds` cover and density tuned so they don't wash out the sky colour.

## Materials and colour

- One palette for the whole world: 5-7 base colours + 1-2 accents for interactables / premium.
- Large surfaces get lower saturation and value variation (subtle gradients, trim breaks). Small focal items get the saturated colours.
- Repetition breakers: vary scale and rotation of repeated props; decals for wear; avoid obvious tiling.

## Streaming (any map larger than one screen)

- `StreamingEnabled` on for larger maps. Know what streams:
  - `ModelStreamingMode = Atomic` for models that must arrive whole;
  - `Persistent` only for the few the client always needs.
- Client code never assumes a part exists: `WaitForChild` with a timeout or a stream-in handler, and it handles the part disappearing again.
- `Player:RequestStreamAroundAsync` before teleporting a player somewhere new.
- **Test streaming in a live server,** walking far away and back. Studio Play with a small map hides streaming bugs.

## Audits (automatic, every lane that touches the map)

1. **Overlap audit:** OBB intersections between visible parts. Catch parts already intersecting at rest, not just sweep casts.
2. **Support audit:** raycast down from the 4 bottom corners + the centre of everything that rests on something. Flag float > 0.03 studs or any unsupported corner. Structure is included (posts, feet, legs, stands).
3. **Functional-surface audit:** slab-test the top face (0-0.4 studs above) of every belt, path, seat, button and work area against all visible parts except the intended cargo, the same model included.
4. **Spawn and fall audit:** every spawn safe; no gaps players fall through; kill planes under the map.
5. **Camera audit:** walk every route with the default camera. No camera traps in tight spaces; no walls that block the view of the core action.

## Senses: what to catch

- [ ] The most important thing on screen is the most visible (value contrast, colour, light).
- [ ] Nothing dark, muddy or empty in the play space; nothing cluttered on functional surfaces.
- [ ] Everything rests on its surface (check from low back-corner angles, not just hero angles).
- [ ] Colour grade about 10% under first instinct; the world doesn't fight the UI colours.
- [ ] Junctions and merges are reviewed top-down (belts, rails, paths).
- [ ] Every place an upgraded asset appears was updated (shelves, previews, tutorial areas).
- [ ] No generic flag props or filler banners.
- [ ] Prune sweep: does every object still earn its place?

## Traps (from real misses)

- Gantry feet overhanging desk corners and rail bars across a belt were both missed by hero-angle reviews. Hence audits 2 and 3.
- The lighting brightened about 5 s after join: a late script overrode the place settings.
- A stand-in prop stayed beside its new Hall-of-Fame replacement. Redundant pairs are the classic prune miss.
