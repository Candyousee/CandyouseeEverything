-- Kit: builds a blocky rig (same format as rigs/Cat.luau) from an Animals.luau entry.
-- One builder per body plan; measurements come from the shared animation modules
-- so joints always sit exactly where the animations expect them.

local Kit = {}

local W = { 246, 244, 238 }
local K = { 27, 27, 32 }

local function seg(base, pitch, len)
	local p = math.rad(pitch)
	local dy, dz = math.sin(p), math.cos(p)
	local center = { base[1], base[2] + dy * len / 2, base[3] + dz * len / 2 }
	local function along(d)
		return { base[1], base[2] + dy * d, base[3] + dz * d }
	end
	return center, { -pitch, 0, 0 }, along
end

local function palette(p)
	local c = p.colors
	local function get(key, ...)
		if c[key] then
			return c[key]
		end
		for i = 1, select("#", ...) do
			local k = select(i, ...)
			if c[k] then
				return c[k]
			end
		end
		return c.main
	end
	return get
end

local function rigBuilder()
	local parts, count = {}, {}
	local function add(t)
		table.insert(parts, t)
		return t
	end
	-- unique decoration names: Spot1, Spot2...
	local function name(base)
		count[base] = (count[base] or 0) + 1
		return base .. count[base]
	end
	return parts, add, name
end

-- Front-facing eyes with a joint each (they slide back into the head to blink).
local function frontEyes(add, parent, x, y, zFront, size, eyeColor, glint, glow)
	for _, side in { -1, 1 } do
		local nm = if side < 0 then "L" else "R"
		local ex = side * x
		add({ name = "Eye" .. nm, size = { size[1], size[2], 0.1 }, pos = { ex, y, zFront - 0.05 }, color = eyeColor, neon = glow, joint = { parent, { ex, y, zFront - 0.05 } } })
		if glow then
			-- glowing eyes: no pupil or glint
		elseif eyeColor[1] + eyeColor[2] > 200 then
			-- coloured eyes get a slit pupil instead of a glint
			add({ name = "Pupil" .. nm, size = { 0.12, size[2] * 0.7, 0.04 }, pos = { ex, y, zFront - 0.12 }, color = K, weld = "Eye" .. nm })
		else
			add({ name = "Glint" .. nm, size = { 0.15, 0.15, 0.04 }, pos = { ex + size[1] * 0.22, y + size[2] * 0.24, zFront - 0.12 }, color = glint, weld = "Eye" .. nm })
		end
	end
end

local function tailChain(add, base, t1, t2, w, lens, color, tipColor, tipSize, rings, ringColor)
	local p1, r1, along1 = seg(base, t1, lens[1])
	add({ name = "Tail1", size = { w, w, lens[1] }, pos = p1, rot = r1, color = color, joint = { "Torso", base } })
	if not lens[2] then
		return
	end
	local b2 = along1(lens[1] - 0.1)
	local p2, r2, along2 = seg(b2, t2, lens[2])
	add({ name = "Tail2", size = { w * 0.88, w * 0.88, lens[2] }, pos = p2, rot = r2, color = color, joint = { "Tail1", b2 } })
	if tipColor then
		add({ name = "TailTip", size = { tipSize, tipSize, math.min(0.45, tipSize) }, pos = along2(lens[2] - math.min(0.45, tipSize) / 2 + 0.02), rot = r2, color = tipColor, weld = "Tail2" })
	end
	if rings then
		add({ name = "TailRing1", size = { w + 0.06, w + 0.06, 0.22 }, pos = along1(lens[1] * 0.5), rot = r1, color = ringColor, weld = "Tail1" })
		add({ name = "TailRing2", size = { w * 0.88 + 0.06, w * 0.88 + 0.06, 0.22 }, pos = along2(lens[2] * 0.4), rot = r2, color = ringColor, weld = "Tail2" })
	end
end

