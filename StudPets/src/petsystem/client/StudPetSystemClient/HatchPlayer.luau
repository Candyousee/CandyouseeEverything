-- Plays the egg-hatch cinematic on the client from HatchSequence (the pure timeline):
-- egg + glowing crack bricks + rarity glow + burst particles + shockwave + shell shards +
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
			table.insert(slot.parts, { part = p, rel = root.CFrame:ToObjectSpace(p.CFrame), size = p.Size, crack = p:GetAttribute("Crack"), color = p.Color, material = p.Material })
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

	-- two shockwave rings (segments): a fast bright one and a slower soft one
	slot.ring, slot.ring2 = {}, {}
	for k = 1, 32 do
		local seg = part({ Name = "Ring", Material = Enum.Material.Neon, Size = Vector3.new(0.6, 0.32, 0.05), Transparency = 1 })
		seg.Parent = folder
		slot.ring[k] = seg
		local seg2 = part({ Name = "Ring2", Material = Enum.Material.Neon, Size = Vector3.new(0.6, 0.16, 0.05), Transparency = 1 })
		seg2.Parent = folder
		slot.ring2[k] = seg2
	end

	-- flash ball at the moment of the pop
	local ball = part({ Name = "FlashBall", Material = Enum.Material.Neon, Size = Vector3.new(1, 1, 1), Transparency = 1, Shape = Enum.PartType.Ball })
	ball.Parent = folder
	slot.ball = ball

	-- confetti (rare+)
	-- confetti in the rarity's own colours (rainbow for Secret)
	slot.confetti = {}
	do
		local base = rgb(rarity.Color)
		local palette = if rarity.Rainbow
			then { Color3.fromRGB(255, 90, 90), Color3.fromRGB(255, 210, 60), Color3.fromRGB(90, 220, 120), Color3.fromRGB(80, 170, 255), Color3.fromRGB(200, 110, 255), Color3.new(1, 1, 1) }
			else { base, base:Lerp(Color3.new(1, 1, 1), 0.45), base:Lerp(Color3.new(0, 0, 0), 0.25), base:Lerp(Color3.new(1, 1, 1), 0.8) }
		for k = 1, 22 + 14 * slot.drama do
			local c = part({ Name = "Confetti", Material = Enum.Material.SmoothPlastic, Size = Vector3.new(0.28, 0.14, 0.03), Transparency = 1, Color = palette[(k % #palette) + 1] })
			c.Parent = folder
			slot.confetti[k] = c
		end
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
	gui.StudsOffset = Vector3.new(0, -4.35, 0) -- below the pedestal, clear of the glowing rim
	gui.AlwaysOnTop = true
	gui.LightInfluence = 0
	gui.Adornee = fx
	local pill = Instance.new("Frame")
	pill.AnchorPoint = Vector2.new(0.5, 0)
	pill.Position = UDim2.fromScale(0.5, 0)
	pill.Size = UDim2.fromScale(0.85, 1)
	pill.BackgroundColor3 = Color3.fromRGB(16, 18, 34)
	pill.BackgroundTransparency = 1
	local pc = Instance.new("UICorner")
	pc.CornerRadius = UDim.new(0.25, 0)
	pc.Parent = pill
	pill.Parent = gui
	slot.labelPill = pill
	local name = Instance.new("TextLabel")
	name.BackgroundTransparency = 1
	name.Size = UDim2.fromScale(1, 0.55)
	name.FontFace = FONT
	name.TextScaled = true
	name.TextColor3 = Color3.new(1, 1, 1)
	name.TextStrokeTransparency = 0.1
	name.ZIndex = 2
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
	rar.ZIndex = 2
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
		-- ~170 bricks per egg: move them in one bulk call, resize only when the scale changes
		local resize = math.abs((slot.lastScale or -1) - s.eggScale) > 0.002
		if resize then
			slot.lastScale = s.eggScale
		end
		local list, cfs = slot.bulkParts, slot.bulkCFs
		if not list then
			list, cfs = {}, {}
			for k, e in slot.parts do
				list[k] = e.part
			end
			slot.bulkParts, slot.bulkCFs = list, cfs
		end
		for k, e in slot.parts do
			local rel = e.rel
			cfs[k] = eggCF * CFrame.new(rel.Position * s.eggScale) * rel.Rotation
			if resize then
				e.part.Size = e.size * s.eggScale
			end
		end
		workspace:BulkMoveTo(list, cfs, Enum.BulkMoveMode.FireCFrameChanged)
		for _, e in slot.parts do
			if e.crack then
				-- crack bricks are shell until they split open, then glow in the rarity colour
				local open = e.crack <= s.cracks
				e.part.Material = if open then Enum.Material.Neon else e.material
				e.part.Color = if open then color else e.color
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

	-- shockwave rings (face the camera)
	local function ringAt(segs, r, alpha, thick)
		for k, seg in segs do
			local a = (k / #segs) * math.pi * 2
			if alpha > 0.01 then
				seg.Size = Vector3.new(r * 2 * math.pi / #segs * 1.08, thick, 0.05)
				seg.CFrame = stageCF * CFrame.new(0, 0.2, 0) * CFrame.Angles(0, 0, a) * CFrame.new(0, r, 0)
				seg.Color = color
				seg.Transparency = 1 - alpha
			else
				seg.Transparency = 1
			end
		end
	end
	if s.ring then
		-- one clean ring, kept compact
		local ringScale = if slot.crowded then 0.5 else 0.65
		ringAt(slot.ring, 0.8 + (s.ring[1] - 0.8) * ringScale, s.ring[2] * 0.7, 0.16 * s.ring[2] + 0.05)
		ringAt(slot.ring2, 0, 0, 0)
	else
		ringAt(slot.ring, 0, 0, 0)
		ringAt(slot.ring2, 0, 0, 0)
	end

	-- flash ball: swells and fades right at the pop
	local pp = t - slot.timing.pop
	if pp >= 0 and pp < 0.32 then
		local k = pp / 0.32
		local d = 1.5 + 4.5 * math.sqrt(k) + slot.drama * 0.6
		slot.ball.Size = Vector3.new(d, d, d)
		slot.ball.CFrame = stageCF * CFrame.new(0, 0.2, 0)
		slot.ball.Color = Color3.new(1, 1, 1):Lerp(color, k)
		slot.ball.Transparency = 0.15 + 0.85 * k
	else
		slot.ball.Transparency = 1
	end

	-- confetti: bursts up and out, then keeps falling and fluttering until it reaches the
	-- floor, where it fades out (never hangs in the air)
	for k, c in slot.confetti do
		local h1 = (k * 0.6180339) % 1
		local h2 = (k * 0.4142135 + 0.3) % 1
		local h3 = (k * 0.7320508 + 0.7) % 1
		local q = pp - h3 * 0.2 -- small stagger
		if q > 0 then
			local ang = h1 * math.pi * 2
			local spread = 2.2 + 2.8 * h2
			local vy = 6 + 3 * h3
			local apex = vy / 12
			local y
			if q < apex then
				y = 0.4 + vy * q - 6 * q * q -- rising, slowing down
			else
				y = 0.4 + vy * apex - 6 * apex * apex - (2.6 + 1.2 * h2) * (q - apex) -- steady flutter-fall
			end
			local out = spread * (1 - math.exp(-q * 2.5))
			local sway = math.sin(q * (4 + 3 * h1) + k) * 0.35 * math.min(1, q)
			local x = math.cos(ang) * out + sway
			local z = math.sin(ang) * out * 0.45
			local floorY = -2.9
			if y > floorY then
				c.CFrame = stageCF * CFrame.new(x, y, z) * CFrame.Angles(q * (6 + k % 5), q * (4 + k % 3), q * (3 + k % 4))
				c.Transparency = math.clamp((floorY + 0.8 - y) / 0.8, 0, 1) -- fade just before the floor
			else
				c.Transparency = 1
			end
		else
			c.Transparency = 1
		end
	end
	return s
end

function HatchPlayer.Play(eggName: string, results: { any })
	if HatchPlayer.Busy then
		return
	end
	HatchPlayer.Busy = true
	local camera = workspace.CurrentCamera
	local oldType = camera.CameraType
	local oldCF = camera.CFrame
	local oldFov = camera.FieldOfView

	-- the hatch plays on its own little stage high above the map, so nothing in the
	-- world clutters it; the camera cuts there behind a quick fade to black
	local STAGE = CFrame.new(0, 4000, 0)
	local baseCF = CFrame.lookAt((STAGE * CFrame.new(0, 1.1, 0)).Position + Vector3.new(0, 0, 1) * 0, STAGE.Position)

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
	local black = Instance.new("Frame")
	black.Size = UDim2.fromScale(1, 1)
	black.BackgroundColor3 = Color3.new(0, 0, 0)
	black.BackgroundTransparency = 1
	black.BorderSizePixel = 0
	black.ZIndex = 5
	black.Parent = gui
	gui.Parent = player:WaitForChild("PlayerGui")

	-- fade to black, then cut to the stage
	for k = 1, 8 do
		black.BackgroundTransparency = 1 - k / 8
		task.wait(1 / 60)
	end

	local n = #results
	local spacing = if n > 1 then 5.4 else 0
	local dist = if n > 1 then 14 else 10.5
	baseCF = CFrame.lookAt((STAGE * CFrame.new(0, 1.3, dist)).Position, (STAGE * CFrame.new(0, 0.2, 0)).Position)
	camera.CameraType = Enum.CameraType.Scriptable
	camera.CFrame = baseCF

	-- the set: a deep backdrop, a soft halo behind the egg, and a glowing pedestal per egg
	local backdrop = part({ Name = "Backdrop", Size = Vector3.new(500, 500, 1), Color = Color3.fromRGB(14, 16, 34), Material = Enum.Material.SmoothPlastic })
	backdrop.CFrame = STAGE * CFrame.new(0, 0, -16)
	backdrop.Parent = folder
	local floor = part({ Name = "Floor", Size = Vector3.new(500, 1, 500), Color = Color3.fromRGB(22, 24, 46), Material = Enum.Material.SmoothPlastic })
	floor.CFrame = STAGE * CFrame.new(0, -3.4, 0)
	floor.Parent = folder
	local pedestals = {}
	local slots = {}
	for i, r in results do
		slots[i] = makeSlot(folder, eggName, r, i)
		slots[i].offset = (i - (n + 1) / 2) * spacing
		slots[i].crowded = n > 1
		local x = slots[i].offset
		local top = part({ Name = "Pedestal", Shape = Enum.PartType.Cylinder, Material = Enum.Material.SmoothPlastic, Color = Color3.fromRGB(40, 42, 70), Size = Vector3.new(0.6, 3.6, 3.6) })
		top.CFrame = STAGE * CFrame.new(x, -2.75, 0) * CFrame.Angles(0, 0, math.rad(90))
		top.Parent = folder
		-- a thin soft glowing edge (not a bright disc)
		local rim = part({ Name = "PedestalRim", Shape = Enum.PartType.Cylinder, Material = Enum.Material.Neon, Size = Vector3.new(0.12, 3.75, 3.75), Transparency = 0.45 })
		-- sits clearly inside the pedestal's height (top at -2.56 vs pedestal top -2.45) so the
		-- two surfaces never share a plane (no z-fighting / flicker)
		rim.CFrame = STAGE * CFrame.new(x, -2.62, 0) * CFrame.Angles(0, 0, math.rad(90))
		rim.Parent = folder
		pedestals[i] = rim
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
		local punch, charge = 0, 0
		for i, slot in slots do
			local stageCF = CFrame.lookAt((STAGE * CFrame.new(slot.offset, 0, 0)).Position, Vector3.new(camPos.X, (STAGE * CFrame.new(0, 0, 0)).Position.Y, camPos.Z))
			-- cues (sounds, particle bursts) at their exact times
			while slot.events[slot.nextEvent] and slot.events[slot.nextEvent][1] <= t do
				local ev = slot.events[slot.nextEvent]
				cue(slot, ev[2], ev[3])
				slot.nextEvent += 1
			end
			local tt = math.min(t, slot.timing.length)
			local s = update(slot, tt, stageCF, camPos)
			shake = math.max(shake, s.shake)
			flashA = math.max(flashA, s.flash)
			dim = math.max(dim, s.dim)
			local color = rarityColor(slot.rarity, t)
			pedestals[i].Color = color
			-- zoom in during the charge, punch out on the pop, settle back
			local T = slot.timing
			charge = math.max(charge, math.clamp((tt - T.shakes[1]) / (T.pop - T.shakes[1]), 0, 1))
			local pp = tt - T.pop
			if pp > 0 then
				punch = math.max(punch, math.exp(-pp / 0.18) * (6 + 2 * slot.drama))
			end
		end
		flash.BackgroundTransparency = 1 - flashA
		-- fade back out of black at the start, into black at the end
		black.BackgroundTransparency = math.clamp(t / 0.3, 0, 1) * (1 - math.clamp((t - length + 0.3) / 0.3, 0, 1))
		hint.TextTransparency = if skipTo == nil and t > 2.5 and t < length - 0.6 then 0.3 else 1
		local nx = math.noise(t * 25, 1.7) * shake
		local ny = math.noise(t * 25, 9.3) * shake
		local popped = punch > 0.01 or t > slots[1].timing.pop
		camera.FieldOfView = oldFov - (if popped then 0 else 9 * charge * charge) + punch
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
	camera.CFrame = oldCF
	camera.FieldOfView = oldFov
	camera.CameraType = if oldType == Enum.CameraType.Scriptable then Enum.CameraType.Custom else oldType
	-- fade back in from black over the world
	task.spawn(function()
		for k = 1, 12 do
			black.BackgroundTransparency = k / 12
			task.wait(1 / 60)
		end
		gui:Destroy()
	end)
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
