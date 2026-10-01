-- Runs the real Stud Gear server script against fake Roblox objects and checks every
-- effect: equip / unequip / swap, gravity force from the character's mass, another script
-- changing speed while gear is held, respawning, game passes and the display stands.
--   lune run build/test_gear_sim.luau

local fs = require("@lune/fs")
local luau = require("@lune/luau")
local roblox = require("@lune/roblox")

local SOURCES = {}
for _, path in {
	"src/shared/StudGear/Config.luau",
	"src/shared/StudGear/Effects.luau",
	"src/server/StudGearServer.server.luau",
} do
	SOURCES[path] = fs.readFile(path)
end

local failures, passes = 0, 0
local function check(ok: any, msg: string)
	if ok then
		passes += 1
	else
		failures += 1
		print("  FAIL " .. msg)
	end
end
local function near(a, b)
	return type(a) == "number" and math.abs(a - b) < 1e-3
end

-- scheduler -------------------------------------------------------------------------
local now = 0
local queue = {}
local function resume(co, ...)
	local ok, err = coroutine.resume(co, ...)
	if not ok then
		failures += 1
		print("  FAIL script error: " .. tostring(err))
	end
end
local Task = {
	spawn = function(fn, ...)
		local co = if type(fn) == "thread" then fn else coroutine.create(fn)
		resume(co, ...)
		return co
	end,
	delay = function(n, fn, ...)
		table.insert(queue, { at = now + n, co = coroutine.create(fn) })
	end,
	wait = function(n)
		local start = now
		table.insert(queue, { at = now + (n or 0.03), co = coroutine.running() })
		coroutine.yield()
		return now - start
	end,
}
local function advance(seconds)
	local target = now + seconds
	while true do
		table.sort(queue, function(a, b)
			return a.at < b.at
		end)
		local nxt = queue[1]
		if not nxt or nxt.at > target then
			break
		end
		table.remove(queue, 1)
		now = math.max(now, nxt.at)
		resume(nxt.co)
	end
	now = target
end

-- fake instances -----------------------------------------------------------------------
local function signal()
	local s = { fns = {} }
	function s:Connect(fn)
		table.insert(self.fns, fn)
		return { Disconnect = function() end }
	end
	function s:Fire(...)
		for _, fn in table.clone(self.fns) do
			Task.spawn(fn, ...)
		end
	end
	function s:Once(fn)
		return self:Connect(fn)
	end
	function s:Wait()
		local co = coroutine.running()
		local conn
		conn = true
		table.insert(self.fns, function(...)
			if conn then
				conn = false
				Task.spawn(co, ...)
			end
		end)
		return coroutine.yield()
	end
	return s
end

local Inst = {}
local function new(class, props)
	local o = setmetatable({ _p = { ClassName = class, Name = class }, _c = {}, _a = {}, _sig = {} }, Inst)
	rawget(o, "_p").ChildAdded = signal()
	rawget(o, "_p").ChildRemoved = signal()
	rawget(o, "_p").AncestryChanged = signal()
	for k, v in props or {} do
		o[k] = v
	end
	return o
end
Inst.__index = function(self, k)
	local v = rawget(Inst, k)
	if v ~= nil then
		return v
	end
	local p = rawget(self, "_p")
	if p[k] ~= nil then
		return p[k]
	end
	return self:FindFirstChild(k)
end
Inst.__newindex = function(self, k, v)
	local p = rawget(self, "_p")
	if k == "Parent" then
		local old = p.Parent
		if old == v then
			return
		end
		if old then
			local list = rawget(old, "_c")
			table.remove(list, table.find(list, self))
		end
		p.Parent = v
		if v then
			table.insert(rawget(v, "_c"), self)
		end
		if old then
			old.ChildRemoved:Fire(self)
		end
		if v then
			v.ChildAdded:Fire(self)
		end
		self.AncestryChanged:Fire()
		return
	end
	local changed = p[k] ~= v
	p[k] = v
	local sig = rawget(self, "_sig")[k]
	if changed and sig then
		sig:Fire()
	end
