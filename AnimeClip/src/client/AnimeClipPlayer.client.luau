-- Anime clip (client): plays the 10-second duel on your screen, framed for a vertical
-- TikTok (9:16). Press R to replay, F to show / hide the frame guides.
--
-- Everything comes from ReplicatedStorage.AnimeClip.Timeline (the same maths the preview
-- video was rendered from): the fighters' joint rotations, the camera, every effect.

local Lighting = game:GetService("Lighting")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local System = ReplicatedStorage:WaitForChild("AnimeClip")
local Config = require(System:WaitForChild("Config"))
local CF = require(System:WaitForChild("CF"))
local Rig = require(System:WaitForChild("Rig"))
local Props = require(System:WaitForChild("Props"))
local T = require(System:WaitForChild("Timeline"))

local player = Players.LocalPlayer
-- a clean screen for recording: no chat, player list or backpack
pcall(function()
	game:GetService("StarterGui"):SetCoreGuiEnabled(Enum.CoreGuiType.All, false)
end)
local camera = workspace.CurrentCamera

local function toCF(c)
	return CFrame.new(c[1], c[2], c[3], c[4], c[5], c[6], c[7], c[8], c[9], c[10], c[11], c[12])
end
local function fromCF(cf: CFrame)
	return { cf:GetComponents() }
end
local function rgb(c)
	return Color3.fromRGB(math.clamp(c[1], 0, 255), math.clamp(c[2], 0, 255), math.clamp(c[3], 0, 255))
end

---------------------------------------------------------------------------
-- Fighters: local copies of the avatars the server built
---------------------------------------------------------------------------
local actorsFolder = workspace:WaitForChild("AnimeClipActors"):WaitForChild(tostring(player.UserId))
local localFolder = Instance.new("Folder")
localFolder.Name = "AnimeClipLocal"
localFolder.Parent = workspace

type Fighter = {
	model: Model,
	root: BasePart,
	motors: { [string]: Motor6D },
	desc: any,
	stand: number,
	world: { [string]: any }?,
	gear: { parts: { BasePart }, local_: { any }, sheath: { BasePart }, sheathLocal: { any } },
	highlight: Highlight,
}
local fighters: { [string]: Fighter } = {}

local function buildGear(name: string, style: string)
	local folder = Instance.new("Model") -- (a Model, so a Highlight can cover it on impact frames)
	folder.Name = name .. "Gear"
	folder.Parent = localFolder
	local function make(list)
		local parts, locals = {}, {}
		for _, p in list do
			local part = Instance.new("Part")
			part.Anchored = true
			part.CanCollide = false
			part.CanQuery = false
			part.CanTouch = false
			part.CastShadow = false
			part.Size = Vector3.new(p.size[1], p.size[2], p.size[3])
			part.Color = rgb(p.color)
			part.Material = if p.neon then Enum.Material.Neon else Enum.Material.SmoothPlastic
			part.Reflectance = if p.shine then 0.15 else 0
			if p.shape == "cyl" then
				part.Shape = Enum.PartType.Cylinder
			end
			part:SetAttribute("Blade", p.tag == "blade")
			part.Parent = folder
			table.insert(parts, part)
			table.insert(locals, p)
		end
		return parts, locals
	end
	local parts, locals = make(Props.Katana(style))
	local sheath, sheathLocal = {}, {}
	if name == "hero" then
		sheath, sheathLocal = make(Props.Sheath())
	end
	return { parts = parts, local_ = locals, sheath = sheath, sheathLocal = sheathLocal, folder = folder }
end

