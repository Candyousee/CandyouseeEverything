--!strict
-- Swimmer animation set (whales, sharks, fish...): they float and swim through
-- the air, pet-sim style. Joints: Torso, Head, Tail1, Tail2, FinL, FinR, EyeL, EyeR.
-- `kick = "side"` for fish/sharks (tail sweeps left-right), "vertical" for
-- whales/dolphins (flukes pump up-down).

return function(A, Q)
	local J, wave, curve = A.J, A.wave, A.curve

	local S = {}

	function S.measure(p)
		local b = p.body or { 1.8, 1.6, 3 }
		local base = p.hover or 1.4
		-- tall bottom fins need extra clearance
		local hover = base + (if p.tallFins then b[2] * 0.95 else 0)
		local spec = {
			rootY = hover + b[2] / 2,
			hover = hover,
			baseHover = base,
			noPlant = true,
			kick = p.kick or "side",
			swim = p.swimPeriod or 1, -- must divide 4 s
			ears = "perky",
		}
		for key, v in p.anim or {} do
			spec[key] = v
		end
		return spec
	end

	-- side eyes close by sinking sideways into the head
	local function eyes(P, closed: number)
		P.EyeL = J(0, 0, 0, 0.12 * closed, 0, 0)
		P.EyeR = J(0, 0, 0, -0.12 * closed, 0, 0)
	end

	-- Tail + fins for a swim stroke of `amp` (0..1) with period T.
	local function stroke(spec, P, t: number, T: number, amp: number)
		local a1, a2 = 18 * amp, 32 * amp
		if spec.kick == "vertical" then
			P.Tail1 = J(a1 * wave(t, T), 0, 0)
			P.Tail2 = J(a2 * wave(t, T, 0.15), 0, 0)
			P.Head = J(-3 * amp * wave(t, T, 0.5))
		else
			P.Tail1 = J(0, a1 * wave(t, T), 0)
			P.Tail2 = J(0, a2 * wave(t, T, 0.15), 0)
			P.Head = J(0, -4 * amp * wave(t, T, 0.5))
		end
		local fin = 10 + 18 * amp * wave(t, T, 0.25)
		P.FinL = J(0, 0, -fin)
		P.FinR = J(0, 0, fin)
	end

	function S.Idle(spec)
		return {
			Name = "Idle",
			Length = 4,
			Looped = true,
			Pose = function(t)
				local P = {}
				stroke(spec, P, t, 2, 0.4)
				P.Torso = J(2 * wave(t, 4, 0.25), 6 * wave(t, 4), 0, 0, 0.15 * wave(t, 4))
				eyes(P, Q.blink(t, { 1.1, 3.2 }))
				return P
			end,
		}
	end

	function S.Walk(spec)
		local T = spec.swim
		return {
			Name = "Walk",
			Length = T,
			Looped = true,
			Pose = function(t)
				local P = {}
				stroke(spec, P, t, T, 1)
				local side = if spec.kick == "side" then 4 * wave(t, T, 0.5) else 0
				local bob = if spec.kick == "vertical" then 3 * wave(t, T, 0.5) else 0
				P.Torso = J(bob - 2, side, 0, 0, 0.1 * wave(t, T, 0.25))
				eyes(P, 0)
				return P
			end,
		}
	end

	function S.Run(spec)
		local T = spec.swim / 2
		return {
			Name = "Run",
			Length = T * 2,
			Looped = true,
			Pose = function(t)
				local P = {}
				stroke(spec, P, t, T, 1.3)
				local side = if spec.kick == "side" then 6 * wave(t, T, 0.5) else 0
				local bob = if spec.kick == "vertical" then 5 * wave(t, T, 0.5) else 0
				P.Torso = J(bob - 6, side, 0, 0, 0.3 + 0.15 * wave(t, T, 0.25))
				P.FinL = J(0, -25, -30)
				P.FinR = J(0, 25, 30)
				eyes(P, 0)
				return P
			end,
		}
	end

	function S.Sit(spec)
		return {
			Name = "Sit",
			Length = 4,
			Looped = true,
			Pose = function(t)
				local P = {}
				stroke(spec, P, t, 4, 0.3)
				P.Torso = J(3 * wave(t, 4), 0, 4 * wave(t, 4, 0.3), 0, -spec.baseHover * 0.55 + 0.08 * wave(t, 4))
				eyes(P, Q.blink(t, { 2.2 }))
				return P
			end,
		}
	end

	function S.Jump(spec)
		local k = {
			Up = { { 0, 0 }, { 0.2, -0.3 }, { 0.65, 2.6, "QuadOut" }, { 1.1, 0, "QuadIn" }, { 1.25, -0.2 }, { 1.5, 0 } },
			Pitch = { { 0, 0 }, { 0.2, -10 }, { 0.45, 40 }, { 0.8, 0 }, { 1.0, -30 }, { 1.15, 0 }, { 1.3, 3 }, { 1.5, 0 } },
		}
		return {
			Name = "Jump",
			Length = 1.5,
			Looped = false,
			Pose = function(t)
				local P = {}
				stroke(spec, P, t, 0.5, 1.2)
				P.Torso = J(curve(t, k.Pitch) * (spec.leapPitch or 1), 0, 0, 0, curve(t, k.Up))
				eyes(P, 0)
				return P
			end,
		}
	end

	function S.Sleep(spec)
		return {
			Name = "Sleep",
			Length = 4,
			Looped = true,
			Pose = function(t)
				local P = {}
				stroke(spec, P, t, 4, 0.15)
				P.Torso = J(-3, 0, 12 + 2 * wave(t, 4), 0, -spec.baseHover * 0.6 + 0.06 * wave(t, 4))
				eyes(P, 1)
				return P
			end,
		}
	end

	-- Flip: pop up and do a full forward somersault.
	function S.Flip(spec)
		local k = {
			Up = { { 0, 0 }, { 0.2, -0.2 }, { 0.6, 1.8, "QuadOut" }, { 1.2, 1.6 }, { 1.6, 0, "QuadIn" }, { 1.8, 0 } },
			Spin = { { 0, 0 }, { 0.35, 0 }, { 1.3, -360, "Cubic" }, { 1.8, -360 } },
		}
		return {
			Name = "Flip",
			Length = 1.8,
			Looped = false,
			Pose = function(t)
				local P = {}
				stroke(spec, P, t, 0.45, 1.2)
				local spin = curve(t, k.Spin)
				P.Torso = J(if spin <= -360 then 0 else spin, 0, 0, 0, curve(t, k.Up))
				eyes(P, if spin < -60 and spin > -300 then 1 else 0)
				return P
			end,
		}
	end

	-- Spin: twirl on the spot (round fish).
	function S.Spin(spec)
		return {
			Name = "Spin",
			Length = 1.4,
			Looped = false,
			Pose = function(t)
				local P = {}
				stroke(spec, P, t, 0.35, 1)
				local turn = curve(t, { { 0, 0 }, { 1.1, 360, "Cubic" }, { 1.4, 360 } })
				P.Torso = J(0, if turn >= 360 then 0 else turn, 0, 0, 0.4 * math.sin(math.pi * math.clamp(t / 1.1, 0, 1)))
				eyes(P, 0)
				return P
			end,
		}
	end

	function S.fromParams(p)
		local spec = S.measure(p)
		local trick = p.trick or "Flip"
		local anims = {
			Idle = S.Idle(spec),
			Walk = S.Walk(spec),
			Run = S.Run(spec),
			Sit = S.Sit(spec),
			Jump = S.Jump(spec),
			Sleep = S.Sleep(spec),
		}
		anims[trick] = S[trick](spec)
		return { Spec = spec, Anims = anims, Order = { "Idle", "Walk", "Run", "Sit", "Jump", "Sleep", trick }, Trick = trick }
	end

	return S
end
