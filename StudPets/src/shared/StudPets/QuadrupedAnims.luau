--!strict
-- Shared quadruped animations (Idle, Walk, Run, Sit, Jump, Sleep), built from a
-- pet's body measurements so the cat and dog share one set of motion rules.
-- Pure math: runs in-game and in the offline Lune build.
--
-- Joints (Part1 names): Torso, Head, EarL, EarR, EyeL, EyeR, Jaw,
-- LegFL, LegFR, LegBL, LegBR, Tail1, Tail2.

return function(A)
	local J, wave, curve = A.J, A.wave, A.curve
	local rad, deg, cos, sin, max = math.rad, math.deg, math.cos, math.sin, math.max

	local Q = {}

	-- A rigid block leg pivots at its top; swung by `angle` degrees, its lowest
	-- corner reaches hipY*cos + legT/2*sin below the pivot. Lift the pivot by the
	-- excess so the paw rocks on its corner instead of digging into the ground.
	function Q.legGroundLift(spec, angle: number): number
		local a = rad(math.abs(angle))
		return max(0, spec.hipY * cos(a) + spec.legT * 0.5 * sin(a) - spec.hipY)
	end

	function Q.gaitLeg(spec, t: number, period: number, phase: number, swing: number, lift: number)
		local angle = swing * wave(t, period, phase)
		-- positive while the leg swings forward (the derivative of the swing wave)
		local forward = max(0, wave(t, period, phase - 0.25))
		return J(angle, 0, 0, 0, Q.legGroundLift(spec, angle) + lift * forward, 0)
	end

	-- Paw planting: after a pose is built, slide any leg whose block would dip
	-- below the ground back up along the torso (the top hides inside the body).
	-- Keeps every blend between keys ground-safe, the way a foot IK would.
	local LEGS = {
		{ "LegFL", -1, "hipZF" },
		{ "LegFR", 1, "hipZF" },
		{ "LegBL", -1, "hipZB" },
		{ "LegBR", 1, "hipZB" },
	}
	function Q.plant(spec, P)
		local torso = P.Torso or A.ZERO
		local rx, ry, rz = rad(torso[1]), rad(torso[2]), rad(torso[3])
		local cx, sx, cy, sy, cz, sz = cos(rx), sin(rx), cos(ry), sin(ry), cos(rz), sin(rz)
		-- world-Y of a torso-frame vector under CFrame.Angles(rx, ry, rz) = Rx*Ry*Rz
		local function worldY(x, y, z)
			local x1, y1 = x * cz - y * sz, x * sz + y * cz
			local z2 = -x1 * sy + z * cy
			return y1 * cx - z2 * sx
		end
		local upY = worldY(0, 1, 0)
		local top = spec.legTop or 0.2
		for _, leg in LEGS do
			local name, side, zKey = leg[1], leg[2], leg[3]
			local p = P[name] or J()
			local hipY = spec.rootY + torso[5] + worldY(side * (spec.hipX or 0.5), spec.hipY - spec.rootY, spec[zKey]) + p[5] * upY
			local theta = rad(torso[1] + p[1])
			local c, s = cos(theta), sin(theta)
			local h = spec.legT * 0.5
			local lowest = math.huge
			for _, y in { -spec.hipY, top } do
				for _, z in { -h, h } do
					lowest = math.min(lowest, y * c - z * s)
				end
			end
			local pawY = hipY + lowest
			if pawY < 0 and upY > 0.2 then
				P[name] = J(p[1], p[2], p[3], p[4], p[5] - pawY / upY, p[6])
			end
		end
		return P
	end

	-- Tiny 3x3 rotation helpers (row-major) for aiming tail segments.
	local function euler(rx: number, ry: number, rz: number)
		-- same as CFrame.Angles(rx, ry, rz) = Rx * Ry * Rz
		local ca, sa, cb, sb, cc, sc = cos(rad(rx)), sin(rad(rx)), cos(rad(ry)), sin(rad(ry)), cos(rad(rz)), sin(rad(rz))
		return {
			cb * cc, -cb * sc, sb,
			ca * sc + sa * sb * cc, ca * cc - sa * sb * sc, -sa * cb,
			sa * sc - ca * sb * cc, sa * cc + ca * sb * sc, ca * cb,
		}
	end
	local function mul(m, n)
		local o = table.create(9)
		for r = 0, 2 do
			for c = 0, 2 do
				o[r * 3 + c + 1] = m[r * 3 + 1] * n[c + 1] + m[r * 3 + 2] * n[c + 4] + m[r * 3 + 3] * n[c + 7]
			end
		end
		return o
	end
	local function applyT(m, v) -- transpose(m) * v, i.e. world -> local
		return {
			m[1] * v[1] + m[4] * v[2] + m[7] * v[3],
			m[2] * v[1] + m[5] * v[2] + m[8] * v[3],
			m[3] * v[1] + m[6] * v[2] + m[9] * v[3],
		}
	end
	local function unit(v)
		local l = math.sqrt(v[1] * v[1] + v[2] * v[2] + v[3] * v[3])
		return { v[1] / l, v[2] / l, v[3] / l }
	end
	local function fromTo(a, b) -- shortest rotation taking unit a onto unit b
		local ax = { a[2] * b[3] - a[3] * b[2], a[3] * b[1] - a[1] * b[3], a[1] * b[2] - a[2] * b[1] }
		local s = math.sqrt(ax[1] ^ 2 + ax[2] ^ 2 + ax[3] ^ 2)
		local c = a[1] * b[1] + a[2] * b[2] + a[3] * b[3]
		if s < 1e-6 then
			return euler(0, 0, 0)
		end
		local x, y, z = ax[1] / s, ax[2] / s, ax[3] / s
		local t = 1 - c
		return {
			t * x * x + c, t * x * y - s * z, t * x * z + s * y,
			t * x * y + s * z, t * y * y + c, t * y * z - s * x,
			t * x * z - s * y, t * y * z + s * x, t * z * z + c,
		}
	end
	local function toEuler(m)
		return { deg(math.atan2(-m[6], m[9])), deg(math.asin(math.clamp(m[3], -1, 1))), deg(math.atan2(-m[2], m[1])) }
	end
	Q.euler = euler

	-- Turn a direction about the vertical axis by `angle` degrees.
	function Q.yawDir(d, angle: number)
		local c, s = cos(rad(angle)), sin(rad(angle))
		return { d[1] * c + d[3] * s, d[2], -d[1] * s + d[3] * c }
	end

	-- Joint angles that point Tail1/Tail2 along world directions dirs[1]/dirs[2]
	-- while the torso holds `torso` (a pose). Tail rest pitches come from spec.tailRest.
	function Q.aimTail(spec, torso, dirs)
		local function restDir(pitch)
			return { 0, sin(rad(pitch)), cos(rad(pitch)) }
		end
		local rT = euler(torso[1], torso[2], torso[3])
		local r1 = fromTo(restDir(spec.tailRest[1]), applyT(rT, unit(dirs[1])))
		local r2 = fromTo(restDir(spec.tailRest[2]), applyT(mul(rT, r1), unit(dirs[2])))
		return toEuler(r1), toEuler(r2)
	end

	-- back > 0 folds ears back, out > 0 splays them outward, for either ear style.
	function Q.ears(spec, P, back: number, out: number, twitchL: number?, twitchR: number?)
		local l = out + (twitchL or 0)
		local r = out + (twitchR or 0)
		if spec.ears == "floppy" then -- pivot at the top of the ear
			P.EarL = J(-back, 0, -l)
			P.EarR = J(-back, 0, r)
		else -- perky: pivot at the base
			P.EarL = J(back, 0, l)
			P.EarR = J(back, 0, -r)
		end
	end

	-- Eyes slide back into the head to blink (0.2 studs hides eye + glint).
	function Q.eyes(P, closed: number)
		P.EyeL = J(0, 0, 0, 0, 0, 0.2 * closed)
		P.EyeR = J(0, 0, 0, 0, 0, 0.2 * closed)
	end

	function Q.blink(t: number, at: { number }): number
		for _, t0 in at do
			local d = t - t0
			if d >= 0 and d < 0.2 then
				return if d < 0.05 then d / 0.05 elseif d < 0.13 then 1 else 1 - (d - 0.13) / 0.07
			end
		end
		return 0
	end

	-- Front-leg world angle (degrees forward) that puts the paw corner on the
	-- ground when the hip pivot sits `hipHeight` above it.
	function Q.solveLegAngle(spec, hipHeight: number): number
		local L, h = spec.hipY, spec.legT * 0.5
		local peak = math.atan2(h, L)
		local function depth(b)
			return L * cos(b) + h * sin(b)
		end
		if hipHeight >= depth(peak) then
			return 0 -- paw can't reach: hang straight
		end
		local lo, hi = peak, rad(89)
		for _ = 1, 30 do
			local mid = (lo + hi) / 2
			if depth(mid) > hipHeight then
				lo = mid
			else
				hi = mid
			end
		end
		return deg((lo + hi) / 2)
	end

	-- Sitting: rear on the ground, back legs folded forward, front legs planted.
	function Q.sitPose(spec)
		local phi = rad(spec.sitPitch)
		local c, s = cos(phi), sin(phi)
		local hipRel = spec.hipY - spec.rootY
		local rearY = -spec.halfH * c - spec.halfLen * s
		local py = spec.sitClear - (spec.rootY + rearY)
		local backHip = spec.rootY + py + (hipRel * c - spec.hipZB * s)
		if backHip < spec.legT * 0.5 then
			py += spec.legT * 0.5 - backHip
		end
		local frontHip = spec.rootY + py + (hipRel * c - spec.hipZF * s)
		local beta = Q.solveLegAngle(spec, frontHip)
		return {
			py = py,
			front = beta - spec.sitPitch,
			back = 90 - spec.sitPitch,
		}
	end

	function Q.Idle(spec)
		local wagAmp, wagPeriod = spec.idleWag[1], spec.idleWag[2]
		return {
			Name = "Idle",
			Length = 4,
			Looped = true,
			Pose = function(t)
				local P = {}
				local br = wave(t, 2)
				local look = curve(t, { { 0, 0 }, { 0.9, 0 }, { 1.4, 18 }, { 2.1, 18 }, { 2.6, -10 }, { 3.3, -10 }, { 3.8, 0 }, { 4, 0 } })
				local tilt = curve(t, { { 0, 0 }, { 0.9, 0 }, { 1.4, 7 }, { 2.1, 7 }, { 2.6, -3 }, { 3.3, -3 }, { 3.8, 0 } })
				local nod = curve(t, { { 0, 0 }, { 2.9, 0 }, { 3.05, -5, "QuadOut" }, { 3.35, 0 } })
				P.Torso = J(0.8 * br, 0, 0, 0, 0.025 * br, 0)
				P.Head = J(nod - 0.8 * br, look, tilt)
				local tw = curve(t, { { 0, 0 }, { 1.5, 0 }, { 1.56, 1, "QuadOut" }, { 1.72, 0 }, { 1.78, 0.7, "QuadOut" }, { 1.95, 0 } })
				Q.ears(spec, P, 3 * br, 0, 22 * tw, 0)
				Q.eyes(P, Q.blink(t, { 0.55, 2.95 }))
				P.Tail1 = J(2 * br, wagAmp * wave(t, wagPeriod), 0)
				P.Tail2 = J(-5 * wave(t, 2, 0.2), wagAmp * 1.3 * wave(t, wagPeriod, 0.12), 0)
				return Q.plant(spec, P)
			end,
		}
	end

	function Q.Walk(spec)
		local T = spec.walkPeriod
		local sw = spec.walkSwing
		return {
			Name = "Walk",
			Length = T,
			Looped = true,
			Pose = function(t)
				local P = {}
				-- lateral-sequence walk: back-left, front-left, back-right, front-right
				P.LegBL = Q.gaitLeg(spec, t, T, 0.0, sw, 0.12)
				P.LegFL = Q.gaitLeg(spec, t, T, 0.25, sw, 0.12)
				P.LegBR = Q.gaitLeg(spec, t, T, 0.5, sw, 0.12)
				P.LegFR = Q.gaitLeg(spec, t, T, 0.75, sw, 0.12)
				P.Torso = J(1 * wave(t, T / 2, 0.1), 2 * wave(t, T, 0.25), 2.5 * wave(t, T), 0, 0.04 * wave(t, T / 2), 0)
				P.Head = J(-2 + -2 * wave(t, T / 2, 0.2), -2 * wave(t, T, 0.25), -2 * wave(t, T))
				local earBob = (if spec.ears == "floppy" then 10 else 4) * wave(t, T / 2, 0.35)
				Q.ears(spec, P, earBob, if spec.ears == "floppy" then 4 else 0)
				Q.eyes(P, 0)
				P.Tail1 = J(spec.walkTail[1], spec.tailWag * wave(t, T), 0)
				P.Tail2 = J(spec.walkTail[2] + 4 * wave(t, T / 2, 0.2), spec.tailWag * 1.3 * wave(t, T, 0.15), 0)
				return Q.plant(spec, P)
			end,
		}
	end

	function Q.Run(spec)
		local T = spec.runPeriod
		local sw = spec.runSwing
		return {
			Name = "Run",
			Length = T,
			Looped = true,
			Pose = function(t)
				local P = {}
				-- rotary gallop: front pair together, back pair half a cycle later
				P.LegFL = Q.gaitLeg(spec, t, T, 0.0, sw, 0.3)
				P.LegFR = Q.gaitLeg(spec, t, T, 0.08, sw, 0.3)
				P.LegBL = Q.gaitLeg(spec, t, T, 0.5, sw, 0.3)
				P.LegBR = Q.gaitLeg(spec, t, T, 0.58, sw, 0.3)
				local reach = wave(t, T, 0.0)
				P.Torso = J(7 * reach, 0, 1.5 * wave(t, T, 0.25), 0, 0.06 + 0.12 * reach, 0)
				P.Head = J(-8 - 6 * reach, 0, 0, 0, 0, -0.1)
				local flap = if spec.ears == "floppy" then 12 * wave(t, T / 2, 0.3) else 0
				Q.ears(spec, P, 28 + flap, if spec.ears == "floppy" then 10 else 6)
				Q.eyes(P, 0)
				P.Tail1 = J(spec.runTail[1] + 6 * wave(t, T / 2), 5 * wave(t, T, 0.2), 0)
				P.Tail2 = J(spec.runTail[2] + 8 * wave(t, T / 2, 0.15), 6 * wave(t, T, 0.35), 0)
				return Q.plant(spec, P)
			end,
		}
	end

	function Q.Sit(spec)
		local S = Q.sitPose(spec)
		local dirs = spec.sitTailDirs
		return {
			Name = "Sit",
			Length = 3,
			Looped = true,
			Pose = function(t)
				local P = {}
				local br = wave(t, 1.5)
				P.Torso = J(spec.sitPitch + 0.8 * br, 0, 0, 0, S.py + 0.02 * br, 0)
				P.LegFL = J(S.front - 0.8 * br)
				P.LegFR = J(S.front - 0.8 * br)
				P.LegBL = J(S.back - 0.8 * br)
				P.LegBR = J(S.back - 0.8 * br)
				local look = curve(t, { { 0, 0 }, { 1.0, 0 }, { 1.3, 12 }, { 2.2, 12 }, { 2.6, 0 } })
				P.Head = J(-spec.sitPitch * 0.9 - 0.8 * br + 4, look, look * 0.35)
				local tw = curve(t, { { 0, 0 }, { 0.4, 0 }, { 0.46, 1, "QuadOut" }, { 0.62, 0 } })
				Q.ears(spec, P, 2 * br, 0, 0, 20 * tw)
				Q.eyes(P, Q.blink(t, { 1.9 }))
				local flick = curve(t, { { 0, 0 }, { 1.6, 0 }, { 1.8, 1 }, { 2.0, -0.4 }, { 2.3, 0 } })
				-- dogs sweep the floor with a wag; cats just sway (0.75 s divides the 3 s loop)
				local sway = if spec.sitWag > 0 then spec.sitWag * wave(t, 0.75) else 4 * wave(t, 3)
				local d2 = Q.yawDir(dirs[2], sway)
				local tail1, tail2 = Q.aimTail(spec, P.Torso, { Q.yawDir(dirs[1], sway), { d2[1], d2[2] + 0.7 * flick, d2[3] } })
				P.Tail1 = J(tail1[1], tail1[2], tail1[3])
				P.Tail2 = J(tail2[1], tail2[2], tail2[3])
				return Q.plant(spec, P)
			end,
		}
	end

	function Q.Jump(spec)
		local h = spec.jumpHeight
		local torso = {
			{ 0.0, J(0, 0, 0, 0, 0, 0) },
			{ 0.22, J(-6, 0, 0, 0, -0.16, 0.08), "Sine" },
			{ 0.36, J(14, 0, 0, 0, h * 0.45, -0.1), "QuadIn" },
			{ 0.56, J(2, 0, 0, 0, h, -0.15), "QuadOut" },
			{ 0.78, J(-10, 0, 0, 0, h * 0.3, -0.05), "QuadIn" },
			{ 0.88, J(-4, 0, 0, 0, -0.16, 0), "QuadIn" },
			{ 1.02, J(1.5, 0, 0, 0, 0.04, 0), "QuadOut" },
			{ 1.2, J(0, 0, 0, 0, 0, 0), "Sine" },
		}
		local front = {
			{ 0.0, 0 },
			{ 0.22, 14, "Sine" },
			{ 0.36, 38, "QuadIn" },
			{ 0.56, 62, "QuadOut" },
			{ 0.78, 12, "Sine" },
			{ 0.88, 16, "QuadIn" },
			{ 1.02, -3, "QuadOut" },
			{ 1.2, 0, "Sine" },
		}
		local back = {
			{ 0.0, 0 },
			{ 0.22, -14, "Sine" },
			{ 0.36, -45, "QuadIn" },
			{ 0.56, 28, "QuadOut" },
			{ 0.78, -8, "Sine" },
			{ 0.88, -16, "QuadIn" },
			{ 1.02, 3, "QuadOut" },
			{ 1.2, 0, "Sine" },
		}
		local head = {
			{ 0.0, 0 },
			{ 0.22, -10, "Sine" },
			{ 0.36, 12, "QuadOut" },
			{ 0.56, 0 },
			{ 0.78, 4 },
			{ 0.92, -12, "QuadOut" },
			{ 1.1, 3, "Sine" },
			{ 1.2, 0, "Sine" },
		}
		local tail = {
			{ 0.0, 0 },
			{ 0.22, -15, "Sine" },
			{ 0.36, 18, "QuadIn" },
			{ 0.6, 22 },
			{ 0.9, -12, "QuadIn" },
			{ 1.1, 4, "Sine" },
			{ 1.2, 0, "Sine" },
		}
		local ears = { { 0, 0 }, { 0.22, 8 }, { 0.36, 30, "QuadOut" }, { 0.8, 18 }, { 0.92, -10, "QuadOut" }, { 1.1, 3 }, { 1.2, 0 } }
		return {
			Name = "Jump",
			Length = 1.2,
			Looped = false,
			Pose = function(t)
				local P = {}
				P.Torso = curve(t, torso)
				local f, b = curve(t, front), curve(t, back)
				P.LegFL = J(f, 0, 0, 0, Q.legGroundLift(spec, f))
				P.LegFR = J(f, 0, 0, 0, Q.legGroundLift(spec, f))
				P.LegBL = J(b, 0, 0, 0, Q.legGroundLift(spec, b))
				P.LegBR = J(b, 0, 0, 0, Q.legGroundLift(spec, b))
				P.Head = J(curve(t, head))
				local tl = curve(t, tail)
				P.Tail1 = J(tl, 0, 0)
				P.Tail2 = J(tl * 0.6, 0, 0)
				Q.ears(spec, P, curve(t, ears), 0)
				Q.eyes(P, 0)
				return Q.plant(spec, P)
			end,
		}
	end

	function Q.Sleep(spec)
		local drop = spec.legT * 0.5 - spec.hipY
		local dirs = spec.sleepTailDirs
		return {
			Name = "Sleep",
			Length = 4,
			Looped = true,
			Pose = function(t)
				local P = {}
				local br = wave(t, 4)
				P.Torso = J(0, 0, 0, 0, drop + 0.035 * br, 0)
				P.LegFL = J(90, 0, 0)
				P.LegFR = J(90, 0, 0)
				P.LegBL = J(90, 0, 0)
				P.LegBR = J(90, 0, 0)
				P.Head = J(spec.sleepHead[1] - 1.5 * br, 8, 4, 0, spec.sleepHead[2] - 0.02 * br, 0)
				local tw = curve(t, { { 0, 0 }, { 2.6, 0 }, { 2.66, 1, "QuadOut" }, { 2.8, 0 } })
				Q.ears(spec, P, if spec.ears == "floppy" then 0 else 12, if spec.ears == "floppy" then 6 else 10, 16 * tw, 0)
				Q.eyes(P, 1)
				local tip = curve(t, { { 0, 0 }, { 1.2, 0 }, { 1.5, 1 }, { 1.9, 0 } })
				local d2 = dirs[2]
				local tail1, tail2 = Q.aimTail(spec, P.Torso, { dirs[1], { d2[1], d2[2] + 0.5 * tip, d2[3] } })
				P.Tail1 = J(tail1[1], tail1[2], tail1[3])
				P.Tail2 = J(tail2[1], tail2[2], tail2[3])
				return Q.plant(spec, P)
			end,
		}
	end

	-- The six shared animations for a pet spec.
	function Q.build(spec)
		return {
			Idle = Q.Idle(spec),
			Walk = Q.Walk(spec),
			Run = Q.Run(spec),
			Sit = Q.Sit(spec),
			Jump = Q.Jump(spec),
			Sleep = Q.Sleep(spec),
		}
	end

	return Q
end
