--!strict
-- Hero batch v2, BRICK-BUILT (owner: "blocky, not smooth"). Every top face has studs.
local Kit = require("../build/Kit")
local C, CF = Kit.C, Kit.CF

local items = {}

-- 1. Classic Jack-o'-Lantern (ref 1.1 #1)
table.insert(items, function()
	local it = Kit.new("ClassicJackOLantern", "Pumpkins")
	local h = Kit.jack(it, CF(), 6, "grin", C.glowOrange)
	it.light({ 0, h * 0.5, -1 }, C.glowOrange, 12, 1.6)
	return it
end)

-- 2. Stacked Pumpkin Trio (ref 1.1 #6)
table.insert(items, function()
	local it = Kit.new("StackedPumpkinTrio", "Pumpkins")
	local y = 0
	for i, s in { { 6, 0.7, 5, "grin" }, { 5, 0.8, 3, "wicked" }, { 4, 0.7, 3, "happy" } } do
		local w, lh, n, style = s[1] :: number, s[2] :: number, s[3] :: number, s[4] :: string
		local h = Kit.jack(it, CF(0, y, 0), w, style, C.glowOrange, { lh = lh, layers = n, stem = i == 3 })
		it.light({ 0, y + h * 0.5, -1 }, C.glowOrange, 9, 1.1)
		y += h
	end
	return it
end)

-- 3. Skull Headstone (ref 1.2 #3)
table.insert(items, function()
	local it = Kit.new("SkullHeadstone", "Graveyard")
	it.block("Base", { 6, 0.8, 3 }, CF(0, 0.4, 0), C.stoneDark)
	local b = 0.8
	it.block("Stone", { 4, 3.6, 1.2 }, CF(0, b + 1.8, 0.4), C.stone)
	it.block("StoneStep", { 3, 0.8, 1.2 }, CF(0, b + 4.0, 0.4), C.stone)
	it.block("StoneTop", { 2, 0.6, 1.2 }, CF(0, b + 4.7, 0.4), C.stone)
	it.block("Panel", { 3, 3, 0.2 }, CF(0, b + 2.0, -0.3), C.stoneDark, { studs = false })
	Kit.skull(it, CF(0, b + 0.9, -0.95), 0.85, C.black, false)
	-- moss on the steps and a side, a dirt mound and grass tufts in front
	it.block("MossTop", { 1.2, 0.2, 1.2 }, CF(-0.3, b + 5.1, 0.4), C.moss)
	it.block("MossStep", { 0.5, 0.2, 1.2 }, CF(-1.25, b + 4.5, 0.4), C.moss)
	it.block("MossSide", { 0.2, 1.6, 1.2 }, CF(-2.1, b + 0.8, 0.4), C.moss, { studs = false })
	it.block("Mound", { 3, 0.4, 1 }, CF(0.5, b + 0.2, -1.0), C.dirt)
	for i, p in { { -2.3, -0.9 }, { 2.4, -0.6 }, { 1.8, -1.1 } } do
		it.block("Grass" .. i, { 0.4, 0.6, 0.4 }, CF(p[1], b + 0.3, p[2]), C.moss)
	end
	return it
end)

-- 4. Bubbling Cauldron (ref 2.1 #1)
table.insert(items, function()
	local it = Kit.new("BubblingCauldron", "Witch")
	for i, p in { { -1.4, 0.9 }, { 1.4, 0.9 }, { 0, -1.5 } } do
		it.block("Leg" .. i, { 0.8, 1.0, 0.8 }, CF(p[1], 0.5, p[2]), C.black)
	end
	local y = 0.8
	local layers = {}
	for i, d in { 3, 4, 5, 5, 4 } do
		Kit.roundLayer(it, "Pot" .. i, CF(0, y, 0), d, 0.8, C.black)
		table.insert(layers, { y0 = y, y1 = y + 0.8, d = d })
		y += 0.8
	end
	Kit.roundLayer(it, "Rim", CF(0, y, 0), 5, 0.4, C.stoneDark)
	y += 0.4
	Kit.roundLayer(it, "Brew", CF(0, y, 0), 4, 0.2, C.toxic)
	for _, p in it.parts do
		if string.sub(p.name, 1, 4) == "Brew" then
			p.neon, p.studs = true, false
		end
	end
	for i, b in { { 0.6, 0.6, -0.4, 0.8 }, { -0.8, 0.4, 0.3, 0.6 }, { 0.9, 0.3, 0.8, 0.5 }, { -0.2, 1.4, -0.1, 0.5 }, { 0.3, 2.1, 0.2, 0.4 } } do
		it.block("Bubble" .. i, { b[4], b[4], b[4] }, CF(b[1], y + 0.2 + b[2], b[3]), C.glowGreen, { neon = true })
	end
	it.block("Drip", { 0.4, 1.2, 0.2 }, CF(1.2, y - 0.9, -1.6), C.toxic, { neon = true })
	-- a glowing pixel crescent moon on the front
	local moon = { "..##..", ".##...", "##....", "##....", ".##...", "..##.." }
	Kit.pixelFace(it, CF(-0.2, 0, 0), moon, 0.35, 2.8, Kit.pumpkinFront(layers), C.glowOrange)
	it.light({ 0, y + 1.5, 0 }, C.glowGreen, 12, 2)
	it.light({ 0, 2.8, -3 }, C.glowOrange, 6, 0.8)
	return it
end)

-- 5. Pumpkin Lamp Post (ref 3.1 #1)
table.insert(items, function()
	local it = Kit.new("PumpkinLampPost", "Lights")
	local top = Kit.roundBase(it, CF(), 4, C.stoneDark)
	local postH = 6
	it.block("Post", { 1, postH, 1 }, CF(0, top + postH / 2, 0), C.black)
	for i, y in { 0.6, 2.8, 5.0 } do
		it.block("Band" .. i, { 1.4, 0.4, 1.4 }, CF(0, top + y, 0), C.orange)
	end
	local capY = top + postH
	it.block("Cap", { 2, 0.4, 2 }, CF(0, capY + 0.2, 0), C.orange)
	it.block("LeafL", { 1, 0.2, 0.6 }, CF(-1.3, capY + 0.3, 0), C.moss)
	it.block("LeafR", { 1, 0.2, 0.6 }, CF(1.3, capY + 0.3, 0.2), C.moss)
	local h = Kit.jack(it, CF(0, capY + 0.4, 0), 4, "happy", C.glowOrange, { lh = 0.8, layers = 3 })
	it.light({ 0, capY + 0.4 + h * 0.5, -0.8 }, C.glowOrange, 16, 2)
	return it
end)

-- 6. Candle Cluster (ref 1.3 #3)
table.insert(items, function()
	local it = Kit.new("CandleCluster", "Lights")
	local top = Kit.roundBase(it, CF(), 5, C.stoneDark)
	local brightest
	for i, c in { { 0, 0.2, 3.0, 1 }, { -1.3, 0.4, 2.0, 0.8 }, { 1.3, 0.3, 1.6, 0.8 }, { 0.6, -1.2, 1.0, 0.6 }, { -0.7, -1.2, 0.8, 0.6 } } do
		local p = Kit.candle(it, CF(c[1], top, c[2]), c[4], c[3], C.wax, C.glowOrange)
		if i == 1 then
			brightest = p
		end
	end
	it.block("WaxPool", { 2, 0.2, 1 }, CF(0.4, top + 0.1, -0.4), C.wax, { studs = false })
	it.light(brightest, C.glowOrange, 12, 1.8)
	return it
end)

return items
