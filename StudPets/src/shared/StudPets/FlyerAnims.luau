--!strict
-- Flyer animation set (birds, bats, bees, butterflies, dragons).
-- Joints: Torso, Head, WingL, WingR, Tail1, Tail2, LegL, LegR, EyeL, EyeR, Jaw.
-- Wings are built spread sideways; +rz on the right wing / -rz on the left lifts them,
-- and ry of +-90 folds them back along the body. Perching birds stand on two legs;
-- `alwaysFly` pets (insects, bats) hover all the time.

return function(A, Q)
	local J, wave, curve = A.J, A.wave, A.curve

	local F = {}

	function F.measure(p)
		local b = p.body or { 1.4, 1.4, 1.8 }
		local legH = if p.alwaysFly then 0 else (p.legH or 0.6)
		local flap = p.flapPeriod or 0.4 -- must divide 4 s for seamless loops
		local hover = p.hover or 1.0 -- flight height: close to the owner
		local spec = {
			rootY = legH + b[2] / 2 + (if p.alwaysFly then hover else 0),
			hover = hover,
			alwaysFly = p.alwaysFly == true,
			noPlant = p.alwaysFly == true,
			flap = flap,
			flapAmp = p.flapAmp or 45,
			hipY = legH,
			hipX = p.legX or 0.35,
			legT = 0.3,
			legTop = 0.15,
			legList = { { "LegL", -1, 0 }, { "LegR", 1, 0 } },
			ears = "perky",
		}
		for key, v in p.anim or {} do
			spec[key] = v
		end
		return spec
	end

	-- lift > 0 raises the wings; fold 1 = tucked back along the body
	-- folded wings hang down each side and point back (plates vertical, not a flat tray)
	local function wings(P, lift: number, fold: number)
		local open = 1 - fold
		P.WingL = J(-90 * fold, 0, 90 * fold - lift * open)
		P.WingR = J(-90 * fold, 0, -90 * fold + lift * open)
	end

	-- Airborne pose: `speed` 0 = hover, 1 = fast forward flight.
	local function fly(spec, P, t: number, speed: number, flapPeriod: number, height: number)
		local lift = if spec.alwaysFly then 0 else spec.hover
		local beat = wave(t, flapPeriod)
		P.Torso = J(-6 - 12 * speed + 3 * beat, 0, 0, 0, lift + height + 0.12 * wave(t, flapPeriod, 0.25), 0)
		wings(P, spec.flapAmp * beat + 10, 0)
		P.Head = J(4 + 10 * speed - 2 * beat)
		P.LegL = J(-55)
		P.LegR = J(-55)
		P.Tail1 = J(4 * wave(t, flapPeriod, 0.3))
		P.Tail2 = J(6 * wave(t, flapPeriod, 0.5))
	end

	local function eyes(P, closed: number)
		Q.eyes(P, closed)
	end

	function F.Idle(spec)
		return {
			Name = "Idle",
			Length = 4,
			Looped = true,
			Pose = function(t)
				local P = {}
				local look = curve(t, { { 0, 0 }, { 0.8, 0 }, { 1.1, 35 }, { 1.9, 35 }, { 2.2, -25 }, { 3.2, -25 }, { 3.6, 0 } })
				if spec.alwaysFly then
					fly(spec, P, t, 0, spec.flap, 0)
					P.Torso[2] = 8 * wave(t, 4)
				else
					local br = wave(t, 2)
					P.Torso = J(br, 0, 0, 0, 0.03 * br)
					wings(P, 2 * br, 1)
					P.Tail1 = J(curve(t, { { 0, 0 }, { 2.4, 0 }, { 2.5, -15 }, { 2.7, 0 } }))
				end
				-- birds jerk their heads round in quick steps
				P.Head = J(curve(t, { { 0, 0 }, { 2.9, 0 }, { 3.0, -12 }, { 3.2, 0 } }), look, look * 0.2)
				eyes(P, Q.blink(t, { 0.5, 2.8 }))
				return Q.plant(spec, P)
			end,
		}
	end

	function F.Walk(spec)
		local T = spec.flap * math.max(1, math.round(0.8 / spec.flap))
		return {
			Name = "Walk",
			Length = T,
			Looped = true,
			Pose = function(t)
				local P = {}
				fly(spec, P, t, 0.5, spec.flap, 0)
				eyes(P, 0)
				return P
			end,
		}
	end

	function F.Run(spec)
		local f = spec.flap * 0.75
		return {
			Name = "Run",
			Length = f * 2,
			Looped = true,
			Pose = function(t)
				local P = {}
				fly(spec, P, t, 1, f, 0.3)
				wings(P, (spec.flapAmp + 10) * wave(t, f) + 5, 0)
				eyes(P, 0)
				return P
			end,
		}
	end

	function F.Sit(spec)
		return {
			Name = "Sit",
			Length = 4,
			Looped = true,
			Pose = function(t)
				local P = {}
				if spec.alwaysFly then
					fly(spec, P, t, 0, spec.flap * 2, -spec.hover * 0.5)
					wings(P, spec.flapAmp * 0.5 * wave(t, spec.flap * 2) + 10, 0)
				else
					-- fluffed up and settled low on its feet
					local br = wave(t, 2)
					P.Torso = J(4, 0, 0, 0, -0.25 + 0.03 * br)
					P.LegL = J(0, 0, 0, 0, 0.25)
					P.LegR = J(0, 0, 0, 0, 0.25)
					wings(P, 0, 1)
					P.Head = J(-6 + br, curve(t, { { 0, 0 }, { 1.5, 0 }, { 1.8, 20 }, { 3, 20 }, { 3.3, 0 } }))
				end
				eyes(P, Q.blink(t, { 1.2, 3.5 }))
				return Q.plant(spec, P)
			end,
		}
	end

	function F.Jump(spec)
		local k = {
			Up = { { 0, 0 }, { 0.18, -0.2 }, { 0.5, 1.8, "QuadOut" }, { 0.9, 1.4 }, { 1.25, 0, "QuadIn" }, { 1.35, -0.12 }, { 1.5, 0 } },
			Open = { { 0, 0 }, { 0.15, 0 }, { 0.3, 1 }, { 1.15, 1 }, { 1.35, 0 } },
		}
		return {
			Name = "Jump",
			Length = 1.5,
			Looped = false,
			Pose = function(t)
				local P = {}
				local open = curve(t, k.Open)
				local h = curve(t, k.Up)
				if spec.alwaysFly then
					fly(spec, P, t, 0.2, spec.flap * 0.5, h)
				else
					P.Torso = J(-10 * open, 0, 0, 0, h)
					wings(P, open * (spec.flapAmp * wave(t, 0.3) + 10), 1 - open)
					P.LegL = J(-40 * open)
					P.LegR = J(-40 * open)
					P.Head = J(10 * open)
					P.Tail1 = J(-10 * open)
				end
				eyes(P, 0)
				return Q.plant(spec, P)
			end,
		}
	end

	function F.Sleep(spec)
		return {
			Name = "Sleep",
			Length = 4,
			Looped = true,
			Pose = function(t)
				local P = {}
				local br = wave(t, 4)
				if spec.alwaysFly then
					fly(spec, P, t, 0, spec.flap * 2, -spec.hover * 0.6 + 0.1 * br)
					wings(P, spec.flapAmp * 0.35 * wave(t, spec.flap * 2) + 5, 0)
					P.Head = J(-15)
				else
					P.Torso = J(6, 0, 0, 0, -0.3 + 0.04 * br)
					P.LegL = J(0, 0, 0, 0, 0.3)
					P.LegR = J(0, 0, 0, 0, 0.3)
					wings(P, 0, 1)
					P.Head = J(-(spec.sleepHeadDrop or 25) - 2 * br, 25, 8)
				end
				eyes(P, 1)
				return Q.plant(spec, P)
			end,
		}
	end

	-- Loop: take off (if perched), barrel roll, settle back.
	function F.Loop(spec)
		local k = {
			Up = { { 0, 0 }, { 0.3, 1.5, "QuadOut" }, { 1.3, 1.5 }, { 1.7, 0, "QuadIn" }, { 2, 0 } },
			Roll = { { 0, 0 }, { 0.35, 0 }, { 1.25, 360, "Cubic" }, { 2, 360 } },
			Open = { { 0, 0 }, { 0.15, 1 }, { 1.6, 1 }, { 1.85, 0 } },
		}
		return {
			Name = "Loop",
			Length = 2,
			Looped = false,
			Pose = function(t)
				local P = {}
				local open = if spec.alwaysFly then 1 else curve(t, k.Open)
				local roll = curve(t, k.Roll)
				fly(spec, P, t, 0.3, spec.flap * 0.75, curve(t, k.Up) - (if spec.alwaysFly then 0 else spec.hover * (1 - open)))
				P.Torso[3] = if roll >= 360 then 0 else roll
				P.LegL = J(-55 * open)
				P.LegR = J(-55 * open)
				if not spec.alwaysFly then
					wings(P, open * (spec.flapAmp * wave(t, spec.flap * 0.75) + 10), 1 - open)
				end
				eyes(P, if roll > 90 and roll < 300 then 1 else 0)
				return Q.plant(spec, P)
			end,
		}
	end

	function F.fromParams(p)
		local spec = F.measure(p)
		local trick = p.trick or "Loop"
		local anims = {
			Idle = F.Idle(spec),
			Walk = F.Walk(spec),
			Run = F.Run(spec),
			Sit = F.Sit(spec),
			Jump = F.Jump(spec),
			Sleep = F.Sleep(spec),
		}
		anims[trick] = F[trick](spec)
		return { Spec = spec, Anims = anims, Order = { "Idle", "Walk", "Run", "Sit", "Jump", "Sleep", trick }, Trick = trick }
	end

	return F
end
