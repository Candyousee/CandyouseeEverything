--!strict
-- Body poses for the duel, as R15 joint rotations in degrees: { x, y, z [, px, py, pz] }.
-- Body-relative, so they work whichever way a fighter faces.
--
-- Conventions (from the Motor6D maths, checked in the preview):
--   Shoulder / Hip  x+  swings the limb forward and up;   Knee  x-  bends the knee
--   RightShoulder z+ / LeftShoulder z-  lift the arm out to the side
--   Elbow x+ bends the forearm forward / up;              Waist x- leans forward, x+ back
--   Waist / Neck y+ turns to the body's left;            Neck x- looks down, x+ up
--   Root py lowers (-) or raises (+) the hips (feet are re-planted on the ground afterwards)

local Poses = {}

Poses.Stand = {
	Root = { 0, 0, 0 },
	Waist = { 0, 0, 0 },
	Neck = { 0, 0, 0 },
	RightShoulder = { 4, 0, 7 },
	LeftShoulder = { 4, 0, -7 },
	RightElbow = { 10, 0, 0 },
	LeftElbow = { 10, 0, 0 },
	RightHip = { 0, 0, 2 },
	LeftHip = { 0, 0, -2 },
	RightKnee = { -3, 0, 0 },
	LeftKnee = { -3, 0, 0 },
}

-- iai stance: low, left foot forward, right hand on the hilt at the left hip, left hand on the sheath
Poses.Ready = {
	Root = { 0, 0, 0, 0, -0.55, 0 },
	Waist = { -16, -22, 0 },
	Neck = { 6, 20, 0 },
	RightShoulder = { 38, 10, -42 },
	RightElbow = { 72, 0, 0 },
	RightWrist = { 0, 0, 10 },
	LeftShoulder = { 18, 0, -8 },
	LeftElbow = { 46, 0, 0 },
	LeftHip = { 32, 0, -6 },
	LeftKnee = { -38, 0, 0 },
	LeftAnkle = { 6, 0, 0 },
	RightHip = { -22, 0, 8 },
	RightKnee = { -30, 0, 0 },
	RightAnkle = { 20, 0, 0 },
}

-- the blade comes out: right arm sweeps forward and up across the body
Poses.Draw = {
	Root = { 0, 0, 0, 0, -0.5, 0 },
	Waist = { -12, 10, 0 },
	Neck = { 4, -6, 0 },
	RightShoulder = { 78, 0, 18 },
	RightElbow = { 18, 0, 0 },
	RightWrist = { -10, 0, 0 },
	LeftShoulder = { 10, 0, -14 },
	LeftElbow = { 40, 0, 0 },
	LeftHip = { 32, 0, -6 },
	LeftKnee = { -36, 0, 0 },
	LeftAnkle = { 6, 0, 0 },
	RightHip = { -22, 0, 8 },
	RightKnee = { -30, 0, 0 },
	RightAnkle = { 20, 0, 0 },
}

-- guard (chudan): both hands on the hilt in front, blade angled up at the opponent
Poses.Guard = {
	Root = { 0, 0, 0, 0, -0.35, 0 },
	Waist = { -6, 12, 0 },
	Neck = { 2, -10, 0 },
	RightShoulder = { 58, 0, -22 },
	RightElbow = { 46, 0, 0 },
	RightWrist = { -78, 0, 0 },
	LeftShoulder = { 54, 0, 26 },
	LeftElbow = { 52, 0, 0 },
	LeftWrist = { -70, 0, 0 },
	LeftHip = { 24, 0, -8 },
	LeftKnee = { -26, 0, 0 },
	RightHip = { -18, 0, 8 },
	RightKnee = { -22, 0, 0 },
	RightAnkle = { 14, 0, 0 },
}

-- dash: leaning hard forward, blade trailing low behind, mid-stride
Poses.Dash = {
	Root = { 0, 0, 0, 0, -0.45, 0 },
	Waist = { -32, -8, 0 },
	Neck = { 22, 6, 0 },
	RightShoulder = { -48, 0, 24 },
	RightElbow = { 14, 0, 0 },
	RightWrist = { 50, 0, 0 },
	LeftShoulder = { 34, 0, -12 },
	LeftElbow = { 62, 0, 0 },
	LeftHip = { 58, 0, 0 },
	LeftKnee = { -78, 0, 0 },
	LeftAnkle = { 10, 0, 0 },
	RightHip = { -38, 0, 0 },
	RightKnee = { -46, 0, 0 },
	RightAnkle = { 26, 0, 0 },
}
Poses.Dash2 = { -- the other stride
	Root = { 0, 0, 0, 0, -0.4, 0 },
	Waist = { -30, 6, 0 },
	Neck = { 20, -4, 0 },
	RightShoulder = { -40, 0, 26 },
	RightElbow = { 16, 0, 0 },
	RightWrist = { 46, 0, 0 },
	LeftShoulder = { 46, 0, -14 },
	LeftElbow = { 56, 0, 0 },
	LeftHip = { -36, 0, 0 },
	LeftKnee = { -44, 0, 0 },
	LeftAnkle = { 24, 0, 0 },
	RightHip = { 56, 0, 0 },
	RightKnee = { -80, 0, 0 },
	RightAnkle = { 10, 0, 0 },
}

