"""12 s showcase video for the Stud Pet System: the egg stands, a Legendary hatch (the exact
timeline the game plays), and a lineup of hatched pets.

  lune run build/petsystem.luau video <sys.json> 2
  lune run build/build.luau preview <pets.json> all WhiteTiger,Unicorn,Bear,Elephant,TRex,Kitsune
  EGL_PLATFORM=surfaceless python3 build/make_system_video.py <sys.json> <pets.json> <frames_dir>
  python3 build/finish_system_video.py <frames_dir> <out.mp4>

Geometry is rendered in Blender (workbench); glows, sparkles, the shockwave ring, screen
flash and labels are drawn afterwards from the per-frame fx_*.json this script writes.
"""

import json
import math
import os
import random
import sys

import bpy
from bpy_extras.object_utils import world_to_camera_view
from mathutils import Matrix, Vector

sys.path.insert(0, os.path.dirname(__file__))
os.environ.setdefault("PREVIEW_ENGINE", "workbench")
import render_preview as rp  # noqa: E402

FPS = 24
W, H = int(os.environ.get("VIDEO_W", 1280)), int(os.environ.get("VIDEO_H", 720))
SHOT1, SHOT3 = 60, 74  # frames; the hatch shot is as long as the hatch itself
GOLD = (255, 196, 40)
SKY = (150, 196, 245)
GRASS = (75, 151, 75)
BACKDROP = (14, 16, 34)
STAGE_FLOOR = (22, 24, 46)
PEDESTAL = (40, 42, 70)


def lin(rgb):
    return tuple(rp.srgb_to_linear(c) for c in rgb)


def lerp3(a, b, k):
    return tuple(a[i] + (b[i] - a[i]) * k for i in range(3))


def smooth(x):
    x = max(0.0, min(1.0, x))
    return x * x * (3 - 2 * x)


# --- Roblox CFrame helpers (Roblox space; CONV turns them into Blender space) -------------
def cf(x=0.0, y=0.0, z=0.0):
    return Matrix.Translation((x, y, z))


def angles(rx, ry, rz):
    return Matrix.Rotation(rx, 4, "X") @ Matrix.Rotation(ry, 4, "Y") @ Matrix.Rotation(rz, 4, "Z")


def look_at(pos, target):
    pos, target = Vector(pos), Vector(target)
    back = (pos - target).normalized()  # Roblox look vector is -Z
    right = Vector((0, 1, 0)).cross(back).normalized()
    up = back.cross(right)
    m = Matrix.Identity(4)
    for r in range(3):
        m[r][0], m[r][1], m[r][2], m[r][3] = right[r], up[r], back[r], pos[r]
    return m


def scale(s):
    return Matrix.Diagonal((s, s, s, 1))


# --- scene --------------------------------------------------------------------------------
def new_scene(sky):
    scene = rp.reset_scene()
    scene.render.resolution_x, scene.render.resolution_y = W, H
    scene.display.render_aa = "16"
    scene.display.shading.color_type = "OBJECT"
    scene.world.color = lin(sky)
    return scene


def add_part(part, color=None):
    obj = bpy.data.objects.new(part["name"], rp.part_mesh(part))
    bpy.context.scene.collection.objects.link(obj)
    obj.color = (*lin(color or part["color"]), 1)
    return obj


def add_box(name, size, color):
    return add_part({"name": name, "class": "Part", "size": list(size), "color": list(color)})


def place(obj, m):
    obj.matrix_world = rp.CONV @ m


def set_color(obj, rgb):
    obj.color = (*lin(rgb), 1)


def add_camera(scene):
    cam = bpy.data.objects.new("Cam", bpy.data.cameras.new("Cam"))
    scene.collection.objects.link(cam)
    scene.camera = cam
    cam.data.sensor_fit = "VERTICAL"
    cam.data.clip_end = 2000
    return cam


def set_camera(cam, m, fov):
    cam.matrix_world = rp.CONV @ m
    cam.data.angle_y = math.radians(fov)


def add_sun(scene):
    sun = bpy.data.objects.new("Sun", bpy.data.lights.new("Sun", "SUN"))
    scene.collection.objects.link(sun)
    scene.display.light_direction = (0.45, -0.35, 0.82)