local function setupFighter(name: string, source: Model, style: string): Fighter
	local model = source:Clone()
	model.Parent = localFolder
	local root = model:WaitForChild("HumanoidRootPart") :: BasePart
	root.Anchored = true
	local humanoid = model:FindFirstChildOfClass("Humanoid")
	if humanoid then
		-- nothing else may move the joints
		local animator = humanoid:FindFirstChildOfClass("Animator")
		if animator then
			animator:Destroy()
		end
	end
	local motors = {}
	local list = {}
	local sizes = {}
	for _, d in model:GetDescendants() do
		if d:IsA("Motor6D") and d.Part0 and d.Part1 then
			motors[d.Name] = d
		elseif d:IsA("BasePart") then
			sizes[d.Name] = { d.Size.X, d.Size.Y, d.Size.Z }
		end
	end
	for _, j in Rig.JOINTS do
		local m = motors[j.name]
		if m then
			table.insert(list, { name = j.name, part0 = (m.Part0 :: BasePart).Name, part1 = (m.Part1 :: BasePart).Name, c0 = fromCF(m.C0), c1 = fromCF(m.C1) })
		end
	end
	local desc = Rig.Describe(list, sizes)
	local highlight = Instance.new("Highlight")
	highlight.Enabled = false
	highlight.FillTransparency = 0
	highlight.OutlineTransparency = 1
	highlight.DepthMode = Enum.HighlightDepthMode.Occluded
	highlight.Adornee = model
	highlight.Parent = model
	return {
		model = model,
		root = root,
		motors = motors,
		desc = desc,
		stand = Rig.StandHeight(desc),
		gear = buildGear(name, style),
		highlight = highlight,
	}
end

fighters.hero = setupFighter("hero", actorsFolder:WaitForChild("Hero") :: Model, "hero")
fighters.rival = setupFighter("rival", actorsFolder:WaitForChild("Rival") :: Model, "rival")
for _, f in fighters do
	local h = Instance.new("Highlight")
	h.Enabled = false
	h.FillTransparency = 0
	h.OutlineTransparency = 1
	h.DepthMode = Enum.HighlightDepthMode.Occluded
	h.Adornee = (f.gear :: any).folder
	h.Parent = (f.gear :: any).folder
	;(f.gear :: any).highlight = h
end

---------------------------------------------------------------------------
-- Effects: a pool of parts reused every frame
---------------------------------------------------------------------------
local fxFolder = Instance.new("Folder")
fxFolder.Name = "AnimeClipFX"
fxFolder.Parent = localFolder
local pools: { [string]: { BasePart } } = { block = {}, ball = {}, cyl = {}, sphere = {} }
local used: { [string]: number } = {}
local FAR = CFrame.new(0, -1000, 0)

local function take(shape: string): BasePart
	used[shape] = (used[shape] or 0) + 1
	local list = pools[shape]
	local part = list[used[shape]]
	if not part then
		part = Instance.new("Part")
		part.Anchored = true
		part.CanCollide = false
		part.CanQuery = false
		part.CanTouch = false
		part.CastShadow = false
		part.TopSurface = Enum.SurfaceType.Smooth
		part.BottomSurface = Enum.SurfaceType.Smooth
		if shape == "ball" then
			part.Shape = Enum.PartType.Ball
		elseif shape == "cyl" then
			part.Shape = Enum.PartType.Cylinder
		elseif shape == "sphere" then
			local m = Instance.new("SpecialMesh")
			m.MeshType = Enum.MeshType.Sphere
			m.Parent = part
		end
		part.Parent = fxFolder
		list[used[shape]] = part
	end
	return part
end

local moveParts, moveCFs = {}, {}
local function drawPrims(prims)
	table.clear(used)
	table.clear(moveParts)
	table.clear(moveCFs)
	for _, p in prims do
		local a = p.alpha or 0
		if a < 0.98 then
			local part = take(p.shape)
			local size = Vector3.new(math.max(0.02, p.size[1]), math.max(0.02, p.size[2]), math.max(0.02, p.size[3]))
			if part.Size ~= size then
				part.Size = size
			end
			part.Color = rgb(p.color)
			part.Material = if p.neon then Enum.Material.Neon else Enum.Material.SmoothPlastic
			part.Transparency = a
			table.insert(moveParts, part)
			table.insert(moveCFs, toCF(p.cf))
		end
	end
	-- park the rest
	for shape, list in pools do
		for i = (used[shape] or 0) + 1, #list do
			if list[i].CFrame ~= FAR then
				table.insert(moveParts, list[i])
				table.insert(moveCFs, FAR)
			end
		end
	end
	workspace:BulkMoveTo(moveParts, moveCFs, Enum.BulkMoveMode.FireCFrameChanged)
end

---------------------------------------------------------------------------
-- Lighting: sunset grade
---------------------------------------------------------------------------
local stage = workspace:WaitForChild("DuelStage")
local stageParent = stage.Parent

local function effect(class: string, name: string): any
	local e = Lighting:FindFirstChild(name) or Instance.new(class)
	e.Name = name
	e.Parent = Lighting
	return e
