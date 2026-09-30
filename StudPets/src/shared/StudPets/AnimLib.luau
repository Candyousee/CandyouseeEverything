--!strict
-- Pure-math animation helpers. No Roblox types in here, so the exact same file
-- runs in-game (PetAnimator) and offline in Lune (build + preview + QA).
--
-- A pose is {rx, ry, rz, px, py, pz}: degrees + studs, applied as
--   Motor6D.Transform = CFrame.new(px, py, pz) * CFrame.Angles(rad(rx), rad(ry), rad(rz))
-- Joint axes are model-aligned at rest: +rx pitches the front up / swings a leg
-- forward, +ry turns left, +rz rolls the top toward -X.

local AnimLib = {}

export type Pose = { number }
export type PoseSet = { [string]: Pose }
export type Anim = {
	Name: string,
	Length: number,
	Looped: boolean,
	Pose: (t: number) -> PoseSet,
}

local TAU = 2 * math.pi
local PI = math.pi

local function backOut(a: number): number
	local s = 1.70158
	a -= 1
	return 1 + (s + 1) * a * a * a + s * a * a
end

AnimLib.Ease = {
	Linear = function(a: number): number
		return a
	end,
	Constant = function(_a: number): number
		return 0
	end,
	Sine = function(a: number): number
		return 0.5 - 0.5 * math.cos(PI * a)
	end,
	SineIn = function(a: number): number
		return 1 - math.cos(a * PI / 2)
	end,
	SineOut = function(a: number): number
		return math.sin(a * PI / 2)
	end,
	QuadIn = function(a: number): number
		return a * a
	end,
	QuadOut = function(a: number): number
		return 1 - (1 - a) * (1 - a)
	end,
	Cubic = function(a: number): number
		return if a < 0.5 then 4 * a * a * a else 1 - (-2 * a + 2) ^ 3 / 2
	end,
	CubicOut = function(a: number): number
		return 1 - (1 - a) ^ 3
	end,
	BackOut = backOut,
}

-- sin wave with a period (seconds) and a phase offset (fraction of a cycle).
function AnimLib.wave(t: number, period: number, phase: number?): number
	return math.sin(TAU * (t / period - (phase or 0)))
end

-- 0..1 wave
function AnimLib.wave01(t: number, period: number, phase: number?): number
	return 0.5 + 0.5 * AnimLib.wave(t, period, phase)
end

function AnimLib.J(rx: number?, ry: number?, rz: number?, px: number?, py: number?, pz: number?): Pose
	return { rx or 0, ry or 0, rz or 0, px or 0, py or 0, pz or 0 }
end

local ZERO: Pose = { 0, 0, 0, 0, 0, 0 }
AnimLib.ZERO = ZERO

-- Keyed curve. keys = {{time, value, ease?}, ...} sorted by time; `ease` names
-- how the curve ARRIVES at that key (default "Sine"). Values can be numbers or poses.
function AnimLib.curve(t: number, keys: { any }): any
	local first = keys[1]
	if t <= first[1] then
		return first[2]
	end
	for i = 2, #keys do
		local k = keys[i]
		if t <= k[1] then
			local prev = keys[i - 1]
			local span = k[1] - prev[1]
			local a = if span > 0 then (t - prev[1]) / span else 1
			local easeFn = AnimLib.Ease[k[3] or "Sine"]
			a = easeFn(a)
			local v0, v1 = prev[2], k[2]
			if type(v0) == "number" then
				return v0 + (v1 - v0) * a
			end
			local out = table.create(6)
			for c = 1, 6 do
				local x0 = v0[c] or 0
				out[c] = x0 + ((v1[c] or 0) - x0) * a
			end
			return out
		end
	end
	return keys[#keys][2]
end

-- Component-wise sum of poses (layering an oscillation on top of a keyed pose).
function AnimLib.add(...: Pose?): Pose
	local out = { 0, 0, 0, 0, 0, 0 }
	for i = 1, select("#", ...) do
		local p = select(i, ...)
		if p then
			for c = 1, 6 do
				out[c] += p[c] or 0
			end
		end
	end
	return out
end

function AnimLib.lerpPose(a: Pose?, b: Pose?, alpha: number): Pose
	local pa = a or ZERO
	local pb = b or ZERO
	local out = table.create(6)
	for c = 1, 6 do
		out[c] = pa[c] + (pb[c] - pa[c]) * alpha
	end
	return out
end

-- Blend two pose sets (missing joints count as rest pose).
function AnimLib.blend(a: PoseSet, b: PoseSet, alpha: number): PoseSet
	local out: PoseSet = {}
	for name, p in a do
		out[name] = AnimLib.lerpPose(p, b[name], alpha)
	end
	for name, p in b do
		if out[name] == nil then
			out[name] = AnimLib.lerpPose(nil, p, alpha)
		end
	end
	return out
end

function AnimLib.localTime(anim: Anim, t: number): number
	if anim.Looped then
		return t % anim.Length
	end
	return math.clamp(t, 0, anim.Length)
end

function AnimLib.sample(anim: Anim, t: number): PoseSet
	return anim.Pose(AnimLib.localTime(anim, t))
end

return AnimLib