def project(scene, cam, p):
    """Roblox-space point -> (px, py, depth)."""
    v = world_to_camera_view(scene, cam, rp.CONV @ Vector(p))
    return (v.x * W, (1 - v.y) * H, v.z)


class Pet:
    def __init__(self, data):
        self.anims = {a["name"]: a for a in data["anims"]}
        self.trick = data["anims"][-1]["name"]
        self.objs = [add_part(p) for p in data["parts"]]
        lo, hi = [math.inf] * 3, [-math.inf] * 3
        for i, part in enumerate(data["parts"]):
            m = rp.cf_matrix(data["anims"][0]["frames"][0][i * 12:(i + 1) * 12])
            sx, sy, sz = part["size"]
            for cx in (-1, 1):
                for cy in (-1, 1):
                    for cz in (-1, 1):
                        q = m @ Vector((cx * sx / 2, cy * sy / 2, cz * sz / 2))
                        for a in range(3):
                            lo[a], hi[a] = min(lo[a], q[a]), max(hi[a], q[a])
        self.lo, self.hi = lo, hi
        self.center = Vector([(lo[a] + hi[a]) / 2 for a in range(3)])
        self.extent = max(hi[a] - lo[a] for a in range(3))

    def frame(self, name, t, fps):
        anim = self.anims[name]
        fr = anim["frames"]
        i = int(t * fps)
        i = i % len(fr) if anim.get("looped", True) else min(i, len(fr) - 1)
        return fr[i]

    def length(self, name, fps):
        return len(self.anims[name]["frames"]) / fps

    def pose(self, m, frame):
        for i, obj in enumerate(self.objs):
            obj.matrix_world = rp.CONV @ m @ rp.cf_matrix(frame[i * 12:(i + 1) * 12])

    def hide(self):
        for obj in self.objs:
            obj.matrix_world = Matrix.Translation((0, 0, -999))


def render(scene, out_dir, idx, fx):
    path = os.path.join(out_dir, f"f_{idx:04d}.png")
    with open(os.path.join(out_dir, f"fx_{idx:04d}.json"), "w") as f:
        json.dump(fx, f)
    every = int(os.environ.get("VIDEO_EVERY", "1"))  # >1: quick review renders
    if idx % every == 0 and not os.path.exists(path):
        rp.render_to(scene, path)


# --- shot 1: the six egg stands -----------------------------------------------------------
def shot_stands(sys_data, out_dir, start):
    scene = new_scene(SKY)
    add_sun(scene)
    floor = add_box("Floor", (400, 1, 400), GRASS)
    place(floor, cf(0, -0.5, 0))
    pivots = {k: rp.cf_matrix(v) for k, v in sys_data["pivots"].items()}
    eggs = []
    for p in sys_data["stands"]:
        obj = add_part(p)
        m = rp.cf_matrix(p["cf"])
        if p["isEgg"]:
            pv = pivots[p["stand"]]
            eggs.append((obj, p["stand"], pv, pv.inverted() @ m))
        else:
            place(obj, m)
    order = list(pivots)
    cam = add_camera(scene)
    for f in range(SHOT1):
        t = f / FPS
        for obj, stand, pv, rel in eggs:
            ph = order.index(stand) * 1.1
            place(obj, pv @ cf(0, 0.25 * math.sin((t + ph) * 2), 0) @ angles(0, (t + ph) * 0.6, 0) @ rel)
        # stand in the middle of the arc and pan across the eggs
        k = smooth(f / (SHOT1 - 1))
        a = math.radians(-46 + 92 * k)
        d = Vector((math.sin(a), 0, -math.cos(a)))
        pos = Vector((0, 6.2, 30)) + d * 9
        set_camera(cam, look_at(pos, Vector((0, 4.2, 30)) + d * 26), 50)
        render(scene, out_dir, start + f, {"shot": 1, "t": t})
    return SHOT1


