-- Builds the set: a shrine field at sunset. Writes the Roblox model and the preview's prims.
--   lune run build/stage.luau            -> assets/Stage.rbxm + build/out/stage.json
local fs = require("@lune/fs")
local serde = require("@lune/serde")
local roblox = require("@lune/roblox")
local CF = require("../src/shared/AnimeClip/CF")

local prims = {}
local function add(shape, cf, size, color, extra)
	local p = { shape = shape, cf = cf, size = size, color = color, alpha = 0, neon = false }
	for k, v in extra or {} do
		p[k] = v
	end
	table.insert(prims, p)
	return p
end
local H = CF.hash
local UP = CF.angles(0, 0, math.pi / 2) -- cylinder standing up
local function vary(c, k, seed)
	local v = (H(seed) - 0.5) * 2 * k
	return { math.clamp(c[1] * (1 + v), 0, 255), math.clamp(c[2] * (1 + v), 0, 255), math.clamp(c[3] * (1 + v), 0, 255) }
end

---------------------------------------------------------------- ground + path
add("block", CF.new(0, -0.5, 0), { 420, 1, 420 }, { 104, 132, 66 }, { tag = "ground" })
-- a slightly darker worn circle where they fight
add("cyl", CF.mul(CF.new(0, 0.005, 0), UP), { 0.02, 30, 30 }, { 128, 122, 84 }, { tag = "ground" })
-- stone path along X
local n = 0
for x = -40, 40, 2.3 do
	for row = -1, 1 do
		n += 1
		local w = 2.0 + 0.2 * H(n)
		local cf = CF.mul(CF.new(x + (H(n + 7) - 0.5) * 0.3 + (row % 2) * 1.1, 0.06, row * 1.55 + (H(n + 3) - 0.5) * 0.2), CF.angles(0, (H(n + 11) - 0.5) * 0.15, 0))
		add("block", cf, { w, 0.14, 1.4 }, vary({ 150, 146, 138 }, 0.12, n))
	end
end

---------------------------------------------------------------- grass tufts
for i = 1, 520 do
	local x = -70 + 140 * H(i * 1.31)
	local z = -45 + 90 * H(i * 2.77)
	if math.abs(z) > 3.2 and not (math.abs(x) < 13 and math.abs(z) < 13 and H(i * 5.1) < 0.7) then
		local c = vary(if H(i * 3.3) < 0.3 then { 170, 160, 80 } else { 92, 138, 58 }, 0.18, i)
		for b = 1, 3 do
			local h = 0.5 + 0.9 * H(i * 7 + b)
			local tilt = (H(i * 11 + b) - 0.5) * 0.9
			local yaw = H(i * 13 + b) * 6.28
			add("block", CF.mul(CF.mul(CF.new(x + (b - 2) * 0.12, h / 2 - 0.05, z), CF.angles(0, yaw, tilt)), CF.new(0, 0, 0)), { 0.08, h, 0.16 }, c)
		end
	end
end

---------------------------------------------------------------- torii gate (behind the rival, toward the sun)
do
	local gx = 25
	local red, black = { 200, 52, 38 }, { 26, 24, 26 }
	for _, z in { -4.4, 4.4 } do
		add("cyl", CF.mul(CF.new(gx, 4.6, z), UP), { 9.2, 1.0, 1.0 }, red, { shine = true })
		add("cyl", CF.mul(CF.new(gx, 0.35, z), UP), { 0.7, 1.3, 1.3 }, black)
	end
	add("block", CF.new(gx, 7.0, 0), { 0.7, 0.6, 11.2 }, red) -- nuki
	add("block", CF.new(gx, 8.0, 0), { 0.5, 1.4, 0.6 }, red) -- gakuzuka
	add("block", CF.new(gx, 8.75, 0), { 1.1, 0.5, 12.4 }, red) -- shimaki
	-- kasagi: black top beam sweeping up at both ends
	add("block", CF.new(gx, 9.3, 0), { 1.4, 0.6, 9.0 }, black)
	for _, side in { -1, 1 } do
		add("block", CF.mul(CF.new(gx, 9.55, side * 5.9), CF.angles(side * math.rad(-12), 0, 0)), { 1.4, 0.6, 3.4 }, black)
	end
	add("block", CF.new(gx, 9.0, 0), { 1.25, 0.25, 12.6 }, red)
	-- a sign plaque
	add("block", CF.new(gx - 0.32, 8.0, 0), { 0.12, 1.1, 0.85 }, black)
end

