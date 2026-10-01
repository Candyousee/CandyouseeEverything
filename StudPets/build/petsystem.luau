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

-- Stud eggs v3: every tier is a ring of small bricks around a core, and the egg's pattern
-- is just which colour each brick is - so decorations are flush with the shell (nothing
-- floats or clips), the crack lines are bricks that light up, and only a few pieces sit
-- on top of the egg.
local PROFILES = {
	default = { { 1.4, 0.35 }, { 2.0, 0.4 }, { 2.45, 0.45 }, { 2.7, 0.5 }, { 2.8, 0.5 }, { 2.7, 0.45 }, { 2.45, 0.4 }, { 2.05, 0.4 }, { 1.5, 0.35 }, { 0.9, 0.25 } },
	round = { { 1.6, 0.35 }, { 2.3, 0.4 }, { 2.75, 0.45 }, { 3.0, 0.5 }, { 3.05, 0.5 }, { 2.9, 0.45 }, { 2.6, 0.4 }, { 2.15, 0.4 }, { 1.55, 0.35 }, { 0.9, 0.25 } },
	tall = { { 1.3, 0.35 }, { 1.9, 0.4 }, { 2.3, 0.45 }, { 2.55, 0.5 }, { 2.6, 0.5 }, { 2.5, 0.5 }, { 2.3, 0.45 }, { 2.0, 0.45 }, { 1.6, 0.4 }, { 1.1, 0.35 }, { 0.6, 0.25 } },
	wide = { { 1.7, 0.35 }, { 2.4, 0.4 }, { 2.85, 0.45 }, { 3.1, 0.5 }, { 3.1, 0.5 }, { 2.95, 0.45 }, { 2.6, 0.4 }, { 2.1, 0.4 }, { 1.5, 0.3 }, { 0.85, 0.25 } },
}
local THEME_PROFILE = { spots = "default", leaves = "default", rosettes = "default", waves = "round", spikes = "wide", royal = "tall" }
local SHELL_DEPTH = 0.22 -- thickness of the brick ring around each tier's core
local CELL = 0.36 -- target brick width along a face

local function shade(c, k)
	return { math.clamp(math.floor(c[1] * k), 0, 255), math.clamp(math.floor(c[2] * k), 0, 255), math.clamp(math.floor(c[3] * k), 0, 255) }
end

local function tiers(egg)
	local prof = PROFILES[THEME_PROFILE[egg.Theme or "spots"] or "default"]
	local H = 0
	for _, t in prof do
		H += t[2]
	end
	local out, y = {}, -H / 2
	for _, t in prof do
		table.insert(out, { w = t[1], h = t[2], y = y + t[2] / 2 })
		y += t[2]
	end
	return out, H
end

local EGG_H = select(2, tiers({ Theme = "spots" }))

-- wrap-around distance on the egg's surface, q = 0..1 around (0 = front centre)
local PERIM = 9.0
local function sdist(q1, y1, q2, y2)
	local dq = math.abs(q1 - q2)
	dq = math.min(dq, 1 - dq) * PERIM
	return math.sqrt(dq * dq + (y1 - y2) * (y1 - y2))
end

