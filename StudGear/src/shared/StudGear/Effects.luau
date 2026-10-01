--!strict
-- Combines the effects of the gear a character is holding (pure math, shared + tested).

local Effects = {}

export type Combined = { speed: number, gravity: number, jump: number, active: boolean }

-- strongest of each effect wins (holding two speed coils doesn't double up)
function Effects.Combine(gear: { any }): Combined
	local speed, gravity, jump = 1, 1, 1
	for _, g in gear do
		speed = math.max(speed, tonumber(g.Speed) or 1)
		gravity = math.min(gravity, math.clamp(tonumber(g.Gravity) or 1, 0, 1))
		jump = math.max(jump, tonumber(g.Jump) or 1)
	end
	return { speed = speed, gravity = gravity, jump = jump, active = speed ~= 1 or gravity ~= 1 or jump ~= 1 }
end

-- upward force that leaves `gravity` of the normal weight (mass * workspace.Gravity)
function Effects.LiftForce(mass: number, worldGravity: number, gravity: number): number
	return mass * worldGravity * (1 - gravity)
end

return Effects
