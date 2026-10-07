-- Offline build for Stud Deco (run from the StudDeco folder):
--   lune run build/build.luau                 -> assets/<Category>/<Item>.rbxm + QA report
--   lune run build/build.luau preview F.json  -> also dump every item's parts for the Blender renders
-- Nothing here talks to Roblox or Studio: it only writes files.

local fs = require("@lune/fs")
local serde = require("@lune/serde")
local process = require("@lune/process")
local roblox = require("@lune/roblox")
local Instance, CFrame, Vector3, Color3, Enum = roblox.Instance, roblox.CFrame, roblox.Vector3, roblox.Color3, roblox.Enum

local SOURCES = if process.env.DECO_SRC == "pet" then { require("../items_petstyle/Proto") } else { require("../items/Heroes") }

local MIN_SIZE = 0.1 -- Roblox's own minimum part size is 0.001; below 0.1 nothing reads in game

local function v3(t) return Vector3.new(t[1], t[2], t[3]) end

local function makePart(p)
	local part
	if p.shape == "wedge" then
		part = Instance.new("WedgePart")
	else
		part = Instance.new("Part")
		if p.shape == "cyl" then
			part.Shape = Enum.PartType.Cylinder
		end
	end
	part.Name = p.name
	part.Size = v3(p.size)
	part.CFrame = p.cf
	part.Color = Color3.fromRGB(p.color[1], p.color[2], p.color[3])
	part.Material = if p.neon then Enum.Material.Neon else Enum.Material.Plastic
	for _, face in { "Front", "Back", "Left", "Right" } do
		part[face .. "Surface"] = Enum.SurfaceType.Smooth
	end
	part.TopSurface = if p.studs then Enum.SurfaceType.Studs else Enum.SurfaceType.Smooth
	part.BottomSurface = Enum.SurfaceType.Smooth
	part.Anchored = true
	-- big parts block players; small trim, flames and glow bits don't
	local smallest = math.min(p.size[1], p.size[2], p.size[3])
	part.CanCollide = smallest >= 0.5 and not p.neon
	part.CanTouch = false
	part.CastShadow = not p.neon
	if p.shape == "ball" then
		local mesh = Instance.new("SpecialMesh")
		mesh.MeshType = Enum.MeshType.Sphere
		mesh.Parent = part
	end
	return part
end

local function makeModel(item)
	local model = Instance.new("Model")
	model.Name = item.name
	for _, p in item.parts do
		makePart(p).Parent = model
	end
	for i, l in item.lights do
		local holder = Instance.new("Part")
		holder.Name = "Light" .. i
		holder.Size = Vector3.new(0.2, 0.2, 0.2)
		holder.CFrame = CFrame.new(l.pos[1], l.pos[2], l.pos[3])
		holder.Transparency = 1
		holder.Anchored = true
		holder.CanCollide = false
		holder.CanTouch = false
		holder.CanQuery = false
		holder.CastShadow = false
		local light = Instance.new("PointLight")
		light.Color = Color3.fromRGB(l.color[1], l.color[2], l.color[3])
		light.Range = l.range
		light.Brightness = l.brightness
		light.Shadows = false
		light.Parent = holder
		holder.Parent = model
	end
	-- the pivot sits at the base centre, so a dropped-in item lands on the ground
	model.WorldPivot = CFrame.new()
	model:SetAttribute("StudDeco", item.category)
	model:AddTag("StudDeco")
	return model
end

-- ---------- QA ----------
local problems = 0
local function warn(item, msg)
	problems += 1
	print(`  [QA] {item.name}: {msg}`)
end

local function qa(item)
	if #item.parts == 0 then
		warn(item, "no parts")
	end
	local lowest = math.huge
	for _, p in item.parts do
		for _, s in p.size do
			if s < MIN_SIZE then
				warn(item, `part {p.name} is too small ({s})`)
				break
			end
		end
		-- lowest corner of the part's box
		local half = v3(p.size) / 2
		for _, sx in { -1, 1 } do
			for _, sy in { -1, 1 } do
				for _, sz in { -1, 1 } do
					local w = p.cf * Vector3.new(half.X * sx, half.Y * sy, half.Z * sz)
					lowest = math.min(lowest, w.Y)
				end
			end
		end
	end
	if lowest < -0.15 or lowest > 0.15 then
		warn(item, `base is at Y = {math.round(lowest * 100) / 100}, not on the ground`)
	end
	local budget = if item.category == "Arches" or item.category == "Stalls" then 160 else 120
	if #item.parts > budget then
		warn(item, `{#item.parts} parts (budget {budget})`)
	end
	for _, l in item.lights do
		if l.range > 20 then
			warn(item, "light range over 20 studs")
		end
	end
