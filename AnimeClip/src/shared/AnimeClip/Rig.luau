--!strict
-- R15 skeleton maths shared by the game and the preview.
--
-- A rig description lists the 15 Motor6D joints of an R15 character (same names as Roblox),
-- each with its parent part, child part, C0 and C1, plus every part's size. The game builds
-- one from the real avatar; the preview uses PROXY, a blocky R15 body with the same joints.
-- Forward kinematics works exactly like Roblox: part = parent * C0 * Transform * C1:Inverse().

local CF = require(script and script.Parent and script.Parent:FindFirstChild("CF") or "./CF")

local Rig = {}

-- joint order: every parent before its children
Rig.JOINTS = {
	{ name = "Root", part0 = "HumanoidRootPart", part1 = "LowerTorso" },
	{ name = "Waist", part0 = "LowerTorso", part1 = "UpperTorso" },
	{ name = "Neck", part0 = "UpperTorso", part1 = "Head" },
	{ name = "LeftShoulder", part0 = "UpperTorso", part1 = "LeftUpperArm" },
	{ name = "LeftElbow", part0 = "LeftUpperArm", part1 = "LeftLowerArm" },
	{ name = "LeftWrist", part0 = "LeftLowerArm", part1 = "LeftHand" },
	{ name = "RightShoulder", part0 = "UpperTorso", part1 = "RightUpperArm" },
	{ name = "RightElbow", part0 = "RightUpperArm", part1 = "RightLowerArm" },
	{ name = "RightWrist", part0 = "RightLowerArm", part1 = "RightHand" },
	{ name = "LeftHip", part0 = "LowerTorso", part1 = "LeftUpperLeg" },
	{ name = "LeftKnee", part0 = "LeftUpperLeg", part1 = "LeftLowerLeg" },
	{ name = "LeftAnkle", part0 = "LeftLowerLeg", part1 = "LeftFoot" },
	{ name = "RightHip", part0 = "LowerTorso", part1 = "RightUpperLeg" },
	{ name = "RightKnee", part0 = "RightUpperLeg", part1 = "RightLowerLeg" },
	{ name = "RightAnkle", part0 = "RightLowerLeg", part1 = "RightFoot" },
}

-- The proxy body: rest-pose part centres (relative to the HumanoidRootPart, feet at y = -3),
-- sizes, and joint pivots. All rest orientations are identity, as in a standard R15 rig.
local CENTERS = {
	HumanoidRootPart = { 0, 0, 0 },
	LowerTorso = { 0, -0.7, 0 },
	UpperTorso = { 0, 0.4, 0 },
	Head = { 0, 1.8, 0 },
	LeftUpperArm = { -1.5, 0.6, 0 },
	LeftLowerArm = { -1.5, -0.35, 0 },
	LeftHand = { -1.5, -0.9, 0 },
	RightUpperArm = { 1.5, 0.6, 0 },
	RightLowerArm = { 1.5, -0.35, 0 },
	RightHand = { 1.5, -0.9, 0 },
	LeftUpperLeg = { -0.5, -1.5, 0 },
	LeftLowerLeg = { -0.5, -2.4, 0 },
	LeftFoot = { -0.5, -2.9, -0.1 },
	RightUpperLeg = { 0.5, -1.5, 0 },
	RightLowerLeg = { 0.5, -2.4, 0 },
	RightFoot = { 0.5, -2.9, -0.1 },
}
local SIZES = {
	HumanoidRootPart = { 2, 2, 1 },
	LowerTorso = { 2, 0.6, 1 },
	UpperTorso = { 2, 1.6, 1 },
	Head = { 1.2, 1.2, 1.2 },
	LeftUpperArm = { 1, 1.2, 1 },
	LeftLowerArm = { 0.94, 0.7, 0.94 },
	LeftHand = { 0.9, 0.4, 0.9 },
	RightUpperArm = { 1, 1.2, 1 },
	RightLowerArm = { 0.94, 0.7, 0.94 },
	RightHand = { 0.9, 0.4, 0.9 },
	LeftUpperLeg = { 1, 1.0, 1 },
	LeftLowerLeg = { 0.94, 0.8, 0.94 },
	LeftFoot = { 1, 0.2, 1.2 },
	RightUpperLeg = { 1, 1.0, 1 },
	RightLowerLeg = { 0.94, 0.8, 0.94 },
	RightFoot = { 1, 0.2, 1.2 },
}
local PIVOTS = {
	Root = { 0, -0.7, 0 },
	Waist = { 0, -0.4, 0 },
	Neck = { 0, 1.2, 0 },
	LeftShoulder = { -1.5, 1.0, 0 },
	LeftElbow = { -1.5, 0, 0 },
	LeftWrist = { -1.5, -0.7, 0 },
	RightShoulder = { 1.5, 1.0, 0 },
	RightElbow = { 1.5, 0, 0 },
	RightWrist = { 1.5, -0.7, 0 },
	LeftHip = { -0.5, -1.0, 0 },
	LeftKnee = { -0.5, -2.0, 0 },
	LeftAnkle = { -0.5, -2.8, 0 },
	RightHip = { 0.5, -1.0, 0 },
	RightKnee = { 0.5, -2.0, 0 },
	RightAnkle = { 0.5, -2.8, 0 },
}

