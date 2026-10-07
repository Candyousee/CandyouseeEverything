--!strict
-- Stud Deco kit: BRICK-BUILT helpers (owner: "blocky, not smooth").
-- Everything is made of blocks (and the odd wedge), with Roblox's built-in Studs surface on every top face,
-- so items look like toy bricks. Round things are stepped layers; faces are pixel art in glowing blocks.
-- Units are studs. Y is up, the item faces -Z, its base sits on Y = 0.

local roblox = require("@lune/roblox")
local CFrame = roblox.CFrame

local Kit = {}

Kit.C = {
	orange = { 232, 116, 30 }, orangeDark = { 196, 90, 22 }, orangeLight = { 246, 146, 52 },
	purple = { 106, 63, 160 }, purpleDeep = { 59, 37, 96 }, toxic = { 123, 224, 74 },
	bone = { 239, 227, 200 }, boneDark = { 206, 192, 160 }, stone = { 120, 116, 130 }, stoneDark = { 72, 68, 80 },
	wood = { 107, 68, 38 }, woodDark = { 63, 40, 22 }, black = { 38, 34, 44 }, gold = { 232, 184, 74 },
	moss = { 104, 150, 62 }, mossDark = { 70, 108, 44 }, stem = { 86, 128, 48 }, wax = { 242, 234, 214 },
	glowOrange = { 255, 150, 40 }, glowYellow = { 255, 214, 110 }, glowPurple = { 190, 120, 255 }, glowGreen = { 140, 255, 90 },
	dirt = { 104, 70, 44 },
}

local CF, A = CFrame.new, CFrame.Angles
Kit.CF, Kit.A = CF, A

export type Part = { name: string, shape: string, size: { number }, cf: any, color: { number }, studs: boolean?, neon: boolean? }

function Kit.new(name: string, category: string)
	local self = { name = name, category = category, parts = {} :: { Part }, lights = {}, n = 0 }
	local function add(shape, partName, size, cf, color, opts)
		self.n += 1
		table.insert(self.parts, {
			name = partName or (shape .. self.n), shape = shape, size = size, cf = cf, color = color,
			-- studs on top by default: that's the look
			studs = if opts and opts.studs ~= nil then opts.studs else not (opts and opts.neon),
			neon = opts and opts.neon or false,
		})
	end
	function self.block(name, size, cf, color, opts) add("block", name, size, cf, color, opts) end
	function self.wedge(name, size, cf, color, opts) add("wedge", name, size, cf, color, opts) end
	function self.light(pos, color, range, brightness)
		table.insert(self.lights, { pos = pos, color = color, range = range, brightness = brightness or 1.5 })
	end
	return self
end

-- One stepped "round" layer: a plus-shaped octagon from 3 non-overlapping blocks (no z-fighting).
-- `d` = full width (studs), `h` = layer height, `at` = the layer's bottom centre.
function Kit.roundLayer(it, name: string, at, d: number, h: number, color, sideColor)
	local side = if d >= 3 then 1 else 0.5 -- whole studs so the studs line up
	local core = d - 2 * side
	it.block(name, { core, h, d }, at * CF(0, h / 2, 0), color)
	if side >= 0.25 then
		it.block(name .. "L", { side, h, core }, at * CF(-(core + side) / 2, h / 2, 0), sideColor or color)
		it.block(name .. "R", { side, h, core }, at * CF((core + side) / 2, h / 2, 0), sideColor or color)
	end
end

-- A brick-built pumpkin: stepped layers in whole-stud widths, darker side ribs, a block stem.
-- Returns its height and the layer table (for the face).
function Kit.pumpkin(it, at, w: number, opts: { lh: number?, stem: boolean?, layers: number? }?)
	local lh = opts and opts.lh or 0.8
	local widths = if opts and opts.layers == 3 then { w - 1, w, w - 1 } else { w - 1, w, w, w, w - 1 }
	local y = 0
	local layers = {}
	for i, d in widths do
		Kit.roundLayer(it, "Pumpkin" .. i, at * CF(0, y, 0), d, lh, Kit.C.orange, Kit.C.orangeDark)
		table.insert(layers, { y0 = y, y1 = y + lh, d = d })
		y += lh
	end
	if not opts or opts.stem ~= false then
		it.block("Stem", { 0.6, 0.7, 0.6 }, at * CF(0, y + 0.35, 0), Kit.C.stem)
		it.block("StemTip", { 0.6, 0.4, 0.4 }, at * CF(0.35, y + 0.75, 0), Kit.C.stem)
		it.block("Leaf", { 1.0, 0.2, 0.6 }, at * CF(-0.55, y + 0.1, 0.2), Kit.C.moss)
	end
	return y, layers
end

