-- Renders data for a pose sheet: every pose on the stand-in body, sword in hand, sheath on hip.
--   lune run build/posesheet.luau out.json
local fs = require("@lune/fs")
local serde = require("@lune/serde")
local process = require("@lune/process")
local CF = require("../src/shared/AnimeClip/CF")
local Rig = require("../src/shared/AnimeClip/Rig")
local Poses = require("../src/shared/AnimeClip/Poses")
local Props = require("../src/shared/AnimeClip/Props")

local names = { "Stand", "Ready", "Draw", "Guard", "Dash", "Dash2", "Clash", "Block", "SlashWind", "SlashFollow", "Charge", "IaiReady", "IaiFinish", "Sheathe", "Hit", "Kneel" }
local stand = Rig.StandHeight(Rig.PROXY)
local prims = {}
local colors = Props.BodyColors("hero")
local katana, sheath = Props.Katana("hero"), Props.Sheath()
for i, name in names do
	-- each pose far apart along X (rendered one at a time), facing +X (yaw -90)
	local root = CF.mul(CF.new((i - 1) * 100, stand, 0), CF.angles(0, -math.pi / 2, 0))
	local pose = Poses[name]
	local world = Rig.FK(Rig.PROXY, root, pose)
	local low = Rig.Lowest(Rig.PROXY, world)
	root = CF.mul(CF.new(0, -low, 0), root)
	world = Rig.FK(Rig.PROXY, root, pose)
	for part, cf in world do
		if part ~= "HumanoidRootPart" then
			table.insert(prims, { shape = if part == "Head" then "block" else "block", cf = cf, size = Rig.PROXY.sizes[part], color = colors[part] })
		end
	end
	local sheathed = name == "Stand" or name == "Ready" or name == "Sheathe" or name == "IaiReady"
	local swordCF = if sheathed then CF.mul(world.LowerTorso, Props.SHEATHED) else CF.mul(world.RightHand, Props.GRIP)
	for _, p in katana do
		table.insert(prims, { shape = p.shape, cf = CF.mul(swordCF, p.cf), size = p.size, color = p.color })
	end
	for _, p in sheath do
		table.insert(prims, { shape = p.shape, cf = CF.mul(CF.mul(world.LowerTorso, Props.SHEATH), p.cf), size = p.size, color = p.color })
	end
end
fs.writeFile(process.args[1], serde.encode("json", { prims = prims, names = names }))
print("pose sheet ->", process.args[1], #prims, "prims")
