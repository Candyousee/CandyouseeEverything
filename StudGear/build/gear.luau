-- Builds the Stud Gear assets (run from the StudGear folder):
--   lune run build/gear.luau           -> assets/tools/*.rbxm, assets/StudGearDemo.rbxm
--   lune run build/gear.luau preview F -> also the coils + displays as render JSON (Blender)

local fs = require("@lune/fs")
local process = require("@lune/process")
local roblox = require("@lune/roblox")
local serde = require("@lune/serde")
local Instance, CFrame, Vector3, Color3, Enum = roblox.Instance, roblox.CFrame, roblox.Vector3, roblox.Color3, roblox.Enum

local Config = require("../src/shared/StudGear/Config")

local function rgb(t)
	return Color3.fromRGB(t[1], t[2], t[3])
end
local function lighten(t, k)
	return { t[1] + (255 - t[1]) * k, t[2] + (255 - t[2]) * k, t[3] + (255 - t[3]) * k }
end
local function hsv(h, s, v)
	local c = Color3.fromHSV(h % 1, s, v)
	return { math.round(c.R * 255), math.round(c.G * 255), math.round(c.B * 255) }
end

-- A classic coil in handle space: a rubber grip in your fist, a smooth shiny spring standing
-- straight up out of it (+Y is up once the tool's Grip is applied).
-- {name, size, cf, color, neon?, shape?, shine?}
local function coilParts(gear)
	local parts = {}
	local function add(name, size, cf, color, extra)
		local p = { name = name, size = size, cf = cf, color = color }
		for k, v in extra or {} do
			p[k] = v
		end
		table.insert(parts, p)
	end
	local UP = CFrame.Angles(0, 0, math.rad(90)) -- a cylinder's axis is X: turn it upright
	local grip, metal = { 52, 54, 64 }, { 175, 180, 190 }
	local accent = gear.Accent or gear.Color
	add("Grip", { 1.1, 0.42, 0.42 }, CFrame.new(0, 0, 0) * UP, grip, { shape = "cylinder" })
	for k = -1, 1 do
		add("GripRing" .. k, { 0.1, 0.46, 0.46 }, CFrame.new(0, k * 0.3, 0) * UP, { 35, 36, 44 }, { shape = "cylinder" })
	end
	add("Pommel", { 0.14, 0.5, 0.5 }, CFrame.new(0, -0.6, 0) * UP, metal, { shape = "cylinder", shine = true })
	add("Base", { 0.18, 1.06, 1.06 }, CFrame.new(0, 0.62, 0) * UP, metal, { shape = "cylinder", shine = true })
	-- the spring: a round tube following a helix, from short cylinder segments
	local TURNS, PER, R, TUBE = 6, 18, 0.43, 0.17
	local y0, y1 = 0.78, 3.05
	local n = TURNS * PER
	local rise = (y1 - y0) / n
	local step = 2 * math.pi * R / PER
	local pitch = math.atan2(rise, step)
	local len = math.sqrt(step * step + rise * rise) * 1.12
	for i = 0, n - 1 do
		local a = (i + 0.5) / PER * 2 * math.pi
		local y = y0 + (i + 0.5) * rise
		local color = gear.Color
		if gear.Rainbow then
			color = hsv(i / n, 0.8, 1)
		elseif gear.Name == "Fusion Coil" then
			color = if math.floor(i / PER) % 2 == 0 then gear.Color else accent
		end
		-- segment axis (X) along the helix tangent
		local cf = CFrame.new(R * math.cos(a), y, R * math.sin(a)) * CFrame.Angles(0, -a - math.pi / 2, 0) * CFrame.Angles(0, 0, pitch)
		add("Spring" .. i, { len, TUBE, TUBE }, cf, color, { shape = "cylinder", shine = true })
	end
	add("Top", { 0.16, 1.0, 1.0 }, CFrame.new(0, y1 + 0.12, 0) * UP, metal, { shape = "cylinder", shine = true })
	add("Tip", { 0.34, 0.34, 0.34 }, CFrame.new(0, y1 + 0.32, 0), if gear.Rainbow then { 255, 255, 255 } else accent, { shape = "ball", neon = true })
	return parts
end

-- shared little builder for the other looks
local function parts()
	local list = {}
	local function add(name, size, cf, color, extra)
		local p = { name = name, size = size, cf = cf, color = color }
		for k, v in extra or {} do
			p[k] = v
		end
		table.insert(list, p)
		return p
	end
	return list, add
end

-- A classic balloon: a shiny round balloon high over your hand on a string.
local function balloonParts(gear)
	local list, add = parts()
	add("Grip", { 0.3, 0.3, 0.3 }, CFrame.new(0, 0, 0), { 245, 245, 245 }, { shape = "ball" })
	add("String", { 3.4, 0.06, 0.06 }, CFrame.new(0, 1.75, 0) * CFrame.Angles(0, 0, math.rad(90)), { 245, 245, 245 }, { shape = "cylinder" })
	add("Knot", { 0.3, 0.3, 0.3 }, CFrame.new(0, 3.5, 0), gear.Color, { shape = "ball" })
	add("Balloon", { 2.3, 2.7, 2.3 }, CFrame.new(0, 4.95, 0), gear.Color, { shape = "sphere", shine = true })
	add("Shine", { 0.45, 0.7, 0.3 }, CFrame.new(-0.55, 5.55, -0.95) * CFrame.Angles(0, math.rad(-30), math.rad(-25)), lighten(gear.Color, 0.7), { shape = "sphere" })
	return list
end

-- Jetpack: nothing in your hand (an invisible handle); the pack itself is worn (jetpackWear).
local function jetpackParts(_gear)
	local list, add = parts()
	add("Grip", { 0.2, 0.2, 0.2 }, CFrame.new(0, 0, 0), { 46, 48, 62 }, { invisible = true })
	return list
end

-- The pack on your back. WearRoot sits on the middle of the back; +Z points away from you.
local function jetpackWear(gear)
	local list, add = parts()
	local dark, metal = { 46, 48, 62 }, gear.Color
	add("WearRoot", { 0.2, 0.2, 0.2 }, CFrame.new(0, 0, 0), dark, { invisible = true })
	add("Plate", { 1.7, 1.8, 0.3 }, CFrame.new(0, 0, 0.18), dark)
	for side = -1, 1, 2 do
		local x = side * 0.48
		local vertical = CFrame.Angles(0, 0, math.rad(90))
		add("Tank" .. side, { 1.9, 0.8, 0.8 }, CFrame.new(x, 0.05, 0.72) * vertical, metal, { shape = "cylinder", shine = true })
		add("Band" .. side, { 0.22, 0.86, 0.86 }, CFrame.new(x, 0.45, 0.72) * vertical, gear.Accent, { shape = "cylinder" })
		add("Dome" .. side, { 0.8, 0.8, 0.8 }, CFrame.new(x, 1.0, 0.72), metal, { shape = "ball", shine = true })
		add("Fin" .. side, { 0.12, 0.9, 0.55 }, CFrame.new(x + side * 0.46, -0.55, 0.72), gear.Accent)
		local nozzle = add("Nozzle" .. side, { 0.4, 0.55, 0.55 }, CFrame.new(x, -1.08, 0.72) * vertical, dark, { shape = "cylinder" })
		nozzle.flame = true
	end
	return list
end

-- Grapple gun: grip in your hand, barrel pointing forward (-Z), hook at the front.
local function grappleParts(gear)
	local list, add = parts()
	local dark = { 46, 48, 62 }
	add("Grip", { 0.42, 1.0, 0.55 }, CFrame.new(0, 0, 0), dark)
	add("Body", { 0.62, 0.62, 1.7 }, CFrame.new(0, 0.78, -0.45), gear.Color)
	add("Reel", { 0.5, 0.75, 0.75 }, CFrame.new(0, 0.78, 0.3), gear.Accent, { shape = "cylinder" })
	add("Barrel", { 1.1, 0.42, 0.42 }, CFrame.new(0, 0.82, -1.75) * CFrame.Angles(0, math.rad(90), 0), dark, { shape = "cylinder" })
	local hook = add("Hook", { 0.3, 0.3, 0.3 }, CFrame.new(0, 0.82, -2.42), gear.Accent, { neon = true })
	hook.muzzle = true
	for k = 0, 2 do
		local a = k / 3 * 2 * math.pi
		add("Claw" .. k, { 0.12, 0.12, 0.42 }, CFrame.new(math.cos(a) * 0.22, 0.82 + math.sin(a) * 0.22, -2.52) * CFrame.Angles(math.sin(a) * 0.6, -math.cos(a) * 0.6, 0), gear.Accent)
	end
	return list
end

local function gearParts(gear)
	local look = gear.Look or "coil"
	if look == "balloon" then
		return balloonParts(gear)
	elseif look == "jetpack" then
		return jetpackParts(gear)
	elseif look == "grapple" then
		return grappleParts(gear)
	end
	return coilParts(gear)
end

-- what the display stand shows, and how big / how high off the stand
local function displayParts(gear)
	local look = gear.Look or "coil"
	if look == "jetpack" then
		return jetpackWear(gear), 1.25, 1.4
	elseif look == "balloon" then
		return balloonParts(gear), 0.95, 0.4
	elseif look == "grapple" then
		return grappleParts(gear), 1.5, 0.6
	end
	return coilParts(gear), 1.7, 0.5
end

local function makePart(p, anchored)
	local part = Instance.new("Part")
	part.Name = p.name
	part.Size = Vector3.new(p.size[1], p.size[2], p.size[3])
	part.CFrame = p.cf
	part.Color = rgb(p.color)
	part.Material = if p.neon then Enum.Material.Neon else Enum.Material.SmoothPlastic
	part.TopSurface = Enum.SurfaceType.Smooth
	part.BottomSurface = Enum.SurfaceType.Smooth
	part.Anchored = anchored
	part.CanCollide = false
	part.CanTouch = false
	part.CanQuery = false
	part.Massless = not anchored
	part.CastShadow = true
	if p.shape == "cylinder" then
		part.Shape = Enum.PartType.Cylinder
	elseif p.shape == "ball" then
		part.Shape = Enum.PartType.Ball
	elseif p.shape == "sphere" then
		local mesh = Instance.new("SpecialMesh") -- a ball stretched to fill the part's box
		mesh.MeshType = Enum.MeshType.Sphere
		mesh.Parent = part
	end
	if p.shine then
		part.Reflectance = 0.18
	end
	if p.invisible then
		part.Transparency = 1
	end
	if p.muzzle then
		local a = Instance.new("Attachment")
		a.Name = "Muzzle"
		a.Parent = part
	end
	return part
end

local function makeTool(gear)
	local tool = Instance.new("Tool")
	tool.Name = gear.Name
	tool.RequiresHandle = true
	tool.CanBeDropped = false
	tool.ManualActivationOnly = gear.Grapple == nil -- only the grapple uses clicks
	-- built with +Y up and -Z forward; this Grip makes the hand hold it that way round
	tool.Grip = CFrame.Angles(math.pi, 0, 0)
	local bits = {}
	if gear.Speed then
		table.insert(bits, ("%d%% faster"):format(math.round((gear.Speed - 1) * 100)))
	end
	if gear.Gravity then
		table.insert(bits, "low gravity")
	end
	if gear.Jump then
		table.insert(bits, ("%d%% higher jumps"):format(math.round((gear.Jump - 1) * 100)))
	end
	if gear.AirJumps then
		table.insert(bits, if gear.AirJumps == 1 then "jump again in mid-air" else ("%d mid-air jumps"):format(gear.AirJumps))
	end
	if gear.MaxFall then
		table.insert(bits, "float down slowly")
	end
	if gear.Regen then
		table.insert(bits, ("heals %d HP/s"):format(gear.Regen))
	end
	if gear.Jetpack then
		table.insert(bits, "hold Jump to fly")
	end
	if gear.Grapple then
		table.insert(bits, "click a surface to swing to it")
	end
	tool.ToolTip = table.concat(bits, ", ")
	tool:SetAttribute("StudGear", gear.Name)
	local handle
	for _, p in gearParts(gear) do
		local part = makePart(p, false)
		if p.name == "Grip" then
			part.Name = "Handle"
			part.Massless = false -- a tool needs a little mass in its handle
			part.CanTouch = true -- lets a dropped tool be picked back up
			handle = part
		end
		part.Parent = tool
	end
	for _, part in tool:GetChildren() do
		if part ~= handle then
			local w = Instance.new("WeldConstraint")
			w.Part0 = handle
			w.Part1 = part
			w.Parent = part
		end
	end
	return tool
end

-- worn models (the jetpack's pack), with flames the scripts switch on while flying
local function makeWear(gear)
	local model = Instance.new("Model")
	model.Name = gear.Name
	local root
	for _, p in jetpackWear(gear) do
		local part = makePart(p, false)
		part.Parent = model
		if p.name == "WearRoot" then
			root = part
		end
		if p.flame then
			local at = Instance.new("Attachment")
			at.Name = "Flame"
			at.Position = Vector3.new(-0.3, 0, 0) -- the cylinder's axis is X: -X is its bottom
			at.Orientation = Vector3.new(0, 0, 90)
			at.Parent = part
			local fire = Instance.new("ParticleEmitter")
			fire.Name = "Flame"
			fire.Texture = "rbxasset://textures/particles/fire_main.dds"
			fire.Enabled = false
			fire.Rate = 70
			fire.Lifetime = roblox.NumberRange.new(0.18, 0.32)
			fire.Speed = roblox.NumberRange.new(10, 14)
			fire.SpreadAngle = roblox.Vector2.new(8, 8)
			fire.LightEmission = 1
			fire.EmissionDirection = Enum.NormalId.Bottom
			fire.Size = roblox.NumberSequence.new({ roblox.NumberSequenceKeypoint.new(0, 0.55), roblox.NumberSequenceKeypoint.new(1, 0.1) })
			fire.Color = roblox.ColorSequence.new(Color3.fromRGB(255, 230, 120), Color3.fromRGB(255, 90, 30))
			fire.Parent = at
			local light = Instance.new("PointLight")
			light.Name = "Glow"
			light.Enabled = false
			light.Color = Color3.fromRGB(255, 150, 60)
			light.Range = 8
			light.Brightness = 2
			light.Parent = at
		end
	end
	for _, part in model:GetChildren() do
		if part ~= root then
			local w = Instance.new("WeldConstraint")
			w.Part0 = root
			w.Part1 = part
			w.Parent = part
		end
	end
	model.PrimaryPart = root
	return model
end

for _, dir in { "assets/tools", "assets/wearables" } do
	if fs.isDir(dir) then
		fs.removeDir(dir)
	end
	fs.writeDir(dir)
end
local tools = {}
for _, gear in Config.Gear do
	local t = makeTool(gear)
	tools[gear.Name] = t
	fs.writeFile(`assets/tools/{gear.Name}.rbxm`, roblox.serializeModel({ t }))
	if gear.Jetpack then
		fs.writeFile(`assets/wearables/{gear.Name}.rbxm`, roblox.serializeModel({ makeWear(gear) }))
	end
end

---------------------------------------------------------------------------
-- Demo world: floor, spawn, a display stand per gear, and a test course
---------------------------------------------------------------------------
local function block(name, size, cf, color, studs, material)
	local p = Instance.new("Part")
	p.Name = name
	p.Size = size
	p.CFrame = cf
	p.Color = rgb(color)
	p.Material = material or Enum.Material.Plastic
	p.TopSurface = if studs then Enum.SurfaceType.Studs else Enum.SurfaceType.Smooth
	p.BottomSurface = Enum.SurfaceType.Smooth
	p.Anchored = true
	return p
end

local function sign(parent, text, cf, color)
	local board = block("Sign", Vector3.new(10, 3, 0.4), cf, { 40, 42, 60 }, false, Enum.Material.SmoothPlastic)
	local gui = Instance.new("SurfaceGui")
	gui.Face = Enum.NormalId.Back -- faces the spawn (+Z)
	gui.PixelsPerStud = 40
	gui.LightInfluence = 0
	local l = Instance.new("TextLabel")
	l.BackgroundTransparency = 1
	l.Size = roblox.UDim2.fromScale(1, 1)
	l.FontFace = roblox.Font.new("rbxasset://fonts/families/FredokaOne.json")
	l.TextScaled = true
	l.TextColor3 = rgb(color)
	l.Text = text
	l.Parent = gui
	gui.Parent = board
	board.Parent = parent
	local pos = cf.Position
	block("SignPost", Vector3.new(0.6, pos.Y - 1.5, 0.6), CFrame.new(pos.X, (pos.Y - 1.5) / 2, pos.Z - 0.4), { 90, 70, 50 }, false).Parent = parent
	return board
end

local demo = Instance.new("Folder")
demo.Name = "StudGearDemo"
block("Floor", Vector3.new(220, 1, 220), CFrame.new(0, -0.5, 0), { 75, 151, 75 }, true).Parent = demo
local spawn = Instance.new("SpawnLocation")
spawn.Name = "Spawn"
spawn.Size = Vector3.new(8, 1, 8)
spawn.CFrame = CFrame.new(0, 0.5, 24)
spawn.Anchored = true
spawn.Neutral = true
spawn.Duration = 0
spawn.TopSurface = Enum.SurfaceType.Studs
spawn.Parent = demo

local displays = Instance.new("Folder")
displays.Name = "GearDisplays"
displays.Parent = demo
local n = #Config.Gear
local displayData = {}
for i, gear in Config.Gear do
	-- two rows of five, facing the spawn (+Z)
	local row, col = math.floor((i - 1) / 5), (i - 1) % 5
	local perRow = math.min(5, n - row * 5)
	local x = (col - (perRow - 1) / 2) * 10
	local cf = CFrame.new(x, 0, 4 - row * 11) * CFrame.Angles(0, math.pi, 0)
	local stand = Instance.new("Model")
	stand.Name = gear.Name
	local function disc(name, d, h, y, color, neon)
		local p = block(name, Vector3.new(h, d, d), cf * CFrame.new(0, y, 0) * CFrame.Angles(0, 0, math.rad(90)), color, false, if neon then Enum.Material.Neon else Enum.Material.SmoothPlastic)
		p.Shape = Enum.PartType.Cylinder
		return p
	end
	disc("Base", 6.4, 1, 0.5, { 88, 86, 96 }).Parent = stand
	disc("Rim", 5.8, 0.3, 1.1, if gear.Rainbow then { 255, 255, 255 } else gear.Color, true).Parent = stand
	local top = disc("Top", 5.4, 0.5, 1.35, { 52, 54, 76 })
	top.Parent = stand
	-- the coil, bigger, floating over the stand (the client spins it)
	local coil = Instance.new("Model")
	coil.Name = "Coil"
	local shown, SCALE, lift = displayParts(gear)
	local at = cf * CFrame.new(0, 2.3 + lift * SCALE, 0)
	local pivot = block("Pivot", Vector3.new(0.2, 0.2, 0.2), at, { 0, 0, 0 }, false)
	pivot.Transparency = 1
	pivot.CanCollide = false
	pivot.Parent = coil
	local list = {}
	for _, p in shown do
		if p.invisible then
			continue
		end
		local c = p.cf
		local q = table.clone(p)
		q.cf = at * CFrame.new(c.Position * SCALE) * (c - c.Position)
		q.size = { p.size[1] * SCALE, p.size[2] * SCALE, p.size[3] * SCALE }
		makePart(q, true).Parent = coil
		table.insert(list, q)
	end
	coil.PrimaryPart = pivot
	coil.Parent = stand
	stand.PrimaryPart = top
	stand:SetAttribute("StudGearDisplay", gear.Name)
	stand.ModelStreamingMode = Enum.ModelStreamingMode.Atomic
	stand:AddTag("StudGearDisplay")
	stand.Parent = displays
	table.insert(displayData, { name = gear.Name, parts = list, stand = stand })
end

-- test course behind the stands: one challenge per effect
local course = Instance.new("Folder")
course.Name = "TestCourse"
course.Parent = demo
local GREY, WOOD = { 163, 162, 165 }, { 200, 160, 110 }
-- SPEED: a gap you can only clear running fast (normal jump carries ~8 studs, Speed Coil ~14)
sign(course, "SPEED COIL: clear the gap", CFrame.new(-23, 4.5, -4), { 255, 120, 120 })
block("SpeedStart", Vector3.new(10, 6, 24), CFrame.new(-34, 3, -24), GREY, true).Parent = course
block("SpeedRamp", Vector3.new(10, 1, 12), CFrame.new(-34, 2.6, -6.5) * CFrame.Angles(math.rad(27), 0, 0), GREY, true).Parent = course
block("SpeedLand", Vector3.new(10, 6, 14), CFrame.new(-34, 3, -55), GREY, true).Parent = course
block("SpeedGoal", Vector3.new(4, 0.4, 4), CFrame.new(-34, 6.2, -58), { 255, 90, 90 }, false, Enum.Material.Neon).Parent = course
-- JUMP: steps 10 studs apart in height (normal jump ~7, Jump Coil ~13)
sign(course, "JUMP / DOUBLE JUMP: climb the steps", CFrame.new(0, 4.5, -12), { 120, 255, 140 })
for k = 1, 4 do
	block("Step" .. k, Vector3.new(8, 10 * k, 8), CFrame.new(-6 + 4 * k, 5 * k, -16 - 8 * k), WOOD, true).Parent = course
end
block("JumpGoal", Vector3.new(4, 0.4, 4), CFrame.new(10, 40.2, -48), { 90, 255, 120 }, false, Enum.Material.Neon).Parent = course
-- GRAVITY: a pillar too tall for anything but low gravity (~21 studs with the Gravity Coil)
sign(course, "GRAVITY COIL: reach the top", CFrame.new(34, 4.5, -12), { 170, 140, 255 })
block("GravityPillar", Vector3.new(10, 18, 10), CFrame.new(34, 9, -24), WOOD, true).Parent = course
block("GravityGoal", Vector3.new(4, 0.4, 4), CFrame.new(34, 18.2, -24), { 160, 110, 255 }, false, Enum.Material.Neon).Parent = course
-- BALLOON: float off the top step to a platform far below (falling normally covers ~9 studs)
sign(course, "BALLOON: float from the top step to the far platform", CFrame.new(20, 4.5, -30), { 255, 130, 140 })
block("BalloonLand", Vector3.new(16, 12, 16), CFrame.new(10, 6, -96), GREY, true).Parent = course
block("BalloonGoal", Vector3.new(4, 0.4, 4), CFrame.new(10, 12.2, -96), { 255, 90, 110 }, false, Enum.Material.Neon).Parent = course
-- JETPACK / GRAPPLE: a floating island 34 studs up
sign(course, "JETPACK or GRAPPLE HOOK: reach the sky island", CFrame.new(-46, 4.5, -40), { 255, 200, 90 })
block("SkyIsland", Vector3.new(16, 1.5, 16), CFrame.new(-34, 34, -96), WOOD, true).Parent = course
block("SkyGoal", Vector3.new(4, 0.4, 4), CFrame.new(-34, 34.95, -96), { 255, 200, 60 }, false, Enum.Material.Neon).Parent = course
-- leave room in front for the two rows of stands
for _, d in course:GetDescendants() do
	if d:IsA("BasePart") then
		d.CFrame = CFrame.new(0, 0, -12) * d.CFrame
	end
end

fs.writeFile("assets/StudGearDemo.rbxm", roblox.serializeModel({ demo }))
print(("[gear] %d tools -> assets/tools, demo world -> assets/StudGearDemo.rbxm"):format(n))

-- render data: each coil in tool space, and the whole demo world as placed
if process.args[1] == "preview" then
	local function out(p, cf)
		local comps = { cf:GetComponents() }
		return { name = p.name, class = "Part", size = p.size, color = p.color, neon = p.neon == true, studs = false, shape = p.shape, frame = comps }
	end
	local data = { coils = {}, world = {} }
	for _, gear in Config.Gear do
		local list = {}
		for _, p in gearParts(gear) do
			table.insert(list, out(p, p.cf))
		end
		data.coils[gear.Name] = list
		if gear.Jetpack then
			local wear = {}
			for _, p in jetpackWear(gear) do
				if not p.invisible then
					table.insert(wear, out(p, p.cf))
				end
			end
			data.coils[gear.Name .. " (worn)"] = wear
		end
	end
	for _, d in demo:GetDescendants() do
		if d:IsA("BasePart") and d.Transparency < 1 then
			local shape = if d:IsA("Part") and d.Shape == Enum.PartType.Cylinder then "cylinder" else nil
			table.insert(data.world, {
				name = d.Name,
				class = d.ClassName,
				size = { d.Size.X, d.Size.Y, d.Size.Z },
				color = { math.round(d.Color.R * 255), math.round(d.Color.G * 255), math.round(d.Color.B * 255) },
				neon = d.Material == Enum.Material.Neon,
				studs = false,
				shape = shape,
				frame = { d.CFrame:GetComponents() },
			})
		end
	end
	fs.writeFile(process.args[2], serde.encode("json", data))
	print("[gear] preview data -> " .. process.args[2])
end
