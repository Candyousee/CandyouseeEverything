--!strict
-- Tiny CFrame maths on plain arrays, so the same animation code runs inside Roblox and in
-- the offline preview. A CF is { x, y, z, r00, r01, r02, r10, r11, r12, r20, r21, r22 },
-- the same component order as Roblox's CFrame:GetComponents().

local CF = {}

export type CF = { number }
export type V3 = { number }

function CF.new(x: number?, y: number?, z: number?): CF
	return { x or 0, y or 0, z or 0, 1, 0, 0, 0, 1, 0, 0, 0, 1 }
end

-- same as CFrame.Angles(rx, ry, rz) (radians): R = Rx * Ry * Rz
function CF.angles(rx: number, ry: number, rz: number): CF
	local cx, sx = math.cos(rx), math.sin(rx)
	local cy, sy = math.cos(ry), math.sin(ry)
	local cz, sz = math.cos(rz), math.sin(rz)
	-- Rx * Ry
	local a00, a01, a02 = cy, 0, sy
	local a10, a11, a12 = sx * sy, cx, -sx * cy
	local a20, a21, a22 = -cx * sy, sx, cx * cy
	-- (Rx * Ry) * Rz
	return {
		0,
		0,
		0,
		a00 * cz + a01 * sz,
		-a00 * sz + a01 * cz,
		a02,
		a10 * cz + a11 * sz,
		-a10 * sz + a11 * cz,
		a12,
		a20 * cz + a21 * sz,
		-a20 * sz + a21 * cz,
		a22,
	}
end

-- angles in degrees
function CF.deg(x: number, y: number, z: number): CF
	return CF.angles(math.rad(x), math.rad(y), math.rad(z))
end

function CF.mul(a: CF, b: CF): CF
	local ax, ay, az = a[1], a[2], a[3]
	local a00, a01, a02, a10, a11, a12, a20, a21, a22 = a[4], a[5], a[6], a[7], a[8], a[9], a[10], a[11], a[12]
	local bx, by, bz = b[1], b[2], b[3]
	local b00, b01, b02, b10, b11, b12, b20, b21, b22 = b[4], b[5], b[6], b[7], b[8], b[9], b[10], b[11], b[12]
	return {
		ax + a00 * bx + a01 * by + a02 * bz,
		ay + a10 * bx + a11 * by + a12 * bz,
		az + a20 * bx + a21 * by + a22 * bz,
		a00 * b00 + a01 * b10 + a02 * b20,
		a00 * b01 + a01 * b11 + a02 * b21,
		a00 * b02 + a01 * b12 + a02 * b22,
		a10 * b00 + a11 * b10 + a12 * b20,
		a10 * b01 + a11 * b11 + a12 * b21,
		a10 * b02 + a11 * b12 + a12 * b22,
		a20 * b00 + a21 * b10 + a22 * b20,
		a20 * b01 + a21 * b11 + a22 * b21,
		a20 * b02 + a21 * b12 + a22 * b22,
	}
end

function CF.inv(a: CF): CF
	local x, y, z = a[1], a[2], a[3]
	local r00, r01, r02, r10, r11, r12, r20, r21, r22 = a[4], a[5], a[6], a[7], a[8], a[9], a[10], a[11], a[12]
	-- transpose rotation, -R^T p
	return {
		-(r00 * x + r10 * y + r20 * z),
		-(r01 * x + r11 * y + r21 * z),
		-(r02 * x + r12 * y + r22 * z),
		r00,
		r10,
		r20,
		r01,
		r11,
		r21,
		r02,
		r12,
		r22,
	}
end

-- a point in a's space -> world
function CF.point(a: CF, x: number, y: number, z: number): V3
	return {
		a[1] + a[4] * x + a[5] * y + a[6] * z,
		a[2] + a[7] * x + a[8] * y + a[9] * z,
		a[3] + a[10] * x + a[11] * y + a[12] * z,
	}
end

-- a direction in a's space -> world
function CF.vector(a: CF, x: number, y: number, z: number): V3
	return {
		a[4] * x + a[5] * y + a[6] * z,
		a[7] * x + a[8] * y + a[9] * z,
		a[10] * x + a[11] * y + a[12] * z,
	}