export type Joint = { name: string, part0: string, part1: string, c0: { number }, c1inv: { number } }
export type Desc = { joints: { Joint }, sizes: { [string]: { number } } }

local function makeProxy(): Desc
	local joints = {}
	for _, j in Rig.JOINTS do
		local p = PIVOTS[j.name]
		local a, b = CENTERS[j.part0], CENTERS[j.part1]
		table.insert(joints, {
			name = j.name,
			part0 = j.part0,
			part1 = j.part1,
			c0 = CF.new(p[1] - a[1], p[2] - a[2], p[3] - a[3]),
			c1inv = CF.inv(CF.new(p[1] - b[1], p[2] - b[2], p[3] - b[3])),
		})
	end
	return { joints = joints, sizes = SIZES }
end
Rig.PROXY = makeProxy()

-- Build a description from real C0 / C1 component arrays (the game does this per avatar).
function Rig.Describe(list: { { name: string, part0: string, part1: string, c0: { number }, c1: { number } } }, sizes: { [string]: { number } }): Desc
	local joints = {}
	for _, j in list do
		table.insert(joints, { name = j.name, part0 = j.part0, part1 = j.part1, c0 = j.c0, c1inv = CF.inv(j.c1) })
	end
	-- parents first
	table.sort(joints, function(a, b)
		local ia, ib = 99, 99
		for i, r in Rig.JOINTS do
			if r.name == a.name then
				ia = i
			end
			if r.name == b.name then
				ib = i
			end
		end
		return ia < ib
	end)
	return { joints = joints, sizes = sizes }
end

-- the Motor6D Transform for a pose entry { x, y, z (degrees), px, py, pz (studs, optional) }
function Rig.Transform(e: { number }?): { number }
	if not e then
		return CF.new()
	end
	local t = CF.deg(e[1] or 0, e[2] or 0, e[3] or 0)
	t[1], t[2], t[3] = e[4] or 0, e[5] or 0, e[6] or 0
	return t
end

-- forward kinematics: world CF of every part
function Rig.FK(desc: Desc, root: { number }, pose: { [string]: { number } }): { [string]: { number } }
	local world = { HumanoidRootPart = root }
	for _, j in desc.joints do
		local parent = world[j.part0]
		if parent then
			world[j.part1] = CF.mul(CF.mul(CF.mul(parent, j.c0), Rig.Transform(pose[j.name])), j.c1inv)
		end
	end
	return world
end

-- lowest point of the feet (and lower legs) in world space
function Rig.Lowest(desc: Desc, world: { [string]: { number } }): number
	local low = math.huge
	for _, name in { "LeftFoot", "RightFoot", "LeftLowerLeg", "RightLowerLeg" } do
		local c, s = world[name], desc.sizes[name]
		if c and s then
			for _, sx in { -0.5, 0.5 } do
				for _, sy in { -0.5, 0.5 } do
					for _, sz in { -0.5, 0.5 } do
						local p = CF.point(c, s[1] * sx, s[2] * sy, s[3] * sz)
						low = math.min(low, p[2])
					end
				end
			end
		end
	end
	return low
end

-- the rest-pose height of the root above the floor (how tall the legs are)
function Rig.StandHeight(desc: Desc): number
	local world = Rig.FK(desc, CF.new(), {})
	return -Rig.Lowest(desc, world)
end

return Rig
