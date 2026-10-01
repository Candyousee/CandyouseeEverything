-- Shows every player's equipped pets following them (each client draws everyone's
-- pets locally from the "StudPetsEquipped" player attribute - no server physics).

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local PetAnimator = require(ReplicatedStorage:WaitForChild("StudPets"):WaitForChild("PetAnimator"))
local PetModels = ReplicatedStorage:WaitForChild("StudPetModels")

local FOLLOW_SCALE = 0.55
local SIT_AFTER, SLEEP_AFTER = 5, 12
local DRAW_DISTANCE = 160

local Followers = {}

type Pet = {
	model: Model,
	anim: any,
	rootHeight: number,
	stride: number,
	pos: Vector3?,
	vel: Vector3,
	yaw: number,
	still: number,
}

local owners: { [Player]: { key: string, pets: { Pet } } } = {}
local folder = Instance.new("Folder")
folder.Name = "StudPetFollowers"
folder.Parent = workspace

local rayParams = RaycastParams.new()
rayParams.FilterType = Enum.RaycastFilterType.Exclude
rayParams.FilterDescendantsInstances = { folder }

local function spawnPet(petType: string): Pet?
	local template = PetModels:FindFirstChild("Stud" .. petType)
	if not template then
		return nil
	end
	local model = template:Clone()
	model:SetAttribute("Showcase", nil)
	local animScale = (model:GetAttribute("AnimScale") :: number?) or 1
	local scale = FOLLOW_SCALE / math.sqrt(animScale) -- big pets stay big, but not huge
	model:ScaleTo(scale)
	model.Parent = folder
	return {
		model = model,
		anim = PetAnimator.new(model),
		rootHeight = ((model:GetAttribute("RootHeight") :: number?) or 1) * scale,
		stride = scale * animScale / FOLLOW_SCALE,
		pos = nil,
		vel = Vector3.zero,
		yaw = 0,
		still = 0,
	}
end

local function clear(player: Player)
	local o = owners[player]
	if o then
		for _, p in o.pets do
			p.anim:Destroy()
			p.model:Destroy()
		end
		owners[player] = nil
	end
end

local function refresh(player: Player)
	local key = (player:GetAttribute("StudPetsEquipped") :: string?) or ""
	local o = owners[player]
	if o and o.key == key then
		return
	end
	clear(player)
	local pets = {}
	for petType in key:gmatch("[^,]+") do
		local p = spawnPet(petType)
		if p then
			table.insert(pets, p)
		end
	end
	owners[player] = { key = key, pets = pets }
end

local function angleLerp(a: number, b: number, t: number): number
	local d = (b - a + math.pi) % (2 * math.pi) - math.pi
	return a + d * t
end

-- slot behind the player: a small arc
local function slotOffset(i: number, n: number): Vector3
	local spread = math.rad(55)
	local a = if n == 1 then 0 else -spread / 2 + spread * (i - 1) / (n - 1)
	local r = 5 + 0.6 * n
	return Vector3.new(math.sin(a) * r, 0, math.cos(a) * r)
end

local function step(dt: number)
	local cam = workspace.CurrentCamera
	for player, o in owners do
		local character = player.Character
		local hrp = character and character:FindFirstChild("HumanoidRootPart") :: BasePart?
		if not hrp or not character then
			continue
		end
		local far = cam and (hrp.Position - cam.CFrame.Position).Magnitude > DRAW_DISTANCE
		for i, p in o.pets do
			p.model.Parent = if far then nil else folder
			if far then
				p.pos = nil
				continue
			end
			local target = (hrp.CFrame * CFrame.new(slotOffset(i, #o.pets))).Position
			local pos = p.pos or target
			local flat = Vector3.new(target.X - pos.X, 0, target.Z - pos.Z)
			local dist = flat.Magnitude
			if dist > 60 then
				pos, dist, flat = target, 0, Vector3.zero
			end
			local desired = if dist > 0.6 then flat.Unit * math.min(dist * 4, 32) else Vector3.zero
			p.vel = p.vel:Lerp(desired, 1 - math.exp(-8 * dt))
			pos += p.vel * dt
			p.pos = pos
			local speed = p.vel.Magnitude
			rayParams.FilterDescendantsInstances = { folder, character }
			local hit = workspace:Raycast(pos + Vector3.new(0, 6, 0), Vector3.new(0, -30, 0), rayParams)
			local groundY = if hit then hit.Position.Y else hrp.Position.Y - 3
			local faceYaw = if speed > 0.8 then math.atan2(-p.vel.X, -p.vel.Z) else select(2, hrp.CFrame:ToOrientation())
			p.yaw = angleLerp(p.yaw, faceYaw, 1 - math.exp(-10 * dt))
			p.model:PivotTo(CFrame.new(pos.X, groundY + p.rootHeight, pos.Z) * CFrame.Angles(0, p.yaw, 0))
			if p.anim:IsBusy() then
				continue
			end
			if speed > 11 then
				p.still = 0
				p.anim:Play("Run", 0.2, math.clamp(speed / (16 * p.stride), 0.6, 1.7))
			elseif speed > 0.8 then
				p.still = 0
				p.anim:Play("Walk", 0.2, math.clamp(speed / (5 * p.stride), 0.5, 1.8))
			else
				p.still += dt
				p.anim:Play(if p.still > SLEEP_AFTER then "Sleep" elseif p.still > SIT_AFTER then "Sit" else "Idle", 0.45)
			end
		end
	end
end

-- make one player's pets jump (e.g. when they jump)
function Followers.Jump(player: Player)
	local o = owners[player]
	if o then
		for _, p in o.pets do
			p.still = 0
			if not p.anim:IsBusy() then
				p.anim:Play("Jump", 0.1)
			end
		end
	end
end

function Followers.Start()
	local function watch(player: Player)
		refresh(player)
		player:GetAttributeChangedSignal("StudPetsEquipped"):Connect(function()
			refresh(player)
		end)
		local function hook(character: Model)
			local humanoid = character:WaitForChild("Humanoid", 10) :: Humanoid?
			if humanoid then
				humanoid.StateChanged:Connect(function(_, new)
					if new == Enum.HumanoidStateType.Jumping then
						Followers.Jump(player)
					end
				end)
			end
		end
		if player.Character then
			task.spawn(hook, player.Character)
		end
		player.CharacterAdded:Connect(hook)
	end
	for _, p in Players:GetPlayers() do
		watch(p)
	end
	Players.PlayerAdded:Connect(watch)
	Players.PlayerRemoving:Connect(clear)
	RunService.RenderStepped:Connect(step)
end

return Followers
