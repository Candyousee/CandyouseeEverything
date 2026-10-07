--!strict
-- Hero batch (HALLOWEEN-PLAN section 5): the first 6 items, for the owner's look-check.
local Kit = require("../build/Kit")
local C, CF, A = Kit.C, Kit.CF, Kit.A

local items = {}

-- 1. Classic Jack-o'-Lantern (ref 1.1 #1)
table.insert(items, function()
	local it = Kit.new("ClassicJackOLantern", "Pumpkins")
	local at = CF(0, 0, 0)
	local w, h = 3, 2.6
	Kit.pumpkin(it, at, w, h, C.orange, { bumps = true })
	Kit.face(it, at, w, h, C.glowOrange, "grin")
	it.light({ 0, h * 0.5, -w * 0.2 }, C.glowOrange, 10, 1.6)
	return it
end)

-- 2. Stacked Pumpkin Trio (ref 1.1 #6)
table.insert(items, function()
	local it = Kit.new("StackedPumpkinTrio", "Pumpkins")
	local y = 0
	for i, s in { { 3.2, 2.6, "grin" }, { 2.6, 2.1, "wicked" }, { 2.0, 1.7, "happy" } } do
		local w, h, style = s[1] :: number, s[2] :: number, s[3] :: string
		local at = CF(0, y, 0) * A(0, math.rad((i - 2) * 9), 0)
		Kit.pumpkin(it, at, w, h, C.orange, { stem = i == 3, bumps = i ~= 2 })
		Kit.face(it, at, w, h, C.glowOrange, style)
		it.light({ 0, y + h * 0.5, -w * 0.2 }, C.glowOrange, 8, 1.1)
		y += h * 0.86
	end
	return it
end)

-- 3. Skull Headstone (ref 1.2 #3)
table.insert(items, function()
	local it = Kit.new("SkullHeadstone", "Graveyard")
	local base = Kit.slabBase(it, CF(0, 0, 0), 4.2, 0.6, 2.2, C.stoneDark)
	it.block("Mound", { 3.0, 0.35, 1.0 }, CF(0, base + 0.15, -1.25), C.dirt)
	-- the stone: a block with a rounded top (a cylinder lying front-to-back)
	local sw, sh, sd = 3.0, 2.6, 0.9
	it.block("Stone", { sw, sh, sd }, CF(0, base + sh / 2, 0.3), C.stone)
	it.hcyl("StoneTop", sw, sd, CF(0, base + sh, 0.3) * A(0, math.rad(90), 0), C.stone)
	it.block("Frame", { sw - 0.5, sh - 0.3, 0.12 }, CF(0, base + sh / 2 + 0.1, 0.3 - sd / 2 - 0.05), C.stoneDark)
	it.hcyl("FrameTop", sw - 0.5, 0.12, CF(0, base + sh + 0.1, 0.3 - sd / 2 - 0.05) * A(0, math.rad(90), 0), C.stoneDark)
	Kit.skull(it, CF(0, base + 2.35, -0.25), 1.05, C.black, false)
	-- moss and grass
	it.block("MossTop", { 1.4, 0.18, 0.95 }, CF(-0.55, base + sh + 1.38, 0.3) * A(0, 0, math.rad(-18)), C.moss, { studs = true })
	it.block("MossSide", { 0.25, 1.0, 0.95 }, CF(-1.5, base + 0.9, 0.3), C.moss)
	for i, x in { -1.7, 1.75, 1.2 } do
		it.wedge("Grass" .. i, { 0.3, 0.6, 0.4 }, CF(x, base + 0.3, -0.75 + i * 0.1) * A(0, math.rad(i * 70), 0), C.moss)
	end
	return it
end)

-- 4. Bubbling Cauldron (ref 2.1 #1)
table.insert(items, function()
	local it = Kit.new("BubblingCauldron", "Witch")
	for i = 0, 2 do
		local a = i / 3 * math.pi * 2 + math.pi / 6
		it.block("Leg" .. i, { 0.45, 0.9, 0.45 }, CF(math.cos(a) * 1.05, 0.45, math.sin(a) * 1.05), C.black)
	end
	local bodyY = 1.85
	it.ball("Pot", { 3.3, 2.6, 3.3 }, CF(0, bodyY, 0), C.black)
	it.vcyl("Rim", 3.0, 0.4, CF(0, bodyY + 1.05, 0), C.stoneDark)
	it.vcyl("RimLip", 3.2, 0.2, CF(0, bodyY + 1.3, 0), C.black)
	it.vcyl("Brew", 2.6, 0.2, CF(0, bodyY + 1.36, 0), C.toxic, { neon = true })
	for i, b in { { 0.3, 0.55, -0.3, 0.7 }, { -0.5, 0.35, 0.25, 0.5 }, { 0.65, 0.3, 0.45, 0.4 }, { -0.1, 1.2, -0.1, 0.45 }, { 0.2, 1.75, 0.15, 0.3 } } do
		it.ball("Bubble" .. i, { b[4], b[4], b[4] }, CF(b[1], bodyY + 1.4 + b[2], b[3]), C.glowGreen, { neon = true })
	end
	it.block("Drip", { 0.35, 0.7, 0.2 }, CF(0.9, bodyY + 0.9, -1.25) * A(math.rad(-20), 0, 0), C.toxic, { neon = true })
	-- a glowing crescent moon on the front, with two triangle eyes
	local front = CF(0, bodyY + 0.05, -1.5)
	it.ball("MoonGlow", { 1.0, 1.0, 0.35 }, front * CF(0, 0.05, 0), C.glowOrange, { neon = true })
	it.ball("MoonCut", { 0.85, 0.9, 0.4 }, front * CF(0.3, 0.18, -0.05), C.black)
	it.wedge("StarL", { 0.2, 0.3, 0.3 }, front * CF(-0.95, 0.35, 0.12) * A(0, math.rad(90), 0), C.glowOrange, { neon = true })
	it.wedge("StarR", { 0.2, 0.3, 0.3 }, front * CF(0.95, 0.35, 0.12) * A(0, math.rad(-90), 0), C.glowOrange, { neon = true })
	it.light({ 0, bodyY + 2.0, 0 }, C.glowGreen, 12, 2)
	it.light({ 0, bodyY, -2.2 }, C.glowOrange, 6, 0.8)
	return it
end)

-- 5. Pumpkin Lamp Post (ref 3.1 #1)
table.insert(items, function()
	local it = Kit.new("PumpkinLampPost", "Lights")
	local top = Kit.roundBase(it, CF(0, 0, 0), 2.4, 0.6, C.stoneDark)
	it.vcyl("Foot", 1.1, 0.5, CF(0, top + 0.35, 0), C.black)
	local postH = 5.2
	it.vcyl("Post", 0.55, postH, CF(0, top + 0.5 + postH / 2, 0), C.black)
	for i, y in { 0.9, 2.6, 4.4 } do
		it.vcyl("Band" .. i, 0.72, 0.28, CF(0, top + 0.5 + y, 0), C.orange)
	end
	local cupY = top + 0.5 + postH
	it.vcyl("Cup", 1.0, 0.35, CF(0, cupY, 0), C.orange)
	it.block("Leaf1", { 0.9, 0.12, 0.35 }, CF(0.55, cupY + 0.05, 0) * A(0, 0, math.rad(-25)), C.stem)
	it.block("Leaf2", { 0.9, 0.12, 0.35 }, CF(-0.55, cupY + 0.05, 0.1) * A(0, 0, math.rad(25)), C.stem)
	local at = CF(0, cupY + 0.1, 0)
	local w, h = 2.0, 1.7
	Kit.pumpkin(it, at, w, h, C.orange, {})
	Kit.face(it, at, w, h, C.glowOrange, "happy")
	it.light({ 0, cupY + 0.95, -0.2 }, C.glowOrange, 16, 2)
	return it
end)

-- 6. Candle Cluster (ref 1.3 #3)
table.insert(items, function()
	local it = Kit.new("CandleCluster", "Lights")
	local top = Kit.roundBase(it, CF(0, 0, 0), 3.0, 0.45, C.stoneDark)
	local brightest
	for i, c in { { 0, 0.15, 1.9, 0.72 }, { -0.75, 0.25, 1.3, 0.62 }, { 0.78, 0.2, 1.05, 0.6 }, { 0.35, -0.65, 0.7, 0.5 }, { -0.45, -0.6, 0.55, 0.48 } } do
		local p = Kit.candle(it, CF(c[1], top + 0.2, c[2]), c[4], c[3], C.wax, C.glowOrange)
		if i == 1 then
			brightest = p
		end
	end
	it.block("WaxPool", { 1.6, 0.12, 1.2 }, CF(0.1, top + 0.24, -0.1), C.wax)
	it.light(brightest, C.glowOrange, 12, 1.8)
	return it
end)

return items
