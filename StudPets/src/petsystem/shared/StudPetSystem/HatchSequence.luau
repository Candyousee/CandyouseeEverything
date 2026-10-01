--!strict
-- The egg-hatch cinematic as pure maths: time in, poses out. The client applies it
-- every frame; the offline preview renders the exact same numbers.
--
-- Everything is in "stage space": studs, relative to the spot in front of the camera
-- where the egg sits (x right, y up, z toward the camera). `drama` comes from the pet's
-- rarity (0 common .. 3 secret) and makes the hatch longer and bigger.

local Hatch = {}

local TAU = math.pi * 2

local function clamp01(x: number): number
	return if x < 0 then 0 elseif x > 1 then 1 else x
end

local function smooth(x: number): number
	x = clamp01(x)
	return x * x * (3 - 2 * x)
end

local function backOut(x: number, s: number?): number
	x = clamp01(x)
	local k = s or 1.9
	x -= 1
	return 1 + (k + 1) * x * x * x + k * x * x
end

local function decay(x: number): number
	return if x < 0 then 0 else math.exp(-x)
end

-- deterministic pseudo-random (same numbers in-game and offline)
local function rng(seed: number)
	local state = (seed * 9301 + 49297) % 233280
	return function(): number
		state = (state * 9301 + 49297) % 233280
		return state / 233280
	end
end

export type Timing = {
	appear: number,
	shakes: { number },
	shakeLen: number,
	charge: number,
	chargeLen: number,
	pop: number,
	hold: number,
	length: number,
}

function Hatch.Timing(drama: number): Timing
	local shakes = {}
	local n = 3 + (if drama >= 2 then 1 else 0)
	local gap = 0.5 - 0.03 * drama
	for i = 1, n do
		table.insert(shakes, 0.55 + (i - 1) * gap)
	end
	local shakeLen = 0.32
	local charge = shakes[n] + shakeLen + 0.05
	local chargeLen = if drama >= 1 then 0.3 + 0.35 * drama else 0.12
	local pop = charge + chargeLen + 0.16 -- 0.16 s anticipation squash
	local hold = 1.4 + 0.5 * drama
	return {
		appear = 0.45,
		shakes = shakes,
		shakeLen = shakeLen,
		charge = charge,
		chargeLen = chargeLen,
		pop = pop,
		hold = hold,
		length = pop + hold + 0.45,
	}
end

function Hatch.Length(drama: number): number
	return Hatch.Timing(drama).length
end

-- Sound / particle cues, in time order: { {time, name, index?}, ... }
function Hatch.Events(drama: number): { { any } }
	local T = Hatch.Timing(drama)
	local ev = { { 0.12, "EggAppear" } }
	for i, s in T.shakes do
		table.insert(ev, { s, "Shake", i })
		if i <= 3 then
			table.insert(ev, { s + T.shakeLen * 0.8, "Crack", i })
		end
	end
	if drama >= 1 then
		table.insert(ev, { T.charge, "Charge" })
	end
	table.insert(ev, { T.pop, "Pop" })
	table.insert(ev, { T.pop + 0.12, "Reveal" })
	table.sort(ev, function(a, b)
		return a[1] < b[1]
	end)
	return ev
end

export type Shard = { pos: { number }, rot: { number }, size: number, alpha: number, color: number }

export type State = {
	eggVisible: boolean,
	eggScale: number,
	eggPos: { number },
	eggRot: { number }, -- degrees x, y, z
	cracks: number, -- 0..3 visible crack lines
	glow: number, -- 0..1 rarity glow on the egg
	rays: number, -- 0..1 light rays behind the egg / pet (rare+)
	flash: number, -- 0..1 white screen flash
	ring: { number }?, -- {radius, alpha} shockwave
	shards: { Shard },
	petScale: number, -- 0..1 of the pet's display size
	petYaw: number, -- degrees, 0 = facing the camera
	petY: number,
	banner: number, -- 0..1 rarity banner
	shake: number, -- camera shake amplitude (studs)
	dim: number, -- 0..1 background dim
	fade: number, -- 0..1 whole-stage fade out at the end
}

