--!strict
-- Plays Stud Pet animations straight from code: no uploads, no asset IDs.
-- Each frame it evaluates the pet's animation and writes Motor6D.Transform,
-- with smooth crossfades between animations. Run it on the client.
--
--   local PetAnimator = require(ReplicatedStorage.StudPets.PetAnimator)
--   local anim = PetAnimator.new(petModel)       -- reads the model's "StudPet" attribute (pet type)
--   anim:Play("Walk", 0.2, 1.3)                  -- name, fade seconds, playback speed
--   anim:Play("Jump")                            -- one-shots return to Idle by themselves
--   anim:Destroy()
--
-- Pet types: Cat, Dog + every entry in Animals.luau (PetAnimator.GetTypes()).
-- Want real Animation assets instead? Open an editor rig in the Animation Editor:
-- every animation is in AnimSaves, ready to publish.

local StudPets = script.Parent
local AnimLib = require(StudPets.AnimLib)
local Quadruped = require(StudPets.QuadrupedAnims)(AnimLib)
local Animals = require(StudPets.Animals)
local Plans = {
	Quadruped = Quadruped,
	Flyer = require(StudPets.FlyerAnims)(AnimLib, Quadruped),
	Swimmer = require(StudPets.SwimmerAnims)(AnimLib, Quadruped),
	Biped = require(StudPets.BipedAnims)(AnimLib, Quadruped),
}

type PoseSet = AnimLib.PoseSet
type Anim = AnimLib.Anim

export type PetSet = {
	Spec: any,
	Anims: { [string]: Anim },
	Order: { string },
	Trick: string,
}

export type Options = {
	PetType: string?,
	Default: string?, -- animation to return to after one-shots (default "Idle")
	AutoStep: boolean?, -- false = call :Step(dt) yourself
	OnFinished: ((name: string) -> ())?,
}

local PetAnimator = {}
PetAnimator.__index = PetAnimator

export type PetAnimator = typeof(setmetatable(
	{} :: {
		Model: Model,
		Set: PetSet,
		Motors: { [string]: Motor6D },
		Current: Anim,
		Time: number,
		Speed: number,
		Default: string,
		From: PoseSet?,
		Fade: number,
		FadeTime: number,
		OnFinished: ((name: string) -> ())?,
		CanScale: boolean,
		AnimScale: number,
		_conns: { RBXScriptConnection },
		_destroyed: boolean,
	},
	PetAnimator
))

local CULL_DISTANCE = 250 -- stop posing pets the camera can't see well

local sets: { [string]: PetSet } = {}
local live: { [PetAnimator]: boolean } = {}
local byModel: { [Model]: PetAnimator } = setmetatable({}, { __mode = "kv" }) :: any
local stepConnection: RBXScriptConnection? = nil

function PetAnimator.GetSet(petType: string): PetSet
	local set = sets[petType]
	if not set then
		local module = StudPets.Pets:FindFirstChild(petType)
		if module and module:IsA("ModuleScript") then
			set = (require(module) :: any)(AnimLib, Quadruped) -- hand-built pets (Cat, Dog)
		else
			local entry = Animals.ByName[petType]
			assert(entry, `StudPets: unknown pet type "{petType}"`)
			set = Plans[entry.Plan].fromParams(entry)
		end
		sets[petType] = set
	end
	return set :: PetSet
end

-- Every pet type name, Cat and Dog first.
function PetAnimator.GetTypes(): { string }
	local types = { "Cat", "Dog" }
	for _, name in Animals.Order do
		table.insert(types, name)
	end
	return types
end

local function stepAll(dt: number)
	local camera = workspace.CurrentCamera
	local camPos = camera and camera.CFrame.Position
	for animator in live do
		local root = animator.Model.PrimaryPart
		local far = camPos ~= nil and root ~= nil and (root.Position - camPos).Magnitude > CULL_DISTANCE
		animator:Step(dt, far)
	end
end

local function startStepping()
	if not stepConnection then
		local RunService = game:GetService("RunService")
		-- Stepped runs before physics, which is when joint transforms must be set
		stepConnection = RunService.Stepped:Connect(function(_, dt)
			stepAll(dt)
		end)
	end
end

local function stopSteppingIfIdle()
	if next(live) == nil and stepConnection then
		stepConnection:Disconnect()
		stepConnection = nil
	end
end

