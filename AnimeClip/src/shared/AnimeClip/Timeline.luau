--!strict
-- The whole 10-second clip as pure maths: who stands where in which pose, where the camera
-- is, every visual effect, and the post-processing. Sample(t) returns one frame.
-- The game and the offline preview both play this, so they match.
--
-- World: flat ground at y = 0. The hero starts at x = -9 facing +X, the rival at x = +9
-- facing -X. The sun sets behind the rival (+X).

local here = script and script.Parent
local CF = require(here and here:FindFirstChild("CF") or "./CF")
local Rig = require(here and here:FindFirstChild("Rig") or "./Rig")
local Poses = require(here and here:FindFirstChild("Poses") or "./Poses")
local Props = require(here and here:FindFirstChild("Props") or "./Props")

local T = {}
T.LENGTH = 10

local rad = math.rad
local smooth, easeOut, easeIn, clamp01, lerp = CF.smooth, CF.easeOut, CF.easeIn, CF.clamp01, CF.lerp

---------------------------------------------------------------------------
-- Colours
---------------------------------------------------------------------------
local WHITE = { 255, 255, 255 }
local CYAN = { 110, 220, 255 }
local DEEPBLUE = { 40, 120, 255 }
local SPARK = { 255, 220, 140 }
local RED = { 255, 70, 80 }
local PETAL = { 255, 182, 206 }
local PETAL2 = { 255, 214, 228 }
local DUST = { 214, 196, 170 }
local ROCK = { 96, 88, 82 }

---------------------------------------------------------------------------
-- Fighters: keyframes { t, pose, x, z, yaw (deg), lift, ease, sword, glow }
---------------------------------------------------------------------------
local HERO_YAW, RIVAL_YAW = -90, 90

local function dashKeys(list, t0, t1, x0, x1, yaw, sword)
	local n = 8
	for i = 1, n do
		local k = i / n
		-- accelerate hard, ease into contact
		local xk = easeIn(k, 1.6)
		table.insert(list, { t = t0 + (t1 - t0) * k, pose = if i % 2 == 0 then "Dash" else "Dash2", x = lerp(x0, x1, xk), yaw = yaw, sword = sword, ease = "linear" })
	end
end

local HERO = {
	{ t = 0, pose = "Stand", x = -9, sword = "sheath" },
	{ t = 0.95, pose = "Stand", x = -9, sword = "sheath" },
	{ t = 1.55, pose = "Ready", x = -9.2, sword = "sheath", ease = "out" },
	{ t = 3.02, pose = "Ready", x = -9.2, sword = "sheath" },
	{ t = 3.08, pose = "Ready", x = -9.2, sword = "hand" },
	{ t = 3.2, pose = "Draw", x = -9.1, sword = "hand", ease = "out" },
	{ t = 3.3, pose = "Dash", x = -8.6, sword = "hand", ease = "in" },
}
dashKeys(HERO, 3.3, 4.3, -8.6, -1.5, HERO_YAW, "hand")
for _, k in {
	{ t = 4.3, pose = "Clash", x = -1.5, sword = "hand", ease = "step" },
	{ t = 6.0, pose = "Clash", x = -1.4, sword = "hand" },
	{ t = 6.25, pose = "Guard", x = -5.6, sword = "hand", ease = "out" },
	{ t = 6.62, pose = "Guard", x = -5.5, sword = "hand" },
	{ t = 6.78, pose = "Block", x = -5.3, sword = "hand", ease = "out" },
	{ t = 7.05, pose = "Block", x = -5.4, sword = "hand" },
	{ t = 7.3, pose = "Guard", x = -4.6, sword = "hand", ease = "out" },
	{ t = 7.45, pose = "Charge", x = -4.6, sword = "hand", ease = "out", glow = 0.2 },
	{ t = 8.45, pose = "Charge", x = -4.6, sword = "hand", glow = 1 },
	{ t = 8.56, pose = "IaiReady", x = -4.7, sword = "hand", ease = "out", glow = 1 },
	{ t = 8.62, pose = "IaiReady", x = -4.7, sword = "hand", glow = 1 },
	{ t = 8.621, pose = "IaiFinish", x = 8.4, sword = "hand", ease = "step", glow = 1 },
	{ t = 9.3, pose = "IaiFinish", x = 8.4, sword = "hand", glow = 0.3 },
	{ t = 9.55, pose = "Sheathe", x = 8.4, sword = "hand", ease = "smooth", glow = 0 },
	{ t = 9.56, pose = "Sheathe", x = 8.4, sword = "sheath" },
	{ t = 10, pose = "Sheathe", x = 8.4, sword = "sheath" },
} do
	table.insert(HERO, k)
end

