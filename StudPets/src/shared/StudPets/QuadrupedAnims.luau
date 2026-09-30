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
		if spec.noPlant then
			return P
		end
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
		for _, leg in spec.legList or LEGS do
			local name, side, zKey = leg[1], leg[2], leg[3]
			local zHip = if type(zKey) == "string" then spec[zKey] else zKey
			local p = P[name] or J()
			local hipY = spec.rootY + torso[5] + worldY(side * (spec.hipX or 0.5), spec.hipY - spec.rootY, zHip) + p[5] * upY
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

	-- Hopping gait (frogs, rabbits): all four legs push together, the body arcs,
	-- front paws reach to land. `height` in studs, one hop per period.
	function Q.hop(spec, P, t: number, period: number, height: number)
		local u = (t % period) / period
		local air = curve(u, { { 0, 0 }, { 0.18, -0.08 }, { 0.3, 0.2 }, { 0.6, 1, "QuadOut" }, { 0.88, 0, "QuadIn" }, { 1, 0 } })
		local pitch = curve(u, { { 0, 0 }, { 0.18, -5 }, { 0.32, 14, "QuadOut" }, { 0.6, 0 }, { 0.85, -10 }, { 0.95, 2 }, { 1, 0 } })
		local back = curve(u, { { 0, 0 }, { 0.18, 8 }, { 0.32, -45, "QuadOut" }, { 0.6, 20 }, { 0.88, 10 }, { 1, 0 } })
		local front = curve(u, { { 0, 0 }, { 0.18, -8 }, { 0.32, -20 }, { 0.6, 35 }, { 0.85, 25 }, { 1, 0 } })
		P.Torso = J(pitch, 0, 0, 0, height * math.max(air, 0) + math.min(air, 0), 0)
		P.LegBL = J(back)
		P.LegBR = J(back)
		P.LegFL = J(front)
		P.LegFR = J(front)
		P.Head = J(-pitch * 0.6)
		local e = spec.ears == "floppy"
		Q.ears(spec, P, (if e then -1 else 1) * 25 * math.max(air, 0), if e then 8 * air else 0)
		P.Tail1 = J(-15 * air)
		P.Tail2 = J(-10 * air)
	end

	function Q.Walk(spec)
		local T = spec.walkPeriod
		local sw = spec.walkSwing
		if spec.gait == "hop" then
			return {
				Name = "Walk",
				Length = T * 1.6,
				Looped = true,
				Pose = function(t)
					local P = {}
					Q.hop(spec, P, t, T * 1.6, spec.hipY * 0.8 + 0.35)
					Q.eyes(P, 0)
					return Q.plant(spec, P)
				end,
			}
		end
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
		if spec.gait == "hop" then
			return {
				Name = "Run",
				Length = T * 1.4,
				Looped = true,
				Pose = function(t)
					local P = {}
					Q.hop(spec, P, t, T * 1.4, spec.hipY * 1.6 + 0.6)
					Q.eyes(P, 0)
					return Q.plant(spec, P)
				end,
			}
		end
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
				local ef = spec.earFlap or 1 -- elephants: keep the big ears off the face
				Q.ears(spec, P, (28 + flap) * ef, (if spec.ears == "floppy" then 10 else 6) * ef)
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
		if spec.sitStyle == "kush" then
			-- camelid rest: all legs folded under, chest down, neck and head up
			local drop = spec.legT * 0.5 - spec.hipY
			return {
				Name = "Sit",
				Length = 3,
				Looped = true,
				Pose = function(t)
					local P = {}
					local br = wave(t, 1.5)
					P.Torso = J(2, 0, 0, 0, drop + 0.03 * br, 0)
					P.LegFL = J(-88)
					P.LegFR = J(-88)
					P.LegBL = J(88)
					P.LegBR = J(88)
					local look = curve(t, { { 0, 0 }, { 1.0, 0 }, { 1.3, 15 }, { 2.2, 15 }, { 2.6, 0 } })
					P.Head = J(-br, look, 0)
					P.Tail1 = J(-35)
					P.Tail2 = J(-20)
					Q.ears(spec, P, 2 * br, 0)
					Q.eyes(P, Q.blink(t, { 1.9 }))
					return Q.plant(spec, P)
				end,
			}
		end
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
				local tl = curve(t, tail) * (spec.jumpTailScale or 1)
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
				P.Torso = J(0, 0, 5, 0, drop + 0.035 * br, 0)
				P.LegFL = J(90, 0, 0)
				P.LegFR = J(90, 0, 0)
				P.LegBL = J(90, 0, 0)
				P.LegBR = J(90, 0, 0)
				if spec.hasNeck then
					-- long necks come down so the head rests low
					P.Neck = J(-spec.neckDrop - 1.5 * br, 10, 0)
					P.Head = J(spec.neckDrop * 0.55, 0, 4)
				else
					P.Head = J(spec.sleepHead[1] - 1.5 * br, 8, 4, 0, spec.sleepHead[2] - 0.02 * br, 0)
				end
				local tw = curve(t, { { 0, 0 }, { 2.6, 0 }, { 2.66, 1, "QuadOut" }, { 2.8, 0 } })
				local earBack = if spec.ears == "floppy" then 0 elseif spec.earsTall then 70 else 12
				Q.ears(spec, P, earBack, if spec.ears == "floppy" then 6 else 10, 16 * tw, 0)
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
	-- Hind legs planted, torso pitched by `phi` degrees: torso py that keeps the
	-- back hips at standing height, plus the front-hip height that results.
	local function pitchOnHind(spec, phi)
		local c, s = cos(rad(phi)), sin(rad(phi))
		local hipRel = spec.hipY - spec.rootY
		local py = spec.hipY - (spec.rootY + hipRel * c - spec.hipZB * s)
		return py, spec.rootY + py + hipRel * c - spec.hipZF * s
	end

	-- Stretch: front paws slide out, chest down, rear up, then a back-leg stretch.
	function Q.Stretch(spec)
		local phi = -20
		local py, frontHip = pitchOnHind(spec, phi)
		local front = Q.solveLegAngle(spec, frontHip) - phi
		local back = -phi
		local k = {
			Torso = { { 0, J() }, { 0.6, J(phi, 0, 0, 0, py, 0.2) }, { 1.35, J(phi + 1, 0, 0, 0, py - 0.02, 0.22) }, { 1.75, J(3, 0, 0, 0, 0.05, 0) }, { 2.05, J(4, 0, -2, 0, 0.06, -0.05) }, { 2.35, J() }, { 2.6, J() } },
			Front = { { 0, 0 }, { 0.6, front }, { 1.35, front - 1 }, { 1.75, 0 }, { 2.6, 0 } },
			Back = { { 0, 0 }, { 0.6, back }, { 1.35, back + 1 }, { 1.75, 0 }, { 2.6, 0 } },
			BackL = { { 0, 0 }, { 0.6, back }, { 1.35, back + 1 }, { 1.75, 0 }, { 2.05, -42, "QuadOut" }, { 2.35, 0 }, { 2.6, 0 } },
			Head = { { 0, 0 }, { 0.6, 26 }, { 1.0, 30 }, { 1.35, 28 }, { 1.75, -4 }, { 2.05, 4 }, { 2.6, 0 } },
			Tail = { { 0, 0 }, { 0.6, -32 }, { 1.35, -36 }, { 1.75, 0 }, { 2.05, -10 }, { 2.6, 0 } },
			Ears = { { 0, 0 }, { 0.6, 20 }, { 1.35, 22 }, { 1.75, 0 }, { 2.6, 0 } },
			Eyes = { { 0, 0 }, { 0.7, 0 }, { 0.8, 1 }, { 1.25, 1 }, { 1.35, 0 } },
		}
		return {
			Name = "Stretch",
			Length = 2.6,
			Looped = false,
			Pose = function(t)
				local P = {}
				local tremble = if t > 0.6 and t < 1.35 then 0.6 * math.sin(t * 40) else 0
				P.Torso = A.add(curve(t, k.Torso), J(tremble))
				local f, b, bl = curve(t, k.Front), curve(t, k.Back), curve(t, k.BackL)
				P.LegFL = J(f)
				P.LegFR = J(f)
				P.LegBR = J(b)
				P.LegBL = J(bl, 0, 0, 0, if bl < 0 then -bl / 42 * 0.35 else 0)
				P.Head = J(curve(t, k.Head))
				local tl = curve(t, k.Tail)
				P.Tail1 = J(tl)
				P.Tail2 = J(tl * 0.5)
				Q.ears(spec, P, curve(t, k.Ears), 0)
				Q.eyes(P, curve(t, k.Eyes))
				return Q.plant(spec, P)
			end,
		}
	end

	-- Roar / howl / moo: head thrown up, jaw wide, head shake, front paw stamp.
	function Q.Roar(spec)
		local k = {
			Head = { { 0, 0 }, { 0.25, -10 }, { 0.5, 28, "BackOut" }, { 1.2, 26 }, { 1.5, 0 }, { 1.8, 0 } },
			Shake = { { 0, 0 }, { 0.5, 0 }, { 0.6, 1 }, { 1.2, 1 }, { 1.4, 0 } },
			Jaw = { { 0, 0 }, { 0.3, 0 }, { 0.5, -40, "QuadOut" }, { 1.2, -38 }, { 1.4, 0 } },
			Torso = { { 0, J() }, { 0.25, J(-4, 0, 0, 0, -0.08, 0.1) }, { 0.5, J(6, 0, 0, 0, 0.05, -0.05) }, { 1.3, J(5) }, { 1.8, J() } },
			Stamp = { { 0, 0 }, { 0.2, 0 }, { 0.32, 25, "QuadOut" }, { 0.46, 0, "QuadIn" }, { 1.8, 0 } },
			Ears = { { 0, 0 }, { 0.4, 25 }, { 1.3, 25 }, { 1.7, 0 } },
		}
		return {
			Name = "Roar",
			Length = 1.8,
			Looped = false,
			Pose = function(t)
				local P = {}
				P.Torso = curve(t, k.Torso)
				local shake = curve(t, k.Shake) * 7 * math.sin(t * 38)
				P.Head = J(curve(t, k.Head), shake, shake * 0.4)
				P.Jaw = J(curve(t, k.Jaw))
				P.LegFR = J(curve(t, k.Stamp), 0, 0, 0, curve(t, k.Stamp) * 0.012)
				P.Trunk = J(-curve(t, k.Head) * 2)
				Q.ears(spec, P, curve(t, k.Ears), 4)
				Q.eyes(P, 0)
				P.Tail1 = J(-15 * curve(t, k.Shake), 10 * math.sin(t * 12))
				return Q.plant(spec, P)
			end,
		}
	end

	-- Rear up on the hind legs, front legs pawing the air (horses, bears, goats).
	function Q.Rear(spec)
		local phi = spec.rearPitch or 38
		local py = pitchOnHind(spec, phi)
		local k = {
			Up = { { 0, 0 }, { 0.2, -0.12 }, { 0.55, 1, "BackOut" }, { 1.35, 1 }, { 1.7, -0.08, "QuadIn" }, { 1.9, 0 } },
		}
		return {
			Name = "Rear",
			Length = 1.9,
			Looped = false,
			Pose = function(t)
				local P = {}
				local u = curve(t, k.Up)
				local paw = if u > 0.5 then 30 * math.sin(t * 14) else 0
				P.Torso = J(phi * u, 0, 0, 0, py * math.max(0, u) + (if u < 0 then 0.6 * u else 0), 0)
				P.LegBL = J(-phi * u)
				P.LegBR = J(-phi * u)
				P.LegFL = J(-phi * u + 55 * math.max(0, u) + paw)
				P.LegFR = J(-phi * u + 55 * math.max(0, u) - paw)
				P.Head = J(-phi * 0.6 * u + 10 * u)
				Q.ears(spec, P, 18 * math.max(0, u), 0)
				Q.eyes(P, 0)
				P.Tail1 = J((spec.rearTail or 20) * u)
				P.Jaw = J(-20 * math.max(0, u))
				return Q.plant(spec, P)
			end,
		}
	end

	-- Happy spin: a little hop and a full turn on the spot.
	function Q.Spin(spec)
		local T = spec.walkPeriod * 0.8
		local k = {
			Turn = { { 0, 0 }, { 0.15, -15 }, { 1.05, 360, "Cubic" }, { 1.4, 360 } },
			Hop = { { 0, 0 }, { 0.15, -0.1 }, { 0.35, 0.5, "QuadOut" }, { 0.6, 0, "QuadIn" }, { 0.8, 0.35, "QuadOut" }, { 1.0, 0, "QuadIn" }, { 1.4, 0 } },
		}
		return {
			Name = "Spin",
			Length = 1.4,
			Looped = false,
			Pose = function(t)
				local P = {}
				local turn = curve(t, k.Turn)
				P.Torso = J(0, if turn >= 360 then 0 else turn, 0, 0, curve(t, k.Hop), 0)
				local e = if t < 1.1 then 1 else 0
				P.LegFL = Q.gaitLeg(spec, t, T, 0.0, 20 * e, 0.1)
				P.LegBR = Q.gaitLeg(spec, t, T, 0.0, 20 * e, 0.1)
				P.LegFR = Q.gaitLeg(spec, t, T, 0.5, 20 * e, 0.1)
				P.LegBL = Q.gaitLeg(spec, t, T, 0.5, 20 * e, 0.1)
				P.Head = J(8 * e, -12 * e)
				Q.ears(spec, P, 15 * e, 0)
				Q.eyes(P, if t > 0.35 and t < 0.9 then 1 else 0)
				P.Tail1 = J(-20 * e, 25 * e * math.sin(t * 20))
				P.Tail2 = J(0, 25 * e * math.sin(t * 20 - 1))
				return Q.plant(spec, P)
			end,
		}
	end

	-- Elephant trumpet: trunk swings up, ears flare, a front foot lifts.
	function Q.Trumpet(spec)
		local k = {
			Trunk = { { 0, 0 }, { 0.3, 15 }, { 0.7, -125, "BackOut" }, { 1.6, -120 }, { 2.0, 0 } },
			Head = { { 0, 0 }, { 0.7, 18 }, { 1.6, 16 }, { 2.0, 0 } },
			Ears = { { 0, 0 }, { 0.5, 30 }, { 1.6, 30 }, { 2.0, 0 } },
			Foot = { { 0, 0 }, { 0.5, 0 }, { 0.8, 35, "QuadOut" }, { 1.4, 35 }, { 1.7, 0, "QuadIn" }, { 2.0, 0 } },
		}
		return {
			Name = "Trumpet",
			Length = 2.0,
			Looped = false,
			Pose = function(t)
				local P = {}
				local flap = 8 * math.sin(t * 16)
				P.Torso = J(3 * curve(t, k.Foot) / 35)
				P.Head = J(curve(t, k.Head))
				P.Trunk = J(curve(t, k.Trunk), 0, 0)
				Q.ears(spec, P, 0, curve(t, k.Ears) + flap)
				P.LegFL = J(curve(t, k.Foot), 0, 0, 0, curve(t, k.Foot) * 0.015)
				Q.eyes(P, 0)
				P.Tail1 = J(0, 15 * math.sin(t * 9))
				return Q.plant(spec, P)
			end,
		}
	end

	-- Measurements for a kit-built quadruped (must match build/rigs/Kit.luau).
	function Q.measure(p)
		local b = p.body or { 2, 1.4, 3.2 }
		local legH, legW = p.legH or 1.3, p.legW or 0.8
		local zLeg = b[3] / 2 - legW / 2 - 0.15
		local t1 = p.tailPitch or 45
		local t2 = p.tail2Pitch or (t1 + 25)
		if p.tail == "curly" then
			t1, t2 = 20, 140
		elseif p.tail == "paddle" then
			t1, t2 = -15, -15
		end
		local lowTail = t1 < 20 -- tails that trail along the ground (crocs, dinos, otters)
		local highTail = t1 >= 60 -- tails carried up over the back (squirrels, huskies)
		local spec = {
			rootY = legH + b[2] / 2,
			halfLen = b[3] / 2,
			halfH = b[2] / 2,
			hipY = legH,
			hipZF = -zLeg,
			hipZB = zLeg,
			hipX = math.max(b[1] / 2 - legW / 2 - 0.12, legW / 2 + 0.08),
			legT = legW + (if p.pompoms then 0.3 else 0), -- poodle cuffs stick out past the leg
			ears = if p.ears == "floppy" or p.ears == "elephant" then "floppy" else "perky",
			walkPeriod = 0.5 + 0.2 * legH,
			walkSwing = 22,
			runPeriod = 0.32 + 0.09 * legH,
			runSwing = 38,
			tailWag = 10,
			idleWag = { 9, 4 },
			walkTail = if lowTail then { 0, 0 } else { -10, 5 },
			runTail = if lowTail then { -4, 0 } else { 25, 15 },
			jumpTailScale = if lowTail then 0.2 else 1,
			hasNeck = p.neck ~= nil,
			neckDrop = math.min(55, 20 + (p.neck or 0) * 10),
			earsTall = p.ears == "tall",
			gait = p.gait,
			sitStyle = p.sitStyle,
			earFlap = if p.ears == "elephant" then 0.35 else 1,
			sitPitch = if lowTail then 30 else 32,
			sitClear = 0.05,
			sitWag = 0,
			tailRest = { t1, t2 },
			sitTailDirs = if lowTail then { { -0.25, 0, 1 }, { -0.35, 0, 0.94 } }
				elseif highTail then { { -0.1, 0.7, 0.7 }, { -0.1, 0.95, -0.3 } }
				else { { -0.5, -0.3, 0.8 }, { -0.55, 0, -0.83 } },
			jumpHeight = 1.2 + 0.4 * legH,
			sleepHead = if p.horns then { -4, -0.08 } else { -12, -0.35 }, -- horns must not clip the back
			sleepTailDirs = if lowTail then { { -0.3, -0.05, 1 }, { -0.5, 0, 0.87 } }
				elseif highTail then { { -0.2, 0.5, 0.85 }, { -0.2, 0.9, -0.4 } }
				else { { -0.55, -0.45, 0.7 }, { -0.4, -0.3, -0.87 } },
			rearTail = if lowTail then -45 else 20,
		}
		for key, v in p.anim or {} do
			spec[key] = v
		end
		return spec
	end

	-- Full animation set for an entry in Animals.luau.
	-- Wing motion for winged four-legged pets (dragons, pegasus, griffin): layered
	-- on top of every animation. open > 0 spreads both wings outward.
	local function wingOpen(name: string, t: number, len: number): number
		if name == "Idle" then
			-- breathing, plus a big stretch-and-shake once per loop
			return 3 * wave(t, 2) + curve(t, { { 0, 0 }, { 2.2, 0 }, { 2.6, 55, "BackOut" }, { 3.0, 50 }, { 3.5, 0 } }) + (if t > 2.6 and t < 3.0 then 6 * math.sin(t * 40) else 0)
		elseif name == "Walk" then
			return 4 + 4 * wave(t, len)
		elseif name == "Run" then
			return 40 + 32 * wave(t, len)
		elseif name == "Sit" then
			return -6 + 2 * wave(t, 1.5)
		elseif name == "Sleep" then
			return -10
		elseif name == "Jump" then
			local open = curve(t, { { 0, 0 }, { 0.2, -8 }, { 0.36, 60, "QuadOut" }, { 0.85, 55 }, { 1.05, 8 }, { 1.2, 0 } })
			local flap = if t > 0.36 and t < 0.85 then 28 * math.sin((t - 0.36) * 26) else 0
			return open + flap
		elseif name == "Roar" or name == "Rear" then
			local open = curve(t, { { 0, 0 }, { 0.35, 70, "BackOut" }, { len - 0.4, 65 }, { len, 0 } })
			return open + (if t > 0.35 and t < len - 0.4 then 8 * math.sin(t * 9) else 0)
		end
		return 20 * math.sin(math.pi * math.clamp(t / len, 0, 1))
	end

	function Q.addWings(anims)
		for name, anim in anims do
			local pose = anim.Pose
			anim.Pose = function(t)
				local P = pose(t)
				local a = wingOpen(name, t, anim.Length)
				P.WingL = J(-a * 0.15, 0, a)
				P.WingR = J(-a * 0.15, 0, -a)
				return P
			end
		end
	end

	function Q.fromParams(p)
		local spec = Q.measure(p)
		local anims = Q.build(spec)
		local trick = p.trick or "Spin"
		anims[trick] = Q[trick](spec)
		if p.wings then
			Q.addWings(anims)
		end
		if p.trunk then
			-- trunk swings gently unless the animation drives it (Trumpet, Roar)
			for name, anim in anims do
				local pose = anim.Pose
				local period = if anim.Looped then anim.Length / math.max(1, math.round(anim.Length / 2)) else 2
				anim.Pose = function(t)
					local P = pose(t)
					if not P.Trunk then
						local swing = if name == "Run" then 20 else 8
						P.Trunk = J(18 + swing * wave(t, period), 6 * wave(t, period, 0.25), 0)
					end
					return P
				end
			end
		end
		return { Spec = spec, Anims = anims, Order = { "Idle", "Walk", "Run", "Sit", "Jump", "Sleep", trick }, Trick = trick }
	end

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