end
function Inst:GetPropertyChangedSignal(k)
	local sigs = rawget(self, "_sig")
	sigs[k] = sigs[k] or signal()
	return sigs[k]
end
function Inst:FindFirstChild(name, recursive)
	for _, c in rawget(self, "_c") do
		if c.Name == name then
			return c
		end
		if recursive then
			local r = c:FindFirstChild(name, true)
			if r then
				return r
			end
		end
	end
	return nil
end
function Inst:FindFirstChildOfClass(class)
	for _, c in rawget(self, "_c") do
		if c.ClassName == class then
			return c
		end
	end
	return nil
end
function Inst:FindFirstChildWhichIsA(class)
	return self:FindFirstChildOfClass(class)
end
function Inst:WaitForChild(name)
	return assert(self:FindFirstChild(name), "would wait forever for " .. name)
end
function Inst:GetChildren()
	return table.clone(rawget(self, "_c"))
end
function Inst:GetDescendants()
	local out = {}
	local function walk(o)
		for _, c in rawget(o, "_c") do
			table.insert(out, c)
			walk(c)
		end
	end
	walk(self)
	return out
end
function Inst:IsA(class)
	if class == "BasePart" then
		return self.ClassName == "Part"
	end
	return self.ClassName == class
end
function Inst:SetAttribute(k, v)
	rawget(self, "_a")[k] = v
end
function Inst:GetAttribute(k)
	return rawget(self, "_a")[k]
end
function Inst:Destroy()
	self.Parent = nil
end
function Inst:Clone()
	local map = {}
	local function copy(o)
		local c = new(o.ClassName)
		map[o] = c
		for k, v in rawget(o, "_p") do
			if k ~= "Parent" and k ~= "ChildAdded" and k ~= "ChildRemoved" and k ~= "AncestryChanged" then
				rawget(c, "_p")[k] = v
			end
		end
		for k, v in rawget(o, "_a") do
			rawget(c, "_a")[k] = v
		end
		for _, ch in rawget(o, "_c") do
			local cc = copy(ch)
			rawget(cc, "_p").Parent = c
			table.insert(rawget(c, "_c"), cc)
		end
		return c
	end
	local root = copy(self)
	-- references inside the copy point at the copy (PrimaryPart, Part0...)
	for orig, c in map do
		for k, v in rawget(c, "_p") do
			if type(v) == "table" and map[v] and k ~= "Parent" then
				rawget(c, "_p")[k] = map[v]
			end
		end
		local _ = orig
	end
	return root
end
function Inst:GetPivot()
	return self.PrimaryPart and self.PrimaryPart.CFrame or roblox.CFrame.new()
end
function Inst:PivotTo(cf)
	local delta = cf * self:GetPivot():Inverse()
	for _, d in self:GetDescendants() do
		if rawget(d, "_p").CFrame then
			d.CFrame = delta * d.CFrame
		end
	end
end
function Inst:EquipTool(tool)
	tool.Parent = self.Parent -- humanoid's parent is the character
end
function Inst:UnequipTools()
	local character = self.Parent
	for _, c in character:GetChildren() do
		if c.ClassName == "Tool" then
			c.Parent = character.Player:FindFirstChildOfClass("Backpack")
		end
	end
end

