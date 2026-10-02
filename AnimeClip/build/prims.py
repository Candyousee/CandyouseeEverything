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

SHAPES = {"block": None, "ball": "ball", "cyl": "cylinder", "sphere": "sphere"}


def lin(c):
    return tuple(rp.srgb_to_linear(v) for v in c[:3])


class Pool:
    """Objects per (shape, size) key, reused frame to frame."""

    def __init__(self):
        self.free = {}
        self.used = {}
        self.meshes = {}

    def _mesh(self, shape, size):
        key = (shape, tuple(round(s, 3) for s in size))
        m = self.meshes.get(key)
        if m is None:
            m = rp.part_mesh({"name": "p", "class": "Part", "size": list(size), "color": [0, 0, 0], "shape": SHAPES[shape]})
            self.meshes[key] = m
        return key, m

    def begin(self):
        for key, objs in self.used.items():
            self.free.setdefault(key, []).extend(objs)
        self.used = {}

    def take(self, shape, size):
        key, mesh = self._mesh(shape, size)
        lst = self.free.get(key)
        if lst:
            obj = lst.pop()
        else:
            obj = bpy.data.objects.new("prim", mesh)
            bpy.context.scene.collection.objects.link(obj)
        self.used.setdefault(key, []).append(obj)
        return obj

    def end(self):
        # park anything unused this frame far away
        for objs in self.free.values():
            for o in objs:
                o.location = (0, 0, -9999)


def place(obj, cf, alpha=0.0):
    obj.matrix_world = rp.CONV @ rp.cf_matrix(cf)


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
        obj = pool.take(p["shape"], size)
        place(obj, p["cf"])
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
