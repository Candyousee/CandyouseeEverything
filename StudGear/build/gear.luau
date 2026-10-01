-- Builds the Stud Gear assets (run from the StudGear folder):
--   lune run build/gear.luau           -> assets/tools/*.rbxm, assets/StudGearDemo.rbxm
--   lune run build/gear.luau preview F -> also the coils + displays as render JSON (Blender)

local fs = require("@lune/fs")
local process = require("@lune/process")
local roblox = require("@lune/roblox")
local serde = require("@lune/serde")
local Instance, CFrame, Vector3, Color3, Enum = roblox.Instance, roblox.CFrame, roblox.Vector3, roblox.Color3, roblox.Enum

local Config = require("../src/shared/StudGear/Config")

local function rgb(t)
	return Color3.fromRGB(t[1], t[2], t[3])
end
local function lighten(t, k)
	return { t[1] + (255 - t[1]) * k, t[2] + (255 - t[2]) * k, t[3] + (255 - t[3]) * k }
end
-- a CFrame at `pos` whose X axis (a cylinder's length) points along `dir`
-- (Lune's CFrame.lookAt is unreliable, so build the basis by hand)
local function along(pos, dir)
	local x = dir.Unit
	local ref = if math.abs(x.Y) < 0.9 then Vector3.new(0, 1, 0) else Vector3.new(1, 0, 0)
	local z = x:Cross(ref).Unit
	local y = z:Cross(x).Unit
	return CFrame.fromMatrix(pos, x, y, z)
end

local function darken(t, k)
	return { t[1] * (1 - k), t[2] * (1 - k), t[3] * (1 - k) }
end
local function mix(a, b, k)
	return { a[1] + (b[1] - a[1]) * k, a[2] + (b[2] - a[2]) * k, a[3] + (b[3] - a[3]) * k }
end
local function hsv(h, s, v)
	local c = Color3.fromHSV(h % 1, s, v)
	return { math.round(c.R * 255), math.round(c.G * 255), math.round(c.B * 255) }
end

-- A classic coil in handle space: a rubber grip in your fist, a smooth shiny spring standing
-- straight up out of it around a glowing core, and a themed top so every coil reads at a
-- glance (+Y is up once the tool's Grip is applied).
-- {name, size, cf, color, neon?, shape?, shine?, glass?, tipFx?}
local function coilParts(gear)
	local parts = {}
	local function add(name, size, cf, color, extra)
		local p = { name = name, size = size, cf = cf, color = color }
		for k, v in extra or {} do
			p[k] = v
		end
		table.insert(parts, p)
		return p
	end
	local UP = CFrame.Angles(0, 0, math.rad(90)) -- a cylinder's axis is X: turn it upright
	local grip, metal, darkMetal = { 52, 54, 64 }, { 190, 195, 205 }, { 120, 124, 136 }
	local color = gear.Color
	local accent = gear.Accent or color
	local glow = if gear.Rainbow then { 255, 255, 255 } else lighten(color, 0.35)

	-- grip: rubber with ridges, a metal pommel, an accent stripe and a flared guard
	add("Grip", { 1.1, 0.42, 0.42 }, CFrame.new(0, 0, 0) * UP, grip, { shape = "cylinder" })
	for k = -2, 2 do
		add("Ridge" .. k, { 0.07, 0.46, 0.46 }, CFrame.new(0, k * 0.17 - 0.04, 0) * UP, { 34, 35, 42 }, { shape = "cylinder" })
	end
	add("Pommel", { 0.16, 0.52, 0.52 }, CFrame.new(0, -0.6, 0) * UP, metal, { shape = "cylinder", shine = true })
	add("PommelCap", { 0.24, 0.24, 0.24 }, CFrame.new(0, -0.7, 0), darkMetal, { shape = "ball", shine = true })
	add("Stripe", { 0.08, 0.47, 0.47 }, CFrame.new(0, 0.42, 0) * UP, if gear.Rainbow then { 255, 90, 90 } else color, { shape = "cylinder", neon = true })
	add("Guard", { 0.12, 0.78, 0.78 }, CFrame.new(0, 0.54, 0) * UP, darkMetal, { shape = "cylinder", shine = true })
	add("Base", { 0.16, 1.08, 1.08 }, CFrame.new(0, 0.66, 0) * UP, metal, { shape = "cylinder", shine = true })
	add("BaseRim", { 0.06, 1.14, 1.14 }, CFrame.new(0, 0.74, 0) * UP, accent, { shape = "cylinder" })

	-- spring: a round tube on a helix, shading darker at the bottom to lighter at the top
	local TURNS, PER, R, TUBE = 6, 18, 0.43, 0.17
	local y0, y1 = 0.8, 3.05
	local n = TURNS * PER
	local rise = (y1 - y0) / n
	local step = 2 * math.pi * R / PER
	local pitch = math.atan2(rise, step)
	local len = math.sqrt(step * step + rise * rise) * 1.12
	for i = 0, n - 1 do
		local a = (i + 0.5) / PER * 2 * math.pi
		local y = y0 + (i + 0.5) * rise
		local k = i / (n - 1)
		local c
		if gear.Rainbow then
			c = hsv(k * 0.85, 0.8, 1)
		elseif gear.Name == "Fusion Coil" then
			c = if math.floor(i / PER) % 2 == 0 then color else accent
		else
			c = mix(darken(color, 0.22), lighten(color, 0.18), k)
		end
		local cf = CFrame.new(R * math.cos(a), y, R * math.sin(a)) * CFrame.Angles(0, -a - math.pi / 2, 0) * CFrame.Angles(0, 0, pitch)
		add("Spring" .. i, { len, TUBE, TUBE }, cf, c, { shape = "cylinder", shine = true })
	end
	-- glowing core inside the spring
	add("Core", { y1 - y0, 0.3, 0.3 }, CFrame.new(0, (y0 + y1) / 2, 0) * UP, glow, { shape = "cylinder", neon = true, glass = 0.35 })
	add("TopRim", { 0.06, 1.14, 1.14 }, CFrame.new(0, y1 + 0.04, 0) * UP, accent, { shape = "cylinder" })
	add("Top", { 0.16, 1.02, 1.02 }, CFrame.new(0, y1 + 0.13, 0) * UP, metal, { shape = "cylinder", shine = true })
	add("Socket", { 0.14, 0.5, 0.5 }, CFrame.new(0, y1 + 0.27, 0) * UP, darkMetal, { shape = "cylinder", shine = true })

	-- themed top
	local top = y1 + 0.34
	local function orb(name, y, d, c)
		return add(name, { d, d, d }, CFrame.new(0, y, 0), c, { shape = "ball", neon = true })
	end
	if gear.Rainbow then
		-- a sparkling star: six glowing points
		local tip = orb("Tip", top + 0.3, 0.3, { 255, 255, 255 })
		tip.tipFx = true
		local pts = { { 0, 0, 0 }, { 0, 0, 90 }, { 90, 0, 0 }, { 0, 45, 45 }, { 0, -45, 45 } }
		for k, r in pts do
			add("Ray" .. k, { 0.1, 0.78, 0.1 }, CFrame.new(0, top + 0.3, 0) * CFrame.Angles(math.rad(r[1]), math.rad(r[2]), math.rad(r[3])), hsv(k / #pts, 0.6, 1), { neon = true })
		end
	elseif gear.Regen then
		-- a glowing heal cross
		local tip = add("Tip", { 0.18, 0.62, 0.18 }, CFrame.new(0, top + 0.34, 0), { 120, 255, 150 }, { neon = true })
		tip.tipFx = true
		add("CrossX", { 0.62, 0.18, 0.18 }, CFrame.new(0, top + 0.38, 0), { 120, 255, 150 }, { neon = true })
		add("CrossZ", { 0.18, 0.18, 0.62 }, CFrame.new(0, top + 0.38, 0), { 120, 255, 150 }, { neon = true })
	elseif gear.AirJumps then
		-- two jump orbs, one above the other
		orb("Tip", top + 0.16, 0.3, glow).tipFx = true
		orb("Orb2", top + 0.5, 0.22, accent)
		add("OrbStem", { 0.4, 0.06, 0.06 }, CFrame.new(0, top + 0.3, 0) * UP, darkMetal, { shape = "cylinder" })
	elseif gear.Jump then
		-- an up arrow
		local tip = add("Tip", { 0.16, 0.42, 0.16 }, CFrame.new(0, top + 0.21, 0), glow, { neon = true })
		tip.tipFx = true
		-- arrowhead: two arms meeting at the top of the stem
		for side = -1, 1, 2 do
			add("Arrow" .. side, { 0.14, 0.38, 0.16 }, CFrame.new(side * 0.12, top + 0.3, 0) * CFrame.Angles(0, 0, side * math.rad(45)), glow, { neon = true })
		end
	elseif gear.Speed and not gear.Gravity then
		-- a glowing lightning bolt, seen from the front and the back
		local pts = { { 0.15, 0.78 }, { -0.1, 0.4 }, { 0.1, 0.4 }, { -0.15, 0.02 } }
		for k = 1, 3 do
			local a0 = Vector3.new(pts[k][1], top + pts[k][2], 0)
			local a1 = Vector3.new(pts[k + 1][1], top + pts[k + 1][2], 0)
			local seg = add("Bolt" .. k, { (a1 - a0).Magnitude + 0.1, if k == 2 then 0.11 else 0.13, if k == 2 then 0.11 else 0.13 }, along((a0 + a1) / 2, a1 - a0), { 255, 235, 120 }, { neon = true })
			seg.tipFx = k == 2
		end
	else
		orb("Tip", top + 0.18, 0.34, glow).tipFx = true
		if gear.Gravity then
			-- a ring floating round the tip
			local RING, SEG = 0.42, 14
			for k = 0, SEG - 1 do
				local a = (k + 0.5) / SEG * 2 * math.pi
				local tilt = CFrame.Angles(math.rad(18), 0, 0)
				add("Ring" .. k, { 2 * math.pi * RING / SEG * 1.1, 0.06, 0.06 }, CFrame.new(0, top + 0.18, 0) * tilt * CFrame.new(RING * math.cos(a), 0, RING * math.sin(a)) * CFrame.Angles(0, -a - math.pi / 2, 0), if gear.Speed then accent else glow, { shape = "cylinder", neon = true })
			end
		end
	end
	return parts
end

-- shared little builder for the other looks
local function parts()
	local list = {}
	local function add(name, size, cf, color, extra)
		local p = { name = name, size = size, cf = cf, color = color }
		for k, v in extra or {} do
			p[k] = v
		end
		table.insert(list, p)
		return p
	end
	return list, add
end

-- A classic balloon: a shiny round balloon on a curly ribbon, with a tied knot and a soft
-- highlight.
local function balloonParts(gear)
	local list, add = parts()
	local white = { 245, 245, 245 }
	add("Grip", { 0.26, 0.26, 0.26 }, CFrame.new(0, 0, 0), white, { shape = "ball" })
	-- curly ribbon: a gentle helix from the hand up to the knot
	local N, R = 26, 0.12
	local y0, y1 = 0.1, 3.42
	local prev = Vector3.new(0, y0, 0)
	for i = 1, N do
		local k = i / N
		local a = k * 5 * math.pi
		local r = R * math.sin(math.pi * k) -- straight at both ends
		local pt = Vector3.new(r * math.cos(a), y0 + (y1 - y0) * k, r * math.sin(a))
		local mid = (prev + pt) / 2
		local d = pt - prev
		add("Ribbon" .. i, { d.Magnitude * 1.15, 0.05, 0.05 }, along(mid, d), white, { shape = "cylinder" })
		prev = pt
	end
	add("Tie", { 0.16, 0.16, 0.16 }, CFrame.new(0, 3.45, 0), gear.Color, { shape = "ball" })
	add("Knot", { 0.32, 0.26, 0.32 }, CFrame.new(0, 3.6, 0), darken(gear.Color, 0.12), { shape = "sphere" })
	add("Neck", { 0.5, 0.36, 0.5 }, CFrame.new(0, 3.8, 0), gear.Color, { shape = "sphere", shine = true })
	add("Balloon", { 2.3, 2.7, 2.3 }, CFrame.new(0, 5.15, 0), gear.Color, { shape = "sphere", shine = true })
	add("Shine", { 0.42, 0.72, 0.3 }, CFrame.new(-0.55, 5.75, -0.96) * CFrame.Angles(0, math.rad(-30), math.rad(-25)), lighten(gear.Color, 0.75), { shape = "sphere" })
	add("Glint", { 0.16, 0.16, 0.12 }, CFrame.new(-0.78, 6.25, -0.78) * CFrame.Angles(0, math.rad(-40), 0), { 255, 255, 255 }, { shape = "sphere" })
	return list
end

-- Jetpack: nothing in your hand (an invisible handle); the pack itself is worn (jetpackWear).
local function jetpackParts(_gear)
	local list, add = parts()
	add("Grip", { 0.2, 0.2, 0.2 }, CFrame.new(0, 0, 0), { 46, 48, 62 }, { invisible = true })
	return list
end

-- The pack on your back. WearRoot sits on the middle of the back; +Z points away from you.
local function jetpackWear(gear)
	local list, add = parts()
	local dark, metal, accent = { 46, 48, 62 }, gear.Color, gear.Accent
	local UP = CFrame.Angles(0, 0, math.rad(90))
	add("WearRoot", { 0.2, 0.2, 0.2 }, CFrame.new(0, 0, 0), dark, { invisible = true })
	add("Plate", { 1.75, 1.9, 0.26 }, CFrame.new(0, 0, 0.16), dark)
	-- shoulder straps over the top of the torso
	for side = -1, 1, 2 do
		add("Strap" .. side, { 0.3, 0.12, 1.15 }, CFrame.new(side * 0.55, 0.88, -0.38), { 35, 36, 44 })
		add("Buckle" .. side, { 0.34, 0.16, 0.2 }, CFrame.new(side * 0.55, 0.88, -0.1), metal, { shine = true })
	end
	-- glowing reactor between the tanks
	add("Reactor", { 0.42, 0.62, 0.62 }, CFrame.new(0, 0.05, 0.5) * CFrame.Angles(0, math.rad(90), 0), dark, { shape = "cylinder" })
	add("ReactorGlow", { 0.44, 0.42, 0.42 }, CFrame.new(0, 0.05, 0.51) * CFrame.Angles(0, math.rad(90), 0), accent, { shape = "cylinder", neon = true })
	for side = -1, 1, 2 do
		local x = side * 0.5
		add("Tank" .. side, { 1.8, 0.8, 0.8 }, CFrame.new(x, 0.05, 0.72) * UP, metal, { shape = "cylinder", shine = true })
		add("Band" .. side, { 0.16, 0.86, 0.86 }, CFrame.new(x, 0.5, 0.72) * UP, accent, { shape = "cylinder" })
		add("Band2" .. side, { 0.1, 0.84, 0.84 }, CFrame.new(x, -0.35, 0.72) * UP, dark, { shape = "cylinder" })
		add("Dome" .. side, { 0.8, 0.8, 0.8 }, CFrame.new(x, 0.95, 0.72), metal, { shape = "ball", shine = true })
		add("Valve" .. side, { 0.2, 0.2, 0.2 }, CFrame.new(x, 1.35, 0.72), accent, { shape = "ball", neon = true })
		add("Fin" .. side, { 0.1, 0.85, 0.6 }, CFrame.new(x + side * 0.46, -0.5, 0.78) * CFrame.Angles(0, 0, side * math.rad(-8)), accent, { shine = true })
		-- bell-shaped nozzle: a throat and a wider bell (flames come out of the bell)
		add("Throat" .. side, { 0.2, 0.46, 0.46 }, CFrame.new(x, -0.95, 0.72) * UP, dark, { shape = "cylinder" })
		local nozzle = add("Nozzle" .. side, { 0.34, 0.66, 0.66 }, CFrame.new(x, -1.2, 0.72) * UP, darken(metal, 0.35), { shape = "cylinder", shine = true })
		nozzle.flame = true
		add("NozzleGlow" .. side, { 0.02, 0.5, 0.5 }, CFrame.new(x, -1.37, 0.72) * UP, { 255, 140, 50 }, { shape = "cylinder", neon = true })
	end
	return list
end

-- Grapple gun: grip in your hand, barrel pointing forward (-Z), a reel wound with rope,
-- a scope, glowing trim and a three-claw hook at the front (the rope fires from its Muzzle).
local function grappleParts(gear)
	local list, add = parts()
	local dark, mid = { 46, 48, 62 }, { 80, 84, 100 }
	local color, accent = gear.Color, gear.Accent
	local FWD = CFrame.Angles(0, math.rad(90), 0) -- cylinder axis along Z
	local SIDE = CFrame.new() -- cylinder axis along X
	add("Grip", { 0.4, 1.0, 0.52 }, CFrame.new(0, 0, 0.05) * CFrame.Angles(math.rad(-12), 0, 0), dark)
	for k = 0, 2 do
		add("GripRidge" .. k, { 0.44, 0.06, 0.4 }, CFrame.new(0, -0.3 + k * 0.25, 0.08) * CFrame.Angles(math.rad(-12), 0, 0), { 34, 35, 42 })
	end
	add("Trigger", { 0.12, 0.3, 0.12 }, CFrame.new(0, 0.32, -0.38) * CFrame.Angles(math.rad(15), 0, 0), accent)
	add("TriggerGuard", { 0.1, 0.08, 0.5 }, CFrame.new(0, 0.12, -0.36), mid)
	add("Body", { 0.6, 0.62, 1.8 }, CFrame.new(0, 0.78, -0.5), color, { shine = true })
	add("BodyStripe", { 0.62, 0.1, 1.6 }, CFrame.new(0, 0.82, -0.5), accent, { neon = true })
	add("Back", { 0.5, 0.5, 0.2 }, CFrame.new(0, 0.78, 0.45), dark)
	-- reel with rope wound on it (side-on)
	add("Reel", { 0.56, 0.78, 0.78 }, CFrame.new(0, 0.78, 0.22) * SIDE, mid, { shape = "cylinder", shine = true })
	add("Rope", { 0.6, 0.62, 0.62 }, CFrame.new(0, 0.78, 0.22) * SIDE, { 130, 100, 70 }, { shape = "cylinder" })
	for side = -1, 1, 2 do
		add("ReelCap" .. side, { 0.06, 0.84, 0.84 }, CFrame.new(side * 0.32, 0.78, 0.22) * SIDE, accent, { shape = "cylinder" })
	end
	-- scope on top
	add("ScopeMount", { 0.16, 0.16, 0.5 }, CFrame.new(0, 1.15, -0.55), dark)
	add("Scope", { 0.8, 0.26, 0.26 }, CFrame.new(0, 1.3, -0.55) * FWD, dark, { shape = "cylinder" })
	add("Lens", { 0.04, 0.2, 0.2 }, CFrame.new(0, 1.3, -0.96) * FWD, { 120, 220, 255 }, { shape = "cylinder", neon = true })
	-- barrel with rings
	add("Barrel", { 1.1, 0.4, 0.4 }, CFrame.new(0, 0.82, -1.9) * FWD, dark, { shape = "cylinder", shine = true })
	for k = 0, 1 do
		add("BarrelRing" .. k, { 0.08, 0.46, 0.46 }, CFrame.new(0, 0.82, -1.55 - k * 0.5) * FWD, accent, { shape = "cylinder" })
	end
	-- hook head
	local hook = add("Hook", { 0.3, 0.3, 0.3 }, CFrame.new(0, 0.82, -2.55), accent, { shape = "ball", neon = true })
	hook.muzzle = true
	for k = 0, 2 do
		local a = k / 3 * 2 * math.pi + math.pi / 2
		local dir = Vector3.new(math.cos(a), math.sin(a), 0)
		local base = Vector3.new(0, 0.82, -2.62)
		-- each claw reaches out and forward, then its tip curls back in
		local a0, a1 = base + dir * 0.12, base + dir * 0.34 + Vector3.new(0, 0, -0.3)
		local a2 = base + dir * 0.2 + Vector3.new(0, 0, -0.5)
		add("Claw" .. k, { (a1 - a0).Magnitude + 0.06, 0.1, 0.1 }, along((a0 + a1) / 2, a1 - a0), accent, { shine = true })
		add("ClawTip" .. k, { (a2 - a1).Magnitude + 0.06, 0.1, 0.1 }, along((a1 + a2) / 2, a2 - a1), accent, { shine = true })
	end
	return list
end

local function gearParts(gear)
	local look = gear.Look or "coil"
	if look == "balloon" then
		return balloonParts(gear)
	elseif look == "jetpack" then
		return jetpackParts(gear)
	elseif look == "grapple" then
		return grappleParts(gear)
	end
	return coilParts(gear)
end

-- what the display stand shows, and how big / how high off the stand
local function displayParts(gear)
	local look = gear.Look or "coil"
	if look == "jetpack" then
		return jetpackWear(gear), 1.25, 1.4
	elseif look == "balloon" then
		return balloonParts(gear), 0.95, 0.4
	elseif look == "grapple" then
		return grappleParts(gear), 1.5, 0.6
	end
	return coilParts(gear), 1.7, 0.5
end

local function makePart(p, anchored)
	local part = Instance.new("Part")
	part.Name = p.name
	part.Size = Vector3.new(p.size[1], p.size[2], p.size[3])
	part.CFrame = p.cf
	part.Color = rgb(p.color)
	part.Material = if p.neon then Enum.Material.Neon else Enum.Material.SmoothPlastic
	part.TopSurface = Enum.SurfaceType.Smooth
	part.BottomSurface = Enum.SurfaceType.Smooth
	part.Anchored = anchored
	part.CanCollide = false
	part.CanTouch = false
	part.CanQuery = false
	part.Massless = not anchored
	part.CastShadow = true
	if p.shape == "cylinder" then
		part.Shape = Enum.PartType.Cylinder
	elseif p.shape == "ball" then
		part.Shape = Enum.PartType.Ball
	elseif p.shape == "sphere" then
		local mesh = Instance.new("SpecialMesh") -- a ball stretched to fill the part's box
		mesh.MeshType = Enum.MeshType.Sphere
		mesh.Parent = part
	end
	if p.shine then
		part.Reflectance = 0.18
	end
	if p.glass then
		part.Transparency = p.glass
	end
	if p.tipFx then
		-- a soft glow and a few drifting sparkles in the gear's colour
		local c = Color3.fromRGB(p.color[1], p.color[2], p.color[3])
		local light = Instance.new("PointLight")
		light.Color = c
		light.Range = 6
		light.Brightness = 1.2
		light.Shadows = false
		light.Parent = part
		local sparkle = Instance.new("ParticleEmitter")
		sparkle.Name = "Sparkle"
		sparkle.Texture = "rbxasset://textures/particles/sparkles_main.dds"
		sparkle.Rate = 6
		sparkle.Lifetime = roblox.NumberRange.new(0.6, 1.0)
		sparkle.Speed = roblox.NumberRange.new(0.6, 1.4)
		sparkle.SpreadAngle = roblox.Vector2.new(180, 180)
		sparkle.LightEmission = 1
		sparkle.Color = roblox.ColorSequence.new(c)
		sparkle.Size = roblox.NumberSequence.new({ roblox.NumberSequenceKeypoint.new(0, 0), roblox.NumberSequenceKeypoint.new(0.3, 0.22), roblox.NumberSequenceKeypoint.new(1, 0) })
		sparkle.Parent = part
	end
	if p.invisible then
		part.Transparency = 1
	end
	if p.muzzle then
		local a = Instance.new("Attachment")
		a.Name = "Muzzle"
		a.Parent = part
	end
	return part
end

local function makeTool(gear)
	local tool = Instance.new("Tool")
	tool.Name = gear.Name
	tool.RequiresHandle = true
	tool.CanBeDropped = false
	tool.ManualActivationOnly = gear.Grapple == nil -- only the grapple uses clicks
	-- built with +Y up and -Z forward; this Grip makes the hand hold it that way round
	tool.Grip = CFrame.Angles(math.pi, 0, 0)
	local bits = {}
	if gear.Speed then
		table.insert(bits, ("%d%% faster"):format(math.round((gear.Speed - 1) * 100)))
	end
	if gear.Gravity then
		table.insert(bits, "low gravity")
	end
	if gear.Jump then
		table.insert(bits, ("%d%% higher jumps"):format(math.round((gear.Jump - 1) * 100)))
	end
	if gear.AirJumps then
		table.insert(bits, if gear.AirJumps == 1 then "jump again in mid-air" else ("%d mid-air jumps"):format(gear.AirJumps))
	end
	if gear.MaxFall then
		table.insert(bits, "float down slowly")
	end
	if gear.Regen then
		table.insert(bits, ("heals %d HP/s"):format(gear.Regen))
	end
	if gear.Jetpack then
		table.insert(bits, "hold Jump to fly")
	end
	if gear.Grapple then
		table.insert(bits, "click a surface to swing to it")
	end
	tool.ToolTip = table.concat(bits, ", ")
	tool:SetAttribute("StudGear", gear.Name)
	local handle
	for _, p in gearParts(gear) do
		local part = makePart(p, false)
		if p.name == "Grip" then
			part.Name = "Handle"
			part.Massless = false -- a tool needs a little mass in its handle
			part.CanTouch = true -- lets a dropped tool be picked back up
			handle = part
		end
		part.Parent = tool
	end
	for _, part in tool:GetChildren() do
		if part ~= handle then
			local w = Instance.new("WeldConstraint")
			w.Part0 = handle
			w.Part1 = part
			w.Parent = part
		end
	end
	return tool
end

-- worn models (the jetpack's pack), with flames the scripts switch on while flying
local function makeWear(gear)
	local model = Instance.new("Model")
	model.Name = gear.Name
	local root
	for _, p in jetpackWear(gear) do
		local part = makePart(p, false)
		part.Parent = model
		if p.name == "WearRoot" then
			root = part
		end
		if p.flame then
			local at = Instance.new("Attachment")
			at.Name = "Flame"
			at.Position = Vector3.new(-0.2, 0, 0) -- the cylinder's axis is X: -X is its bottom
			at.Orientation = Vector3.new(0, 0, 90)
			at.Parent = part
			local fire = Instance.new("ParticleEmitter")
			fire.Name = "Flame"
			fire.Texture = "rbxasset://textures/particles/fire_main.dds"
			fire.Enabled = false
			fire.Rate = 70
			fire.Lifetime = roblox.NumberRange.new(0.18, 0.32)
			fire.Speed = roblox.NumberRange.new(10, 14)
			fire.SpreadAngle = roblox.Vector2.new(8, 8)
			fire.LightEmission = 1
			fire.EmissionDirection = Enum.NormalId.Bottom
			fire.Size = roblox.NumberSequence.new({ roblox.NumberSequenceKeypoint.new(0, 0.55), roblox.NumberSequenceKeypoint.new(1, 0.1) })
			fire.Color = roblox.ColorSequence.new(Color3.fromRGB(255, 230, 120), Color3.fromRGB(255, 90, 30))
			fire.Parent = at
			local light = Instance.new("PointLight")
			light.Name = "Glow"
			light.Enabled = false
			light.Color = Color3.fromRGB(255, 150, 60)
			light.Range = 8
			light.Brightness = 2
			light.Parent = at
		end
	end
	for _, part in model:GetChildren() do
		if part ~= root then
			local w = Instance.new("WeldConstraint")
			w.Part0 = root
			w.Part1 = part
			w.Parent = part
		end
	end
	model.PrimaryPart = root
	return model
end

for _, dir in { "assets/tools", "assets/wearables" } do
	if fs.isDir(dir) then
		fs.removeDir(dir)
	end
	fs.writeDir(dir)
end
local tools = {}
for _, gear in Config.Gear do
	local t = makeTool(gear)
	tools[gear.Name] = t
	fs.writeFile(`assets/tools/{gear.Name}.rbxm`, roblox.serializeModel({ t }))
	if gear.Jetpack then
		fs.writeFile(`assets/wearables/{gear.Name}.rbxm`, roblox.serializeModel({ makeWear(gear) }))
	end
end

---------------------------------------------------------------------------
-- Demo world: floor, spawn, a display stand per gear, and a test course
---------------------------------------------------------------------------
local function block(name, size, cf, color, studs, material)
	local p = Instance.new("Part")
	p.Name = name
	p.Size = size
	p.CFrame = cf
	p.Color = rgb(color)
	p.Material = material or Enum.Material.Plastic
	p.TopSurface = if studs then Enum.SurfaceType.Studs else Enum.SurfaceType.Smooth
	p.BottomSurface = Enum.SurfaceType.Smooth
	p.Anchored = true
	return p
end

local function sign(parent, text, cf, color)
	local board = block("Sign", Vector3.new(10, 3, 0.4), cf, { 40, 42, 60 }, false, Enum.Material.SmoothPlastic)
	local gui = Instance.new("SurfaceGui")
	gui.Face = Enum.NormalId.Back -- faces the spawn (+Z)
	gui.PixelsPerStud = 40
	gui.LightInfluence = 0
	local l = Instance.new("TextLabel")
	l.BackgroundTransparency = 1
	l.Size = roblox.UDim2.fromScale(1, 1)
	l.FontFace = roblox.Font.new("rbxasset://fonts/families/FredokaOne.json")
	l.TextScaled = true
	l.TextColor3 = rgb(color)
	l.Text = text
	l.Parent = gui
	gui.Parent = board
	board.Parent = parent
	local pos = cf.Position
	block("SignPost", Vector3.new(0.6, pos.Y - 1.5, 0.6), CFrame.new(pos.X, (pos.Y - 1.5) / 2, pos.Z - 0.4), { 90, 70, 50 }, false).Parent = parent
	return board
end

local demo = Instance.new("Folder")
demo.Name = "StudGearDemo"
block("Floor", Vector3.new(220, 1, 220), CFrame.new(0, -0.5, 0), { 75, 151, 75 }, true).Parent = demo
local spawn = Instance.new("SpawnLocation")
spawn.Name = "Spawn"
spawn.Size = Vector3.new(8, 1, 8)
spawn.CFrame = CFrame.new(0, 0.5, 24)
spawn.Anchored = true
spawn.Neutral = true
spawn.Duration = 0
spawn.TopSurface = Enum.SurfaceType.Studs
spawn.Parent = demo

local displays = Instance.new("Folder")
displays.Name = "GearDisplays"
displays.Parent = demo
local n = #Config.Gear
local displayData = {}
for i, gear in Config.Gear do
	-- two rows of five, facing the spawn (+Z)
	local row, col = math.floor((i - 1) / 5), (i - 1) % 5
	local perRow = math.min(5, n - row * 5)
	local x = (col - (perRow - 1) / 2) * 10
	local cf = CFrame.new(x, 0, 4 - row * 11) * CFrame.Angles(0, math.pi, 0)
	local stand = Instance.new("Model")
	stand.Name = gear.Name
	local function disc(name, d, h, y, color, neon)
		local p = block(name, Vector3.new(h, d, d), cf * CFrame.new(0, y, 0) * CFrame.Angles(0, 0, math.rad(90)), color, false, if neon then Enum.Material.Neon else Enum.Material.SmoothPlastic)
		p.Shape = Enum.PartType.Cylinder
		return p
	end
	disc("Base", 6.4, 1, 0.5, { 88, 86, 96 }).Parent = stand
	disc("Rim", 5.8, 0.3, 1.1, if gear.Rainbow then { 255, 255, 255 } else gear.Color, true).Parent = stand
	local top = disc("Top", 5.4, 0.5, 1.35, { 52, 54, 76 })
	top.Parent = stand
	-- the coil, bigger, floating over the stand (the client spins it)
	local coil = Instance.new("Model")
	coil.Name = "Coil"
	local shown, SCALE, lift = displayParts(gear)
	local at = cf * CFrame.new(0, 2.3 + lift * SCALE, 0)
	local pivot = block("Pivot", Vector3.new(0.2, 0.2, 0.2), at, { 0, 0, 0 }, false)
	pivot.Transparency = 1
	pivot.CanCollide = false
	pivot.Parent = coil
	local list = {}
	for _, p in shown do
		if p.invisible then
			continue
		end
		local c = p.cf
		local q = table.clone(p)
		q.cf = at * CFrame.new(c.Position * SCALE) * (c - c.Position)
		q.size = { p.size[1] * SCALE, p.size[2] * SCALE, p.size[3] * SCALE }
		makePart(q, true).Parent = coil
		table.insert(list, q)
	end
	coil.PrimaryPart = pivot
	coil.Parent = stand
	stand.PrimaryPart = top
	stand:SetAttribute("StudGearDisplay", gear.Name)
	stand.ModelStreamingMode = Enum.ModelStreamingMode.Atomic
	stand:AddTag("StudGearDisplay")
	stand.Parent = displays
	table.insert(displayData, { name = gear.Name, parts = list, stand = stand })
end

-- test course behind the stands: one challenge per effect
local course = Instance.new("Folder")
course.Name = "TestCourse"
course.Parent = demo
local GREY, WOOD = { 163, 162, 165 }, { 200, 160, 110 }
-- SPEED: a gap you can only clear running fast (normal jump carries ~8 studs, Speed Coil ~14)
sign(course, "SPEED COIL: clear the gap", CFrame.new(-23, 4.5, -4), { 255, 120, 120 })
block("SpeedStart", Vector3.new(10, 6, 24), CFrame.new(-34, 3, -24), GREY, true).Parent = course
block("SpeedRamp", Vector3.new(10, 1, 12), CFrame.new(-34, 2.6, -6.5) * CFrame.Angles(math.rad(27), 0, 0), GREY, true).Parent = course
block("SpeedLand", Vector3.new(10, 6, 14), CFrame.new(-34, 3, -55), GREY, true).Parent = course
block("SpeedGoal", Vector3.new(4, 0.4, 4), CFrame.new(-34, 6.2, -58), { 255, 90, 90 }, false, Enum.Material.Neon).Parent = course
-- JUMP: steps 10 studs apart in height (normal jump ~7, Jump Coil ~13)
sign(course, "JUMP / DOUBLE JUMP: climb the steps", CFrame.new(0, 4.5, -12), { 120, 255, 140 })
for k = 1, 4 do
	block("Step" .. k, Vector3.new(8, 10 * k, 8), CFrame.new(-6 + 4 * k, 5 * k, -16 - 8 * k), WOOD, true).Parent = course
end
block("JumpGoal", Vector3.new(4, 0.4, 4), CFrame.new(10, 40.2, -48), { 90, 255, 120 }, false, Enum.Material.Neon).Parent = course
-- GRAVITY: a pillar too tall for anything but low gravity (~21 studs with the Gravity Coil)
sign(course, "GRAVITY COIL: reach the top", CFrame.new(34, 4.5, -12), { 170, 140, 255 })
block("GravityPillar", Vector3.new(10, 18, 10), CFrame.new(34, 9, -24), WOOD, true).Parent = course
block("GravityGoal", Vector3.new(4, 0.4, 4), CFrame.new(34, 18.2, -24), { 160, 110, 255 }, false, Enum.Material.Neon).Parent = course
-- BALLOON: float off the top step to a platform far below (falling normally covers ~9 studs)
sign(course, "BALLOON: float from the top step to the far platform", CFrame.new(20, 4.5, -30), { 255, 130, 140 })
block("BalloonLand", Vector3.new(16, 12, 16), CFrame.new(10, 6, -96), GREY, true).Parent = course
block("BalloonGoal", Vector3.new(4, 0.4, 4), CFrame.new(10, 12.2, -96), { 255, 90, 110 }, false, Enum.Material.Neon).Parent = course
-- JETPACK / GRAPPLE: a floating island 34 studs up
sign(course, "JETPACK or GRAPPLE HOOK: reach the sky island", CFrame.new(-46, 4.5, -40), { 255, 200, 90 })
block("SkyIsland", Vector3.new(16, 1.5, 16), CFrame.new(-34, 34, -96), WOOD, true).Parent = course
block("SkyGoal", Vector3.new(4, 0.4, 4), CFrame.new(-34, 34.95, -96), { 255, 200, 60 }, false, Enum.Material.Neon).Parent = course
-- leave room in front for the two rows of stands
for _, d in course:GetDescendants() do
	if d:IsA("BasePart") then
		d.CFrame = CFrame.new(0, 0, -12) * d.CFrame
	end
end

fs.writeFile("assets/StudGearDemo.rbxm", roblox.serializeModel({ demo }))
print(("[gear] %d tools -> assets/tools, demo world -> assets/StudGearDemo.rbxm"):format(n))

-- render data: each coil in tool space, and the whole demo world as placed
if process.args[1] == "preview" then
	local function out(p, cf)
		local comps = { cf:GetComponents() }
		return { name = p.name, class = "Part", size = p.size, color = p.color, neon = p.neon == true, studs = false, shape = p.shape, frame = comps }
	end
	local data = { coils = {}, world = {} }
	for _, gear in Config.Gear do
		local list = {}
		for _, p in gearParts(gear) do
			table.insert(list, out(p, p.cf))
		end
		data.coils[gear.Name] = list
		if gear.Jetpack then
			local wear = {}
			for _, p in jetpackWear(gear) do
				if not p.invisible then
					table.insert(wear, out(p, p.cf))
				end
			end
			data.coils[gear.Name .. " (worn)"] = wear
		end
	end
	for _, d in demo:GetDescendants() do
		if d:IsA("BasePart") and d.Transparency < 1 then
			local shape = if d:IsA("Part") and d.Shape == Enum.PartType.Cylinder then "cylinder" else nil
			table.insert(data.world, {
				name = d.Name,
				class = d.ClassName,
				size = { d.Size.X, d.Size.Y, d.Size.Z },
				color = { math.round(d.Color.R * 255), math.round(d.Color.G * 255), math.round(d.Color.B * 255) },
				neon = d.Material == Enum.Material.Neon,
				studs = false,
				shape = shape,
				frame = { d.CFrame:GetComponents() },
			})
		end
	end
	fs.writeFile(process.args[2], serde.encode("json", data))
	print("[gear] preview data -> " .. process.args[2])
end
