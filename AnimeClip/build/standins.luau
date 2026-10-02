-- Builds the blocky stand-in fighters (used if an avatar can't load): proper R15 rigs with
-- Motor6Ds, plus the anime face and hair, all welded with stored offsets.
--   lune run build/standins.luau  -> assets/StandIns.rbxm
local fs = require("@lune/fs")
local roblox = require("@lune/roblox")
local CF = require("../src/shared/AnimeClip/CF")
local Rig = require("../src/shared/AnimeClip/Rig")
local Props = require("../src/shared/AnimeClip/Props")
local Instance, Vector3, Color3, Enum = roblox.Instance, roblox.Vector3, roblox.Color3, roblox.Enum

local function toCFrame(c)
	return roblox.CFrame.new(c[1], c[2], c[3], c[4], c[5], c[6], c[7], c[8], c[9], c[10], c[11], c[12])
end
local function rgb(c)
	return Color3.fromRGB(math.floor(c[1]), math.floor(c[2]), math.floor(c[3]))
end

local function build(name, style)
	local model = Instance.new("Model")
	model.Name = name
	local stand = Rig.StandHeight(Rig.PROXY)
	local world = Rig.FK(Rig.PROXY, CF.new(0, stand, 0), {})
	local colors = Props.BodyColors(style)
	local parts = {}
	for partName, size in Rig.PROXY.sizes do
		local p = Instance.new("Part")
		p.Name = partName
		p.Size = Vector3.new(size[1], size[2], size[3])
		p.CFrame = toCFrame(world[partName])
		p.Color = rgb(colors[partName] or { 200, 200, 200 })
		p.Material = Enum.Material.SmoothPlastic
		p.TopSurface = Enum.SurfaceType.Smooth
		p.BottomSurface = Enum.SurfaceType.Smooth
		p.CanCollide = false
		if partName == "HumanoidRootPart" then
			p.Transparency = 1
		end
		p.Parent = model
		parts[partName] = p
	end
	for _, j in Rig.PROXY.joints do
		local m = Instance.new("Motor6D")
		m.Name = j.name
		m.Part0 = parts[j.part0]
		m.Part1 = parts[j.part1]
		m.C0 = toCFrame(j.c0)
		m.C1 = toCFrame(CF.inv(j.c1inv))
		m.Parent = parts[j.part1]
	end
	-- face + hair, welded to the head with stored offsets
	local head = parts.Head
	for i, d in Props.HeadDetail(style) do
		local p = Instance.new("Part")
		p.Name = "Detail" .. i
		p.Size = Vector3.new(d.size[1], d.size[2], d.size[3])
		p.CFrame = toCFrame(CF.mul(world.Head, d.cf))
		p.Color = rgb(d.color)
		p.Material = Enum.Material.SmoothPlastic
		p.CanCollide = false
		p.Massless = true
		p.Parent = model
		local w = Instance.new("Weld")
		w.Part0 = head
		w.Part1 = p
		w.C0 = toCFrame(d.cf)
		w.Parent = p
	end
	local humanoid = Instance.new("Humanoid")
	humanoid.RigType = Enum.HumanoidRigType.R15
	humanoid.HipHeight = stand - 1
	humanoid.Parent = model
	model.PrimaryPart = parts.HumanoidRootPart
	return model
end

local folder = Instance.new("Folder")
folder.Name = "AnimeClipStandIns"
build("Hero", "hero").Parent = folder
build("Rival", "rival").Parent = folder
fs.writeFile("assets/StandIns.rbxm", roblox.serializeModel({ folder }))
print("[standins] assets/StandIns.rbxm")
