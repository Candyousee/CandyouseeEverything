"""Pose sheet: each pose rendered on its own from a 3/4 front-side view, labelled."""
import json, math, os, sys
sys.path.insert(0, os.path.dirname(__file__))
import prims as P
from PIL import Image, ImageDraw, ImageFont
data = json.load(open(sys.argv[1]))
out = sys.argv[2]
scene, cam = P.scene_setup(360, 440)
pool = P.Pool()
P.draw(pool, data["prims"])
tiles = []
for i, name in enumerate(data["names"]):
    x = i * 100
    # fighter faces +X: camera in front-right (+X, +Z), looking at the body
    pos = (x + 7.5, 3.6, 8.5)
    tgt = (x + 0.4, 2.4, 0)
    import mathutils
    d = mathutils.Vector(tgt) - mathutils.Vector(pos)
    # build a Roblox-style lookAt CF
    back = (-d).normalized()
    right = mathutils.Vector((0, 1, 0)).cross(back).normalized()
    up = back.cross(right)
    cf = [pos[0], pos[1], pos[2], right.x, up.x, back.x, right.y, up.y, back.y, right.z, up.z, back.z]
    P.set_camera(cam, cf, 40)
    path = os.path.join(os.path.dirname(out), f"pose_{i:02d}.png")
    P.rp.render_to(scene, path)
    tiles.append((name, path))
W, H = 360, 440
sheet = Image.new("RGB", (W * 8, H * 2), "white")
font = ImageFont.truetype("/usr/share/fonts/truetype/dejavu/DejaVuSans-Bold.ttf", 26)
for i, (name, path) in enumerate(tiles):
    im = Image.open(path).convert("RGB")
    ImageDraw.Draw(im).text((10, 8), name, fill=(20, 20, 30), font=font)
    sheet.paste(im, ((i % 8) * W, (i // 8) * H))
sheet.save(out, quality=85)
