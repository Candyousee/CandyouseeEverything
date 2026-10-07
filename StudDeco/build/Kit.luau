--!strict
-- Stud Deco kit: tiny helpers that turn shapes into part lists.
-- Every item is a list of parts { name, shape, size, cf, color, studs, neon } plus point lights.
-- Shapes: "block" (Part), "ball" (SpecialMesh Sphere: an ellipsoid filling its box),
-- "cyl" (Part, Shape = Cylinder, axis along X), "wedge" (WedgePart).
-- Units are studs. Y is up, the item faces -Z (towards the camera), its base sits on Y = 0.

local roblox = require("@lune/roblox")
local CFrame, Vector3 = roblox.CFrame, roblox.Vector3

local Kit = {}

Kit.C = {
	orange = { 232, 116, 30 }, orangeDark = { 180, 80, 26 }, orangeLight = { 246, 150, 60 },
	purple = { 106, 63, 160 }, purpleDeep = { 59, 37, 96 }, toxic = { 123, 224, 74 },
	bone = { 239, 227, 200 }, boneDark = { 200, 186, 156 }, stone = { 110, 106, 120 }, stoneDark = { 62, 58, 70 },
	wood = { 107, 68, 38 }, woodDark = { 63, 40, 22 }, black = { 30, 26, 36 }, gold = { 232, 184, 74 },
	moss = { 94, 138, 58 }, mossDark = { 64, 100, 40 }, stem = { 86, 120, 48 }, wax = { 240, 232, 210 },
	glowOrange = { 255, 150, 40 }, glowYellow = { 255, 214, 110 }, glowPurple = { 190, 120, 255 }, glowGreen = { 140, 255, 90 },
	dirt = { 92, 62, 40 },
}

export type Part = { name: string, shape: string, size: { number }, cf: any, color: { number }, studs: boolean?, neon: boolean? }
export type Light = { pos: { number }, color: { number }, range: number, brightness: number }
export type Item = { name: string, category: string, parts: { Part }, lights: { Light } }

function Kit.new(name: string, category: string)
	local self = { name = name, category = category, parts = {} :: { Part }, lights = {} :: { Light }, n = 0 }

	local function add(shape: string, partName: string?, size: { number }, cf: any, color: { number }, opts: { studs: boolean?, neon: boolean? }?)
		self.n += 1
		table.insert(self.parts, {
			name = partName or (shape .. self.n),
			shape = shape,
			size = size,
			cf = cf,
			color = color,
			studs = opts and opts.studs or false,
			neon = opts and opts.neon or false,
		})
	end

	-- a block; studs = true puts Roblox's built-in Studs surface on top
	function self.block(name: string?, size, cf, color, opts) add("block", name, size, cf, color, opts) end
	function self.ball(name: string?, size, cf, color, opts) add("ball", name, size, cf, color, opts) end
	function self.wedge(name: string?, size, cf, color, opts) add("wedge", name, size, cf, color, opts) end
	-- a vertical cylinder of diameter d and height h, standing on its centre point
	function self.vcyl(name: string?, d: number, h: number, cf, color, opts)
		add("cyl", name, { h, d, d }, cf * CFrame.Angles(0, 0, math.rad(90)), color, opts)
	end
	-- a cylinder lying along the item's X axis
	function self.hcyl(name: string?, d: number, len: number, cf, color, opts)
		add("cyl", name, { len, d, d }, cf, color, opts)
	end
	function self.light(pos: { number }, color: { number }, range: number, brightness: number?)
		table.insert(self.lights, { pos = pos, color = color, range = range, brightness = brightness or 1.5 })
	end
	return self
end

local CF, A = CFrame.new, CFrame.Angles
Kit.CF, Kit.A = CF, A

