"""Composites the rendered frames into the final vertical clip.

Adds the sunset sky (per-pixel from each frame's camera), bloom, colour grade, vignette,
anime speed lines, the eye glint, flashes, impact-frame backgrounds, text and the fade.

  python3 build/finish_clip.py <out.mp4> [scale]
"""

import glob
import json
import math
import os
import subprocess
import sys
import tempfile

import numpy as np
from PIL import Image, ImageChops, ImageDraw, ImageFilter, ImageFont

ROOT = os.path.join(os.path.dirname(__file__), "out")
FPS = 30
JP = "/usr/share/fonts/truetype/fonts-japanese-gothic.ttf"
BOLD = "/usr/share/fonts/truetype/dejavu/DejaVuSans-Bold.ttf"
SUN = np.array([320.0, 34.0, -30.0])
SUN /= np.linalg.norm(SUN)


def sky(w, h, cf, fov):
    """Sunset gradient for every pixel's view direction."""
    right = np.array([cf[3], cf[6], cf[9]])
    up = np.array([cf[4], cf[7], cf[10]])
    back = np.array([cf[5], cf[8], cf[11]])
    th = math.tan(math.radians(fov) / 2)
    tw = th * w / h
    xs = (np.arange(w) + 0.5) / w * 2 - 1
    ys = 1 - (np.arange(h) + 0.5) / h * 2
    X, Y = np.meshgrid(xs * tw, ys * th)
    d = X[..., None] * right + Y[..., None] * up - back
    d /= np.linalg.norm(d, axis=-1, keepdims=True)
    el = d[..., 1]
    horizon = np.array([255, 168, 112])
    low = np.array([238, 128, 128])
    mid = np.array([150, 104, 160])
    top = np.array([44, 52, 112])
    e = np.clip(el, -0.2, 1)[..., None]
    c = np.where(e < 0.06, horizon + (low - horizon) * np.clip((e + 0.2) / 0.26, 0, 1) * 0.3,
                 np.where(e < 0.2, horizon + (low - horizon) * (e - 0.06) / 0.14,
                          np.where(e < 0.45, low + (mid - low) * (e - 0.2) / 0.25, mid + (top - mid) * np.clip((e - 0.45) / 0.55, 0, 1))))
    # sun glow
    s = np.clip((d @ SUN), 0, 1)
    glow = (s ** 80) * 0.7 + (s ** 10) * 0.22
    c = c + glow[..., None] * np.array([255, 220, 170])
    return np.clip(c, 0, 255).astype(np.uint8)


def grade(img, post):
    a = np.asarray(img).astype(np.float32) / 255
    tint = np.array(post.get("tint", [1, 1, 1]), dtype=np.float32)
    a = a * tint
    lum = (a @ np.array([0.299, 0.587, 0.114], dtype=np.float32))[..., None]
    a = lum + (a - lum) * (1 + post.get("saturation", 0))
    a = (a - 0.5) * (1 + post.get("contrast", 0)) + 0.5 + post.get("brightness", 0)
    return Image.fromarray((np.clip(a, 0, 1) * 255).astype(np.uint8))


def bloom(img, k):
    if k <= 0:
        return img
    lum = img.convert("L").point(lambda v: 255 if v > 205 else 0)
    bright = Image.composite(img, Image.new("RGB", img.size), lum)
    w = img.size[0]
    halo = bright.filter(ImageFilter.GaussianBlur(w * 0.018)).point(lambda v: int(v * 0.9 * k))
    halo2 = bright.filter(ImageFilter.GaussianBlur(w * 0.05)).point(lambda v: int(v * 0.6 * k))
    return ImageChops.add(ImageChops.add(img, halo), halo2)


def vignette(img, k):
    if k <= 0:
        return img
    w, h = img.size
    ys, xs = np.mgrid[0:h, 0:w]
    r = np.sqrt(((xs - w / 2) / (w / 2)) ** 2 + ((ys - h / 2) / (h / 2)) ** 2)
    m = np.clip(1 - k * np.clip(r - 0.55, 0, 1) ** 1.5, 0, 1)
    a = np.asarray(img).astype(np.float32) * m[..., None]
    return Image.fromarray(a.astype(np.uint8))


def speed_lines(img, k, seed):
    if k <= 0:
        return img
    w, h = img.size
    layer = Image.new("RGBA", img.size, (0, 0, 0, 0))
    d = ImageDraw.Draw(layer)
    rng = np.random.default_rng(seed)
    cx, cy = w / 2, h / 2
    for _ in range(int(70 * k)):
        ang = rng.uniform(0, 2 * math.pi)
        r0 = rng.uniform(0.42, 0.7) * max(w, h)
        r1 = max(w, h) * 1.2
        width = rng.uniform(1, 4) * w / 540
        p0 = (cx + math.cos(ang) * r0, cy + math.sin(ang) * r0)
        p1 = (cx + math.cos(ang) * r1, cy + math.sin(ang) * r1)
        d.line([p0, p1], fill=(255, 255, 255, int(rng.uniform(90, 200) * k)), width=int(width))
    return Image.alpha_composite(img.convert("RGBA"), layer).convert("RGB")