-- world ---------------------------------------------------------------------------------
local function makeWorld(opts)
	local env = {}
	local Players = new("Players")
	rawget(Players, "_p").PlayerAdded = signal()
	rawget(Players, "_p").PlayerRemoving = signal()
	rawget(Players, "_p").GetPlayers = function(self)
		return self:GetChildren()
	end
	local RS = new("ReplicatedStorage")
	local System = new("Folder", { Name = "StudGear", Parent = RS })
	new("ModuleScript", { Name = "Config", Parent = System, Path = "src/shared/StudGear/Config.luau" })
	new("ModuleScript", { Name = "Effects", Parent = System, Path = "src/shared/StudGear/Effects.luau" })
	local Tools = new("Folder", { Name = "Tools", Parent = System })
	local Heartbeat = signal()
	local RunService = new("RunService")
	rawget(RunService, "_p").Heartbeat = Heartbeat
	local passes = opts.passes or {}
	local MS = new("MarketplaceService")
	local prompts = {}
	rawget(MS, "_p").UserOwnsGamePassAsync = function(_, userId, id)
		return passes[userId .. ":" .. id] == true
	end
	rawget(MS, "_p").PromptGamePassPurchase = function(_, player, id)
		table.insert(prompts, { player, id })
	end
	rawget(MS, "_p").PromptGamePassPurchaseFinished = signal()
	local tagged = {}
	local CS = new("CollectionService")
	rawget(CS, "_p").GetTagged = function()
		return tagged
	end
	rawget(CS, "_p").GetInstanceAddedSignal = function()
		return signal()
	end
	local cache = {}
	local config
	local function fakeRequire(m)
		if cache[m.Path] == nil then
			cache[m.Path] = luau.load(SOURCES[m.Path], { debugName = m.Path, environment = env })()
		end
		return cache[m.Path]
	end
	local script = new("Script", { Name = "StudGearServer" })
	env.script = script
	env.game = {
		GetService = function(_, n)
			return ({ Players = Players, ReplicatedStorage = RS, RunService = RunService, MarketplaceService = MS, CollectionService = CS })[n]
				or error("no fake service " .. n)
		end,
	}
	local terrain = new("Terrain", { Name = "Terrain" })
	env.workspace = { Gravity = 196.2, Terrain = terrain }
	env.task = Task
	env.require = fakeRequire
	env.warn = function() end
	env.os = {
		clock = function()
			return now
		end,
	}
	env.Instance = { new = function(c)
		local o = new(c)
		if c == "ProximityPrompt" then
			rawget(o, "_p").Triggered = signal()
		elseif c == "RemoteEvent" then
			rawget(o, "_p").OnServerEvent = signal()
		end
		return o
	end }
	env.Vector3 = roblox.Vector3
	env.CFrame = roblox.CFrame
	env.typeof = typeof
	env.Color3 = { fromRGB = function(r, g, b)
		return { r, g, b }
	end }
	env.ColorSequence = { new = function(...)
		return { ... }
	end }
	env.ColorSequenceKeypoint = { new = function(...)
		return { ... }
	end }
	env.NumberSequence = env.ColorSequence
	env.NumberSequenceKeypoint = env.ColorSequenceKeypoint
	env.Enum = { ActuatorRelativeTo = { World = "World" } }
	config = fakeRequire(System.Config)
	for k, v in opts.config or {} do
		config[k] = v
	end
	for _, g in config.Gear do
		for k, v in (opts.gear or {})[g.Name] or {} do
			g[k] = v
		end
		local t = new("Tool", { Name = g.Name })
		t:SetAttribute("StudGear", g.Name)
		if g.Grapple then
			local hook = new("Part", { Name = "Hook", Parent = t, CFrame = roblox.CFrame.new() })
			new("Attachment", { Name = "Muzzle", Parent = hook })
		end
		t.Parent = Tools
	end
	local Wearables = new("Folder", { Name = "Wearables", Parent = System })
	local pack = new("Model", { Name = "Jetpack", Parent = Wearables })
	local wroot = new("Part", { Name = "WearRoot", Parent = pack, CFrame = roblox.CFrame.new(), Size = roblox.Vector3.new(0.2, 0.2, 0.2) })
	rawget(pack, "_p").PrimaryPart = wroot
	local nozzle = new("Part", { Name = "Nozzle", Parent = pack, CFrame = roblox.CFrame.new(0.5, -1, 0.7), Size = roblox.Vector3.new(1, 1, 1) })
	local flame = new("Attachment", { Name = "Flame", Parent = nozzle })
	new("ParticleEmitter", { Name = "Flame", Parent = flame, Enabled = false })
	-- a display stand for the Speed Coil
	local stand = new("Model", { Name = "Speed Coil" })
	local top = new("Part", { Name = "Top", Parent = stand })
	rawget(stand, "_p").PrimaryPart = top
	stand:SetAttribute("StudGearDisplay", "Speed Coil")
	table.insert(tagged, stand)

	Task.spawn(luau.load(SOURCES["src/server/StudGearServer.server.luau"], { debugName = "StudGearServer", environment = env }))

	local world = { Players = Players, Heartbeat = Heartbeat, MS = MS, prompts = prompts, stand = stand, script = script, config = config, terrain = terrain, System = System }
	local uid = 0
	function world.spawn(player, mass)
		local character = new("Model", { Name = player.Name, Player = player })
		local humanoid = new("Humanoid", { WalkSpeed = 16, JumpPower = 50, JumpHeight = 7.2, Health = 100, MaxHealth = 100, Parent = character })
		local root = new("Part", { Name = "HumanoidRootPart", AssemblyMass = mass or 15, Parent = character, CFrame = roblox.CFrame.new(0, 3, 0), Position = roblox.Vector3.new(0, 3, 0) })
		new("Part", { Name = "UpperTorso", Parent = character, CFrame = roblox.CFrame.new(0, 3.5, 0), Size = roblox.Vector3.new(2, 1.6, 1) })
		character.Parent = { _p = {}, _c = {}, ChildAdded = signal(), ChildRemoved = signal() } -- "workspace"
		setmetatable(character.Parent, Inst)
		player.Character = character
		player.CharacterAdded:Fire(character)
		advance(0.1)
		return character, humanoid, root
	end
	function world.join(name)
		uid += 1
		local p = new("Player", { Name = name, UserId = uid, Parent = Players })
		rawget(p, "_p").CharacterAdded = signal()
		new("Backpack", { Parent = p })
		Players.PlayerAdded:Fire(p)
		advance(0.1)
		return p
	end
	function world.toolIn(container, name)
		for _, c in container:GetChildren() do
			if c.ClassName == "Tool" and c:GetAttribute("StudGear") == name then
				return c
			end
		end
		return nil
	end
	return world