-- A ribbed pumpkin: a core plus `lobes` ellipsoid lobes around it, a stem, and a few stud bumps.
-- `at` is the CFrame of the pumpkin's bottom centre. Returns its height.
function Kit.pumpkin(it, at, w: number, h: number, color, opts: { lobes: number?, stem: boolean?, bumps: boolean?, darkTone: { number }? }?)
	local lobes = opts and opts.lobes or 8
	local dark = opts and opts.darkTone or Kit.C.orangeDark
	local mid = at * CF(0, h / 2, 0)
	it.ball("Core", { w * 0.82, h * 0.96, w * 0.82 }, mid, dark)
	for i = 0, lobes - 1 do
		local a = (i + 0.5) / lobes * math.pi * 2
		local lobeCF = mid * A(0, a, 0) * CF(0, 0, -w * 0.2)
		it.ball("Lobe", { w * 0.42, h, w * 0.62 }, lobeCF, if i % 2 == 0 then color else Kit.C.orangeLight)
	end
	if not opts or opts.stem ~= false then
		it.vcyl("Stem", w * 0.16, h * 0.28, at * CF(0, h * 1.0, 0) * A(0, 0, math.rad(12)), Kit.C.stem)
		it.vcyl("StemTip", w * 0.13, h * 0.12, at * CF(w * 0.06, h * 1.14, 0) * A(0, 0, math.rad(40)), Kit.C.stem)
	end
	if opts and opts.bumps then
		-- little stud bumps on the sides and back (never on the face)
		for i, q in { { 1.3, 0.45 }, { -1.25, -0.2 }, { 2.4, 0.1 }, { -2.3, 0.5 }, { 3.1, -0.35 } } do
			local u, v = q[1], q[2]
			local a, b, c = 0.5 * w, 0.5 * h, 0.48 * w
			local phi = math.asin(v * 0.9)
			local p = Vector3.new(a * math.cos(phi) * math.sin(u), b * math.sin(phi), -c * math.cos(phi) * math.cos(u))
			local bumpCF = at * CF(0, h / 2, 0) * CF(p)
			it.ball("Bump" .. i, { w * 0.1, w * 0.1, w * 0.1 }, bumpCF, color)
		end
	end
	return h
end

-- A frame sitting on the surface of the pumpkin ellipsoid (semi-axes 0.5w, 0.5h, 0.48w around its centre),
-- with its -Z (front) pointing outwards. x, y = offsets from the front centre, in studs.
-- `inset` = how far behind the surface the part's centre sits (half its depth minus how proud it stands).
function Kit.onPumpkin(at, w: number, h: number, x: number, y: number, inset: number)
	local a, b, c = 0.5 * w, 0.5 * h, 0.48 * w
	local u = math.asin(math.clamp(x / a, -0.95, 0.95))
	local phi = math.asin(math.clamp(y / b, -0.95, 0.95))
	local px, py, pz = a * math.cos(phi) * math.sin(u), b * math.sin(phi), -c * math.cos(phi) * math.cos(u)
	-- ellipsoid normal: (px/a^2, py/b^2, pz/c^2)
	local n = Vector3.new(px / (a * a), py / (b * b), pz / (c * c)).Unit
	local centre = at * CF(0, h / 2, 0)
	local p = centre * Vector3.new(px, py, pz)
	local nw = centre:VectorToWorldSpace(n)
	return CFrame.lookAt(p, p + nw) * CF(0, 0, inset)
end

-- An isosceles triangle facing -Z, made of two mirrored wedges. pointDown flips it.
function Kit.tri(it, name: string, at, width: number, height: number, depth: number, color, opts, pointDown: boolean?)
	local flip = if pointDown then A(0, 0, math.rad(180)) else CF()
	local half = math.max(0.12, width / 2)
	it.wedge(name .. "L", { depth, height, half }, at * flip * CF(-half / 2, 0, 0) * A(0, math.rad(90), 0), color, opts)
	it.wedge(name .. "R", { depth, height, half }, at * flip * CF(half / 2, 0, 0) * A(0, math.rad(-90), 0), color, opts)
end

-- A glowing jack-o'-lantern face set into the front of a pumpkin of width w, height h.
-- style: "grin" (triangle eyes, toothy grin) | "wicked" (slanted eyes, fangs) | "happy" (round eyes, smile)
function Kit.face(it, at, w: number, h: number, glow, style: string?)
	style = style or "grin"
	local s = w / 3 -- designed on a 3-stud-wide pumpkin
	local depth = 0.4
	local neon = { neon = true }
	-- each feature's centre sits (depth/2 - 0.05) behind the surface, so it stands 0.05 proud
	local function F(x, y) return Kit.onPumpkin(at, w, h, x * s, y * s, depth / 2 - 0.05) end
	if style == "happy" then
		it.ball("EyeL", { 0.42 * s, 0.5 * s, depth }, F(-0.46, 0.3), glow, neon)
		it.ball("EyeR", { 0.42 * s, 0.5 * s, depth }, F(0.46, 0.3), glow, neon)
	elseif style == "wicked" then
		it.wedge("EyeL", { depth, 0.4 * s, 0.62 * s }, F(-0.48, 0.3) * A(0, math.rad(-90), 0), glow, neon)
		it.wedge("EyeR", { depth, 0.4 * s, 0.62 * s }, F(0.48, 0.3) * A(0, math.rad(90), 0), glow, neon)
	else
		Kit.tri(it, "EyeL", F(-0.46, 0.34), 0.56 * s, 0.48 * s, depth, glow, neon)
		Kit.tri(it, "EyeR", F(0.46, 0.34), 0.56 * s, 0.48 * s, depth, glow, neon)
	end
	Kit.tri(it, "Nose", F(0, 0.02), 0.34 * s, 0.26 * s, depth, glow, neon)
	-- the mouth: a wide smile (centre bar + two raised corners); teeth stay in the pumpkin's colour
	it.block("Mouth", { 1.0 * s, 0.28 * s, depth }, F(0, -0.36), glow, neon)
	it.block("MouthL", { 0.44 * s, 0.24 * s, depth }, F(-0.66, -0.25) * A(0, 0, math.rad(30)), glow, neon)
	it.block("MouthR", { 0.44 * s, 0.24 * s, depth }, F(0.66, -0.25) * A(0, 0, math.rad(-30)), glow, neon)
	local tooth = Kit.C.orange
	local tSize = { math.max(0.14, 0.17 * s), math.max(0.12, 0.13 * s), depth + 0.04 }
	if style == "wicked" then
		it.block("FangL", tSize, F(-0.25, -0.27), tooth)
		it.block("FangR", tSize, F(0.25, -0.27), tooth)
	elseif style == "grin" then
		it.block("ToothTop", tSize, F(-0.2, -0.27), tooth)
		it.block("ToothBottom", tSize, F(0.24, -0.45), tooth)
	end
