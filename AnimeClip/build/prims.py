"""Turns AnimeClip "prims" (block / ball / cyl with a Roblox CFrame) into Blender objects.

Shared by the pose sheet and the clip preview. Objects are pooled by shape + size so a frame
only moves / recolours what already exists.
"""

import math
import os
import sys

import bpy
from mathutils import Matrix, Vector

sys.path.insert(0, os.path.dirname(__file__))
os.environ.setdefault("PREVIEW_ENGINE", "workbench")
import render_preview as rp  # noqa: E402
from mathutils import Matrix  # noqa: E402,F811

SHAPES = {"block": None, "ball": "ball", "cyl": "cylinder", "sphere": "sphere"}


def lin(c):
    return tuple(rp.srgb_to_linear(v) for v in c[:3])


class Pool:
    """One unit-size mesh per shape; objects are reused frame to frame and scaled to size."""

    def __init__(self):
        self.objs = {}
        self.count = {}
        self.meshes = {}

    def _mesh(self, shape):
        m = self.meshes.get(shape)
        if m is None:
            m = rp.part_mesh({"name": "p", "class": "Part", "size": [1, 1, 1], "color": [0, 0, 0], "shape": SHAPES[shape]})
            self.meshes[shape] = m
        return m

    def begin(self):
        self.count = {}

    def take(self, shape):
        n = self.count.get(shape, 0)
        lst = self.objs.setdefault(shape, [])
        if n < len(lst):
            obj = lst[n]
        else:
            obj = bpy.data.objects.new("prim", self._mesh(shape))
            bpy.context.scene.collection.objects.link(obj)
            lst.append(obj)
        self.count[shape] = n + 1
        obj.hide_render = False
        return obj

    def end(self):
        for shape, lst in self.objs.items():
            for obj in lst[self.count.get(shape, 0):]:
                obj.hide_render = True

    def all(self):
        for lst in self.objs.values():
            yield from lst


def scaled(shape, size):
    sx, sy, sz = size
    if shape == "ball":
        d = min(sx, sy, sz)
        return Matrix.Diagonal((d, d, d, 1))
    if shape == "cyl":
        d = min(sy, sz)
        return Matrix.Diagonal((sx, d, d, 1))
    return Matrix.Diagonal((sx, sy, sz, 1))


def draw(pool, prims):
    for p in prims:
        a = p.get("alpha", 0) or 0
        if a >= 0.97:
            continue
        size = p["size"]
        if a > 0.0:
            # workbench has no soft transparency: shrink faded things instead
            k = max(0.05, 1 - a)
            size = [s * (0.4 + 0.6 * k) for s in size]
        obj = pool.take(p["shape"])
        obj.matrix_world = rp.CONV @ rp.cf_matrix(p["cf"]) @ scaled(p["shape"], size)
        c = lin(p["color"])
        if p.get("neon"):
            c = tuple(min(1.0, v * 1.25 + 0.08) for v in c)
        obj.color = (*c, 1)


def scene_setup(w, h, sky=(0.62, 0.74, 0.92)):
    scene = rp.reset_scene()
    scene.render.resolution_x, scene.render.resolution_y = w, h
    scene.display.shading.color_type = "OBJECT"
    scene.display.render_aa = "8"
    scene.world.color = lin([v * 255 for v in sky]) if max(sky) <= 1 else lin(sky)
    cam = bpy.data.objects.new("Cam", bpy.data.cameras.new("Cam"))
    scene.collection.objects.link(cam)
    scene.camera = cam
    cam.data.sensor_fit = "VERTICAL"
    cam.data.clip_start = 0.05
    cam.data.clip_end = 3000
    return scene, cam


def set_camera(cam, cf, fov):
    cam.matrix_world = rp.CONV @ rp.cf_matrix(cf)
    cam.data.angle_y = math.radians(fov)