end

-- scenarios ------------------------------------------------------------------------------
print("[equip / unequip]")
do
	local w = makeWorld({})
	local p = w.join("A")
	local character, humanoid, root = w.spawn(p, 15)
	check(w.script:FindFirstChild("GiveGear"), "GiveGear API exists")
	local give = w.script.GiveGear.OnInvoke
	check(give(p, "Speed Coil") == true, "GiveGear gives the Speed Coil")
	local backpack = p:FindFirstChildOfClass("Backpack")
	local speed = w.toolIn(backpack, "Speed Coil")
	check(speed, "tool is in the backpack")
	check(not give(p, "Nope"), "unknown gear refused")
	give(p, "Speed Coil")
	local count = 0
	for _, c in backpack:GetChildren() do
		count += if c:GetAttribute("StudGear") == "Speed Coil" then 1 else 0
	end
	check(count == 1, "giving twice doesn't duplicate")
	humanoid:EquipTool(speed)
	advance(0.05)
	check(near(humanoid.WalkSpeed, 28), "speed coil: walk 16 -> 28 (" .. tostring(humanoid.WalkSpeed) .. ")")
	check(near(humanoid.JumpPower, 50) and near(humanoid.JumpHeight, 7.2), "speed coil leaves jump alone")
	check(root:FindFirstChild("StudGearTrail"), "trail while holding gear")
	speed.Parent = backpack
	advance(0.05)
	check(near(humanoid.WalkSpeed, 16), "unequip puts speed back to 16 (" .. tostring(humanoid.WalkSpeed) .. ")")
	check(root:FindFirstChild("StudGearTrail") == nil, "trail removed on unequip")

	-- gravity
	give(p, "Gravity Coil")
	local grav = w.toolIn(backpack, "Gravity Coil")
	humanoid:EquipTool(grav)
	advance(0.05)
	local force = root:FindFirstChild("StudGearGravity")
	check(force and force.ClassName == "VectorForce", "gravity coil adds a VectorForce")
	w.Heartbeat:Fire(1 / 60)
	advance(0.01)
	local want = 15 * 196.2 * (1 - 0.35)
	check(force and near(force.Force.Y, want), ("lift = mass x g x 0.65 (%s vs %.1f)"):format(force and tostring(force.Force.Y) or "nil", want))
	root.AssemblyMass = 22 -- put on heavy accessories
	w.Heartbeat:Fire(1 / 60)
	advance(0.01)
	check(force and near(force.Force.Y, 22 * 196.2 * 0.65), "lift follows the character's mass")
	check(near(humanoid.WalkSpeed, 16), "gravity coil leaves speed alone")
	grav.Parent = backpack
	advance(0.05)
	check(root:FindFirstChild("StudGearGravity") == nil, "unequip removes the gravity force")

	-- swap speed -> fusion (Roblox unequips the old one first)
	humanoid:EquipTool(speed)
	advance(0.05)
	give(p, "Fusion Coil")
	local fusion = w.toolIn(backpack, "Fusion Coil")
	speed.Parent = backpack
	humanoid:EquipTool(fusion)
	advance(0.05)
	check(near(humanoid.WalkSpeed, 16 * 1.6), "swap to fusion: 16 x 1.6 (" .. tostring(humanoid.WalkSpeed) .. ")")
	check(root:FindFirstChild("StudGearGravity"), "fusion has low gravity too")
	fusion.Parent = backpack
	advance(0.05)
	check(near(humanoid.WalkSpeed, 16) and root:FindFirstChild("StudGearGravity") == nil, "fusion off: all back to normal")

	-- jump coil
	give(p, "Jump Coil")
	local jump = w.toolIn(backpack, "Jump Coil")
	humanoid:EquipTool(jump)
	advance(0.05)
	check(near(humanoid.JumpHeight, 7.2 * 1.8), "jump coil: JumpHeight x1.8")
	check(near(humanoid.JumpPower, 50 * math.sqrt(1.8)), "jump coil: JumpPower x sqrt(1.8) (same height in JumpPower mode)")
	jump.Parent = backpack
	advance(0.05)
	check(near(humanoid.JumpHeight, 7.2) and near(humanoid.JumpPower, 50), "jump back to normal")

	-- another script changes speed while the coil is held (a sprint key)
	humanoid:EquipTool(speed)
	advance(0.05)
	humanoid.WalkSpeed = 24 -- sprint starts
	advance(0.05)
	check(near(humanoid.WalkSpeed, 24 * 1.75), "sprint while holding the coil stacks: 24 x 1.75 (" .. tostring(humanoid.WalkSpeed) .. ")")
	humanoid.WalkSpeed = 16 -- sprint ends
	advance(0.05)
	check(near(humanoid.WalkSpeed, 28), "sprint ends: back to coil speed 28")
	speed.Parent = backpack
	advance(0.05)
	check(near(humanoid.WalkSpeed, 16), "unequip after sprinting: 16")
	humanoid:EquipTool(speed)
	advance(0.05)
	humanoid.WalkSpeed = 24
	advance(0.05)
	speed.Parent = backpack
	advance(0.05)
	check(near(humanoid.WalkSpeed, 24), "unequip while still sprinting keeps the sprint speed (24)")

	-- respawn
	local c2, h2, r2 = w.spawn(p, 15)
	check(c2 ~= character and near(h2.WalkSpeed, 16), "new character starts normal")
	local spd = w.toolIn(backpack, "Speed Coil")
	h2:EquipTool(spd)
	advance(0.05)
	check(near(h2.WalkSpeed, 28), "gear works after respawning")
	check(r2:FindFirstChild("StudGearTrail"), "trail on the new character")