def glint(img, g):
    if not g:
        return img
    w, h = img.size
    k = max(0.0, g["k"])
    y = g["y"] * h
    layer = Image.new("RGBA", img.size, (0, 0, 0, 0))
    d = ImageDraw.Draw(layer)
    for i, (thick, a) in enumerate(((h * 0.02, 60), (h * 0.008, 140), (h * 0.0025, 255))):
        d.rectangle((0, y - thick, w, y + thick), fill=(200, 235, 255, int(a * k)))
    layer = layer.filter(ImageFilter.GaussianBlur(w * 0.004))
    return Image.alpha_composite(img.convert("RGBA"), layer).convert("RGB")


def text(img, t):
    w, h = img.size
    size = int(t["size"] * h * (0.5 if t.get("font") == "jp" else 1))
    font = ImageFont.truetype(JP if t.get("font") == "jp" else BOLD, max(8, size))
    layer = Image.new("RGBA", img.size, (0, 0, 0, 0))
    d = ImageDraw.Draw(layer)
    msg = t["text"]
    spacing = t.get("spacing", 0) * size
    widths = [d.textlength(ch, font=font) for ch in msg]
    total = sum(widths) + spacing * (len(msg) - 1)
    x = (w - total) / 2
    y = t["y"] * h - size / 2
    a = int(255 * max(0, min(1, t["alpha"])))
    col = tuple(t.get("color", [255, 255, 255]))
    for ch, cw in zip(msg, widths):
        d.text((x, y), ch, font=font, fill=(*col, a), stroke_width=max(1, size // 18), stroke_fill=(10, 10, 20, int(a * 0.8)))
        x += cw + spacing
    glow = layer.filter(ImageFilter.GaussianBlur(size * 0.15))
    out = Image.alpha_composite(img.convert("RGBA"), glow)
    return Image.alpha_composite(out, layer).convert("RGB")


def frame(path, render_path, scale):
    fr = json.load(open(path))
    post = fr["post"]
    geo = Image.open(render_path).convert("RGBA")
    w, h = geo.size
    impact = post.get("impact", 0)
    if impact:
        bg = Image.new("RGB", (w, h), (0, 0, 0) if impact == 1 else (255, 255, 255))
        img = Image.alpha_composite(bg.convert("RGBA"), geo).convert("RGB")
    else:
        bg = Image.fromarray(sky(w, h, fr["camera"]["cf"], fr["camera"]["fov"]))
        img = Image.alpha_composite(bg.convert("RGBA"), geo).convert("RGB")
        img = grade(img, post)
        img = bloom(img, post.get("bloom", 0.6))
        img = vignette(img, post.get("vignette", 0))
    if scale != 1:
        img = img.resize((int(w * scale), int(h * scale)), Image.LANCZOS)
    img = speed_lines(img, post.get("speed", 0), int(fr["t"] * 1000))
    img = glint(img, post.get("glint"))
    if post.get("flash", 0) > 0:
        img = Image.blend(img, Image.new("RGB", img.size, (255, 255, 255)), min(1, post["flash"]))
    for t in post.get("texts", []):
        img = text(img, t)
    if post.get("fade", 0) > 0:
        img = Image.blend(img, Image.new("RGB", img.size, (0, 0, 0)), min(1, post["fade"]))
    return img


def main():
    out = sys.argv[1]
    scale = float(sys.argv[2]) if len(sys.argv) > 2 else 1.0
    renders = sorted(glob.glob(os.path.join(ROOT, "render", "*.png")))
    tmp = tempfile.mkdtemp()
    for i, rp in enumerate(renders):
        idx = os.path.basename(rp)[:4]
        img = frame(os.path.join(ROOT, "frames", idx + ".json"), rp, scale)
        img.save(os.path.join(tmp, f"{i:05d}.png"))
    if out.endswith(".mp4"):
        subprocess.run(["ffmpeg", "-y", "-loglevel", "error", "-framerate", str(FPS), "-i", os.path.join(tmp, "%05d.png"),
                        "-c:v", "libx264", "-pix_fmt", "yuv420p", "-crf", "17", "-preset", "slow", "-movflags", "+faststart", out], check=True)
    else:
        # a contact sheet of the frames
        ims = [Image.open(os.path.join(tmp, f)) for f in sorted(os.listdir(tmp))]
        cw, ch = ims[0].size
        cols = 5
        sheet = Image.new("RGB", (cw * cols, ch * math.ceil(len(ims) / cols)))
        for i, im in enumerate(ims):
            sheet.paste(im, ((i % cols) * cw, (i // cols) * ch))
        sheet.save(out, quality=82)
    print("[finish]", out, len(renders), "frames")


if __name__ == "__main__":
    main()
