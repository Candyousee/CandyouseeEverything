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

-- Egg shape: two overlapping ellipsoids (SpecialMesh spheres, built into Roblox - no uploads):
-- a wider body and a narrower, taller top, which together read as a real egg.
local BODY = { c = -0.05, rx = 1.36, ry = 1.78 } -- one smooth oval
local TOP = BODY
local EGG_H = (TOP.c + TOP.ry) - (BODY.c - BODY.ry)

-- point + outward normal on the shell at a yaw (0 = front, -Z) and height y
local function surface(yaw: number, y: number)
	local function rAt(e)
		local k = (y - e.c) / e.ry
		return if math.abs(k) < 1 then e.rx * math.sqrt(1 - k * k) else 0
	end
	local rb, rt = rAt(BODY), rAt(TOP)
	local e = if rb >= rt then BODY else TOP
	local r = math.max(rb, rt)
	local x, z = math.sin(yaw) * r, -math.cos(yaw) * r
	local n = Vector3.new(x / (e.rx * e.rx), (y - e.c) / (e.ry * e.ry), z / (e.rx * e.rx)).Unit
	return Vector3.new(x, y, z), n
end

-- a flat decoration lying on the shell (thin axis along the surface normal)
local function onShell(yaw: number, y: number, lift: number?, spin: number?)
	local p, n = surface(yaw, y)
	local up = if math.abs(n.Y) > 0.95 then Vector3.new(0, 0, -1) else Vector3.new(0, 1, 0)
	return CFrame.lookAt(p + n * (lift or 0), p + n * 2, up) * CFrame.Angles(0, 0, math.rad(spin or 0))
end

local function dark(c, k)
	return { math.floor(c[1] * k), math.floor(c[2] * k), math.floor(c[3] * k) }
end