-- clash: both hands driving the blade forward into the opponent's
Poses.Clash = {
	Root = { 0, 0, 0, 0, -0.5, 0 },
	Waist = { -18, 18, 0 },
	Neck = { 10, -14, 0 },
	RightShoulder = { 84, 0, -26 },
	RightElbow = { 30, 0, 0 },
	RightWrist = { -84, 0, 0 },
	LeftShoulder = { 82, 0, 30 },
	LeftElbow = { 34, 0, 0 },
	LeftWrist = { -78, 0, 0 },
	LeftHip = { 40, 0, -8 },
	LeftKnee = { -44, 0, 0 },
	LeftAnkle = { 4, 0, 0 },
	RightHip = { -34, 0, 10 },
	RightKnee = { -16, 0, 0 },
	RightAnkle = { 30, 0, 0 },
}

-- block: blade held flat overhead to catch a downward cut
Poses.Block = {
	Root = { 0, 0, 0, 0, -0.7, 0 },
	Waist = { 4, 0, 0 },
	Neck = { 18, 0, 0 },
	RightShoulder = { 150, 0, -6 },
	RightElbow = { 30, 0, 0 },
	RightWrist = { 0, 0, -80 },
	LeftShoulder = { 150, 0, 14 },
	LeftElbow = { 36, 0, 0 },
	LeftHip = { 30, 0, -14 },
	LeftKnee = { -48, 0, 0 },
	RightHip = { -20, 0, 14 },
	RightKnee = { -40, 0, 0 },
	RightAnkle = { 16, 0, 0 },
}

-- overhead wind-up, then the cut follows through low
Poses.SlashWind = {
	Root = { 0, 0, 0, 0, -0.1, 0 },
	Waist = { 10, -12, 0 },
	Neck = { 6, 8, 0 },
	RightShoulder = { 168, 0, 12 },
	RightElbow = { 34, 0, 0 },
	RightWrist = { 30, 0, 0 },
	LeftShoulder = { 160, 0, -22 },
	LeftElbow = { 40, 0, 0 },
	LeftHip = { 46, 0, -6 },
	LeftKnee = { -70, 0, 0 },
	RightHip = { -10, 0, 4 },
	RightKnee = { -50, 0, 0 },
}
Poses.SlashFollow = {
	Root = { 0, 0, 0, 0, -0.6, 0 },
	Waist = { -34, 26, 0 },
	Neck = { 20, -18, 0 },
	RightShoulder = { 52, 0, -30 },
	RightElbow = { 8, 0, 0 },
	RightWrist = { -50, 0, 0 },
	LeftShoulder = { 46, 0, 30 },
	LeftElbow = { 14, 0, 0 },
	LeftHip = { 36, 0, -6 },
	LeftKnee = { -48, 0, 0 },
	RightHip = { -30, 0, 8 },
	RightKnee = { -34, 0, 0 },
	RightAnkle = { 22, 0, 0 },
}

-- charge: blade held upright in front of the face, wide low stance, power building
Poses.Charge = {
	Root = { 0, 0, 0, 0, -0.55, 0 },
	Waist = { 6, 0, 0 },
	Neck = { -4, 0, 0 },
	RightShoulder = { 72, 0, -18 },
	RightElbow = { 66, 0, 0 },
	RightWrist = { -48, 0, 0 },
	LeftShoulder = { 70, 0, 22 },
	LeftElbow = { 70, 0, 0 },
	LeftWrist = { -50, 0, 0 },
	LeftHip = { 8, 0, -22 },
	LeftKnee = { -30, 0, 0 },
	LeftAnkle = { 10, 0, 14 },
	RightHip = { 8, 0, 22 },
	RightKnee = { -30, 0, 0 },
	RightAnkle = { 10, 0, -14 },
}

