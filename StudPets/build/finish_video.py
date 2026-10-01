"""Adds titles to the frames from make_video.py and encodes the mp4.

  python3 build/finish_video.py <frames_dir> <out.mp4>
"""

import os
import subprocess
import sys
import tempfile

from PIL import Image, ImageDraw, ImageFilter, ImageFont

FPS = 24
BOLD = "/usr/share/fonts/truetype/dejavu/DejaVuSans-Bold.ttf"


def font(size):
    return ImageFont.truetype(BOLD, size)


def fade(t, start, end, ramp=0.35):
    if t < start or t > end:
        return 0.0
    return min(1.0, (t - start) / ramp, (end - t) / ramp)


def text(img, msg, size, y, alpha, color=(255, 255, 255)):
    if alpha <= 0:
        return img
    layer = Image.new("RGBA", img.size, (0, 0, 0, 0))
    d = ImageDraw.Draw(layer)
    f = font(size)
    w = d.textlength(msg, font=f)
    x = (img.width - w) / 2
    stroke = max(2, size // 12)
    d.text((x, y), msg, font=f, fill=(*color, int(255 * alpha)), stroke_width=stroke, stroke_fill=(30, 30, 46, int(230 * alpha)))
    return Image.alpha_composite(img, layer)


def banner(img, y0, y1, alpha):
    if alpha <= 0:
        return img
    layer = Image.new("RGBA", img.size, (0, 0, 0, 0))
    ImageDraw.Draw(layer).rectangle((0, y0, img.width, y1), fill=(20, 22, 34, int(120 * alpha)))
    return Image.alpha_composite(img, layer)


def main():
    src, out = sys.argv[1], sys.argv[2]
    flyby = sorted(f for f in os.listdir(src) if f.startswith("flyby_"))
    cat = sorted(f for f in os.listdir(src) if f.startswith("cat_"))
    run_frames = 3 * FPS
    tmp = tempfile.mkdtemp()
    n = 0

    def emit(img):
        nonlocal n
        img.convert("RGB").save(os.path.join(tmp, f"{n:05d}.png"))
        n += 1

    for i, name in enumerate(flyby):
        t = i / FPS
        img = Image.open(os.path.join(src, name)).convert("RGBA")
        H = img.height
        a = fade(t, 0.2, 3.0)
        img = text(img, "STUD PETS", 96, int(H * 0.08), a, (255, 214, 92))
        img = text(img, "200 animated blocky pets for Roblox", 38, int(H * 0.08) + 112, a)
        for msg, s, e in (
            ("Dogs  ·  Cats  ·  Dinos  ·  Dragons  ·  Ocean  ·  Birds  ·  Bugs", 3.6, 7.2),
            ("Every pet: Idle · Walk · Run · Sit · Jump · Sleep · Trick", 7.6, 11.6),
        ):
            a = fade(t, s, e)
            img = banner(img, H - 108, H - 30, a)
            img = text(img, msg, 34, H - 92, a)
        emit(img)

    last = None
    for i, name in enumerate(cat):
        t = i / FPS
        img = Image.open(os.path.join(src, name)).convert("RGBA")
        H = img.height
        if i < run_frames:
            a = fade(t, 0.15, 2.9)
            msg = "Smooth animations, played straight from code"
        else:
            a = fade(t - run_frames / FPS, 0.15, 10)
            msg = "...and a unique trick for every pet"
        img = banner(img, H - 108, H - 30, a)
        img = text(img, msg, 34, H - 92, a)
        emit(img)
        last = Image.open(os.path.join(src, name)).convert("RGBA")

    # end card over a soft, dimmed last frame
    end = last.filter(ImageFilter.GaussianBlur(8))
    end = Image.alpha_composite(end, Image.new("RGBA", end.size, (20, 22, 34, 150)))
    H = end.height
    for i in range(int(2.0 * FPS)):
        a = min(1.0, (i + 1) / 8)
        img = Image.alpha_composite(last, Image.blend(last, end, a)) if a < 1 else end
        img = text(img, "STUD PETS  ·  200 PACK", 72, int(H * 0.28), a, (255, 214, 92))
        img = text(img, "No uploads  ·  No asset IDs  ·  Drop in & press Play", 34, int(H * 0.28) + 100, a)
        img = text(img, "Roblox Creator Store", 44, int(H * 0.28) + 170, a)
        emit(img)

    subprocess.run(["ffmpeg", "-y", "-loglevel", "error", "-framerate", str(FPS), "-i", os.path.join(tmp, "%05d.png"),
                    "-c:v", "libx264", "-pix_fmt", "yuv420p", "-crf", "18", "-preset", "slow", "-movflags", "+faststart", out], check=True)
    print(f"[video] {out}: {n} frames, {n / FPS:.1f} s")


if __name__ == "__main__":
    main()
