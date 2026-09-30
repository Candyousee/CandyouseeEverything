"""Turn rendered frames into preview GIFs.

  python3 build/make_gifs.py <frames_dir> <out_dir>

frames_dir/<Pet>/<Anim>/0000.png ... (from render_preview.py anim mode)
Writes <out_dir>/<Pet>_all.gif: every animation playing at once in a labelled grid.
"""

import os
import sys

from PIL import Image, ImageDraw, ImageFont

FPS = 20
GRID_SECONDS = 4.0
CELL = (256, 220)
FONT = "/usr/share/fonts/truetype/dejavu/DejaVuSans-Bold.ttf"
ORDER = ["Idle", "Walk", "Run", "Sit", "Jump", "Sleep", "Stretch", "Bark"]
ONE_SHOT_HOLD = 12  # frames to rest on the first frame between one-shot plays


def load(pet_dir):
    anims = {}
    for name in sorted(os.listdir(pet_dir)):
        files = sorted(os.listdir(os.path.join(pet_dir, name)))
        anims[name] = [Image.open(os.path.join(pet_dir, name, f)).convert("RGB").resize(CELL, Image.LANCZOS) for f in files]
    return anims


def main():
    frames_dir, out_dir = sys.argv[1], sys.argv[2]
    os.makedirs(out_dir, exist_ok=True)
    font = ImageFont.truetype(FONT, 20)
    title_font = ImageFont.truetype(FONT, 30)
    for pet in sorted(os.listdir(frames_dir)):
        anims = load(os.path.join(frames_dir, pet))
        names = [n for n in ORDER if n in anims]
        looped = {n: n not in ("Jump", "Stretch", "Bark") for n in names}
        total = int(GRID_SECONDS * FPS)
        cols = 4
        rows = (len(names) + 1 + cols - 1) // cols
        out = []
        for i in range(total):
            sheet = Image.new("RGB", (CELL[0] * cols, CELL[1] * rows), (240, 242, 246))
            draw = ImageDraw.Draw(sheet)
            for k, name in enumerate(names):
                seq = anims[name]
                if not looped[name]:
                    seq = [seq[0]] * ONE_SHOT_HOLD + seq
                im = seq[i % len(seq)]
                x, y = (k % cols) * CELL[0], (k // cols) * CELL[1]
                sheet.paste(im, (x, y))
                draw.text((x + 10, y + 8), name, fill=(25, 25, 35), font=font)
            k = len(names)
            x, y = (k % cols) * CELL[0], (k // cols) * CELL[1]
            label = pet.replace("Stud", "Stud ")
            draw.text((x + 20, y + 70), label, fill=(25, 25, 35), font=title_font)
            draw.text((x + 20, y + 112), f"{len(names)} animations", fill=(90, 95, 110), font=font)
            out.append(sheet)
        # one shared palette, no dithering: render noise otherwise defeats GIF compression
        palette = out[len(out) // 2].quantize(colors=128, method=Image.Quantize.MEDIANCUT)
        frames = [f.quantize(palette=palette, dither=Image.Dither.NONE) for f in out]
        path = os.path.join(out_dir, f"{pet}_all.gif")
        frames[0].save(path, save_all=True, append_images=frames[1:], duration=int(1000 / FPS), loop=0, optimize=True)
        print(path, os.path.getsize(path) // 1024, "KB")


if __name__ == "__main__":
    main()