end

-- A chunky round base (stone / dirt) with studs on top. Returns the top height.
function Kit.roundBase(it, at, d: number, h: number, color)
	it.vcyl("Base", d, h, at * CF(0, h / 2, 0), color)
	it.block("BaseTop", { d * 0.62, 0.2, d * 0.62 }, at * CF(0, h + 0.1, 0), color, { studs = true })
	return h
end

-- A chunky square base with studs. Returns the top height.
function Kit.slabBase(it, at, x: number, h: number, z: number, color)
	it.block("Base", { x, h, z }, at * CF(0, h / 2, 0), color, { studs = true })
	return h
end

-- A candle with a wax drip and a neon flame; returns the flame position (for a light).
function Kit.candle(it, at, d: number, h: number, wax, flame)
	it.vcyl("Candle", d, h, at * CF(0, h / 2, 0), wax)
	it.block("Drip", { math.max(0.15, d * 0.28), h * 0.35, math.max(0.12, d * 0.2) }, at * CF(d * 0.32, h * 0.78, -d * 0.4), wax)
	it.vcyl("Wick", 0.12, math.max(0.15, d * 0.25), at * CF(0, h + d * 0.1, 0), Kit.C.black)
	it.ball("Flame", { d * 0.42, d * 0.85, d * 0.42 }, at * CF(0, h + d * 0.5, 0), flame, { neon = true })
	it.ball("FlameCore", { math.max(0.12, d * 0.2), d * 0.4, math.max(0.12, d * 0.2) }, at * CF(0, h + d * 0.4, -d * 0.08), Kit.C.glowYellow, { neon = true })
	local p = (at * CF(0, h + d * 0.55, 0)).Position
	return { p.X, p.Y, p.Z }
end

-- A cartoon skull (cream): cranium, cheekbones, jaw, dark sockets. `at` = the skull's centre.
function Kit.skull(it, at, s: number, socket, eyeGlow: boolean?)
	it.ball("Cranium", { 1.2 * s, 1.05 * s, 1.1 * s }, at, Kit.C.bone)
	it.block("Cheeks", { 0.95 * s, 0.4 * s, 0.8 * s }, at * CF(0, -0.42 * s, -0.12 * s), Kit.C.bone)
	it.block("Jaw", { 0.7 * s, 0.25 * s, 0.6 * s }, at * CF(0, -0.68 * s, -0.16 * s), Kit.C.boneDark)
	for i, x in { -0.28, -0.09, 0.09, 0.28 } do
		it.block("Tooth" .. i, { 0.13 * s, 0.14 * s, 0.12 }, at * CF(x * s, -0.6 * s, -0.54 * s), Kit.C.bone)
	end
	local opts = if eyeGlow then { neon = true } else nil
	it.ball("SocketL", { 0.34 * s, 0.36 * s, 0.2 * s }, at * CF(-0.26 * s, -0.08 * s, -0.5 * s), socket, opts)
	it.ball("SocketR", { 0.34 * s, 0.36 * s, 0.2 * s }, at * CF(0.26 * s, -0.08 * s, -0.5 * s), socket, opts)
	it.wedge("NoseHole", { 0.14 * s, 0.16 * s, 0.1 * s }, at * CF(0, -0.32 * s, -0.55 * s), Kit.C.black)
end

return Kit