---------------------------------------------------------------- shrine hall (behind the hero)
do
	local sx = -36
	local wood, roof, white = { 92, 56, 40 }, { 40, 44, 52 }, { 236, 228, 210 }
	add("block", CF.new(sx, 0.6, 0), { 12, 1.2, 16 }, { 120, 116, 110 })
	add("block", CF.new(sx, 4.0, 0), { 8.5, 5.6, 12 }, white)
	for _, z in { -6, -2, 2, 6 } do
		add("cyl", CF.mul(CF.new(sx + 4.3, 4.0, z), UP), { 5.8, 0.6, 0.6 }, { 180, 50, 36 })
	end
	add("block", CF.new(sx + 4.3, 6.6, 0), { 0.5, 0.5, 12.4 }, { 180, 50, 36 })
	-- big curved roof: layered slabs
	for i = 0, 3 do
		add("block", CF.mul(CF.new(sx, 7.6 + i * 0.7, 0), CF.angles(0, 0, 0)), { 12 - i * 2.2, 0.5, 18 - i * 1.6 }, roof)
	end
	add("block", CF.new(sx, 10.6, 0), { 1.2, 0.8, 15.6 }, roof)
	-- steps
	for i = 0, 2 do
		add("block", CF.new(sx + 6.5 + i * 0.9, 0.2 + (2 - i) * 0.35, 0), { 0.9, 0.4, 5 }, { 140, 136, 128 })
	end
	-- glowing lanterns at the door
	for _, z in { -3, 3 } do
		add("ball", CF.new(sx + 4.9, 5.3, z), { 0.9, 0.9, 0.9 }, { 255, 170, 90 }, { neon = true })
	end
end

---------------------------------------------------------------- stone lanterns along the path
local function toro(x, z, seed)
	local stone = vary({ 140, 138, 130 }, 0.06, seed)
	add("block", CF.new(x, 0.3, z), { 1.6, 0.6, 1.6 }, stone)
	add("cyl", CF.mul(CF.new(x, 1.6, z), UP), { 2.0, 0.6, 0.6 }, stone)
	add("block", CF.new(x, 2.75, z), { 1.4, 0.3, 1.4 }, stone)
	add("block", CF.new(x, 3.35, z), { 1.0, 0.9, 1.0 }, stone)
	add("block", CF.new(x, 3.35, z), { 1.05, 0.5, 0.55 }, { 255, 190, 110 }, { neon = true })
	add("block", CF.new(x, 3.35, z), { 0.55, 0.5, 1.05 }, { 255, 190, 110 }, { neon = true })
	add("block", CF.mul(CF.new(x, 4.0, z), CF.angles(0, math.rad(45), 0)), { 1.9, 0.35, 1.9 }, stone)
	add("block", CF.mul(CF.new(x, 4.35, z), CF.angles(0, math.rad(45), 0)), { 1.0, 0.35, 1.0 }, stone)
	add("ball", CF.new(x, 4.75, z), { 0.5, 0.5, 0.5 }, stone)
end
local li = 0
for _, x in { -30, -22, 24, 32 } do
	for _, z in { -4.6, 4.6 } do
		li += 1
		toro(x, z, li)
	end
end