function Hatch.State(t: number, drama: number, seed: number): State
	local T = Hatch.Timing(drama)
	local s: State = {
		eggVisible = t < T.pop,
		eggScale = 1,
		eggPos = { 0, 0, 0 },
		eggRot = { 0, 0, 0 },
		cracks = 0,
		glow = 0,
		rays = 0,
		flash = 0,
		ring = nil,
		shards = {},
		petScale = 0,
		petYaw = 0,
		petY = 0,
		banner = 0,
		shake = 0,
		dim = smooth(t / 0.3) * (1 - smooth((t - T.length + 0.4) / 0.4)),
		fade = smooth((t - T.length + 0.45) / 0.45),
	}

	-- appear: drop in from above, land with a squash-bounce
	local a = t / T.appear
	s.eggScale = 0.35 + 0.65 * backOut(a, 1.4)
	s.eggPos[2] = 2.6 * (1 - smooth(a)) ^ 2
	s.eggRot[2] = -40 * (1 - smooth(a)) -- spins a little as it falls

	-- shakes: harder each time, a little hop, a crack at the end of each
	for i, st in T.shakes do
		local u = (t - st) / T.shakeLen
		if u >= 0 and u <= 1 then
			local amp = 9 + 6 * i + 3 * drama
			local env = math.sin(math.pi * u)
			s.eggRot[3] += amp * env * math.sin(TAU * 4.5 * u)
			s.eggRot[1] += amp * 0.25 * env * math.sin(TAU * 3 * u + 1)
			s.eggPos[2] += 0.18 * i * env
			s.shake = math.max(s.shake, 0.04 * i * env)
		end
		if t >= st + T.shakeLen * 0.8 and i <= 3 then
			s.cracks = i
		end
	end

	-- glow builds from the 2nd shake; rare+ charge up with rays and a fast tremble
	local glowStart = T.shakes[2] or T.charge
	s.glow = smooth((t - glowStart) / (T.pop - glowStart)) * (if drama >= 1 then 1 else 0.55)
	if drama >= 1 and t >= T.charge and t < T.pop then
		local c = (t - T.charge) / T.chargeLen
		s.eggRot[3] += 3.5 * math.sin(TAU * 22 * t) * clamp01(c * 2)
		s.eggScale *= 1 + 0.08 * smooth(c)
		s.rays = smooth(c) * 0.6
		s.shake = math.max(s.shake, 0.03 * drama * smooth(c))
	end

	-- anticipation: squeeze down just before the pop
	local q = (t - (T.pop - 0.16)) / 0.16
	if q >= 0 and q <= 1 then
		s.eggScale *= 1 - 0.14 * math.sin(math.pi * 0.5 * q)
	end

	-- the pop
	local p = t - T.pop
	if p >= 0 then
		s.flash = 0.9 * decay(p / 0.09) * (0.75 + 0.08 * drama)
		s.shake = math.max(s.shake, (0.22 + 0.1 * drama) * decay(p / 0.12))
		if p < 0.7 then
			local r = smooth(p / 0.55)
			s.ring = { 0.8 + (5 + 1.5 * drama) * r, 1 - smooth(p / 0.7) }
		end
		-- shell shards
		local rand = rng(seed)
		local n = 12 + 4 * drama
		for k = 1, n do
			-- draw every random number first so the sequence never shifts
			local yaw = TAU * (k / n) + rand() * 0.5
			local up = 0.15 + rand() * 0.9
			local spd = 6 + rand() * 5 + drama
			local life = 0.85 + rand() * 0.35
			local spin = 400 + rand() * 500
			local size = 0.35 + rand() * 0.35
			local tint = if rand() < 0.3 then 2 else 1 -- 1 shell, 2 spots
			if p < life then
				local dx, dz = math.cos(yaw), math.sin(yaw)
				local vx, vy, vz = dx * spd * (1 - up * 0.5), 4 + up * 7, dz * spd * (1 - up * 0.5)
				table.insert(s.shards, {
					pos = { dx * 0.9 + vx * p, 0.2 + up * 0.8 + vy * p - 13 * p * p, dz * 0.9 + vz * p },
					rot = { spin * p + yaw * 57, spin * 0.7 * p, spin * 0.4 * p },
					size = size,
					alpha = 1 - smooth((p - life + 0.25) / 0.25),
					color = tint,
				})
			end
		end
		-- pet: pops out with an overshoot, spins round to face you, settles
		s.petScale = backOut(p / 0.42, 2.2)
		s.petYaw = -360 * (1 - smooth(p / 0.85)) ^ 2
		s.petY = 0.9 * math.sin(math.pi * clamp01(p / 0.5)) * (1 - clamp01(p / 0.5) * 0.4)
		s.banner = smooth((p - 0.3) / 0.25)
		s.rays = math.max(s.rays, if drama >= 1 then 0.6 + 0.4 * smooth(p / 0.3) else 0)
	end
	return s
end

return Hatch