-- iai: coiled low just before the flash cut
Poses.IaiReady = {
	Root = { 0, 0, 0, 0, -0.9, 0 },
	Waist = { -26, -30, 0 },
	Neck = { 22, 26, 0 },
	RightShoulder = { 30, 0, -50 },
	RightElbow = { 80, 0, 0 },
	RightWrist = { 0, 0, 30 },
	LeftShoulder = { 20, 0, -10 },
	LeftElbow = { 50, 0, 0 },
	LeftHip = { 50, 0, -8 },
	LeftKnee = { -80, 0, 0 },
	LeftAnkle = { 14, 0, 0 },
	RightHip = { -30, 0, 10 },
	RightKnee = { -58, 0, 0 },
	RightAnkle = { 30, 0, 0 },
}

-- after the cut: crouched low, blade swept out wide behind, head down
Poses.IaiFinish = {
	Root = { 0, 0, 0, 0, -1.05, 0 },
	Waist = { -30, 22, 0 },
	Neck = { -14, -10, 0 },
	RightShoulder = { 30, 0, 78 },
	RightElbow = { 6, 0, 0 },
	RightWrist = { 0, 0, -20 },
	LeftShoulder = { -6, 0, -36 },
	LeftElbow = { 20, 0, 0 },
	LeftHip = { 66, 0, -10 },
	LeftKnee = { -96, 0, 0 },
	LeftAnkle = { 22, 0, 0 },
	RightHip = { -44, 0, 12 },
	RightKnee = { -70, 0, 0 },
	RightAnkle = { 36, 0, 0 },
}

-- standing up, sliding the blade back into the sheath at the left hip
Poses.Sheathe = {
	Root = { 0, 0, 0, 0, -0.15, 0 },
	Waist = { -6, -16, 0 },
	Neck = { -8, 8, 0 },
	RightShoulder = { 46, 0, -48 },
	RightElbow = { 64, 0, 0 },
	RightWrist = { 0, 0, 14 },
	LeftShoulder = { 16, 0, -8 },
	LeftElbow = { 42, 0, 0 },
	LeftHip = { 6, 0, -4 },
	LeftKnee = { -8, 0, 0 },
	RightHip = { -4, 0, 4 },
	RightKnee = { -6, 0, 0 },
}

-- staggered (hit), then down on one knee
Poses.Hit = {
	Root = { 0, 0, 0, 0, -0.2, 0 },
	Waist = { 16, -10, 0 },
	Neck = { 24, 0, 0 },
	RightShoulder = { 30, 0, 36 },
	RightElbow = { 30, 0, 0 },
	LeftShoulder = { 26, 0, -40 },
	LeftElbow = { 26, 0, 0 },
	LeftHip = { 10, 0, -6 },
	LeftKnee = { -14, 0, 0 },
	RightHip = { -10, 0, 6 },
	RightKnee = { -10, 0, 0 },
}
Poses.Kneel = {
	Root = { 0, 0, 0, 0, -1.6, 0 },
	Waist = { -34, 0, 0 },
	Neck = { -30, 0, 0 },
	RightShoulder = { -6, 0, 16 },
	RightElbow = { 12, 0, 0 },
	LeftShoulder = { 18, 0, -12 },
	LeftElbow = { 30, 0, 0 },
	RightHip = { -4, 0, 6 },
	RightKnee = { -96, 0, 0 },
	RightAnkle = { -20, 0, 0 },
	LeftHip = { 86, 0, -4 },
	LeftKnee = { -92, 0, 0 },
	LeftAnkle = { 8, 0, 0 },
}

-- blend two poses joint by joint
function Poses.Blend(a: { [string]: { number } }, b: { [string]: { number } }, k: number): { [string]: { number } }
	local out = {}
	local keys = {}
	for name in a do
		keys[name] = true
	end
	for name in b do
		keys[name] = true
	end
	for name in keys do
		local x, y = a[name] or {}, b[name] or {}
		local e = {}
		for i = 1, 6 do
			local u, v = x[i] or 0, y[i] or 0
			e[i] = u + (v - u) * k
		end
		out[name] = e
	end
	return out
end

-- add small per-joint offsets (breathing, trembling)
function Poses.Add(p: { [string]: { number } }, name: string, dx: number, dy: number, dz: number, py: number?)
	local e = p[name] or { 0, 0, 0 }
	p[name] = { (e[1] or 0) + dx, (e[2] or 0) + dy, (e[3] or 0) + dz, e[4] or 0, (e[5] or 0) + (py or 0), e[6] or 0 }
end

return Poses
