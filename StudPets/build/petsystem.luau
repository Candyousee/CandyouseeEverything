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

-- Stud eggs: stacked tiers with studs on every ledge. Each egg has its own silhouette
-- (tier profile), colour shading and themed block decorations.
local PROFILES = {
	default = { { 1.4, 0.35 }, { 2.0, 0.4 }, { 2.45, 0.45 }, { 2.7, 0.5 }, { 2.8, 0.5 }, { 2.7, 0.45 }, { 2.45, 0.4 }, { 2.05, 0.4 }, { 1.5, 0.35 }, { 0.9, 0.25 } },
	round = { { 1.6, 0.35 }, { 2.3, 0.4 }, { 2.75, 0.45 }, { 3.0, 0.5 }, { 3.05, 0.5 }, { 2.9, 0.45 }, { 2.6, 0.4 }, { 2.15, 0.4 }, { 1.55, 0.35 }, { 0.9, 0.25 } },
	tall = { { 1.3, 0.35 }, { 1.9, 0.4 }, { 2.3, 0.45 }, { 2.55, 0.5 }, { 2.6, 0.5 }, { 2.5, 0.5 }, { 2.3, 0.45 }, { 2.0, 0.45 }, { 1.6, 0.4 }, { 1.1, 0.35 }, { 0.6, 0.25 } },
	wide = { { 1.7, 0.35 }, { 2.4, 0.4 }, { 2.85, 0.45 }, { 3.1, 0.5 }, { 3.1, 0.5 }, { 2.95, 0.45 }, { 2.6, 0.4 }, { 2.1, 0.4 }, { 1.5, 0.3 }, { 0.85, 0.25 } },
}
local THEME_PROFILE = { spots = "default", leaves = "default", rosettes = "default", waves = "round", spikes = "wide", royal = "tall" }

local function shade(c, k)
	return { math.clamp(math.floor(c[1] * k), 0, 255), math.clamp(math.floor(c[2] * k), 0, 255), math.clamp(math.floor(c[3] * k), 0, 255) }
end

-- tier layout for an egg: list of {w, h, y} (y = centre), centred on y = 0
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

