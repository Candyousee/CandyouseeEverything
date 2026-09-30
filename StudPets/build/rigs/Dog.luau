-- Stud Dog rig: every block, its colour and how it attaches.
-- Units are studs; the model origin is the ground under the body, facing -Z.
-- joint = animated Motor6D (pivot in model space); weld = rigidly follows a part.

local C = {
	Fur = { 190, 122, 66 },
	Dark = { 112, 68, 40 },
	Cream = { 238, 218, 180 },
	Pink = { 240, 120, 140 },
	Black = { 27, 27, 32 },
	Red = { 205, 45, 45 },
	Gold = { 250, 200, 50 },
}

local function seg(base, pitch, len)
	local p = math.rad(pitch)
	local dy, dz = math.sin(p), math.cos(p)
	local center = { base[1], base[2] + dy * len / 2, base[3] + dz * len / 2 }
	local function along(d)
		return { base[1], base[2] + dy * d, base[3] + dz * d }
	end
	return center, { -pitch, 0, 0 }, along
end

local tail1Base = { 0, 2.85, 1.85 }
local tail1Pos, tail1Rot, tail1Along = seg(tail1Base, 50, 1.0)
local tail2Base = tail1Along(0.9)
local tail2Pos, tail2Rot, tail2Along = seg(tail2Base, 70, 0.8)

local parts = {
	{ name = "Torso", size = { 2, 1.6, 4 }, pos = { 0, 2.3, 0 }, color = C.Fur, studs = true, joint = { "RootPart", { 0, 2.3, 0 } } },
	{ name = "Chest", size = { 1.2, 0.65, 0.05 }, pos = { 0, 1.95, -2.025 }, color = C.Cream, weld = "Torso" },
	{ name = "Patch", size = { 0.05, 0.8, 1.2 }, pos = { -1.025, 2.45, 0.5 }, color = C.Dark, weld = "Torso" },
	{ name = "Collar", size = { 2.3, 0.35, 0.7 }, pos = { 0, 2.575, -1.8 }, color = C.Red, weld = "Torso" },
	{ name = "Tag", size = { 0.35, 0.35, 0.08 }, pos = { 0, 2.3, -2.19 }, color = C.Gold, weld = "Collar" },

	{ name = "Head", size = { 3, 1.8, 2 }, pos = { 0, 3.6, -2.3 }, color = C.Fur, studs = true, joint = { "Torso", { 0, 3.0, -1.7 } } },
	{ name = "Muzzle", size = { 1.6, 0.6, 0.8 }, pos = { 0, 3.3, -3.6 }, color = C.Cream, studs = true, weld = "Head" },
	{ name = "Nose", size = { 0.6, 0.35, 0.15 }, pos = { 0, 3.4, -4.075 }, color = C.Black, weld = "Head" },
	{ name = "Jaw", size = { 1.4, 0.3, 0.65 }, pos = { 0, 2.87, -3.625 }, color = C.Cream, joint = { "Head", { 0, 2.95, -3.3 } } },
	{ name = "Tongue", size = { 0.6, 0.08, 0.5 }, pos = { 0, 3.05, -3.6 }, color = C.Pink, weld = "Jaw" },
	{ name = "EyeL", size = { 0.4, 0.5, 0.1 }, pos = { -0.7, 3.95, -3.35 }, color = C.Black, joint = { "Head", { -0.7, 3.95, -3.35 } } },
	{ name = "EyeR", size = { 0.4, 0.5, 0.1 }, pos = { 0.7, 3.95, -3.35 }, color = C.Black, joint = { "Head", { 0.7, 3.95, -3.35 } } },
	{ name = "GlintL", size = { 0.15, 0.15, 0.04 }, pos = { -0.61, 4.07, -3.42 }, color = C.Cream, weld = "EyeL" },
	{ name = "GlintR", size = { 0.15, 0.15, 0.04 }, pos = { 0.79, 4.07, -3.42 }, color = C.Cream, weld = "EyeR" },
	{ name = "BrowL", size = { 0.35, 0.15, 0.04 }, pos = { -0.7, 4.33, -3.32 }, color = C.Cream, weld = "Head" },
	{ name = "BrowR", size = { 0.35, 0.15, 0.04 }, pos = { 0.7, 4.33, -3.32 }, color = C.Cream, weld = "Head" },
	{ name = "EarL", size = { 0.3, 1.4, 1.0 }, pos = { -1.65, 3.85, -2.2 }, color = C.Dark, joint = { "Head", { -1.65, 4.45, -2.2 } } },
	{ name = "EarR", size = { 0.3, 1.4, 1.0 }, pos = { 1.65, 3.85, -2.2 }, color = C.Dark, joint = { "Head", { 1.65, 4.45, -2.2 } } },

	{ name = "LegFL", size = { 0.8, 1.3, 0.8 }, pos = { -0.5, 1.05, -1.3 }, color = C.Fur, joint = { "Torso", { -0.5, 1.5, -1.3 } } },
	{ name = "LegFR", size = { 0.8, 1.3, 0.8 }, pos = { 0.5, 1.05, -1.3 }, color = C.Fur, joint = { "Torso", { 0.5, 1.5, -1.3 } } },
	{ name = "LegBL", size = { 0.8, 1.3, 0.8 }, pos = { -0.5, 1.05, 1.3 }, color = C.Fur, joint = { "Torso", { -0.5, 1.5, 1.3 } } },
	{ name = "LegBR", size = { 0.8, 1.3, 0.8 }, pos = { 0.5, 1.05, 1.3 }, color = C.Fur, joint = { "Torso", { 0.5, 1.5, 1.3 } } },
	{ name = "PawFL", size = { 0.8, 0.4, 0.8 }, pos = { -0.5, 0.2, -1.3 }, color = C.Cream, weld = "LegFL" },
	{ name = "PawFR", size = { 0.8, 0.4, 0.8 }, pos = { 0.5, 0.2, -1.3 }, color = C.Cream, weld = "LegFR" },
	{ name = "PawBL", size = { 0.8, 0.4, 0.8 }, pos = { -0.5, 0.2, 1.3 }, color = C.Cream, weld = "LegBL" },
	{ name = "PawBR", size = { 0.8, 0.4, 0.8 }, pos = { 0.5, 0.2, 1.3 }, color = C.Cream, weld = "LegBR" },

	{ name = "Tail1", size = { 0.36, 0.36, 1.0 }, pos = tail1Pos, rot = tail1Rot, color = C.Fur, joint = { "Torso", tail1Base } },
	{ name = "Tail2", size = { 0.34, 0.34, 0.8 }, pos = tail2Pos, rot = tail2Rot, color = C.Fur, joint = { "Tail1", tail2Base } },
	{ name = "TailTip", size = { 0.38, 0.38, 0.25 }, pos = tail2Along(0.68), rot = tail2Rot, color = C.Cream, weld = "Tail2" },
}

return {
	Name = "StudDog",
	PetType = "Dog",
	RootHeight = 2.3,
	Parts = parts,
}