local RIVAL = {
	{ t = 0, pose = "Stand", x = 9, sword = "hand" },
	{ t = 1.0, pose = "Stand", x = 9, sword = "hand" },
	{ t = 1.6, pose = "Guard", x = 8.8, sword = "hand", ease = "out" },
	{ t = 3.3, pose = "Guard", x = 8.6, sword = "hand" },
}
dashKeys(RIVAL, 3.3, 4.3, 8.6, 1.5, RIVAL_YAW, "hand")
for _, k in {
	{ t = 4.3, pose = "Clash", x = 1.5, sword = "hand", ease = "step" },
	{ t = 6.0, pose = "Clash", x = 1.4, sword = "hand" },
	{ t = 6.25, pose = "Guard", x = 5.6, sword = "hand", ease = "out" },
	{ t = 6.38, pose = "Guard", x = 5.4, sword = "hand" },
	{ t = 6.58, pose = "SlashWind", x = 1.6, lift = 3.6, sword = "hand", ease = "out" },
	{ t = 6.78, pose = "SlashWind", x = -2.2, lift = 1.4, sword = "hand", ease = "in" },
	{ t = 6.86, pose = "SlashFollow", x = -2.7, lift = 0, sword = "hand", ease = "out" },
	{ t = 7.05, pose = "SlashFollow", x = -2.5, sword = "hand" },
	{ t = 7.18, pose = "Guard", x = 0.6, lift = 2.4, sword = "hand", ease = "out" },
	{ t = 7.4, pose = "Guard", x = 4.6, lift = 0, sword = "hand", ease = "in" },
	{ t = 9.56, pose = "Guard", x = 4.6, sword = "hand" },
	{ t = 9.66, pose = "Hit", x = 4.5, sword = "hand", ease = "out" },
	{ t = 9.95, pose = "Kneel", x = 4.4, sword = "hand", ease = "smooth" },
	{ t = 10, pose = "Kneel", x = 4.4, sword = "hand" },
} do
	table.insert(RIVAL, k)
end

T.TRACKS = { hero = HERO, rival = RIVAL }
T.STYLE = { hero = "hero", rival = "rival" }

local function ease(kind: string?, k: number): number
	if kind == "out" then
		return easeOut(k, 3)
	elseif kind == "in" then
		return easeIn(k, 2)
	elseif kind == "linear" then
		return k
	elseif kind == "step" then
		return 1
	end
	return smooth(k)
end

