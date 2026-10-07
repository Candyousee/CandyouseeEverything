--!strict
-- Pet-style prototypes (Stud Pets look): a few big boxes, studs on top, thin flat feature plates.
local Kit = require("../build/Kit")
local C, CF, A = Kit.C, Kit.CF, Kit.A
local items = {}

local function plate(it, name, size, cf, color, glow)
	it.block(name, size, cf, color, { studs = false, neon = glow or false })
end

-- Jack-o'-Lantern, pet style
table.insert(items, function()
	local it = Kit.new("JackOLantern_PetStyle", "Pumpkins")
	local w, h, d = 3, 2.4, 3
	it.block("Bottom", { w - 0.4, 0.3, d - 0.4 }, CF(0, 0.15, 0), C.orangeDark, { studs = false })
	it.block("Body", { w, h, d }, CF(0, 0.3 + h / 2, 0), C.orange)
	-- ribs: darker flat strips on the front and sides
	for i, x in { -1.0, 1.0 } do
		plate(it, "RibF" .. i, { 0.18, h - 0.3, 0.1 }, CF(x, 0.3 + h / 2, -d / 2 - 0.05), C.orangeDark)
		plate(it, "RibS" .. i, { 0.1, h - 0.3, 0.18 }, CF(x * (w / 2 + 0.05), 0.3 + h / 2, 0), C.orangeDark)
	end
	-- stem + leaf
	it.block("Stem", { 0.5, 0.7, 0.5 }, CF(0, 0.3 + h + 0.35, 0), C.stem)
	it.block("StemTip", { 0.5, 0.25, 0.3 }, CF(0.2, 0.3 + h + 0.8, 0) * A(0, 0, math.rad(-25)), C.stem, { studs = false })
	it.wedge("Leaf", { 0.6, 0.25, 0.9 }, CF(-0.55, 0.3 + h + 0.12, 0.3) * A(0, math.rad(40), 0), C.moss)
	-- face: glowing triangle eyes, nose, a toothy grin (thin plates, like the pets' eyes)
	local fz = -d / 2 - 0.06
	local fy = 0.3 + h / 2
	local glow = C.glowYellow
	for i, x in { -0.62, 0.62 } do
		it.wedge("EyeA" .. i, { 0.12, 0.6, 0.3 }, CF(x - 0.15, fy + 0.45, fz) * A(0, math.rad(90), 0), glow, { neon = true })
		it.wedge("EyeB" .. i, { 0.12, 0.6, 0.3 }, CF(x + 0.15, fy + 0.45, fz) * A(0, math.rad(-90), 0), glow, { neon = true })
	end
	plate(it, "Nose", { 0.3, 0.25, 0.12 }, CF(0, fy + 0.05, fz), glow, true)
	plate(it, "Mouth", { 1.9, 0.5, 0.12 }, CF(0, fy - 0.5, fz), glow, true)
	plate(it, "ToothT", { 0.3, 0.22, 0.14 }, CF(-0.35, fy - 0.36, fz - 0.01), C.orange)
	plate(it, "ToothB", { 0.3, 0.22, 0.14 }, CF(0.4, fy - 0.64, fz - 0.01), C.orange)
	it.light({ 0, fy, -1.0 }, C.glowOrange, 10, 1.4)
	return it
end)

return items
