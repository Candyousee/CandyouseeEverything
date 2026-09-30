"""Headless Blender preview renders for Stud Pets.

Reads the per-frame part transforms dumped by `lune run build/build.luau preview <json>`
(the exact poses the game plays) and renders them with Cycles.

  python3 build/render_preview.py <preview.json> <out_dir> sheet   # one still per animation
  python3 build/render_preview.py <preview.json> <out_dir> anim    # every frame (for GIFs)
  python3 build/render_preview.py <preview.json> <out_dir> hero    # both pets, big still

Needs: pip install bpy==5.0.1 pillow
"""

import json
import math
import os
import sys

import bpy
import bmesh
from mathutils import Matrix, Vector

# Roblox (Y up, -Z forward) -> Blender (Z up): (x, y, z) -> (x, -z, y)
CONV = Matrix(((1, 0, 0, 0), (0, 0, -1, 0), (0, 1, 0, 0), (0, 0, 0, 1)))

STUD_RADIUS = 0.26
STUD_HEIGHT = 0.12


def srgb_to_linear(c):
    c = c / 255.0
    return c / 12.92 if c <= 0.04045 else ((c + 0.055) / 1.055) ** 2.4


def cf_matrix(comps):
    x, y, z, r00, r01, r02, r10, r11, r12, r20, r21, r22 = comps
    return Matrix(((r00, r01, r02, x), (r10, r11, r12, y), (r20, r21, r22, z), (0, 0, 0, 1)))


def reset_scene():
    bpy.ops.wm.read_factory_settings(use_empty=True)
    _materials.clear()
    scene = bpy.context.scene
    scene.render.engine = "CYCLES"
    scene.cycles.device = "CPU"
    scene.cycles.samples = 20
    scene.cycles.use_denoising = True
    scene.cycles.max_bounces = 4
    scene.render.film_transparent = False
    scene.view_settings.view_transform = "Standard"
    scene.view_settings.look = "None"
    scene.render.image_settings.file_format = "PNG"
    world = bpy.data.worlds.new("World")
    scene.world = world
    world.use_nodes = True
    bg = world.node_tree.nodes["Background"]
    bg.inputs[0].default_value = (0.62, 0.74, 0.92, 1)
    bg.inputs[1].default_value = 0.55
    return scene


_materials = {}


def material(rgb, rough=0.38, glow=False):
    key = (tuple(rgb), rough, glow)
    if key in _materials:
        return _materials[key]
    mat = bpy.data.materials.new(f"m{len(_materials)}")
    mat.use_nodes = True
    bsdf = mat.node_tree.nodes["Principled BSDF"]
    bsdf.inputs["Base Color"].default_value = (*[srgb_to_linear(c) for c in rgb], 1)
    bsdf.inputs["Roughness"].default_value = rough
    if glow:
        bsdf.inputs["Emission Color"].default_value = (*[srgb_to_linear(c) for c in rgb], 1)
        bsdf.inputs["Emission Strength"].default_value = 2.0
    _materials[key] = mat
    return mat


def part_mesh(part):
    sx, sy, sz = part["size"]
    hx, hy, hz = sx / 2, sy / 2, sz / 2
    bm = bmesh.new()
    if part["class"] == "WedgePart":
        # Roblox wedge: full-height face at the back (+Z), slope running down to the front.
        v = [bm.verts.new(p) for p in (
            (-hx, -hy, -hz), (hx, -hy, -hz), (hx, -hy, hz), (-hx, -hy, hz),
            (-hx, hy, hz), (hx, hy, hz),
        )]
        for f in ((0, 1, 2, 3), (3, 2, 5, 4), (0, 4, 5, 1), (0, 3, 4), (1, 5, 2)):
            bm.faces.new([v[i] for i in f])
    else:
        bmesh.ops.create_cube(bm, size=1.0, matrix=Matrix.Diagonal((sx, sy, sz, 1)))
        if part["studs"]:
            nx, nz = int(sx + 1e-3), int(sz + 1e-3)
            for i in range(nx):
                for k in range(nz):
                    px = i - (nx - 1) / 2
                    pz = k - (nz - 1) / 2
                    # cone axis is local Z; rotate so it points up the part's +Y
                    m = Matrix.Translation((px, hy + STUD_HEIGHT / 2, pz)) @ Matrix.Rotation(math.radians(-90), 4, "X")
                    bmesh.ops.create_cone(bm, cap_ends=True, segments=20, radius1=STUD_RADIUS,
                                          radius2=STUD_RADIUS, depth=STUD_HEIGHT, matrix=m)
    bmesh.ops.recalc_face_normals(bm, faces=bm.faces)
    mesh = bpy.data.meshes.new(part["name"])
    bm.to_mesh(mesh)
    bm.free()
    return mesh


def build_pet(pet, offset=(0, 0, 0)):
    objs = []
    for part in pet["parts"]:
        obj = bpy.data.objects.new(part["name"], part_mesh(part))
        obj.data.materials.append(material(part["color"], glow=part.get("neon", False)))
        bpy.context.scene.collection.objects.link(obj)
        objs.append(obj)
    return objs, Matrix.Translation(offset)


