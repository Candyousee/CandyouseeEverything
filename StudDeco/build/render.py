"""Headless Blender renders for Stud Deco (pip install bpy==5.0.1 pillow).

  lune run build/build.luau preview deco.json
  python3 build/render.py deco.json out_dir           # one image per item, next to a grey avatar for scale
  python3 build/render.py deco.json out_dir NAME      # only that item

The look matches the owner's reference sheet: dark backdrop, warm key light, glowing parts.
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
STUD_RADIUS, STUD_HEIGHT = 0.26, 0.12


def lin(c):
    c = c / 255.0
    return c / 12.92 if c <= 0.04045 else ((c + 0.055) / 1.055) ** 2.4


def cf_matrix(c):
    x, y, z, r00, r01, r02, r10, r11, r12, r20, r21, r22 = c
    return Matrix(((r00, r01, r02, x), (r10, r11, r12, y), (r20, r21, r22, z), (0, 0, 0, 1)))


_mats = {}


def material(rgb, glow=False, rough=0.42):
    key = (tuple(rgb), glow, rough)
    if key in _mats:
        return _mats[key]
    m = bpy.data.materials.new(f"m{len(_mats)}")
    m.use_nodes = True
    b = m.node_tree.nodes["Principled BSDF"]
    col = (*[lin(c) for c in rgb], 1)
    b.inputs["Base Color"].default_value = col
    b.inputs["Roughness"].default_value = rough
    if glow:
        b.inputs["Emission Color"].default_value = col
        b.inputs["Emission Strength"].default_value = 2.2
    _mats[key] = m
    return m


def part_mesh(p):
    sx, sy, sz = p["size"]
    hx, hy, hz = sx / 2, sy / 2, sz / 2
    bm = bmesh.new()
    shape = p.get("shape")
    if shape == "ball":
        bmesh.ops.create_uvsphere(bm, u_segments=32, v_segments=20, radius=0.5, matrix=Matrix.Diagonal((sx, sy, sz, 1)))
        for f in bm.faces:
            f.smooth = True
    elif shape == "cyl":
        d = min(sy, sz)  # Roblox cylinder: axis along X, diameter = min(Y, Z)
        bmesh.ops.create_cone(bm, cap_ends=True, segments=40, radius1=0.5, radius2=0.5, depth=sx,
                              matrix=Matrix.Rotation(math.radians(90), 4, "Y") @ Matrix.Diagonal((d, d, 1, 1)))
        for f in bm.faces:
            f.smooth = len(f.verts) == 4
    elif shape == "wedge":
        # Roblox wedge: full height at the back (+Z), sloping down to the front (-Z)
        v = [bm.verts.new(q) for q in ((-hx, -hy, -hz), (hx, -hy, -hz), (hx, -hy, hz), (-hx, -hy, hz), (-hx, hy, hz), (hx, hy, hz))]
        for f in ((0, 1, 2, 3), (3, 2, 5, 4), (0, 4, 5, 1), (0, 3, 4), (1, 5, 2)):
            bm.faces.new([v[i] for i in f])
    else:
        bmesh.ops.create_cube(bm, size=1.0, matrix=Matrix.Diagonal((sx, sy, sz, 1)))
        if p.get("studs"):
            nx, nz = int(sx + 1e-3), int(sz + 1e-3)
            for i in range(nx):
                for k in range(nz):
                    m = Matrix.Translation((i - (nx - 1) / 2, hy + STUD_HEIGHT / 2, k - (nz - 1) / 2)) @ Matrix.Rotation(math.radians(-90), 4, "X")
                    bmesh.ops.create_cone(bm, cap_ends=True, segments=20, radius1=STUD_RADIUS, radius2=STUD_RADIUS,
                                          depth=STUD_HEIGHT, matrix=m)
    bmesh.ops.recalc_face_normals(bm, faces=bm.faces)
    mesh = bpy.data.meshes.new(p["name"])
    bm.to_mesh(mesh)
    bm.free()
    if shape != "ball":
        # a small bevel look on blocks/cylinders comes from the Roblox-style flat shading; keep it crisp
        pass
    return mesh


def reset():
    bpy.ops.wm.read_factory_settings(use_empty=True)
    _mats.clear()
    s = bpy.context.scene
    s.render.engine = "CYCLES"
    s.cycles.device = "CPU"
    s.cycles.samples = int(os.environ.get("SAMPLES", "48"))
    s.cycles.use_denoising = True
    s.cycles.max_bounces = 5
    s.view_settings.view_transform = "AgX"
    s.view_settings.look = "AgX - Medium High Contrast"
    s.render.image_settings.file_format = "PNG"
    w = bpy.data.worlds.new("World")
    s.world = w
    w.use_nodes = True
    bg = w.node_tree.nodes["Background"]
    bg.inputs[0].default_value = (0.03, 0.03, 0.04, 1)
    if os.environ.get("STYLE") == "day":  # the Stud Pets look: soft blue-grey daylight
        bg.inputs[0].default_value = (0.62, 0.74, 0.92, 1)
        bg.inputs[1].default_value = 0.55
    bg.inputs[1].default_value = 1.0
    return s


def add_obj(name, mesh, mat, matrix):
    o = bpy.data.objects.new(name, mesh)
    o.data.materials.append(mat)
    o.matrix_world = matrix
    bpy.context.scene.collection.objects.link(o)
    return o


def build_item(item, offset=Vector((0, 0, 0))):
    base = Matrix.Translation(offset)
    for p in item["parts"]:
        add_obj(p["name"], part_mesh(p), material(p["color"], glow=p.get("neon")), base @ CONV @ cf_matrix(p["cf"]))
    for i, l in enumerate(item["lights"]):
        ld = bpy.data.lights.new(f"L{i}", "POINT")
        ld.color = tuple(lin(c) for c in l["color"])
        ld.energy = 60 * l["brightness"] * (l["range"] / 10)
        ld.shadow_soft_size = 0.4
        lo = bpy.data.objects.new(f"L{i}", ld)
        x, y, z = l["pos"]
        lo.location = base @ Vector((x, -z, y))
        bpy.context.scene.collection.objects.link(lo)


def bounds(item):
    lo, hi = [math.inf] * 3, [-math.inf] * 3
    for p in item["parts"]:
        m = CONV @ cf_matrix(p["cf"])
        sx, sy, sz = p["size"]
        for cx in (-1, 1):
            for cy in (-1, 1):
                for cz in (-1, 1):
                    q = m @ Vector((cx * sx / 2, cy * sy / 2, cz * sz / 2))
                    for a in range(3):
                        lo[a], hi[a] = min(lo[a], q[a]), max(hi[a], q[a])
    return lo, hi


def avatar(x):
    """A grey blocky avatar, about 5 studs tall, for scale (like the reference sheet)."""
    grey = material((150, 150, 156), rough=0.6)
    for name, size, pos in (
        ("LegL", (0.95, 2, 1), (-0.5, 1.0)), ("LegR", (0.95, 2, 1), (0.5, 1.0)),
        ("Torso", (2, 2, 1), (0, 3.0)), ("ArmL", (0.95, 2, 1), (-1.5, 3.0)), ("ArmR", (0.95, 2, 1), (1.5, 3.0)),
        ("Head", (1.2, 1.1, 1.1), (0, 4.6)),
    ):
        bm = bmesh.new()
        bmesh.ops.create_cube(bm, size=1.0, matrix=Matrix.Diagonal((size[0], size[2], size[1], 1)))
        mesh = bpy.data.meshes.new(name)
        bm.to_mesh(mesh)
        bm.free()
        add_obj("Avatar" + name, mesh, grey, Matrix.Translation((x + pos[0], -0.6, pos[1])))


def stage(target, dist, yaw=-30, pitch=16, lens=50):
    s = bpy.context.scene
    bm = bmesh.new()
    bmesh.ops.create_grid(bm, x_segments=1, y_segments=1, size=300)
    mesh = bpy.data.meshes.new("ground")
    bm.to_mesh(mesh)
    bm.free()
    add_obj("Ground", mesh, material((196, 202, 210) if os.environ.get("STYLE") == "day" else (40, 38, 46), rough=0.7), Matrix.Identity(4))
    # warm key + cool rim, dim enough that the glow reads
    for name, energy, rot, col in (("Key", 2.4, (50, -15, 140), (1.0, 0.92, 0.84)), ("Fill", 0.6, (65, 10, -150), (0.75, 0.78, 1.0)), ("Rim", 1.6, (70, 0, -10), (0.6, 0.65, 1.0))):
        ld = bpy.data.lights.new(name, "SUN")
        ld.energy = energy
        ld.angle = math.radians(10)
        ld.color = col
        lo = bpy.data.objects.new(name, ld)
        lo.rotation_euler = tuple(math.radians(a) for a in rot)
        s.collection.objects.link(lo)
    cd = bpy.data.cameras.new("Cam")
    cd.lens = lens
    cam = bpy.data.objects.new("Cam", cd)
    s.collection.objects.link(cam)
    s.camera = cam
    t = Vector(target)
    y, p = math.radians(yaw), math.radians(pitch)
    d = Vector((math.sin(y) * math.cos(p), math.cos(y) * math.cos(p), math.sin(p)))  # items face Blender +Y
    cam.location = t + d * dist
    cam.rotation_euler = (-d).to_track_quat("-Z", "Y").to_euler()


def main():
    data_path, out_dir = sys.argv[1], sys.argv[2]
    only = sys.argv[3] if len(sys.argv) > 3 else None
    os.makedirs(out_dir, exist_ok=True)
    data = json.load(open(data_path))
    for item in data["items"]:
        if only and item["name"] != only:
            continue
        s = reset()
        s.render.resolution_x, s.render.resolution_y = 900, 900
        lo, hi = bounds(item)
        build_item(item)
        avatar(lo[0] - 2.4)
        width = hi[0] - (lo[0] - 4.0)
        height = max(hi[2], 5.2)
        stage(((lo[0] - 4.0 + hi[0]) / 2, 0, height * 0.48), max(width, height) * 1.75 + 3, yaw=float(os.environ.get("YAW", "24")))
        s.render.filepath = os.path.join(out_dir, item["name"] + ".png")
        bpy.ops.render.render(write_still=True)
        print("rendered", item["name"])


if __name__ == "__main__":
    main()