-- pose + placement of a fighter at time t
function T.ActorState(name: string, t: number)
	local track = T.TRACKS[name]
	local a, b = track[1], track[#track]
	for i = 1, #track - 1 do
		if t >= track[i].t and t < track[i + 1].t then
			a, b = track[i], track[i + 1]
			break
		end
	end
	if t >= track[#track].t then
		a = track[#track]
		b = a
	end
	local span = b.t - a.t
	local k = if span > 0 then ease(b.ease, clamp01((t - a.t) / span)) else 1
	local pose = Poses.Blend(Poses[a.pose], Poses[b.pose], k)
	local yawDeg = if name == "hero" then HERO_YAW else RIVAL_YAW
	local s = {
		pose = pose,
		x = lerp(a.x or 0, b.x or a.x or 0, k),
		z = lerp(a.z or 0, b.z or a.z or 0, k),
		lift = lerp(a.lift or 0, b.lift or 0, k),
		yaw = yawDeg,
		sword = if k >= 1 then b.sword or a.sword else a.sword,
		glow = lerp(a.glow or 0, b.glow or a.glow or 0, k),
		grounded = true,
	}
	-- life: breathing, and the trembling strain of the locked blades
	Poses.Add(pose, "Waist", math.sin(t * 2.4 + (if name == "hero" then 0 else 1.3)) * 1.4, 0, 0)
	if t > 4.4 and t < 6.0 then
		local n = CF.noise(t * 22, if name == "hero" then 1 else 2)
		s.x += n * 0.04
		Poses.Add(pose, "RightShoulder", n * 2.5, 0, 0)
		Poses.Add(pose, "LeftShoulder", -n * 2.5, 0, 0)
	end
	return s
end

-- root CFrame of a fighter for a given rig (feet planted on the ground, plus any jump lift)
function T.RootFor(desc: any, s: any, standHeight: number?): { number }
	local h = standHeight or Rig.StandHeight(desc)
	local root = CF.mul(CF.new(s.x, h, s.z), CF.angles(0, rad(s.yaw), 0))
	if s.grounded then
		local world = Rig.FK(desc, root, s.pose)
		local low = Rig.Lowest(desc, world)
		root = CF.mul(CF.new(0, -low, 0), root)
	end
	return CF.mul(CF.new(0, s.lift, 0), root)
end

local PROXY_STAND = Rig.StandHeight(Rig.PROXY)
-- stand-in FK used for aiming cameras and effects
function T.ProxyWorld(name: string, t: number): { [string]: { number } }
	local s = T.ActorState(name, t)
	return Rig.FK(Rig.PROXY, T.RootFor(Rig.PROXY, s, PROXY_STAND), s.pose)
end

---------------------------------------------------------------------------
-- Prim helpers
---------------------------------------------------------------------------
local P = Props.prim
local function ball(out, pos, r, color, alpha, neon)
	table.insert(out, P("ball", CF.new(pos[1], pos[2], pos[3]), { r * 2, r * 2, r * 2 }, color, { alpha = alpha or 0, neon = neon ~= false }))
end
local function streak(out, p0, p1, w, color, alpha, neon)
	local d = CF.sub(p1, p0)
	local l = CF.len(d)
	if l < 1e-3 then
		return
	end
	table.insert(out, P("block", CF.along(CF.lerpv(p0, p1, 0.5), d), { l, w, w }, color, { alpha = alpha or 0, neon = neon ~= false }))
end
-- a ring (torus of segments) round `axis` frame's Y axis
local function ring(out, frame, radius, thick, color, alpha, segs)
	segs = segs or 28
	for i = 0, segs - 1 do
		local a0, a1 = i / segs * 2 * math.pi, (i + 1) / segs * 2 * math.pi
		local p0 = CF.point(frame, radius * math.cos(a0), 0, radius * math.sin(a0))
		local p1 = CF.point(frame, radius * math.cos(a1), 0, radius * math.sin(a1))
		streak(out, p0, p1, thick, color, alpha, true)
	end
end
-- a crescent (sword-slash arc) in `frame`'s XY plane: a flat ribbon, wide in the middle and
-- pointed at both ends
local function crescent(out, frame, radius, a0, a1, thick, color, alpha, segs)
	segs = segs or 36
	for i = 0, segs - 1 do
		local u0, u1 = i / segs, (i + 1) / segs
		local b0, b1 = lerp(a0, a1, u0), lerp(a0, a1, u1)
		local bm = (b0 + b1) / 2
		local w = thick * math.sin(math.pi * (u0 + u1) / 2) ^ 0.8
		if w > 0.02 then
			local len = radius * math.abs(b1 - b0) * 1.12
			-- X along the arc, Y pointing out from the centre, Z the plane normal
			local tang = CF.vector(frame, -math.sin(bm), math.cos(bm), 0)
			local radial = CF.vector(frame, math.cos(bm), math.sin(bm), 0)
			local normal = CF.vector(frame, 0, 0, 1)
			for layer = 1, 2 do
				local r = radius + (if layer == 1 then 0 else w * 0.15)
				local p = CF.point(frame, r * math.cos(bm), r * math.sin(bm), 0)
				local ww = if layer == 1 then w else w * 0.35
				local cf = { p[1], p[2], p[3], tang[1], radial[1], normal[1], tang[2], radial[2], normal[2], tang[3], radial[3], normal[3] }
				table.insert(out, P("block", cf, { len, ww, 0.05 }, if layer == 1 then color else WHITE, { alpha = alpha, neon = true }))
			end
		end
	end
end
-- jagged lightning between two points
local function bolt(out, p0, p1, seed, color, alpha)
	local prev = p0
	local n = 7
	for i = 1, n do
		local k = i / n
		local p = CF.lerpv(p0, p1, k)
		if i < n then
			local j = 0.7 * math.sin(math.pi * k)
			p = CF.add(p, { (CF.hash(seed + i) - 0.5) * j * 2, (CF.hash(seed + i + 40) - 0.5) * j * 2, (CF.hash(seed + i + 80) - 0.5) * j * 2 })
		end
		streak(out, prev, p, 0.09, color, alpha, true)
		streak(out, prev, p, 0.04, WHITE, alpha, true)
		prev = p
	end
end
local function rock(out, pos, size, rot, alpha)
	table.insert(out, P("block", CF.mul(CF.new(pos[1], pos[2], pos[3]), CF.angles(rot[1], rot[2], rot[3])), { size, size * 0.8, size * 0.9 }, ROCK, { alpha = alpha or 0 }))
end
-- a four-point star (blade glint)
local function star(out, pos, s, color, alpha)
	streak(out, CF.add(pos, { -s, 0, 0 }), CF.add(pos, { s, 0, 0 }), s * 0.12, color, alpha, true)
	streak(out, CF.add(pos, { 0, -s, 0 }), CF.add(pos, { 0, s, 0 }), s * 0.12, color, alpha, true)
	streak(out, CF.add(pos, { 0, 0, -s }), CF.add(pos, { 0, 0, s }), s * 0.12, color, alpha, true)
	ball(out, pos, s * 0.18, WHITE, alpha, true)
end

local function swordTip(world)
	local grip = CF.mul(world.RightHand, Props.GRIP)
	return CF.point(grip, 0, 4.4, 0), CF.point(grip, 0, 1.2, 0)
end

---------------------------------------------------------------------------
-- Cherry blossom petals: one deterministic drifting field
---------------------------------------------------------------------------
local PETALS = 150
local function petals(out, t, density, burst)
	local wind = { 3.2, -1.1, -2.2 }
	for i = 1, math.floor(PETALS * density) do
		local h1, h2, h3, h4 = CF.hash(i), CF.hash(i + 300), CF.hash(i + 600), CF.hash(i + 900)
		local bx, by, bz = -24 + 48 * h1, 0.5 + 13 * h2, -16 + 32 * h3
		local x = bx + wind[1] * t * (0.7 + 0.6 * h4)
		local y = by + wind[2] * t * (0.6 + 0.8 * h1) + math.sin(t * 2 + i) * 0.5
		local z = bz + wind[3] * t * (0.7 + 0.6 * h2)
		-- wrap inside the box
		x = (x + 24) % 48 - 24
		y = (y - 0.3) % 13.5 + 0.3
		z = (z + 16) % 32 - 16
		if burst and burst > 0 then
			-- blown outward from the rival at the end
			local dx, dz = x - 4.6, z
			local d = math.max(1, math.sqrt(dx * dx + dz * dz))
			x += dx / d * burst * 6 * h3
			y += burst * 2.5 * h1
			z += dz / d * burst * 6 * h3
		end
		local spin = t * (3 + 4 * h3) + i
		table.insert(out, P("block", CF.mul(CF.new(x, y, z), CF.angles(spin, spin * 0.7, spin * 1.3)), { 0.32, 0.05, 0.22 }, if i % 3 == 0 then PETAL2 else PETAL, { neon = false }))
	end
end

---------------------------------------------------------------------------
-- Cameras: shot list
---------------------------------------------------------------------------
-- each returns pos, target, fov, roll(deg)
local SHOTS = {
	{ -- 1. face-off over the hero's shoulder, the rival small in the distance under the torii
		t0 = 0,
		t1 = 1.8,
		cam = function(t, k)
			local e = smooth(k)
			return { -18.5 + 2.5 * e, 4.8 - 0.3 * e, 4.3 - 0.4 * e }, { 9, 3.2, 0.2 }, 32 - 3 * e, 0
		end,
	},
	{ -- 2. close-up of the hero's face
		t0 = 1.8,
		t1 = 2.75,
		cam = function(t, k, W)
			local head = CF.pos(W("hero", "Head"))
			local e = smooth(k)
			return CF.add(head, { 6.4 - 0.8 * e, 0.2, 2.1 - 0.3 * e }), CF.add(head, { 0, -0.35, 0 }), 34 - 4 * e, 0
		end,
	},
	{ -- 3. the hand on the hilt: the draw
		t0 = 2.75,
		t1 = 3.3,
		cam = function(t, k, W)
			-- from the hero's front-left, low, on the hilt at the sheath mouth
			local mouth = CF.pos(CF.mul(W("hero", "LowerTorso"), Props.SHEATH))
			local e = smooth(k)
			return CF.add(mouth, { 6.4 - 0.8 * e, 0.9, -4.6 }), CF.add(mouth, { 0, 1.0 + 0.6 * clamp01((t - 3.05) / 0.2), 0 }), 34, 6
		end,
	},
	{ -- 4a. the hero charges straight at the camera
		t0 = 3.3,
		t1 = 3.8,
		cam = function(t, k, W)
			local hip = CF.pos(W("hero", "LowerTorso"))
			return CF.add(hip, { 9.5 - 1.5 * k, -0.6, 2.0 }), CF.add(hip, { 0, 0.9, 0 }), 44, 6
		end,
	},
	{ -- 4b. high angle, rolled: they rush at each other top and bottom of the frame
		t0 = 3.8,
		t1 = 4.3,
		cam = function(t, k)
			return { 0, 13.5 - 2 * k, 1.8 }, { 0, 2, 0 }, 52, 90
		end,
	},
	{ -- 5. CLASH: tight on the crossed blades
		t0 = 4.3,
		t1 = 4.62,
		cam = function(t, k)
			return { 0.6, 4.9, 8.2 }, { 0, 4.5, 0 }, 40, -10
		end,
	},
	{ -- 6a. slow orbit round the locked blades
		t0 = 4.62,
		t1 = 6.0,
		cam = function(t, k)
			local e = smooth(k)
			local a = rad(70 + 120 * e)
			local r = 15 - 2 * e
			return { math.cos(a) * r, 4.6 + 2.2 * e, math.sin(a) * r }, { 0, 4.0, 0 }, 32, lerp(-6, 6, e)
		end,
	},
	{ -- 6b. blasted apart: low and wide
		t0 = 6.0,
		t1 = 6.34,
		cam = function(t, k)
			return { -15 - 1.5 * k, 1.8, 2.6 }, { 3, 3.4, 0 }, 40, 4
		end,
	},
	{ -- 6c. worm's-eye: the rival leaps down on the hero
		t0 = 6.34,
		t1 = 7.2,
		cam = function(t, k)
			return { -8.4, 0.9, 5.4 }, { -2.2, 6.2, 0 }, 56, 8
		end,
	},
	{ -- 7. the power-up: crane up in front of the hero
		t0 = 7.2,
		t1 = 8.5,
		cam = function(t, k, W)
			local chest = CF.pos(W("hero", "UpperTorso"))
			local e = smooth(k)
			return CF.add(chest, { 10.5 + 1.0 * e, -2.4 + 6.5 * e, 2.6 + 0.6 * e }), CF.add(chest, { 0, 0.2 * e, 0 }), 46 - 8 * e, 0
		end,
	},
	{ -- 8a. eyes, a beat before the cut
		t0 = 8.5,
		t1 = 8.62,
		cam = function(t, k, W)
			local head = CF.pos(W("hero", "Head"))
			return CF.add(head, { 5.6, 0.1, 1.4 }), CF.add(head, { 0, -0.1, 0 }), 26, 0
		end,
	},
	{ -- 8b. the flash cut: wide along the path
		t0 = 8.62,
		t1 = 9.15,
		cam = function(t, k)
			return { 17 - 1.2 * k, 3.1, 7.4 }, { 3.2, 3.6, 0 }, 44, -8
		end,
	},
	{ -- 9. back to back: the hero in front, the rival falls behind
		t0 = 9.15,
		t1 = 10.01,
		cam = function(t, k)
			local e = smooth(k)
			return { 16.0 - 1.4 * e, 3.0, 7.2 - 0.6 * e }, { 6.2, 3.0, 0.2 }, 36 - 3 * e, 0
		end,
	},
}
T.SHOTS = SHOTS

---------------------------------------------------------------------------
-- Sample
---------------------------------------------------------------------------
-- `resolve(actor, part)` -> world CF of a body part; the game passes one built from the real
-- avatars so close-ups aim at the real heads and hands. Defaults to the stand-in body.
function T.Sample(t: number, resolve: any?)
	local cache = {}
	local function W(actor: string, part: string)
		if resolve then
			local c = resolve(actor, part)
			if c then
				return c
			end
		end
		if not cache[actor] then
			cache[actor] = T.ProxyWorld(actor, t)
		end
		return cache[actor][part]
	end
	local prims = {}
	local post = {
		flash = 0,
		flashColor = WHITE,
		impact = 0,
		speed = 0,
		tint = { 1, 0.94, 0.86 },
		saturation = 0.15,
		contrast = 0.12,
		brightness = 0,
		vignette = 0.35,
		fade = 0,
		glint = nil,
		texts = {},
		shake = 0,
		bloom = 0.6,
		blur = 0,
	}
	local ghosts = {}

	-- shot + camera
	local shot = SHOTS[#SHOTS]
	local shotIndex = #SHOTS
	for i, s in SHOTS do
		if t >= s.t0 and t < s.t1 then
			shot, shotIndex = s, i
			break
		end
	end
	local k = clamp01((t - shot.t0) / (shot.t1 - shot.t0))
	local pos, target, fov, roll = shot.cam(t, k, W)

	local function pulse(a, b)
		return if t >= a and t < b then 1 - (t - a) / (b - a) else 0
	end
	local function window(a, b)
		return t >= a and t < b
	end

	-------------------------------------------------- effects by beat
	-- petals everywhere (slowed during the orbit), burst at the end
	local petalTime = t
	if t > 4.62 and t < 6.0 then
		petalTime = 4.62 + (t - 4.62) * 0.25
	elseif t >= 6.0 then
		petalTime = 4.62 + 1.38 * 0.25 + (t - 6.0)
	end
	petals(prims, petalTime, if t > 9.5 then 1 else 0.8, if t > 9.58 then easeOut((t - 9.58) / 0.42, 2) else 0)

	-- 1: wind streaks across the field
	if t < 1.8 then
		for i = 1, 10 do
			local h = CF.hash(i * 7.7)
			local u = ((t * (0.7 + h) + h * 3) % 1.4) / 1.4
			local x = -24 + 48 * u
			local y, z = 1 + 9 * CF.hash(i * 3.1), -10 + 20 * CF.hash(i * 5.3)
			streak(prims, { x, y, z }, { x + 3.5, y - 0.4, z - 1.4 }, 0.04, WHITE, 0.55 + 0.4 * math.abs(math.sin(u * math.pi * 2)), true)
		end
	end

	-- 2: the light glint across the eyes
	if window(2.15, 2.6) then
		post.glint = { y = 0.47, k = math.sin(math.pi * (t - 2.15) / 0.45) }
	end

	-- 3: the draw: a star glint off the blade + a little flash
	if window(3.06, 3.3) then
		local hw = W("hero", "RightHand")
		local grip = CF.mul(hw, Props.GRIP)
		local g = 1 - (t - 3.06) / 0.24
		star(prims, CF.point(grip, 0, 2.2, 0), 0.6 + 0.8 * g, WHITE, 1 - g)
		post.flash = math.max(post.flash, 0.35 * pulse(3.06, 3.16))
	end

	-- 4: the dash: speed lines, afterimages, dust kicked up
	if window(3.3, 4.3) then
		post.speed = 0.6 + 0.4 * ((t - 3.3) / 1.0)
		post.shake = 0.03
		for _, name in { "hero", "rival" } do
			for g = 1, 3 do
				table.insert(ghosts, { actor = name, t = t - g * 0.045, alpha = 0.45 + 0.17 * g, color = if name == "hero" then CYAN else RED })
			end
		end
		for i = 0, 9 do
			local tt = 3.3 + i * 0.1
			if t >= tt and t < tt + 0.5 then
				local age = (t - tt) / 0.5
				for _, name in { "hero", "rival" } do
					local s = T.ActorState(name, tt)
					local r = 0.5 + 1.1 * easeOut(age, 2)
					ball(prims, { s.x, 0.4 + 0.5 * age, 0.6 * (CF.hash(i + #name) - 0.5) }, r, DUST, 0.35 + 0.65 * age, false)
				end
			end
		end
	end

	-- 5: CLASH — impact frames, shockwaves, sparks, flying rocks
	local CLASH = { 0, 4.55, 0 }
	if window(4.3, 4.37) then
		post.impact = 1 -- black world, white silhouettes
	elseif window(4.37, 4.42) then
		post.impact = 2 -- white world, black silhouettes
	end
	if window(4.42, 5.3) then
		local a = (t - 4.42) / 0.88
		ring(prims, CF.mul(CF.new(CLASH[1], CLASH[2], CLASH[3]), CF.angles(0, 0, math.pi / 2)), 0.6 + 9 * easeOut(a, 2.5), 0.18 * (1 - a) + 0.04, WHITE, a, 40)
		ring(prims, CF.new(0, 0.15, 0), 0.8 + 11 * easeOut(a, 2), 0.3 * (1 - a) + 0.05, SPARK, 0.2 + 0.8 * a, 44)
		post.shake = math.max(post.shake, 0.55 * (1 - a) ^ 2)
		post.flash = math.max(post.flash, 0.5 * pulse(4.42, 4.55))
		for i = 1, 36 do
			local h1, h2, h3 = CF.hash(i * 1.37), CF.hash(i * 2.11), CF.hash(i * 3.73)
			local dir = CF.unit({ (h1 - 0.5) * 0.8, h2 - 0.25, (h3 - 0.5) * 2 })
			local d = (5 + 10 * h1) * easeOut(a, 2)
			local p0 = CF.add(CLASH, CF.scale(dir, d))
			local p1 = CF.add(CLASH, CF.scale(dir, d + 1.2 * (1 - a) + 0.2))
			streak(prims, p0, p1, 0.07, SPARK, a ^ 1.5, true)
		end
		for i = 1, 16 do
			local h1, h2, h3 = CF.hash(i * 9.1), CF.hash(i * 4.3), CF.hash(i * 6.7)
			local ang = h1 * 2 * math.pi
			local tt = t - 4.42
			local p = { math.cos(ang) * (1.5 + 7 * tt), 0.3 + (5 + 6 * h2) * tt - 13 * tt * tt, math.sin(ang) * (1.5 + 7 * tt) }
			if p[2] > 0 then
				rock(prims, p, 0.25 + 0.4 * h3, { tt * 9 * h1, tt * 7, tt * 5 * h2 }, 0)
			end
		end
		fov += 7 * (1 - easeOut(a * 3, 2))
	end
	-- 6a: sparks streaming off the locked blades, slow-motion
	if window(4.62, 6.0) then
		for i = 1, 22 do
			local h1, h2, h3 = CF.hash(i * 5.5), CF.hash(i * 8.2), CF.hash(i * 2.9)
			local life = 0.5 + 0.4 * h1
			local age = ((t - 4.62) * 0.6 + h2 * life) % life / life
			local dir = CF.unit({ (h3 - 0.5) * 0.6, 0.6 + h1, (h2 - 0.5) * 2 })
			local p0 = CF.add(CLASH, CF.scale(dir, 0.3 + 3.5 * age))
			local p1 = CF.add(p0, CF.scale(dir, 0.5))
			p0[2] -= 2.5 * age * age
			p1[2] -= 2.5 * age * age
			streak(prims, p0, p1, 0.05, SPARK, age ^ 2, true)
		end
		ball(prims, CLASH, 0.35 + 0.08 * math.sin(t * 30), WHITE, 0.15, true)
		ball(prims, CLASH, 0.8 + 0.1 * math.sin(t * 17), SPARK, 0.65, true)
		post.saturation = 0.05
		post.contrast = 0.22
	end
	-- 6b: the burst apart: wind ring + dust trails
	if window(6.0, 6.5) then
		local a = (t - 6.0) / 0.5
		ring(prims, CF.new(0, 0.2, 0), 1 + 8 * easeOut(a, 2), 0.25 * (1 - a) + 0.04, WHITE, 0.3 + 0.7 * a, 40)
		post.shake = math.max(post.shake, 0.3 * (1 - a))
		for _, name in { "hero", "rival" } do
			local s = T.ActorState(name, t)
			for j = 0, 4 do
				ball(prims, { s.x * (1 - j * 0.12), 0.3, (j - 2) * 0.3 }, 0.4 + 0.5 * a, DUST, 0.45 + 0.5 * a, false)
			end
		end
	end
	-- 6c: the rival's red cut, sparks on the block
	if window(6.66, 7.0) then
		local a = (t - 6.66) / 0.34
		local frame = CF.mul(CF.new(-3.0, 4.8, 0), CF.angles(0, 0, 0))
		crescent(prims, frame, 3.2, rad(150) - rad(140) * easeOut(a * 1.6, 2), rad(150), 0.6 * (1 - a), RED, a ^ 0.7, 22)
	end
	if window(6.82, 7.2) then
		local a = (t - 6.82) / 0.38
		local hit = CF.pos(CF.mul(W("hero", "RightHand"), CF.mul(Props.GRIP, CF.new(0, 1.8, 0))))
		for i = 1, 20 do
			local h1, h2 = CF.hash(i * 3.3), CF.hash(i * 7.9)
			local dir = CF.unit({ (h1 - 0.5) * 2, h2 * 0.8 + 0.1, (CF.hash(i) - 0.5) * 2 })
			streak(prims, CF.add(hit, CF.scale(dir, 4 * easeOut(a, 2))), CF.add(hit, CF.scale(dir, 4 * easeOut(a, 2) + 0.7)), 0.06, SPARK, a, true)
		end
		post.flash = math.max(post.flash, 0.4 * pulse(6.82, 6.92))
		post.shake = math.max(post.shake, 0.35 * (1 - a))
	end

	-- 7: power-up: blue aura flames, lightning, cracks of light, rising stones
	if window(7.3, 8.62) then
		local p = clamp01((t - 7.3) / 0.8)
		local hw = W("hero", "LowerTorso")
		local c = CF.pos(hw)
		local feet = { c[1], 0.05, c[3] }
		post.tint = { 0.86, 0.95, 1.12 }
		post.saturation = 0.3
		post.vignette = 0.55
		post.bloom = 1.1
		-- flames: tongues rising round the body
		for i = 1, 48 do
			local h1, h2, h3 = CF.hash(i * 4.1), CF.hash(i * 6.3), CF.hash(i * 9.7)
			local life = 0.45 + 0.35 * h1
			local age = ((t + h2 * life) % life) / life
			local ang = h3 * 2 * math.pi
			local r = (1.2 + 0.6 * h2) * (1 - 0.5 * age)
			local base = { feet[1] + math.cos(ang) * r, 0.2 + age * (5.5 + 1.5 * h1), feet[3] + math.sin(ang) * r }
			local size = (0.45 + 0.35 * h1) * (1 - age) * p
			if size > 0.05 then
				table.insert(prims, P("block", CF.mul(CF.new(base[1], base[2], base[3]), CF.angles(0, ang, rad(45))), { size * 0.32, size * 2.6, size * 0.32 }, if i % 3 == 0 then WHITE else (if i % 2 == 0 then CYAN else DEEPBLUE), { alpha = 0.15 + 0.6 * age, neon = true }))
			end
		end
		-- the glowing ground cracks
		for i = 1, 9 do
			local ang = i / 9 * 2 * math.pi + 0.3
			local len = (3 + 3 * CF.hash(i * 2.2)) * easeOut(p, 2)
			local mid = { feet[1] + math.cos(ang) * len * 0.5, 0.06, feet[3] + math.sin(ang) * len * 0.5 }
			table.insert(prims, P("block", CF.mul(CF.new(mid[1], mid[2], mid[3]), CF.angles(0, -ang, 0)), { len, 0.06, 0.12 }, CYAN, { neon = true, alpha = 0.1 }))
		end
		-- floating stones
		for i = 1, 12 do
			local h1, h2, h3 = CF.hash(i * 2.9), CF.hash(i * 5.1), CF.hash(i * 7.4)
			local ang = h1 * 2 * math.pi
			local r = 2.5 + 3 * h2
			local y = 0.2 + (1 + 3 * h3) * easeOut(p, 2) + math.sin(t * 3 + i) * 0.2
			rock(prims, { feet[1] + math.cos(ang) * r, y, feet[3] + math.sin(ang) * r }, 0.2 + 0.35 * h3, { t * h1, t * 0.7, t * h2 }, 0)
		end
		-- lightning crackling round the body
		local slot = math.floor(t / 0.07)
		for b = 1, 3 do
			local s1 = slot * 13 + b * 101
			if CF.hash(s1) < 0.7 * p then
				local a0 = CF.hash(s1 + 1) * 2 * math.pi
				local p0 = { feet[1] + math.cos(a0) * 1.6, 0.5 + 4.5 * CF.hash(s1 + 2), feet[3] + math.sin(a0) * 1.6 }
				local p1 = { feet[1] + math.cos(a0 + 1.4) * 2.2, 0.5 + 5 * CF.hash(s1 + 3), feet[3] + math.sin(a0 + 1.4) * 2.2 }
				bolt(prims, p0, p1, s1, CYAN, 0)
			end
		end
		-- energy motes rushing into the blade
		local tip = swordTip(T.ProxyWorld("hero", t))
		for i = 1, 14 do
			local h1, h2 = CF.hash(i * 3.7), CF.hash(i * 8.8)
			local age = ((t * 1.6 + h1) % 1)
			local from = { tip[1] + math.cos(h2 * 6.28) * 5, tip[2] + (h1 - 0.5) * 6, tip[3] + math.sin(h2 * 6.28) * 5 }
			local at = CF.lerpv(from, tip, easeIn(age, 2))
			ball(prims, at, 0.09, WHITE, 0.2, true)
		end
		post.shake = math.max(post.shake, 0.06 * p)
		if t > 7.7 then
			table.insert(post.texts, { text = "覚醒", size = 0.3, y = 0.2, alpha = 0.55 * clamp01((t - 7.7) / 0.3) * clamp01((8.6 - t) / 0.15), color = CYAN, font = "jp" })
		end
	end
	-- 8a: the eyes flash
	if window(8.5, 8.62) then
		post.glint = { y = 0.47, k = 1 - (t - 8.5) / 0.12 }
		post.tint = { 0.86, 0.95, 1.12 }
		post.saturation = -0.2
		post.contrast = 0.4
	end
	-- 8b: the flash cut: white-out, a giant crescent, the light trail along the path
	if window(8.62, 9.3) then
		local a = (t - 8.62) / 0.68
		post.flash = math.max(post.flash, 1 - easeOut(a * 5, 2))
		post.speed = 1 - a
		post.shake = math.max(post.shake, 0.45 * (1 - a) ^ 2)
		-- one long thin crescent cutting diagonally through the rival's chest
		local chest = CF.pos(W("rival", "UpperTorso"))
		local frame = CF.mul(CF.mul(CF.new(chest[1], chest[2], chest[3] + 1.7), CF.angles(0, 0, rad(-30))), CF.new(0, -8, 0))
		local grow = easeOut(a * 3, 2)
		crescent(prims, frame, 8, rad(90) - rad(40) * grow, rad(90) + rad(40) * grow, 1.2 * (1 - a * 0.7), CYAN, a ^ 1.3, 40)
		streak(prims, { -4.6, 3.6, 0 }, { 8.4, 3.6, 0 }, 0.18 * (1 - a) + 0.03, WHITE, a ^ 0.6, true)
		streak(prims, { -4.6, 3.6, 0 }, { 8.4, 3.6, 0 }, 0.45 * (1 - a) + 0.05, CYAN, 0.4 + 0.6 * a, true)

	end
	-- 9: the sheath click, the delayed cut on the rival, petals, title
	if window(9.55, 9.75) then
		local ht = W("hero", "LowerTorso")
		local mouth = CF.pos(CF.mul(ht, Props.SHEATH))
		star(prims, mouth, 0.5 + 0.6 * (1 - (t - 9.55) / 0.2), WHITE, (t - 9.55) / 0.2)
	end
	if window(9.58, 9.9) then
		local a = (t - 9.58) / 0.32
		local c = CF.pos(W("rival", "UpperTorso"))
		streak(prims, CF.add(c, { 0.3, 1.6, -1.6 }), CF.add(c, { -0.3, -1.6, 1.6 }), 0.14 * (1 - a) + 0.02, WHITE, a ^ 0.5, true)
		post.flash = math.max(post.flash, 0.25 * pulse(9.58, 9.66))
		post.shake = math.max(post.shake, 0.15 * (1 - a))
	end
	if t > 9.3 then
		local a = clamp01((t - 9.3) / 0.35)
		table.insert(post.texts, { text = "CANDYOUSEE", size = 0.048, y = 0.84, alpha = a, color = WHITE, font = "title", spacing = 0.2 })
		table.insert(post.texts, { text = "一閃", size = 0.16, y = 0.12, alpha = a * 0.9, color = WHITE, font = "jp" })
	end
	post.fade = clamp01((t - 9.82) / 0.18)

	-- camera shake + build the camera
	if post.shake > 0 then
		local s = post.shake
		pos = CF.add(pos, { CF.noise(t * 31, 3) * s, CF.noise(t * 29, 5) * s, CF.noise(t * 27, 7) * s * 0.5 })
		roll += CF.noise(t * 23, 9) * s * 6
	end
	local camCF = CF.lookAt(pos, target, rad(roll))

	-- fighters
	local actors = {}
	for name in T.TRACKS do
		local s = T.ActorState(name, t)
		s.style = T.STYLE[name]
		actors[name] = s
	end

	return { t = t, shot = shotIndex, camera = { cf = camCF, fov = fov }, actors = actors, prims = prims, ghosts = ghosts, post = post }
end

-- stand-in body prims for a fighter (preview, ghosts, and the in-game fallback)
function T.BodyPrims(name: string, s: any, color: { number }?, alpha: number?, neon: boolean?): { any }
	local out = {}
	local root = T.RootFor(Rig.PROXY, s, PROXY_STAND)
	local world = Rig.FK(Rig.PROXY, root, s.pose)
	local colors = Props.BodyColors(T.STYLE[name])
	for part, cf in world do
		if part ~= "HumanoidRootPart" then
			table.insert(out, P("block", cf, Rig.PROXY.sizes[part], color or colors[part], { alpha = alpha or 0, neon = neon == true, tag = "body" }))
		end
	end
	if not color then
		for _, p in Props.HeadDetail(T.STYLE[name]) do
			local q = table.clone(p)
			q.cf = CF.mul(world.Head, p.cf)
			q.tag = "body"
			table.insert(out, q)
		end
	end
	return out, world
end

-- an afterimage: the fighter's silhouette at an earlier moment (or a set pose / place)
function T.GhostPrims(g: any): { any }
	local s = T.ActorState(g.actor, g.t)
	if g.pose then
		s.pose = Poses.Blend(Poses[g.pose], Poses[g.pose], 0)
	end
	if g.xOverride then
		s.x = g.xOverride
	end
	local body = T.BodyPrims(g.actor, s, g.color, g.alpha, true)
	return body
end

-- the katana (+ hero's sheath) placed for a fighter, given its world parts
function T.GearPrims(name: string, s: any, world: { [string]: { number } }): { any }
	local out = {}
	local swordCF
	if s.sword == "sheath" then
		swordCF = CF.mul(world.LowerTorso, Props.SHEATHED)
	else
		swordCF = CF.mul(world.RightHand, Props.GRIP)
	end
	for _, p in Props.Katana(T.STYLE[name]) do
		local q = table.clone(p)
		q.cf = CF.mul(swordCF, p.cf)
		if p.tag == "blade" and (s.glow or 0) > 0.05 then
			q.color = { lerp(p.color[1], CYAN[1], s.glow), lerp(p.color[2], CYAN[2], s.glow), lerp(p.color[3], CYAN[3], s.glow) }
			q.neon = s.glow > 0.4
		end
		table.insert(out, q)
	end
	if name == "hero" then
		for _, p in Props.Sheath() do
			local q = table.clone(p)
			q.cf = CF.mul(CF.mul(world.LowerTorso, Props.SHEATH), p.cf)
			table.insert(out, q)
		end
	end
	return out
end

return T