-- part list in egg space: {name, size, cf, color, shape?, neon?, crack?, class?}
local function eggParts(egg: any)
	local C = egg.Colors
	local shell, spots = C.Shell, C.Spots
	local parts = {}
	local function add(p)
		table.insert(parts, p)
		return p
	end
	add({ name = "Body", size = { BODY.rx * 2, BODY.ry * 2, BODY.rx * 2 }, cf = CFrame.new(0, BODY.c, 0), color = shell, shape = "sphere" })
	local n = 0
	local function deco(name, size, cf, color, extra)
		n += 1
		-- a flat oval on a curved shell: sink it so its rim meets the surface (no floating edges)
		if not (extra and extra.raised) then
			-- rounded domes: thick enough to read as soft bumps at the silhouette, mostly sunk in
			local r = math.max(size[1], size[2]) / 2
			local sag = r * r / (2 * 1.4)
			local thick = math.max(size[3], 0.5 * r + 2 * sag)
			cf = cf * CFrame.new(0, 0, sag + thick * 0.22)
			size = { size[1], size[2], thick }
		end
		local p = { name = name .. n, size = size, cf = cf, color = color, shape = "sphere" }
		for k, v in extra or {} do
			p[k] = v
		end
		return add(p)
	end
	local theme = egg.Theme or "spots"
	local TAU = math.pi * 2
	if theme == "spots" then
		-- big cow spots, front-loaded so they read from the camera
		local S = { { -0.35, 0.55, 1.05 }, { 0.55, -0.35, 0.85 }, { -0.85, -0.8, 0.6 }, { 1.2, 0.85, 0.55 }, { 2.4, -0.1, 0.9 }, { 3.4, 0.7, 0.75 }, { 4.3, -0.6, 0.85 }, { 5.3, 0.3, 0.7 }, { 0.2, 1.45, 0.45 } }
		for _, sp in S do
			deco("Spot", { sp[3], sp[3] * 0.82, 0.16 }, onShell(sp[1], sp[2], -0.05, sp[1] * 37), spots)
		end
	elseif theme == "leaves" then
		-- two rings of flat leaves hugging the lower half, plus a sprout on top
		for k = 0, 11 do
			local yaw = TAU * k / 12
			deco("Leaf", { 0.6, 1.0, 0.1 }, onShell(yaw, -0.75, 0, if k % 2 == 0 then 18 else -18), if k % 2 == 0 then spots else dark(spots, 0.82))
		end
		for k = 0, 11 do
			deco("LeafHigh", { 0.5, 0.8, 0.1 }, onShell(TAU * (k + 0.5) / 12, -0.05, 0, if k % 2 == 0 then -18 else 18), dark(spots, 0.9))
		end
		local top = TOP.c + TOP.ry
		add({ name = "Stem", size = { 0.18, 0.55, 0.18 }, cf = CFrame.new(0, top + 0.15, 0) * CFrame.Angles(0, 0, math.rad(-10)), color = { 110, 80, 50 } })
		deco("SproutLeaf", { 0.8, 0.16, 0.42 }, CFrame.new(0.38, top + 0.42, 0) * CFrame.Angles(0, 0, math.rad(25)), spots)
		deco("SproutLeaf", { 0.65, 0.14, 0.36 }, CFrame.new(-0.32, top + 0.34, 0) * CFrame.Angles(0, 0, math.rad(-30)), spots)
	elseif theme == "rosettes" then
		-- leopard rosettes: dark ring, warm centre
		local R = { { -0.3, 0.6 }, { 0.45, 0.05 }, { -0.7, -0.45 }, { 0.15, -1.0 }, { 0.95, 0.95 }, { 1.4, -0.6 }, { 2.2, 0.4 }, { 2.9, -0.5 }, { 3.6, 0.7 }, { 4.3, -0.2 }, { 5.0, 0.8 }, { 5.6, -0.7 }, { -0.05, 1.45 } }
		for _, r in R do
			deco("Rosette", { 0.72, 0.62, 0.15 }, onShell(r[1], r[2], -0.05, r[1] * 50), spots)
			deco("RosetteMid", { 0.36, 0.3, 0.16 }, onShell(r[1], r[2], 0.1, r[1] * 50), { 230, 150, 55 }, { raised = true })
		end
	elseif theme == "waves" then
		-- a white scalloped wave band, a big starfish, bubbles
		for k = 0, 19 do
			local yaw = TAU * k / 20
			deco("Wave", { 0.62, 0.5, 0.14 }, onShell(yaw, -0.3 + 0.1 * math.sin(k * 1.3), -0.04), { 248, 252, 255 })
		end
		for k = 0, 19 do
			deco("DeepWave", { 0.62, 0.5, 0.14 }, onShell(TAU * (k + 0.5) / 20, -0.85, -0.04), spots)
		end
		for k = 0, 4 do
			deco("StarArm", { 0.24, 0.62, 0.12 }, onShell(0.35, 0.75, 0.0) * CFrame.Angles(0, 0, math.rad(72 * k)) * CFrame.new(0, 0.24, 0), { 255, 150, 90 })
		end
		for k = 0, 5 do
			local r = 0.22 + (k % 3) * 0.08
			deco("Bubble", { r, r, 0.12 }, onShell(-0.5 + k * 0.45, 1.0 + (k % 2) * 0.35, -0.02), { 225, 245, 255 })
		end
	elseif theme == "spikes" then
		-- a ridge of bony spikes up the side facing the camera, and tiger stripes
		for k = 0, 6 do
			local y = -1.0 + 0.45 * k
			local pt, nn = surface(math.rad(-80), math.min(y, TOP.c + TOP.ry - 0.1))
			local size = 0.45 + 0.15 * math.sin(math.pi * k / 6)
			add({ name = "Spike" .. k, class = "WedgePart", size = { 0.26, size, size }, cf = CFrame.lookAt(pt, pt + nn, Vector3.new(0, 1, 0)) * CFrame.Angles(math.rad(-90), 0, 0) * CFrame.new(0, size * 0.3, 0), color = { 250, 236, 200 } })
		end
		for k = 0, 11 do
			local yaw = TAU * k / 12 + 0.15
			deco("Stripe", { 0.3, 1.1, 0.14 }, onShell(yaw, 0.25 - (k % 2) * 0.55, -0.04, if k % 2 == 0 then 12 else -12), spots)
		end
	elseif theme == "royal" then
		-- a gold band with glowing gems, a gold crown, sparkles
		for k = 0, 23 do
			deco("Band", { 0.55, 0.5, 0.13 }, onShell(TAU * k / 24, -0.15, -0.04), spots)
		end
		for k = 0, 5 do
			deco("Gem", { 0.42, 0.5, 0.2 }, onShell(TAU * k / 6, -0.15, 0.03), C.Gem or { 90, 230, 255 }, { neon = true })
		end
		local top = TOP.c + TOP.ry
		add({ name = "CrownBase", size = { 0.25, 1.1, 1.1 }, cf = CFrame.new(0, top - 0.12, 0) * CFrame.Angles(0, 0, math.rad(90)), color = spots, shape = "cylinder" })
		for k = 0, 4 do
			local a = TAU * k / 5
			add({ name = "Crown" .. k, class = "WedgePart", size = { 0.14, 0.5, 0.32 }, cf = CFrame.new(math.sin(a) * 0.44, top + 0.2, -math.cos(a) * 0.44) * CFrame.Angles(0, -a, 0), color = spots })
		end
		for k = 0, 6 do
			deco("Sparkle", { 0.22, 0.22, 0.12 }, onShell(-1.2 + k * 0.45, 0.85 + (k % 2) * 0.4, -0.01), { 255, 250, 210 }, { neon = true })
		end
	end
	-- glossy highlight (front-left, upper), on every egg
	deco("Shine", { 0.38, 0.75, 0.1 }, onShell(-0.55, 0.85, 0.0, -20), { 255, 255, 255 }, { transparency = 0.35 })
	deco("ShineDot", { 0.18, 0.18, 0.1 }, onShell(-0.62, 0.28, 0.0), { 255, 255, 255 }, { transparency = 0.35 })
	-- crack lines on the front (-Z, faces the camera): three connected zig-zags, revealed
	-- one per shake. Neon so the rarity glow shines through them.
	local CRACKS = {
		{ { -0.75, 0.15 }, { -0.45, 0.4 }, { -0.15, 0.08 }, { 0.12, 0.38 } },
		{ { 0.12, 0.38 }, { 0.38, 0.05 }, { 0.62, 0.32 }, { 0.85, 0.02 } },
		{ { -0.15, 0.08 }, { -0.05, -0.32 }, { 0.22, -0.62 }, { 0.02, -0.95 } },
	}
	for ci, pts in CRACKS do
		for j = 1, #pts - 1 do
			local a, b = pts[j], pts[j + 1]
			-- yaw from the x offset across the front
			local function at(pt)
				local p = surface(math.asin(math.clamp(pt[1] / 1.35, -1, 1)), pt[2])
				return p
			end
			local pa, pb = at(a), at(b)
			local mid = (pa + pb) / 2
			local _, nrm = surface(math.asin(math.clamp((a[1] + b[1]) / 2 / 1.35, -1, 1)), (a[2] + b[2]) / 2)
			local len = (pb - pa).Magnitude + 0.08
			local dir = (pb - pa).Unit
			local right = dir
			local look = nrm
			local up = look:Cross(right).Unit
			local cf = CFrame.fromMatrix(mid + nrm * 0.03, right, up, -look)
			add({ name = ("Crack%d_%d"):format(ci, j), size = { len, 0.11, 0.08 }, cf = cf, color = { 255, 250, 220 }, crack = ci, neon = true })
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
	for _, p in eggParts(egg) do
		local part = Instance.new(p.class or "Part")
		part.Name = p.name
		part.Size = Vector3.new(p.size[1], p.size[2], p.size[3])
		part.CFrame = p.cf
		part.Color = Color3.fromRGB(p.color[1], p.color[2], p.color[3])
		part.Material = if p.neon then Enum.Material.Neon else Enum.Material.SmoothPlastic
		part.TopSurface = Enum.SurfaceType.Smooth
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
		table.insert(parts, { name = p.name, class = p.class or "Part", size = p.size, color = p.color, studs = false, neon = p.neon == true, shape = p.shape })
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
				table.insert(parts, { name = p.name, class = p.class or "Part", size = p.size, color = p.color, studs = false, neon = p.neon == true, shape = p.shape })
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
