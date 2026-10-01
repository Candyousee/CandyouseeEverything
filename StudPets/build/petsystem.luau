-- Builds the Stud Pet System assets (run from the StudPets folder):
--   lune run build/petsystem.luau            -> assets/eggs/*.rbxm, assets/PetSystemDemo.rbxm
--   lune run build/petsystem.luau preview F  -> also dumps the hatch cinematic to F (for Blender)

local fs = require("@lune/fs")
local serde = require("@lune/serde")
local process = require("@lune/process")
local roblox = require("@lune/roblox")
local Instance, CFrame, Vector3, Color3, Enum = roblox.Instance, roblox.CFrame, roblox.Vector3, roblox.Color3, roblox.Enum

local Config = require("../src/petsystem/shared/StudPetSystem/Config")
local Hatch = require("../src/petsystem/shared/StudPetSystem/HatchSequence")

local K = { 40, 34, 30 }

-- Stud eggs v4: a round brick egg built from small bricks (layers of voxels), with each
-- egg's pattern hand-drawn as pixel art on a 32-column x 13-row wrap-around map.
-- Column 16 is the front centre; row 1 is the top layer.
local LAYER_H = 0.3
local CELLW = 0.3
local NLAYERS = 13
local EGG_H = NLAYERS * LAYER_H

-- egg radius at height y (y = 0 at the centre): rounder bottom, longer pointier top
local function radiusAt(y)
	local c = -0.3
	local a = if y < c then 1.65 else 2.25
	local k = (y - c) / a
	if math.abs(k) >= 1 then
		return 0.15
	end
	return 1.45 * math.sqrt(1 - k * k)
end

local function blank()
	local m = {}
	for r = 1, NLAYERS do
		m[r] = string.rep(".", 32)
	end
	return m
end
-- write `rows` (strings, spaces = leave as is) into the map at row r, column c (wrapping)
local function stamp(m, r, c, rows)
	for dr, line in rows do
		local row = r + dr - 1
		if row >= 1 and row <= NLAYERS then
			local chars = string.split(m[row], "")
			for dc = 1, #line do
				local ch = string.sub(line, dc, dc)
				if ch ~= " " then
					chars[((c + dc - 2) % 32) + 1] = ch
				end
			end
			m[row] = table.concat(chars)
		end
	end
end
local function fillRow(m, r, ch)
	m[r] = string.rep(ch, 32)
end

-- the six designs. palette: char -> {r,g,b} (or {r,g,b, neon = true}); "." = base shell
local DESIGNS = {}

DESIGNS.spots = function()
	local m = blank()
	-- big cow patches
	stamp(m, 2, 5, { " bb", "bbb", " b" })
	stamp(m, 3, 13, { "  bb", " bbbb", "bbbb", " bb" })
	stamp(m, 3, 23, { "bb", "bbb" })
	stamp(m, 7, 10, { " bb", "bbbb", " bb" })
	stamp(m, 8, 2, { "bbb", "bbbb", " bb" })
	stamp(m, 7, 26, { " bb", "bbbb", "bbb" })
	stamp(m, 10, 19, { "bb", "bbb" })
	stamp(m, 1, 13, { "b" })
	-- straw nest round the bottom
	fillRow(m, 13, "y")
	stamp(m, 12, 1, { "y.y.Y.y.y.Y.y.y.Y.y.y.Y.y.y.Y.y." })
	return m, {
		["."] = { 250, 247, 236 },
		b = { 42, 40, 46 },
		y = { 230, 196, 90 },
		Y = { 200, 160, 70 },
	}
end

DESIGNS.leaves = function()
	local m = blank()
	-- a vine spiralling round with leaves, a flower on the front
	local vine = { { 4, 1 }, { 4, 2 }, { 5, 3 }, { 5, 4 }, { 6, 5 }, { 6, 6 }, { 7, 7 }, { 7, 8 }, { 8, 9 }, { 8, 10 }, { 9, 11 }, { 9, 12 }, { 10, 13 }, { 10, 14 }, { 10, 15 }, { 10, 16 }, { 10, 17 }, { 9, 18 }, { 9, 19 }, { 8, 20 }, { 8, 21 }, { 7, 22 }, { 7, 23 }, { 6, 24 }, { 6, 25 }, { 5, 26 }, { 5, 27 }, { 4, 28 }, { 4, 29 }, { 4, 30 }, { 4, 31 }, { 4, 32 } }
	for _, v in vine do
		stamp(m, v[1], v[2], { "v", "v" })
	end
	for _, l in { { 2, 3 }, { 5, 7 }, { 8, 12 }, { 12, 16 }, { 8, 21 }, { 5, 26 }, { 2, 30 }, { 7, 4 }, { 11, 9 }, { 7, 24 }, { 11, 20 } } do
		stamp(m, l[1], l[2], { "ll", "l" })
	end
	stamp(m, 5, 15, { " p ", "pyp", " p " })
	stamp(m, 6, 20, { "P", "" })
	fillRow(m, 12, "m")
	fillRow(m, 13, "M")
	stamp(m, 11, 1, { "m..m...m..m...m..m...m..m...m..." })
	return m, {
		["."] = { 140, 200, 100 },
		v = { 50, 120, 50 },
		l = { 90, 170, 70 },
		p = { 255, 130, 185 },
		P = { 255, 230, 90 },
		y = { 255, 225, 80 },
		m = { 100, 160, 75 },
		M = { 80, 130, 60 },
	}
end

DESIGNS.rosettes = function()
	local m = blank()
	local rosette = { " dd ", "dood", " dd " }
	local small = { "dd", "do" }
	for _, p in { { 2, 6 }, { 2, 21 }, { 4, 13 }, { 5, 1 }, { 5, 27 }, { 7, 8 }, { 7, 19 }, { 9, 14 }, { 10, 3 }, { 10, 25 } } do
		stamp(m, p[1], p[2], rosette)
	end
	for _, p in { { 1, 15 }, { 3, 30 }, { 6, 16 }, { 8, 30 }, { 11, 10 }, { 12, 19 }, { 4, 23 } } do
		stamp(m, p[1], p[2], small)
	end
	return m, {
		["."] = { 245, 200, 105 },
		d = { 70, 45, 30 },
		o = { 215, 130, 50 },
	}
end

DESIGNS.waves = function()
	local m = blank()
	-- sky-blue top with bubbles, wave crests, a foam line, deep water with a starfish + seaweed
	for _, b in { { 2, 6 }, { 3, 13 }, { 2, 20 }, { 4, 26 }, { 3, 2 }, { 1, 16 } } do
		stamp(m, b[1], b[2], { "w" })
	end
	stamp(m, 5, 1, { "..ww..ww..ww..ww..ww..ww..ww..ww" })
	stamp(m, 6, 1, { ".wwwwwwwwwwwwwwwwwwwwwwwwwwwwwww" })
	stamp(m, 6, 1, { "ww" })
	fillRow(m, 7, "f")
	for r = 8, 13 do
		fillRow(m, r, if r % 2 == 0 then "b" else "B")
	end
	stamp(m, 9, 14, { "  s  ", "sssss", " s s ", "s   s" })
	for _, c in { 4, 8, 24, 28 } do
		stamp(m, 10, c, { "g", "g", "g", "g" })
		stamp(m, 9, c + 1, { "g" })
	end
	return m, {
		["."] = { 120, 190, 245 },
		w = { 235, 248, 255 },
		f = { 255, 255, 255 },
		b = { 40, 105, 190 },
		B = { 35, 92, 170 },
		s = { 255, 140, 80 },
		g = { 70, 170, 110 },
	}
end

DESIGNS.spikes = function()
	local m = blank()
	-- cream belly on the front, dark spots, a stripe of darker scales across the back
	stamp(m, 4, 13, { " ccccc ", "ccccccc", "ccccccc", "ccccccc", "ccccccc", "ccccccc", " ccccc ", "  ccc  " })
	for _, p in { { 3, 5 }, { 6, 2 }, { 9, 6 }, { 3, 25 }, { 6, 28 }, { 9, 24 }, { 2, 17 }, { 11, 9 }, { 11, 22 } } do
		stamp(m, p[1], p[2], { "ss", "sd" })
	end
	for r = 2, 12 do
		stamp(m, r, 31, { "k" })
		stamp(m, r, 32, { "k" })
		stamp(m, r, 1, { "k" })
	end
	return m, {
		["."] = { 235, 140, 60 },
		c = { 255, 228, 170 },
		s = { 125, 70, 40 },
		d = { 95, 50, 30 },
		k = { 190, 100, 45 },
	}
end

DESIGNS.royal = function()
	local m = blank()
	-- purple with a gold cross-band, glowing gems, and twinkling stars
	fillRow(m, 7, "g")
	fillRow(m, 8, "G")
	for _, c in { 16, 8, 24, 32 } do
		for r = 2, 12 do
			stamp(m, r, c, { "g" })
		end
		stamp(m, 7, c - 1, { "geg" })
		stamp(m, 8, c - 1, { "GeG" })
	end
	for _, s in { { 3, 4 }, { 4, 12 }, { 2, 20 }, { 4, 27 }, { 10, 6 }, { 11, 13 }, { 10, 21 }, { 11, 29 } } do
		stamp(m, s[1], s[2], { "*" })
	end
	return m, {
		["."] = { 120, 70, 205 },
		g = { 255, 205, 70 },
		G = { 225, 170, 45 },
		e = { 90, 235, 255, neon = true },
		["*"] = { 255, 248, 210, neon = true },
	}
end

-- crack paths on the front: {row, column, stage}; they glow in the rarity colour as the egg shakes
local CRACK_CELLS = {
	{ 6, 12, 1 }, { 5, 13, 1 }, { 6, 14, 1 }, { 5, 15, 1 }, { 6, 16, 1 },
	{ 6, 16, 2 }, { 5, 17, 2 }, { 6, 18, 2 }, { 5, 19, 2 }, { 6, 20, 2 }, { 7, 21, 2 },
	{ 7, 16, 3 }, { 8, 15, 3 }, { 9, 16, 3 }, { 10, 15, 3 }, { 9, 14, 3 },
}

local function tiers(_egg)
	return nil, EGG_H
end

-- part list in egg space: {name, size, cf, color, neon?, crack?, class?, studs?}
local function eggParts(egg: any)
	local design = DESIGNS[egg.Theme or "spots"] or DESIGNS.spots
	local map, palette = design()
	local crackAt: { [string]: number } = {}
	for _, c in CRACK_CELLS do
		local key = c[1] .. ":" .. c[2]
		crackAt[key] = crackAt[key] or c[3]
	end
	local parts = {}
	local n = 0
	local function add(p)
		n += 1
		p.name = p.name .. n
		table.insert(parts, p)
		return p
	end

	-- voxel occupancy per layer
	local layers = {}
	for L = 1, NLAYERS do
		local y = EGG_H / 2 - (L - 0.5) * LAYER_H -- layer 1 at the top
		local r = radiusAt(y) + 0.06
		local cells = {}
		local N = math.ceil(r / CELLW) + 1
		for ix = -N, N do
			for iz = -N, N do
				local x, z = (ix + 0.5) * CELLW, (iz + 0.5) * CELLW
				if x * x + z * z <= r * r then
					cells[ix .. ":" .. iz] = true
				end
			end
		end
		layers[L] = { y = y, cells = cells, N = N }
	end
	local function filled(L, ix, iz)
		local l = layers[L]
		return l ~= nil and l.cells[ix .. ":" .. iz] == true
	end

	for L, layer in layers do
		local shadeK = 0.9 + 0.16 * (1 - (L - 1) / (NLAYERS - 1))
		for iz = -layer.N, layer.N do
			-- one row along x; colour each visible cell from the map, merge runs of one colour
			local run = nil
			local function flush()
				if run then
					local x0, x1 = run.i0 * CELLW, (run.i1 + 1) * CELLW
					local col = run.color
					add({
						name = if run.crack then "Crack" .. run.crack .. "_" else "Brick",
						size = { x1 - x0, LAYER_H, CELLW },
						cf = CFrame.new((x0 + x1) / 2, layer.y, (iz + 0.5) * CELLW),
						color = col,
						neon = run.neon,
						crack = run.crack,
						studs = true,
					})
					run = nil
				end
			end
			for ix = -layer.N, layer.N do
				if not layer.cells[ix .. ":" .. iz] then
					flush()
					continue
				end
				local exposed = not (filled(L, ix + 1, iz) and filled(L, ix - 1, iz) and filled(L, ix, iz + 1) and filled(L, ix, iz - 1) and filled(L - 1, ix, iz) and filled(L + 1, ix, iz))
				local color, neon, crack = nil, nil, nil
				if exposed then
					local x, z = (ix + 0.5) * CELLW, (iz + 0.5) * CELLW
					local q = (math.atan2(x, -z) / (2 * math.pi)) % 1 -- 0 = front centre
					local colIdx = (math.floor(((q + 0.5) % 1) * 32) % 32) + 1
					local ch = string.sub(map[L], colIdx, colIdx)
					local pc = palette[ch] or palette["."]
					color = { math.clamp(math.floor(pc[1] * shadeK), 0, 255), math.clamp(math.floor(pc[2] * shadeK), 0, 255), math.clamp(math.floor(pc[3] * shadeK), 0, 255) }
					if pc.neon then
						color = { pc[1], pc[2], pc[3] }
					end
					neon = pc.neon == true
					-- crack cells: front-facing bricks only
					if z < -0.3 and crackAt[L .. ":" .. colIdx] then
						crack = crackAt[L .. ":" .. colIdx]
					end
				end
				local key = if color then table.concat(color, ",") .. (if neon then "n" else "") else nil
				if run and not crack and not run.crack and (key == nil or run.key == nil or run.key == key) then
					run.i1 = ix
					if key and not run.key then
						run.key, run.color, run.neon = key, color, neon
					end
				else
					flush()
					run = { i0 = ix, i1 = ix, key = key, color = color or palette["."], neon = neon, crack = crack }
				end
			end
			flush()
		end
	end

	-- toppers (sit on the top layer)
	local top = EGG_H / 2
	local theme = egg.Theme or "spots"
	local function block(name, size, cf, color, extra)
		local p = { name = name, size = size, cf = cf, color = color }
		for k, v in extra or {} do
			p[k] = v
		end
		return add(p)
	end
	if theme == "spots" then
		-- a little red farm bow on top
		block("Bow", { 0.5, 0.3, 0.25 }, CFrame.new(-0.28, top + 0.15, 0) * CFrame.Angles(0, 0, math.rad(-15)), { 220, 60, 60 })
		block("Bow", { 0.5, 0.3, 0.25 }, CFrame.new(0.28, top + 0.15, 0) * CFrame.Angles(0, 0, math.rad(15)), { 220, 60, 60 })
		block("BowKnot", { 0.22, 0.25, 0.27 }, CFrame.new(0, top + 0.15, 0), { 190, 45, 45 })
	elseif theme == "leaves" then
		block("Stem", { 0.2, 0.4, 0.2 }, CFrame.new(0, top + 0.2, 0), { 110, 80, 50 })
		for k = 0, 4 do
			local a = k * math.pi * 2 / 5
			block("TopLeaf", { 0.16, 0.9, 0.6 }, CFrame.new(math.sin(a) * 0.3, top + 0.42, -math.cos(a) * 0.3) * CFrame.Angles(0, -a, 0) * CFrame.Angles(math.rad(-40), 0, 0), if k % 2 == 0 then { 60, 150, 60 } else { 100, 190, 80 }, { class = "WedgePart" })
		end
	elseif theme == "waves" then
		-- coral on top
		block("Coral", { 0.2, 0.6, 0.2 }, CFrame.new(0, top + 0.3, 0), { 255, 110, 130 })
		block("Coral", { 0.18, 0.4, 0.18 }, CFrame.new(-0.18, top + 0.42, 0) * CFrame.Angles(0, 0, math.rad(35)), { 255, 110, 130 })
		block("Coral", { 0.18, 0.35, 0.18 }, CFrame.new(0.17, top + 0.38, 0.05) * CFrame.Angles(0, 0, math.rad(-35)), { 255, 140, 150 })
	elseif theme == "spikes" then
		for k = -1, 1 do
			block("Plate", { 0.18, 0.5 - math.abs(k) * 0.15, 0.36 }, CFrame.new(0, top + 0.24 - math.abs(k) * 0.07, k * 0.3) * CFrame.Angles(0, if k < 0 then math.pi else 0, 0), { 255, 232, 190 }, { class = "WedgePart" })
		end
	elseif theme == "royal" then
		block("CrownBand", { 0.75, 0.2, 0.75 }, CFrame.new(0, top + 0.1, 0), { 255, 205, 70 })
		for k = 0, 3 do
			local a = k * math.pi / 2 + math.pi / 4
			block("CrownPoint", { 0.14, 0.4, 0.3 }, CFrame.new(math.sin(a) * 0.28, top + 0.4, -math.cos(a) * 0.28) * CFrame.Angles(0, -a, 0), { 255, 205, 70 }, { class = "WedgePart" })
		end
		block("CrownGem", { 0.22, 0.22, 0.22 }, CFrame.new(0, top + 0.32, 0), { 90, 235, 255 }, { neon = true })
	end
	return parts
end

local function makeEgg(egg)
	local model = Instance.new("Model")
	model.Name = egg.Name
	local root = Instance.new("Part")
	root.Name = "Root"
	root.Size = Vector3.new(1, 1, 1)
	root.Transparency = 1
	root.Anchored = true
	root.CanCollide = false
	root.CanQuery = false
	root.CanTouch = false
	root.CFrame = CFrame.new()
	root.Parent = model
	for _, p in eggParts(egg) do
		local part = Instance.new(p.class or "Part")
		part.Name = p.name
		part.Size = Vector3.new(p.size[1], p.size[2], p.size[3])
		part.CFrame = p.cf
		part.Color = Color3.fromRGB(p.color[1], p.color[2], p.color[3])
		part.Material = if p.neon then Enum.Material.Neon else Enum.Material.SmoothPlastic
		part.TopSurface = if p.studs then Enum.SurfaceType.Studs else Enum.SurfaceType.Smooth
		part.BottomSurface = Enum.SurfaceType.Smooth
		part.Anchored = true
		part.CanCollide = false
		part.CanQuery = false
		part.CanTouch = false
		part.CastShadow = not p.crack
		if p.shape == "sphere" then
			local mesh = Instance.new("SpecialMesh")
			mesh.MeshType = Enum.MeshType.Sphere
			mesh.Parent = part
		end
		if p.transparency then
			part.Transparency = p.transparency
		end
		if p.shape == "cylinder" then
			part.Shape = Enum.PartType.Cylinder
		end
		if p.crack then
			-- a normal shell brick until its crack opens, then it glows in the rarity colour
			part:SetAttribute("Crack", p.crack)
		end
		part.Parent = model
	end
	model.PrimaryPart = root
	model:SetAttribute("EggHeight", EGG_H)
	model:SetAttribute("StudEgg", egg.Name)
	return model
end

fs.writeDir("assets/eggs")
local eggModels = {}
for _, egg in Config.Eggs do
	local m = makeEgg(egg)
	eggModels[egg.Name] = m
	fs.writeFile(`assets/eggs/{egg.Name}.rbxm`, roblox.serializeModel({ m }))
end

-- Demo world: floor, spawn, one stand per egg in an arc facing the spawn.
local function block(name, size, cf, rgb, studs)
	local p = Instance.new("Part")
	p.Name = name
	p.Size = size
	p.CFrame = cf
	p.Color = Color3.fromRGB(rgb[1], rgb[2], rgb[3])
	p.Material = Enum.Material.Plastic
	p.TopSurface = if studs then Enum.SurfaceType.Studs else Enum.SurfaceType.Smooth
	p.BottomSurface = Enum.SurfaceType.Smooth
	p.Anchored = true
	return p
end

local demo = Instance.new("Folder")
demo.Name = "PetSystemDemo"
block("Floor", Vector3.new(160, 1, 160), CFrame.new(0, -0.5, 0), { 75, 151, 75 }, true).Parent = demo
local spawn = Instance.new("SpawnLocation")
spawn.Name = "Spawn"
spawn.Size = Vector3.new(8, 1, 8)
spawn.CFrame = CFrame.new(0, 0.5, 30)
spawn.Anchored = true
spawn.Neutral = true
spawn.Duration = 0
spawn.TopSurface = Enum.SurfaceType.Studs
spawn.Parent = demo
local stands = Instance.new("Folder")
stands.Name = "EggStands"
stands.Parent = demo
local n = #Config.Eggs
for i, egg in Config.Eggs do
	local a = math.rad(-60 + 120 * (i - 1) / (n - 1))
	local pos = Vector3.new(math.sin(a) * 26, 0, 30 - math.cos(a) * 26)
	-- face the spawn
	local cf = CFrame.lookAt(pos, Vector3.new(0, 0, 30))
	local stand = Instance.new("Model")
	stand.Name = egg.Name
	-- round pedestal: a stone base, a glowing rim in the egg's colour, a dark top
	local function disc(name, d, h, y, rgb, neon)
		local p = block(name, Vector3.new(h, d, d), cf * CFrame.new(0, y, 0) * CFrame.Angles(0, 0, math.rad(90)), rgb, false)
		p.Shape = Enum.PartType.Cylinder
		p.Material = if neon then Enum.Material.Neon else Enum.Material.SmoothPlastic
		return p
	end
	disc("Base", 8, 1, 0.5, { 88, 86, 96 }).Parent = stand
	disc("Rim", 7.2, 0.3, 1.1, egg.Colors.Spots, true).Parent = stand
	disc("Top", 6.8, 0.5, 1.35, { 52, 54, 76 }).Parent = stand
	local e = eggModels[egg.Name]:Clone()
	e.Name = "Egg"
	-- (Lune has no PivotTo/ScaleTo: place and scale the parts by hand)
	local SCALE = 1.4
	local at = cf * CFrame.new(0, 2.3 + EGG_H / 2 * SCALE, 0) * CFrame.Angles(0, math.pi, 0)
	for _, part in e:GetChildren() do
		if part:IsA("BasePart") then
			local c = part.CFrame
			part.CFrame = at * CFrame.new(c.Position * SCALE) * (c - c.Position)
			part.Size = part.Size * SCALE
		end
	end
	e.Parent = stand
	stand.PrimaryPart = stand:FindFirstChild("Base") :: any
	stand:SetAttribute("StudEggStand", egg.Name)
	-- stream the whole stand at once so the client always finds its egg
	stand.ModelStreamingMode = Enum.ModelStreamingMode.Atomic
	stand:AddTag("StudEggStand")
	stand.Parent = stands
end
fs.writeFile("assets/PetSystemDemo.rbxm", roblox.serializeModel({ demo }))
print(("[petsystem] %d eggs -> assets/eggs, demo world -> assets/PetSystemDemo.rbxm"):format(n))

-- Hatch cinematic preview: egg + shards + a stand-in pet box, in the same JSON format
-- render_preview.py reads (one "pet" whose parts are the stage objects).
if process.args[1] == "preview" then
	local drama = tonumber(process.args[3]) or 2
	local egg = Config.Eggs[tonumber(process.args[4]) or 1]
	local ep = eggParts(egg)
	local parts, frames = {}, {}
	for _, p in ep do
		table.insert(parts, { name = p.name, class = p.class or "Part", size = p.size, color = p.color, studs = p.studs == true, neon = p.neon == true, shape = p.shape })
	end
	local MAXS = 24
	for k = 1, MAXS do
		table.insert(parts, { name = "Shard" .. k, class = "Part", size = { 1, 1, 0.25 }, color = egg.Colors.Shell, studs = false, neon = false })
	end
	table.insert(parts, { name = "Pet", class = "Part", size = { 2.4, 2.4, 2.4 }, color = { 255, 200, 60 }, studs = true, neon = false })
	table.insert(parts, { name = "Ring", class = "Part", size = { 1, 0.08, 1 }, color = { 255, 255, 255 }, studs = false, neon = true })
	local FPS = 24
	local T = Hatch.Timing(drama)
	local HIDE = CFrame.new(0, -500, 0)
	for f = 0, math.floor(T.length * FPS) do
		local s = Hatch.State(f / FPS, drama, 7)
		local frame = {}
		local function put(cf)
			for _, c in { cf:GetComponents() } do
				table.insert(frame, math.round(c * 10000) / 10000)
			end
		end
		local base = CFrame.new(0, 3, 0) -- lift the stage off the ground for the render
		local eggCF = base
			* CFrame.new(s.eggPos[1], s.eggPos[2], s.eggPos[3])
			* CFrame.Angles(math.rad(s.eggRot[1]), math.rad(s.eggRot[2]), math.rad(s.eggRot[3]))
		for _, p in ep do
			local visible = s.eggVisible
			if visible then
				local c = p.cf
				put(eggCF * CFrame.new(c.Position * s.eggScale) * (c - c.Position))
			else
				put(HIDE)
			end
		end
		for k = 1, MAXS do
			local sh = s.shards[k]
			if sh and sh.alpha > 0.3 then
				put(base * CFrame.new(sh.pos[1], sh.pos[2], sh.pos[3]) * CFrame.Angles(math.rad(sh.rot[1]), math.rad(sh.rot[2]), math.rad(sh.rot[3])))
			else
				put(HIDE)
			end
		end
		if s.petScale > 0.02 then
			-- stand-in for the pet; the real one is scaled with Model:ScaleTo in game
			put(base * CFrame.new(0, s.petY, 0) * CFrame.Angles(0, math.rad(s.petYaw), 0))
		else
			put(HIDE)
		end
		put(if s.ring then base * CFrame.new(0, -1.6, 0) else HIDE)
		table.insert(frames, frame)
	end
	fs.writeFile(process.args[2], serde.encode("json", { fps = FPS, pets = { { name = "Hatch", parts = parts, anims = { { name = "Hatch", looped = false, frames = frames } } } } }))
	print("[petsystem] hatch preview -> " .. process.args[2])
end

-- Egg stills: every egg at rest, cracks hidden (render with render_preview.py sheet).
if process.args[1] == "eggs" then
	local pets = {}
	for _, egg in Config.Eggs do
		local parts, frame = {}, {}
		for _, p in eggParts(egg) do
			if true then
				table.insert(parts, { name = p.name, class = p.class or "Part", size = p.size, color = p.color, studs = p.studs == true, neon = p.neon == true, shape = p.shape })
				for _, c in { (CFrame.new(0, EGG_H / 2 + 0.25, 0) * p.cf):GetComponents() } do
					table.insert(frame, c)
				end
			end
		end
		table.insert(pets, { name = egg.Name:gsub(" ", ""), parts = parts, anims = { { name = "Idle", looped = true, frames = { frame } } } })
	end
	fs.writeFile(process.args[2], serde.encode("json", { fps = 20, pets = pets }))
	print("[petsystem] egg stills -> " .. process.args[2])
end

-- Showcase video data (render with build/make_system_video.py): every egg in egg space with
-- its crack stages, the demo stands as placed in the world, and the hatch timeline per frame.
if process.args[1] == "video" then
	local function partOut(p: any, cf: any)
		return {
			name = p.Name,
			class = p.ClassName,
			size = { p.Size.X, p.Size.Y, p.Size.Z },
			color = { math.round(p.Color.R * 255), math.round(p.Color.G * 255), math.round(p.Color.B * 255) },
			neon = p.Material == Enum.Material.Neon,
			studs = p.TopSurface == Enum.SurfaceType.Studs,
			shape = if p:FindFirstChildOfClass("SpecialMesh") then "sphere" elseif p:IsA("Part") and p.Shape == Enum.PartType.Cylinder then "cylinder" else nil,
			crack = p:GetAttribute("Crack"),
			cf = { cf:GetComponents() },
		}
	end
	local eggs = {}
	for name, m in eggModels do
		local list = {}
		for _, p in m:GetChildren() do
			if p:IsA("BasePart") and p.Name ~= "Root" then
				table.insert(list, partOut(p, p.CFrame))
			end
		end
		eggs[name] = { parts = list }
	end
	local standList, pivots = {}, {}
	for _, stand in stands:GetChildren() do
		local egg = stand:FindFirstChild("Egg")
		pivots[stand.Name] = { (egg.PrimaryPart :: any).CFrame:GetComponents() }
		for _, d in stand:GetDescendants() do
			if d:IsA("BasePart") and d.Transparency < 1 then
				local o = partOut(d, d.CFrame)
				o.stand = stand.Name
				o.isEgg = d:IsDescendantOf(egg)
				table.insert(standList, o)
			end
		end
	end
	local drama = tonumber(process.args[3]) or 2
	local FPS = 24
	local T = Hatch.Timing(drama)
	local frames = {}
	for f = 0, math.ceil(T.length * FPS) do
		local s = Hatch.State(f / FPS, drama, 28)
		table.insert(frames, s)
	end
	fs.writeFile(process.args[2], serde.encode("json", {
		eggs = eggs,
		stands = standList,
		pivots = pivots,
		hatch = { drama = drama, fps = FPS, pop = T.pop, length = T.length, shakes = T.shakes, frames = frames },
	}))
	print("[petsystem] video data -> " .. process.args[2])
end