---------------------------------------------------------------- cherry trees
local function tree(x, z, scale, seed)
	local bark = { 74, 48, 44 }
	local trunkH = 6 * scale
	-- a leaning trunk in a few segments
	local base = { x, 0, z }
	local lean = { (H(seed) - 0.5) * 0.5, 1, (H(seed + 1) - 0.5) * 0.5 }
	local top = CF.add(base, CF.scale(CF.unit(lean), trunkH))
	local mid = CF.lerpv(base, top, 0.5)
	local d = CF.sub(top, base)
	add("cyl", CF.along(mid, d), { trunkH, 1.1 * scale, 1.1 * scale }, bark)
	add("cyl", CF.mul(CF.new(x, 0.3, z), UP), { 0.6, 1.8 * scale, 1.8 * scale }, bark)
	-- branches out to the canopy blobs
	local blobs = {}
	for b = 1, 5 do
		local ang = b / 5 * 6.28 + H(seed + b) * 0.8
		local out = { math.cos(ang) * (3 + 1.5 * H(seed + b * 3)) * scale, (1 + 2.5 * H(seed + b * 5)) * scale, math.sin(ang) * (3 + 1.5 * H(seed + b * 3)) * scale }
		local tip = CF.add(top, out)
		local dd = CF.sub(tip, top)
		add("cyl", CF.along(CF.lerpv(top, tip, 0.5), dd), { CF.len(dd), 0.45 * scale, 0.45 * scale }, bark)
		table.insert(blobs, tip)
	end
	table.insert(blobs, CF.add(top, { 0, 2.5 * scale, 0 }))
	local pinks = { { 255, 183, 210 }, { 248, 160, 192 }, { 255, 208, 224 }, { 236, 142, 178 } }
	local k = 0
	for bi, c in blobs do
		for j = 1, 6 do
			k += 1
			local r = (1.3 + 1.2 * H(seed * 7 + k)) * scale
			local p = CF.add(c, { (H(seed + k * 3) - 0.5) * 3.2 * scale, (H(seed + k * 5) - 0.5) * 1.6 * scale, (H(seed + k * 7) - 0.5) * 3.2 * scale })
			add("ball", CF.new(p[1], p[2], p[3]), { r * 2, r * 2, r * 2 }, pinks[(k + bi) % #pinks + 1])
		end
	end
	-- fallen petals carpet under the tree
	for j = 1, 26 do
		local a, r = H(seed * 3 + j) * 6.28, 6 * scale * math.sqrt(H(seed * 5 + j))
		add("block", CF.mul(CF.new(x + math.cos(a) * r, 0.03, z + math.sin(a) * r), CF.angles(0, a, 0)), { 0.35, 0.03, 0.25 }, pinks[j % 4 + 1])
	end
end
tree(16, -12, 1.15, 11)
tree(-15, -13, 1.25, 23)
tree(-22, 12, 1.1, 37)
tree(19, 13, 1.0, 41)
tree(36, -18, 1.3, 53)
tree(-38, -20, 1.2, 61)
tree(-45, 16, 1.3, 71)
tree(42, 20, 1.2, 83)
tree(4, -26, 1.4, 97)
tree(-6, 27, 1.3, 103)

---------------------------------------------------------------- rocks
for i = 1, 26 do
	local x, z = -50 + 100 * H(i * 4.4), -36 + 72 * H(i * 6.6)
	if math.abs(z) > 4 then
		local s = 0.5 + 1.6 * H(i * 8.8)
		add("block", CF.mul(CF.new(x, s * 0.3, z), CF.angles(H(i) * 0.6, H(i * 2) * 6, H(i * 3) * 0.6)), { s * 1.4, s, s * 1.2 }, vary({ 112, 108, 104 }, 0.1, i))
	end
end

---------------------------------------------------------------- distant mountains, sun, clouds
for i = 1, 26 do
	local ang = i / 26 * 6.28 + H(i) * 0.2
	local dist = 230 + 60 * H(i * 2)
	local h = 40 + 70 * H(i * 3)
	local x, z = math.cos(ang) * dist, math.sin(ang) * dist
	-- a pyramid: a cube on its corner, sunk into the ground
	local far = H(i * 5)
	local col = { 70 + 40 * far, 62 + 30 * far, 104 + 40 * far }
	add("block", CF.mul(CF.mul(CF.new(x, -h * 0.25, z), CF.angles(0, ang, 0)), CF.angles(math.rad(45), 0, math.rad(35))), { h, h, h }, col, { tag = "far" })
end
add("ball", CF.new(320, 34, -30), { 40, 40, 40 }, { 255, 186, 110 }, { neon = true, tag = "sun" })
-- (clouds come from Roblox's own cloud layer in the game)

---------------------------------------------------------------- write
fs.writeDir("build/out")
fs.writeFile("build/out/stage.json", serde.encode("json", { prims = prims }))

local Instance, Vector3, Color3, Enum = roblox.Instance, roblox.Vector3, roblox.Color3, roblox.Enum
local function toCFrame(c)
	return roblox.CFrame.new(c[1], c[2], c[3], c[4], c[5], c[6], c[7], c[8], c[9], c[10], c[11], c[12])
end
local model = Instance.new("Model")
model.Name = "DuelStage"
for i, p in prims do
	local part = Instance.new("Part")
	part.Name = p.tag or "Set"
	part.Anchored = true
	part.CanCollide = p.tag == "ground"
	part.CanQuery = false
	part.CanTouch = false
	part.Size = Vector3.new(p.size[1], p.size[2], p.size[3])
	part.CFrame = toCFrame(p.cf)
	part.Color = Color3.fromRGB(math.floor(p.color[1]), math.floor(p.color[2]), math.floor(p.color[3]))
	part.Material = if p.neon then Enum.Material.Neon else Enum.Material.SmoothPlastic
	part.TopSurface = Enum.SurfaceType.Smooth
	part.BottomSurface = Enum.SurfaceType.Smooth
	part.CastShadow = p.tag ~= "far" and p.tag ~= "sun"
	if p.shine then
		part.Reflectance = 0.08
	end
	if p.shape == "cyl" then
		part.Shape = Enum.PartType.Cylinder
	elseif p.shape == "ball" then
		part.Shape = Enum.PartType.Ball
	elseif p.shape == "sphere" then
		local m = Instance.new("SpecialMesh")
		m.MeshType = Enum.MeshType.Sphere
		m.Parent = part
	end
	part.Parent = model
	local _ = i
end
fs.writeFile("assets/Stage.rbxm", roblox.serializeModel({ model }))
print(("[stage] %d parts -> assets/Stage.rbxm, build/out/stage.json"):format(#prims))
