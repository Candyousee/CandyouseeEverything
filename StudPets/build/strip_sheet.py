"""Per-pet grid: one row per animation, frames left to right.
python3 build/strip_sheet.py <strip_dir> <out_dir>"""
import collections
import os
import sys

from PIL import Image, ImageDraw, ImageFont

src, out = sys.argv[1], sys.argv[2]
os.makedirs(out, exist_ok=True)
font = ImageFont.truetype("/usr/share/fonts/truetype/dejavu/DejaVuSans-Bold.ttf", 16)
pets = collections.defaultdict(lambda: collections.defaultdict(list))
order = {}
for f in sorted(os.listdir(src)):
    pet, anim, _ = f.split("__")
    pets[pet][anim].append(f)
    order.setdefault(pet, [])
    if anim not in order[pet]:
        order[pet].append(anim)
cell = (200, 173)
for pet, anims in pets.items():
    rows = order[pet]
    sheet = Image.new("RGB", (cell[0] * 5 + 90, cell[1] * len(rows)), "white")
    d = ImageDraw.Draw(sheet)
    for r, anim in enumerate(rows):
        d.text((6, r * cell[1] + 70), anim, fill=(20, 20, 30), font=font)
        for c, f in enumerate(anims[anim]):
            im = Image.open(os.path.join(src, f)).convert("RGB").resize(cell, Image.LANCZOS)
            sheet.paste(im, (90 + c * cell[0], r * cell[1]))
    sheet.save(os.path.join(out, pet + ".jpg"), quality=85)
print("ok")
