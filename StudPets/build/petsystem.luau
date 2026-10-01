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

-- Egg shape: stacked tiers (bottom to top), {width, height}. Centre of the egg is y = 0.
local TIERS = { { 1.4, 0.4 }, { 2.2, 0.55 }, { 2.6, 0.75 }, { 2.7, 0.6 }, { 2.4, 0.55 }, { 1.9, 0.45 }, { 1.2, 0.35 } }
local EGG_H = 0
for _, t in TIERS do
	EGG_H += t[2]
end

-- part list in egg space: {name, size, cf, color, studs, crack index}
local function eggParts(colors)
	local parts = {}
	local y = -EGG_H / 2
	local tierY = {}
	for i, t in TIERS do
		local cy = y + t[2] / 2
		tierY[i] = cy
		table.insert(parts, { name = "Tier" .. i, size = { t[1], t[2], t[1] }, cf = CFrame.new(0, cy, 0), color = colors.Shell, studs = i == #TIERS })
		y += t[2]
	end
	-- spots on the four sides of the wide tiers
	local spotN = 0
	local SPOTS = { { 3, -0.5, 0.05 }, { 4, 0.55, 0 }, { 2, 0.25, 0 }, { 5, -0.35, 0 } }
	for face = 0, 3 do
		local yaw = face * math.pi / 2 + 0.4
		for k, s in SPOTS do
			if (k + face) % 2 == 0 then
				local t = TIERS[s[1]]
				local half = t[1] / 2
				local sz = 0.55 - (k % 2) * 0.12
				spotN += 1
				local c = CFrame.Angles(0, face * math.pi / 2, 0) * CFrame.new(s[2] * half * 0.8, tierY[s[1]] + s[3], -half - 0.03)
				table.insert(parts, { name = "Spot" .. spotN, size = { sz, math.min(sz, t[2] - 0.08), 0.08 }, cf = c, color = colors.Spots })
			end
		end
	end
	-- crack lines on the front (-Z, faces the camera): three connected zig-zags, revealed
	-- one per shake. They're neon so the rarity glow can shine through them.
	local function faceZ(y)
		-- front face depth of the tier at height y
		local yy = -EGG_H / 2
		for _, t in TIERS do
			if y <= yy + t[2] then
				return -t[1] / 2
			end
			yy += t[2]
		end
		return -TIERS[#TIERS][1] / 2
	end
	local CRACKS = {
		{ { -0.95, 0.05 }, { -0.55, 0.35 }, { -0.2, 0.0 }, { 0.15, 0.3 } },
		{ { 0.15, 0.3 }, { 0.45, -0.05 }, { 0.8, 0.25 }, { 1.05, -0.05 } },
		{ { -0.2, 0.0 }, { -0.05, -0.4 }, { 0.3, -0.7 }, { 0.05, -1.0 } },
	}
	for ci, pts in CRACKS do
		for j = 1, #pts - 1 do
			local a, b = pts[j], pts[j + 1]
			local mx, my = (a[1] + b[1]) / 2, (a[2] + b[2]) / 2
			local len = math.sqrt((b[1] - a[1]) ^ 2 + (b[2] - a[2]) ^ 2) + 0.1
			local ang = math.atan2(b[2] - a[2], b[1] - a[1])
			table.insert(parts, {
				name = ("Crack%d_%d"):format(ci, j),
				size = { len, 0.12, 0.06 },
				cf = CFrame.new(mx, my, faceZ(my) - 0.04) * CFrame.Angles(0, 0, ang),
				color = { 255, 250, 220 },
				crack = ci,
				neon = true,
			})
		end
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
	for _, p in eggParts(egg.Colors) do
		local part = Instance.new("Part")
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
	block("Base", Vector3.new(7, 1, 7), cf * CFrame.new(0, 0.5, 0), { 99, 95, 98 }, true).Parent = stand
	block("Top", Vector3.new(5, 1, 5), cf * CFrame.new(0, 1.5, 0), Config.Rarities[math.min(i, #Config.Rarities)].Color, true).Parent = stand
	local e = eggModels[egg.Name]:Clone()
	e.Name = "Egg"
	-- (Lune has no PivotTo/ScaleTo: place and scale the parts by hand)
	local SCALE = 1.4
	local at = cf * CFrame.new(0, 2 + EGG_H / 2 * SCALE, 0) * CFrame.Angles(0, math.pi, 0)
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
	local ep = eggParts(egg.Colors)
	local parts, frames = {}, {}
	for _, p in ep do
		table.insert(parts, { name = p.name, class = "Part", size = p.size, color = p.color, studs = p.studs == true, neon = p.neon == true })
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