-- the pattern: colour (+ neon) of the brick at surface position (q, y), tier i
local function patternColor(egg, q, y, i, nT, face, u)
	local C = egg.Colors
	local shell, spots = C.Shell, C.Spots
	local base = shade(shell, 0.86 + 0.24 * (i - 1) / (nT - 1))
	local theme = egg.Theme or "spots"
	if theme == "spots" then
		for _, s in { { 0.02, 0.35, 0.55 }, { 0.13, -0.45, 0.45 }, { 0.9, -0.3, 0.5 }, { 0.3, 0.6, 0.5 }, { 0.45, -0.2, 0.55 }, { 0.62, 0.45, 0.5 }, { 0.75, -0.65, 0.45 }, { 0.85, 0.9, 0.35 } } do
			if sdist(q, y, s[1], s[2]) < s[3] then
				return spots
			end
		end
	elseif theme == "leaves" then
		-- a vine zig-zagging round the middle
		local band = -0.55 + 1.0 * math.abs(((q * 8) % 2) - 1)
		if math.abs(y - band) < 0.26 then
			return spots
		end
		if math.abs(y - band) < 0.42 then
			return shade(C.Shell, 0.92)
		end
		if sdist(q, y, 0.04, 0.85) < 0.12 then
			return { 255, 225, 80 }
		end
		if sdist(q, y, 0.04, 0.85) < 0.36 then
			return { 255, 130, 180 }
		end
		if y < -1.25 then
			return shade(spots, 1.15)
		end
	elseif theme == "rosettes" then
		for _, r in { { 0.0, 0.0 }, { 0.12, 0.75 }, { 0.88, 0.7 }, { 0.15, -0.8 }, { 0.85, -0.75 }, { 0.3, 0.1 }, { 0.7, 0.05 }, { 0.45, 0.8 }, { 0.55, -0.7 }, { 0.42, -0.25 }, { 0.58, 0.4 } } do
			local d = sdist(q, y, r[1], r[2])
			if d < 0.2 then
				return { 230, 145, 55 }
			elseif d < 0.45 then
				return spots
			end
		end
	elseif theme == "waves" then
		-- deep water below, a white foam line, wave crests rising into the sky-blue top
		if i <= 3 then
			return shade(spots, 0.9 + 0.1 * i)
		elseif i == 4 then
			return { 245, 252, 255 }
		elseif i == 5 then
			local k = math.floor((u + 1) * 3 + face * 7) % 3
			if k == 0 then
				return { 245, 252, 255 }
			end
		end
		for _, b in { { 0.05, 0.75 }, { 0.92, 1.0 }, { 0.3, 0.9 }, { 0.6, 0.7 }, { 0.75, 1.2 }, { 0.12, 1.25 } } do
			if sdist(q, y, b[1], b[2]) < 0.16 then
				return { 220, 245, 255 }
			end
		end
		-- a starfish on the front, made of bricks
		local sx, sy = (((q + 0.5) % 1) - 0.5) * PERIM - 0.55, y - 0.55
		local d = math.sqrt(sx * sx + sy * sy)
		local a = math.atan2(sy, sx)
		local arm = math.abs(math.sin(a * 2.5 + 0.3))
		if d < 0.12 + 0.28 * arm then
			return { 255, 140, 80 }
		end
	elseif theme == "spikes" then
		-- pale belly on the front, dark spots elsewhere
		if face == 0 and math.abs(u) < 0.5 and y < 0.55 and y > -1.3 then
			return shade({ 255, 225, 170 }, 0.9 + 0.15 * (i - 1) / (nT - 1))
		end
		for _, s in { { 0.14, 0.75, 0.3 }, { 0.86, 0.7, 0.3 }, { 0.16, -0.35, 0.28 }, { 0.84, -0.4, 0.28 }, { 0.25, 0.25, 0.35 }, { 0.75, 0.2, 0.35 }, { 0.32, -0.75, 0.3 }, { 0.68, -0.8, 0.3 }, { 0.5, 0.1, 0.4 }, { 0.42, 0.9, 0.25 }, { 0.58, 1.0, 0.25 }, { 0.05, 1.25, 0.22 } } do
			if sdist(q, y, s[1], s[2]) < s[3] then
				return spots
			end
		end
	elseif theme == "royal" then
		if i == 5 then
			if math.abs(u) < 0.2 then
				return C.Gem or { 90, 230, 255 }, true
			end
			return spots
		end
		if i == 4 or i == 6 then
			if math.abs(u) < 0.2 then
				return shade(spots, 0.8)
			end
		end
		for _, s in { { 0.1, 0.9 }, { 0.35, 1.1 }, { 0.6, 0.8 }, { 0.85, 1.05 }, { 0.2, -0.8 }, { 0.7, -0.9 }, { 0.95, -0.6 }, { 0.45, -1.0 } } do
			if sdist(q, y, s[1], s[2]) < 0.13 then
				return { 255, 250, 215 }, true
			end
		end
	end
	return base
end

-- crack paths on the front face: {tier, u} pairs per crack (u = -1..1 across the face)
local CRACKS = {
	{ { 5, -0.75 }, { 6, -0.55 }, { 6, -0.3 }, { 5, -0.15 }, { 5, 0.05 }, { 6, 0.2 } },
	{ { 6, 0.2 }, { 6, 0.4 }, { 5, 0.55 }, { 5, 0.75 }, { 6, 0.9 } },
	{ { 5, 0.05 }, { 4, 0.1 }, { 4, 0.3 }, { 3, 0.4 }, { 3, 0.2 }, { 2, 0.1 } },
}