-- Pixel-art glowing face on the front of a stepped shape.
-- rows = strings top to bottom ("#" = glow, "." = empty); `cell` = pixel size; `cy` = face centre height;
-- `frontZ(y)` = the shape's front surface at height y (negative Z). Runs of "#" merge into one block.
function Kit.pixelFace(it, at, rows: { string }, cell: number, cy: number, frontZ: (number) -> number, glow)
	local n = #rows
	for r, row in rows do
		local y = cy + ((n + 1) / 2 - r) * cell
		local z = frontZ(y)
		local c = 1
		local len = #row
		while c <= len do
			if string.sub(row, c, c) == "#" then
				local s = c
				while c + 1 <= len and string.sub(row, c + 1, c + 1) == "#" do
					c += 1
				end
				local x = ((s + c) / 2 - (len + 1) / 2) * cell
				it.block("Face" .. r .. "_" .. s, { (c - s + 1) * cell, cell, 0.3 }, at * CF(x, y, z + 0.1), glow, { neon = true })
			end
			c += 1
		end
	end
end

Kit.FACES = {
	grin = { "##....##", "###..###", "...##...", "#......#", ".######.", "..#..#.." },
	wicked = { "#......#", "##....##", ".##..##.", "........", "#.####.#", ".#.##.#." },
	happy = { ".##..##.", ".##..##.", "........", "#......#", ".######." },
}

-- front surface of a stepped pumpkin, from its layers (the centre block reaches d/2)
function Kit.pumpkinFront(layers)
	return function(y: number)
		for _, l in layers do
			if y >= l.y0 - 1e-6 and y <= l.y1 + 1e-6 then
				return -l.d / 2
			end
		end
		return -layers[1].d / 2
	end
end

-- A pumpkin with a glowing pixel face; returns its height.
function Kit.jack(it, at, w: number, style: string, glow, opts)
	local h, layers = Kit.pumpkin(it, at, w, opts)
	local cell = (w - 2) / 8 -- the face fits the front (centre) block
	Kit.pixelFace(it, at, Kit.FACES[style], cell, h * 0.5, Kit.pumpkinFront(layers), glow)
	return h
end

-- A stepped round base: two plates, the top one smaller. Returns its top.
function Kit.roundBase(it, at, d: number, color)
	Kit.roundLayer(it, "Base", at, d, 0.4, color)
	Kit.roundLayer(it, "BaseTop", at * CF(0, 0.4, 0), d - 1, 0.4, color)
	return 0.8
end

-- A square candle with a stepped neon flame. Returns the flame position.
function Kit.candle(it, at, d: number, h: number, wax, flame)
	it.block("Candle", { d, h, d }, at * CF(0, h / 2, 0), wax)
	it.block("Drip", { 0.2, h * 0.4, 0.2 }, at * CF(d / 2 - 0.05, h * 0.75, -d / 2), wax, { studs = false })
	it.block("Wick", { 0.12, 0.2, 0.12 }, at * CF(0, h + 0.1, 0), Kit.C.black, { studs = false })
	it.block("Flame", { 0.4, 0.4, 0.4 }, at * CF(0, h + 0.4, 0), flame, { neon = true })
	it.block("FlameTip", { 0.22, 0.3, 0.22 }, at * CF(0, h + 0.75, 0), Kit.C.glowYellow, { neon = true })
	local p = (at * CF(0, h + 0.5, 0)).Position
	return { p.X, p.Y, p.Z }
end

-- A brick-built skull: head, crown, cheeks, dark eye sockets, nose, teeth. `at` = bottom centre; s = scale (1 = 2 studs wide).
function Kit.skull(it, at, s: number, socket, glowEyes: boolean?)
	it.block("Skull", { 2 * s, 1.2 * s, 1.6 * s }, at * CF(0, 1.1 * s, 0), Kit.C.bone)
	it.block("SkullTop", { 1.4 * s, 0.4 * s, 1.2 * s }, at * CF(0, 1.9 * s, 0.05 * s), Kit.C.bone)
	it.block("Cheeks", { 1.6 * s, 0.5 * s, 1.4 * s }, at * CF(0, 0.25 * s, -0.05 * s), Kit.C.bone)
	local opts = if glowEyes then { neon = true } else { studs = false }
	it.block("EyeL", { 0.5 * s, 0.5 * s, 0.2 }, at * CF(-0.45 * s, 1.0 * s, -0.8 * s - 0.05), socket, opts)
	it.block("EyeR", { 0.5 * s, 0.5 * s, 0.2 }, at * CF(0.45 * s, 1.0 * s, -0.8 * s - 0.05), socket, opts)
	it.block("Nose", { 0.25 * s, 0.25 * s, 0.2 }, at * CF(0, 0.62 * s, -0.8 * s - 0.05), Kit.C.black, { studs = false })
	for i, x in { -0.45, -0.15, 0.15, 0.45 } do
		it.block("Tooth" .. i, { 0.22 * s, 0.25 * s, 0.2 }, at * CF(x * s, 0.25 * s, -0.7 * s - 0.05), Kit.C.boneDark, { studs = false })
	end
end

return Kit
