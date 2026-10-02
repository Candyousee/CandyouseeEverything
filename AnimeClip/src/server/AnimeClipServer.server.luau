--!strict
-- Anime clip (server): builds the two fighters for each player who joins.
--   Hero  = that player's own avatar (R15)
--   Rival = Config.RivalUsername's avatar
-- If an avatar can't be loaded, the blocky stand-in fighter is used instead.
-- The fighters are anchored and the client animates them.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local System = ReplicatedStorage:WaitForChild("AnimeClip")
local Config = require(System:WaitForChild("Config")) :: any
local Stand = ReplicatedStorage:WaitForChild("AnimeClipStandIns")

local folder = workspace:FindFirstChild("AnimeClipActors") or Instance.new("Folder")
folder.Name = "AnimeClipActors"
folder.Parent = workspace

local function prepare(model: Model, name: string)
	model.Name = name
	for _, d in model:GetDescendants() do
		if d:IsA("BasePart") then
			d.CanCollide = false
			d.CanTouch = false
			d.CanQuery = false
			d.Anchored = false
		elseif d:IsA("Script") or d:IsA("LocalScript") then
			d:Destroy() -- e.g. the Animate script: the clip drives every joint itself
		end
	end
	local root = model:FindFirstChild("HumanoidRootPart") :: BasePart?
	if root then
		root.Anchored = true
		root.CFrame = CFrame.new(0, -400, 0)
	end
	local humanoid = model:FindFirstChildOfClass("Humanoid")
	if humanoid then
		humanoid.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.None
		humanoid.HealthDisplayType = Enum.HumanoidHealthDisplayType.AlwaysOff
		humanoid.EvaluateStateMachine = false
		humanoid.BreakJointsOnDeath = false
	end
end

local function avatarFor(userId: number?): Model?
	if not userId then
		return nil
	end
	local ok, model = pcall(function()
		local desc = Players:GetHumanoidDescriptionFromUserId(userId)
		return Players:CreateHumanoidModelFromDescription(desc, Enum.HumanoidRigType.R15)
	end)
	if ok and model then
		return model
	end
	warn("[AnimeClip] couldn't load avatar", userId, model)
	return nil
end

local rivalId: number? = nil
do
	local ok, id = pcall(Players.GetUserIdFromNameAsync, Players, Config.RivalUsername)
	if ok then
		rivalId = id
	else
		warn("[AnimeClip] couldn't find rival user", Config.RivalUsername)
	end
end

local function setup(player: Player)
	local mine = folder:FindFirstChild(tostring(player.UserId)) or Instance.new("Folder")
	mine.Name = tostring(player.UserId)
	mine:ClearAllChildren()
	local hero = avatarFor(player.UserId) or (Stand:WaitForChild("Hero") :: Model):Clone()
	local rival = avatarFor(rivalId) or (Stand:WaitForChild("Rival") :: Model):Clone()
	prepare(hero, "Hero")
	prepare(rival, "Rival")
	hero.Parent = mine
	rival.Parent = mine
	mine.Parent = folder
end

Players.PlayerAdded:Connect(setup)
for _, p in Players:GetPlayers() do
	task.spawn(setup, p)
end
Players.PlayerRemoving:Connect(function(p)
	local mine = folder:FindFirstChild(tostring(p.UserId))
	if mine then
		mine:Destroy()
	end
end)
