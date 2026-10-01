"""~20 s showcase video: a flyby over all 200 pets, then the cat running and doing its trick.

  lune run build/build.luau preview /tmp/all.json Idle
  lune run build/build.luau preview /tmp/cat.json all Cat
  python3 build/make_video.py /tmp/all.json /tmp/cat.json /tmp/frames flyby|cat
  (then build/finish_video.py adds titles and encodes the mp4)

VIDEO_ENGINE=eevee|workbench (default workbench), VIDEO_W/VIDEO_H for resolution.
"""

import json
import math
import os
import sys

import bpy
from mathutils import Matrix, Vector

sys.path.insert(0, os.path.dirname(__file__))
os.environ.setdefault("PREVIEW_ENGINE", "workbench")
import render_preview as rp  # noqa: E402

FPS = 24
DATA_FPS = 20


def setup(scene):
    scene.render.resolution_x = int(os.environ.get("VIDEO_W", 1280))
    scene.render.resolution_y = int(os.environ.get("VIDEO_H", 720))
    if os.environ.get("VIDEO_ENGINE") == "eevee":
        scene.render.engine = "BLENDER_EEVEE"
        scene.eevee.taa_render_samples = 16
        world = scene.world
        world.use_nodes = True
        bg = world.node_tree.nodes["Background"]
        bg.inputs[0].default_value = (0.62, 0.74, 0.92, 1)
        bg.inputs[1].default_value = 0.9


def frame_at(anim, t):
    frames = anim["frames"]
    i = int(t * DATA_FPS)
    if anim.get("looped", True):
        i %= len(frames)
    else:
        i = min(i, len(frames) - 1)
    return frames[i]


def look(cam, pos, target):
    cam.location = Vector(pos)
    d = Vector(target) - Vector(pos)
    cam.rotation_euler = d.to_track_quat("-Z", "Y").to_euler()


def smooth(x):
    x = max(0.0, min(1.0, x))
    return x * x * (3 - 2 * x)


def flyby(data, out_dir, seconds=12.0):
    scene = rp.reset_scene()
    setup(scene)
    pets = data["pets"]
    # rows of 20, smallest at the front so nothing hides behind a whale
    sized = []
    for pet in pets:
        lo, hi = rp.rest_bounds(pet)
        sized.append((hi[2] - lo[2], pet, lo, hi))
    sized.sort(key=lambda s: s[0])
    # rows about ROW_W studs wide, centred on x = 0, smallest pets at the front
    ROW_W = 70.0
    rows, row, w = [], [], 0.0
    for item in sized:
        pw = item[3][0] - item[2][0] + 1.5
        if row and w + pw > ROW_W:
            rows.append((row, w))
            row, w = [], 0.0
        row.append(item)
        w += pw
    rows.append((row, w))
    placed = []
    y = 0.0
    for row, w in rows:
        x = -w / 2
        depth = 0.0
        for _, pet, lo, hi in row:
            objs, _ = rp.build_pet(pet)
            # pets face Blender +Y: rows step back toward -Y, camera sits on the +Y side
            base = Matrix.Translation((x - lo[0], 0, y + hi[1]))  # (base is in Roblox space)
            placed.append((objs, base, pet["anims"][0]))
            x += (hi[0] - lo[0]) + 1.5
            depth = max(depth, hi[1] - lo[1])
        y += depth + 2.5
    width_total = ROW_W
    cam = rp.add_stage(scene, (0, -y / 2, 0), 10)
    cam.data.lens = 35
    n = int(seconds * FPS)
    only = os.environ.get("VIDEO_FRAMES")
    for f in (map(int, only.split(",")) if only else range(n)):
        out = os.path.join(out_dir, f"flyby_{f:04d}.png")
        if os.path.exists(out):
            continue
        t = f / FPS
        for objs, base, anim in placed:
            rp.pose_pet(objs, base, frame_at(anim, t))
        u = f / (n - 1)
        W, D = width_total, y
        if u < 0.7:
            # glide along the front of the herd, looking in at an angle
            k = smooth(u / 0.7)
            px = -W / 2 - 4 + k * (W + 4)
            pos, tgt = (px, 14, 5.5), (px * 0.55 + 5, -D * 0.3, 1.5)
        else:
            # rise and pull back to reveal all 200
            k = smooth((u - 0.7) / 0.3)
            a0, a1 = Vector((W / 2, 14, 5.5)), Vector((0, 8 + D * 0.3, 7 + D * 0.32))
            t0, t1 = Vector((W / 2 * 0.55 + 5, -D * 0.3, 1.5)), Vector((0, -D * 0.4, 0))
            pos, tgt = a0.lerp(a1, k), t0.lerp(t1, k)
        look(cam, pos, tgt)
        rp.render_to(scene, out)


def cat(data, out_dir):
    scene = rp.reset_scene()
    setup(scene)
    pet = data["pets"][0]
    anims = {a["name"]: a for a in pet["anims"]}
    objs, _ = rp.build_pet(pet)
    cam = rp.add_stage(scene, (0, 0, 1.5), 12)
    cam.data.lens = 50
    run_s, trick_s = 3.0, len(anims["Stretch"]["frames"]) / DATA_FPS + 0.6
    total = int((run_s + trick_s) * FPS)
    speed = 9.0  # studs per second while running
    for f in range(total):
        out = os.path.join(out_dir, f"cat_{f:04d}.png")
        if os.path.exists(out):
            continue
        t = f / FPS
        if t < run_s:
            # running along +X past a tracking camera
            x = -speed * run_s / 2 + speed * t
            base = Matrix.Translation((x, 0, 0)) @ Matrix.Rotation(math.radians(-90), 4, "Y")
            rp.pose_pet(objs, base, frame_at(anims["Run"], t))
            look(cam, (x - 3, -21, 5.5), (x + 1, 0, 2.6))
        else:
            tt = t - run_s
            base = Matrix.Translation((speed * run_s / 2, 0, 0)) @ Matrix.Rotation(math.radians(-40), 4, "Y")
            rp.pose_pet(objs, base, frame_at(anims["Stretch"], tt))
            cx = speed * run_s / 2
            look(cam, (cx + 6, 13, 4.2), (cx, 0, 2.4))
        rp.render_to(scene, out)


def main():
    all_path, cat_path, out_dir, part = sys.argv[1:5]
    os.makedirs(out_dir, exist_ok=True)
    if part == "flyby":
        with open(all_path) as f:
            flyby(json.load(f), out_dir)
    else:
        with open(cat_path) as f:
            cat(json.load(f), out_dir)


if __name__ == "__main__":
    main()
