# MODELING: props, items, characters, pets, vehicles, environment meshes, textures

## The bar

Top Roblox front-page quality in **this game's style sheet** (craft/STYLE.md): stud, cartoony, anime or realistic. Always:
- a clear silhouette at a glance;
- chunky readable forms with real bevels;
- materials that read correctly under the game's lighting;
- zero visible seams, gaps or interpenetration.

Every model starts from `templates/MODEL-SPEC-TEMPLATE.xlsx` (Brief, Parts, LODs, Textures, Acceptance, Uploads, Tools). It is done only when the Acceptance gate reads PASS.

## Toolchain (all free; re-check licences each project)

| Step | Tool | Catch |
|---|---|---|
| Concept / style frames | ComfyUI + FLUX.1-schnell / SDXL / Qwen-Image (local) | Style frames only; never shipped |
| Base shape (optional) | Hunyuan3D-2 | A **shape guide only**; never shipped geometry in sale packs; licence excludes EU/UK/KR |
| Anime / stylised characters | VRoid Studio + Blender VRM add-on | Scripted faces aren't acceptable for anime |
| Modeling, retopo, UV, bake | Blender + the Roblox add-on | Your output is yours (GPL covers the program, not your models) |
| PBR textures | Blender bakes, Material Maker (GUI only), Krita | Material Maker's CLI crashes |
| Upscale / cutout | Real-ESRGAN, rembg | |
| Import | Studio 3D Importer (GUI) or Open Cloud via `oc_upload.ps1` | The importer needs computer use with the owner's approval; agents can't drive it |

## Workflow

1. **Blockout at true scale** against a 5-stud R15 avatar, in the real game camera. Approve the silhouette before ANY detail.
2. **Primary forms → secondary → tertiary.**
   - Primary: the big readable shapes.
   - Secondary: bevels, panel breaks, straps.
   - Tertiary: small trims.

   Stylised Roblox art lives mostly in primary + secondary. Tertiary detail that's invisible at gameplay distance costs triangles for nothing.
3. **Bevel every visible hard edge** (a chunky toy feel, and it catches the light). Two segments are usually enough.
4. **Retopo** to budget:
   - quads where it deforms;
   - triangles fine on rigid props;
   - no n-gons in the export.
5. **UVs:** one 0-1 set per mesh.
   - Stylised props: a **palette atlas** (a grid of flat colours + a few gradient strips) shares one texture across a whole pack.
   - Hero pieces: unique UVs + baked AO / normal.
6. **Bake** high→low: normal (OpenGL tangent space for Roblox), AO, and curvature for edge wear if the style wants it.
7. **Textures:**
   - SurfaceAppearance needs Color + Normal + Roughness + Metalness;
   - 1024 px is the default; 2048 only for a hero piece, with the reason recorded;
   - check the palette against the art bible, about 10% less saturated than first instinct.
8. **Export:** FBX or glTF with transforms applied and scale 1, and +Z / -Z checked.
   - Roblox's front is -Z.
   - The Roblox importer mirrors Z on some FBX exports, so check a known-asymmetric test part the first time.
9. **Import, then compare** in the game's lighting, side by side with the target image. Don't judge it in Blender's viewport.

## Roblox numbers

- **Triangles:** at most 20,000 per MeshPart. Split bigger hero props into several meshes that share ONE atlas / map set.
- **Sizes of one family:** one mesh per size, never non-uniform scaling (it stretches bevels and tape).
- **Pivot:** set the PrimaryPart and `PivotOffset` to the intended origin before cloning with `PivotTo`, or everything lands offset.
- **Collision:**
  - `CollisionFidelity = Box` or `Hull` for props;
  - `PreciseConvexDecomposition` only where players touch detail;
  - `CanCollide` / `CanQuery` / `CanTouch` off for pure decor.
- **Never "fix" clipping by turning collision off broadly.** It hides misplaced geometry and breaks pathfinding and cameras.
- **Group-owned games:** upload with `-GroupId`. A user-owned mesh in a group game can be invisible on live servers while Studio shows it fine.
- **LOD:** `RenderFidelity = Automatic`, plus your own LOD1 / LOD2 only for big or numerous meshes seen far away.

## Welds and assemblies (built offline or by script)

- A **WeldConstraint created offline** (Lune / rbxm / a scripted build) can lose its offsets on load, so every piece snaps onto Part0. For anything built offline, use a `Weld` with `C0 = root.CFrame:Inverse() * part.CFrame`, `C1 = identity`.
- Bones only bind inside the same assembly: weld skinned parts into the rig.
- **Tool grips:** with the default Grip, handle space has +Z running along the forearm. Wrap arm-worn things (coils, bracers) around Z, and test in first and third person.
- Set `Attachment.WorldPosition` only after parenting.
- **CSG from scripts:** use `GeometryService:UnionAsync`, which works on unparented parts. `BasePart:UnionAsync` fails when unparented.

## Skinned meshes

- Read the uploaded mesh's bind pose first (`EditableMesh:GetBones` / `GetBoneCFrame`) and diff it against the live rig before guessing at skinning faults.
- Studio can crash when rendering file-based skinned local `.mesh` files. What works: `AssetService:CreateEditableMeshAsync(uri, {FixedSize=true})` → `CreateMeshPartAsync`, welded into the rig.
- The client EditableMesh budget is about 100k triangles, so ship LOD1 in Play.
- Test on a 2-bone bar first: each crash costs a Studio restart.

## Senses: what the eye must catch

- [ ] **Silhouette** reads as the subject at the hero distance, 25 studs and 70 studs (a black-fill test).
- [ ] **Proportions** match the reference side by side (within about 3%). Measure with an overlay; don't eyeball it.
- [ ] **Shape language** is consistent across the pack: the same bevel width, corner radius and chunkiness.
- [ ] **No interpenetration, z-fighting, floating trim or poke-through:** the automated overlap audit + close-ups from several angles, INCLUDING low back corners.
- [ ] **Resting contact:** sits ON its surface; float ≤ 0.03 studs; every foot, leg and corner supported (raycast support audit).
- [ ] **Nothing lies over a functional surface** (belts, paths, seats, buttons, desks' work areas), parts from the same model included.
- [ ] **Joinery like real objects:** bars stop at corners; one flush bracket, not three overlapping ones.
- [ ] **Normals** point outward, with no dark smoothing artefacts on flat faces (mark sharp + weighted normals).
- [ ] **Texel density** is even across the pack (no blurry piece next to a crisp one).
- [ ] **Colour** matches the name; no lookalike within its category (contact sheet).
- [ ] **Premium items** carry effects at hero quality; plain items carry none.
- [ ] **Symbols** on the model are one mesh or a decal, never stacked parts.
- [ ] **Swapped in everywhere** it appears; the old stand-in is removed WITH its code.

## Traps (from real misses)

- Primitive-part "models" slipped through because a brief said "Items3D" without naming Blender. Every brief names the tool.
- The rule-45 sweep covered props but not pets, NPCs or first-person hands. The sweep lists EVERY visible model class.
- Gantry feet hung off desk corners for days because no shot framed the back corners. The support audit is automatic now.
- Rail bars lay across a moving belt at a junction; the overlap audit missed it, so the functional-surface audit was added.
- A ring of balls used for a rounded rim read as gear teeth. Use two stepped cylinders or a real bevel.
- Coils collapsed onto the handle (offline WeldConstraints), then didn't wrap the arm (wrong axis), then had ornaments the owner disliked. Check the axis and welds in Studio after the FIRST build, before any polish.
