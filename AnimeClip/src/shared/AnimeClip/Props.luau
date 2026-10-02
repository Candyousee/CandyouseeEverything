--!strict
-- Shapes for the katana, its sheath, and the blocky stand-in body, as "prims":
--   { shape = "block" | "ball" | "cyl", cf = CF, size = {x, y, z}, color = {r, g, b},
--     alpha = 0..1 (0 = solid), neon = bool, tag = string? }
-- ("cyl" is a Roblox cylinder: its length runs along X.)
-- The game turns prims into Parts; the preview turns them into Blender objects.

local CF = require(script and script.Parent and script.Parent:FindFirstChild("CF") or "./CF")

local Props = {}

local function prim(shape, cf, size, color, extra)
	local p = { shape = shape, cf = cf, size = size, color = color, alpha = 0, neon = false }
	for k, v in extra or {} do
		p[k] = v
	end
	return p
end
Props.prim = prim

local UPCYL = CF.angles(0, 0, math.pi / 2) -- a cylinder standing along Y

-- Katana in sword space: grip centre at the origin, blade along +Y.
-- tag "blade" parts glow when the sword is charged.
function Props.Katana(style: string): { any }
	local list = {}
	local wrap = if style == "rival" then { 120, 20, 30 } else { 30, 34, 52 }
	local guard = if style == "rival" then { 40, 30, 30 } else { 190, 160, 80 }
	local steel = if style == "rival" then { 200, 190, 200 } else { 225, 232, 240 }
	-- handle: wrapped grip with diamond pattern bands, pommel cap
	table.insert(list, prim("cyl", CF.mul(CF.new(0, -0.05, 0), UPCYL), { 1.25, 0.24, 0.24 }, wrap))
	for k = 0, 4 do
		table.insert(list, prim("block", CF.mul(CF.new(0, -0.55 + k * 0.24, 0), CF.angles(0, math.rad(45), 0)), { 0.19, 0.06, 0.19 }, { 235, 230, 220 }))
	end
	table.insert(list, prim("cyl", CF.mul(CF.new(0, -0.72, 0), UPCYL), { 0.1, 0.27, 0.27 }, guard))
	-- tsuba (round guard) + collar
	table.insert(list, prim("cyl", CF.mul(CF.new(0, 0.62, 0), UPCYL), { 0.08, 0.62, 0.62 }, guard, { shine = true }))
	table.insert(list, prim("block", CF.new(0, 0.72, 0), { 0.14, 0.14, 0.2 }, guard, { shine = true }))
	-- blade: slightly curved, thin spine and a bright edge, a point at the tip
	local N = 8
	local L = 3.7
	for i = 0, N - 1 do
		local a = i / N
		local b = (i + 1) / N
		local y0, y1 = 0.78 + a * L, 0.78 + b * L
		local z0, z1 = 0.02 * (a * 4) ^ 2, 0.02 * (b * 4) ^ 2 -- curve back toward +Z (the spine side)
		local mid = { 0, (y0 + y1) / 2, (z0 + z1) / 2 }
		local dir = { 0, y1 - y0, z1 - z0 }
		local seg = CF.mul(CF.along(mid, dir), CF.angles(0, 0, 0))
		local len = math.sqrt(dir[2] ^ 2 + dir[3] ^ 2) * 1.04
		local w = if i == N - 1 then 0.1 else 0.13
		table.insert(list, prim("block", seg, { len, 0.045, w }, steel, { tag = "blade", shine = true }))
		-- the bright cutting edge on the -Z side
		local edge = CF.mul(seg, CF.new(0, 0, -w / 2))
		table.insert(list, prim("block", edge, { len, 0.03, 0.035 }, { 255, 255, 255 }, { tag = "blade" }))
	end
	return list
end

-- Sheath (saya) in sheath space: mouth at the origin, running along +Y.
function Props.Sheath(): { any }
	local list = {}
	local lacquer, gold = { 22, 22, 30 }, { 190, 160, 80 }
	table.insert(list, prim("block", CF.new(0, 1.95, 0.04), { 0.2, 3.9, 0.3 }, lacquer, { shine = true }))
	table.insert(list, prim("block", CF.new(0, 0.08, 0.02), { 0.24, 0.16, 0.34 }, gold, { shine = true }))
	table.insert(list, prim("block", CF.new(0, 3.86, 0.04), { 0.23, 0.14, 0.33 }, gold, { shine = true }))
	-- cord (sageo) loop
	table.insert(list, prim("block", CF.mul(CF.new(-0.12, 0.6, 0.04), CF.angles(0, 0, math.rad(12))), { 0.05, 0.5, 0.36 }, { 80, 40, 140 }))
	return list
end

-- Where the sword sits in the hand (RightHand space -> sword space): blade out of the front of the fist.
Props.GRIP = CF.mul(CF.new(0, -0.12, 0), CF.angles(-math.pi / 2, 0, 0))
-- Sheath on the left hip (LowerTorso space): mouth forward, running back and down.
do
	local mouth = { -1.05, 0.05, -0.75 }
	local dir = CF.unit({ 0.08, -0.32, 1 })
	Props.SHEATH = CF.mul(CF.along(mouth, dir), CF.angles(0, 0, -math.pi / 2))
