-- Stud Cat rig: every block, its colour and how it attaches.
-- Units are studs; the model origin is the ground under the body, facing -Z.
-- joint = animated Motor6D (pivot in model space); weld = rigidly follows a part.

local C = {
	Orange = { 232, 142, 64 },
	Stripe = { 190, 94, 36 },
	White = { 246, 244, 238 },
	Pink = { 255, 158, 178 },
	Black = { 27, 27, 32 },
}

-- A tail segment starting at `base`, leaning back (+Z) and `pitch` degrees up.
local function seg(base, pitch, len)
	local p = math.rad(pitch)
	local dy, dz = math.sin(p), math.cos(p)
	local center = { base[1], base[2] + dy * len / 2, base[3] + dz * len / 2 }
	local function along(d)
		return { base[1], base[2] + dy * d, base[3] + dz * d }
	end
	return center, { -pitch, 0, 0 }, along
end

local tail1Base = { 0, 2.1, 1.35 }
local tail1Pos, tail1Rot, tail1Along = seg(tail1Base, 45, 1.2)
local tail2Base = tail1Along(1.1)
local tail2Pos, tail2Rot, tail2Along = seg(tail2Base, 75, 1.0)

local parts = {
	{ name = "Torso", size = { 2, 1.2, 3 }, pos = { 0, 1.8, 0 }, color = C.Orange, studs = true, joint = { "RootPart", { 0, 1.8, 0 } } },
	{ name = "Chest", size = { 1.2, 0.7, 0.05 }, pos = { 0, 1.65, -1.525 }, color = C.White, weld = "Torso" },

	{ name = "Head", size = { 3, 1.6, 2 }, pos = { 0, 2.9, -1.9 }, color = C.Orange, studs = true, joint = { "Torso", { 0, 2.3, -1.3 } } },
	{ name = "Muzzle", size = { 1.4, 0.6, 0.3 }, pos = { 0, 2.6, -3.0 }, color = C.White, studs = true, weld = "Head" },
	{ name = "Nose", size = { 0.5, 0.3, 0.1 }, pos = { 0, 2.74, -3.2 }, color = C.Pink, weld = "Head" },
	{ name = "EyeL", size = { 0.4, 0.5, 0.1 }, pos = { -0.75, 3.15, -2.95 }, color = C.Black, joint = { "Head", { -0.75, 3.15, -2.95 } } },
	{ name = "EyeR", size = { 0.4, 0.5, 0.1 }, pos = { 0.75, 3.15, -2.95 }, color = C.Black, joint = { "Head", { 0.75, 3.15, -2.95 } } },
	{ name = "GlintL", size = { 0.15, 0.15, 0.04 }, pos = { -0.66, 3.27, -3.02 }, color = C.White, weld = "EyeL" },
	{ name = "GlintR", size = { 0.15, 0.15, 0.04 }, pos = { 0.84, 3.27, -3.02 }, color = C.White, weld = "EyeR" },
	{ name = "BrowStripe1", size = { 0.2, 0.4, 0.05 }, pos = { -0.35, 3.47, -2.925 }, color = C.Stripe, weld = "Head" },
	{ name = "BrowStripe2", size = { 0.2, 0.4, 0.05 }, pos = { 0, 3.47, -2.925 }, color = C.Stripe, weld = "Head" },
	{ name = "BrowStripe3", size = { 0.2, 0.4, 0.05 }, pos = { 0.35, 3.47, -2.925 }, color = C.Stripe, weld = "Head" },
	{ name = "WhiskerL1", size = { 0.7, 0.06, 0.06 }, pos = { -0.95, 2.72, -3.05 }, rot = { 0, 0, -8 }, color = C.Black, weld = "Head" },
	{ name = "WhiskerL2", size = { 0.7, 0.06, 0.06 }, pos = { -0.95, 2.52, -3.05 }, rot = { 0, 0, 6 }, color = C.Black, weld = "Head" },
	{ name = "WhiskerR1", size = { 0.7, 0.06, 0.06 }, pos = { 0.95, 2.72, -3.05 }, rot = { 0, 0, 8 }, color = C.Black, weld = "Head" },
	{ name = "WhiskerR2", size = { 0.7, 0.06, 0.06 }, pos = { 0.95, 2.52, -3.05 }, rot = { 0, 0, -6 }, color = C.Black, weld = "Head" },
	-- ears: wedges turned sideways so the triangle faces forward
	{ name = "EarL", class = "WedgePart", size = { 0.3, 0.8, 0.8 }, pos = { -1.0, 4.1, -1.7 }, rot = { 0, -90, 0 }, color = C.Orange, joint = { "Head", { -1.0, 3.7, -1.7 } } },
	{ name = "EarR", class = "WedgePart", size = { 0.3, 0.8, 0.8 }, pos = { 1.0, 4.1, -1.7 }, rot = { 0, 90, 0 }, color = C.Orange, joint = { "Head", { 1.0, 3.7, -1.7 } } },
	{ name = "InnerEarL", class = "WedgePart", size = { 0.05, 0.5, 0.5 }, pos = { -1.05, 3.95, -1.875 }, rot = { 0, -90, 0 }, color = C.Pink, weld = "EarL" },
	{ name = "InnerEarR", class = "WedgePart", size = { 0.05, 0.5, 0.5 }, pos = { 1.05, 3.95, -1.875 }, rot = { 0, 90, 0 }, color = C.Pink, weld = "EarR" },

	{ name = "LegFL", size = { 0.8, 1.0, 0.8 }, pos = { -0.5, 0.9, -1.0 }, color = C.Orange, joint = { "Torso", { -0.5, 1.2, -1.0 } } },
	{ name = "LegFR", size = { 0.8, 1.0, 0.8 }, pos = { 0.5, 0.9, -1.0 }, color = C.Orange, joint = { "Torso", { 0.5, 1.2, -1.0 } } },
	{ name = "LegBL", size = { 0.8, 1.0, 0.8 }, pos = { -0.5, 0.9, 1.0 }, color = C.Orange, joint = { "Torso", { -0.5, 1.2, 1.0 } } },
	{ name = "LegBR", size = { 0.8, 1.0, 0.8 }, pos = { 0.5, 0.9, 1.0 }, color = C.Orange, joint = { "Torso", { 0.5, 1.2, 1.0 } } },
	{ name = "PawFL", size = { 0.8, 0.4, 0.8 }, pos = { -0.5, 0.2, -1.0 }, color = C.White, weld = "LegFL" },
	{ name = "PawFR", size = { 0.8, 0.4, 0.8 }, pos = { 0.5, 0.2, -1.0 }, color = C.White, weld = "LegFR" },
	{ name = "PawBL", size = { 0.8, 0.4, 0.8 }, pos = { -0.5, 0.2, 1.0 }, color = C.White, weld = "LegBL" },
	{ name = "PawBR", size = { 0.8, 0.4, 0.8 }, pos = { 0.5, 0.2, 1.0 }, color = C.White, weld = "LegBR" },

	{ name = "Tail1", size = { 0.4, 0.4, 1.2 }, pos = tail1Pos, rot = tail1Rot, color = C.Orange, joint = { "Torso", tail1Base } },
	{ name = "Tail2", size = { 0.38, 0.38, 1.0 }, pos = tail2Pos, rot = tail2Rot, color = C.Orange, joint = { "Tail1", tail2Base } },
	{ name = "TailTip", size = { 0.42, 0.42, 0.3 }, pos = tail2Along(0.86), rot = tail2Rot, color = C.White, weld = "Tail2" },
}

-- tabby stripes down both flanks
for i, z in { -0.6, 0.1, 0.8 } do
	local h = ({ 0.8, 0.7, 0.6 })[i]
	for _, side in { -1, 1 } do
		table.insert(parts, {
			name = "Stripe" .. (if side < 0 then "L" else "R") .. i,
			size = { 0.05, h, 0.3 },
			pos = { side * 1.025, 2.4 - h / 2, z },
			color = C.Stripe,
			weld = "Torso",
		})
	end
end

return {
	Name = "StudCat",
	PetType = "Cat",
	RootHeight = 1.8,
	Parts = parts,
}