function PetAnimator.new(model: Model, options: Options?): PetAnimator
	local opts: Options = options or {}
	local petType = opts.PetType or model:GetAttribute("StudPet")
	assert(type(petType) == "string", `StudPets: {model:GetFullName()} has no StudPet attribute`)

	local set = PetAnimator.GetSet(petType)
	local default = opts.Default or "Idle"
	local self = setmetatable({
		Model = model,
		Set = set,
		Motors = {},
		Current = set.Anims[default],
		Time = 0,
		Speed = 1,
		Default = default,
		From = nil,
		Fade = 0,
		FadeTime = 0,
		OnFinished = opts.OnFinished,
		_conns = {},
		_destroyed = false,
		CanScale = (pcall(function()
			return model:GetScale()
		end)),
		AnimScale = (model:GetAttribute("AnimScale") :: number?) or 1,
	}, PetAnimator)
	assert(self.Current, `StudPets: {petType} has no "{default}" animation`)

	-- one animator per model: a new one replaces the old
	local old = byModel[model]
	if old then
		old:Destroy()
	end
	byModel[model] = self

	local function addMotor(d: Instance)
		if d:IsA("Motor6D") and d.Part1 then
			self.Motors[d.Part1.Name] = d
		end
	end
	for _, d in model:GetDescendants() do
		addMotor(d)
	end
	-- parts that stream in later still get animated
	table.insert(self._conns, model.DescendantAdded:Connect(addMotor))

	if opts.AutoStep ~= false then
		-- pause while the model is out of the game (parented to nil, pooled...), resume when it's back.
		-- Destroying the model disconnects this and lets the animator be collected.
		local function refresh()
			if self._destroyed then
				return
			end
			if model:IsDescendantOf(game) then
				live[self] = true
				startStepping()
			else
				live[self] = nil
				stopSteppingIfIdle()
			end
		end
		table.insert(self._conns, model.AncestryChanged:Connect(refresh))
		refresh()
	end

	-- start looping animations at a random point so neighbouring pets don't move in lockstep
	if self.Current.Looped then
		self.Time = math.random() * self.Current.Length
	end
	self:Step(0)
	return self
end

-- Start an animation. Calling it again for the looping animation that is
-- already playing just updates the speed, so it is safe to call every frame.
function PetAnimator.Play(self: PetAnimator, name: string, fadeTime: number?, speed: number?)
	local anim = self.Set.Anims[name]
	assert(anim, `StudPets: unknown animation "{name}"`)
	if anim == self.Current and anim.Looped then
		self.Speed = speed or self.Speed
		return
	end
	self.From = self:GetPose()
	self.FadeTime = fadeTime or 0.2
	self.Fade = 0
	self.Current = anim
	self.Time = 0
	-- one-shots must move forward or they would never finish
	self.Speed = if anim.Looped then speed or 1 else math.max(speed or 1, 0.01)
end

function PetAnimator.GetName(self: PetAnimator): string
	return self.Current.Name
end

-- True while a one-shot (Jump, tricks) is still playing.
function PetAnimator.IsBusy(self: PetAnimator): boolean
	return not self.Current.Looped
end

function PetAnimator.GetPose(self: PetAnimator): PoseSet
	local pose = AnimLib.sample(self.Current, self.Time)
	local from = self.From
	if from and self.FadeTime > 0 then
		local a = math.clamp(self.Fade / self.FadeTime, 0, 1)
		pose = AnimLib.blend(from, pose, a * a * (3 - 2 * a))
	end
	return pose
end

function PetAnimator.Step(self: PetAnimator, dt: number, skipPose: boolean?)
	self.Time += dt * self.Speed
	if self.From then
		self.Fade += dt
		if self.Fade >= self.FadeTime then
			self.From = nil
		end
	end
	local current = self.Current
	if not current.Looped and self.Time >= current.Length then
		self:Play(self.Default, 0.25)
		if self.OnFinished then
			-- spawned so an error in user code can't stop the other pets this frame
			task.spawn(self.OnFinished, current.Name)
		end
	end
	if not skipPose then
		self:_apply(self:GetPose())
	end
end

function PetAnimator._apply(self: PetAnimator, pose: PoseSet)
	-- Motor offsets scale with Model:ScaleTo(); our translations must too.
	-- kit pets are built at their own size (AnimScale); Model:ScaleTo() adds on top
	local s = (if self.CanScale then self.Model:GetScale() else 1) * self.AnimScale
	local rad = math.rad
	for name, motor in self.Motors do
		local p = pose[name]
		if p then
			motor.Transform = CFrame.new(p[4] * s, p[5] * s, p[6] * s) * CFrame.Angles(rad(p[1]), rad(p[2]), rad(p[3]))
		else
			motor.Transform = CFrame.new()
		end
	end
end

function PetAnimator.Destroy(self: PetAnimator)
	if self._destroyed then
		return
	end
	self._destroyed = true
	live[self] = nil
	for _, c in self._conns do
		c:Disconnect()
	end
	table.clear(self._conns)
	if byModel[self.Model] == self then
		byModel[self.Model] = nil
		for _, motor in self.Motors do
			if motor.Parent then
				motor.Transform = CFrame.new()
			end
		end
	end
	stopSteppingIfIdle()
end

return PetAnimator
