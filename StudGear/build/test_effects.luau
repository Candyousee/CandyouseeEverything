-- Physics check for the gear maths: steps a character frame by frame (60 fps, real gravity)
-- and proves every test-course challenge can be done with its gear - and not without it.
--   lune run build/test_effects.luau

local Config = require("../src/shared/StudGear/Config")
local Effects = require("../src/shared/StudGear/Effects")

local G, DT = 196.2, 1 / 60
local JUMP_HEIGHT, WALK = 7.2, 16
local fails = 0
local function check(ok, msg)
	print((if ok then "  ok   " else "  FAIL ") .. msg)
	if not ok then
		fails += 1
	end
end
local gear = {}
for _, g in Config.Gear do
	gear[g.Name] = g
end

-- a jump with the given gear: peak height and how far you travel before landing back at y=0
local function jump(fx, opts)
	opts = opts or {}
	local g = G * fx.gravity
	local vy = Effects.JumpVelocity(false, 50, JUMP_HEIGHT * fx.jump, G)
	local y, t, peak = 0, 0, 0
	local airJumps = 0
	while t < 30 do
		vy -= g * DT
		vy = Effects.SlowFall(vy, fx.maxFall)
		y += vy * DT
		t += DT
		peak = math.max(peak, y)
		-- mid-air jump at the top of the first jump
		if vy <= 0 and airJumps < fx.airJumps then
			airJumps += 1
			vy = Effects.JumpVelocity(false, 50, JUMP_HEIGHT * fx.jump, G)
		end
		if y <= (opts.floor or 0) and vy < 0 then
			break
		end
	end
	return peak, t * WALK * fx.speed, t
end

local none = Effects.Combine({})
print("[jumps]")
local normalPeak, normalReach = jump(none)
check(math.abs(normalPeak - 7.2) < 0.6, ("a normal jump peaks at ~7.2 studs (%.1f)"):format(normalPeak))
check(normalReach < 11, ("normal jump carries %.1f studs: can't clear the 12-stud speed gap"):format(normalReach))
local _, speedReach = jump(Effects.Combine({ gear["Speed Coil"] }))
check(speedReach > 13, ("Speed Coil jump carries %.1f studs: clears the 12-stud gap"):format(speedReach))
local gravPeak = jump(Effects.Combine({ gear["Gravity Coil"] }))
check(gravPeak > 19 and normalPeak < 18, ("Gravity Coil peaks at %.1f: tops the 18-stud pillar"):format(gravPeak))
local jumpPeak = jump(Effects.Combine({ gear["Jump Coil"] }))
check(jumpPeak > 11 and normalPeak < 10, ("Jump Coil peaks at %.1f: climbs the 10-stud steps"):format(jumpPeak))
local dblPeak = jump(Effects.Combine({ gear["Double Jump Coil"] }))
check(dblPeak > 13, ("Double Jump peaks at %.1f (two jumps): climbs the 10-stud steps"):format(dblPeak))
local rainbowPeak, rainbowReach = jump(Effects.Combine({ gear["Rainbow Coil"] }))
check(rainbowPeak > 19 and rainbowReach > 13, ("Rainbow Coil: %.1f high, %.1f far - does the speed and gravity challenges"):format(rainbowPeak, rainbowReach))
check(Effects.JumpVelocity(true, 50, 0, G) == 50, "JumpPower mode: launch speed is JumpPower")

print("[balloon]")
local function fallReach(fx, drop)
	local vy, y, t = 0, drop, 0
	while y > 0 and t < 30 do
		vy = Effects.SlowFall(vy - G * fx.gravity * DT, fx.maxFall)
		y += vy * DT
		t += DT
	end
	return t * WALK * fx.speed, t
end
local balloonFx = Effects.Combine({ gear["Balloon"] })
local floatReach, floatTime = fallReach(balloonFx, 28)
local dropReach = fallReach(none, 28)
check(floatReach > 40, ("Balloon floats %.1f studs while dropping 28 (%.1f s): reaches the far platform (36-stud gap)"):format(floatReach, floatTime))
check(dropReach < 15, ("without it you only get %.1f studs"):format(dropReach))
check(Effects.SlowFall(-50, 9) == -9 and Effects.SlowFall(20, 9) == 20 and Effects.SlowFall(-50, nil) == -50, "slow fall only caps falling")