end
local grade = effect("ColorCorrectionEffect", "ClipGrade")
local bloom = effect("BloomEffect", "ClipBloom")
bloom.Threshold = 0.85
bloom.Size = 28
local rays = effect("SunRaysEffect", "ClipRays")
rays.Intensity = 0.12
rays.Spread = 0.8
local atmosphere = effect("Atmosphere", "ClipAtmosphere")
atmosphere.Density = 0.32
atmosphere.Offset = 0.08
atmosphere.Color = Color3.fromRGB(255, 186, 150)
atmosphere.Decay = Color3.fromRGB(120, 92, 140)
atmosphere.Glare = 0.6
atmosphere.Haze = 1.4
local sky = effect("Sky", "ClipSky")
sky.CelestialBodiesShown = false
Lighting.Brightness = 2.2
Lighting.Ambient = Color3.fromRGB(96, 80, 96)
Lighting.OutdoorAmbient = Color3.fromRGB(150, 118, 132)
Lighting.EnvironmentDiffuseScale = 0.5
Lighting.EnvironmentSpecularScale = 0.6
Lighting.ShadowSoftness = 0.25
do
	-- put the real sun low behind the rival (+X), where the set's sun sits
	local best, bestScore = { 17.6, 40 }, -math.huge
	for lat = 0, 60, 5 do
		Lighting.GeographicLatitude = lat
		for clock = 15.5, 19.5, 0.1 do
			Lighting.ClockTime = clock
			local d = Lighting:GetSunDirection()
			local score = d.X - math.abs(d.Y - 0.14) * 3 - math.abs(d.Z) * 0.5
			if score > bestScore then
				best, bestScore = { clock, lat }, score
			end
		end
	end
	Lighting.ClockTime = best[1]
	Lighting.GeographicLatitude = best[2]
end
local clouds = workspace.Terrain:FindFirstChildOfClass("Clouds") or Instance.new("Clouds")
clouds.Cover = 0.55
clouds.Density = 0.6
clouds.Color = Color3.fromRGB(255, 205, 190)
clouds.Parent = workspace.Terrain

-- impact frames: a box of flat colour around the camera, fighters filled with the other colour
local backdrop = {}
for i = 1, 6 do
	local p = Instance.new("Part")
	p.Anchored = true
	p.CanCollide = false
	p.CanQuery = false
	p.CanTouch = false
	p.CastShadow = false
	p.Material = Enum.Material.Neon
	p.Size = Vector3.new(600, 600, 1)
	p.CFrame = FAR
	p.Parent = localFolder
	backdrop[i] = p
end
local BOX = {
	CFrame.new(0, 0, -290),
	CFrame.new(0, 0, 290),
	CFrame.Angles(0, math.pi / 2, 0) * CFrame.new(0, 0, -290),
	CFrame.Angles(0, -math.pi / 2, 0) * CFrame.new(0, 0, -290),
	CFrame.Angles(math.pi / 2, 0, 0) * CFrame.new(0, 0, -290),
	CFrame.Angles(-math.pi / 2, 0, 0) * CFrame.new(0, 0, -290),
}

---------------------------------------------------------------------------
-- Screen overlays, inside a 9:16 frame
---------------------------------------------------------------------------
local gui = Instance.new("ScreenGui")
gui.Name = "AnimeClipScreen"
gui.IgnoreGuiInset = true
gui.ResetOnSpawn = false
gui.DisplayOrder = 20
gui.Parent = player:WaitForChild("PlayerGui")

local frame916 = Instance.new("Frame")
frame916.BackgroundTransparency = 1
frame916.AnchorPoint = Vector2.new(0.5, 0.5)
frame916.Position = UDim2.fromScale(0.5, 0.5)
frame916.Size = UDim2.fromScale(1, 1)
frame916.ClipsDescendants = true
frame916.Parent = gui
local aspect = Instance.new("UIAspectRatioConstraint")
aspect.AspectRatio = 9 / 16
aspect.Parent = frame916
local bars = {}
for i, anchor in { 0, 1 } do
	local b = Instance.new("Frame")
	b.BackgroundColor3 = Color3.new(0, 0, 0)
	b.BorderSizePixel = 0
	b.AnchorPoint = Vector2.new(anchor, 0)
	b.Position = UDim2.fromScale(anchor, 0)
	b.ZIndex = 50
	b.Parent = gui
	bars[i] = b
