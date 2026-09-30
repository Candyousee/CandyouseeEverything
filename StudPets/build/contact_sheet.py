"""Grid of one still per pet: python3 build/contact_sheet.py <stills_dir> <out.jpg> [cols]"""
import os
import sys

from PIL import Image, ImageDraw, ImageFont

src, out = sys.argv[1], sys.argv[2]
cols = int(sys.argv[3]) if len(sys.argv) > 3 else 10
files = sorted(f for f in os.listdir(src) if f.endswith(".png"))
cell = (240, 206)
font = ImageFont.truetype("/usr/share/fonts/truetype/dejavu/DejaVuSans-Bold.ttf", 17)
rows = (len(files) + cols - 1) // cols
sheet = Image.new("RGB", (cell[0] * cols, cell[1] * rows), "white")
draw = ImageDraw.Draw(sheet)
for i, f in enumerate(files):
    im = Image.open(os.path.join(src, f)).convert("RGB").resize(cell, Image.LANCZOS)
    x, y = (i % cols) * cell[0], (i // cols) * cell[1]
    sheet.paste(im, (x, y))
    label = f.split("_")[0].replace("Stud", "")
    draw.text((x + 8, y + 6), label, fill=(20, 20, 30), font=font)
sheet.save(out, quality=88)
print(out, sheet.size)