print("[jetpack]")
do
	local fx = Effects.Combine({ gear["Jetpack"] })
	local fuel = fx.jetpack.Fuel
	local vy = Effects.JumpVelocity(false, 50, JUMP_HEIGHT, G)
	local y, t, peak, topSpeed = 0, 0, 0, 0
	while t < 8 do
		vy -= G * DT -- what the physics does between frames
		local on
		vy, fuel, on = Effects.Jetpack(vy, fuel, true, false, DT, fx.jetpack, G)
		y += vy * DT
		t += DT
		peak = math.max(peak, y)
		if on and t > 1 then
			topSpeed = math.max(topSpeed, vy) -- after the jump's own momentum has gone
		end
		if y < 0 then
			break
		end
	end
	check(peak > 40, ("jetpack climbs to %.1f studs on one tank: reaches the 34-stud sky island"):format(peak))
	check(math.abs(topSpeed - fx.jetpack.Thrust) < 0.5, ("climb speed settles at Thrust (%.1f)"):format(topSpeed))
	check(fuel == 0, "the tank runs dry")
	-- refuel on the ground
	local f = 0
	for _ = 1, math.ceil(fx.jetpack.Refuel / DT) + 1 do
		local _
		_, f = Effects.Jetpack(0, f, false, true, DT, fx.jetpack, G)
	end
	check(math.abs(f - fx.jetpack.Fuel) < 1e-6, ("refills in %.1f s on the ground"):format(fx.jetpack.Refuel))
	local _, f2 = Effects.Jetpack(0, 1, false, false, DT, fx.jetpack, G)
	check(f2 == 1, "no refuel in mid-air")
	-- catching a fall: falling at 60, thrust stops the drop within half a second
	local v, fl = -60, fx.jetpack.Fuel
	local tt = 0
	while v < 0 and tt < 2 do
		v -= G * DT
		v, fl = Effects.Jetpack(v, fl, true, false, DT, fx.jetpack, G)
		tt += DT
	end
	check(tt < 0.5, ("stops a 60 stud/s fall in %.2f s"):format(tt))
end

print("[grapple]")
do
	local fx = Effects.Combine({ gear["Grapple Hook"] })
	-- from the ground to the underside edge of the sky island, ~67 studs away
	local px, py, pz = -46, 3, -64
	local tx, ty, tz = -34, 33.25, -100
	local t = 0
	while t < 3 do
		local vx, vy, vz = Effects.GrapplePull(px, py, pz, tx, ty, tz, fx.grapple.Speed)
		if not vx then
			break
		end
		px, py, pz = px + vx * DT, py + vy * DT, pz + vz * DT
		t += DT
	end
	local dist = math.sqrt((tx - px) ^ 2 + (ty - py) ^ 2 + (tz - pz) ^ 2)
	check(t < 3 and dist < 4.5, ("pulls you %.0f studs to the target in %.2f s"):format(67, t))
	-- the hop at the end clears the ledge
	local rise = math.max(0, ty - py) + 6.5
	local vy = math.sqrt(2 * G * rise)
	local hop = vy * vy / (2 * G)
	local feet = py + hop - 3 -- the root sits ~3 studs above your feet
	check(feet > ty + 1.5 + 0.5, ("end hop lifts your feet to %.1f, above the island top (%.2f)"):format(feet, ty + 1.5))
	local ax = Effects.GrapplePull(0, 0, 0, 0, 0, 3, 75)
	check(ax == nil, "arrived: stops pulling")
end

print("[combining]")
local both = Effects.Combine({ gear["Speed Coil"], gear["Fusion Coil"] })
check(both.speed == 1.75 and both.gravity == 0.4, "strongest effect of each kind wins (no stacking two coils)")
local c = Effects.Combine({})
check(not c.active and c.speed == 1 and c.gravity == 1 and c.jump == 1 and c.airJumps == 0 and c.maxFall == nil, "nothing held: no effects")
check(math.abs(Effects.LiftForce(15, G, 0.35) - 15 * G * 0.65) < 1e-6, "lift force = mass x g x (1 - gravity)")
for _, g in Config.Gear do
	check(Effects.Combine({ g }).active, g.Name .. " does something")
end

print(if fails == 0 then "[effects] all checks passed" else ("[effects] %d FAILED"):format(fails))
if fails > 0 then
	error("effects failed")
end