-- part list in egg space: {name, size, cf, color, studs?, class?, neon?, crack?}
local function eggParts(egg: any)
	local C = egg.Colors
	local shell, spots = C.Shell, C.Spots
	local T, H = tiers(egg)
	local parts = {}
	local n = 0
	local function add(p)
		n += 1
		p.name = p.name .. n
		table.insert(parts, p)
		return p
	end
	-- the shell: darker at the bottom, lighter at the top, studs on every ledge
	for i, t in T do
		local k = 0.86 + 0.24 * (i - 1) / (#T - 1)
		add({ name = "Tier", size = { t.w, t.h, t.w }, cf = CFrame.new(0, t.y, 0), color = shade(shell, k), studs = true })
	end
	-- a flat tile on one face of a tier. face 0 = front (-Z), 1 = left, 2 = back, 3 = right;
	-- u = -1..1 across the face; dy = offset from the tier centre
	local function tile(face, ti, u, w, h, color, proud, dy, extra)
		local t = T[ti]
		local half = t.w / 2
		local pr = proud or 0.08
		local cf = CFrame.Angles(0, face * math.pi / 2, 0) * CFrame.new(u * (half - w / 2 - 0.02), t.y + (dy or 0), -half - pr / 2 + 0.01)
		local p = { name = "Deco", size = { w, h, pr }, cf = cf, color = color }
		for key, v in extra or {} do
			p[key] = v
		end
		return add(p)
	end
	local theme = egg.Theme or "spots"
	if theme == "spots" then
		-- farm: big two-tone brown spots all round + grass tufts at the base
		local S = { { 0, 5, -0.55, 0.75 }, { 0, 3, 0.45, 0.6 }, { 0, 7, 0.2, 0.5 }, { 1, 4, 0.1, 0.8 }, { 1, 7, -0.4, 0.5 }, { 2, 5, 0.3, 0.75 }, { 2, 3, -0.5, 0.5 }, { 3, 4, -0.2, 0.7 }, { 3, 6, 0.45, 0.55 } }
		for _, sp in S do
			local t = T[sp[2]]
			local sz = math.min(sp[4], t.h * 1.6)
			-- an irregular blob: two overlapping tiles
			tile(sp[1], sp[2], sp[3], sz, math.min(sz, t.h + 0.2), spots, 0.1)
			tile(sp[1], sp[2], sp[3] + (if sp[3] > 0 then -0.18 else 0.18), sz * 0.6, math.min(sz, t.h + 0.2) * 0.6, spots, 0.12, (if sp[2] % 2 == 0 then 0.18 else -0.18))
		end
		for face = 0, 3 do
			for k = -1, 1 do
				add({ name = "Grass", class = "WedgePart", size = { 0.18, 0.45, 0.3 }, cf = CFrame.Angles(0, face * math.pi / 2 + k * 0.35, 0) * CFrame.new(k * 0.35, T[1].y + 0.05, -T[2].w / 2 - 0.05), color = { 110, 190, 80 } })
			end
		end
	elseif theme == "leaves" then
		-- forest: a zig-zag vine band, a little flower on the front, a crown of leaves on top
		for face = 0, 3 do
			for k = -2, 2 do
				local ti = if k % 2 == 0 then 4 else 5
				tile(face, ti, k * 0.42, 0.42, T[ti].h - 0.06, spots, 0.08)
			end
		end
		tile(0, 7, -0.3, 0.32, 0.32, { 255, 140, 190 }, 0.1)
		tile(0, 7, -0.3, 0.14, 0.14, { 255, 230, 90 }, 0.16)
		local top = T[#T].y + T[#T].h / 2
		for k = 0, 4 do
			local a = k * math.pi * 2 / 5
			add({ name = "TopLeaf", class = "WedgePart", size = { 0.14, 0.95, 0.7 }, cf = CFrame.new(math.sin(a) * 0.38, top + 0.32, -math.cos(a) * 0.38) * CFrame.Angles(0, -a, 0) * CFrame.Angles(math.rad(-45), 0, 0), color = if k % 2 == 0 then spots else shade(spots, 1.3) })
		end
	elseif theme == "rosettes" then
		-- safari: leopard rosettes - a dark ring with a warm centre
		local R = { { 0, 3, -0.4 }, { 0, 5, 0.35 }, { 0, 7, -0.25 }, { 1, 4, 0.3 }, { 1, 6, -0.4 }, { 2, 3, 0.2 }, { 2, 5, -0.35 }, { 2, 7, 0.3 }, { 3, 4, -0.3 }, { 3, 6, 0.4 } }
		for _, r in R do
			local t = T[r[2]]
			local sz = math.min(0.6, t.h + 0.15)
			tile(r[1], r[2], r[3], sz, sz, spots, 0.09)
			tile(r[1], r[2], r[3], sz * 0.5, sz * 0.5, { 225, 140, 50 }, 0.14)
		end
	elseif theme == "waves" then
		-- ocean: a white wave crest band, darker deep-water bottom, a starfish, bubbles
		for face = 0, 3 do
			for k = -3, 3 do
				local up = (k % 2 == 0)
				tile(face, 5, k * 0.36, 0.34, if up then 0.62 else 0.42, { 245, 252, 255 }, 0.08, if up then 0.08 else -0.02)
			end
			for k = -2, 2 do
				tile(face, 3, k * 0.45, 0.4, T[3].h - 0.08, shade(spots, 1), 0.07)
			end
			tile(face, 8, 0.35, 0.18, 0.18, { 210, 240, 255 }, 0.08, 0.05)
			tile(face, 9, -0.2, 0.14, 0.14, { 210, 240, 255 }, 0.08)
		end
		for k = 0, 4 do
			add({ name = "Star", size = { 0.14, 0.38, 0.08 }, cf = CFrame.new(-0.45, T[7].y, -T[7].w / 2 - 0.05) * CFrame.Angles(0, 0, math.rad(72 * k)) * CFrame.new(0, 0.15, 0), color = { 255, 140, 80 } })
		end
	elseif theme == "spikes" then
		-- dino: bony spikes out of both sides and a crest on top, dark stripes, pale belly
		for i = 3, #T - 1 do
			local t = T[i]
			local sz = 0.4 + 0.18 * math.sin(math.pi * (i - 3) / (#T - 4))
			for _, side in { -1, 1 } do
				add({ name = "Spike", class = "WedgePart", size = { 0.22, sz, sz }, cf = CFrame.new(side * (t.w / 2 + sz * 0.3), t.y + 0.05, 0.25) * CFrame.Angles(0, side * math.pi / 2, 0), color = { 250, 236, 200 } })
			end
		end
		local top = T[#T].y + T[#T].h / 2
		for k = -1, 1 do
			add({ name = "Crest", class = "WedgePart", size = { 0.2, 0.55 - math.abs(k) * 0.15, 0.5 }, cf = CFrame.new(k * 0.3, top + 0.2, 0) * CFrame.Angles(0, math.pi / 2, 0), color = { 250, 236, 200 } })
		end
		for face = 0, 3 do
			for k = -1, 1 do
				tile(face, 5 + (k + 1) % 2, k * 0.6, 0.24, 0.85, spots, 0.08)
			end
		end
		tile(0, 3, 0, 1.1, T[3].h - 0.05, shade(shell, 1.3), 0.06)
		tile(0, 4, 0, 1.3, T[4].h - 0.05, shade(shell, 1.3), 0.06)
	elseif theme == "royal" then
		-- mythic: a gold band with glowing gems, gold crown, star sparkles
		local band = 5
		for face = 0, 3 do
			tile(face, band, 0, T[band].w - 0.04, T[band].h - 0.04, spots, 0.07)
			tile(face, band, 0, 0.3, 0.3, C.Gem or { 90, 230, 255 }, 0.14, 0, { neon = true })
			tile(face, 8, (face % 2) * 0.5 - 0.25, 0.14, 0.14, { 255, 250, 210 }, 0.08, 0, { neon = true })
			tile(face, 3, 0.4 - (face % 2) * 0.8, 0.12, 0.12, { 255, 250, 210 }, 0.08, 0, { neon = true })
		end
		local top = T[#T].y + T[#T].h / 2
		for k = 0, 4 do
			local a = k * math.pi * 2 / 5
			add({ name = "Crown", class = "WedgePart", size = { 0.12, 0.42, 0.24 }, cf = CFrame.new(math.sin(a) * 0.36, top + 0.2, -math.cos(a) * 0.36) * CFrame.Angles(0, -a, 0), color = spots })
		end
		add({ name = "CrownGem", size = { 0.22, 0.22, 0.22 }, cf = CFrame.new(0, top + 0.15, 0), color = C.Gem or { 90, 230, 255 }, neon = true })
	end

	-- crack lines on the front (-Z, faces the camera): three connected zig-zags revealed one
	-- per shake. Neon so the rarity glow shines through them.
	local function faceZ(y)
		for _, t in T do
			if y <= t.y + t.h / 2 then
				return -t.w / 2
			end
		end
		return -T[#T].w / 2
	end
	local CRACKS = {
		{ { -0.95, 0.15 }, { -0.55, 0.45 }, { -0.2, 0.1 }, { 0.15, 0.4 } },
		{ { 0.15, 0.4 }, { 0.45, 0.05 }, { 0.8, 0.35 }, { 1.05, 0.05 } },
		{ { -0.2, 0.1 }, { -0.05, -0.3 }, { 0.3, -0.6 }, { 0.05, -0.95 } },
	}
	for ci, pts in CRACKS do
		for j = 1, #pts - 1 do
			local a, b = pts[j], pts[j + 1]
			local mx, my = (a[1] + b[1]) / 2, (a[2] + b[2]) / 2
			local len = math.sqrt((b[1] - a[1]) ^ 2 + (b[2] - a[2]) ^ 2) + 0.1
			local ang = math.atan2(b[2] - a[2], b[1] - a[1])
			table.insert(parts, { name = ("Crack%d_%d"):format(ci, j), size = { len, 0.12, 0.08 }, cf = CFrame.new(mx, my, faceZ(my) - 0.12) * CFrame.Angles(0, 0, ang), color = { 255, 250, 220 }, crack = ci, neon = true })
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
			part.Transparency = 1
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
			local visible = s.eggVisible and (not p.crack or p.crack <= s.cracks)
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
			if not p.crack or process.args[3] == "cracked" then
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
