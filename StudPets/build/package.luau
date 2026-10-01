-- Builds the Creator Store upload: one plain Model, no running scripts (the buyer drags
-- two folders into place - auto-install scripts get flagged by moderation).
--   lune run build/package.luau            (after `rojo build -o StudPets.rbxl`)
-- Writes StudPets_CreatorStore.rbxm. Drag it into Studio, then
-- right-click > Save / Export > Save to Roblox...

local fs = require("@lune/fs")
local roblox = require("@lune/roblox")
local Instance = roblox.Instance

local game = roblox.deserializePlace(fs.readFile("StudPets.rbxl"))
local rs = game:GetService("ReplicatedStorage")
local sps = game:GetService("StarterPlayer"):FindFirstChild("StarterPlayerScripts")

local model = Instance.new("Model")
model.Name = "StudPets200"

local toRS = Instance.new("Folder")
toRS.Name = "PutInReplicatedStorage"
toRS.Parent = model
assert(rs:FindFirstChild("StudPets")):Clone().Parent = toRS
assert(rs:FindFirstChild("StudPetModels")):Clone().Parent = toRS

-- Lay the pets out in rows so the inserted model is a tidy showcase (and a good store
-- thumbnail) instead of 200 pets stacked on the origin.
do
	local x, z, rowDepth = 0, 0, 0
	local ROW = 240
	for _, pet in toRS.StudPetModels:GetChildren() do
		local lo, hi = roblox.Vector3.new(math.huge, math.huge, math.huge), roblox.Vector3.new(-math.huge, -math.huge, -math.huge)
		local parts = {}
		for _, d in pet:GetDescendants() do
			if d:IsA("BasePart") then
				table.insert(parts, d)
				local h = d.Size / 2
				lo = lo:Min(d.CFrame.Position - h)
				hi = hi:Max(d.CFrame.Position + h)
			end
		end
		local w, dep = hi.X - lo.X, hi.Z - lo.Z
		if x + w > ROW then
			x, z, rowDepth = 0, z + rowDepth + 4, 0
		end
		local shift = roblox.Vector3.new(x - lo.X, -lo.Y, z - lo.Z)
		for _, part in parts do
			part.CFrame = part.CFrame + shift
		end
		x += w + 3
		rowDepth = math.max(rowDepth, dep)
	end
end

local toSPS = Instance.new("Folder")
toSPS.Name = "PutInStarterPlayerScripts_Optional"
toSPS.Parent = model
assert(sps and sps:FindFirstChild("PetDemo")):Clone().Parent = toSPS

local readme = Instance.new("ModuleScript")
readme.Name = "README"
readme.Source = [=[
--[[ STUD PETS 200 - setup (1 minute)

1. Drag the two folders inside PutInReplicatedStorage (StudPets and StudPetModels)
   into ReplicatedStorage.
2. Optional demo: drag PetDemo from PutInStarterPlayerScripts_Optional into
   StarterPlayer > StarterPlayerScripts. A pet follows you (G = trick, ] / [ = next / previous pet).
3. Delete this model. Done.

Use it (LocalScript):
  local PetAnimator = require(game.ReplicatedStorage.StudPets.PetAnimator)
  local pet = game.ReplicatedStorage.StudPetModels.StudCat:Clone()
  pet:ScaleTo(0.6)
  pet.Parent = workspace
  local anim = PetAnimator.new(pet)
  anim:Play("Walk", 0.2, 1.3)    -- Idle, Walk, Run, Sit, Jump, Sleep + anim.Set.Trick
  -- move it with pet:PivotTo(cframe); run the animator on the client

Every pet: 7 animations played from code. Nothing to upload, no asset IDs.
]]
return nil
]=]
readme.Parent = model

fs.writeFile("StudPets_CreatorStore.rbxm", roblox.serializeModel({ model }))
local n = 0
for _, d in model:GetDescendants() do
	if d:IsA("BasePart") then
		n += 1
	end
end
print(`[package] StudPets_CreatorStore.rbxm: {#toRS.StudPetModels:GetChildren()} pets, {n} parts`)
