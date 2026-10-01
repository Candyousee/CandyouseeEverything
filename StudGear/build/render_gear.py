"""Stills of the Stud Gear coils and demo world (workbench).

  lune run build/gear.luau preview <gear.json>
  EGL_PLATFORM=surfaceless python3 build/render_gear.py <gear.json> <out_dir>
"""

import json
import math
import os
import sys

sys.path.insert(0, os.path.dirname(__file__))
os.environ.setdefault("PREVIEW_ENGINE", "workbench")
import render_preview as rp  # noqa: E402
from mathutils import Matrix, Vector  # noqa: E402


def build(parts, offset=Matrix.Identity(4)):
    for p in parts:
        obj = rp.bpy.data.objects.new(p["name"], rp.part_mesh(p))
        obj.data.materials.append(rp.material(p["color"], glow=p.get("neon", False)))
        rp.bpy.context.scene.collection.objects.link(obj)
        obj.matrix_world = rp.CONV @ offset @ rp.cf_matrix(p["frame"])


def look(cam, pos, target, lens):
    cam.location = Vector(pos)
    cam.rotation_euler = (Vector(target) - Vector(pos)).to_track_quat("-Z", "Y").to_euler()
    cam.data.lens = lens


def main():
    data = json.load(open(sys.argv[1]))
    out = sys.argv[2]
    os.makedirs(out, exist_ok=True)
    # coils side by side
    scene = rp.reset_scene()
    scene.render.resolution_x, scene.render.resolution_y = 1800, 1000
    names = list(data["coils"])
    per = 6
    for i, name in enumerate(names):
        row, col = divmod(i, per)
        # Roblox space: x across, rows step back (-Z); turned a little so guns show their side
        m = Matrix.Translation(((col - (per - 1) / 2) * 3.2, 1.0, -row * 6.5)) @ Matrix.Rotation(math.radians(-35), 4, "Y")
        build(data["coils"][name], m)
    cam = rp.add_stage(scene, (0, 0, 2.6), 1)
    look(cam, (0, -24, 9), (0, 3.5, 3.4), 40)
    rp.render_to(scene, os.path.join(out, "coils.png"))
    # demo world
    scene = rp.reset_scene()
    scene.render.resolution_x, scene.render.resolution_y = 1600, 900
    build(data["world"], Matrix.Translation((0, 0.03, 0)))  # just above the stage's ground plane
    cam = rp.add_stage(scene, (0, 0, 0), 1)
    look(cam, (0, -52, 24), (0, 14, 5), 32)
    rp.render_to(scene, os.path.join(out, "world.png"))


if __name__ == "__main__":
    main()