# --- shot 2: the hatch --------------------------------------------------------------------
def shot_hatch(sys_data, pets, out_dir, start):
    scene = new_scene(BACKDROP)
    scene.display.shading.show_shadows = False
    H_ = sys_data["hatch"]
    drama, pop, length = H_["drama"], H_["pop"], H_["length"]
    frames = H_["frames"]
    stage = Matrix.Rotation(math.pi, 4, "Y")  # faces the camera (+Z)
    floor = add_box("Floor", (500, 1, 500), STAGE_FLOOR)
    place(floor, cf(0, -3.4, 0))
    ped = add_part({"name": "Pedestal", "class": "Part", "shape": "cylinder", "size": [0.6, 3.6, 3.6], "color": list(PEDESTAL)})
    place(ped, cf(0, -2.75, 0) @ angles(0, 0, math.radians(90)))
    rim = add_part({"name": "Rim", "class": "Part", "shape": "cylinder", "size": [0.12, 3.75, 3.75], "color": list(lerp3(GOLD, PEDESTAL, 0.45))})
    place(rim, cf(0, -2.62, 0) @ angles(0, 0, math.radians(90)))

    egg_name = "Forest Egg"
    egg_parts = sys_data["eggs"][egg_name]["parts"]
    egg_objs = [(add_part(p), rp.cf_matrix(p["cf"]), p) for p in egg_parts]
    shell, spots = (150, 205, 110), (60, 140, 60)  # Forest egg colours (Config)
    shards = [add_box(f"Shard{k}", (1, 1, 0.16), shell) for k in range(24)]
    palette = [GOLD, lerp3(GOLD, (255, 255, 255), 0.45), lerp3(GOLD, (0, 0, 0), 0.25), lerp3(GOLD, (255, 255, 255), 0.8)]
    confetti = []
    for k in range(1, 22 + 14 * drama + 1):
        confetti.append(add_box(f"Confetti{k}", (0.28, 0.14, 0.03), palette[k % 4]))
    pet = Pet(next(p for p in pets if p["name"] == "StudKitsune"))
    pet_fit = 3.6 / pet.extent
    pfps = pets_fps
    cam = add_camera(scene)
    base_cam = look_at((0, 1.3, 10.5), (0, 0.2, 0))
    oldfov = 46  # tighter than the in-game 70 so the egg fills the video frame
    rng = random.Random(5)
    burst = []
    aura = []
    reveal = pop + 0.12
    trick_at = reveal + 0.35
    n = len(frames)
    for f in range(n):
        t = f / FPS
        s = frames[f]
        # egg
        egg_cf = stage @ cf(*s["eggPos"]) @ angles(*[math.radians(a) for a in s["eggRot"]])
        glow = s["glow"]
        for obj, rel, p in egg_objs:
            if s["eggVisible"]:
                pos = rel.to_translation() * s["eggScale"]
                m = egg_cf @ Matrix.Translation(pos) @ rel.to_3x3().to_4x4() @ scale(s["eggScale"])
                place(obj, m)
                c = p["color"]
                if p.get("crack") and p["crack"] <= s["cracks"]:
                    c = GOLD
                set_color(obj, lerp3(c, GOLD, 0.5 * glow))
            else:
                obj.matrix_world = Matrix.Translation((0, 0, -999))
        # shards
        for k, sh in enumerate(shards):
            d = s["shards"][k] if k < len(s["shards"]) else None
            if d and d["alpha"] > 0.05:
                r = [math.radians(a) for a in d["rot"]]
                place(sh, stage @ cf(*d["pos"]) @ angles(*r) @ Matrix.Diagonal((d["size"], d["size"], 1, 1)))
                set_color(sh, spots if d["color"] == 2 else shell)
            else:
                sh.matrix_world = Matrix.Translation((0, 0, -999))
        # confetti (same motion as HatchPlayer)
        pp = t - pop
        for k, c in enumerate(confetti, start=1):
            h1, h2, h3 = (k * 0.6180339) % 1, (k * 0.4142135 + 0.3) % 1, (k * 0.7320508 + 0.7) % 1
            q = pp - h3 * 0.2
            if 0 < q < 1.5:
                ang = h1 * math.pi * 2
                spread, vy, g = 2.2 + 2.6 * h2, 7 + 2.5 * h3, 16
                apex = vy / g
                y = 0.4 + vy * q - 0.5 * g * q * q if q < apex else 0.4 + 0.5 * vy * apex - (4 + 1.5 * h2) * (q - apex)
                out = spread * (1 - math.exp(-q * 3))
                sway = math.sin(q * (5 + 3 * h1) + k) * 0.35 * min(1, q * 2)
                x, z = math.cos(ang) * out + sway, math.sin(ang) * out * 0.45
                fade = max(min(1, max(0, (-2.9 + 0.8 - y) / 0.8)), min(1, max(0, (q - 1.15) / 0.35)))
                if fade < 0.97:
                    place(c, stage @ cf(x, max(y, -2.9), z) @ angles(q * (6 + k % 5), q * (4 + k % 3), q * (3 + k % 4)) @ scale(1 - fade))
                    continue
            c.matrix_world = Matrix.Translation((0, 0, -999))
        # pet
        if s["petScale"] > 0.15:
            sc = pet_fit * max(0.15, s["petScale"])
            face = cf(0, s["petY"] - 0.2, 0) @ Matrix.Rotation(math.pi, 4, "Y") @ Matrix.Rotation(math.radians(s["petYaw"]), 4, "Y")
            m = face @ Matrix.Translation(-pet.center * sc) @ scale(sc)
            tt = t - trick_at
            if 0 <= tt < pet.length(pet.trick, pfps):
                pet.pose(m, pet.frame(pet.trick, tt, pfps))
            else:
                pet.pose(m, pet.frame("Idle", t, pfps))
        else:
            pet.hide()
        # camera: charge zoom, pop punch, shake
        T0 = H_["shakes"][0]
        charge = max(0.0, min(1.0, (t - T0) / (pop - T0)))
        punch = math.exp(-pp / 0.18) * (6 + 2 * drama) if pp > 0 else 0
        fov = oldfov - (0 if pp > 0 or punch > 0.01 else 9 * charge * charge) + punch
        sh = s["shake"]
        nx = math.sin(t * 61.3) * math.cos(t * 23.1) * sh
        ny = math.sin(t * 47.9 + 1.3) * math.cos(t * 31.7) * sh
        set_camera(cam, base_cam @ cf(nx, ny, 0), fov)
        bpy.context.view_layer.update()

        # 2D effects
        centre = project(scene, cam, (0, 0.2, 0))
        right = project(scene, cam, (1, 0.2, 0))
        pps = abs(right[0] - centre[0])  # pixels per stud at the egg
        fx = {"shot": 2, "t": t, "c": centre[:2], "pps": pps, "flash": s["flash"], "glow": glow, "items": []}
        fx["black"] = 1 - min(1, t / 0.3) * (1 - max(0, min(1, (t - length + 0.3) / 0.3)))
        if 0 <= pp < 0.32:
            k = pp / 0.32
            d = 1.5 + 4.5 * math.sqrt(k) + drama * 0.6
            col = lerp3((255, 255, 255), GOLD, k)
            fx["items"].append({"kind": "ball", "x": centre[0], "y": centre[1], "r": d / 2 * pps, "col": col, "a": 1 - (0.15 + 0.85 * k)})
        ring = s.get("ring")
        if ring:
            r = 0.8 + (ring[0] - 0.8) * 0.65
            fx["items"].append({"kind": "ring", "x": centre[0], "y": centre[1], "r": r * pps, "w": (0.16 * ring[1] + 0.05) * pps, "col": GOLD, "a": ring[1] * 0.7})
        # sparkle burst at the pop, aura while charging and after the reveal
        if f > 0 and frames[f - 1]["eggVisible"] and not s["eggVisible"]:
            for _ in range(45 + 25 * drama):
                v = Vector((rng.gauss(0, 1), rng.gauss(0, 1), rng.gauss(0, 1))).normalized() * rng.uniform(14, 26)
                burst.append((t, v, rng.uniform(0.5, 1.1), rng.uniform(0, 6.28)))
        charging = t >= pop - (0.3 + 0.35 * drama) - 0.16 and pp < 0
        rate = (25 + 15 * drama) if charging else ((18 + 10 * drama) if pp >= 0.12 else 0)
        for _ in range(int(rate / FPS) + (1 if rng.random() < (rate / FPS) % 1 else 0)):
            v = Vector((rng.gauss(0, 1), rng.gauss(0, 1), rng.gauss(0, 1))).normalized() * rng.uniform(1, 3)
            aura.append((t, v, rng.uniform(0.8, 1.4), rng.uniform(0, 6.28)))
        for t0, v, life, rot in burst:
            a = t - t0
            if 0 <= a < life:
                p = v * (1 - math.exp(-5 * a)) / 5
                u = a / life
                size = 0.9 + (0.6 - 0.9) * (u / 0.5) if u < 0.5 else 0.6 * (1 - (u - 0.5) / 0.5)
                alpha = 1 - (0.2 * u / 0.7 if u < 0.7 else 0.2 + 0.8 * (u - 0.7) / 0.3)
                x, y, _ = project(scene, cam, (p.x, 0.2 + p.y, p.z))
                fx["items"].append({"kind": "spark", "x": x, "y": y, "r": size * pps * 0.5, "col": lerp3((255, 255, 255), GOLD, u), "a": alpha, "rot": rot + a * 3})
        for t0, v, life, rot in aura:
            a = t - t0
            if 0 <= a < life:
                p = v * a
                u = a / life
                size = 0.45 * (u / 0.3) if u < 0.3 else 0.45 * (1 - (u - 0.3) / 0.7)
                x, y, _ = project(scene, cam, (p.x, 0.2 + p.y, p.z))
                fx["items"].append({"kind": "spark", "x": x, "y": y, "r": size * pps * 0.5, "col": GOLD, "a": 1.0, "rot": rot})
        lx, ly, _ = project(scene, cam, (0, 0.2 - 4.35, 0))
        fx["label"] = {"x": lx, "y": ly, "pps": pps, "a": s["banner"], "name": "Kitsune", "rarity": "LEGENDARY", "col": GOLD}
        render(scene, out_dir, start + f, fx)
    return n