local function eggParts(egg: any)
	local C = egg.Colors
	local T, H = tiers(egg)
	local nT = #T
	local parts = {}
	local n = 0
	local function add(p)
		n += 1
		p.name = p.name .. n
		table.insert(parts, p)
		return p
	end
	-- which (tier, face 0, cell) belongs to which crack
	local crackCell: { [string]: number } = {}
	for ci, path in CRACKS do
		for _, c in path do
			local key = c[1] .. ":" .. c[2]
			crackCell[key] = crackCell[key] or ci
		end
	end

	for i, t in T do
		local d = math.min(SHELL_DEPTH, t.w * 0.2)
		local inner = t.w - 2 * d
		local shellBase = shade(C.Shell, 0.86 + 0.24 * (i - 1) / (nT - 1))
		add({ name = "Core", size = { inner, t.h, inner }, cf = CFrame.new(0, t.y, 0), color = shellBase, studs = true })
		-- four faces: front/back strips span the full width, left/right fit between them
		for face = 0, 3 do
			local len = if face % 2 == 0 then t.w else inner
			local cells = math.max(2, math.floor(len / CELL + 0.5))
			local cw = len / cells
			local rot = CFrame.Angles(0, face * math.pi / 2, 0)
			-- build cells, then merge runs of the same colour into one brick
			local run = nil
			local function flush()
				if run then
					local mid = (run.u0 + run.u1) / 2
					local w = run.u1 - run.u0
					add({
						name = if run.crack then "Crack" .. run.crack .. "_" else "Brick",
						size = { w, t.h, d },
						cf = rot * CFrame.new(mid, t.y, -t.w / 2 + d / 2),
						color = run.color,
						neon = run.neon,
						crack = run.crack,
						studs = true,
					})
					run = nil
				end
			end
			for c = 1, cells do
				local x0 = -len / 2 + (c - 1) * cw
				local x1 = x0 + cw
				local u = (x0 + x1) / len -- -1..1 across the face
				-- position around the egg: front centre 0, going round to the left
				local q = ((face + 0.5 + ((x0 + x1) / 2) / len) / 4 - 0.125) % 1
				q = (face / 4 + ((x0 + x1) / 2) / len / 4) % 1
				local color, neon = patternColor(egg, q, t.y, i, nT, face, u)
				local crack = nil
				if face == 0 then
					for _, path in CRACKS do
						for _, cc in path do
							if cc[1] == i and math.abs(cc[2] - u) < cw / len then
								crack = crackCell[cc[1] .. ":" .. cc[2]]
							end
						end
					end
				end
				local key = table.concat(color, ",") .. (if neon then "n" else "")
				if run and not crack and not run.crack and run.key == key then
					run.u1 = x1
				else
					flush()
					run = { u0 = x0, u1 = x1, color = color, neon = neon, key = key, crack = crack }
				end
			end
			flush()
		end
	end

	-- the few pieces that sit on top of the egg
	local topT = T[nT]
	local top = topT.y + topT.h / 2
	local theme = egg.Theme or "spots"
	if theme == "leaves" then
		for k = 0, 4 do
			local a = k * math.pi * 2 / 5
			add({ name = "TopLeaf", class = "WedgePart", size = { 0.14, 0.85, 0.55 }, cf = CFrame.new(math.sin(a) * 0.22, top + 0.38, -math.cos(a) * 0.22) * CFrame.Angles(0, -a, 0) * CFrame.Angles(math.rad(-35), 0, 0), color = if k % 2 == 0 then C.Spots else shade(C.Spots, 1.3) })
		end
		add({ name = "Stem", size = { 0.2, 0.3, 0.2 }, cf = CFrame.new(0, top + 0.15, 0), color = { 110, 80, 50 } })
	elseif theme == "royal" then
		for k = 0, 3 do
			local a = k * math.pi / 2
			add({ name = "Crown", class = "WedgePart", size = { 0.5, 0.38, 0.12 }, cf = CFrame.new(math.sin(a) * 0.24, top + 0.19, -math.cos(a) * 0.24) * CFrame.Angles(0, -a, 0) * CFrame.Angles(0, math.pi / 2, 0), color = C.Spots })
		end
		add({ name = "CrownGem", size = { 0.24, 0.24, 0.24 }, cf = CFrame.new(0, top + 0.16, 0), color = C.Gem or { 90, 230, 255 }, neon = true })
	elseif theme == "spikes" then
		for k = -1, 1 do
			add({ name = "Plate", class = "WedgePart", size = { 0.16, 0.42 - math.abs(k) * 0.12, 0.3 }, cf = CFrame.new(0, top + 0.2 - math.abs(k) * 0.06, k * 0.27) * CFrame.Angles(0, if k < 0 then math.pi else 0, 0), color = { 250, 236, 200 } })
		end
	end
	local _ = H
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