end
local function layoutBars()
	local vp = camera.ViewportSize
	local w = vp.Y * 9 / 16
	local side = math.max(0, (vp.X - w) / 2)
	for _, b in bars do
		b.Size = UDim2.new(0, side + 1, 1, 0)
		b.Visible = Config.VerticalFrame
	end
end
layoutBars()
camera:GetPropertyChangedSignal("ViewportSize"):Connect(layoutBars)

local function full(name: string, color: Color3, z: number): Frame
	local f = Instance.new("Frame")
	f.Name = name
	f.Size = UDim2.fromScale(1, 1)
	f.BackgroundColor3 = color
	f.BackgroundTransparency = 1
	f.BorderSizePixel = 0
	f.ZIndex = z
	f.Parent = frame916
	return f
end
local flash = full("Flash", Color3.new(1, 1, 1), 30)
local fade = full("Fade", Color3.new(0, 0, 0), 40)

-- vignette: dark gradients on all four edges
local vignette = {}
for i, rot in { 0, 90, 180, 270 } do
	local v = Instance.new("Frame")
	v.BackgroundColor3 = Color3.new(0, 0, 0)
	v.BorderSizePixel = 0
	v.AnchorPoint = Vector2.new(0.5, 0.5)
	v.Position = UDim2.fromScale(0.5, 0.5)
	v.Size = if rot % 180 == 0 then UDim2.fromScale(1, 1) else UDim2.fromScale(16 / 9, 9 / 16)
	v.Rotation = rot
	v.ZIndex = 5
	local g = Instance.new("UIGradient")
	g.Transparency = NumberSequence.new({ NumberSequenceKeypoint.new(0, 0.2), NumberSequenceKeypoint.new(0.28, 1), NumberSequenceKeypoint.new(1, 1) })
	g.Parent = v
	v.Parent = frame916
	vignette[i] = v
end

-- glint: a bright horizontal streak
local glint = Instance.new("Frame")
glint.AnchorPoint = Vector2.new(0, 0.5)
glint.Size = UDim2.new(1, 0, 0.012, 0)
glint.BackgroundColor3 = Color3.fromRGB(215, 240, 255)
glint.BorderSizePixel = 0
glint.ZIndex = 20
glint.Visible = false
glint.Parent = frame916
do
	local g = Instance.new("UIGradient")
	g.Transparency = NumberSequence.new({ NumberSequenceKeypoint.new(0, 1), NumberSequenceKeypoint.new(0.5, 0), NumberSequenceKeypoint.new(1, 1) })
	g.Parent = glint
end

-- speed lines: thin white streaks rushing in from the edges
local lines = {}
for i = 1, 70 do
	local l = Instance.new("Frame")
	l.AnchorPoint = Vector2.new(0.5, 0.5)
	l.BackgroundColor3 = Color3.new(1, 1, 1)
	l.BorderSizePixel = 0
	l.ZIndex = 15
	l.Visible = false
	local g = Instance.new("UIGradient")
	g.Transparency = NumberSequence.new({ NumberSequenceKeypoint.new(0, 1), NumberSequenceKeypoint.new(1, 0) })
	g.Parent = l
	l.Parent = frame916
	lines[i] = l
end

-- texts
local labels = {}
local function label(i: number): TextLabel
	local l = labels[i]
	if not l then
		l = Instance.new("TextLabel")
		l.BackgroundTransparency = 1
		l.AnchorPoint = Vector2.new(0.5, 0.5)
		l.TextScaled = true
		l.ZIndex = 25
		local stroke = Instance.new("UIStroke")
		stroke.Color = Color3.fromRGB(10, 10, 20)
		stroke.Thickness = 2
		stroke.Parent = l
		l.Parent = frame916
		labels[i] = l
	end
	return l :: TextLabel
end

local hint = Instance.new("TextLabel")
hint.BackgroundTransparency = 1
hint.AnchorPoint = Vector2.new(0.5, 1)
hint.Position = UDim2.new(0.5, 0, 1, -16)
hint.Size = UDim2.fromOffset(420, 28)
hint.Font = Enum.Font.GothamBold
hint.TextSize = 16
hint.TextColor3 = Color3.new(1, 1, 1)
hint.TextStrokeTransparency = 0.4
hint.Text = "R = replay    F = frame guides"
hint.ZIndex = 60
hint.Parent = gui

