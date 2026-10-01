--!strict
-- Stud Pet System (server). Owns every player's coins, pets and equipped pets.
-- The server rolls every hatch, so exploiters can't choose what they get.
--
-- Remotes (ReplicatedStorage.StudPetSystem.Remotes):
--   Hatch:InvokeServer(eggName, count) -> { ok, results = {{Id, Pet, Rarity}}, err }
--   Equip:FireServer(petId, equipped)    Delete:FireServer({petIds})    EquipBest:FireServer()
--   Data (client <- server): the player's inventory whenever it changes
-- Equipped pets are published as a "StudPetsEquipped" attribute on the Player
-- ("Dog,Cat,Unicorn") so every client can show everyone's pets.

local DataStoreService = game:GetService("DataStoreService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local System = ReplicatedStorage:WaitForChild("StudPetSystem")
local Config = require(System:WaitForChild("Config"))
local Odds = require(System:WaitForChild("Odds"))(Config)

---------------------------------------------------------------------------
-- Currency adapter: swap these three functions to use your own currency.
---------------------------------------------------------------------------
local function setupCurrency(player: Player, saved: number?)
	local stats = player:FindFirstChild("leaderstats") or Instance.new("Folder")
	stats.Name = "leaderstats"
	local coins = stats:FindFirstChild(Config.Currency) :: IntValue? or Instance.new("IntValue")
	coins.Name = Config.Currency
	coins.Value = saved or Config.StartingCoins
	coins.Parent = stats
	stats.Parent = player
end

local function getCoins(player: Player): number
	local stats = player:FindFirstChild("leaderstats")
	local coins = stats and stats:FindFirstChild(Config.Currency) :: IntValue?
	return if coins then coins.Value else 0
end

local function addCoins(player: Player, amount: number)
	local stats = player:FindFirstChild("leaderstats")
	local coins = stats and stats:FindFirstChild(Config.Currency) :: IntValue?
	if coins then
		coins.Value += amount
	end
end

---------------------------------------------------------------------------
-- Remotes
---------------------------------------------------------------------------
local remotes = System:FindFirstChild("Remotes") or Instance.new("Folder")
remotes.Name = "Remotes"
local function remote(class: string, name: string): any
	local r = remotes:FindFirstChild(name) or Instance.new(class)
	r.Name = name
	r.Parent = remotes
	return r
end
local HatchRemote = remote("RemoteFunction", "Hatch")
local EquipRemote = remote("RemoteEvent", "Equip")
local DeleteRemote = remote("RemoteEvent", "Delete")
local EquipBestRemote = remote("RemoteEvent", "EquipBest")
local DataRemote = remote("RemoteEvent", "Data")
remotes.Parent = System

---------------------------------------------------------------------------
-- Player data
---------------------------------------------------------------------------
type Pet = { Id: string, Pet: string, Rarity: string }
type Data = { Coins: number, Pets: { Pet }, Equipped: { string }, NextId: number }

local store = nil
if Config.SaveData then
	local ok, result = pcall(function()
		return DataStoreService:GetDataStore(Config.DataStoreName)
	end)
	if ok then
		store = result
	else
		warn("[StudPetSystem] DataStore unavailable, progress won't save:", result)
	end
end

local data: { [Player]: Data } = {}
local loaded: { [Player]: boolean } = {}
local lastHatch: { [Player]: number } = {}
local lastAction: { [Player]: number } = {}
local savedOnClose: { [Player]: boolean } = {}

-- ignore spammed equip/delete requests
local function throttled(player: Player): boolean
	local now = os.clock()
	if now - (lastAction[player] or 0) < 0.15 then
		return true
	end
	lastAction[player] = now
	return false
end
local rng = Random.new()

local function key(player: Player): string
	return "player_" .. player.UserId
end

local function publish(player: Player)
	local d = data[player]
	if not d then
		return
	end
	local types = {}
	for _, id in d.Equipped do
		for _, p in d.Pets do
			if p.Id == id then
				table.insert(types, p.Pet)
				break
			end
		end
	end
	player:SetAttribute("StudPetsEquipped", table.concat(types, ","))
	DataRemote:FireClient(player, { Pets = d.Pets, Equipped = d.Equipped, MaxEquipped = Config.MaxEquipped, MaxInventory = Config.MaxInventory })
end

-- Session lock: while a server has a player's data open it stamps the save with its JobId.
-- Another server waits for that lock to be released (or go stale) before loading, so a
-- fast server hop can never load an older copy and overwrite newer progress.
local LOCK_STALE = 300 -- seconds; autosaves refresh the lock every 90 s
local LOAD_TRIES = 8 -- ~30 s of waiting for the old server to finish saving

local function load(player: Player)
	local saved: any = nil
	local loadedOk = store == nil
	if store then
		for attempt = 1, LOAD_TRIES do
			local lockedElsewhere = false
			local force = attempt == LOAD_TRIES -- last try: the old server must have died, take over
			local ok, result = pcall(function()
				return store:UpdateAsync(key(player), function(old)
					old = if type(old) == "table" then old else {}
					local lock = old.Lock
					if not force and type(lock) == "table" and lock.Job ~= game.JobId and os.time() - (lock.Time or 0) < LOCK_STALE then
						lockedElsewhere = true
						return nil -- leave it alone, try again shortly
					end
					old.Lock = { Job = game.JobId, Time = os.time() }
					return old
				end)
			end)
			if ok and not lockedElsewhere then
				saved = result
				loadedOk = true
				break
			end
			if not ok then
				warn(("[StudPetSystem] load failed for %s (try %d): %s"):format(player.Name, attempt, tostring(result)))
			end
			if attempt < LOAD_TRIES then
				task.wait(4)
			end
			if not player.Parent then
				return
			end
		end
	end
	if not player.Parent then
		return
	end
	if not loadedOk then
		-- never play on fresh data: the next save would overwrite their real progress
		player:Kick("Your pets couldn't be loaded right now. Please rejoin in a moment.")
		return
	end
	local d: Data = {
		Coins = if type(saved) == "table" and type(saved.Coins) == "number" then saved.Coins else Config.StartingCoins,
		Pets = if type(saved) == "table" and type(saved.Pets) == "table" then saved.Pets else {},
		Equipped = if type(saved) == "table" and type(saved.Equipped) == "table" then saved.Equipped else {},
		NextId = if type(saved) == "table" and type(saved.NextId) == "number" then saved.NextId else 1,
	}
	data[player] = d
	setupCurrency(player, d.Coins)
	loaded[player] = true
	publish(player)
end

local function save(player: Player, release: boolean?)
	local d = data[player]
	if not (store and d and loaded[player]) then
		return
	end
	d.Coins = getCoins(player)
	local ok, err = pcall(function()
		store:UpdateAsync(key(player), function(old)
			-- another server took this player over: never overwrite its newer data
			if type(old) == "table" and type(old.Lock) == "table" and old.Lock.Job ~= game.JobId then
				return nil
			end
			local out = table.clone(d)
			out.Lock = if release then nil else { Job = game.JobId, Time = os.time() }
			return out
		end)
	end)
	if not ok then
		warn(("[StudPetSystem] save failed for %s: %s"):format(player.Name, tostring(err)))
	end
end

---------------------------------------------------------------------------
-- Actions
---------------------------------------------------------------------------
local function findPet(d: Data, id: string): (Pet?, number?)
	for i, p in d.Pets do
		if p.Id == id then
			return p, i
		end
	end
	return nil, nil
end

HatchRemote.OnServerInvoke = function(player: Player, eggName: any, count: any)
	local d = data[player]
	if not d then
		return { ok = false, err = "Loading..." }
	end
	if type(eggName) ~= "string" then
		return { ok = false, err = "Bad egg" }
	end
	local egg = Odds.GetEgg(eggName)
	if not egg then
		return { ok = false, err = "Bad egg" }
	end
	local n = if count == 3 and Config.TripleHatch then 3 else 1
	local now = os.clock()
	if now - (lastHatch[player] or 0) < Config.HatchCooldown then
		return { ok = false, err = "Slow down!" }
	end
	if #d.Pets + n > Config.MaxInventory then
		return { ok = false, err = "Inventory full" }
	end
	local cost = egg.Price * n
	if getCoins(player) < cost then
		return { ok = false, err = ("Need %d %s"):format(cost, Config.Currency) }
	end
	lastHatch[player] = now
	addCoins(player, -cost)
	local results = {}
	for _ = 1, n do
		local roll = Odds.Roll(egg, rng)
		local pet = { Id = tostring(d.NextId), Pet = roll.Pet, Rarity = roll.Rarity }
		d.NextId += 1
		table.insert(d.Pets, pet)
		table.insert(results, pet)
	end
	publish(player)
	return { ok = true, results = results }
end

EquipRemote.OnServerEvent:Connect(function(player: Player, id: any, equip: any)
	local d = data[player]
	if throttled(player) or not d or type(id) ~= "string" or not findPet(d, id) then
		return
	end
	local at = table.find(d.Equipped, id)
	if equip and not at and #d.Equipped < Config.MaxEquipped then
		table.insert(d.Equipped, id)
	elseif not equip and at then
		table.remove(d.Equipped, at)
	end
	publish(player)
end)

DeleteRemote.OnServerEvent:Connect(function(player: Player, ids: any)
	local d = data[player]
	if throttled(player) or not d or type(ids) ~= "table" or #ids > Config.MaxInventory then
		return
	end
	for _, id in ids do
		if type(id) == "string" then
			local _, i = findPet(d, id)
			if i then
				table.remove(d.Pets, i)
				local at = table.find(d.Equipped, id)
				if at then
					table.remove(d.Equipped, at)
				end
			end
		end
	end
	publish(player)
end)

EquipBestRemote.OnServerEvent:Connect(function(player: Player)
	local d = data[player]
	if throttled(player) or not d then
		return
	end
	local sorted = table.clone(d.Pets)
	table.sort(sorted, function(a, b)
		return Odds.RarityRank(a.Rarity) > Odds.RarityRank(b.Rarity)
	end)
	d.Equipped = {}
	for i = 1, math.min(Config.MaxEquipped, #sorted) do
		table.insert(d.Equipped, sorted[i].Id)
	end
	publish(player)
end)

---------------------------------------------------------------------------
-- Lifecycle
---------------------------------------------------------------------------
Players.PlayerAdded:Connect(load)
for _, p in Players:GetPlayers() do
	task.spawn(load, p)
end
Players.PlayerRemoving:Connect(function(player)
	if not savedOnClose[player] then
		save(player, true)
	end
	data[player] = nil
	loaded[player] = nil
	lastHatch[player] = nil
	lastAction[player] = nil
	savedOnClose[player] = nil
end)
game:BindToClose(function()
	if not store then
		return
	end
	-- save everyone once and wait for those saves to finish (Roblox allows ~30 s)
	local pending = 0
	for _, p in Players:GetPlayers() do
		if loaded[p] then
			pending += 1
			savedOnClose[p] = true
			task.spawn(function()
				save(p, true)
				pending -= 1
			end)
		end
	end
	local waited = 0
	while pending > 0 and waited < 25 do
		waited += task.wait(0.2)
	end
end)

-- autosave + demo income
task.spawn(function()
	local t = 0
	while true do
		task.wait(1)
		t += 1
		if Config.PassiveIncome > 0 then
			for p in data do
				addCoins(p, Config.PassiveIncome)
			end
		end
		if t % 90 == 0 then
			for p in data do
				task.spawn(save, p)
			end
		end
	end
end)
