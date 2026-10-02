-- Offline checks for the anime clip:
--  1. a rig read from real Motor6Ds (the stand-in .rbxm, the way the game reads an avatar)
--     poses exactly like the timeline's own stand-in maths, every frame
--  2. every frame samples cleanly: no NaNs, feet on the ground when grounded, camera sane,
--     the sword stays in the hand
--  3. shots cover 0..10 s with no gaps
--   lune run build/test_clip.luau
local fs = require("@lune/fs")
local roblox = require("@lune/roblox")
local CF = require("../src/shared/AnimeClip/CF")
local Rig = require("../src/shared/AnimeClip/Rig")
local Props = require("../src/shared/AnimeClip/Props")
local T = require("../src/shared/AnimeClip/Timeline")

local fails, checks = 0, 0
local function check(ok, msg)
	checks += 1
	if not ok then
		fails += 1
		if fails < 25 then
			print("  FAIL " .. msg)
		end
	end
end

-- 1. read the stand-in rigs like the client does
local folder = roblox.deserializeModel(fs.readFile("assets/StandIns.rbxm"))[1]
local descs = {}
for _, name in { "Hero", "Rival" } do
	local model = folder[name]
	local list, sizes = {}, {}
	local motors = {}
	for _, d in model:GetDescendants() do
		if d:IsA("Motor6D") then
			motors[d.Name] = d
		elseif d:IsA("BasePart") then
			sizes[d.Name] = { d.Size.X, d.Size.Y, d.Size.Z }
		end
	end
	for _, j in Rig.JOINTS do
		local m = motors[j.name]
		check(m ~= nil, name .. " has joint " .. j.name)
		if m then
			table.insert(list, { name = j.name, part0 = m.Part0.Name, part1 = m.Part1.Name, c0 = { m.C0:GetComponents() }, c1 = { m.C1:GetComponents() } })
		end
	end
	descs[name:lower()] = Rig.Describe(list, sizes)
end

local function near(a, b, eps)
	for i = 1, 12 do
		if math.abs(a[i] - b[i]) > (eps or 1e-3) then
			return false
		end
	end
	return true
end

local FPS = 30
local covered = {}
for f = 0, T.LENGTH * FPS - 1 do
	local t = f / FPS
	for _, name in { "hero", "rival" } do
		local s = T.ActorState(name, t)
		local desc = descs[name]
		local root = T.RootFor(desc, s)
		local world = Rig.FK(desc, root, s.pose)
		local proxy = T.ProxyWorld(name, t)
		for part, cf in proxy do
			check(world[part] ~= nil and near(world[part], cf, 2e-3), ("t=%.2f %s %s matches"):format(t, name, part))
		end
		if s.grounded and s.lift < 0.01 then
			local low = Rig.Lowest(desc, world)
			check(math.abs(low) < 1e-3, ("t=%.2f %s feet on the ground (%.3f)"):format(t, name, low))
		end
		-- the sword's grip stays in the right hand
		if s.sword == "hand" then
			local grip = CF.pos(CF.mul(world.RightHand, Props.GRIP))
			local hand = CF.pos(world.RightHand)
			check(CF.len(CF.sub(grip, hand)) < 0.3, ("t=%.2f %s grip in hand"):format(t, name))
		end
	end
	local fr = T.Sample(t)
	covered[fr.shot] = true
	local cam = fr.camera.cf
	for i = 1, 12 do
		check(cam[i] == cam[i], ("t=%.2f camera finite"):format(t))
	end
	check(fr.camera.fov > 10 and fr.camera.fov < 80, ("t=%.2f fov %.1f"):format(t, fr.camera.fov))
	check(cam[2] > 0.3, ("t=%.2f camera above ground (%.2f)"):format(t, cam[2]))
	for _, p in fr.prims do
		for i = 1, 12 do
			check(p.cf[i] == p.cf[i], ("t=%.2f prim finite"):format(t))
		end
	end
end
for i = 1, #T.SHOTS do
	check(covered[i], "shot " .. i .. " is used")
end
for i = 1, #T.SHOTS - 1 do
	check(math.abs(T.SHOTS[i].t1 - T.SHOTS[i + 1].t0) < 1e-6, ("shot %d ends where %d starts"):format(i, i + 1))
end
print(("[clip test] %d checks, %d failed"):format(checks, fails))
if fails > 0 then
	error("clip test failed")
end