---------------------------------------------------------------------------
-- Quadrupeds
---------------------------------------------------------------------------
function Kit.Quadruped(p, Q)
	local spec = Q.measure(p)
	local col = palette(p)
	local parts, add, name = rigBuilder()
	local b = p.body or { 2, 1.4, 3.2 }
	local legH, legW = p.legH or 1.3, p.legW or 0.8
	local rootY, hipX, zLeg = spec.rootY, spec.hipX, spec.hipZB
	local top = rootY + b[2] / 2

	add({ name = "Torso", size = b, pos = { 0, rootY, 0 }, color = col("main"), studs = not p.wool, joint = { "RootPart", { 0, rootY, 0 } } })
	add({ name = "Chest", size = { b[1] * 0.55, b[2] * 0.5, 0.05 }, pos = { 0, rootY - b[2] * 0.15, -b[3] / 2 - 0.025 }, color = col("accent"), weld = "Torso" })
	for _, leg in { { "FL", -1, -zLeg }, { "FR", 1, -zLeg }, { "BL", -1, zLeg }, { "BR", 1, zLeg } } do
		local x, z = leg[2] * hipX, leg[3]
		local pawH = math.min(0.4, legH * 0.5)
		add({ name = "Leg" .. leg[1], size = { legW, legH + 0.2 - pawH, legW }, pos = { x, (pawH + legH + 0.2) / 2, z }, color = col("leg"), joint = { "Torso", { x, legH, z } } })
		add({ name = "Paw" .. leg[1], size = { legW, pawH, legW }, pos = { x, pawH / 2, z }, color = col("paw", "accent"), weld = "Leg" .. leg[1] })
	end
	if p.wool then
		add({ name = "Wool", size = { b[1] + 0.3, 0.6, b[3] - 0.4 }, pos = { 0, top + 0.2, 0 }, color = col("main"), studs = true, weld = "Torso" })
	end
	for i = 1, p.hump or 0 do
		local z = if p.hump == 1 then 0 else (i - 1.5) * b[3] * 0.4
		local hh = p.humpH or 0.8
		add({ name = name("Hump"), size = { b[1] * 0.6, hh, b[3] * 0.3 }, pos = { 0, top + hh / 2 - 0.05, z }, color = col("main"), studs = true, weld = "Torso" })
	end

	-- neck + head
	local h = table.clone(p.head or { 2.4, 1.6, 1.8 })
	if math.abs(h[1] - b[1]) < 0.05 then
		h[1] += 0.2
	end
	local headParent, headY, headZ, headPivot = "Torso", 0, 0, nil
	if p.neck then
		local nw = p.neckW or 1.0
		local nz = -b[3] / 2 + nw / 2 + 0.15
		local baseY = top - 0.3
		local Ln = p.neck + 0.3
		-- the neck leans forward by neckLean degrees (horses, dragons...)
		local th = math.rad(p.neckLean or 0)
		local dir = { 0, math.cos(th), -math.sin(th) }
		local back = { 0, math.sin(th), math.cos(th) }
		local function along(d, off)
			off = off or 0
			return { 0, baseY + dir[2] * d + back[2] * off, nz + dir[3] * d + back[3] * off }
		end
		local rot = { -(p.neckLean or 0), 0, 0 }
		local topPt = along(Ln)
		add({ name = "Neck", size = { nw, Ln, nw }, pos = along(Ln / 2), rot = rot, color = col("main"), joint = { "Torso", { 0, baseY, nz } } })
		if p.maneStrip then
			add({ name = "NeckMane", size = { 0.7, p.neck + 0.6, 0.7 }, pos = along(Ln / 2 + 0.2, nw / 2 + 0.3), rot = rot, color = col("mane", "dark"), weld = "Neck" })
			add({ name = "Forelock", size = { 0.75, 0.6, 0.55 }, pos = along(Ln + 0.35, nw / 2 - 0.1), rot = rot, color = col("mane", "dark"), weld = "Neck" })
		end
		if p.markings == "giraffe" or p.markings == "zebra" then
			for i = 1, 3 do
				for _, side in { -1, 1 } do
					local c = along(Ln * i / 3.8, if p.markings == "zebra" then 0 else (i % 2 - 0.5) * 0.3)
					add({ name = name("NeckMark"), size = { 0.05, math.min(0.4, p.neck / 4), if p.markings == "zebra" then nw * 0.7 else 0.4 }, pos = { side * (nw / 2 + 0.025), c[2], c[3] }, rot = rot, color = col("dark"), weld = "Neck" })
				end
			end
		end
		headParent = "Neck"
		headY = topPt[2] + h[2] / 2 - 0.5
		headZ = topPt[3] - h[3] / 2 + nw / 2 + 0.2
		headPivot = { 0, topPt[2] - 0.3, topPt[3] }
	else
		headZ = -b[3] / 2 - h[3] / 2 + 0.6
		headY = top - 0.3 + h[2] / 2 + (p.headUp or 0)
		headPivot = { 0, headY - h[2] / 2 + 0.2, headZ + h[3] / 2 - 0.4 }
	end
	add({ name = "Head", size = h, pos = { 0, headY, headZ }, color = col("head"), studs = not p.mane, joint = { headParent, headPivot } })
	local hw = h[1]
	local headFront, headTop, headBottom = headZ - h[3] / 2, headY + h[2] / 2, headY - h[2] / 2

	-- snout, nose, jaw
	local sn = p.snout or { 1.2, 0.6, 0.4 }
	local snY = headBottom + sn[2] / 2 + (p.snoutLift or 0.15)
	local snZ = headFront - sn[3] / 2 + 0.05
	local snFront, snTop = snZ - sn[3] / 2, snY + sn[2] / 2
	add({ name = "Muzzle", size = sn, pos = { 0, snY, snZ }, color = col("snout", "accent"), studs = true, weld = "Head" })
	if p.nostrils then
		for _, side in { -1, 1 } do
			add({ name = name("Nostril"), size = { 0.18, 0.18, 0.06 }, pos = { side * sn[1] * 0.22, snY + sn[2] * 0.1, snFront - 0.03 }, color = col("nose", "dark"), weld = "Head" })
		end
	elseif not p.noNose then
		add({ name = "Nose", size = { math.min(0.55, sn[1] * 0.45), 0.28, 0.1 }, pos = { 0, snTop - 0.2, snFront - 0.05 }, color = col("nose", "dark"), weld = "Head" })
	end
	if p.jaw then
		local jw = { sn[1] * 0.85, 0.3, sn[3] * 0.85 }
		local jawY = snY - sn[2] / 2 - 0.13
		local jawZ = snZ + sn[3] * 0.05
		add({ name = "Jaw", size = jw, pos = { 0, jawY, jawZ }, color = col("snout", "accent"), joint = { "Head", { 0, jawY + 0.13, jawZ + jw[3] / 2 } } })
		add({ name = "Tongue", size = { jw[1] * 0.5, 0.08, jw[3] * 0.7 }, pos = { 0, jawY + 0.18, jawZ }, color = { 240, 110, 130 }, weld = "Jaw" })
	end
	if p.trunk then
		local tz = snFront + 0.3
		local tl = p.trunkLen or 2.0
		add({ name = "Trunk", size = { 0.7, tl, 0.7 }, pos = { 0, snY + sn[2] / 2 - 0.05 - tl / 2, tz }, color = col("main"), joint = { "Head", { 0, snY, tz } } })
		add({ name = "TrunkTip", size = { 0.62, 0.6, 0.9 }, pos = { 0, snY + sn[2] / 2 - 0.05 - tl + 0.27, tz - 0.3 }, color = col("trunkTip", "main"), weld = "Trunk" })
	end
	if p.tusks then
		for _, side in { -1, 1 } do
			add({ name = name("Tusk"), size = { 0.25, 0.25, 0.9 }, pos = { side * 0.5, snY - 0.35, snFront - 0.15 }, rot = { 25, 0, 0 }, color = col("horn"), weld = "Head" })
		end
	end

	-- eyes (above the muzzle, below the top of the head)
	local es = p.eyeSize or { 0.4, 0.5 }
	local eyeY = math.max(headY + h[2] * 0.08, snTop + es[2] / 2 + 0.06)
	eyeY = math.min(eyeY, headTop - es[2] / 2 - 0.06)
	local eyeX = p.eyeX or math.max(hw * 0.24, sn[1] / 2 * 0.2 + 0.35)
	if p.markings == "panda" then
		for _, side in { -1, 1 } do
			add({ name = name("EyePatch"), size = { es[1] + 0.3, es[2] + 0.3, 0.03 }, pos = { side * eyeX, eyeY - 0.05, headFront - 0.025 }, color = col("dark"), weld = "Head" })
		end
	elseif p.markings == "mask" then
		add({ name = "Mask", size = { hw * 0.85, es[2] + 0.2, 0.03 }, pos = { 0, eyeY, headFront - 0.025 }, color = col("dark"), weld = "Head" })
	end
	if p.eyeRing then
		for _, side in { -1, 1 } do
			add({ name = name("EyeRing"), size = { es[1] + 0.3, es[2] + 0.3, 0.35 }, pos = { side * eyeX, eyeY, headFront - 0.16 }, color = col("ring", "main"), weld = "Head" })
		end
	end
	frontEyes(add, "Head", eyeX, eyeY, headFront - (if p.eyeRing then 0.33 else 0), es, p.colors.eye or K, W, p.eyeGlow)

	-- mane (lion) sits round the head; ears go on top of it
	local earBaseY = headTop
	if p.mane then
		local mh = h[2] + 0.7
		add({ name = "Mane", size = { hw + 0.8, mh, h[3] * 0.85 }, pos = { 0, headY + 0.1, headZ + h[3] * 0.15 }, color = col("mane", "dark"), studs = true, weld = "Head" })
		add({ name = "ChinRuff", size = { hw * 0.75, 0.55, h[3] * 0.55 }, pos = { 0, headBottom - 0.15, headZ + h[3] * 0.05 }, color = col("mane", "dark"), weld = "Head" })
		earBaseY = headY + 0.1 + mh / 2
	end
	if p.wool then
		add({ name = "WoolCap", size = { hw + 0.2, 0.45, h[3] * 0.6 }, pos = { 0, headTop + 0.1, headZ + 0.1 }, color = col("wool", "main"), studs = true, weld = "Head" })
	end
	if p.pompoms then
		-- poodle cut: fluffy cuffs on every ankle and a topknot
		for _, leg in { "FL", "FR", "BL", "BR" } do
			local lx = (if leg:sub(2, 2) == "L" then -1 else 1) * hipX
			local lz = if leg:sub(1, 1) == "F" then -zLeg else zLeg
			add({ name = "Cuff" .. leg, size = { legW + 0.3, 0.55, legW + 0.3 }, pos = { lx, 0.5, lz }, color = col("wool", "accent"), weld = "Leg" .. leg })
		end
		add({ name = "Topknot", size = { hw * 0.6, 0.6, h[3] * 0.45 }, pos = { 0, headTop + 0.55, headZ + 0.05 }, color = col("wool", "accent"), studs = true, weld = "Head" })
	end
	if p.casque then
		add({ name = "Casque", class = "WedgePart", size = { hw * 0.5, 0.8, h[3] * 0.9 }, pos = { 0, headTop + 0.35, headZ + 0.1 }, color = col("dark"), weld = "Head" })
	end

	-- ears
	local ear = col("ear", "main")
	local inner = p.colors.innerEar or col("accent")
	local es2 = p.earSize or 0.8
	for _, side in { -1, 1 } do
		local nm = if side < 0 then "L" else "R"
		if p.ears == "perky" then
			local x, z = side * hw * 0.3, headZ + 0.15
			add({ name = "Ear" .. nm, class = "WedgePart", size = { 0.3, es2, es2 }, pos = { x, earBaseY + es2 / 2, z }, rot = { 0, side * 90, 0 }, color = ear, joint = { "Head", { x, earBaseY, z } } })
			add({ name = "InnerEar" .. nm, class = "WedgePart", size = { 0.05, es2 * 0.62, es2 * 0.62 }, pos = { side * (math.abs(x) + es2 * 0.19 - 0.1), earBaseY + es2 * 0.31, z - 0.175 }, rot = { 0, side * 90, 0 }, color = inner, weld = "Ear" .. nm })
		elseif p.ears == "round" then
			local x, z = side * math.max(hw / 2 - es2 / 2 - 0.06, es2 / 2 + 0.05), headZ + 0.2
			add({ name = "Ear" .. nm, size = { es2, es2, 0.3 }, pos = { x, earBaseY + es2 / 2 - 0.12, z }, color = ear, joint = { "Head", { x, earBaseY - 0.1, z } } })
			add({ name = "InnerEar" .. nm, size = { es2 * 0.55, es2 * 0.55, 0.05 }, pos = { x, earBaseY + es2 / 2 - 0.17, z - 0.175 }, color = inner, weld = "Ear" .. nm })
		elseif p.ears == "koala" then
			local x, z = side * (hw / 2 + es2 * 0.42), headZ + 0.15
			add({ name = "Ear" .. nm, size = { es2, es2, 0.4 }, pos = { x, headTop - 0.3, z }, color = ear, joint = { "Head", { side * hw / 2, headTop - 0.2, z } } })
			add({ name = "InnerEar" .. nm, size = { es2 * 0.62, es2 * 0.62, 0.05 }, pos = { x, headTop - 0.3, z - 0.225 }, color = inner, weld = "Ear" .. nm })
		elseif p.ears == "tall" then
			local x, z = side * hw * 0.28, headZ + h[3] * 0.2
			add({ name = "Ear" .. nm, size = { 0.35, es2, 0.3 }, pos = { x, earBaseY + es2 / 2 - 0.1, z }, color = ear, joint = { "Head", { x, earBaseY - 0.1, z } } })
			add({ name = "InnerEar" .. nm, size = { 0.2, es2 * 0.7, 0.05 }, pos = { x, earBaseY + es2 / 2 - 0.1, z - 0.175 }, color = inner, weld = "Ear" .. nm })
			if p.colors.earTip then
				add({ name = "EarTip" .. nm, size = { 0.37, es2 * 0.22, 0.32 }, pos = { x, earBaseY + es2 - 0.1 - es2 * 0.11 + 0.01, z }, color = p.colors.earTip, weld = "Ear" .. nm })
			end
		elseif p.ears == "side" then
			local y, z = headTop - 0.25, headZ + 0.1
			add({ name = "Ear" .. nm, size = { es2, 0.3, 0.45 }, pos = { side * (hw / 2 + es2 / 2 - 0.1), y, z }, color = ear, joint = { "Head", { side * hw / 2, y, z } } })
			add({ name = "InnerEar" .. nm, size = { es2 * 0.6, 0.05, 0.28 }, pos = { side * (hw / 2 + es2 / 2), y + 0.175, z }, color = inner, weld = "Ear" .. nm })
		elseif p.ears == "floppy" or p.ears == "elephant" then
			local big = p.ears == "elephant"
			local sz = if big then { 0.3, 2.2, 1.8 } else { 0.3, es2 * 1.4, p.earW or es2 }
			local x, z = side * (hw / 2 + (if big then 0.2 else 0.15)), headZ + (if big then 0.3 else 0.1)
			local ty = headTop + (if big then -0.1 else 0.05)
			add({ name = "Ear" .. nm, size = sz, pos = { x, ty - sz[2] / 2, z }, color = ear, joint = { "Head", { x, ty - 0.1, z } } })
		end
	end

	-- horns & head decorations
	local horn = col("horn", "accent")
	if p.horns == "bull" then
		for _, side in { -1, 1 } do
			local hy = headTop - 0.22 + (if p.wool or p.mane then 0.45 else 0)
			add({ name = name("Horn"), size = { 1.0, 0.3, 0.3 }, pos = { side * (hw / 2 + 0.42), hy, headZ + 0.3 }, color = horn, weld = "Head" })
			add({ name = name("HornTip"), size = { 0.3, 0.6, 0.35 }, pos = { side * (hw / 2 + 0.74), hy + 0.42, headZ + 0.3 }, color = horn, weld = "Head" })
		end
	elseif p.horns == "goat" then
		for _, side in { -1, 1 } do
			local hl = p.hornLen or 0.9
			add({ name = name("Horn"), size = { 0.26, hl, 0.26 }, pos = { side * hw * 0.22, headTop + hl * 0.4, headZ + 0.2 + hl * 0.2 }, rot = { 30, 0, side * -6 }, color = horn, weld = "Head" })
		end
	elseif p.horns == "unicorn" then
		add({ name = "Horn", size = { 0.34, 0.8, 0.34 }, pos = { 0, headTop + 0.3, headFront + 0.5 }, rot = { -15, 0, 0 }, color = horn, weld = "Head" })
		add({ name = "HornTip", size = { 0.2, 0.5, 0.2 }, pos = { 0, headTop + 0.88, headFront + 0.34 }, rot = { -15, 0, 0 }, color = horn, weld = "Head" })
	elseif p.horns == "rhino" then
		add({ name = "Horn", size = { 0.5, 0.9, 0.5 }, pos = { 0, snTop + 0.35, snZ - sn[3] * 0.15 }, rot = { -15, 0, 0 }, color = horn, weld = "Head" })
		add({ name = "HornBack", size = { 0.35, 0.45, 0.35 }, pos = { 0, snTop + 0.15, snZ + sn[3] * 0.35 }, color = horn, weld = "Head" })
	elseif p.horns == "antlers" then
		for _, side in { -1, 1 } do
			local x = side * (hw * 0.22 + 0.2)
			local az = headZ + 0.1 + (if p.ears == "tall" then 0.75 else 0)
			add({ name = name("Antler"), size = { 0.2, 1.1, 0.2 }, pos = { x, headTop + 0.5, az }, rot = { 0, 0, -side * 25 }, color = horn, weld = "Head" })
			add({ name = name("Tine"), size = { 0.2, 0.6, 0.24 }, pos = { x + side * 0.3, headTop + 0.95, az }, rot = { 0, 0, side * 20 }, color = horn, weld = "Head" })
			add({ name = name("Tine"), size = { 0.2, 0.5, 0.2 }, pos = { x + side * 0.12, headTop + 0.7, az - 0.28 }, rot = { -35, 0, 0 }, color = horn, weld = "Head" })
		end
	elseif p.horns == "ossicones" then
		for _, side in { -1, 1 } do
			add({ name = name("Ossicone"), size = { 0.22, 0.55, 0.22 }, pos = { side * hw * 0.22, headTop + 0.25, headZ + 0.2 }, color = horn, weld = "Head" })
			add({ name = name("OssiconeTip"), size = { 0.32, 0.22, 0.32 }, pos = { side * hw * 0.22, headTop + 0.55, headZ + 0.2 }, color = col("dark"), weld = "Head" })
		end
	end
	if p.beard then
		add({ name = "Beard", size = { 0.4, 0.55, 0.3 }, pos = { 0, headBottom - 0.15, snZ + sn[3] * 0.3 }, color = col("dark"), weld = "Head" })
	end

	-- extra body features
	if p.shell then
		add({ name = "ShellRim", size = { b[1] + 0.4, 0.2, b[3] + 0.3 }, pos = { 0, top, 0 }, color = col("accent"), weld = "Torso" })
		add({ name = "Shell", size = { b[1] + 0.2, 0.7, b[3] + 0.1 }, pos = { 0, top + 0.4, 0 }, color = col("shell", "dark"), studs = true, weld = "Torso" })
		add({ name = "ShellTop", size = { b[1] - 0.4, 0.35, b[3] - 0.7 }, pos = { 0, top + 0.9, 0 }, color = col("shell", "dark"), studs = true, weld = "Torso" })
		if p.shellBands then
			for i = 1, 3 do
				add({ name = name("ShellBand"), size = { b[1] + 0.24, 0.74, 0.18 }, pos = { 0, top + 0.4, (i - 2) * b[3] * 0.28 }, color = col("accent"), weld = "Torso" })
			end
		end
		if p.shellSpikes then
			-- ankylosaur armour: spikes along both shell edges
			for i = 1, 4 do
				for _, side in { -1, 1 } do
					add({ name = name("SideSpike"), size = { 0.9, 0.4, 0.4 }, pos = { side * (b[1] / 2 + 0.5), top + 0.3, -b[3] * 0.36 + (i - 1) * b[3] * 0.24 }, rot = { 0, 0, side * 20 }, color = col("horn", "accent"), weld = "Torso" })
				end
			end
		end
	end
	if p.quills then
		local nq = if p.bigQuills then 5 else 3
		local nc = if p.bigQuills then 4 else 3
		for i = 1, nq do
			for j = 1, nc do
				local ql = if p.bigQuills then 1.1 else 0.55
				add({ name = name("Quill"), size = { 0.22, ql, 0.22 }, pos = { (j - (nc + 1) / 2) * b[1] * 0.28, top + ql * 0.3, (i - (nq + 1) / 2) * b[3] * 0.21 }, rot = { 40, 0, (j - (nc + 1) / 2) * -22 }, color = col("quill", "dark"), weld = "Torso" })
			end
		end
	end
	if p.wings then
		-- animated wings (WingL / WingR joints at the shoulders)
		local ws = p.wingSize or { 1.4, 1.6 }
		local wz = p.wingZ or -0.1
		for _, side in { -1, 1 } do
			local nm = if side < 0 then "L" else "R"
			local th, ph = math.rad(-side * 28), math.rad(-15)
			local up = { -math.sin(th), math.cos(th) * math.cos(ph), math.cos(th) * math.sin(ph) }
			local root = { side * (b[1] / 2 - 0.15), top - 0.05, wz }
			local function at(d)
				return { root[1] + up[1] * d, root[2] + up[2] * d, root[3] + up[3] * d }
			end
			add({ name = "Wing" .. nm, size = { 0.2, ws[1], ws[2] }, pos = at(ws[1] / 2), rot = { -15, 0, -side * 28 }, color = col("wing", "main"), joint = { "Torso", root } })
			add({ name = "WingTip" .. nm, size = { 0.24, ws[1] * 0.34, ws[2] + 0.02 }, pos = at(ws[1] * 0.83 + 0.01), rot = { -15, 0, -side * 28 }, color = col("wingTip", "accent"), weld = "Wing" .. nm })
			if p.wingRibs then
				add({ name = "WingRib" .. nm, size = { 0.26, ws[1] * 0.62, 0.16 }, pos = at(ws[1] * 0.36), rot = { -15, 0, -side * 28 }, color = col("dark"), weld = "Wing" .. nm })
			end
		end
	end
	if p.backPlates then
		for i = 1, 4 do
			local side = if i % 2 == 0 then 1 else -1
			add({ name = name("Plate"), class = "WedgePart", size = { 0.2, 0.9, 0.8 }, pos = { side * 0.25, top + 0.4, -b[3] * 0.35 + (i - 1) * b[3] * 0.22 }, color = col("plate", "accent"), weld = "Torso" })
		end
	end
	if p.frill then
		add({ name = "Frill", size = { hw + 1.4, h[2] + 0.9, 0.3 }, pos = { 0, headY + 0.35, headZ + h[3] / 2 + 0.1 }, rot = { 35, 0, 0 }, color = col("frill", "accent"), weld = "Head" })
		add({ name = "FrillRim", size = { hw + 1.5, 0.3, 0.34 }, pos = { 0, headY + 0.35 + (h[2] + 0.9) / 2 * 0.82, headZ + h[3] / 2 + 0.1 + (h[2] + 0.9) / 2 * 0.57 }, rot = { 35, 0, 0 }, color = col("dark"), weld = "Head" })
		for _, side in { -1, 1 } do
			add({ name = name("BrowHorn"), size = { 0.34, 0.34, 1.7 }, pos = { side * hw * 0.28, headTop + 0.1, headFront - 0.5 }, rot = { -30, 0, 0 }, color = col("horn"), weld = "Head" })
		end
		add({ name = "NoseHorn", size = { 0.34, 0.7, 0.34 }, pos = { 0, snTop + 0.3, snZ - sn[3] * 0.2 }, rot = { -15, 0, 0 }, color = col("horn"), weld = "Head" })
	end
	if p.headGills then
		for _, side in { -1, 1 } do
			for i, dy in { 0.35, 0, -0.35 } do
				add({ name = name("Gill"), size = { 0.18, 0.9, 0.18 }, pos = { side * (hw / 2 + 0.4), headY + dy * 1.3, headZ + 0.3 + (i - 2) * 0.28 }, rot = { (i - 2) * 25, 0, -side * (i - 2) * 35 + side * 30 }, color = col("gill", "dark"), weld = "Head" })
			end
		end
	end
	if p.horns == "moose" then
		for _, side in { -1, 1 } do
			add({ name = name("Beam"), size = { 0.6, 0.25, 0.25 }, pos = { side * (hw / 2 + 0.2), headTop + 0.05, headZ + 0.1 }, color = col("horn"), weld = "Head" })
			add({ name = name("Palm"), size = { 1.7, 0.25, 1.1 }, pos = { side * (hw / 2 + 1.0), headTop + 0.55, headZ + 0.1 }, rot = { 0, 0, side * 28 }, color = col("horn"), weld = "Head" })
			for i = 1, 3 do
				add({ name = name("PalmTine"), size = { 0.2, 0.5, 0.2 }, pos = { side * (hw / 2 + 0.55 + i * 0.4), headTop + 0.75 + i * 0.22, headZ + 0.1 + (i - 2) * 0.35 }, rot = { 0, 0, side * 28 }, color = col("horn"), weld = "Head" })
			end
		end
	elseif p.horns == "dragon" then
		for _, side in { -1, 1 } do
			add({ name = name("Horn"), size = { 0.32, 0.32, 1.3 }, pos = { side * hw * 0.3, headTop + 0.3, headZ + 0.55 }, rot = { 35, 0, 0 }, color = col("horn"), weld = "Head" })
			add({ name = name("HornTip"), size = { 0.22, 0.22, 0.6 }, pos = { side * hw * 0.3, headTop + 0.78, headZ + 1.1 }, rot = { 55, 0, 0 }, color = col("horn"), weld = "Head" })
		end
	elseif p.horns == "ram" then
		for _, side in { -1, 1 } do
			add({ name = name("RamHorn"), size = { 0.45, 0.45, 0.9 }, pos = { side * (hw / 2 + 0.1), headTop - 0.2, headZ + 0.25 }, color = col("horn"), weld = "Head" })
			add({ name = name("RamCurl"), size = { 0.44, 0.65, 0.44 }, pos = { side * (hw / 2 + 0.1), headTop - 0.6, headZ - 0.15 }, color = col("horn"), weld = "Head" })
		end
	end
	if p.teeth then
		for _, side in { -1, 1 } do
			add({ name = name("Tooth"), size = { 0.18, 0.25, 0.05 }, pos = { side * 0.1, snY - sn[2] / 2 - 0.1, snFront + 0.05 }, color = W, weld = "Head" })
		end
	end
	if p.beakSnout then
		add({ name = "BeakHook", size = { sn[1] * 0.6, 0.35, 0.3 }, pos = { 0, snY - sn[2] / 2 - 0.1, snFront + 0.1 }, color = col("snout", "accent"), weld = "Head" })
	end

	-- body markings
	local mk = p.markings
	local function sideMarks(list, size, color)
		for i, m in list do
			for _, side in { -1, 1 } do
				add({ name = name("Mark"), size = { 0.05, size[1], size[2] }, pos = { side * (b[1] / 2 + 0.025 + i * 0.008), rootY + m[2] * b[2], m[1] * b[3] }, color = color, weld = "Torso" })
			end
		end
	end
	local SPOTS = { { -0.32, 0.2 }, { -0.1, -0.12 }, { 0.12, 0.22 }, { 0.3, -0.1 }, { -0.28, -0.25 }, { 0.05, 0.05 } }
	if (mk == "stripes" or mk == "zebra") and hw < 2.2 then
		local n = if mk == "zebra" then 6 else 4
		local list = {}
		for i = 1, n do
			table.insert(list, { -0.36 + (i - 1) * 0.72 / (n - 1), 0.2 })
		end
		sideMarks(list, { b[2] * 0.6, 0.22 }, col("dark"))
	elseif mk == "stripes" or mk == "zebra" then
		local n = if mk == "zebra" then 6 else 4
		local list = {}
		for i = 1, n do
			table.insert(list, { -0.36 + (i - 1) * 0.72 / (n - 1), 0.2 })
		end
		sideMarks(list, { b[2] * 0.6, 0.22 }, col("dark"))
		for i, x in { -0.18, 0, 0.18 } do
			add({ name = name("BrowStripe"), size = { 0.11, 0.3, 0.05 }, pos = { x, headTop - 0.2 - (if i == 2 then 0.05 else 0), headFront - 0.025 }, color = col("dark"), weld = "Head" })
		end
	elseif mk == "spots" then
		local ss = p.spotSize or 0.28
		sideMarks(SPOTS, { ss, ss }, col("dark"))
	elseif mk == "giraffe" then
		sideMarks(SPOTS, { 0.45, 0.5 }, col("dark"))
	elseif mk == "fawn" then
		sideMarks({ { -0.25, 0.3 }, { 0, 0.32 }, { 0.25, 0.3 }, { -0.12, 0.1 }, { 0.12, 0.12 } }, { 0.18, 0.18 }, col("accent"))
	elseif mk == "patches" then
		sideMarks({ { -0.2, 0.05 }, { 0.25, -0.1 } }, { b[2] * 0.55, b[3] * 0.28 }, col("dark"))
		add({ name = "HeadPatch", size = { 0.05, h[2] * 0.45, h[3] * 0.5 }, pos = { hw / 2 + 0.025, headY - h[2] * 0.05, headZ }, color = col("dark"), weld = "Head" })
	elseif mk == "panda" then
		add({ name = "ShoulderBand", size = { b[1] + 0.08, b[2] + 0.08, 0.9 }, pos = { 0, rootY, -b[3] / 2 + 0.9 }, color = col("dark"), weld = "Torso" })
	elseif mk == "cheeks" then
		for _, side in { -1, 1 } do
			add({ name = name("Cheek"), size = { 0.45, 0.4, 0.05 }, pos = { side * (hw / 2 - 0.3), snY + 0.05, headFront - 0.025 }, color = col("accent"), weld = "Head" })
		end
	elseif mk == "skunk" then
		for _, x in { -0.32, 0.32 } do
			add({ name = name("BackStripe"), size = { 0.5, 0.08, b[3] - 0.2 }, pos = { x * 0.85 * b[1], top + 0.04, 0 }, color = col("accent"), weld = "Torso" })
		end
		sideMarks({ { 0, 0.3 } }, { 0.3, b[3] * 0.85 }, col("accent"))
		add({ name = "HeadStripe", size = { 0.3, h[2] * 0.7, 0.04 }, pos = { 0, headTop - h[2] * 0.35, headFront - 0.02 }, color = col("accent"), weld = "Head" })
		add({ name = "HeadCap", size = { 0.34, 0.08, h[3] * 0.9 }, pos = { 0, headTop + 0.04, headZ }, color = col("accent"), weld = "Head" })
	elseif mk == "chipmunk" then
		for _, x in { -0.35, 0.35 } do
			add({ name = name("BackStripe"), size = { 0.22, 0.08, b[3] - 0.3 }, pos = { x, top + 0.04, 0 }, color = col("dark"), weld = "Torso" })
		end
		sideMarks({ { 0, 0.15 } }, { 0.22, b[3] * 0.8 }, col("dark"))
	elseif mk == "okapi" then
		-- stripes only on the rump
		sideMarks({ { 0.2, 0.05 }, { 0.3, 0.05 }, { 0.4, 0.05 } }, { b[2] * 0.7, 0.14 }, col("dark"))
	elseif mk == "gazelle" then
		sideMarks({ { 0, -0.05 } }, { 0.18, b[3] * 0.85 }, col("dark"))
	elseif mk == "badger" then
		add({ name = "HeadStripe", size = { 0.3, h[2] * 0.7, 0.04 }, pos = { 0, headTop - h[2] * 0.35, headFront - 0.02 }, color = col("accent"), weld = "Head" })
	elseif mk == "saddle" then
		add({ name = "Saddle", size = { b[1] + 0.06, b[2] * 0.55, b[3] * 0.6 }, pos = { 0, top - b[2] * 0.25, 0.1 }, color = col("dark"), weld = "Torso" })
	elseif mk == "scutes" then
		for i = 1, 4 do
			for _, side in { -1, 1 } do
				add({ name = name("Scute"), size = { 0.35, 0.2, 0.4 }, pos = { side * 0.45, top + 0.08, -b[3] * 0.35 + (i - 1) * b[3] * 0.23 }, color = col("dark"), weld = "Torso" })
			end
		end
	end

	-- tail
	local style = p.tail or "long"
	local base = { 0, top - 0.35, b[3] / 2 - 0.15 }
	local t1, t2 = spec.tailRest[1], spec.tailRest[2]
	local tailCol = col("tail", "main")
	if style == "long" then
		tailChain(add, base, t1, t2, p.tailW or 0.35, p.tailLen or { 1.1, 1.0 }, tailCol, col("tip", "dark"), (p.tailW or 0.35) + 0.06)
	elseif style == "tuft" or style == "hang" then
		local w = if style == "hang" then 0.6 else 0.25
		tailChain(add, base, t1, t2, w, p.tailLen or { 1.0, 1.0 }, if style == "hang" then col("tail", "mane", "dark") else tailCol, col("mane", "dark"), w + 0.25)
	elseif style == "fluffy" then
		local w = p.tailW or 0.6
		tailChain(add, base, t1, t2, w, p.tailLen or { 1.0, 1.0 }, tailCol, col("tip", "accent"), w + 0.08, p.tailRings, col("ring", "dark"))
	elseif style == "curly" then
		tailChain(add, base, 20, 140, p.tailW or 0.2, p.tailLen or { 0.45, 0.4 }, col("curl", "accent"), nil, 0)
	elseif style == "croc" then
		tailChain(add, { 0, rootY, b[3] / 2 - 0.2 }, t1, t2, p.tailW or 0.9, p.tailLen or { 1.8, 1.6 }, tailCol, nil, 0)
	elseif style == "club" then
		tailChain(add, { 0, rootY, b[3] / 2 - 0.2 }, t1, t2, p.tailW or 0.6, p.tailLen or { 1.4, 1.3 }, tailCol, col("dark"), 0.95)
		-- the club itself: a big block on the tail tip
		local p2 = parts[#parts]
		local cs = p.clubSize or 1.2
		add({ name = "Club", size = { cs, cs * 0.65, cs * 0.8 }, pos = p2.pos, rot = p2.rot, color = col("club", "dark"), weld = "Tail2" })
	elseif style == "paddle" then
		local c, r = seg(base, -15, 1.2)
		add({ name = "Tail1", size = { 1.3, 0.36, 1.4 }, pos = c, rot = r, color = col("tail", "dark"), joint = { "Torso", base } })
	elseif style == "thin" then
		tailChain(add, base, t1, t2, 0.2, p.tailLen or { 1.0, 0.9 }, tailCol, nil, 0)
	elseif style == "stub" or style == "puff" then
		local s = if style == "puff" then 0.6 else 0.45
		add({ name = "Tail1", size = { s, s, s }, pos = { 0, top - 0.35, b[3] / 2 + s / 2 - 0.1 }, color = if style == "puff" then col("accent") else tailCol, joint = { "Torso", { 0, top - 0.3, b[3] / 2 - 0.1 } } })
	end
	-- extra welded tails fanned out (kitsune): they wag along with Tail1
	for i = 1, p.extraTails or 0 do
		local yaw = (if i % 2 == 1 then 1 else -1) * (22 + 10 * math.floor((i - 1) / 2))
		local len = (p.tailLen or { 1.0, 1.0 })[1] + (p.tailLen or { 1.0, 1.0 })[2]
		local pr, yr = math.rad(t1 + 10), math.rad(yaw)
		local dir = { math.sin(yr), math.cos(yr) * math.sin(pr), math.cos(yr) * math.cos(pr) }
		add({ name = name("ExtraTail"), size = { 0.5 + i * 0.03, 0.5 + i * 0.03, len * 0.9 }, pos = { base[1] + dir[1] * len * 0.45, base[2] + dir[2] * len * 0.45, base[3] + dir[3] * len * 0.45 }, rot = { -(t1 + 10), yaw, 0 }, color = tailCol, weld = "Tail1" })
		add({ name = name("ExtraTip"), size = { 0.58 + i * 0.03, 0.58 + i * 0.03, 0.4 }, pos = { base[1] + dir[1] * len * 0.88, base[2] + dir[2] * len * 0.88, base[3] + dir[3] * len * 0.88 }, rot = { -(t1 + 10), yaw, 0 }, color = col("accent"), weld = "Tail1" })
	end

	return parts, spec
end

---------------------------------------------------------------------------
-- Flyers
---------------------------------------------------------------------------
function Kit.Flyer(p, F)
	local spec = F.measure(p)
	local col = palette(p)
	local parts, add, name = rigBuilder()
	local b = p.body or { 1.4, 1.4, 1.8 }
	local rootY = spec.rootY
	local top = rootY + b[2] / 2

	add({ name = "Torso", size = b, pos = { 0, rootY, 0 }, color = col("main"), studs = true, joint = { "RootPart", { 0, rootY, 0 } } })
	if not p.stripes and not p.shell then
		add({ name = "Belly", size = { b[1] * 0.72, b[2] * 0.66, 0.05 }, pos = { 0, rootY - b[2] * 0.12, -b[3] / 2 - 0.025 }, color = col("accent"), weld = "Torso" })
		if p.breast then
			-- coloured breast wraps round the front of the flanks
			for _, side in { -1, 1 } do
				add({ name = name("Breast"), size = { 0.05, b[2] * 0.6, b[3] * 0.4 }, pos = { side * (b[1] / 2 + 0.025), rootY - b[2] * 0.12, -b[3] * 0.3 }, color = col("accent"), weld = "Torso" })
			end
		end
	else
		for _, z in { -0.15, 0.35 } do
			add({ name = name("Band"), size = { b[1] + 0.06, b[2] + 0.06, 0.28 }, pos = { 0, rootY, z * b[3] }, color = col("dark"), weld = "Torso" })
		end
	end
	local stingZ = b[3] / 2 + 0.2
	if p.abdomen then
		-- wasp waist: a thin stalk then a pointed striped abdomen
		local ab = p.abdomen
		add({ name = "Waist", size = { 0.3, 0.3, 0.4 }, pos = { 0, rootY - 0.05, b[3] / 2 + 0.15 }, color = col("dark"), weld = "Torso" })
		local az = b[3] / 2 + 0.3 + ab[3] / 2
		add({ name = "Abdomen", size = ab, pos = { 0, rootY - 0.15, az }, color = col("main"), weld = "Torso" })
		for i = 1, 2 do
			add({ name = name("AbBand"), size = { ab[1] + 0.06, ab[2] + 0.06, 0.2 }, pos = { 0, rootY - 0.15, az - ab[3] * 0.2 + (i - 1) * ab[3] * 0.35 }, color = col("dark"), weld = "Torso" })
		end
		-- tapered tip
		add({ name = "AbTip", size = { ab[1] * 0.55, ab[2] * 0.55, 0.45 }, pos = { 0, rootY - 0.15, az + ab[3] / 2 + 0.2 }, color = col("main"), weld = "Torso" })
		stingZ = az + ab[3] / 2 + 0.55
	end
	if p.stinger then
		add({ name = "Stinger", size = { 0.2, 0.2, 0.45 }, pos = { 0, rootY - (if p.abdomen then 0.15 else 0.1), stingZ }, color = col("dark"), weld = "Torso" })
	end
	if p.shell then
		add({ name = "Shell", size = { b[1] + 0.2, b[2] * 0.6, b[3] + 0.1 }, pos = { 0, top - b[2] * 0.2, 0 }, color = col("shell", "main"), studs = true, weld = "Torso" })
		add({ name = "ShellLine", size = { 0.08, b[2] * 0.62, b[3] + 0.12 }, pos = { 0, top - b[2] * 0.2, 0 }, color = K, weld = "Torso" })
		for _, s in { { -1, -0.25 }, { 1, 0.1 }, { -1, 0.35 }, { 1, -0.3 } } do
			add({ name = name("ShellSpot"), size = { 0.5, 0.06, 0.5 }, pos = { s[1] * b[1] * 0.28, top + b[2] * 0.1 + 0.03, s[2] * b[3] }, color = K, weld = "Torso" })
		end
	end
	if p.glowTail then
		add({ name = "Glow", size = { b[1] * 0.8, b[2] * 0.8, 0.7 }, pos = { 0, rootY - 0.05, b[3] / 2 + 0.3 }, color = col("glow", "accent"), neon = true, weld = "Torso" })
	end
	if p.spikes then
		for i = 1, 3 do
			add({ name = name("Spike"), class = "WedgePart", size = { 0.2, 0.45, 0.45 }, pos = { 0, top + 0.2, -b[3] * 0.3 + (i - 1) * b[3] * 0.3 }, color = col("accent"), weld = "Torso" })
		end
	end

	-- head
	local h = table.clone(p.head or { 1.4, 1.2, 1.2 })
	if math.abs(h[1] - b[1]) < 0.05 then
		h[1] += 0.2
	end
	local headY, headZ, pivot
	if p.headOnTop then
		headY, headZ = top + h[2] / 2 - 0.2, -0.05
		pivot = { 0, top - 0.1, headZ }
	else
		headZ = -b[3] / 2 - h[3] / 2 + 0.45
		headY = top - h[2] / 2 + 0.35
		pivot = { 0, headY - h[2] / 2 + 0.2, headZ + h[3] / 2 - 0.3 }
	end
	add({ name = "Head", size = h, pos = { 0, headY, headZ }, color = col("head"), studs = true, joint = { "Torso", pivot } })
	local hw, headFront, headTop = h[1], headZ - h[3] / 2, headY + h[2] / 2
	local beak = col("beak", "accent")
	if p.beak == "hook" then
		add({ name = "Beak", size = { 0.5, 0.45, 0.5 }, pos = { 0, headY - 0.1, headFront - 0.2 }, color = beak, weld = "Head" })
		add({ name = "BeakHook", size = { 0.4, 0.35, 0.2 }, pos = { 0, headY - 0.35, headFront - 0.36 }, color = beak, weld = "Head" })
	elseif p.beak == "small" then
		add({ name = "Beak", size = { 0.4, 0.32, 0.35 }, pos = { 0, headY - 0.15, headFront - 0.12 }, color = beak, weld = "Head" })
	elseif p.beak == "big" then
		add({ name = "Beak", size = { 0.65, 0.65, 1.2 }, pos = { 0, headY - 0.1, headFront - 0.55 }, color = beak, weld = "Head" })
		add({ name = "BeakTip", size = { 0.5, 0.5, 0.3 }, pos = { 0, headY - 0.1, headFront - 1.25 }, color = col("dark"), weld = "Head" })
	elseif p.beak == "pouch" then
		add({ name = "Beak", size = { 0.5, 0.25, 1.5 }, pos = { 0, headY - 0.05, headFront - 0.7 }, color = beak, weld = "Head" })
		add({ name = "Pouch", size = { 0.45, 0.45, 1.1 }, pos = { 0, headY - 0.38, headFront - 0.55 }, color = col("pouch", "accent"), weld = "Head" })
	elseif p.beak == "needle" then
		add({ name = "Beak", size = { 0.18, 0.18, 1.1 }, pos = { 0, headY - 0.1, headFront - 0.52 }, color = beak, weld = "Head" })
	elseif p.beak == "long" then
		add({ name = "Beak", size = { 0.5, 0.45, 1.3 }, pos = { 0, headY - 0.1, headFront - 0.6 }, color = beak, weld = "Head" })
		add({ name = "BeakTip", size = { 0.3, 0.3, 0.9 }, pos = { 0, headY - 0.14, headFront - 1.65 }, color = beak, weld = "Head" })
	elseif p.beak == "snout" then
		local sn = { hw * 0.62, h[2] * 0.45, 0.8 }
		local sy = headY - h[2] / 2 + sn[2] / 2 + 0.1
		add({ name = "Muzzle", size = sn, pos = { 0, sy, headFront - 0.35 }, color = col("main"), studs = true, weld = "Head" })
		for _, side in { -1, 1 } do
			add({ name = name("Nostril"), size = { 0.15, 0.15, 0.06 }, pos = { side * sn[1] * 0.25, sy + 0.05, headFront - 0.78 }, color = col("dark"), weld = "Head" })
		end
		if p.jaw then
			add({ name = "Jaw", size = { sn[1] * 0.85, 0.25, 0.6 }, pos = { 0, sy - sn[2] / 2 - 0.1, headFront - 0.3 }, color = col("accent"), joint = { "Head", { 0, sy - sn[2] / 2, headFront + 0.05 } } })
		end
	end
	local eyeColor = p.colors.eye or K
	local eyeY = headY + h[2] * 0.14
	local eyeX = math.max(hw * 0.26, 0.42)
	local es = if p.eyeRing then { 0.45, 0.55 } else { 0.35, 0.45 }
	if p.eyeRing then
		for _, side in { -1, 1 } do
			add({ name = name("EyeRing"), size = { 0.8, 0.8, 0.03 }, pos = { side * eyeX, eyeY, headFront - 0.025 }, color = col("accent"), weld = "Head" })
		end
	end
	frontEyes(add, "Head", eyeX, eyeY, headFront, es, eyeColor, W)
	if p.crest then
		add({ name = "Crest", size = { 0.3, 0.7, 0.7 }, pos = { 0, headTop + 0.25, headZ + 0.15 }, rot = { -25, 0, 0 }, color = col("accent"), weld = "Head" })
	end
	if p.tufts or p.bigEars then
		local es2 = if p.bigEars then 0.9 else 0.55
		for _, side in { -1, 1 } do
			local nm = if side < 0 then "L" else "R"
			local x = side * hw * 0.32
			add({ name = "Ear" .. nm, class = "WedgePart", size = { 0.25, es2, es2 }, pos = { x, headTop + es2 / 2, headZ }, rot = { 0, side * 90, 0 }, color = col("dark"), joint = { "Head", { x, headTop, headZ } } })
		end
	end
	if p.antennae then
		for _, side in { -1, 1 } do
			add({ name = name("Antenna"), size = { 0.08, 0.8, 0.08 }, pos = { side * 0.28, headTop + 0.35, headZ - 0.05 }, rot = { -15, 0, -side * 18 }, color = col("dark"), weld = "Head" })
			add({ name = name("AntennaTip"), size = { 0.2, 0.2, 0.2 }, pos = { side * 0.4, headTop + 0.72, headZ - 0.15 }, color = col("dark"), weld = "Head" })
		end
	end
	if p.beetleHorn then
		add({ name = "Horn", size = { 0.25, 0.9, 0.25 }, pos = { 0, headTop + 0.25, headFront + 0.05 }, rot = { -30, 0, 0 }, color = col("dark"), weld = "Head" })
	end
	if p.fangs then
		for _, side in { -1, 1 } do
			add({ name = name("Fang"), size = { 0.1, 0.18, 0.06 }, pos = { side * 0.18, headY - h[2] * 0.32, headFront - 0.03 }, color = W, weld = "Head" })
		end
		add({ name = "Nose", size = { 0.3, 0.2, 0.08 }, pos = { 0, headY - 0.12, headFront - 0.04 }, color = col("nose", "accent"), weld = "Head" })
	end
	if p.dragonHorns then
		for _, side in { -1, 1 } do
			add({ name = name("Horn"), size = { 0.25, 0.75, 0.25 }, pos = { side * hw * 0.3, headTop + 0.25, headZ + 0.35 }, rot = { 35, 0, 0 }, color = col("horn"), weld = "Head" })
		end
	end

	-- wings: spread sideways from the shoulder (top-mounted for insects)
	local span, chord = p.wingSpan or 1.8, p.wingChord or 1.1
	local wing = col("wing", "main")
	for _, side in { -1, 1 } do
		local nm = if side < 0 then "L" else "R"
		local px = if p.wingTop then side * 0.3 else side * b[1] / 2
		local py = if p.wingTop then top + (if p.shell then b[2] * 0.1 + 0.12 else 0.02) else rootY + b[2] * 0.25
		local pz = if p.wingTop then -0.1 else 0.1
		add({ name = "Wing" .. nm, size = { span, 0.15, chord }, pos = { px + side * span / 2, py, pz }, color = wing, joint = { "Torso", { px, py, pz } } })
		if p.wingSpots then
			add({ name = name("WingSpot"), size = { span * 0.4, 0.19, chord * 0.4 }, pos = { px + side * span * 0.62, py, pz - chord * 0.12 }, color = col("accent"), weld = "Wing" .. nm })
			add({ name = name("WingEdge"), size = { span * 0.25, 0.17, chord + 0.02 }, pos = { px + side * (span - span * 0.125 + 0.01), py, pz }, color = col("dark"), weld = "Wing" .. nm })
		elseif not p.alwaysFly or p.Name == "Bat" then
			add({ name = name("WingTip"), size = { span * 0.35, 0.17, chord + 0.02 }, pos = { px + side * (span - span * 0.175 + 0.01), py, pz }, color = col("dark"), weld = "Wing" .. nm })
		end
	end

	-- legs + feet
	if spec.hipY > 0 then
		local legH = spec.hipY
		for _, side in { -1, 1 } do
			local nm = if side < 0 then "L" else "R"
			local x = side * spec.hipX
			add({ name = "Leg" .. nm, size = { 0.22, legH + 0.05, 0.22 }, pos = { x, (0.1 + legH + 0.15) / 2, 0 }, color = col("leg", "beak"), joint = { "Torso", { x, legH, 0 } } })
			add({ name = "Foot" .. nm, size = { 0.4, 0.1, 0.55 }, pos = { x, 0.05, -0.1 }, color = col("leg", "beak"), weld = "Leg" .. nm })
		end
	end

	-- tail
	local base = { 0, rootY - b[2] * 0.05, b[3] / 2 - 0.1 }
	if p.tail == "long" or p.tail == "short" then
		local len = if p.tail == "long" then 1.4 else 0.7
		local c, r = seg(base, p.tailPitch or -25, len)
		add({ name = "Tail1", size = { b[1] * 0.6, 0.18, len }, pos = c, rot = r, color = col("tail", "wing", "dark"), joint = { "Torso", base } })
	elseif p.tail == "dragon" then
		tailChain(add, { 0, rootY, b[3] / 2 - 0.2 }, -10, -5, 0.6, { 1.3, 1.2 }, col("main"), col("accent"), 0.5)
	elseif p.tail == "stick" then
		local c, r = seg(base, 0, 2.0)
		add({ name = "Tail1", size = { 0.3, 0.3, 2.0 }, pos = c, rot = r, color = col("main"), joint = { "Torso", base } })
	elseif p.tail == "flame" then
		local c, r = seg(base, -20, 1.6)
		add({ name = "Tail1", size = { b[1] * 0.7, 0.2, 1.6 }, pos = c, rot = r, color = col("tail", "accent"), neon = true, joint = { "Torso", base } })
	end
	return parts, spec
end

---------------------------------------------------------------------------
-- Swimmers
---------------------------------------------------------------------------
function Kit.Swimmer(p, S)
	local spec = S.measure(p)
	local col = palette(p)
	local parts, add, name = rigBuilder()
	local b = p.body or { 1.8, 1.6, 3 }
	local h = table.clone(p.head or { b[1] * 0.95, b[2] * 0.95, b[3] * 0.4 })
	for i = 1, 2 do
		if math.abs(h[i] - b[i]) < 0.05 then
			h[i] -= 0.1
		end
	end
	local rootY = spec.rootY
	local fin = col("fin", "dark")

	add({ name = "Torso", size = b, pos = { 0, rootY, 0 }, color = col("main"), studs = true, joint = { "RootPart", { 0, rootY, 0 } } })
	local headZ = -b[3] / 2 - h[3] / 2 + 0.1
	add({ name = "Head", size = h, pos = { 0, rootY, headZ }, color = col("main"), studs = true, joint = { "Torso", { 0, rootY, -b[3] / 2 + 0.05 } } })
	local headFront = headZ - h[3] / 2
	if p.belly then
		add({ name = "Belly", size = { b[1] * 0.8, 0.05, b[3] * 0.85 }, pos = { 0, rootY - b[2] / 2 - 0.025, 0 }, color = col("accent"), weld = "Torso" })
		add({ name = "HeadBelly", size = { h[1] * 0.8, 0.04, h[3] * 0.8 }, pos = { 0, rootY - h[2] / 2 - 0.02, headZ }, color = col("accent"), weld = "Head" })
	end
	if p.beak then
		add({ name = "Beak", size = { h[1] * 0.45, h[2] * 0.3, 0.7 }, pos = { 0, rootY - h[2] * 0.2, headFront - 0.3 }, color = col("main"), weld = "Head" })
	end
	if p.tusk then
		add({ name = "Tusk", size = { 0.18, 0.18, 2.2 }, pos = { 0, rootY + h[2] * 0.05, headFront - 1.05 }, color = col("horn"), weld = "Head" })
	end
	if p.blowhole then
		add({ name = "Blowhole", size = { 0.45, 0.05, 0.3 }, pos = { 0, rootY + h[2] / 2 + 0.025, headZ + 0.3 }, color = col("dark"), weld = "Head" })
	end
	if p.melon then
		-- beluga's bulging forehead
		add({ name = "Melon", size = { h[1] * 0.9, h[2] * 0.6, h[3] * 0.75 }, pos = { 0, rootY + h[2] * 0.45, headFront + h[3] * 0.3 }, color = col("main"), studs = true, weld = "Head" })
	end
	if p.muzzle then
		-- seal / manatee snout pad with whisker dots
		local mz = { h[1] * 0.55 * (p.muzzleScale or 1), h[2] * 0.4 * (p.muzzleScale or 1), 0.35 }
		add({ name = "Muzzle", size = mz, pos = { 0, rootY - h[2] * 0.12, headFront - 0.15 }, color = col("snout", "accent"), weld = "Head" })
		add({ name = "Nose", size = { 0.35, 0.18, 0.06 }, pos = { 0, rootY - h[2] * 0.12 + mz[2] * 0.25, headFront - 0.35 }, color = K, weld = "Head" })
		for _, side in { -1, 1 } do
			add({ name = name("Whiskers"), size = { 0.06, 0.2, 0.06 }, pos = { side * mz[1] * 0.3, rootY - h[2] * 0.15, headFront - 0.35 }, color = col("dark"), weld = "Head" })
		end
	end
	if p.sideBelly then
		-- pale underside wrapping up the flanks so it reads from above
		for _, side in { -1, 1 } do
			add({ name = name("Flank"), size = { 0.05, b[2] * 0.35, b[3] * 0.85 }, pos = { side * (b[1] / 2 + 0.025), rootY - b[2] * 0.3, 0 }, color = col("accent"), weld = "Torso" })
			add({ name = name("HeadFlank"), size = { 0.05, h[2] * 0.3, h[3] * 0.6 }, pos = { side * (h[1] / 2 + 0.025), rootY - h[2] * 0.33, headZ - h[3] * 0.1 }, color = col("accent"), weld = "Head" })
		end
	end
	if p.shell then
		add({ name = "Shell", size = { b[1] + 0.2, b[2] * 0.7, b[3] + 0.1 }, pos = { 0, rootY + b[2] * 0.45, 0 }, color = col("shell", "dark"), studs = true, weld = "Torso" })
		add({ name = "ShellTop", size = { b[1] - 0.4, b[2] * 0.35, b[3] - 0.6 }, pos = { 0, rootY + b[2] * 0.9, 0 }, color = col("shell", "dark"), studs = true, weld = "Torso" })
	end
	if not p.beak and not p.muzzle then add({ name = "Mouth", size = { h[1] * 0.45, 0.08, 0.05 }, pos = { 0, rootY - h[2] * 0.22, headFront - 0.025 }, color = col("dark"), weld = "Head" }) end
	if p.teeth then
		add({ name = "Teeth", size = { h[1] * 0.5, 0.16, 0.06 }, pos = { 0, rootY - h[2] * 0.32, headFront - 0.03 }, color = W, weld = "Head" })
	end
	if p.gills then
		for i = 1, 3 do
			for _, side in { -1, 1 } do
				add({ name = name("Gill"), size = { 0.05, 0.5, 0.08 }, pos = { side * (h[1] / 2 + 0.025), rootY - 0.05, headZ + h[3] * 0.15 + i * 0.1 }, color = col("dark"), weld = "Head" })
			end
		end
	end
	-- side eyes (blink by sinking sideways)
	local ey = if p.Name == "Clownfish" or p.Name == "Pufferfish" then 0.5 else 0.4
	for _, side in { -1, 1 } do
		local nm = if side < 0 then "L" else "R"
		local x, y, z = side * (h[1] / 2 + 0.05), rootY + h[2] * 0.14, headZ - h[3] * 0.1
		add({ name = "Eye" .. nm, size = { 0.1, ey, ey }, pos = { x, y, z }, color = K, joint = { "Head", { x, y, z } } })
		add({ name = "Glint" .. nm, size = { 0.04, 0.14, 0.14 }, pos = { side * (h[1] / 2 + 0.12), y + ey * 0.2, z - ey * 0.2 }, color = W, weld = "Eye" .. nm })
	end
	-- tail + fins
	local t1 = if p.thinTail then { 0.16, 0.16, 2.0 } else { b[1] * 0.55, b[2] * 0.55, 1.1 }
	add({ name = "Tail1", size = t1, pos = { 0, rootY, b[3] / 2 + t1[3] / 2 - 0.1 }, color = col("main"), joint = { "Torso", { 0, rootY, b[3] / 2 - 0.05 } } })
	local tz = b[3] / 2 + t1[3] - 0.15
	local fs = p.tailFin or 1
	local fluke = if p.thinTail then { 0.3, 0.3, 0.4 } elseif spec.kick == "vertical" then { b[1] * 1.5 * fs, 0.2, 0.8 * fs } else { 0.2, b[2] * 1.3 * fs, 0.8 * fs }
	add({ name = "Tail2", size = fluke, pos = { 0, rootY, tz + fluke[3] / 2 - 0.05 }, color = fin, joint = { "Tail1", { 0, rootY, tz } } })
	if p.fanTail then
		for _, sgn in { -1, 1 } do
			add({ name = name("TailFan"), size = { 0.15 + (sgn + 1) * 0.02, fluke[2] * 0.7, fluke[3] * 1.1 }, pos = { 0, rootY + sgn * fluke[2] * 0.3, tz + fluke[3] * 0.55 }, rot = { sgn * -28, 0, 0 }, color = col("fan", "accent"), weld = "Tail2" })
		end
	end
	local finSize = p.finSize or { 0.8, 0.15, 0.6 }
	for _, side in { -1, 1 } do
		local nm = if side < 0 then "L" else "R"
		local py, pz = rootY - b[2] * (if p.finSize then 0 else 0.25), -b[3] * (if p.finSize then 0 else 0.15)
		add({ name = "Fin" .. nm, size = finSize, pos = { side * (b[1] / 2 + finSize[1] / 2 - 0.02), py, pz }, color = fin, joint = { "Torso", { side * b[1] / 2, py, pz } } })
	end
	if p.tallFins then
		local fh = b[2] * (p.finH or 0.9)
		add({ name = "TopFin", class = "WedgePart", size = { 0.15, fh, b[3] * 0.6 }, pos = { 0, rootY + b[2] / 2 + fh / 2 - 0.05, b[3] * 0.1 }, color = fin, weld = "Torso" })
		add({ name = "BottomFin", class = "WedgePart", size = { 0.15, fh, b[3] * 0.6 }, pos = { 0, rootY - b[2] / 2 - fh / 2 + 0.05, b[3] * 0.1 }, rot = { 180, 180, 0 }, color = fin, weld = "Torso" })
	end
	if p.lure then
		add({ name = "LureStalk", size = { 0.08, 1.0, 0.08 }, pos = { 0, rootY + h[2] / 2 + 0.45, headZ - 0.1 }, rot = { -25, 0, 0 }, color = col("dark"), weld = "Head" })
		add({ name = "LureBulb", size = { 0.3, 0.3, 0.3 }, pos = { 0, rootY + h[2] / 2 + 0.95, headZ - 0.35 }, color = col("glow", "accent"), neon = true, weld = "Head" })
	end
	if p.patches then
		for _, side in { -1, 1 } do
			add({ name = name("Patch"), size = { 0.05, h[2] * 0.3, h[3] * 0.3 }, pos = { side * (h[1] / 2 + 0.025), rootY + h[2] * 0.2, headZ + h[3] * 0.25 }, color = col("accent"), weld = "Head" })
		end
	end
	if p.walrusTusks then
		for _, side in { -1, 1 } do
			add({ name = name("Tusk"), size = { 0.16, 1.0, 0.16 }, pos = { side * 0.3, rootY - h[2] / 2 - 0.3, headFront + 0.12 }, color = col("horn"), weld = "Head" })
		end
		add({ name = "Mustache", size = { h[1] * 0.6, 0.35, 0.3 }, pos = { 0, rootY - h[2] * 0.2, headFront - 0.12 }, color = col("accent"), weld = "Head" })
	end
	if p.dorsal then
		add({ name = "Dorsal", class = "WedgePart", size = { 0.2, b[2] * 0.55, b[3] * 0.35 }, pos = { 0, rootY + b[2] / 2 + b[2] * 0.275 - 0.05, b[3] * 0.05 }, color = fin, weld = "Torso" })
	end
	if p.bands then
		add({ name = "Band1", size = { b[1] + 0.1, b[2] + 0.1, 0.35 }, pos = { 0, rootY, 0.25 }, color = col("accent"), weld = "Torso" })
		add({ name = "Band2", size = { h[1] + 0.14, h[2] + 0.14, 0.3 }, pos = { 0, rootY, headZ + h[3] * 0.3 }, color = col("accent"), weld = "Head" })
	end
	if p.spots then
		for _, m in { { -0.25, 0.2 }, { 0.05, 0.3 }, { 0.3, 0.15 }, { -0.05, 0.05 } } do
			for _, side in { -1, 1 } do
				add({ name = name("Spot"), size = { 0.05, 0.25, 0.25 }, pos = { side * (b[1] / 2 + 0.025), rootY + m[2] * b[2], m[1] * b[3] }, color = col("dark"), weld = "Torso" })
			end
		end
	end
	if p.spikes then
		for _, s in { { 1, 0.4, 0.4 }, { 1, -0.4, -0.4 }, { 1, 0.35, -0.45 }, { 1, -0.35, 0.45 } } do
			for _, side in { -1, 1 } do
				add({ name = name("Spike"), size = { 0.45, 0.2, 0.2 }, pos = { side * (b[1] / 2 + 0.2), rootY + s[2], s[3] }, color = col("dark"), weld = "Torso" })
			end
		end
		for _, z in { -0.5, 0.5 } do
			for _, x in { -0.5, 0.5 } do
				add({ name = name("Spike"), size = { 0.2, 0.45, 0.2 }, pos = { x, rootY - b[2] / 2 - 0.2, z }, color = col("dark"), weld = "Torso" })
				add({ name = name("Spike"), size = { 0.2, 0.45, 0.2 }, pos = { x, rootY + b[2] / 2 + 0.2, z }, color = col("dark"), weld = "Torso" })
			end
		end
	end
	return parts, spec
end

---------------------------------------------------------------------------
-- Bipeds
---------------------------------------------------------------------------
function Kit.Biped(p, B)
	local spec = B.measure(p)
	local col = palette(p)
	local parts, add, name = rigBuilder()
	local b = p.body or { 1.6, 1.8, 1.4 }
	local legH, legW = p.legH or 0.8, p.legW or 0.6
	local legZ = p.legZ or 0
	local rootY = spec.rootY
	local top = rootY + b[2] / 2

	add({ name = "Torso", size = b, pos = { 0, rootY, 0 }, color = col("main"), studs = true, joint = { "RootPart", { 0, rootY, 0 } } })
	if p.belly or p.Name == "TRex" then
		add({ name = "Belly", size = { b[1] * 0.7, b[2] * 0.75, 0.05 }, pos = { 0, rootY - b[2] * 0.05, -b[3] / 2 - 0.025 }, color = col("accent"), weld = "Torso" })
	end

	local h = table.clone(p.head or { 1.4, 1.3, 1.3 })
	if math.abs(h[1] - b[1]) < 0.05 then
		h[1] += 0.2
	end
	local headY, headZ, pivot
	if p.headFront then
		headZ = -b[3] / 2 - h[3] / 2 + 0.5
		headY = top - 0.1 + (p.headUp or 0)
		pivot = { 0, headY - h[2] / 2 + 0.2, headZ + h[3] / 2 - 0.3 }
	else
		headZ = p.headZ or -0.1
		if math.abs(headZ + h[3] / 2 - b[3] / 2) < 0.03 or math.abs(headZ - h[3] / 2 + b[3] / 2) < 0.03 then
			headZ -= 0.06
		end
		headY = top + h[2] / 2 - 0.2
		pivot = { 0, top - 0.1, headZ }
	end
	if p.neckH then
		-- long neck (swan, ostrich): the head sits on a tall welded neck
		local nz = headZ + 0.1
		local ny0 = top - 0.2
		local nw = p.neckW or 0.5
		add({ name = "Neck", size = { nw, p.neckH + 0.4, nw }, pos = { 0, ny0 + (p.neckH + 0.4) / 2, nz }, color = col("neck", "main"), weld = "Torso" })
		headY += p.neckH
		pivot = { 0, pivot[2] + p.neckH, pivot[3] }
	end
	add({ name = "Head", size = h, pos = { 0, headY, headZ }, color = col("head"), studs = not p.comb, joint = { "Torso", pivot } })
	local hw, headFront, headTop, headBottom = h[1], headZ - h[3] / 2, headY + h[2] / 2, headY - h[2] / 2

	local beak = col("beak", "accent")
	if p.beak == "small" then
		add({ name = "Beak", size = { 0.45, 0.3, 0.35 }, pos = { 0, headY - 0.12, headFront - 0.15 }, color = beak, weld = "Head" })
	elseif p.beak == "bill" then
		add({ name = "Beak", size = { 0.8, 0.25, 0.6 }, pos = { 0, headY - 0.22, headFront - 0.28 }, color = beak, weld = "Head" })
		if p.colors.beakBase then
			add({ name = "BeakBase", size = { 0.84, 0.3, 0.14 }, pos = { 0, headY - 0.22, headFront - 0.04 }, color = p.colors.beakBase, weld = "Head" })
		end
	elseif p.beak == "puffin" then
		add({ name = "Beak", size = { 0.5, 0.65, 0.55 }, pos = { 0, headY - 0.12, headFront - 0.25 }, color = beak, weld = "Head" })
		add({ name = "BeakBand", size = { 0.54, 0.69, 0.12 }, pos = { 0, headY - 0.12, headFront - 0.1 }, color = col("band", "dark"), weld = "Head" })
	elseif p.beak == "needle" then
		add({ name = "Beak", size = { 0.2, 0.2, 1.4 }, pos = { 0, headY - 0.2, headFront - 0.65 }, rot = { 10, 0, 0 }, color = beak, weld = "Head" })
	end
	if p.earPatches then
		for _, side in { -1, 1 } do
			add({ name = name("EarPatch"), size = { 0.05, h[2] * 0.45, h[3] * 0.45 }, pos = { side * (h[1] / 2 + 0.025), headY - h[2] * 0.05, headZ + h[3] * 0.1 }, color = col("patch", "accent"), weld = "Head" })
		end
	end
	if p.cheekPads then
		for _, side in { -1, 1 } do
			add({ name = name("CheekPad"), size = { 0.3, h[2] * 0.85, h[3] * 0.35 }, pos = { side * (h[1] / 2 + 0.15), headY - 0.05, headFront + h[3] * 0.2 }, color = col("pad", "dark"), weld = "Head" })
		end
	end
	if p.muzzle then
		add({ name = "Muzzle", size = { hw * 0.5, h[2] * 0.4, 0.6 }, pos = { 0, headY - h[2] * 0.22, headFront - 0.28 }, color = col("snout", "accent"), weld = "Head" })
		add({ name = "Nose", size = { 0.3, 0.16, 0.06 }, pos = { 0, headY - h[2] * 0.08, headFront - 0.6 }, color = col("dark"), weld = "Head" })
	end
	if p.comb then
		add({ name = "Comb", size = { 0.25, 0.45, 0.7 }, pos = { 0, headTop + 0.2, headZ }, color = col("dark"), weld = "Head" })
		add({ name = "Wattle", size = { 0.22, 0.35, 0.2 }, pos = { 0, headY - 0.45, headFront - 0.12 }, color = col("dark"), weld = "Head" })
	end
	if p.face then
		add({ name = "Face", size = { hw * 0.7, h[2] * 0.7, 0.05 }, pos = { 0, headY - 0.1, headFront - 0.025 }, color = col("face", "accent"), weld = "Head" })
		add({ name = "Muzzle", size = { hw * 0.45, h[2] * 0.35, 0.35 }, pos = { 0, headY - h[2] * 0.23, headFront - 0.17 }, color = col("snout", "accent"), weld = "Head" })
		add({ name = "Nose", size = { 0.35, 0.15, 0.06 }, pos = { 0, headY - h[2] * 0.14, headFront - 0.37 }, color = col("dark"), weld = "Head" })
	end
	if p.jaw then
		local jw = { hw * 0.8, 0.35, h[3] * 0.8 }
		local jy = headBottom - 0.1
		add({ name = "Jaw", size = jw, pos = { 0, jy, headZ - h[3] * 0.12 }, color = col("accent"), joint = { "Head", { 0, jy + 0.15, headZ + h[3] * 0.3 } } })
		add({ name = "Tongue", size = { jw[1] * 0.5, 0.08, jw[3] * 0.6 }, pos = { 0, jy + 0.2, headZ - h[3] * 0.1 }, color = { 240, 110, 130 }, weld = "Jaw" })
	end
	if p.teeth then
		add({ name = "Teeth", size = { hw * 0.7, 0.12, 0.06 }, pos = { 0, headBottom + 0.07, headFront - 0.03 }, color = W, weld = "Head" })
		add({ name = "Nostrils", size = { 0.5, 0.12, 0.05 }, pos = { 0, headTop - 0.3, headFront - 0.025 }, color = col("dark"), weld = "Head" })
	end
	local eyeX = math.max(hw * 0.26, 0.45)
	local eyeY = headY + h[2] * 0.14
	if p.mask then
		for _, side in { -1, 1 } do
			add({ name = name("EyePatch"), size = { 0.6, 0.7, 0.03 }, pos = { side * eyeX, eyeY - 0.05, headFront - 0.025 }, color = col("mask", "dark"), weld = "Head" })
		end
	end
	frontEyes(add, "Head", eyeX, eyeY, headFront - (if p.face then 0.05 else 0), { 0.35, 0.45 }, p.colors.eye or K, W)
	if p.ears == "tall" then
		for _, side in { -1, 1 } do
			local nm = if side < 0 then "L" else "R"
			local es2 = p.earSize or 1.0
			local x, z = side * hw * 0.3, headZ + h[3] * 0.2
			add({ name = "Ear" .. nm, size = { 0.35, es2, 0.3 }, pos = { x, headTop + es2 / 2 - 0.1, z }, color = col("main"), joint = { "Head", { x, headTop - 0.1, z } } })
			add({ name = "InnerEar" .. nm, size = { 0.2, es2 * 0.7, 0.05 }, pos = { x, headTop + es2 / 2 - 0.1, z - 0.175 }, color = col("accent"), weld = "Ear" .. nm })
		end
	elseif p.ears == "sideRound" then
		for _, side in { -1, 1 } do
			local nm = if side < 0 then "L" else "R"
			local x = side * (hw / 2 + 0.12)
			add({ name = "Ear" .. nm, size = { 0.25, 0.6, 0.55 }, pos = { x, headY + 0.05, headZ }, color = col("main"), joint = { "Head", { side * hw / 2, headY + 0.05, headZ } } })
			add({ name = "InnerEar" .. nm, size = { 0.05, 0.35, 0.3 }, pos = { side * (hw / 2 + 0.27), headY + 0.05, headZ }, color = col("accent"), weld = "Ear" .. nm })
		end
	end

	-- arms
	local arm = p.arms or "long"
	for _, side in { -1, 1 } do
		local nm = if side < 0 then "L" else "R"
		local size, x, pz, py, rot
		if arm == "flippers" then
			size, pz, py = { 0.2, b[2] * 0.65, 0.6 }, 0, top - 0.2
		elseif arm == "wings" then
			size, pz, py = { 0.2, b[2] * 0.6, b[3] * 0.6 }, 0.1, rootY + b[2] * 0.35
		elseif arm == "tiny" then
			size, pz, py, rot = { 0.3, 0.7, 0.3 }, -b[3] / 2 + 0.4, rootY + b[2] * 0.1, { -30, 0, 0 }
		else
			size, pz, py = { p.armW or 0.45, p.armLen or 1.5, p.armW or 0.45 }, 0, top - 0.1
		end
		x = side * (b[1] / 2 + size[1] / 2 + 0.02)
		add({ name = "Arm" .. nm, size = size, pos = { x, py - size[2] / 2 + 0.1, pz }, rot = rot, color = col("arm", "main"), joint = { "Torso", { x, py, pz } } })
		if arm == "long" then
			add({ name = "Hand" .. nm, size = { size[1] + 0.05, 0.3, size[3] + 0.05 }, pos = { x, py - size[2] + 0.2, pz }, color = col("hand", "accent"), weld = "Arm" .. nm })
		elseif arm == "wings" then
			add({ name = name("WingTip"), size = { 0.22, size[2] * 0.35 + 0.02, size[3] + 0.02 }, pos = { x, py - size[2] + 0.1 + size[2] * 0.175, pz }, color = col("accent"), weld = "Arm" .. nm })
		end
	end

	-- legs + feet
	for _, side in { -1, 1 } do
		local nm = if side < 0 then "L" else "R"
		local x = side * spec.hipX
		add({ name = "Leg" .. nm, size = { legW, legH - 0.1, legW }, pos = { x, (0.3 + legH + 0.2) / 2, legZ }, color = col("leg", "main"), joint = { "Torso", { x, legH, legZ } } })
		add({ name = "Foot" .. nm, size = { legW + 0.15, 0.3, legW + 0.45 }, pos = { x, 0.15, legZ - 0.2 }, color = col("leg", "accent"), weld = "Leg" .. nm })
	end

	-- tail
	local t = p.tail
	if t == "short" then
		local base = { 0, rootY - b[2] * 0.35, b[3] / 2 - 0.1 }
		local c, r = seg(base, -20, 0.55)
		add({ name = "Tail1", size = { 0.6, 0.2, 0.55 }, pos = c, rot = r, color = col("main"), joint = { "Torso", base } })
	elseif t == "feathers" then
		local base = { 0, rootY + b[2] * 0.15, b[3] / 2 - 0.1 }
		local c, r = seg(base, 40, 0.7)
		add({ name = "Tail1", size = { b[1] * 0.6, 0.5, 0.7 }, pos = c, rot = r, color = col("main"), joint = { "Torso", base } })
	elseif t == "monkey" then
		tailChain(add, { 0, rootY - b[2] * 0.35, b[3] / 2 - 0.1 }, 20, 80, 0.25, { 1.2, 1.0 }, col("main"), nil, 0)
	elseif t == "rex" then
		local base = { 0, rootY + 0.1, b[3] / 2 - 0.2 }
		tailChain(add, base, p.tailPitch or -8, p.tail2Pitch or -12, p.tailW or 1.1, p.tailLen or { 1.6, 1.5 }, col("main"), nil, 0)
	elseif t == "thin" then
		tailChain(add, { 0, rootY - b[2] * 0.35, b[3] / 2 - 0.1 }, p.tailPitch or -40, p.tail2Pitch or -20, 0.2, p.tailLen or { 0.9, 0.8 }, col("main"), col("dark"), 0.26)
	elseif t == "fan" then
		local base = { 0, rootY + b[2] * 0.1, b[3] / 2 - 0.1 }
		local fw, fh = p.fanSize and p.fanSize[1] or 2.6, p.fanSize and p.fanSize[2] or 2.2
		add({ name = "Tail1", size = { fw, fh, 0.2 }, pos = { 0, base[2] + fh / 2 - 0.3, base[3] + 0.25 }, color = col("tail", "main"), joint = { "Torso", base } })
		if p.fanEyes then
			-- a fan of feathers radiating from the base (peacock)
			for i, ang in { -60, -30, 30, 60 } do
				local r = math.rad(ang)
				local len = fh * 0.95
				local cx, cy = -math.sin(r) * len / 2, math.cos(r) * len / 2
				add({ name = name("Feather"), size = { fw * 0.28, len, 0.18 }, pos = { cx * 1.1, base[2] - 0.3 + cy, base[3] + 0.3 + i * 0.012 }, rot = { 0, 0, ang }, color = col("tail", "main"), weld = "Tail1" })
				add({ name = name("FeatherEye"), size = { 0.4, 0.4, 0.04 }, pos = { -math.sin(r) * len * 0.85 * 1.1, base[2] - 0.3 + math.cos(r) * len * 0.85, base[3] + 0.18 + i * 0.012 }, color = col("accent"), weld = "Tail1" })
			end
		end
		local eyes = { { -0.36, 0.62 }, { -0.12, 0.8 }, { 0.12, 0.8 }, { 0.36, 0.62 }, { -0.24, 0.4 }, { 0, 0.55 }, { 0.24, 0.4 } }
		for _, e in (if p.fanEyes then eyes else {}) do
			local ex, ey = e[1] * fw, base[2] - 0.3 + e[2] * fh
			add({ name = name("FanEye"), size = { 0.42, 0.42, 0.04 }, pos = { ex, ey, base[3] + 0.13 }, color = col("accent"), weld = "Tail1" })
			add({ name = name("FanEyeDot"), size = { 0.2, 0.2, 0.04 }, pos = { ex, ey, base[3] + 0.09 }, color = col("eyeSpot", "dark"), weld = "Tail1" })
		end
	end
	if p.sail then
		add({ name = "Sail", size = { 0.2, 1.6, b[3] * 0.6 }, pos = { 0, top + 0.7, 0.25 }, color = col("accent"), weld = "Torso" })
	end
	if p.crest == "pins" then
		for i = -1, 1 do
			add({ name = name("CrestPin"), size = { 0.08, 0.6, 0.08 }, pos = { i * 0.18, headTop + 0.3, headZ + 0.1 }, rot = { 0, 0, -i * 12 }, color = col("dark"), weld = "Head" })
			add({ name = name("CrestTip"), size = { 0.18, 0.18, 0.18 }, pos = { i * 0.24, headTop + 0.62, headZ + 0.1 }, color = col("accent"), weld = "Head" })
		end
	elseif p.crest then
		add({ name = "Crest", size = { 0.3, 0.35, 1.7 }, pos = { 0, headTop + 0.25, headZ + 0.9 }, rot = { -30, 0, 0 }, color = col("accent"), weld = "Head" })
	end
	return parts, spec
end

-- Build any Animals.luau entry. plans = { Quadruped = Q, Flyer = F, Swimmer = S, Biped = B }
-- `entry.size` scales the whole rig uniformly. Animations are authored at size 1,
-- so the model carries AnimScale and every pose translation is multiplied by it.
function Kit.build(entry, plans)
	local parts, spec = Kit[entry.Plan](entry, plans[entry.Plan])
	local s = entry.size or 1
	local function mul(v)
		return { v[1] * s, v[2] * s, v[3] * s }
	end
	for _, part in parts do
		part.size = mul(part.size)
		part.pos = mul(part.pos)
		if part.joint then
			part.joint = { part.joint[1], mul(part.joint[2]) }
		end
	end
	return {
		Name = "Stud" .. entry.Name,
		PetType = entry.Name,
		RootHeight = spec.rootY * s,
		AnimScale = s,
		Parts = parts,
	}
end

return Kit
