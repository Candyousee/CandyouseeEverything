-- Plays the egg-hatch cinematic on the client from HatchSequence (the pure timeline):
-- egg + cracks + rarity glow + light rays + burst particles + shockwave + shell shards +
-- screen flash + camera shake + sounds, then the pet pops out and does its trick.
--
--   HatchPlayer.Play(eggName, results)  -- results = {{Pet, Rarity}, ...} (1 or 3); yields until done

local Players = game:GetService("Players")
local ProximityPromptService = game:GetService("ProximityPromptService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local System = ReplicatedStorage:WaitForChild("StudPetSystem")
local Config = require(System:WaitForChild("Config"))
local Odds = require(System:WaitForChild("Odds"))(Config)
local Hatch = require(System:WaitForChild("HatchSequence"))
local Sounds = require(script.Parent:WaitForChild("Sounds"))
local PetAnimator = require(ReplicatedStorage:WaitForChild("StudPets"):WaitForChild("PetAnimator"))
local PetModels = ReplicatedStorage:WaitForChild("StudPetModels")
local EggModels = ReplicatedStorage:WaitForChild("StudPetSystemEggs")

local player = Players.LocalPlayer
local SPARKLE = "rbxasset://textures/particles/sparkles_main.dds"
local SMOKE = "rbxasset://textures/particles/smoke_main.dds"
local FONT = Font.new("rbxasset://fonts/families/FredokaOne.json")

local HatchPlayer = {}
HatchPlayer.Busy = false

local function rgb(t)
	return Color3.fromRGB(t[1], t[2], t[3])
end

local function part(props)
	local p = Instance.new("Part")
	p.Anchored = true
	p.CanCollide = false
	p.CanQuery = false
	p.CanTouch = false
	p.CastShadow = false
	p.TopSurface = Enum.SurfaceType.Smooth
	p.BottomSurface = Enum.SurfaceType.Smooth
	for k, v in props do
		(p :: any)[k] = v
	end
	return p
end

local function emitter(parent, props)
	local e = Instance.new("ParticleEmitter")
	e.Enabled = false
	e.LightEmission = 1
	e.LightInfluence = 0
	e.Rate = 0
	for k, v in props do
		(e :: any)[k] = v
	end
	e.Parent = parent
	return e
end

-- rainbow cycle for Secret pets
local function rarityColor(rarity, t)
	if rarity.Rainbow then
		return Color3.fromHSV((t * 0.35) % 1, 0.75, 1)
	end
	return rgb(rarity.Color)
end

-- One egg on the stage: its parts, effects and the pet that comes out.
local function makeSlot(folder, eggName, result, index)
	local slot = {}
	local rarity = Odds.Rarity(result.Rarity)
	slot.rarity = rarity
	slot.drama = rarity.Drama or 0
	slot.seed = 11 + index * 17
	slot.timing = Hatch.Timing(slot.drama)
	slot.events = Hatch.Events(slot.drama)
	slot.nextEvent = 1
	local egg = Config.Eggs[1]
	for _, e in Config.Eggs do
		if e.Name == eggName then
			egg = e
		end
	end

	-- egg (anchored parts, moved every frame)
	local template = EggModels:FindFirstChild(eggName) or EggModels:GetChildren()[1]
	local model = template:Clone()
	slot.parts = {}
	local root = model.PrimaryPart
	for _, p in model:GetDescendants() do
		if p:IsA("BasePart") and p ~= root then
			table.insert(slot.parts, { part = p, rel = root.CFrame:ToObjectSpace(p.CFrame), size = p.Size, crack = p:GetAttribute("Crack") })
			if p:GetAttribute("Crack") then
				p.Color = rgb(rarity.Color)
			end
		end
	end
	model.Parent = folder
	slot.egg = model
	local highlight = Instance.new("Highlight")
	highlight.FillTransparency = 1
	highlight.OutlineTransparency = 1
	highlight.DepthMode = Enum.HighlightDepthMode.Occluded
	highlight.Parent = model
	slot.highlight = highlight
	local light = Instance.new("PointLight")
	light.Range = 16
	light.Brightness = 0
	light.Shadows = false
	light.Parent = root
	slot.light = light

	-- effects anchor
	local fx = part({ Name = "FX", Size = Vector3.new(0.2, 0.2, 0.2), Transparency = 1 })
	fx.Parent = folder
	slot.fx = fx
	local at = Instance.new("Attachment")
	at.Parent = fx
	slot.burst = emitter(at, {
		Texture = SPARKLE,
		Lifetime = NumberRange.new(0.5, 1.1),
		Speed = NumberRange.new(14, 26),
		SpreadAngle = Vector2.new(180, 180),
		Drag = 5,
		Size = NumberSequence.new({ NumberSequenceKeypoint.new(0, 0.9), NumberSequenceKeypoint.new(0.5, 0.6), NumberSequenceKeypoint.new(1, 0) }),
		Transparency = NumberSequence.new({ NumberSequenceKeypoint.new(0, 0), NumberSequenceKeypoint.new(0.7, 0.2), NumberSequenceKeypoint.new(1, 1) }),
		Rotation = NumberRange.new(0, 360),
		RotSpeed = NumberRange.new(-200, 200),
	})
	slot.dust = emitter(at, {
		Texture = SMOKE,
		LightEmission = 0,
		LightInfluence = 1,
		Color = ColorSequence.new(rgb(egg.Colors.Shell)),
		Lifetime = NumberRange.new(0.35, 0.6),
		Speed = NumberRange.new(3, 6),
		SpreadAngle = Vector2.new(60, 60),
		Drag = 6,
		Size = NumberSequence.new({ NumberSequenceKeypoint.new(0, 0.4), NumberSequenceKeypoint.new(1, 1.1) }),
		Transparency = NumberSequence.new({ NumberSequenceKeypoint.new(0, 0.35), NumberSequenceKeypoint.new(1, 1) }),
	})
	slot.aura = emitter(at, {
		Texture = SPARKLE,
		Lifetime = NumberRange.new(0.8, 1.4),
		Speed = NumberRange.new(1, 3),
		SpreadAngle = Vector2.new(180, 180),
		Size = NumberSequence.new({ NumberSequenceKeypoint.new(0, 0), NumberSequenceKeypoint.new(0.3, 0.45), NumberSequenceKeypoint.new(1, 0) }),
		Rate = 0,
		Enabled = true,
	})

	-- light rays behind (rare+)
	slot.rays = {}
	if slot.drama >= 1 then
		for k = 1, 10 do
			local ray = part({ Name = "Ray", Material = Enum.Material.Neon, Size = Vector3.new(0.35, 9, 0.05), Transparency = 1 })
			ray.Parent = folder
			slot.rays[k] = ray
		end
	end

	-- shockwave ring segments
	slot.ring = {}
	for k = 1, 22 do
		local seg = part({ Name = "Ring", Material = Enum.Material.Neon, Size = Vector3.new(0.6, 0.18, 0.05), Transparency = 1 })
		seg.Parent = folder
		slot.ring[k] = seg
	end

	-- shell shards (pool)
	slot.shards = {}
	for k = 1, 24 do
		local sh = part({ Name = "Shard", Material = Enum.Material.SmoothPlastic, Size = Vector3.new(0.5, 0.5, 0.16), Transparency = 1 })
		sh.Parent = folder
		slot.shards[k] = sh
	end
	slot.shellColor = rgb(egg.Colors.Shell)
	slot.spotColor = rgb(egg.Colors.Spots)

	-- the pet
	local petTemplate = PetModels:FindFirstChild("Stud" .. result.Pet)
	if petTemplate then
		local pet = petTemplate:Clone()
		local extents = pet:GetExtentsSize()
		slot.petFit = 3.6 / math.max(extents.X, extents.Y, extents.Z)
		slot.petCenter = pet:GetPivot():ToObjectSpace(CFrame.new(pet:GetBoundingBox().Position)).Position
		-- stays out of the world (and never shrinks to a sliver) until it pops out
		slot.pet = pet
		slot.petFolder = folder
		slot.anim = PetAnimator.new(pet)
	end

	-- name + rarity label under the pet
	local gui = Instance.new("BillboardGui")
	gui.Size = UDim2.fromScale(7, 2.2)
	gui.StudsOffset = Vector3.new(0, -3.1, 0)
	gui.AlwaysOnTop = true
	gui.LightInfluence = 0
	gui.Adornee = fx
	local name = Instance.new("TextLabel")
	name.BackgroundTransparency = 1
	name.Size = UDim2.fromScale(1, 0.55)
	name.FontFace = FONT
	name.TextScaled = true
	name.TextColor3 = Color3.new(1, 1, 1)
	name.TextStrokeTransparency = 0.1
	name.Text = result.Pet:gsub("(%l)(%u)", "%1 %2")
	name.Parent = gui
	local rar = Instance.new("TextLabel")
	rar.BackgroundTransparency = 1
	rar.Position = UDim2.fromScale(0, 0.55)
	rar.Size = UDim2.fromScale(1, 0.45)
	rar.FontFace = FONT
	rar.TextScaled = true
	rar.TextColor3 = rgb(rarity.Color)
	rar.TextStrokeTransparency = 0.1
	rar.Text = string.upper(rarity.Name)
	rar.Parent = gui
	gui.Parent = folder
	slot.label, slot.labelName, slot.labelRarity = gui, name, rar
	return slot
end

local function cue(slot, name, idx)
	if name == "EggAppear" then
		Sounds.Play("EggAppear")
	elseif name == "Shake" then
		Sounds.Play("Shake")
	elseif name == "Crack" then
		Sounds.Play("Crack")
		slot.dust:Emit(6 + 3 * idx)
	elseif name == "Charge" then
		Sounds.Play("Charge")
		slot.aura.Rate = 25 + 15 * slot.drama
	elseif name == "Pop" then
		Sounds.Play("Pop")
		slot.burst:Emit(45 + 25 * slot.drama)
		slot.dust:Emit(20)
	elseif name == "Reveal" then
		local d = slot.drama
		Sounds.Play(if d >= 2 then "RevealLegendary" elseif d >= 1 then "RevealRare" else "RevealCommon")
		slot.aura.Rate = if d >= 1 then 18 + 10 * d else 0
		if slot.anim then
			task.delay(0.35, function()
				if slot.anim and slot.pet and slot.pet.Parent then
					slot.anim:Play(slot.anim.Set.Trick, 0.15)
				end
			end)
		end
	end
end

local function update(slot, t, stageCF, camPos)
	local s = Hatch.State(t, slot.drama, slot.seed)
	local color = rarityColor(slot.rarity, t)

	-- egg
	local eggCF = stageCF
		* CFrame.new(s.eggPos[1], s.eggPos[2], s.eggPos[3])
		* CFrame.Angles(math.rad(s.eggRot[1]), math.rad(s.eggRot[2]), math.rad(s.eggRot[3]))
	if s.eggVisible then
		for _, e in slot.parts do
			local rel = e.rel
			e.part.CFrame = eggCF * CFrame.new(rel.Position * s.eggScale) * rel.Rotation
			e.part.Size = e.size * s.eggScale
			if e.crack then
				e.part.Transparency = if e.crack <= s.cracks then 0 else 1
				e.part.Color = color
			end
		end
		slot.egg.PrimaryPart.CFrame = eggCF
	elseif slot.egg.Parent then
		slot.egg.Parent = nil
	end
	slot.highlight.FillColor = color
	slot.highlight.OutlineColor = color
	slot.highlight.FillTransparency = 1 - 0.5 * s.glow
	slot.highlight.OutlineTransparency = 1 - s.glow
	slot.light.Color = color
	slot.light.Brightness = 5 * s.glow
	slot.fx.CFrame = stageCF * CFrame.new(0, 0.2, 0)
	slot.burst.Color = ColorSequence.new(Color3.new(1, 1, 1), color)
	slot.aura.Color = ColorSequence.new(color)

	-- rays: fan of neon blades behind, slowly turning
	for k, ray in slot.rays do
		local a = (k / #slot.rays) * math.pi * 2 + t * 0.7
		ray.CFrame = stageCF * CFrame.new(0, 0.3, -2.5) * CFrame.Angles(0, 0, a) * CFrame.new(0, 4.6, 0)
		ray.Color = color
		ray.Transparency = 1 - 0.55 * s.rays * (1 - s.fade)
	end

	-- shockwave ring (faces the camera)
	if s.ring then
		local r, alpha = s.ring[1], s.ring[2]
		for k, seg in slot.ring do
			local a = (k / #slot.ring) * math.pi * 2
			seg.Size = Vector3.new(r * 2 * math.pi / #slot.ring * 1.05, 0.22, 0.05)
			seg.CFrame = stageCF * CFrame.new(0, 0.2, 0) * CFrame.Angles(0, 0, a) * CFrame.new(0, r, 0)
			seg.Color = color
			seg.Transparency = 1 - alpha
		end
	else
		for _, seg in slot.ring do
			seg.Transparency = 1
		end
	end

	-- shards
	for k, sh in slot.shards do
		local d = s.shards[k]
		if d then
			sh.Size = Vector3.new(d.size, d.size, 0.16)
			sh.CFrame = stageCF * CFrame.new(d.pos[1], d.pos[2], d.pos[3]) * CFrame.Angles(math.rad(d.rot[1]), math.rad(d.rot[2]), math.rad(d.rot[3]))
			sh.Color = if d.color == 2 then slot.spotColor else slot.shellColor
			sh.Transparency = 1 - d.alpha
		else
			sh.Transparency = 1
		end
	end

	-- pet
	if slot.pet then
		local shown = s.petScale > 0.15
		slot.pet.Parent = if shown then slot.petFolder else nil
		local scale = slot.petFit * math.max(0.15, s.petScale)
		if shown and math.abs(slot.pet:GetScale() - scale) > 1e-3 then
			slot.pet:ScaleTo(scale)
		end
		local pos = (stageCF * CFrame.new(0, s.petY - 0.2, 0)).Position
		local face = CFrame.lookAt(pos, Vector3.new(camPos.X, pos.Y, camPos.Z)) * CFrame.Angles(0, math.rad(s.petYaw), 0)
		slot.pet:PivotTo(face * CFrame.new(-slot.petCenter * scale))
	end
	slot.label.Enabled = s.banner > 0.01
	slot.labelName.TextTransparency = 1 - s.banner
	slot.labelRarity.TextTransparency = 1 - s.banner
	slot.labelRarity.TextColor3 = color
	return s
end

function HatchPlayer.Play(eggName: string, results: { any })
	if HatchPlayer.Busy then
		return
	end
	HatchPlayer.Busy = true
	local camera = workspace.CurrentCamera
	local oldType = camera.CameraType
	local baseCF = camera.CFrame
	camera.CameraType = Enum.CameraType.Scriptable

	-- the stage sits between the camera and your avatar: hide the avatar, freeze movement,
	-- and hide other prompts until the cinematic ends
	local hidden = {}
	if player.Character then
		for _, d in player.Character:GetDescendants() do
			if d:IsA("BasePart") or d:IsA("Decal") then
				hidden[d] = d.LocalTransparencyModifier
				d.LocalTransparencyModifier = 1
			end
		end
	end
	local controls = nil
	pcall(function()
		controls = require(player:WaitForChild("PlayerScripts"):WaitForChild("PlayerModule", 2)):GetControls()
		controls:Disable()
	end)
	local oldPrompts = ProximityPromptService.MaxPromptsVisible
	ProximityPromptService.MaxPromptsVisible = 0

	local folder = Instance.new("Folder")
	folder.Name = "StudHatchStage"
	folder.Parent = workspace

	-- dark backdrop behind the stage dims the world
	local back = part({ Name = "Backdrop", Size = Vector3.new(400, 400, 0.2), Color = Color3.fromRGB(12, 12, 24), Material = Enum.Material.SmoothPlastic, Transparency = 1 })
	back.CFrame = baseCF * CFrame.new(0, 0, -30)
	back.Parent = folder

	-- screen flash
	local gui = Instance.new("ScreenGui")
	gui.Name = "StudHatchFlash"
	gui.IgnoreGuiInset = true
	gui.DisplayOrder = 50
	local flash = Instance.new("Frame")
	flash.Size = UDim2.fromScale(1, 1)
	flash.BackgroundColor3 = Color3.new(1, 1, 1)
	flash.BackgroundTransparency = 1
	flash.BorderSizePixel = 0
	flash.Parent = gui
	local hint = Instance.new("TextLabel")
	hint.BackgroundTransparency = 1
	hint.AnchorPoint = Vector2.new(0.5, 1)
	hint.Position = UDim2.new(0.5, 0, 1, -24)
	hint.Size = UDim2.fromOffset(300, 24)
	hint.FontFace = FONT
	hint.TextSize = 18
	hint.TextColor3 = Color3.new(1, 1, 1)
	hint.TextStrokeTransparency = 0.4
	hint.Text = "Click to skip"
	hint.TextTransparency = 1
	hint.Parent = gui
	gui.Parent = player:WaitForChild("PlayerGui")

	local n = #results
	local spacing = if n > 1 then 5.2 else 0
	local dist = if n > 1 then 13 else 10
	local slots = {}
	for i, r in results do
		slots[i] = makeSlot(folder, eggName, r, i)
		slots[i].offset = (i - (n + 1) / 2) * spacing
	end
	local length = 0
	for _, s in slots do
		length = math.max(length, s.timing.length)
	end

	local t = 0
	local skipTo = nil
	local skipConn = UserInputService.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			local popped = true
			for _, s in slots do
				popped = popped and t > s.timing.pop + 0.6
			end
			if popped then
				skipTo = length - 0.45
			end
		end
	end)

	local done = false
	local conn
	local function frame(dt)
		t += dt
		if skipTo and t < skipTo then
			t = skipTo
		end
		local camPos = baseCF.Position
		local shake, flashA, dim = 0, 0, 0
		for _, slot in slots do
			local stageCF = CFrame.lookAt((baseCF * CFrame.new(slot.offset, -0.6, -dist)).Position, camPos)
			-- cues (sounds, particle bursts) at their exact times
			while slot.events[slot.nextEvent] and slot.events[slot.nextEvent][1] <= t do
				local ev = slot.events[slot.nextEvent]
				cue(slot, ev[2], ev[3])
				slot.nextEvent += 1
			end
			local s = update(slot, math.min(t, slot.timing.length), stageCF, camPos)
			shake = math.max(shake, s.shake)
			flashA = math.max(flashA, s.flash)
			dim = math.max(dim, s.dim)
		end
		back.Transparency = 1 - 0.6 * dim
		flash.BackgroundTransparency = 1 - flashA
		hint.TextTransparency = if skipTo == nil and t > 2.5 and t < length - 0.6 then 0.3 else 1
		local nx = math.noise(t * 25, 1.7) * shake
		local ny = math.noise(t * 25, 9.3) * shake
		camera.CFrame = baseCF * CFrame.new(nx, ny, 0)
		if t >= length then
			done = true
		end
	end
	conn = RunService.RenderStepped:Connect(function(dt)
		local ok, err = pcall(frame, dt)
		if not ok then
			warn("[StudPetSystem] hatch frame error:", err)
			done = true
		end
	end)
	while not done do
		task.wait()
	end
	conn:Disconnect()
	skipConn:Disconnect()
	for _, s in slots do
		if s.anim then
			s.anim:Destroy()
		end
	end
	folder:Destroy()
	gui:Destroy()
	camera.CFrame = baseCF
	camera.CameraType = if oldType == Enum.CameraType.Scriptable then Enum.CameraType.Custom else oldType
	for d, v in hidden do
		if d.Parent then
			d.LocalTransparencyModifier = v
		end
	end
	if controls then
		controls:Enable()
	end
	ProximityPromptService.MaxPromptsVisible = oldPrompts
	HatchPlayer.Busy = false
end

return HatchPlayer
