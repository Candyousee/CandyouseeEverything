--!strict
-- Stud Cat: body measurements + the shared quadruped set + its trick (Stretch).
-- Measurements must match build/rigs/Cat.luau.

return function(A, Q)
	local J, curve = A.J, A.curve

	local spec = {
		rootY = 1.8, -- torso centre above the ground
		halfLen = 1.5,
		halfH = 0.6,
		hipY = 1.2, -- leg pivot height = leg length to the paw bottom
		hipZF = -1.0,
		hipZB = 1.0,
		legT = 0.8,
		ears = "perky",
		walkPeriod = 0.7,
		walkSwing = 22,
		runPeriod = 0.42,
		runSwing = 40,
		tailWag = 10,
		idleWag = { 9, 4 },
		walkTail = { -12, 6 },
		runTail = { 35, 25 },
		sitPitch = 35,
		sitClear = 0.05,
		sitWag = 0,
		tailRest = { 45, 75 }, -- rig tail pitches (degrees up from pointing straight back)
		sitTailDirs = { { -0.5, -0.3, 0.8 }, { -0.55, 0, -0.83 } }, -- curl round the left hip
		jumpHeight = 2.2,
		sleepHead = { -12, -0.35 },
		sleepTailDirs = { { -0.55, -0.45, 0.7 }, { -0.4, -0.3, -0.87 } },
	}

	local anims = Q.build(spec)

	-- Stretch: front paws slide out, chest down, rear up, then one back leg stretches.
	do
		local phi = -20
		local c, s = math.cos(math.rad(phi)), math.sin(math.rad(phi))
		local hipRel = spec.hipY - spec.rootY
		local py = spec.hipY - (spec.rootY + hipRel * c - spec.hipZB * s)
		local frontHip = spec.rootY + py + hipRel * c - spec.hipZF * s
		local front = Q.solveLegAngle(spec, frontHip) - phi
		local back = -phi

		local keys = {
			Torso = {
				{ 0, J() },
				{ 0.6, J(phi, 0, 0, 0, py, 0.2) },
				{ 1.35, J(phi + 1, 0, 0, 0, py - 0.02, 0.22) },
				{ 1.75, J(3, 0, 0, 0, 0.05, 0) },
				{ 2.05, J(4, 0, -2, 0, 0.06, -0.05) },
				{ 2.35, J(0, 0, 0, 0, 0, 0) },
				{ 2.6, J() },
			},
			Front = { { 0, 0 }, { 0.6, front }, { 1.35, front - 1 }, { 1.75, 0 }, { 2.6, 0 } },
			Back = { { 0, 0 }, { 0.6, back }, { 1.35, back + 1 }, { 1.75, 0 }, { 2.6, 0 } },
			BackL = { { 0, 0 }, { 0.6, back }, { 1.35, back + 1 }, { 1.75, 0 }, { 2.05, -42, "QuadOut" }, { 2.35, 0 }, { 2.6, 0 } },
			Head = { { 0, 0 }, { 0.6, 26 }, { 1.0, 30 }, { 1.35, 28 }, { 1.75, -4 }, { 2.05, 4 }, { 2.6, 0 } },
			Tail = { { 0, 0 }, { 0.6, -32 }, { 1.35, -36 }, { 1.75, 0 }, { 2.05, -10 }, { 2.6, 0 } },
			Ears = { { 0, 0 }, { 0.6, 20 }, { 1.35, 22 }, { 1.75, 0 }, { 2.6, 0 } },
			Eyes = { { 0, 0 }, { 0.7, 0 }, { 0.8, 1 }, { 1.25, 1 }, { 1.35, 0 } },
		}

		anims.Stretch = {
			Name = "Stretch",
			Length = 2.6,
			Looped = false,
			Pose = function(t)
				local P = {}
				local tremble = if t > 0.6 and t < 1.35 then 0.6 * math.sin(t * 40) else 0
				P.Torso = A.add(curve(t, keys.Torso), J(tremble))
				local f, b, bl = curve(t, keys.Front), curve(t, keys.Back), curve(t, keys.BackL)
				P.LegFL = J(f)
				P.LegFR = J(f)
				P.LegBR = J(b, 0, 0, 0, Q.legGroundLift(spec, b))
				local raise = if bl < 0 then -bl / 42 * 0.35 else 0
				P.LegBL = J(bl, 0, 0, 0, Q.legGroundLift(spec, bl) + raise)
				P.Head = J(curve(t, keys.Head))
				local tl = curve(t, keys.Tail)
				P.Tail1 = J(tl, 0, 0)
				P.Tail2 = J(tl * 0.5, 0, 0)
				Q.ears(spec, P, curve(t, keys.Ears), 0)
				Q.eyes(P, curve(t, keys.Eyes))
				return Q.plant(spec, P)
			end,
		}
	end

	return {
		Spec = spec,
		Anims = anims,
		Order = { "Idle", "Walk", "Run", "Sit", "Jump", "Sleep", "Stretch" },
		Trick = "Stretch",
	}
end
