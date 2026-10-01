--!strict
-- Stud Gear (server). Every effect is applied here, from whatever gear a character is
-- holding: the tools themselves contain no scripts, so they can't break when copied,
-- dropped or used on mobile.
--
--   Speed / Jump: the Humanoid's WalkSpeed and JumpPower/JumpHeight, put back exactly when
--   the gear is unequipped (and other scripts' changes, like a sprint key, are respected).
--   Gravity: a VectorForce on the HumanoidRootPart, sized every frame from the character's
--   real mass (R6, R15, any accessories).
--
-- Give gear from your own scripts:
--   ServerScriptService.StudGearServer.GiveGear:Invoke(player, "Speed Coil")

local CollectionService = game:GetService("CollectionService")
local MarketplaceService = game:GetService("MarketplaceService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

-- the StudGear folder, even if it's still inside the package's 1_PutInReplicatedStorage
local function findSystem(): Instance
	local started = os.clock()
	local reported = false
	while true do
		local direct = ReplicatedStorage:FindFirstChild("StudGear")
		if direct and direct:IsA("Folder") then
			return direct
		end
		for _, d in ReplicatedStorage:GetDescendants() do
			if d.Name == "StudGear" and d:IsA("Folder") then
				return d
			end
		end
		if not reported and os.clock() - started > 6 then
			reported = true
			warn("[StudGear] ReplicatedStorage is missing the StudGear folder (from 1_PutInReplicatedStorage).")
		end
		task.wait(0.25)
	end
end
local System = findSystem()
local Config = require(System:WaitForChild("Config")) :: any
local Effects = require(System:WaitForChild("Effects")) :: any
local Tools = System:WaitForChild("Tools")
local Wearables = System:FindFirstChild("Wearables")

local byName: { [string]: any } = {}
for _, g in Config.Gear do
	byName[g.Name] = g
end

---------------------------------------------------------------------------
-- Ownership (game passes)
---------------------------------------------------------------------------
local owned: { [Player]: { [string]: boolean } } = {}

local function owns(player: Player, gear: any): boolean
	if (gear.GamePassId or 0) == 0 then
		return true
	end
	local list = owned[player]
	return list ~= nil and list[gear.Name] == true
end

local function publishOwned(player: Player)
	local names = {}
	for name in owned[player] or {} do
		table.insert(names, name)
	end
	player:SetAttribute("StudGearOwned", table.concat(names, ","))
end

local function loadOwned(player: Player)
	local list = {}
	owned[player] = list
	for _, g in Config.Gear do
		local id = g.GamePassId or 0
		if id ~= 0 then
			for _ = 1, 3 do
				local ok, has = pcall(MarketplaceService.UserOwnsGamePassAsync, MarketplaceService, player.UserId, id)
				if ok then
					list[g.Name] = has == true or nil
					break
				end
				task.wait(1)
			end
		end
	end
	publishOwned(player)
end

---------------------------------------------------------------------------
-- Giving gear
---------------------------------------------------------------------------
local function findTool(player: Player, name: string): Tool?
	for _, place in { player.Character, player:FindFirstChildOfClass("Backpack") } do
		if place then
			for _, t in place:GetChildren() do
				if t:IsA("Tool") and t:GetAttribute("StudGear") == name then
					return t
				end
			end
		end
	end
	return nil
end

local function give(player: Player, name: string, equip: boolean?): boolean
	local template = Tools:FindFirstChild(name)
	local backpack = player:FindFirstChildOfClass("Backpack")
	if not (template and backpack and byName[name]) then
		return false
	end
	local tool = findTool(player, name)
	if not tool then
		tool = template:Clone() :: Tool
		tool.CanBeDropped = Config.CanDrop == true
		tool.Parent = backpack
	end
	if equip then
		local character = player.Character
		local humanoid = character and character:FindFirstChildOfClass("Humanoid")
		if humanoid and humanoid.Health > 0 and tool then
			humanoid:EquipTool(tool)
		end
	end
	return true
end

local GiveGear = Instance.new("BindableFunction")
GiveGear.Name = "GiveGear"
GiveGear.OnInvoke = function(player: Player, name: string)
	return give(player, name, false)
end
GiveGear.Parent = script

---------------------------------------------------------------------------
-- Effects
---------------------------------------------------------------------------
type State = {
	humanoid: Humanoid,
	root: BasePart,
	speed: number,
	jump: number,
	gravity: number,
	baseWalk: number?,
	baseJumpPower: number?,
	baseJumpHeight: number?,
	appliedWalk: number?,
	appliedJumpPower: number?,
	appliedJumpHeight: number?,
	force: VectorForce?,
	regen: number,
	wear: Model?,
	rope: { Instance }?,
	trail: Trail?,
	trailAttachments: { Attachment }?,
}
local states: { [Model]: State } = {}

local RAINBOW = ColorSequence.new({
	ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 70, 70)),
	ColorSequenceKeypoint.new(0.2, Color3.fromRGB(255, 170, 40)),
	ColorSequenceKeypoint.new(0.4, Color3.fromRGB(255, 240, 70)),
	ColorSequenceKeypoint.new(0.6, Color3.fromRGB(70, 220, 110)),
	ColorSequenceKeypoint.new(0.8, Color3.fromRGB(70, 160, 255)),
	ColorSequenceKeypoint.new(1, Color3.fromRGB(170, 90, 255)),
})

