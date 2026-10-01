-- Runs the real Stud Pet System server script against fake Roblox services (players,
-- DataStore, remotes, a virtual clock) and plays through what a game does with it:
-- join, hatch x1 / x3, equip, equip best, delete, leave, rejoin - in Studio with no API
-- access, and live with saving and session locks.
--   lune run build/test_server_sim.luau

local fs = require("@lune/fs")
local luau = require("@lune/luau")

-- read every source up front: fs reads yield, which would stall the fake scheduler
local SOURCES = {}
for _, path in {
	"src/petsystem/shared/StudPetSystem/Config.luau",
	"src/petsystem/shared/StudPetSystem/Odds.luau",
	"src/petsystem/shared/StudPetSystem/HatchSequence.luau",
	"src/petsystem/server/StudPetSystem.server.luau",
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

---------------------------------------------------------------------------
-- tiny scheduler with a virtual clock
---------------------------------------------------------------------------
local now = 0
local queue: { { at: number, co: thread, args: { any } } } = {}
local function schedule(co, at, ...)
	table.insert(queue, { at = at, co = co, args = { ... } })
end
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
	wait = function(n)
		local start = now
		schedule(coroutine.running(), now + (n or 0.03))
		coroutine.yield()
		return now - start
	end,
	delay = function(n, fn, ...)
		schedule(coroutine.create(fn), now + n, ...)
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
		resume(nxt.co, table.unpack(nxt.args))
	end
	now = target
end

---------------------------------------------------------------------------
-- fake instances
---------------------------------------------------------------------------
local function signal()
	local s = { fns = {} }
	function s:Connect(fn)
		table.insert(self.fns, fn)
		return { Disconnect = function() end }
	end
	function s:Fire(...)
		for _, fn in self.fns do
			Task.spawn(fn, ...)
		end
	end
	return s
end

local Inst = {}
Inst.__index = function(self, k)
	local v = rawget(Inst, k)
	if v ~= nil then
		return v
	end
	local props = rawget(self, "_props")
	if props[k] ~= nil then
		return props[k]
	end
	return self:FindFirstChild(k)
end
Inst.__newindex = function(self, k, v)
	local props = rawget(self, "_props")
	if k == "Parent" then
		local old = props.Parent
		if old then
			local list = rawget(old, "_children")
			local i = table.find(list, self)
			if i then
				table.remove(list, i)
			end
		end
		if v then
			table.insert(rawget(v, "_children"), self)
		end
	end
	props[k] = v
end
local function new(class, props)
	local o = setmetatable({ _props = { ClassName = class, Name = class }, _children = {}, _attrs = {} }, Inst)
	for k, v in props or {} do
		o[k] = v
	end
	if class == "RemoteEvent" then
		rawget(o, "_props").OnServerEvent = signal()
		rawget(o, "_props").fired = {}
		rawget(o, "_props").FireClient = function(self, plr, data)
			table.insert(self.fired, { plr, data })
		end
	end
	return o
end
function Inst:FindFirstChild(name)
	for _, c in rawget(self, "_children") do
		if c.Name == name then
			return c
		end
	end
	return nil
end
function Inst:WaitForChild(name)
	local c = self:FindFirstChild(name)
	assert(c, "WaitForChild would hang forever: " .. name)
	return c
end
function Inst:GetChildren()
	return table.clone(rawget(self, "_children"))
end
function Inst:GetDescendants()
	local out = {}
	local function walk(o)
		for _, c in rawget(o, "_children") do
			table.insert(out, c)
			walk(c)
		end
	end
	walk(self)
	return out
end
function Inst:SetAttribute(k, v)
	rawget(self, "_attrs")[k] = v
end
function Inst:GetAttribute(k)
	return rawget(self, "_attrs")[k]
end
function Inst:IsA(c)
	return self.ClassName == c
end
function Inst:Kick(msg)
	rawget(self, "_props").kicked = msg
end

---------------------------------------------------------------------------
-- fake services
---------------------------------------------------------------------------
local function makeWorld(opts)
	local env = {}
	local Players = new("Players")
	rawget(Players, "_props").PlayerAdded = signal()
	rawget(Players, "_props").PlayerRemoving = signal()
	rawget(Players, "_props").GetPlayers = function(self)
		return self:GetChildren()
	end
	local RS = new("ReplicatedStorage")
	-- opts.nested: dropped in still inside the package folder, like most people do
	local holder = if opts.nested then new("Folder", { Name = "1_PutInReplicatedStorage", Parent = RS }) else RS
	local System = new("Folder", { Name = "StudPetSystem", Parent = holder })
	for _, name in { "Config", "Odds", "HatchSequence" } do
		new("ModuleScript", { Name = name, Parent = System, Path = "src/petsystem/shared/StudPetSystem/" .. name .. ".luau" })
	end
	local saved = opts.saved or {}
	local DataStoreService = new("DataStoreService")
	rawget(DataStoreService, "_props").GetDataStore = function()
		if opts.noDataStore then
			error("You must publish this place to the web to access DataStore.")
		end
		return {
			UpdateAsync = function(_, key, fn)
				if opts.apiOff then
					error("StudioAccessToApisNotAllowed: Studio access to APIs is not allowed.")
				end
				local old = saved[key]
				local copy = if old then luau.load("return " .. old)() else nil
				local new = fn(copy)
				if new ~= nil then
					-- store as a Luau literal so later reads get fresh tables
					local function ser(v)
						if type(v) == "table" then
							local parts = {}
							for k2, v2 in v do
								table.insert(parts, "[" .. ser(k2) .. "]=" .. ser(v2))
							end
							return "{" .. table.concat(parts, ",") .. "}"
						elseif type(v) == "string" then
							return string.format("%q", v)
						end
						return tostring(v)
					end
					saved[key] = ser(new)
					return luau.load("return " .. saved[key])()
				end
				return copy
			end,
		}
	end
	local RunService = new("RunService")
	rawget(RunService, "_props").IsStudio = function()
		return opts.studio == true
	end
	local closers = {}
	local game = {
		JobId = opts.job or "job-A",
		GetService = function(_, name)
			return ({ Players = Players, ReplicatedStorage = RS, DataStoreService = DataStoreService, RunService = RunService })[name]
				or error("no fake for service " .. name)
		end,
		BindToClose = function(_, fn)
			table.insert(closers, fn)
		end,
	}
	local cache = {}
	local function fakeRequire(m)
		local path = m.Path
		if cache[path] == nil then
			cache[path] = luau.load(SOURCES[path], { debugName = path, environment = env })()
		end
		return cache[path]
	end
	env.game = game
	env.task = Task
	env.require = fakeRequire
	env.warn = function(...)
		if opts.log then
			print("    warn:", ...)
		end
	end
	env.Instance = {
		new = function(class)
			return new(class)
		end,
	}
	env.Random = {
		new = function()
			return {
				NextNumber = function(_, a, b)
					a, b = a or 0, b or 1
					return a + math.random() * (b - a)
				end,
				NextInteger = function(_, a, b)
					return math.random(a, b)
				end,
			}
		end,
	}
	env.os = { clock = function()
		return now
	end, time = function()
		return 1700000000 + math.floor(now)
	end }
	local script = luau.load(SOURCES["src/petsystem/server/StudPetSystem.server.luau"], { debugName = "StudPetSystem.server", environment = env })
	Task.spawn(script)
	local remotes = System:FindFirstChild("Remotes")
	local userId = 100
	local world = { Players = Players, remotes = remotes, saved = saved, closers = closers, Config = fakeRequire(System.Config) }
	function world.join(name)
		userId += 1
		local p = new("Player", { Name = name, UserId = userId, Parent = Players })
		Players.PlayerAdded:Fire(p)
		return p
	end
	function world.leave(p)
		p.Parent = nil
		Players.PlayerRemoving:Fire(p)
	end
	function world.coins(p)
		local ls = p:FindFirstChild("leaderstats")
		local c = ls and ls:FindFirstChild(world.Config.Currency)
		return c and c.Value
	end
	function world.hatch(p, egg, n)
		local co = coroutine.create(remotes.Hatch.OnServerInvoke)
		local _, res = coroutine.resume(co, p, egg, n)
		return res
	end
	function world.lastData(p)
		local last
		for _, f in remotes.Data.fired do
			if f[1] == p then
				last = f[2]
			end
		end
		return last
	end
	return world
end

---------------------------------------------------------------------------
-- scenarios
---------------------------------------------------------------------------
local function playthrough(w, label)
	local p = w.join("Tester")
	advance(1)
	check(p.kicked == nil, label .. ": player not kicked (" .. tostring(p.kicked) .. ")")
	local startCoins = w.Config.StartingCoins
	check(w.coins(p) ~= nil and w.coins(p) >= startCoins, label .. ": leaderstats coins exist (" .. tostring(w.coins(p)) .. ")")
	check(w.remotes and w.remotes:FindFirstChild("Hatch") and w.remotes:FindFirstChild("Data"), label .. ": remotes created")
	local before = w.coins(p)
	local egg = w.Config.Eggs[1]
	local r = w.hatch(p, egg.Name, 1)
	check(r and r.ok and #r.results == 1, label .. ": hatch x1 ok (" .. tostring(r and r.err) .. ")")
	check(w.coins(p) == before - egg.Price, label .. ": hatch x1 charged the price")
	local r2 = w.hatch(p, egg.Name, 1)
	check(r2 and not r2.ok and r2.err == "Slow down!", label .. ": cooldown blocks instant re-hatch")
	advance(1)
	local r3 = w.hatch(p, egg.Name, 3)
	check(r3 and r3.ok and #r3.results == 3, label .. ": hatch x3 ok")
	local d = w.lastData(p)
	check(d and #d.Pets == 4, label .. ": inventory has 4 pets (" .. tostring(d and #d.Pets) .. ")")
	for _, pet in r3.results do
		local found = false
		for _, e in egg.Pets do
			found = found or (e.Pet == pet.Pet and e.Rarity == pet.Rarity)
		end
		check(found, label .. ": hatched pet " .. pet.Pet .. " is in " .. egg.Name)
	end
	advance(1)
	check(not w.hatch(p, "Nope Egg", 1).ok, label .. ": unknown egg refused")
	advance(1)
	check(not w.hatch(p, w.Config.Eggs[#w.Config.Eggs].Name, 1).ok, label .. ": can't afford the Mythic egg")
	-- equip
	w.remotes.Equip.OnServerEvent:Fire(p, r.results[1].Id, true)
	advance(0.3)
	check(p:GetAttribute("StudPetsEquipped") == r.results[1].Pet, label .. ": equip publishes the follower attribute")
	w.remotes.EquipBest.OnServerEvent:Fire(p)
	advance(0.3)
	d = w.lastData(p)
	check(#d.Equipped == math.min(w.Config.MaxEquipped, 4), label .. ": equip best fills the slots")
	local equippedCount = #string.split(p:GetAttribute("StudPetsEquipped") or "", ",")
	check(equippedCount == #d.Equipped, label .. ": attribute lists every equipped pet")
	w.remotes.Delete.OnServerEvent:Fire(p, { d.Pets[1].Id, d.Pets[2].Id })
	advance(0.3)
	d = w.lastData(p)
	check(#d.Pets == 2, label .. ": delete removed 2 pets")
	return p
end

print("[studio, place not published]")
do
	local w = makeWorld({ studio = true, noDataStore = true })
	playthrough(w, "unpublished")
end

print("[studio, folders left inside 1_PutInReplicatedStorage]")
do
	local w = makeWorld({ studio = true, noDataStore = true, nested = true })
	playthrough(w, "nested")
end

print("[studio, API access off]")
do
	local w = makeWorld({ studio = true, apiOff = true })
	local p = w.join("Tester")
	advance(0.5)
	check(p.kicked == nil and w.coins(p) ~= nil, "api-off: plays right away without saving")
	local r = w.hatch(p, w.Config.Eggs[1].Name, 1)
	check(r and r.ok, "api-off: hatch works")
end

print("[live, saving]")
do
	local saved = {}
	local w = makeWorld({ studio = false, saved = saved, job = "job-A" })
	local p = playthrough(w, "live")
	local coins = w.coins(p)
	w.leave(p)
	advance(1)
	local key = "player_" .. p.UserId
	check(saved[key] ~= nil, "live: data saved on leave")
	check(saved[key] and not string.find(saved[key], "Lock", 1, true), "live: session lock released on leave")
	-- rejoin on another server
	local w2 = makeWorld({ studio = false, saved = saved, job = "job-B" })
	local p2 = new("Player", { Name = "Tester", UserId = p.UserId, Parent = w2.Players })
	w2.Players.PlayerAdded:Fire(p2)
	advance(1)
	local d = w2.lastData(p2)
	check(d and #d.Pets == 2, "live: pets restored after rejoin")
	local c2 = w2.coins(p2) or -1
	-- (the demo's passive income keeps ticking for the second it takes to rejoin)
	check(c2 >= coins and c2 <= coins + 2 * w2.Config.PassiveIncome, ("live: coins restored after rejoin (%d -> %d)"):format(coins, c2))
end

print("[live, previous server still holds the lock]")
do
	local saved = {}
	local w = makeWorld({ studio = false, saved = saved, job = "job-A" })
	local p = w.join("Hopper")
	advance(1)
	-- p is still "in" job-A; join job-B without leaving
	local w2 = makeWorld({ studio = false, saved = saved, job = "job-B" })
	local p2 = new("Player", { Name = "Hopper", UserId = p.UserId, Parent = w2.Players })
	w2.Players.PlayerAdded:Fire(p2)
	advance(5)
	check(w2.coins(p2) == nil, "lock: waits while another server has the player")
	w.leave(p) -- old server saves and releases
	advance(10)
	check(w2.coins(p2) ~= nil and p2.kicked == nil, "lock: loads once the old server lets go")
end

print(("[server sim] %d passed, %d failed"):format(passes, failures))
if failures > 0 then
	error("server sim failed")
end
