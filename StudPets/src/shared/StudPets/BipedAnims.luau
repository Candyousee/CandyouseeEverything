--!strict
-- Two-legged animation set (penguin, chicken, duck, monkey, T-rex).
-- Joints: Torso, Head, ArmL, ArmR, LegL, LegR, Tail1, Tail2, EyeL, EyeR, Jaw.
-- Arms hang from the shoulders: +rx swings them forward/up, -rz/+rz (left/right)
-- lifts them out sideways (flapping).

return function(A, Q)
	local J, wave, curve = A.J, A.wave, A.curve

	local B = {}

	function B.measure(p)
		local b = p.body or { 1.6, 1.8, 1.4 }
		local legH, legW = p.legH or 0.8, p.legW or 0.6
		local legZ = p.legZ or 0
		local footW = legW + 0.15
		local spec = {
			rootY = legH + b[2] / 2,
			hipY = legH,
			hipX = p.legX or math.max(b[1] / 2 - legW / 2 - 0.1, footW / 2 + 0.06),
			legT = legW + 0.6, -- the feet stick out, so plant against a longer block
			sitTail = 30,
			legW = legW,
			legList = { { "LegL", -1, legZ }, { "LegR", 1, legZ } },
			halfH = b[2] / 2,
			ears = "perky",
			walkPeriod = 0.45 + 0.25 * legH,
			waddle = p.waddle or 6,
			wings = p.arms == "wings",
		}
		for key, v in p.anim or {} do
			spec[key] = v
		end
		return spec
	end

	local function arms(P, fwdL: number, fwdR: number, out: number)
		P.ArmL = J(fwdL, 0, -out)
		P.ArmR = J(fwdR, 0, out)
	end

	function B.Idle(spec)
		return {
			Name = "Idle",
			Length = 4,
			Looped = true,
			Pose = function(t)
				local P = {}
				local br = wave(t, 2)
				local look = curve(t, { { 0, 0 }, { 0.9, 0 }, { 1.3, 22 }, { 2.1, 22 }, { 2.5, -15 }, { 3.3, -15 }, { 3.7, 0 } })
				P.Torso = J(br, 0, 0, 0, 0.03 * br)
				P.Head = J(-br, look, look * 0.15)
				arms(P, 3 * br, 3 * br, 4 + 2 * br)
				P.Tail1 = J(0, 8 * wave(t, 4))
				P.Tail2 = J(0, 10 * wave(t, 4, 0.1))
				Q.eyes(P, Q.blink(t, { 0.7, 3.0 }))
				return Q.plant(spec, P)
			end,
		}
	end

	local function gait(spec, P, t: number, T: number, swing: number, lean: number, rollLift: number)
		for _, leg in { { "LegL", 0 }, { "LegR", 0.5 } } do
			local a = swing * wave(t, T, leg[2])
			local fwd = math.max(0, wave(t, T, leg[2] - 0.25))
			P[leg[1]] = J(a, 0, 0, 0, Q.legGroundLift(spec, a) + 0.12 * fwd + rollLift * math.abs(math.sin(math.rad(spec.waddle))) * spec.hipX)
		end
		P.Torso = J(lean, 3 * wave(t, T, 0.25), spec.waddle * wave(t, T), 0, 0.05 * wave(t, T / 2, 0.25))
		P.Head = J(-lean * 0.6, -3 * wave(t, T, 0.25), -spec.waddle * 0.7 * wave(t, T))
		P.Tail1 = J(0, 10 * wave(t, T, 0.1))
		P.Tail2 = J(0, 14 * wave(t, T, 0.2))
	end

	function B.Walk(spec)
		local T = spec.walkPeriod
		return {
			Name = "Walk",
			Length = T,
			Looped = true,
			Pose = function(t)
				local P = {}
				gait(spec, P, t, T, 24, 0, 0)
				local s = wave(t, T)
				arms(P, -18 * s, 18 * s, if spec.wings then 14 else 6)
				Q.eyes(P, 0)
				return Q.plant(spec, P)
			end,
		}
	end

	function B.Run(spec)
		local T = spec.walkPeriod * 0.6
		return {
			Name = "Run",
			Length = T,
			Looped = true,
			Pose = function(t)
				local P = {}
				gait(spec, P, t, T, 38, -12, 1)
				local s = wave(t, T)
				if spec.wings then
					arms(P, 0, 0, 55 + 35 * wave(t, T / 2))
				else
					arms(P, -35 * s, 35 * s, 8)
				end
				Q.eyes(P, 0)
				return Q.plant(spec, P)
			end,
		}
	end

	function B.Sit(spec)
		-- legs stuck out forward (~78 deg in the world): lower the hips until the feet touch
		local drop = -spec.hipY * (1 - math.cos(math.rad(78))) + spec.legW * 0.5 * math.sin(math.rad(78))
		return {
			Name = "Sit",
			Length = 4,
			Looped = true,
			Pose = function(t)
				local P = {}
				local br = wave(t, 2)
				P.Torso = J(-6 + br, 0, 0, 0, drop + 0.03 * br)
				P.LegL = J(84)
				P.LegR = J(84)
				arms(P, 20, 20, 6)
				P.Head = J(4 - br, curve(t, { { 0, 0 }, { 1.4, 0 }, { 1.8, 18 }, { 2.8, 18 }, { 3.2, 0 } }))
				P.Tail1 = J(spec.sitTail)
				Q.eyes(P, Q.blink(t, { 1.0, 3.4 }))
				return P
			end,
		}
	end

	function B.Jump(spec)
		local k = {
			Up = { { 0, 0 }, { 0.2, -0.15 }, { 0.55, 1.7, "QuadOut" }, { 0.95, 0, "QuadIn" }, { 1.05, -0.15 }, { 1.25, 0 } },
			Arms = { { 0, 0 }, { 0.2, -30 }, { 0.5, 150, "QuadOut" }, { 0.9, 60 }, { 1.1, 0 } },
			Legs = { { 0, 0 }, { 0.2, 12 }, { 0.5, -20 }, { 0.8, 18 }, { 0.95, 0 } },
		}
		return {
			Name = "Jump",
			Length = 1.25,
			Looped = false,
			Pose = function(t)
				local P = {}
				P.Torso = J(0, 0, 0, 0, curve(t, k.Up))
				local a = curve(t, k.Arms)
				if spec.wings then
					arms(P, 0, 0, math.max(0, a) * 0.5 + 25 * math.sin(t * 25) * math.clamp(a / 60, 0, 1))
				else
					arms(P, a, a, 15)
				end
				local l = curve(t, k.Legs)
				P.LegL = J(l)
				P.LegR = J(l)
				P.Head = J(-a * 0.05)
				P.Tail1 = J(a * 0.1)
				Q.eyes(P, 0)
				return Q.plant(spec, P)
			end,
		}
	end

	function B.Sleep(spec)
		-- legs stuck out forward (~78 deg in the world): lower the hips until the feet touch
		local drop = -spec.hipY * (1 - math.cos(math.rad(78))) + spec.legW * 0.5 * math.sin(math.rad(78))
		return {
			Name = "Sleep",
			Length = 4,
			Looped = true,
			Pose = function(t)
				local P = {}
				local br = wave(t, 4)
				P.Torso = J(-6, 0, 3, 0, drop + 0.03 * br)
				P.LegL = J(84)
				P.LegR = J(84)
				arms(P, 10, 10, 2)
				P.Head = J(-28 - 2 * br, 10, 8)
				P.Tail1 = J(spec.sitTail)
				Q.eyes(P, 1)
				return P
			end,
		}
	end

	-- Dance: side hops with arms waving overhead.
	function B.Dance(spec)
		return {
			Name = "Dance",
			Length = 2,
			Looped = false,
			Pose = function(t)
				local P = {}
				local e = curve(t, { { 0, 0 }, { 0.15, 1 }, { 1.8, 1 }, { 2, 0 } })
				local hop = math.abs(math.sin(t * math.pi * 2)) * 0.35 * e
				P.Torso = J(0, 25 * math.sin(t * math.pi) * e, 8 * math.sin(t * math.pi * 2) * e, 0, hop)
				local w = math.sin(t * math.pi * 4)
				if spec.wings then
					arms(P, 0, 0, (70 + 30 * w) * e)
				else
					arms(P, (150 + 20 * w) * e, (150 - 20 * w) * e, 25 * e)
				end
				P.LegL = J(15 * math.sin(t * math.pi * 2) * e)
				P.LegR = J(-15 * math.sin(t * math.pi * 2) * e)
				P.Head = J(0, 0, -12 * math.sin(t * math.pi * 2) * e)
				P.Tail1 = J(0, 30 * w * e)
				Q.eyes(P, if t > 0.8 and t < 1.2 then 1 else 0)
				return Q.plant(spec, P)
			end,
		}
	end

	-- Roar: lean in, head up, jaw wide, arms flailing.
	function B.Roar(spec)
		local k = {
			Head = { { 0, 0 }, { 0.3, -12 }, { 0.6, 30, "BackOut" }, { 1.4, 26 }, { 1.8, 0 } },
			Jaw = { { 0, 0 }, { 0.4, 0 }, { 0.6, -45, "QuadOut" }, { 1.4, -42 }, { 1.6, 0 } },
			Lean = { { 0, 0 }, { 0.3, -8 }, { 0.6, 10 }, { 1.4, 8 }, { 1.8, 0 } },
		}
		return {
			Name = "Roar",
			Length = 1.8,
			Looped = false,
			Pose = function(t)
				local P = {}
				local on = if t > 0.5 and t < 1.5 then 1 else 0
				P.Torso = J(curve(t, k.Lean))
				P.Head = J(curve(t, k.Head), 6 * on * math.sin(t * 35))
				P.Jaw = J(curve(t, k.Jaw))
				arms(P, 40 + 30 * on * math.sin(t * 30), 40 - 30 * on * math.sin(t * 30), 10)
				P.Tail1 = J(-10 * on, 15 * math.sin(t * 8))
				Q.eyes(P, 0)
				return Q.plant(spec, P)
			end,
		}
	end

	function B.fromParams(p)
		local spec = B.measure(p)
		local trick = p.trick or "Dance"
		local anims = {
			Idle = B.Idle(spec),
			Walk = B.Walk(spec),
			Run = B.Run(spec),
			Sit = B.Sit(spec),
			Jump = B.Jump(spec),
			Sleep = B.Sleep(spec),
		}
		anims[trick] = B[trick](spec)
		return { Spec = spec, Anims = anims, Order = { "Idle", "Walk", "Run", "Sit", "Jump", "Sleep", trick }, Trick = trick }
	end

	return B
end