end

function CF.pos(a: CF): V3
	return { a[1], a[2], a[3] }
end

function CF.moved(a: CF, x: number, y: number, z: number): CF
	local c = table.clone(a)
	c[1], c[2], c[3] = x, y, z
	return c
end

function CF.translate(x: number, y: number, z: number): CF
	return CF.new(x, y, z)
end

-- vectors
function CF.v(x: number, y: number, z: number): V3
	return { x, y, z }
end
function CF.add(a: V3, b: V3): V3
	return { a[1] + b[1], a[2] + b[2], a[3] + b[3] }
end
function CF.sub(a: V3, b: V3): V3
	return { a[1] - b[1], a[2] - b[2], a[3] - b[3] }
end
function CF.scale(a: V3, k: number): V3
	return { a[1] * k, a[2] * k, a[3] * k }
end
function CF.dot(a: V3, b: V3): number
	return a[1] * b[1] + a[2] * b[2] + a[3] * b[3]
end
function CF.cross(a: V3, b: V3): V3
	return { a[2] * b[3] - a[3] * b[2], a[3] * b[1] - a[1] * b[3], a[1] * b[2] - a[2] * b[1] }
end
function CF.len(a: V3): number
	return math.sqrt(a[1] * a[1] + a[2] * a[2] + a[3] * a[3])
end
function CF.unit(a: V3): V3
	local l = CF.len(a)
	if l < 1e-9 then
		return { 0, 0, -1 }
	end
	return { a[1] / l, a[2] / l, a[3] / l }
end
function CF.lerpv(a: V3, b: V3, k: number): V3
	return { a[1] + (b[1] - a[1]) * k, a[2] + (b[2] - a[2]) * k, a[3] + (b[3] - a[3]) * k }
end

-- a frame at `pos` whose -Z (look) points at `target`; `roll` (radians) turns it round the look
function CF.lookAt(pos: V3, target: V3, roll: number?): CF
	local back = CF.unit(CF.sub(pos, target))
	local up = { 0, 1, 0 }
	if math.abs(back[2]) > 0.999 then
		up = { 0, 0, -1 }
	end
	local right = CF.unit(CF.cross(up, back))
	local up2 = CF.cross(back, right)
	local c = { pos[1], pos[2], pos[3], right[1], up2[1], back[1], right[2], up2[2], back[2], right[3], up2[3], back[3] }
	if roll and roll ~= 0 then
		c = CF.mul(c, CF.angles(0, 0, roll))
	end
	return c
end

-- a frame at `pos` whose X axis points along `dir` (for cylinders / streaks)
function CF.along(pos: V3, dir: V3): CF
	local x = CF.unit(dir)
	local ref = if math.abs(x[2]) < 0.9 then { 0, 1, 0 } else { 1, 0, 0 }
	local z = CF.unit(CF.cross(x, ref))
	local y = CF.cross(z, x)
	return { pos[1], pos[2], pos[3], x[1], y[1], z[1], x[2], y[2], z[2], x[3], y[3], z[3] }
end

-- easing
function CF.clamp01(k: number): number
	return math.clamp(k, 0, 1)
end
function CF.smooth(k: number): number
	k = math.clamp(k, 0, 1)
	return k * k * (3 - 2 * k)
end
function CF.easeOut(k: number, p: number?): number
	k = math.clamp(k, 0, 1)
	return 1 - (1 - k) ^ (p or 3)
end
function CF.easeIn(k: number, p: number?): number
	k = math.clamp(k, 0, 1)
	return k ^ (p or 3)
end
function CF.lerp(a: number, b: number, k: number): number
	return a + (b - a) * k
end

-- deterministic noise / hashing (no Random in some runtimes)
function CF.hash(n: number): number
	local s = math.sin(n * 127.1 + 311.7) * 43758.5453
	return s - math.floor(s)
end
function CF.noise(t: number, seed: number): number
	local i = math.floor(t)
	local f = t - i
	local a, b = CF.hash(i + seed * 17.3), CF.hash(i + 1 + seed * 17.3)
	local u = f * f * (3 - 2 * f)
	return (a + (b - a) * u) * 2 - 1
end

return CF
