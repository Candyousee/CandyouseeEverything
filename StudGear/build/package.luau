-- Builds the Creator Store upload: one plain Model of numbered folders the buyer drags into
-- place (dragging a whole folder is fine - the scripts find their pieces anywhere in
-- ReplicatedStorage). Nothing installs itself.
--   rojo build -o StudGear.rbxl && lune run build/package.luau
-- Writes StudGear_CreatorStore.rbxm.

local fs = require("@lune/fs")
local roblox = require("@lune/roblox")
local Instance, CFrame = roblox.Instance, roblox.CFrame

local game = roblox.deserializePlace(fs.readFile("StudGear.rbxl"))
local rs = game:GetService("ReplicatedStorage")
local sss = game:GetService("ServerScriptService")
local sps = game:GetService("StarterPlayer"):FindFirstChild("StarterPlayerScripts")
local demo = game.Workspace:FindFirstChild("StudGearDemo")

local model = Instance.new("Model")
model.Name = "StudGear"
local function folder(name)
	local f = Instance.new("Folder")
	f.Name = name
	f.Parent = model
	return f
end

local toRS = folder("1_PutInReplicatedStorage")
local system = assert(rs:FindFirstChild("StudGear")):Clone()
system.Parent = toRS
-- the tool templates would sit on top of each other at the origin: stand them in a row in
-- front of the display stands instead (each tool moves as one piece)
for i, tool in system.Tools:GetChildren() do
	local n = #system.Tools:GetChildren()
	local shift = CFrame.new((i - (n + 1) / 2) * 3, 0.5, 15)
	for _, d in tool:GetDescendants() do
		if d:IsA("BasePart") then
			d.CFrame = shift * d.CFrame
		end
	end
end
assert(sss:FindFirstChild("StudGearServer")):Clone().Parent = folder("2_PutInServerScriptService")
assert(sps and sps:FindFirstChild("StudGearClient")):Clone().Parent = folder("3_PutInStarterPlayerScripts")
assert(demo:FindFirstChild("GearDisplays")):Clone().Parent = folder("4_PutInWorkspace_GearDisplays")
assert(demo:FindFirstChild("TestCourse")):Clone().Parent = folder("5_Optional_TestCourse")

local readme = Instance.new("ModuleScript")
readme.Name = "README"
readme.Source = [=[
--[[ STUD GEAR - obby coils that actually work - setup (1 minute)

Drag each numbered folder into the place its name says. Dragging the whole folder is fine.
  1_PutInReplicatedStorage        -> ReplicatedStorage
  2_PutInServerScriptService      -> ServerScriptService
  3_PutInStarterPlayerScripts     -> StarterPlayer > StarterPlayerScripts
  4_PutInWorkspace_GearDisplays   -> Workspace (move the stands wherever you like)
  5_Optional_TestCourse           -> Workspace if you want the test obby, or delete it
Then delete this model and press Play. Walk up to a stand and press E to get a coil.

GEAR (ReplicatedStorage.StudGear.Config)
  Speed Coil    walk speed x1.75
  Gravity Coil  35% gravity (jumps ~3x higher, floaty falls)
  Fusion Coil   speed x1.6 + 40% gravity
  Jump Coil     jumps 80% higher
  Rainbow Coil  speed x1.8 + 35% gravity + jump x1.15, rainbow trail
Change any number in Config. Trails can be turned off there too.

SELL GEAR AS GAME PASSES
  1. Create a game pass for your experience (Creator Hub > your experience > Monetization > Passes).
  2. Put its ID in that gear's GamePassId in Config.
  Owners get the gear every time they spawn. The stand shows the price, prompts the purchase,
  and gives + equips the gear the moment it's bought. GamePassId = 0 means free.

WHY THESE WORK
  - The tools contain no scripts: one server script applies every effect, so tools can't
    break when copied, dropped, or used on mobile.
  - Gravity is a force sized every frame from the character's real mass (R6, R15, any
    accessories), so it feels the same for everyone.
  - Speed and jump go back exactly when you unequip, swap, or die. If another server script
    changes speed while a coil is held (a sprint key, a speed pad), the coil stacks on top.

GIVE GEAR FROM YOUR OWN SCRIPTS (server)
  game.ServerScriptService:FindFirstChild("StudGearServer", true).GiveGear:Invoke(player, "Speed Coil")
]]
return nil
]=]
readme.Parent = model

fs.writeFile("StudGear_CreatorStore.rbxm", roblox.serializeModel({ model }))
local scripts = 0
for _, d in model:GetDescendants() do
	if d:IsA("LuaSourceContainer") then
		scripts += 1
	end
end
print(`[package] StudGear_CreatorStore.rbxm: {#system.Tools:GetChildren()} gear, {#model["4_PutInWorkspace_GearDisplays"].GearDisplays:GetChildren()} stands, {scripts} scripts`)
