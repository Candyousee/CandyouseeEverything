-- Runtime smoke test (run from the StudPets folder after `rojo build -o StudPets.rbxl`):
--   lune run build/test_runtime.luau StudPets.rbxl
-- Opens the built place, checks its structure, compiles every script and drives
-- the real PetAnimator module against the real pet models.

local fs = require("@lune/fs")
local luau = require("@lune/luau")
local process = require("@lune/process")
local roblox = require("@lune/roblox")

local placePath = process.args[1] or "StudPets.rbxl"
local game = roblox.deserializePlace(fs.readFile(placePath))
local failures = 0

local passes = 0
local function check(ok: boolean, msg: string)
	if ok then
		passes += 1
	else
		failures += 1
		print("  FAIL " .. msg)
	end
end

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")
local Workspace = game:GetService("Workspace")

print("[structure]")
local StudPets = ReplicatedStorage:FindFirstChild("StudPets")
check(StudPets ~= nil, "ReplicatedStorage.StudPets")
for _, name in { "AnimLib", "QuadrupedAnims", "PetAnimator" } do
	local m = StudPets:FindFirstChild(name)
	check(m ~= nil and m.ClassName == "ModuleScript", "module " .. name)
end
local models = ReplicatedStorage:FindFirstChild("StudPetModels")
local petNames = {}
for _, m in models:GetChildren() do
	table.insert(petNames, m.Name)
end
table.sort(petNames)
check(#petNames == 50, ("StudPetModels has 50 pets (found %d)"):format(#petNames))
local quiet = true
for _, petName in petNames do
	local model = models and models:FindFirstChild(petName)
	check(model ~= nil and model.ClassName == "Model", petName .. " model")
	if model then
		local motors, parts = 0, 0
		for _, d in model:GetDescendants() do
			if d.ClassName == "Motor6D" then
				motors += 1
			elseif d:IsA("BasePart") then
				parts += 1
			end
		end
		check(model.PrimaryPart ~= nil and model.PrimaryPart.Name == "RootPart" and model.PrimaryPart.Anchored, petName .. " anchored RootPart is PrimaryPart")
		check(model:HasTag("StudPet") and model:GetAttribute("StudPet") ~= nil, petName .. " tagged + StudPet attribute")
		check(motors >= 6 and parts <= 80, ("%s: %d parts, %d Motor6D joints"):format(petName, parts, motors))
	end
end
for _, petName in { "StudCat", "StudDog" } do
	local rig = ServerStorage.StudPetEditorRigs:FindFirstChild(petName .. "_EditorRig")
	local saves = rig and rig:FindFirstChild("AnimSaves")
	check(saves ~= nil and #saves:GetChildren() == 7, petName .. " editor rig has 7 KeyframeSequences in AnimSaves")
end
local demo = Workspace:FindFirstChild("StudPetsDemo")
local showcase = 0
for _, d in demo:GetChildren() do
	if d:GetAttribute("Showcase") then
		showcase += 1
	end
end
check(showcase == 50, "demo has 50 showcase pets")

print("[compile]")
for _, d in game:GetDescendants() do
	if d:IsA("LuaSourceContainer") then
		local ok, err = pcall(luau.compile, d.Source)
		check(ok, "compiles " .. d:GetFullName() .. (if ok then "" else ": " .. tostring(err)))
	end
end

print("[PetAnimator]")
-- minimal Roblox module loader: script, require(ModuleScript), CFrame
local cache = {}
local function robloxRequire(module)
	if cache[module] == nil then
		local fn = luau.load(module.Source, {
			debugName = module:GetFullName(),
			environment = { script = module, require = robloxRequire, CFrame = roblox.CFrame, Vector3 = roblox.Vector3 },
		})
		cache[module] = fn()
	end
	return cache[module]
end
local PetAnimator = robloxRequire(StudPets.PetAnimator)

for _, petName in petNames do
	local model = models:FindFirstChild(petName)
	local finished = {}
	local animator = PetAnimator.new(model, {
		AutoStep = false,
		OnFinished = function(name)
			table.insert(finished, name)
		end,
	})
	local head = animator.Motors.Head
	check(head ~= nil and animator.Motors.Torso ~= nil, petName .. " motors found by Part1 name")
	local mover = animator.Motors.Torso
	for _, name in animator.Set.Order do
		animator:Play(name, 0.2)
		local anim = animator.Set.Anims[name]
		local moved, bad = false, false
		local first = nil
		for _ = 1, math.ceil(anim.Length * 60) + 5 do
			animator:Step(1 / 60)
			local c = { head.Transform:GetComponents() }
			for _, v in c do
				if v ~= v or math.abs(v) > 1e3 then
					bad = true
				end
			end
			local legs = mover.Transform
			first = first or legs
			if (legs.Position - first.Position).Magnitude > 1e-4 or legs.LookVector:Dot(first.LookVector) < 0.99999 then
				moved = true
			end
		end
		check(not bad, ("%s %s: finite transforms"):format(petName, name))
		if name ~= "Sit" and name ~= "Sleep" then
			check(moved, ("%s %s: body actually moves"):format(petName, name))
		end
		if not anim.Looped then
			check(finished[#finished] == name and animator:GetName() == "Idle", ("%s %s: one-shot finishes and returns to Idle"):format(petName, name))
		end
	end
	-- calling Play every frame for the running loop must not restart it
	animator:Play("Walk", 0.2, 1)
	animator:Step(0.3)
	local t = animator.Time
	animator:Play("Walk", 0.2, 1.5)
	check(animator.Time == t and animator.Speed == 1.5, petName .. " re-Play of a running loop only changes speed")
	animator:Destroy()
	check(head.Transform.Position.Magnitude == 0, petName .. " Destroy resets joints")
end

print(if failures == 0 then ("[test] all %d checks passed"):format(passes) else ("[test] %d failure(s), %d passed"):format(failures, passes))
if failures > 0 then
	process.exit(1)
end