end

print("[game passes]")
do
	local w = makeWorld({
		gear = { ["Gravity Coil"] = { GamePassId = 111 }, ["Speed Coil"] = { GamePassId = 222 } },
		passes = { ["1:111"] = true },
	})
	local p = w.join("Owner")
	w.spawn(p, 15)
	advance(0.2)
	local backpack = p:FindFirstChildOfClass("Backpack")
	check(w.toolIn(backpack, "Gravity Coil"), "pass owner spawns with the Gravity Coil")
	check(not w.toolIn(backpack, "Speed Coil"), "doesn't get a pass they don't own")
	check(not w.toolIn(backpack, "Jump Coil"), "free gear isn't handed out on spawn by default")
	check(p:GetAttribute("StudGearOwned") == "Gravity Coil", "owned list published for the stands")
	-- display stand: not owned -> purchase prompt
	local prompt = w.stand.Top:FindFirstChild("StudGearPrompt")
	check(prompt and prompt.ActionText == "Buy", "stand for a pass you don't own says Buy")
end

print("[display stand]")
do
	local w = makeWorld({})
	local p = w.join("B")
	local character, humanoid = w.spawn(p, 15)
	local prompt = w.stand.Top:FindFirstChild("StudGearPrompt")
	check(prompt and prompt.ActionText == "Get", "free gear stand says Get")
	prompt.Triggered:Fire(p)
	advance(0.05)
	check(w.toolIn(character, "Speed Coil"), "Get gives the coil and equips it")
	check(near(humanoid.WalkSpeed, 28), "and its speed applies right away")
