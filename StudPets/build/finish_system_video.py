"""Composites the Stud Pet System showcase: draws the glows, sparkles, shockwave ring, flash,
pet label and titles over the frames from make_system_video.py, then encodes the mp4.

  python3 build/finish_system_video.py <frames_dir> <out.mp4>
"""

import json
import math
import os
import subprocess
import sys
import tempfile

from PIL import Image, ImageChops, ImageDraw, ImageFilter, ImageFont

FPS = 24
BOLD = "/usr/share/fonts/truetype/dejavu/DejaVuSans-Bold.ttf"
GOLD = (255, 214, 92)


def font(size):
    return ImageFont.truetype(BOLD, int(size))


def fade(t, start, end, ramp=0.3):
    if t < start or t > end:
        return 0.0
    return min(1.0, (t - start) / ramp, (end - t) / ramp)


def text(img, msg, size, y, alpha, color=(255, 255, 255), x=None):
    if alpha <= 0:
        return img
    layer = Image.new("RGBA", img.size, (0, 0, 0, 0))
    d = ImageDraw.Draw(layer)
    f = font(size)
    w = d.textlength(msg, font=f)
    x = (img.width - w) / 2 if x is None else x - w / 2
    stroke = max(2, int(size) // 12)
    d.text((x, y), msg, font=f, fill=(*color, int(255 * alpha)), stroke_width=stroke, stroke_fill=(24, 22, 40, int(230 * alpha)))
    return Image.alpha_composite(img, layer)


def banner(img, y0, y1, alpha):
    if alpha <= 0:
        return img
    layer = Image.new("RGBA", img.size, (0, 0, 0, 0))
    ImageDraw.Draw(layer).rectangle((0, y0, img.width, y1), fill=(20, 22, 34, int(130 * alpha)))
    return Image.alpha_composite(img, layer)


def glow_layer(size, items):
    """Additive light: soft discs, rings and four-point sparkles."""
    layer = Image.new("RGB", size, (0, 0, 0))
    d = ImageDraw.Draw(layer)
    for it in items:
        a = max(0.0, min(1.0, it["a"]))
        if a <= 0.01:
            continue
        col = tuple(int(c * a) for c in it["col"])
        x, y, r = it["x"], it["y"], it["r"]
        if it["kind"] == "ball":
            for k in range(6, 0, -1):
                rr = r * k / 6
                kk = (1 - k / 7) ** 0.7
                d.ellipse((x - rr, y - rr, x + rr, y + rr), fill=tuple(int(c * kk) for c in col))
        elif it["kind"] == "ring":
            d.ellipse((x - r, y - r, x + r, y + r), outline=col, width=max(2, int(it["w"])))
        elif it["kind"] == "spark" and r > 0.4:
            rot = it.get("rot", 0)
            for k in range(2):
                ang = rot + k * math.pi / 2
                dx, dy = math.cos(ang) * r * 1.6, math.sin(ang) * r * 1.6
                px, py = -dy * 0.18, dx * 0.18
                d.polygon([(x - dx, y - dy), (x + px, y + py), (x + dx, y + dy), (x - px, y - py)], fill=col)
            d.ellipse((x - r * 0.35, y - r * 0.35, x + r * 0.35, y + r * 0.35), fill=col)
    return layer


def bloom(img, strength):
    rgb = img.convert("RGB")
    lum = rgb.convert("L").point(lambda v: 255 if v > 200 else 0)
    bright = Image.composite(rgb, Image.new("RGB", rgb.size), lum)
    halo = bright.filter(ImageFilter.GaussianBlur(14))
    halo = halo.point(lambda v: int(v * strength))
    return ImageChops.add(rgb, halo).convert("RGBA")


def pet_label(img, lab):
    a = lab["a"]
    if a <= 0.01:
        return img
    pps = lab["pps"]
    w, h = 7 * pps * 0.85, 2.2 * pps
    x, y = lab["x"], lab["y"] - h / 2
    layer = Image.new("RGBA", img.size, (0, 0, 0, 0))
    ImageDraw.Draw(layer).rounded_rectangle((x - w / 2, y, x + w / 2, y + h), radius=h * 0.25, fill=(16, 18, 34, int(255 * 0.55 * a)))
    img = Image.alpha_composite(img, layer)
    img = text(img, lab["name"], h * 0.42, y + h * 0.04, a, x=x)
    img = text(img, lab["rarity"], h * 0.32, y + h * 0.56, a, tuple(lab["col"]), x=x)
    return img


def main():
    src, out = sys.argv[1], sys.argv[2]
    frames = sorted(f for f in os.listdir(src) if f.startswith("f_") and f.endswith(".png"))
    tmp = tempfile.mkdtemp()
    n = len(frames)
    for i, name in enumerate(frames):
        with open(os.path.join(src, "fx_" + name[2:-4] + ".json")) as f:
            fx = json.load(f)
        img = Image.open(os.path.join(src, name)).convert("RGBA")
        W, H = img.size
        g = W / 1280
        if fx["shot"] == 1:
            t = fx["t"]
            a = fade(t, 0.15, 2.2)
            img = text(img, "STUD PET SYSTEM", 84 * g, H * 0.07, a, GOLD)
            img = text(img, "6 stud eggs  ·  48 animated pets  ·  drag & drop", 32 * g, H * 0.07 + 100 * g, a)
            img = Image.alpha_composite(img, Image.new("RGBA", img.size, (0, 0, 0, int(255 * max(0, (t - 2.25) / 0.25)))))
        elif fx["shot"] == 2:
            img = bloom(img, 0.55 + 0.4 * fx["glow"])
            light = glow_layer(img.size, fx["items"]).filter(ImageFilter.GaussianBlur(1.2 * g))
            img = ImageChops.add(img.convert("RGB"), light).convert("RGBA")
            img = pet_label(img, fx["label"])
            if fx["flash"] > 0:
                img = Image.alpha_composite(img, Image.new("RGBA", img.size, (255, 255, 255, int(255 * fx["flash"]))))
            t = fx["t"]
            a = fade(t, 0.5, 2.6)
            img = banner(img, H - 96 * g, H - 26 * g, a)
            img = text(img, "Shakes, cracks and bursts in the rarity's colour", 32 * g, H - 82 * g, a)
            if fx["black"] > 0:
                img = Image.alpha_composite(img, Image.new("RGBA", img.size, (0, 0, 0, int(255 * min(1, fx["black"])))))
        else:
            t = fx["t"]
            img = Image.alpha_composite(img, Image.new("RGBA", img.size, (0, 0, 0, int(255 * max(0, 1 - t / 0.25)))))
            a = fade(t, 0.1, 1.45, 0.25)
            img = banner(img, H - 96 * g, H - 26 * g, a)
            img = text(img, "Inventory  ·  Equip Best  ·  Pets follow you  ·  Saves", 30 * g, H - 82 * g, a)
            e = min(1.0, max(0.0, (t - 1.5) / 0.3))
            if e > 0:
                blur = img.filter(ImageFilter.GaussianBlur(8 * g))
                blur = Image.alpha_composite(blur, Image.new("RGBA", img.size, (20, 22, 34, 150)))
                img = Image.blend(img, blur, e)
                img = text(img, "STUD PET SYSTEM", 76 * g, H * 0.27, e, GOLD)
                img = text(img, "Server-rolled hatches  ·  Open 1 or 3  ·  Easy Config", 30 * g, H * 0.27 + 98 * g, e)
                img = text(img, "Roblox Creator Store", 42 * g, H * 0.27 + 160 * g, e)
        img.convert("RGB").save(os.path.join(tmp, f"{i:05d}.png"))
    subprocess.run(["ffmpeg", "-y", "-loglevel", "error", "-framerate", str(FPS), "-i", os.path.join(tmp, "%05d.png"),
                    "-c:v", "libx264", "-pix_fmt", "yuv420p", "-crf", "18", "-preset", "slow", "-movflags", "+faststart", out], check=True)
    print(f"[video] {out}: {n} frames, {n / FPS:.1f} s")


if __name__ == "__main__":
    main()