local function rgb(t: { number }): Color3
	return Color3.fromRGB(t[1], t[2], t[3])
end

local function heldGear(character: Model): { any }
	local list = {}
	for _, c in character:GetChildren() do
		if c:IsA("Tool") then
			local g = byName[c:GetAttribute("StudGear") :: string? or ""]
			if g then
				table.insert(list, g)
			end
		end
	end
	return list
end

-- Sets `prop` to base * mult. If another script sets the value while gear is held (a
-- sprint key, a speed pad), that value becomes the new base and the gear stacks on top;
-- unequipping puts back whatever the base is by then.
local function applyStat(st: any, prop: string, baseKey: string, appliedKey: string, mult: number)
	local h = st.humanoid :: any
	local applied = st[appliedKey]
	if applied ~= nil and math.abs(h[prop] - applied) > 1e-3 then
		st[baseKey] = h[prop]
	end
	if mult ~= 1 then
		st[baseKey] = st[baseKey] or h[prop]
		st[appliedKey] = st[baseKey] * mult
		h[prop] = st[appliedKey]
	elseif st[baseKey] ~= nil then
		local base = st[baseKey]
		st[baseKey], st[appliedKey] = nil, nil
		h[prop] = base
	end
end

local function setTrail(st: State, gear: { any })
	local want = nil
	if Config.Trails then
		for _, g in gear do
			if (g.Look or "coil") == "coil" then
				want = g
			end
		end
	end
	if not want then
		if st.trail then
			st.trail:Destroy()
			for _, a in st.trailAttachments or {} do
				a:Destroy()
			end
			st.trail, st.trailAttachments = nil, nil
		end
		return
	end
	if not st.trail then
		local a0 = Instance.new("Attachment")
		a0.Name = "StudGearTrailTop"
		a0.Position = Vector3.new(0, 0.6, 0.4)
		a0.Parent = st.root
		local a1 = Instance.new("Attachment")
		a1.Name = "StudGearTrailBottom"
		a1.Position = Vector3.new(0, -1.6, 0.4)
		a1.Parent = st.root
		local trail = Instance.new("Trail")
		trail.Name = "StudGearTrail"
		trail.Attachment0, trail.Attachment1 = a0, a1
		trail.Lifetime = 0.35
		trail.MinLength = 0.2
		trail.LightEmission = 0.4
		trail.Transparency = NumberSequence.new({ NumberSequenceKeypoint.new(0, 0.35), NumberSequenceKeypoint.new(1, 1) })
		trail.WidthScale = NumberSequence.new({ NumberSequenceKeypoint.new(0, 1), NumberSequenceKeypoint.new(1, 0.2) })
		trail.FaceCamera = true
		trail.Parent = st.root
		st.trail, st.trailAttachments = trail, { a0, a1 }
	end
	local trail = st.trail :: Trail
	trail.Color = if want.Rainbow then RAINBOW else ColorSequence.new(rgb(want.Color), rgb(want.Accent or want.Color))
end

local function clearRope(st: State)
	for _, i in st.rope or {} do
		i:Destroy()
	end
	st.rope = nil
end

-- gear with a model in StudGear.Wearables (the jetpack) wears it on the back while equipped
local function setWear(st: State, character: Model)
	local source = nil
	for _, c in character:GetChildren() do
		if c:IsA("Tool") then
			local found = Wearables and Wearables:FindFirstChild(c:GetAttribute("StudGear") :: string? or "")
			source = found or source
		end
	end
	if st.wear and (not source or st.wear:GetAttribute("From") ~= source.Name) then
		st.wear:Destroy()
		st.wear = nil
	end
	local torso = character:FindFirstChild("UpperTorso") or character:FindFirstChild("Torso")
	if source and not st.wear and torso and torso:IsA("BasePart") then
		local wear = source:Clone() :: Model
		wear.Name = "StudGearWear"
		wear:SetAttribute("From", source.Name)
		local anchor = wear.PrimaryPart
		if anchor then
			for _, p in wear:GetDescendants() do
				if p:IsA("BasePart") then
					p.Anchored = false
					p.CanCollide = false
					p.Massless = true
				end
			end
			-- the Wear model is built with its anchor at the middle of the wearer's back
			wear:PivotTo(torso.CFrame * CFrame.new(0, 0, torso.Size.Z / 2) * anchor.CFrame:ToObjectSpace(wear:GetPivot()))
			local weld = Instance.new("WeldConstraint")
			weld.Part0 = torso
			weld.Part1 = anchor
			weld.Parent = anchor
			wear.Parent = character
			st.wear = wear
		end
	end
