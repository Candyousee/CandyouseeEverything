-- Builds the Creator Store upload for the Stud Pet System: one plain Model of folders the
-- buyer drags into place. Nothing installs itself (auto-install scripts get flagged by
-- moderation) and the one server Script ships disabled, so nothing runs until it's set up.
--   rojo build petsystem.project.json -o StudPetSystem.rbxl
--   lune run build/package_petsystem.luau
-- Writes StudPetSystem_CreatorStore.rbxm. Drag it into Studio, then
-- right-click > Save / Export > Save to Roblox...

local fs = require("@lune/fs")
local roblox = require("@lune/roblox")
local Instance = roblox.Instance

local game = roblox.deserializePlace(fs.readFile("StudPetSystem.rbxl"))
local rs = game:GetService("ReplicatedStorage")
local sss = game:GetService("ServerScriptService")
local sps = game:GetService("StarterPlayer"):FindFirstChild("StarterPlayerScripts")

-- only the pets the eggs can hatch (the full 200 are the separate Stud Pets pack)
local configSource = assert(rs.StudPetSystem:FindFirstChild("Config")).Source
local used = {}
for pet in configSource:gmatch('Pet = "([%w_]+)"') do
	used["Stud" .. pet] = true
end

local model = Instance.new("Model")
model.Name = "StudPetSystem"

local function folder(name: string): any
	local f = Instance.new("Folder")
	f.Name = name
	f.Parent = model
	return f
end

local toRS = folder("1_PutInReplicatedStorage")
assert(rs:FindFirstChild("StudPetSystem")):Clone().Parent = toRS
assert(rs:FindFirstChild("StudPets")):Clone().Parent = toRS
assert(rs:FindFirstChild("StudPetSystemEggs")):Clone().Parent = toRS
local pets = Instance.new("Folder")
pets.Name = "StudPetModels"
pets.Parent = toRS
local petCount = 0
for _, m in assert(rs:FindFirstChild("StudPetModels")):GetChildren() do
	if used[m.Name] then
		m:Clone().Parent = pets
		petCount += 1
		used[m.Name] = nil
	end
end
assert(next(used) == nil, "missing pet models: " .. table.concat((function()
	local t = {}
	for k in used do
		table.insert(t, k)
	end
	return t
end)(), ", "))

local toSSS = folder("2_PutInServerScriptService")
local server = assert(sss:FindFirstChild("StudPetSystem")):Clone()
server.Disabled = true
server.Parent = toSSS

local toSPS = folder("3_PutInStarterPlayerScripts")
assert(sps and sps:FindFirstChild("StudPetSystemClient")):Clone().Parent = toSPS

local toWS = folder("4_PutInWorkspace_EggStands")
local stands = assert(game.Workspace.PetSystemDemo:FindFirstChild("EggStands")):Clone()
stands.Parent = toWS

local readme = Instance.new("ModuleScript")
readme.Name = "README"
readme.Source = [=[
--[[ STUD PET SYSTEM - setup (2 minutes)

1. Open 1_PutInReplicatedStorage and drag everything inside it into ReplicatedStorage
   (StudPetSystem, StudPets, StudPetSystemEggs, StudPetModels).
2. Drag the StudPetSystem script from 2_PutInServerScriptService into ServerScriptService,
   then select it and tick "Enabled" in Properties (it ships switched off so it can't run
   from the wrong place).
3. Drag StudPetSystemClient from 3_PutInStarterPlayerScripts into
   StarterPlayer > StarterPlayerScripts.
4. Drag the EggStands folder from 4_PutInWorkspace_EggStands into Workspace and move the
   stands wherever you like.
5. Delete this model. Press Play: walk up to an egg, E = open 1, R = open 3, B = pets.

Saving: Game Settings > Security > "Enable Studio Access to API Services" to test saving in
Studio. It always saves in a published game.

CUSTOMISE - everything is in ReplicatedStorage.StudPetSystem.Config:
  * Currency name, starting coins, passive income (set 0 to turn off)
  * Max equipped / inventory, hatch cooldown, triple hatch on/off
  * Rarities (colour + how dramatic the hatch is)
  * Eggs: name, price, colours, shell pattern (spots / leaves / rosettes / waves / spikes /
    royal) and the pets with their weights
  * Sounds: silent by default - put any audio ID into a slot to give that moment a sound

Your own currency? Change setupCurrency / getCoins / addCoins at the top of the server
script.

New egg stand: copy a stand and set its "StudEggStand" attribute to the egg's name.
More pets: any pet from the "Stud Pets - 200 Animated Blocky Pets" pack works - drop its
model into StudPetModels and use its name (without "Stud") in an egg's Pets list.

Security: the server rolls every hatch and owns coins and pets, so exploiters can't pick
what they hatch. Data is session-locked so fast server hops can't lose progress.
]]
return nil
]=]
readme.Parent = model

fs.writeFile("StudPetSystem_CreatorStore.rbxm", roblox.serializeModel({ model }))
local scripts = 0
for _, d in model:GetDescendants() do
	if d:IsA("Script") and not d:IsA("LocalScript") and not d.Disabled then
		error("enabled server Script in package: " .. d:GetFullName())
	end
	if d:IsA("LuaSourceContainer") then
		scripts += 1
	end
end
print(`[package] StudPetSystem_CreatorStore.rbxm: {petCount} pets, {#stands:GetChildren()} stands, {scripts} scripts`)
