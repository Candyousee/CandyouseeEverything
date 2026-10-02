"""Renders the clip's frames (geometry only, sky transparent) with Blender workbench.

  EGL_PLATFORM=surfaceless python3 build/render_clip.py [W H] [first last step]
  -> build/out/render/NNNN.png   (finish_clip.py adds the sky, glow, colour and overlays)
"""

import glob
import json
import math
import os
import sys

sys.path.insert(0, os.path.dirname(__file__))
import prims as P  # noqa: E402

ROOT = os.path.join(os.path.dirname(__file__), "out")
W = int(sys.argv[1]) if len(sys.argv) > 1 else 540
H = int(sys.argv[2]) if len(sys.argv) > 2 else 960
first = int(sys.argv[3]) if len(sys.argv) > 3 else 0
last = int(sys.argv[4]) if len(sys.argv) > 4 else 10**9
step = int(sys.argv[5]) if len(sys.argv) > 5 else 1

scene, cam = P.scene_setup(W, H)
scene.render.film_transparent = True
sh = scene.display.shading
sh.light = "STUDIO"
sh.studio_light = "outdoor.sl" if "outdoor.sl" in [s.name for s in P.bpy.context.preferences.studio_lights] else sh.studio_light
sh.show_shadows = True
sh.shadow_intensity = 0.45
sh.show_cavity = False
sh.show_object_outline = False
scene.display.light_direction = (-0.75, 0.15, 0.35)  # low sun from +X (Blender X = Roblox X)

# the set, once
stage = json.load(open(os.path.join(ROOT, "stage.json")))
static_pool = P.Pool()
P.draw(static_pool, stage["prims"])
stage_objs = list(static_pool.all())

pool = P.Pool()
out_dir = os.path.join(ROOT, "render")
os.makedirs(out_dir, exist_ok=True)
files = sorted(glob.glob(os.path.join(ROOT, "frames", "*.json")))
for path in files:
    idx = int(os.path.basename(path)[:4])
    pick = os.environ.get("FRAMES")
    if pick:
        if idx not in {int(v) for v in pick.split(",")}:
            continue
    elif idx < first or idx > last or (idx - first) % step:
        continue
    fr = json.load(open(path))
    post = fr["post"]
    impact = post.get("impact", 0)
    pool.begin()
    prims = fr["prims"]
    if impact:
        # impact frame: only the fighters, flat white (or black) on the opposite background
        ink = [255, 255, 255] if impact == 1 else [0, 0, 0]
        prims = [dict(p, color=ink, neon=False) for p in prims if p.get("fighter")]
    for o in stage_objs:
        o.hide_render = bool(impact)
    P.draw(pool, prims)
    pool.end()
    cf, fov = fr["camera"]["cf"], fr["camera"]["fov"]
    P.set_camera(cam, cf, fov)
    sh.light = "FLAT" if impact else "STUDIO"
    P.rp.render_to(scene, os.path.join(out_dir, f"{idx:04d}.png"))
print("[render] done")