end

local refresh: (Model) -> ()
function refresh(character: Model)
	local humanoid = character:FindFirstChildOfClass("Humanoid")
	local root = character:FindFirstChild("HumanoidRootPart") :: BasePart?
	if not (humanoid and root) then
		return
	end
	local gear = heldGear(character)
	local fx = Effects.Combine(gear)
	local st = states[character]
	if not st then
		if not fx.active and #gear == 0 then
			return
		end
		st = { humanoid = humanoid, root = root, speed = 1, jump = 1, gravity = 1, regen = 0 } :: State
		states[character] = st
		-- another script changed a stat while gear is held: take it as the new base
		for prop, appliedKey in { WalkSpeed = "appliedWalk", JumpPower = "appliedJumpPower", JumpHeight = "appliedJumpHeight" } do
			humanoid:GetPropertyChangedSignal(prop):Connect(function()
				local s = states[character] :: any
				local applied = s and s[appliedKey]
				if applied ~= nil and math.abs((humanoid :: any)[prop] - applied) > 1e-3 then
					refresh(character)
				end
			end)
		end
	end
	local s = st :: State
	s.speed, s.jump, s.gravity, s.regen = fx.speed, fx.jump, fx.gravity, fx.regen
	applyStat(s, "WalkSpeed", "baseWalk", "appliedWalk", fx.speed)
	-- jump height scales with JumpPower squared; set both so either mode works
	applyStat(s, "JumpPower", "baseJumpPower", "appliedJumpPower", math.sqrt(fx.jump))
	applyStat(s, "JumpHeight", "baseJumpHeight", "appliedJumpHeight", fx.jump)
	if fx.gravity < 1 then
		if not s.force then
			local at = Instance.new("Attachment")
			at.Name = "StudGearGravityAttachment"
			at.Parent = root
			local force = Instance.new("VectorForce")
			force.Name = "StudGearGravity"
			force.Attachment0 = at
			force.RelativeTo = Enum.ActuatorRelativeTo.World
			force.ApplyAtCenterOfMass = true
			force.Force = Vector3.zero
			force.Parent = root
			s.force = force
		end
	elseif s.force then
		local at = s.force.Attachment0
		s.force:Destroy()
		if at then
			at:Destroy()
		end
		s.force = nil
	end
	setTrail(s, gear)
	setWear(s, character)
	if not fx.grapple then
		clearRope(s)
	end
end

-- keep every gravity force matched to the character's current mass, and heal Regen gear
RunService.Heartbeat:Connect(function(dt)
	local g = workspace.Gravity
	for character, st in states do
		local h = st.humanoid
		if st.regen > 0 and h.Health > 0 and h.Health < h.MaxHealth then
			h.Health = math.min(h.MaxHealth, h.Health + st.regen * dt)
		end
		if st.force then
			if st.root.Parent then
				st.force.Force = Vector3.new(0, Effects.LiftForce(st.root.AssemblyMass, g, st.gravity), 0)
			end
		end
		if not character.Parent then
			states[character] = nil
		end
	end
end)

local function watchCharacter(player: Player, character: Model)
	character.ChildAdded:Connect(function(c)
		if c:IsA("Tool") then
			refresh(character)
		end
	end)
	character.ChildRemoved:Connect(function(c)
		if c:IsA("Tool") then
			refresh(character)
		end
	end)
	character.AncestryChanged:Connect(function()
		if not character.Parent then
			states[character] = nil
		end
	end)
	-- hand out owned gear for this life
	task.spawn(function()
		if not player:FindFirstChildOfClass("Backpack") then
			player.ChildAdded:Wait()
		end
		if owned[player] == nil then
			loadOwned(player)
		end
		for _, g in Config.Gear do
			local paid = (g.GamePassId or 0) ~= 0
			if (paid and owns(player, g)) or (not paid and Config.GiveFreeGearOnSpawn) then
				give(player, g.Name, false)
			end
		end
	end)
	refresh(character)
end

local function onPlayer(player: Player)
	task.spawn(loadOwned, player)
	player.CharacterAdded:Connect(function(c)
		watchCharacter(player, c)
	end)
	if player.Character then
		watchCharacter(player, player.Character)
	end
end
Players.PlayerAdded:Connect(onPlayer)
for _, p in Players:GetPlayers() do
	task.spawn(onPlayer, p)
