--!strict
-- Stud Dog: body measurements + the shared quadruped set + its trick (Bark).
-- Measurements must match build/rigs/Dog.luau.

return function(A, Q)
	local J, curve, wave = A.J, A.curve, A.wave

	local spec = {
		rootY = 2.3,
		halfLen = 2.0,
		halfH = 0.8,
		hipY = 1.5,
		hipZF = -1.3,
		hipZB = 1.3,
		legT = 0.8,
		ears = "floppy",
		walkPeriod = 0.8,
		walkSwing = 22,
		runPeriod = 0.46,
		runSwing = 38,
		tailWag = 22,
		idleWag = { 16, 0.8 },
		walkTail = { -10, -5 },
		runTail = { 30, 15 },
		sitPitch = 32,
		sitClear = 0.05,
		sitWag = 18,
		tailRest = { 50, 70 },
		sitTailDirs = { { -0.2, -0.75, 0.63 }, { -0.15, -0.35, 0.92 } }, -- thumping on the floor
		jumpHeight = 1.8,
		sleepHead = { -12, -0.45 },
		sleepTailDirs = { { -0.2, -0.95, 0.25 }, { -0.5, -0.35, 0.8 } },
	}

	local anims = Q.build(spec)

	-- Bark: two quick barks with a head thrust, open jaw, braced legs, fast wag.
	do
		local keys = {
			Head = { { 0, 0 }, { 0.15, -6 }, { 0.24, 14, "QuadOut" }, { 0.42, 1 }, { 0.62, -6 }, { 0.71, 14, "QuadOut" }, { 0.9, 1 }, { 1.3, 0 } },
			HeadZ = { { 0, 0 }, { 0.15, 0.05 }, { 0.24, -0.15, "QuadOut" }, { 0.42, 0 }, { 0.62, 0.05 }, { 0.71, -0.15, "QuadOut" }, { 0.9, 0 } },
			Jaw = { { 0, 0 }, { 0.18, 0 }, { 0.24, -32, "QuadOut" }, { 0.36, 0, "QuadIn" }, { 0.65, 0 }, { 0.71, -32, "QuadOut" }, { 0.83, 0, "QuadIn" } },
			Torso = { { 0, 0 }, { 0.15, -2 }, { 0.24, 4, "QuadOut" }, { 0.42, 0 }, { 0.62, -2 }, { 0.71, 4, "QuadOut" }, { 0.9, 0 } },
			Hop = { { 0, 0 }, { 0.2, 0 }, { 0.26, 0.08, "QuadOut" }, { 0.4, 0, "QuadIn" }, { 0.67, 0 }, { 0.73, 0.08, "QuadOut" }, { 0.87, 0, "QuadIn" } },
			Brace = { { 0, 0 }, { 0.12, -8 }, { 1.1, -8 }, { 1.3, 0 } },
			Ears = { { 0, 0 }, { 0.24, 22, "QuadOut" }, { 0.4, -8 }, { 0.55, 0 }, { 0.71, 22, "QuadOut" }, { 0.87, -8 }, { 1.0, 0 } },
			Wag = { { 0, 0 }, { 0.1, 1 }, { 1.1, 1 }, { 1.3, 0 } },
		}

		anims.Bark = {
			Name = "Bark",
			Length = 1.3,
			Looped = false,
			Pose = function(t)
				local P = {}
				P.Torso = J(curve(t, keys.Torso), 0, 0, 0, curve(t, keys.Hop), 0)
				P.Head = J(curve(t, keys.Head), 0, 0, 0, 0, curve(t, keys.HeadZ))
				P.Jaw = J(curve(t, keys.Jaw))
				local brace = curve(t, keys.Brace)
				P.LegFL = J(brace, 0, 0, 0, Q.legGroundLift(spec, brace))
				P.LegFR = J(brace, 0, 0, 0, Q.legGroundLift(spec, brace))
				local e = curve(t, keys.Ears)
				Q.ears(spec, P, e, 6 + math.max(0, e) * 0.4)
				Q.eyes(P, 0)
				local w = curve(t, keys.Wag)
				P.Tail1 = J(-8 * w, 28 * w * wave(t, 0.26), 0)
				P.Tail2 = J(0, 30 * w * wave(t, 0.26, 0.12), 0)
				return Q.plant(spec, P)
			end,
		}
	end

	return {
		Spec = spec,
		Anims = anims,
		Order = { "Idle", "Walk", "Run", "Sit", "Jump", "Sleep", "Bark" },
		Trick = "Bark",
	}
end
