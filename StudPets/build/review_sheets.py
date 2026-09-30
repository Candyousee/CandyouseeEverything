"""Review pages: several pets per image, one row per animation, 5 frames each.
python3 build/review_sheets.py <strip_dir> <out_dir> [pets_per_page]"""
import collections
import os
import sys

from PIL import Image, ImageDraw, ImageFont

src, out = sys.argv[1], sys.argv[2]
per = int(sys.argv[3]) if len(sys.argv) > 3 else 3
os.makedirs(out, exist_ok=True)
font = ImageFont.truetype("/usr/share/fonts/truetype/dejavu/DejaVuSans-Bold.ttf", 15)
big = ImageFont.truetype("/usr/share/fonts/truetype/dejavu/DejaVuSans-Bold.ttf", 22)
pets = collections.OrderedDict()
for f in sorted(os.listdir(src)):
    pet, anim, _ = f.split("__")
    pets.setdefault(pet, collections.OrderedDict()).setdefault(anim, []).append(f)
cell = (150, 130)
names = list(pets)
for page in range(0, len(names), per):
    group = names[page:page + per]
    rows = max(len(pets[p]) for p in group)
    pw = cell[0] * 5 + 70
    sheet = Image.new("RGB", (pw * len(group), cell[1] * rows + 30), "white")
    d = ImageDraw.Draw(sheet)
    for g, pet in enumerate(group):
        x0 = g * pw
        d.text((x0 + 70, 3), pet.replace("Stud", ""), fill=(180, 20, 20), font=big)
        for r, (anim, files) in enumerate(pets[pet].items()):
            y = 30 + r * cell[1]
            d.text((x0 + 3, y + 55), anim, fill=(20, 20, 30), font=font)
            for c, f in enumerate(files[:5]):
                im = Image.open(os.path.join(src, f)).convert("RGB").resize(cell, Image.LANCZOS)
                sheet.paste(im, (x0 + 70 + c * cell[0], y))
        d.line([(x0 + pw - 1, 0), (x0 + pw - 1, sheet.height)], fill=(120, 120, 120), width=2)
    sheet.save(os.path.join(out, f"page{page // per + 1:03d}.jpg"), quality=82)
print(len(names), "pets")