end
Players.PlayerRemoving:Connect(function(p)
	owned[p] = nil
end)

---------------------------------------------------------------------------
-- What other players should see of client-side gear: jetpack flames, grapple ropes
---------------------------------------------------------------------------
local remotes = System:FindFirstChild("Remotes") or Instance.new("Folder")
remotes.Name = "Remotes"
local FxRemote = remotes:FindFirstChild("GearFx") or Instance.new("RemoteEvent")
FxRemote.Name = "GearFx"
FxRemote.Parent = remotes
remotes.Parent = System

local budget: { [Player]: { t: number, n: number } } = {}
FxRemote.OnServerEvent:Connect(function(player: Player, kind: any, value: any)
	-- at most 20 messages a second per player
	local now = os.clock()
	local b = budget[player]
	if not b or now - b.t > 1 then
		b = { t = now, n = 0 }
		budget[player] = b
	end
	b.n += 1
	if b.n > 20 then
		return
	end
	local character = player.Character
	local st = character and states[character]
	if not (character and st) then
		return
	end
	local fx = Effects.Combine(heldGear(character))
	if kind == "Jet" then
		if fx.jetpack and st.wear then
			for _, e in st.wear:GetDescendants() do
				if e:IsA("ParticleEmitter") or e:IsA("PointLight") then
					e.Enabled = value == true
				end
			end
		end
	elseif kind == "Rope" then
		clearRope(st)
		if typeof(value) ~= "Vector3" or not fx.grapple then
			return
		end
		if (value - st.root.Position).Magnitude > (fx.grapple.Range or 120) + 20 then
			return
		end
		local muzzle = nil
		for _, c in character:GetChildren() do
			if c:IsA("Tool") and c:FindFirstChild("Muzzle", true) then
				muzzle = c:FindFirstChild("Muzzle", true)
			end
		end
		if not (muzzle and muzzle:IsA("Attachment")) then
			return
		end
		local target = Instance.new("Attachment")
		target.Name = "StudGearRopeEnd"
		target.WorldPosition = value
		target.Parent = workspace.Terrain
		local beam = Instance.new("Beam")
		beam.Name = "StudGearRope"
		beam.Attachment0 = muzzle
		beam.Attachment1 = target
		beam.Width0, beam.Width1 = 0.16, 0.16
		beam.FaceCamera = true
		beam.Segments = 1
		beam.LightInfluence = 1
		beam.Color = ColorSequence.new(Color3.fromRGB(70, 60, 50))
		beam:SetAttribute("Owner", player.UserId)
		beam.Parent = target
		st.rope = { beam, target }
		-- never leave a rope behind
		task.delay(4, function()
			if st.rope and st.rope[2] == target then
				clearRope(st)
			end
		end)
	end
end)
Players.PlayerRemoving:Connect(function(p)
	budget[p] = nil
end)

---------------------------------------------------------------------------
-- Display stands: Get (free) / Equip (owned) / Buy (game pass)
---------------------------------------------------------------------------
local lastPrompt: { [Player]: number } = {}

local function setupDisplay(stand: Instance)
	local name = stand:GetAttribute("StudGearDisplay")
	local gear = name and byName[name]
	if not gear or not stand:IsA("Model") or stand:FindFirstChild("StudGearPrompt", true) then
		return
	end
	local anchor = stand.PrimaryPart or stand:FindFirstChildWhichIsA("BasePart")
	if not anchor then
		return
	end
	local prompt = Instance.new("ProximityPrompt")
	prompt.Name = "StudGearPrompt"
	prompt.ObjectText = gear.Name
	prompt.ActionText = if (gear.GamePassId or 0) == 0 then "Get" else "Buy"
	prompt.HoldDuration = 0
	prompt.MaxActivationDistance = 10
	prompt.RequiresLineOfSight = false
	prompt.Parent = anchor
	prompt.Triggered:Connect(function(player)
		if os.clock() - (lastPrompt[player] or 0) < 0.4 then
			return
		end
		lastPrompt[player] = os.clock()
		if owns(player, gear) then
			give(player, gear.Name, true)
		else
			MarketplaceService:PromptGamePassPurchase(player, gear.GamePassId)
		end
	end)
end
for _, s in CollectionService:GetTagged("StudGearDisplay") do
	task.spawn(setupDisplay, s)
end
CollectionService:GetInstanceAddedSignal("StudGearDisplay"):Connect(setupDisplay)

MarketplaceService.PromptGamePassPurchaseFinished:Connect(function(player, passId, purchased)
	if not purchased then
		return
	end
	owned[player] = owned[player] or {}
	for _, g in Config.Gear do
		if g.GamePassId == passId then
			owned[player][g.Name] = true
			give(player, g.Name, true)
		end
	end
	publishOwned(player)
end)