# --- shot 3: the hatched pets -------------------------------------------------------------
def shot_lineup(pets, out_dir, start):
    scene = new_scene(SKY)
    add_sun(scene)
    floor = add_box("Floor", (400, 1, 400), GRASS)
    place(floor, cf(0, -0.5, 0))
    order = ["StudWhiteTiger", "StudUnicorn", "StudElephant", "StudTRex", "StudBear", "StudKitsune"]
    placed = []
    x = 0.0
    for i, name in enumerate(order):
        pet = Pet(next(p for p in pets if p["name"] == name))
        w = pet.hi[0] - pet.lo[0]
        # Roblox space: pets face -Z; turn them to face the camera (+Z), feet on the floor
        placed.append((pet, x + w / 2, -pet.lo[1], 0.35 + 0.28 * i))
        x += w + 1.6
    total = x - 1.6
    cam = add_camera(scene)
    for f in range(SHOT3):
        t = f / FPS
        for pet, px, py, trick_at in placed:
            m = cf(px - total / 2, py, 0) @ Matrix.Rotation(math.pi, 4, "Y") @ Matrix.Translation((-pet.center.x, 0, -pet.center.z))
            tt = t - trick_at
            if 0 <= tt < pet.length(pet.trick, pets_fps):
                pet.pose(m, pet.frame(pet.trick, tt, pets_fps))
            else:
                pet.pose(m, pet.frame("Idle", t + trick_at, pets_fps))
        k = smooth(f / (SHOT3 - 1))
        pos = (2.0 - 4 * k, 3.8, total * 0.78 + 3 - 3 * k)
        set_camera(cam, look_at(pos, (0, 2.5, 0)), 46)
        render(scene, out_dir, start + f, {"shot": 3, "t": t})
    return SHOT3


pets_fps = 20


def main():
    global pets_fps
    sys_path, pets_path, out_dir = sys.argv[1:4]
    os.makedirs(out_dir, exist_ok=True)
    with open(sys_path) as f:
        sys_data = json.load(f)
    with open(pets_path) as f:
        pd = json.load(f)
    pets_fps = pd.get("fps", 20)
    only = os.environ.get("VIDEO_SHOT")
    n1 = SHOT1
    if only in (None, "1"):
        shot_stands(sys_data, out_dir, 0)
    n2 = len(sys_data["hatch"]["frames"])
    if only in (None, "2"):
        shot_hatch(sys_data, pd["pets"], out_dir, n1)
    if only in (None, "3"):
        shot_lineup(pd["pets"], out_dir, n1 + n2)
    print(f"[video] frames: {n1} + {n2} + {SHOT3} = {(n1 + n2 + SHOT3) / FPS:.1f} s")


if __name__ == "__main__":
    main()