def pose_pet(objs, base, frame):
    for i, obj in enumerate(objs):
        obj.matrix_world = CONV @ base @ cf_matrix(frame[i * 12:(i + 1) * 12])


def add_stage(scene, target, distance, lens=50, yaw=-38, pitch=17):
    ground = bpy.data.meshes.new("ground")
    bm = bmesh.new()
    bmesh.ops.create_grid(bm, x_segments=1, y_segments=1, size=400)
    bm.to_mesh(ground)
    bm.free()
    g = bpy.data.objects.new("Ground", ground)
    g.data.materials.append(material((196, 202, 210), rough=0.6))
    scene.collection.objects.link(g)

    sun_data = bpy.data.lights.new("Sun", "SUN")
    sun_data.energy = 3.2
    sun_data.angle = math.radians(8)
    sun = bpy.data.objects.new("Sun", sun_data)
    sun.rotation_euler = (math.radians(42), math.radians(-18), math.radians(-35))
    scene.collection.objects.link(sun)

    cam_data = bpy.data.cameras.new("Cam")
    cam_data.lens = lens
    cam = bpy.data.objects.new("Cam", cam_data)
    scene.collection.objects.link(cam)
    scene.camera = cam
    # pet faces Blender +Y; orbit the camera around the front-left
    t = Vector(target)
    yaw_r, pitch_r = math.radians(yaw), math.radians(pitch)
    direction = Vector((math.sin(yaw_r) * math.cos(pitch_r), math.cos(yaw_r) * math.cos(pitch_r), math.sin(pitch_r)))
    cam.location = t + direction * distance
    cam.rotation_euler = (-direction).to_track_quat("-Z", "Y").to_euler()
    return cam


def rest_bounds(pet):
    frame = pet["anims"][0]["frames"][0]
    lo = [math.inf] * 3
    hi = [-math.inf] * 3
    for i, part in enumerate(pet["parts"]):
        m = cf_matrix(frame[i * 12:(i + 1) * 12])
        sx, sy, sz = part["size"]
        for cx in (-1, 1):
            for cy in (-1, 1):
                for cz in (-1, 1):
                    p = CONV @ m @ Vector((cx * sx / 2, cy * sy / 2, cz * sz / 2))
                    for a in range(3):
                        lo[a] = min(lo[a], p[a])
                        hi[a] = max(hi[a], p[a])
    return lo, hi


def render_to(scene, path):
    scene.render.filepath = path
    bpy.ops.render.render(write_still=True)


def main():
    data_path, out_dir, mode = sys.argv[1], sys.argv[2], sys.argv[3]
    only_pet = sys.argv[4] if len(sys.argv) > 4 else None
    with open(data_path) as f:
        data = json.load(f)
    os.makedirs(out_dir, exist_ok=True)

    if mode == "hero":
        scene = reset_scene()
        scene.cycles.samples = 64
        scene.render.resolution_x, scene.render.resolution_y = 1600, 900
        placed = []
        for pet, x in zip(data["pets"], (-3.6, 3.6)):
            objs, base = build_pet(pet)
            base = Matrix.Translation((x, 0, 0))
            pose_pet(objs, base, pet["anims"][0]["frames"][0])
            placed.append((objs, base))
        add_stage(scene, (0, -0.5, 2.1), 19, lens=50, yaw=-28, pitch=14)
        render_to(scene, os.path.join(out_dir, "hero_front.png"))
        return

    for pet in data["pets"]:
        if only_pet and pet["name"] != only_pet:
            continue
        scene = reset_scene()
        scene.render.resolution_x, scene.render.resolution_y = (420, 360) if mode == "sheet" else (360, 310)
        if mode == "anim":
            scene.cycles.samples = 14
        objs, base = build_pet(pet)
        lo, hi = rest_bounds(pet)
        center = ((lo[0] + hi[0]) / 2, (lo[1] + hi[1]) / 2, (hi[2]) * 0.55)
        yaw = float(os.environ.get("PREVIEW_YAW", "-38"))
        size = max(hi[2] + 1.5, hi[1] - lo[1], hi[0] - lo[0])
        add_stage(scene, center, max(15.5, size * 2.9), yaw=yaw)
        for anim in pet["anims"]:
            frames = anim["frames"]
            if mode == "sheet":
                pick = {"Jump": 0.47, "Stretch": 0.4, "Bark": 0.19}.get(anim["name"], 0.3)
                indices = [min(len(frames) - 1, int(len(frames) * pick))]
            else:
                indices = range(len(frames))
            for i in indices:
                pose_pet(objs, base, frames[i])
                name = f"{pet['name']}_{anim['name']}.png" if mode == "sheet" else os.path.join(pet["name"], anim["name"], f"{i:04d}.png")
                render_to(scene, os.path.join(out_dir, name))


if __name__ == "__main__":
    main()
