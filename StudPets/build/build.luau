-- Offline build for Stud Pets (run from the StudPets folder):
--   lune run build/build.luau              -> assets/*.rbxm + QA report
--   lune run build/build.luau preview F    -> also dump per-frame part transforms to F (for Blender renders)
--
-- Uses the same animation modules the game runs, so what the QA and previews
-- check is exactly what plays in Roblox.

local fs = require("@lune/fs")
local serde = require("@lune/serde")
local process = require("@lune/process")
local roblox = require("@lune/roblox")

local Instance, CFrame, Vector3, Color3, Enum = roblox.Instance, roblox.CFrame, roblox.Vector3, roblox.Color3, roblox.Enum

local AnimLib = require("../src/shared/StudPets/AnimLib")
local Quadruped = require("../src/shared/StudPets/QuadrupedAnims")(AnimLib)
local PLANS = {
	Quadruped = Quadruped,
	Flyer = require("../src/shared/StudPets/FlyerAnims")(AnimLib, Quadruped),
	Swimmer = require("../src/shared/StudPets/SwimmerAnims")(AnimLib, Quadruped),
	Biped = require("../src/shared/StudPets/BipedAnims")(AnimLib, Quadruped),
}
local Animals = require("../src/shared/StudPets/Animals")
local Kit = require("./rigs/Kit")

local PETS = {
	{ rig = require("./rigs/Cat"), set = require("../src/shared/StudPets/Pets/Cat")(AnimLib, Quadruped), editor = true },
	{ rig = require("./rigs/Dog"), set = require("../src/shared/StudPets/Pets/Dog")(AnimLib, Quadruped), editor = true },
}
local EDITOR_ALL = table.find(process.args, "editor-all") ~= nil
for _, name in Animals.Order do
	local entry = Animals.ByName[name]
	table.insert(PETS, { rig = Kit.build(entry, PLANS), set = PLANS[entry.Plan].fromParams(entry), editor = EDITOR_ALL })
end

-- every joint name any animation set may pose
local KNOWN_JOINTS = {}
for _, n in { "Torso", "Head", "Neck", "Jaw", "Trunk", "EarL", "EarR", "EyeL", "EyeR", "LegFL", "LegFR", "LegBL", "LegBR",
	"LegL", "LegR", "ArmL", "ArmR", "WingL", "WingR", "FinL", "FinR", "Tail1", "Tail2" } do
	KNOWN_JOINTS[n] = true
end

local BAKE_FPS = 20 -- Animation Editor keyframes per second
local PREVIEW_FPS = 20

local PRIORITY = {
	Idle = Enum.AnimationPriority.Idle,
	Sit = Enum.AnimationPriority.Idle,
	Sleep = Enum.AnimationPriority.Idle,
	Walk = Enum.AnimationPriority.Movement,
	Run = Enum.AnimationPriority.Movement,
}

local function v3(t)
	return Vector3.new(t[1], t[2], t[3])
end

local function restCF(p)
	local cf = CFrame.new(p.pos[1], p.pos[2], p.pos[3])
	if p.rot then
		cf = cf * CFrame.Angles(math.rad(p.rot[1]), math.rad(p.rot[2]), math.rad(p.rot[3]))
	end
	return cf
end

-- Must match PetAnimator: Transform = CFrame.new(pos) * CFrame.Angles(rx, ry, rz)
local function poseCF(p, scale)
	if not p then
		return CFrame.new()
	end
	local k = scale or 1
	return CFrame.new(p[4] * k, p[5] * k, p[6] * k) * CFrame.Angles(math.rad(p[1]), math.rad(p[2]), math.rad(p[3]))
end

---------------------------------------------------------------------------
-- Rig compile: resolve parents, joint offsets, parent-before-child order.
---------------------------------------------------------------------------
local function compileRig(rig)
	local byName = {}
	local all = {}
	local root = { name = "RootPart", size = { 1, 1, 1 }, pos = { 0, rig.RootHeight, 0 }, root = true, color = { 163, 162, 165 } }
	byName.RootPart = root
	table.insert(all, root)
	for _, p in rig.Parts do
		assert(not byName[p.name], "duplicate part name " .. p.name)
		byName[p.name] = p
		table.insert(all, p)
	end
	for _, p in all do
		p.cf = restCF(p)
	end
	for _, p in all do
		if p.joint then
			local parent = assert(byName[p.joint[1]], p.name .. ": unknown joint parent " .. tostring(p.joint[1]))
			local pivot = CFrame.new(v3(p.joint[2]))
			p.parent, p.kind = parent, "motor"
			p.C0 = parent.cf:Inverse() * pivot
			p.C1 = p.cf:Inverse() * pivot
		elseif p.weld then
			local parent = assert(byName[p.weld], p.name .. ": unknown weld parent " .. tostring(p.weld))
			p.parent, p.kind = parent, "weld"
			p.C0 = parent.cf:Inverse() * p.cf
			p.C1 = CFrame.new()
		elseif not p.root then
			error(p.name .. " is not attached to anything")
		end
	end
	local list, seen = {}, {}
	local function visit(p)
		if seen[p] then
			return
		end
		seen[p] = true
		if p.parent then
			visit(p.parent)
		end
		table.insert(list, p)
	end
	for _, p in all do
		visit(p)
	end
	for _, p in list do
		if p.kind == "motor" then
			assert(p.parent.root or p.parent.kind == "motor", p.name .. ": motors must hang off the root or another motor part")
		end
	end
	return { rig = rig, list = list, byName = byName, scale = rig.AnimScale or 1 }
end

-- Forward kinematics, same maths as Roblox:
--   Part1 = Part0 * C0 * Transform * C1:Inverse()
local function solve(R, poseSet, origin)
	local world = {}
	for _, p in R.list do
		if p.root then
			world[p.name] = origin * p.cf
		elseif p.kind == "motor" then
			world[p.name] = world[p.parent.name] * p.C0 * poseCF(poseSet[p.name], R.scale) * p.C1:Inverse()
		else
			world[p.name] = world[p.parent.name] * p.C0 * p.C1:Inverse()
		end
	end
	return world
end

---------------------------------------------------------------------------
-- Instances
---------------------------------------------------------------------------
local function bakeSequence(R, anim)
	local kfs = Instance.new("KeyframeSequence")
	kfs.Name = anim.Name
	kfs.Loop = anim.Looped
	kfs.Priority = PRIORITY[anim.Name] or Enum.AnimationPriority.Action
	local n = math.max(1, math.round(anim.Length * BAKE_FPS))
	for i = 0, n do
		local t = anim.Length * i / n
		local ps = anim.Pose(t)
		local kf = Instance.new("Keyframe")
		kf.Name = "Keyframe"
		kf.Time = t
		local poses = {}
		for _, p in R.list do
			if p.root or p.kind == "motor" then
				local pose = Instance.new("Pose")
				pose.Name = p.name
				pose.CFrame = if p.root then CFrame.new() else poseCF(ps[p.name], R.scale)
				pose.Weight = 1
				pose.EasingStyle = Enum.PoseEasingStyle.Linear
				pose.EasingDirection = Enum.PoseEasingDirection.In
				pose.Parent = if p.root then kf else poses[p.parent.name]
				poses[p.name] = pose
			end
		end
		kf.Parent = kfs
	end
	return kfs
end

local function makeModel(R, set, origin, editorRig)
	local rig = R.rig
	local model = Instance.new("Model")
	model.Name = if editorRig then rig.Name .. "_EditorRig" else rig.Name
	local inst = {}
	for _, p in R.list do
		local part = Instance.new(p.class or "Part")
		part.Name = p.name
		part.Size = v3(p.size)
		part.CFrame = origin * p.cf
		part.Color = Color3.fromRGB(p.color[1], p.color[2], p.color[3])
		part.Material = if p.neon then Enum.Material.Neon else Enum.Material.Plastic
		part.TopSurface = if p.studs then Enum.SurfaceType.Studs else Enum.SurfaceType.Smooth
		part.BottomSurface = if p.studs then Enum.SurfaceType.Inlet else Enum.SurfaceType.Smooth
		part.FrontSurface = Enum.SurfaceType.Smooth
		part.BackSurface = Enum.SurfaceType.Smooth
		part.LeftSurface = Enum.SurfaceType.Smooth
		part.RightSurface = Enum.SurfaceType.Smooth
		part.Anchored = p.root == true
		part.CanCollide = false
		part.CanTouch = false
		part.CanQuery = false
		part.Massless = not p.root
		part.Transparency = if p.root then 1 else 0
		part.CastShadow = not p.root
		part.Parent = model
		inst[p.name] = part
	end
	for _, p in R.list do
		if p.kind == "motor" then
			local m = Instance.new("Motor6D")
			m.Name = if p.name == "Torso" then "RootJoint" else p.name .. "Joint"
			m.Part0 = inst[p.parent.name]
			m.Part1 = inst[p.name]
			m.C0 = p.C0
			m.C1 = p.C1
			m.Parent = inst[p.parent.name]
		elseif p.kind == "weld" then
			local w = Instance.new("Weld")
			w.Name = p.name .. "Weld"
			w.Part0 = inst[p.parent.name]
			w.Part1 = inst[p.name]
			w.C0 = p.C0
			w.C1 = p.C1
			w.Parent = inst[p.name]
		end
	end
	local controller = Instance.new("AnimationController")
	controller.Parent = model
	Instance.new("Animator").Parent = controller

	model.PrimaryPart = inst.RootPart
	model:SetAttribute("StudPet", rig.PetType)
	model:SetAttribute("RootHeight", rig.RootHeight)
	model:SetAttribute("AnimScale", rig.AnimScale or 1)
	model:AddTag("StudPet")
	pcall(function()
		model.ModelStreamingMode = Enum.ModelStreamingMode.Atomic
	end)

	if editorRig then
		local saves = Instance.new("ObjectValue")
		saves.Name = "AnimSaves"
		for _, name in set.Order do
			bakeSequence(R, set.Anims[name]).Parent = saves
		end
		saves.Parent = model
	end
	return model
end

local function studPart(name, size, cf, rgb)
	local part = Instance.new("Part")
	part.Name = name
	part.Size = size
	part.CFrame = cf
	part.Color = Color3.fromRGB(rgb[1], rgb[2], rgb[3])
	part.Material = Enum.Material.Plastic
	part.TopSurface = Enum.SurfaceType.Studs
	part.BottomSurface = Enum.SurfaceType.Inlet
	part.Anchored = true
	return part
end

local function corners(cf, size)
	local out = {}
	local hx, hy, hz = size[1] / 2, size[2] / 2, size[3] / 2
	for _, sx in { -1, 1 } do
		for _, sy in { -1, 1 } do
			for _, sz in { -1, 1 } do
				table.insert(out, cf * Vector3.new(sx * hx, sy * hy, sz * hz))
			end
		end
	end
	return out
end

local function makeDemo(compiled)
	local folder = Instance.new("Folder")
	folder.Name = "StudPetsDemo"
	local spawn = Instance.new("SpawnLocation")
	spawn.Name = "DemoSpawn"
	spawn.Size = Vector3.new(6, 1, 6)
	spawn.CFrame = CFrame.new(0, 0.5, 16)
	spawn.Anchored = true
	spawn.Neutral = true
	spawn.Duration = 0
	spawn.TopSurface = Enum.SurfaceType.Studs
	spawn.Parent = folder
	-- pedestals packed in rows, each sized to its pet's footprint, facing the spawn (+Z)
	local x, z, rowDepth = -55, -6, 0
	local placed = {}
	for _, entry in compiled do
		local lo, hi = Vector3.new(math.huge, 0, math.huge), Vector3.new(-math.huge, 0, -math.huge)
		local world = solve(entry.R, {}, CFrame.new())
		for _, p in entry.R.list do
			if not p.root then
				for _, c in corners(world[p.name], p.size) do
					lo = Vector3.new(math.min(lo.X, c.X), 0, math.min(lo.Z, c.Z))
					hi = Vector3.new(math.max(hi.X, c.X), 0, math.max(hi.Z, c.Z))
				end
			end
		end
		local w = math.max(7, math.ceil(hi.X - lo.X) + 3)
		local d = math.max(8, math.ceil(hi.Z - lo.Z) + 3)
		if x + w > 55 then
			x, z, rowDepth = -55, z - rowDepth - 3, 0
		end
		rowDepth = math.max(rowDepth, d)
		local cx, cz = x + w / 2, z - d / 2
		table.insert(placed, { entry = entry, cx = cx, cz = cz, w = w, d = d, lo = lo, hi = hi })
		x += w + 2
	end
	local farZ = z - rowDepth - 6
	studPart("DemoFloor", Vector3.new(124, 1, 30 - farZ), CFrame.new(0, -0.5, (22 + farZ) / 2), { 75, 151, 75 }).Parent = folder
	for _, pl in placed do
		local R = pl.entry.R
		studPart("Pedestal" .. R.rig.PetType, Vector3.new(pl.w - 1, 1, pl.d - 1), CFrame.new(pl.cx, 0.5, pl.cz), { 163, 162, 165 }).Parent = folder
		-- centre the pet's footprint on its pedestal (it is turned 180 degrees)
		local ox, oz = (pl.lo.X + pl.hi.X) / 2, (pl.lo.Z + pl.hi.Z) / 2
		local pet = makeModel(R, pl.entry.set, CFrame.new(pl.cx + ox, 1, pl.cz + oz) * CFrame.Angles(0, math.pi, 0), false)
		pet:SetAttribute("Showcase", true)
		pet.Parent = folder
	end
	return folder
end

---------------------------------------------------------------------------
-- QA
---------------------------------------------------------------------------
local AIRBORNE = { Jump = true, Run = true, Loop = true, Flip = true, Rear = true, Spin = true, Dance = true }
local VERBOSE = table.find(process.args, "verbose") ~= nil -- allowed to leave the ground
local problems = 0

local currentPet = ""
local function warn(msg)
	problems += 1
	print("  !! " .. currentPet .. ": " .. msg)
end


local function lowestPoint(R, world)
	local minY, who = math.huge, ""
	for _, p in R.list do
		if not p.root then
			for _, c in corners(world[p.name], p.size) do
				if c.Y < minY then
					minY, who = c.Y, p.name
				end
			end
		end
	end
	return minY, who
end

-- Coincident same-facing faces flicker (z-fighting). Check the rest pose.
local function zFightCheck(R)
	local faces = {}
	for _, p in R.list do
		if not p.root and (p.class or "Part") == "Part" then
			local cf = p.cf
			local axes = { cf.RightVector, cf.UpVector, cf.LookVector * -1 }
			for a = 1, 3 do
				for _, sgn in { -1, 1 } do
					local n = axes[a] * sgn
					local center = cf.Position + n * (p.size[a] / 2)
					local u = axes[a % 3 + 1]
					local v = axes[(a + 1) % 3 + 1]
					local su = p.size[a % 3 + 1] / 2
					local sv = p.size[(a + 1) % 3 + 1] / 2
					table.insert(faces, { part = p.name, parent = p.parent and p.parent.name, n = n, c = center, u = u, v = v, su = su, sv = sv })
				end
			end
		end
	end
	local hits = 0
	local seenPairs = {}
	for i = 1, #faces do
		for j = i + 1, #faces do
			local f, g = faces[i], faces[j]
			if f.part ~= g.part and f.n:Dot(g.n) > 0.999 and math.abs((g.c - f.c):Dot(f.n)) < 0.004 then
				-- project g's centre/extent onto f's axes and test rectangle overlap
				local d = g.c - f.c
				local du, dv = math.abs(d:Dot(f.u)), math.abs(d:Dot(f.v))
				local gu = math.abs(g.u:Dot(f.u)) * g.su + math.abs(g.v:Dot(f.u)) * g.sv
				local gv = math.abs(g.u:Dot(f.v)) * g.su + math.abs(g.v:Dot(f.v)) * g.sv
				local key = f.part .. "|" .. g.part
				if du < f.su + gu - 0.004 and dv < f.sv + gv - 0.004 and not seenPairs[key] then
					seenPairs[key] = true
					hits += 1
					warn(("z-fight: %s and %s share a face plane"):format(f.part, g.part))
				end
			end
		end
	end
	return hits
end

local function qa(R, set)
	currentPet = R.rig.Name
	if VERBOSE then
		print(("[QA] %s (%d parts)"):format(R.rig.Name, #R.list - 1))
	end
	local joints = {}
	for _, p in R.list do
		if p.kind == "motor" then
			joints[p.name] = true
		end
	end
	local origin = CFrame.new()
	zFightCheck(R)
	local rest = solve(R, {}, origin)
	local restMin = lowestPoint(R, rest)
	local hovers = set.Spec ~= nil and set.Spec.hover ~= nil -- flyers & swimmers float by design
	if not hovers and math.abs(restMin) > 0.001 then
		warn(("rest pose lowest point %.3f (should be 0)"):format(restMin))
	end
	for _, name in set.Order do
		local anim = set.Anims[name]
		assert(anim and anim.Name == name, "anim name mismatch " .. name)
		local n = math.max(2, math.round(anim.Length * 60))
		local lo, hi, loWho = math.huge, -math.huge, ""
		local unknown = {}
		for i = 0, n do
			local t = anim.Length * i / n
			local ps = anim.Pose(t)
			for joint, pose in ps do
				if not joints[joint] and not KNOWN_JOINTS[joint] then
					unknown[joint] = true
				end
				for c = 1, 6 do
					if pose[c] ~= pose[c] then
						warn(("%s: NaN in %s at t=%.2f"):format(name, joint, t))
					end
				end
			end
			local y, who = lowestPoint(R, solve(R, ps, origin))
			if y < lo then
				lo, loWho = y, who
			end
			hi = math.max(hi, y)
		end
		for joint in unknown do
			warn(("%s: poses unknown joint '%s'"):format(name, joint))
		end
		-- looped animations must end where they start
		if anim.Looped then
			local a, b = anim.Pose(0), anim.Pose(anim.Length)
			for joint, pa in a do
				local pb = b[joint] or AnimLib.ZERO
				for c = 1, 6 do
					if math.abs(pa[c] - pb[c]) > 0.05 then
						warn(("%s: loop seam on %s (channel %d: %.3f vs %.3f)"):format(name, joint, c, pa[c], pb[c]))
						break
					end
				end
			end
		end
		local status = "ok"
		local tol = math.max(1, R.scale) -- tolerances grow with the pet
		if lo < -0.1 * tol then
			status = "SINKS"
			warn(("%s: %s sinks %.2f below ground"):format(name, loWho, -lo))
		elseif not AIRBORNE[name] and not hovers and hi > 0.12 * tol then
			status = "FLOATS"
			warn(("%s: floats up to %.2f above ground"):format(name, hi))
		end
		if VERBOSE or status ~= "ok" then
			print(("  %-8s %4.2fs %-6s lowest point %+.2f..%+.2f (%s)"):format(name, anim.Length, if anim.Looped then "loop" else "once", lo, hi, status))
		end
	end
end

---------------------------------------------------------------------------
-- Main
---------------------------------------------------------------------------
local compiled = {}
for _, pet in PETS do
	table.insert(compiled, { R = compileRig(pet.rig), set = pet.set, editor = pet.editor })
end

for _, entry in compiled do
	qa(entry.R, entry.set)
end

fs.writeDir("assets/editor")
fs.writeDir("assets/pets")
for _, entry in compiled do
	local name = entry.R.rig.Name
	local runtime = makeModel(entry.R, entry.set, CFrame.new(), false)
	fs.writeFile(`assets/pets/{name}.rbxm`, roblox.serializeModel({ runtime }))
	if entry.editor then
		local editor = makeModel(entry.R, entry.set, CFrame.new(), true)
		fs.writeFile(`assets/editor/{name}_EditorRig.rbxm`, roblox.serializeModel({ editor }))
	end
end
fs.writeFile("assets/StudPetsDemo.rbxm", roblox.serializeModel({ makeDemo(compiled) }))
print(("[build] wrote %d pets to assets/pets, editor rigs, assets/StudPetsDemo.rbxm"):format(#compiled))

if process.args[1] == "preview" then
	local out = { fps = PREVIEW_FPS, pets = {} }
	local onlyPet = process.args[4]
	for _, entry in compiled do
		local R, set = entry.R, entry.set
		if onlyPet and onlyPet ~= "all" and not string.find("," .. onlyPet .. ",", "," .. R.rig.PetType .. ",", 1, true) then
			continue
		end
		local parts = {}
		for _, p in R.list do
			if not p.root then
				table.insert(parts, { name = p.name, class = p.class or "Part", size = p.size, color = p.color, studs = p.studs == true, neon = p.neon == true })
			end
		end
		local anims = {}
		local only = process.args[3]
		if only == "all" then
			only = nil
		end
		for _, name in set.Order do
			if not only or only == name then
				local anim = set.Anims[name]
				local n = math.max(1, math.round(anim.Length * PREVIEW_FPS))
				local frames = {}
				-- looped: skip the duplicate last frame; one-shots: include it
				local last = if anim.Looped then n - 1 else n
				for i = 0, last do
					local world = solve(R, anim.Pose(anim.Length * i / n), CFrame.new())
					local frame = {}
					for _, p in R.list do
						if not p.root then
							for _, c in { world[p.name]:GetComponents() } do
								table.insert(frame, math.round(c * 10000) / 10000)
							end
						end
					end
					table.insert(frames, frame)
				end
				table.insert(anims, { name = name, looped = anim.Looped, frames = frames })
			end
		end
		table.insert(out.pets, { name = R.rig.Name, parts = parts, anims = anims })
	end
	fs.writeFile(process.args[2], serde.encode("json", out))
	print("[build] preview data -> " .. process.args[2])
end

print(if problems == 0 then "[QA] all checks passed" else ("[QA] %d problem(s)"):format(problems))