end

print("[buying]")
do
	local w = makeWorld({ gear = { ["Speed Coil"] = { GamePassId = 222 } } })
	local p = w.join("Buyer")
	local character, humanoid = w.spawn(p, 15)
	local prompt = w.stand.Top:FindFirstChild("StudGearPrompt")
	check(prompt.ActionText == "Buy", "paid gear stand says Buy")
	prompt.Triggered:Fire(p)
	advance(0.05)
	check(#w.prompts == 1 and w.prompts[1][2] == 222, "not owned: prompts the game pass purchase")
	check(not w.toolIn(character, "Speed Coil"), "no free coil before paying")
	w.MS.PromptGamePassPurchaseFinished:Fire(p, 222, true)
	advance(0.05)
	check(w.toolIn(character, "Speed Coil") and near(humanoid.WalkSpeed, 28), "after buying: given, equipped, working")
	check(p:GetAttribute("StudGearOwned") == "Speed Coil", "stand now shows OWNED")
	advance(1)
	prompt.Triggered:Fire(p)
	advance(0.05)
	check(#w.prompts == 1, "owner using the stand just equips (no second purchase prompt)")
end

print("[regen, jetpack, grapple]")
do
	local w = makeWorld({})
	local p = w.join("C")
	local character, humanoid, root = w.spawn(p, 15)
	local give = w.script.GiveGear.OnInvoke
	local backpack = p:FindFirstChildOfClass("Backpack")
	local fxRemote = w.System.Remotes.GearFx

	-- regen
	give(p, "Regen Coil")
	humanoid.Health = 50
	humanoid:EquipTool(w.toolIn(backpack, "Regen Coil"))
	advance(0.05)
	w.Heartbeat:Fire(1)
	advance(0.01)
	check(near(humanoid.Health, 60), "regen coil heals 10 HP a second (" .. tostring(humanoid.Health) .. ")")
	for _ = 1, 10 do
		w.Heartbeat:Fire(1)
	end
	advance(0.01)
	check(near(humanoid.Health, 100), "regen stops at max health")
	w.toolIn(character, "Regen Coil").Parent = backpack
	advance(0.05)
	humanoid.Health = 40
	w.Heartbeat:Fire(1)
	advance(0.01)
	check(near(humanoid.Health, 40), "no healing once it's put away")

	-- jetpack: worn on the back while equipped
	give(p, "Jetpack")
	local jet = w.toolIn(backpack, "Jetpack")
	humanoid:EquipTool(jet)
	advance(0.05)
	local wear = character:FindFirstChild("StudGearWear")
	check(wear, "jetpack pack appears on the character")
	local weld = wear and wear.WearRoot and wear.WearRoot:FindFirstChildOfClass("WeldConstraint")
	check(weld and weld.Part0 == character.UpperTorso and weld.Part1 == wear.WearRoot, "pack welded to the torso")
	check(wear and near(wear.WearRoot.CFrame.Position.Z, 0.5), "pack sits on the back of the torso (z " .. tostring(wear and wear.WearRoot.CFrame.Position.Z) .. ")")
	check(root:FindFirstChild("StudGearTrail") == nil, "no running trail for the jetpack")
	local emitter = wear and wear:FindFirstChild("Nozzle"):FindFirstChild("Flame"):FindFirstChild("Flame")
	fxRemote.OnServerEvent:Fire(p, "Jet", true)
	advance(0.01)
	check(emitter and emitter.Enabled == true, "flying turns the flames on for everyone")
	fxRemote.OnServerEvent:Fire(p, "Jet", false)
	advance(0.01)
	check(emitter and emitter.Enabled == false, "and off again")
	jet.Parent = backpack
	advance(0.05)
	check(character:FindFirstChild("StudGearWear") == nil, "pack comes off when unequipped")

	-- grapple rope: everyone sees it, only within range, only while holding the hook
	advance(1.1)
	fxRemote.OnServerEvent:Fire(p, "Rope", roblox.Vector3.new(0, 30, -50))
	advance(0.01)
	check(w.terrain:FindFirstChild("StudGearRopeEnd") == nil, "no rope without holding the grapple")
	give(p, "Grapple Hook")
	local hook = w.toolIn(backpack, "Grapple Hook")
	humanoid:EquipTool(hook)
	advance(0.05)
	fxRemote.OnServerEvent:Fire(p, "Rope", roblox.Vector3.new(0, 30, -50))
	advance(0.01)
	local ropeEnd = w.terrain:FindFirstChild("StudGearRopeEnd")
	local beam = ropeEnd and ropeEnd:FindFirstChild("StudGearRope")
	check(beam and beam.Attachment1 == ropeEnd and beam.Attachment0 and beam.Attachment0.Name == "Muzzle", "rope from the hook to the target")
	check(beam and beam:GetAttribute("Owner") == p.UserId, "rope tagged with its owner (their own copy is hidden)")
	fxRemote.OnServerEvent:Fire(p, "Rope", nil)
	advance(0.01)
	check(w.terrain:FindFirstChild("StudGearRopeEnd") == nil, "letting go removes the rope")
	fxRemote.OnServerEvent:Fire(p, "Rope", roblox.Vector3.new(0, 3, -500))
	advance(0.01)
	check(w.terrain:FindFirstChild("StudGearRopeEnd") == nil, "out-of-range rope refused")
	fxRemote.OnServerEvent:Fire(p, "Rope", "garbage")
	advance(0.01)
	check(w.terrain:FindFirstChild("StudGearRopeEnd") == nil, "junk values refused")
	fxRemote.OnServerEvent:Fire(p, "Rope", roblox.Vector3.new(0, 30, -50))
	advance(0.01)
	hook.Parent = backpack
	advance(0.05)
	check(w.terrain:FindFirstChild("StudGearRopeEnd") == nil, "putting the hook away removes the rope")
	humanoid:EquipTool(hook)
	advance(0.05)
	fxRemote.OnServerEvent:Fire(p, "Rope", roblox.Vector3.new(0, 30, -50))
	advance(4.2)
	check(w.terrain:FindFirstChild("StudGearRopeEnd") == nil, "a rope is never left behind (auto-removed)")
	-- spam limit
	advance(1.1)
	for _ = 1, 40 do
		fxRemote.OnServerEvent:Fire(p, "Rope", nil)
	end
	advance(0.01)
	fxRemote.OnServerEvent:Fire(p, "Rope", roblox.Vector3.new(0, 30, -50))
	advance(0.01)
	check(w.terrain:FindFirstChild("StudGearRopeEnd") == nil, "spamming the remote gets ignored")
end

print(("[gear sim] %d passed, %d failed"):format(passes, failures))
if failures > 0 then
	error("gear sim failed")
end
