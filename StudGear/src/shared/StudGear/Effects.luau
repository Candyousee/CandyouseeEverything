--!strict
-- Gear maths shared by the server, the client and the offline tests (no Roblox objects).

local Effects = {}

export type Combined = {
	speed: number,
	gravity: number,
	jump: number,
	airJumps: number,
	maxFall: number?,
	regen: number,
	jetpack: any?,
	grapple: any?,
	active: boolean,
}

-- what a character gets from everything it holds; the strongest of each effect wins
-- (holding two speed coils doesn't double up)
function Effects.Combine(gear: { any }): Combined
	local c: Combined = { speed = 1, gravity = 1, jump = 1, airJumps = 0, maxFall = nil, regen = 0, jetpack = nil, grapple = nil, active = false }
	for _, g in gear do
		c.speed = math.max(c.speed, tonumber(g.Speed) or 1)
		c.gravity = math.min(c.gravity, math.clamp(tonumber(g.Gravity) or 1, 0, 1))
		c.jump = math.max(c.jump, tonumber(g.Jump) or 1)
		c.airJumps = math.max(c.airJumps, math.floor(tonumber(g.AirJumps) or 0))
		c.regen = math.max(c.regen, tonumber(g.Regen) or 0)
		local mf = tonumber(g.MaxFall)
		if mf then
			c.maxFall = math.min(c.maxFall or math.huge, math.max(1, mf))
		end
		c.jetpack = c.jetpack or g.Jetpack
		c.grapple = c.grapple or g.Grapple
	end
	c.active = c.speed ~= 1 or c.gravity ~= 1 or c.jump ~= 1 or c.airJumps > 0 or c.maxFall ~= nil or c.regen > 0 or c.jetpack ~= nil or c.grapple ~= nil
	return c
end

-- upward force that leaves `gravity` of the normal weight (mass * workspace.Gravity)
function Effects.LiftForce(mass: number, worldGravity: number, gravity: number): number
	return mass * worldGravity * (1 - gravity)
end

-- launch speed of a normal jump (what a mid-air jump gives you)
function Effects.JumpVelocity(useJumpPower: boolean, jumpPower: number, jumpHeight: number, worldGravity: number): number
	if useJumpPower then
		return jumpPower
	end
	return math.sqrt(2 * worldGravity * math.max(0, jumpHeight))
end

-- falling speed capped at maxFall (vy is negative when falling)
function Effects.SlowFall(vy: number, maxFall: number?): number
	if maxFall and vy < -maxFall then
		return -maxFall
	end
	return vy
end

-- one jetpack step: returns the new upward speed and fuel left.
-- Thrusting eases the climb speed up to Thrust (on top of cancelling `gravity`, the pull the
-- physics adds each step); fuel refills while standing on the ground.
function Effects.Jetpack(vy: number, fuel: number, thrusting: boolean, grounded: boolean, dt: number, jet: any, gravity: number?): (number, number, boolean)
	local maxFuel = jet.Fuel or 2.5
	if thrusting and fuel > 0 then
		local target = jet.Thrust or 30
		local accel = target * (if vy < 0 then 8 else 4) -- catches a fall quickly, then climbs
		local newVy = if vy < target then math.min(target, vy + (accel + (gravity or 0)) * dt) else vy
		return newVy, math.max(0, fuel - dt), true
	end
	if grounded then
		fuel = math.min(maxFuel, fuel + dt * maxFuel / math.max(0.1, jet.Refuel or 1.5))
	end
	return vy, fuel, false
end

-- grapple pull: velocity toward the target, or nil once you've arrived
function Effects.GrapplePull(px: number, py: number, pz: number, tx: number, ty: number, tz: number, speed: number): (number?, number?, number?)
	local dx, dy, dz = tx - px, ty - py, tz - pz
	local dist = math.sqrt(dx * dx + dy * dy + dz * dz)
	if dist < 4 then
		return nil, nil, nil
	end
	-- ease off over the last few studs so you don't slam into the wall
	local s = speed * math.clamp(dist / 10, 0.45, 1)
	return dx / dist * s, dy / dist * s, dz / dist * s
end

return Effects