end
-- A sheathed sword: its guard sits at the sheath mouth.
Props.SHEATHED = CF.mul(Props.SHEATH, CF.new(0, -0.7, 0))

-- Anime face and hair for the stand-in head (Head space; the face looks along -Z).
function Props.HeadDetail(style: string): { any }
	local list = {}
	local hair = if style == "rival" then { 230, 230, 238 } else { 18, 18, 24 }
	local iris = if style == "rival" then { 200, 30, 40 } else { 40, 120, 220 }
	-- eyes: white, coloured iris, a sparkle
	for _, side in { -1, 1 } do
		local x = side * 0.25
		table.insert(list, prim("block", CF.new(x, 0.02, -0.6), { 0.3, 0.26, 0.04 }, { 250, 250, 252 }))
		table.insert(list, prim("block", CF.new(x + side * 0.02, -0.0, -0.615), { 0.16, 0.24, 0.04 }, iris))
		table.insert(list, prim("block", CF.new(x - side * 0.03, 0.06, -0.63), { 0.06, 0.06, 0.03 }, { 255, 255, 255 }))
		-- brows angled down toward the middle (a fierce look)
		table.insert(list, prim("block", CF.mul(CF.new(x, 0.22, -0.61), CF.angles(0, 0, side * math.rad(14))), { 0.32, 0.06, 0.04 }, hair))
	end
	table.insert(list, prim("block", CF.new(0, -0.3, -0.605), { 0.22, 0.04, 0.03 }, { 120, 60, 60 }))
	-- hair: a cap plus spikes sweeping back and up
	table.insert(list, prim("block", CF.new(0, 0.5, 0.06), { 1.3, 0.34, 1.32 }, hair))
	table.insert(list, prim("block", CF.new(0, 0.05, 0.56), { 1.3, 1.1, 0.24 }, hair))
	for _, side in { -1, 1 } do
		table.insert(list, prim("block", CF.new(side * 0.62, 0.15, 0.1), { 0.14, 0.8, 1.1 }, hair))
	end
	local spikes = {
		{ 0, 0.78, -0.35, 30, 0, 0, 0.6 },
		{ -0.4, 0.72, -0.4, 35, 0, 25, 0.5 },
		{ 0.4, 0.72, -0.4, 35, 0, -25, 0.5 },
		{ -0.2, 0.85, 0.15, -20, 0, 15, 0.7 },
		{ 0.25, 0.85, 0.2, -25, 0, -20, 0.7 },
		{ 0, 0.8, 0.5, -55, 0, 0, 0.8 },
		{ -0.55, 0.55, 0.45, -50, 0, 40, 0.6 },
		{ 0.55, 0.55, 0.45, -50, 0, -40, 0.6 },
		{ -0.3, 0.45, -0.62, 70, 0, 20, 0.4 }, -- fringe
		{ 0.15, 0.45, -0.64, 75, 0, -15, 0.45 },
	}
	for _, sp in spikes do
		local cf = CF.mul(CF.new(sp[1], sp[2], sp[3]), CF.deg(sp[4], sp[5], sp[6]))
		table.insert(list, prim("block", CF.mul(cf, CF.new(0, sp[7] / 2, 0)), { 0.32, sp[7], 0.3 }, hair))
	end
	if style == "rival" then
		-- a red headband with trailing tails
		table.insert(list, prim("block", CF.new(0, 0.32, 0), { 1.28, 0.16, 1.28 }, { 190, 30, 40 }))
		table.insert(list, prim("block", CF.mul(CF.new(0.15, 0.2, 0.9), CF.deg(-20, 0, 10)), { 0.14, 0.12, 0.8 }, { 190, 30, 40 }))
		table.insert(list, prim("block", CF.mul(CF.new(-0.1, 0.1, 0.95), CF.deg(-35, 0, -8)), { 0.14, 0.12, 0.8 }, { 190, 30, 40 }))
	end
	return list
end

-- Blocky body (the stand-in rig): colours per part
function Props.BodyColors(style: string): { [string]: { number } }
	local skin = { 234, 200, 170 }
	local top = if style == "rival" then { 140, 26, 36 } else { 26, 28, 40 }
	local pants = if style == "rival" then { 40, 30, 34 } else { 18, 18, 24 }
	local sleeve = if style == "rival" then { 110, 20, 30 } else { 36, 40, 58 }
	return {
		Head = skin,
		UpperTorso = top,
		LowerTorso = pants,
		LeftUpperArm = sleeve,
		RightUpperArm = sleeve,
		LeftLowerArm = skin,
		RightLowerArm = skin,
		LeftHand = skin,
		RightHand = skin,
		LeftUpperLeg = pants,
		RightUpperLeg = pants,
		LeftLowerLeg = pants,
		RightLowerLeg = pants,
		LeftFoot = { 20, 20, 24 },
		RightFoot = { 20, 20, 24 },
	}
end

return Props
