--!strict
-- Stud Pets demo (client):
--  * Pets marked "Showcase" cycle through every animation with a name tag.
--  * A pet follows you and picks Idle / Walk / Run from its speed, jumps when
--    you jump, sits after 5 s idle and falls asleep after 12 s.
--    G = trick, P / O = next / previous pet (all 50).
-- The follower is local-only (other players don't see it); it's a demo of the
-- animation system, not a networked pet system.

local CollectionService = game:GetService("CollectionService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local StudPets = ReplicatedStorage:WaitForChild("StudPets")
local PetAnimator = require(StudPets:WaitForChild("PetAnimator"))
local PetModels = ReplicatedStorage:WaitForChild("StudPetModels")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui") :: PlayerGui

local FOLLOW_SCALE = 0.55
local FOLLOW_OFFSET = Vector3.new(3.5, 0, 3) -- right of and behind the player
local SIT_AFTER, SLEEP_AFTER = 5, 12

local function makeTag(adornee: BasePart, height: number): TextLabel
	local gui = Instance.new("BillboardGui")
	gui.Name = "StudPetTag"
	gui.Adornee = adornee
	gui.Size = UDim2.fromOffset(220, 44)
	gui.StudsOffset = Vector3.new(0, height, 0)
	gui.MaxDistance = 45
	local label = Instance.new("TextLabel")
	label.BackgroundTransparency = 1
	label.Size = UDim2.fromScale(1, 1)
	label.FontFace = Font.new("rbxasset://fonts/families/FredokaOne.json")
	label.TextScaled = true
	label.TextColor3 = Color3.new(1, 1, 1)
	label.TextStrokeTransparency = 0.2
	label.Parent = gui
	gui.Parent = playerGui
	return label
end

---------------------------------------------------------------------------
-- Showcase pedestals
---------------------------------------------------------------------------
local showcased: { [Model]: boolean } = {}

local function showcase(model: Instance)
	if not model:IsA("Model") or not model:GetAttribute("Showcase") or showcased[model] then
		return
	end
	local root = model.PrimaryPart or model:WaitForChild("RootPart", 10) :: BasePart?
	if not root then
		return
	end
	showcased[model] = true
	local animator = PetAnimator.new(model)
	local label = makeTag(root, 3.2)
	task.spawn(function()
		while model.Parent do
			for _, name in animator.Set.Order do
				if not model.Parent then
					break
				end
				local anim = animator.Set.Anims[name]
				animator:Play(name, 0.3)
				label.Text = `{model:GetAttribute("StudPet")} · {name}`
				task.wait(if anim.Looped then math.max(3.5, anim.Length * 2) else anim.Length + 0.4)
			end
		end
		local gui = label.Parent
		if gui then
			gui:Destroy()
		end
		showcased[model] = nil
	end)
end

for _, model in CollectionService:GetTagged("StudPet") do
	task.spawn(showcase, model)
end
CollectionService:GetInstanceAddedSignal("StudPet"):Connect(showcase)

---------------------------------------------------------------------------
-- Follower
---------------------------------------------------------------------------
type Follower = {
	model: Model,
	animator: any,
	petType: string,
	rootHeight: number,
	pos: Vector3?,
	vel: Vector3,
	yaw: number,
	still: number,
}

local follower: Follower? = nil
local petTypes = PetAnimator.GetTypes()
local petIndex = 1

local rayParams = RaycastParams.new()
rayParams.FilterType = Enum.RaycastFilterType.Exclude

local function spawnFollower(petType: string)
	if follower then
		follower.animator:Destroy()
		follower.model:Destroy()
		follower = nil
	end
	local template = PetModels:WaitForChild("Stud" .. petType) :: Model
	local model = template:Clone()
	model:SetAttribute("Showcase", nil)
	-- big pets stay big, but not so big they swallow the player
	local followScale = FOLLOW_SCALE / math.sqrt((model:GetAttribute("AnimScale") :: number?) or 1)
	model:ScaleTo(followScale)
	model.Name = "MyStud" .. petType
	model.Parent = workspace
	follower = {
		model = model,
		animator = PetAnimator.new(model),
		petType = petType,
		rootHeight = (model:GetAttribute("RootHeight") :: number) * followScale,
		pos = nil,
		vel = Vector3.zero,
		yaw = 0,
		still = 0,
	}
end

local function angleLerp(a: number, b: number, t: number): number
	local d = (b - a + math.pi) % (2 * math.pi) - math.pi
	return a + d * t
end

local function hookHumanoid(character: Model)
	local humanoid = character:WaitForChild("Humanoid") :: Humanoid
	humanoid.StateChanged:Connect(function(_, new)
		local f = follower
		if f and new == Enum.HumanoidStateType.Jumping then
			f.still = 0
			f.animator:Play("Jump", 0.1)
		end
	end)
end

RunService.RenderStepped:Connect(function(dt)
	local f = follower
	local character = player.Character
	local hrp = character and character:FindFirstChild("HumanoidRootPart") :: BasePart?
	if not f or not hrp or not character then
		return
	end

	local target = (hrp.CFrame * CFrame.new(FOLLOW_OFFSET)).Position
	local pos = f.pos or target
	local flat = Vector3.new(target.X - pos.X, 0, target.Z - pos.Z)
	local dist = flat.Magnitude
	if dist > 60 then -- fell far behind (teleport, respawn): catch up instantly
		pos, dist, flat = target, 0, Vector3.zero
	end

	-- steer toward the slot behind the player; ease in/out so it never jitters
	local desired = if dist > 0.6 then flat.Unit * math.min(dist * 4, 32) else Vector3.zero
	f.vel = f.vel:Lerp(desired, 1 - math.exp(-8 * dt))
	pos += f.vel * dt
	f.pos = pos
	local speed = f.vel.Magnitude

	rayParams.FilterDescendantsInstances = { character, f.model }
	local hit = workspace:Raycast(pos + Vector3.new(0, 6, 0), Vector3.new(0, -30, 0), rayParams)
	local groundY = if hit then hit.Position.Y else hrp.Position.Y - 3

	local faceYaw = if speed > 0.8
		then math.atan2(-f.vel.X, -f.vel.Z)
		else select(2, hrp.CFrame:ToOrientation())
	f.yaw = angleLerp(f.yaw, faceYaw, 1 - math.exp(-10 * dt))
	f.model:PivotTo(CFrame.new(pos.X, groundY + f.rootHeight, pos.Z) * CFrame.Angles(0, f.yaw, 0))

	-- choose an animation (one-shots like Jump / tricks finish first)
	local animator = f.animator
	if animator:IsBusy() then
		return
	end
	if speed > 11 then
		f.still = 0
		animator:Play("Run", 0.2, math.clamp(speed / 16, 0.8, 1.7))
	elseif speed > 0.8 then
		f.still = 0
		animator:Play("Walk", 0.2, math.clamp(speed / 5, 0.6, 1.8))
	else
		f.still += dt
		animator:Play(if f.still > SLEEP_AFTER then "Sleep" elseif f.still > SIT_AFTER then "Sit" else "Idle", 0.45)
	end
end)

UserInputService.InputBegan:Connect(function(input, processed)
	if processed then
		return
	end
	if input.KeyCode == Enum.KeyCode.G and follower then
		follower.still = 0
		follower.animator:Play(follower.animator.Set.Trick, 0.15)
	elseif input.KeyCode == Enum.KeyCode.P or input.KeyCode == Enum.KeyCode.O then
		local step = if input.KeyCode == Enum.KeyCode.P then 1 else -1
		petIndex = (petIndex - 1 + step) % #petTypes + 1
		spawnFollower(petTypes[petIndex])
	end
end)

-- hint
do
	local screen = Instance.new("ScreenGui")
	screen.Name = "StudPetsHint"
	screen.ResetOnSpawn = false
	local label = Instance.new("TextLabel")
	label.AnchorPoint = Vector2.new(0.5, 1)
	label.Position = UDim2.new(0.5, 0, 1, -16)
	label.Size = UDim2.fromOffset(360, 32)
	label.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
	label.BackgroundTransparency = 0.3
	label.FontFace = Font.new("rbxasset://fonts/families/FredokaOne.json")
	label.TextSize = 18
	label.TextColor3 = Color3.new(1, 1, 1)
	label.Text = "G  trick     P / O  next / previous pet"
	Instance.new("UICorner").Parent = label
	label.Parent = screen
	screen.Parent = playerGui
end

if player.Character then
	task.spawn(hookHumanoid, player.Character)
end
player.CharacterAdded:Connect(hookHumanoid)
spawnFollower(petTypes[petIndex])