end

-- ---------- build ----------
local built = {}
for _, src in SOURCES do
	for _, make in src do
		local item = make()
		qa(item)
		table.insert(built, item)
	end
end

fs.writeDir("assets")
local pack = Instance.new("Model")
pack.Name = "StudDeco_Halloween"
local folders = {}
for _, item in built do
	local model = makeModel(item)
	fs.writeDir(`assets/{item.category}`)
	fs.writeFile(`assets/{item.category}/{item.name}.rbxm`, roblox.serializeModel({ model }))
	if not folders[item.category] then
		local f = Instance.new("Folder")
		f.Name = item.category
		f.Parent = pack
		folders[item.category] = f
	end
	makeModel(item).Parent = folders[item.category]
	print(`[build] {item.category}/{item.name}: {#item.parts} parts, {#item.lights} lights`)
end
fs.writeFile("assets/StudDeco_Halloween.rbxm", roblox.serializeModel({ pack }))
print(`[build] {#built} items, QA problems: {problems}`)

-- Studio command-bar scripts: studio/<Item>.lua = the builder with this item's data (paste into the Command Bar)
if process.args[1] == "studio" then
	local template = fs.readFile("studio/StudDecoBuilder.lua")
	local function n(v) return tostring(math.round(v * 1000) / 1000) end
	for _, item in built do
		local lines = { "{", `\tname = "{item.name}", category = "{item.category}",`, "\tparts = {" }
		for _, p in item.parts do
			local pos = p.cf.Position
			local rx, ry, rz = p.cf:ToEulerAnglesXYZ()
			table.insert(lines, `\t\t\{ "{if p.shape == "wedge" then "wedge" else "block"}", "{p.name}", \{ {n(p.size[1])}, {n(p.size[2])}, {n(p.size[3])} \}, `
				.. `\{ {n(pos.X)}, {n(pos.Y)}, {n(pos.Z)} \}, \{ {n(math.deg(rx))}, {n(math.deg(ry))}, {n(math.deg(rz))} \}, `
				.. `\{ {p.color[1]}, {p.color[2]}, {p.color[3]} \}, studs = {tostring(p.studs == true)}, neon = {tostring(p.neon == true)} \},`)
		end
		table.insert(lines, "\t},")
		table.insert(lines, "\tlights = {")
		for _, l in item.lights do
			table.insert(lines, `\t\t\{ pos = \{ {n(l.pos[1])}, {n(l.pos[2])}, {n(l.pos[3])} \}, color = \{ {l.color[1]}, {l.color[2]}, {l.color[3]} \}, range = {l.range}, brightness = {l.brightness} \},`)
		end
		table.insert(lines, "\t},")
		table.insert(lines, "}")
		local out = string.gsub(template, "%-%-ITEM_DATA%-%-", function() return table.concat(lines, "\n") end)
		fs.writeFile(`studio/{item.name}.lua`, out)
		print(`[build] studio/{item.name}.lua`)
	end
end

if process.args[1] == "preview" then
	local out = { items = {} }
	for _, item in built do
		local parts = {}
		for _, p in item.parts do
			local comps = {}
			for _, c in { p.cf:GetComponents() } do
				table.insert(comps, math.round(c * 10000) / 10000)
			end
			table.insert(parts, {
				name = p.name,
				shape = p.shape,
				size = p.size,
				color = p.color,
				studs = p.studs == true,
				neon = p.neon == true,
				cf = comps,
			})
		end
		table.insert(out.items, { name = item.name, category = item.category, parts = parts, lights = item.lights })
	end
	fs.writeFile(process.args[2], serde.encode("json", out))
	print("[build] preview data -> " .. process.args[2])
end