---------------------------------------------------------------------------
-- Hide your own character while the clip plays
---------------------------------------------------------------------------
local function hideCharacter(character: Model)
	for _, d in character:GetDescendants() do
		if d:IsA("BasePart") or d:IsA("Decal") then
			d.LocalTransparencyModifier = 1
		end
	end
	character.DescendantAdded:Connect(function(d)
		if d:IsA("BasePart") or d:IsA("Decal") then
			d.LocalTransparencyModifier = 1
		end
	end)
end
if player.Character then
	hideCharacter(player.Character)
end
player.CharacterAdded:Connect(hideCharacter)

---------------------------------------------------------------------------
-- Playback
---------------------------------------------------------------------------
local startAt = os.clock() + Config.AutoPlayDelay
local last = nil

local function worldFor(name: string, s: any): any
	local f = fighters[name]
	local root = T.RootFor(f.desc, s, f.stand)
	return Rig.FK(f.desc, root, s.pose), root
end

local function step()
	local t = math.clamp((os.clock() - startAt) * Config.Speed, 0, T.LENGTH - 1e-3)
	-- the real fighters' bodies this frame (for aiming the camera and placing gear)
	local states, worlds, roots = {}, {}, {}
	for name in fighters do
		states[name] = T.ActorState(name, t)
		worlds[name], roots[name] = worldFor(name, states[name])
	end
	local frame = T.Sample(t, function(actor, part)
		return worlds[actor] and worlds[actor][part]
	end)

	-- pose the avatars
	for name, f in fighters do
		local s = frame.actors[name]
		f.root.CFrame = toCF(roots[name])
		for jointName, motor in f.motors do
			motor.Transform = toCF(Rig.Transform(s.pose[jointName]))
		end
		-- sword in hand or sheathed, sheath on the hip
		local w = worlds[name]
		local gear = f.gear
		local swordBase = if s.sword == "sheath" then CF.mul(w.LowerTorso, Props.SHEATHED) else CF.mul(w.RightHand, Props.GRIP)
		local cfs = {}
		for i, p in gear.local_ do
			cfs[i] = toCF(CF.mul(swordBase, p.cf))
			local part = gear.parts[i]
			if p.tag == "blade" then
				local g = s.glow or 0
				part.Material = if g > 0.4 then Enum.Material.Neon else Enum.Material.SmoothPlastic
				part.Color = rgb(p.color):Lerp(Color3.fromRGB(110, 220, 255), g)
			end
		end
		workspace:BulkMoveTo(gear.parts, cfs, Enum.BulkMoveMode.FireCFrameChanged)
		if #gear.sheath > 0 then
			local sheathBase = CF.mul(w.LowerTorso, Props.SHEATH)
			local scfs = {}
			for i, p in gear.sheathLocal do
				scfs[i] = toCF(CF.mul(sheathBase, p.cf))
			end
			workspace:BulkMoveTo(gear.sheath, scfs, Enum.BulkMoveMode.FireCFrameChanged)
		end
	end

	local post = frame.post
	local impact = post.impact or 0

	-- effects (+ afterimages); impact frames show only the fighters
	local prims = {}
	if impact == 0 then
		prims = frame.prims
		for _, g in frame.ghosts do
			for _, p in T.GhostPrims(g) do
				table.insert(prims, p)
			end
		end
	end
	drawPrims(prims)

	-- impact frames
	local ink = if impact == 1 then Color3.new(1, 1, 1) else Color3.new(0, 0, 0)
	local paper = if impact == 1 then Color3.new(0, 0, 0) else Color3.new(1, 1, 1)
	local want = if impact > 0 then nil else stageParent
	if stage.Parent ~= want then
		stage.Parent = want
	end
	for _, f in fighters do
		f.highlight.Enabled = impact > 0
		f.highlight.FillColor = ink
		local gh = (f.gear :: any).highlight
		gh.Enabled = impact > 0
		gh.FillColor = ink
	end
	local camCF = toCF(frame.camera.cf)
	for i, p in backdrop do
		p.Color = paper
		p.CFrame = if impact > 0 then CFrame.new(camCF.Position) * BOX[i] else FAR
	end

	-- camera
	camera.CameraType = Enum.CameraType.Scriptable
	camera.CFrame = camCF
	camera.FieldOfView = frame.camera.fov

	-- colour grade
	local tint = post.tint or { 1, 1, 1 }
	local m = math.max(tint[1], tint[2], tint[3], 1)
	grade.Enabled = impact == 0
	grade.TintColor = Color3.new(tint[1] / m, tint[2] / m, tint[3] / m)
	grade.Saturation = post.saturation or 0
	grade.Contrast = post.contrast or 0
	grade.Brightness = (post.brightness or 0) + (m - 1) * 0.3
	bloom.Intensity = 0.35 * (post.bloom or 0.6)
	for _, v in vignette do
		v.BackgroundTransparency = 1 - math.clamp((post.vignette or 0) * 1.4, 0, 1)
	end

	-- overlays
	flash.BackgroundTransparency = 1 - math.clamp(post.flash or 0, 0, 1)
	fade.BackgroundTransparency = 1 - math.clamp(post.fade or 0, 0, 1)
	if post.glint then
		glint.Visible = true
		glint.Position = UDim2.fromScale(0, post.glint.y)
		glint.BackgroundTransparency = 1 - math.clamp(post.glint.k, 0, 1)
	else
		glint.Visible = false
	end
	local speed = post.speed or 0
	local seed = math.floor(t * 30)
	for i, l in lines do
		local on = i <= math.floor(70 * speed)
		l.Visible = on
		if on then
			-- in a 9 x 16 box: a streak from radius r0 outward past the edge, rotated about its centre
			local r = Random.new(seed * 97 + i)
			local ang = r:NextNumber(0, math.pi * 2)
			local r0 = r:NextNumber(0.45, 0.75) * 8
			local len = 9
			local cx = 4.5 + math.cos(ang) * (r0 + len / 2)
			local cy = 8 + math.sin(ang) * (r0 + len / 2)
			l.Position = UDim2.fromScale(cx / 9, cy / 16)
			l.Size = UDim2.new(len / 9, 0, 0, r:NextInteger(1, 4))
			l.Rotation = math.deg(ang)
			l.BackgroundTransparency = 1 - r:NextNumber(0.35, 0.8) * speed
		end
	end
	for i, l in labels do
		l.Visible = false
		local _ = i
	end
	for i, tx in post.texts do
		local l = label(i)
		l.Visible = true
		local jp = tx.font == "jp"
		l.Text = if tx.spacing then table.concat(string.split(tx.text, ""), " ") else tx.text
		l.FontFace = if jp then Font.fromEnum(Enum.Font.GothamBlack) else Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.Heavy)
		l.Size = UDim2.fromScale(0.9, tx.size * (if jp then 0.5 else 1))
		l.Position = UDim2.fromScale(0.5, tx.y)
		l.TextColor3 = rgb(tx.color or { 255, 255, 255 })
		l.TextTransparency = 1 - math.clamp(tx.alpha, 0, 1)
		local stroke = l:FindFirstChildOfClass("UIStroke")
		if stroke then
			stroke.Transparency = 1 - math.clamp(tx.alpha, 0, 1) * 0.8
		end
	end
	hint.Visible = t >= T.LENGTH - 0.01 or os.clock() < startAt
	last = frame
end

local function start()
	startAt = os.clock() + 0.4
end
UserInputService.InputBegan:Connect(function(input, processed)
	if processed then
		return
	end
	if input.KeyCode == Config.ReplayKey then
		start()
	elseif input.KeyCode == Config.ToggleFrameKey then
		Config.VerticalFrame = not Config.VerticalFrame
		layoutBars()
	end
end)

-- run before physics so the joints, gear and effects all land on the same frame
local evt = (RunService :: any).PreSimulation or RunService.Stepped
evt:Connect(function()
	local ok, err = pcall(step)
	if not ok then
		warn("[AnimeClip] frame error:", err)
	end
end)
RunService:BindToRenderStep("AnimeClipCamera", Enum.RenderPriority.Camera.Value + 1, function()
	if last then
		camera.CameraType = Enum.CameraType.Scriptable
		camera.CFrame = toCF(last.camera.cf)
		camera.FieldOfView = last.camera.fov
	end
end)
