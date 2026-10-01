-- Finds the system's folders in ReplicatedStorage, even when they were dropped in still
-- inside the package's "1_PutInReplicatedStorage" folder. Waits until they exist; if one is
-- still missing after a few seconds it says so in Output (and on screen in Studio).

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local HELP = {
	StudPetSystem = "ReplicatedStorage is missing the StudPetSystem folder (from 1_PutInReplicatedStorage).",
	StudPets = "ReplicatedStorage is missing the StudPets folder (from 1_PutInReplicatedStorage).",
	StudPetModels = "ReplicatedStorage is missing the StudPetModels folder (from 1_PutInReplicatedStorage).",
	StudPetSystemEggs = "ReplicatedStorage is missing the StudPetSystemEggs folder (from 1_PutInReplicatedStorage).",
	Remotes = "The server script isn't running: put the 2_PutInServerScriptService folder (StudPetSystemServer script) in ServerScriptService.",
}

local shown: { [string]: boolean } = {}
local helpLabel: TextLabel? = nil

local function report(name: string)
	local msg = HELP[name] or ("Missing " .. name)
	warn("[StudPetSystem] " .. msg)
	if not RunService:IsStudio() or shown[name] then
		return
	end
	shown[name] = true
	-- in Studio, put it on screen too so it can't be missed
	local player = Players.LocalPlayer
	local gui = player and player:FindFirstChild("PlayerGui")
	if not gui then
		return
	end
	if not helpLabel then
		local sg = Instance.new("ScreenGui")
		sg.Name = "StudPetSystemSetupHelp"
		sg.ResetOnSpawn = false
		sg.DisplayOrder = 100
		local l = Instance.new("TextLabel")
		l.AnchorPoint = Vector2.new(0.5, 0)
		l.Position = UDim2.new(0.5, 0, 0, 70)
		l.Size = UDim2.new(0.8, 0, 0, 0)
		l.AutomaticSize = Enum.AutomaticSize.Y
		l.BackgroundColor3 = Color3.fromRGB(120, 24, 24)
		l.BackgroundTransparency = 0.1
		l.TextColor3 = Color3.new(1, 1, 1)
		l.TextWrapped = true
		l.TextSize = 18
		l.Font = Enum.Font.GothamBold
		l.Text = "Stud Pet System setup:"
		local p = Instance.new("UIPadding")
		p.PaddingTop, p.PaddingBottom, p.PaddingLeft, p.PaddingRight = UDim.new(0, 8), UDim.new(0, 8), UDim.new(0, 12), UDim.new(0, 12)
		p.Parent = l
		l.Parent = sg
		sg.Parent = gui
		helpLabel = l
	end
	local l = helpLabel :: TextLabel
	l.Text ..= "\n• " .. msg
end

local function search(parent: Instance, name: string): Instance?
	local direct = parent:FindFirstChild(name)
	if direct and direct:IsA("Folder") then
		return direct
	end
	for _, d in parent:GetDescendants() do
		if d.Name == name and d:IsA("Folder") then
			return d
		end
	end
	return nil
end

local Find = {}

-- A system folder anywhere inside ReplicatedStorage (or inside `parent` if given).
function Find.Folder(name: string, parent: Instance?): Instance
	local root = parent or ReplicatedStorage
	local started = os.clock()
	local reported = false
	while true do
		local found = search(root, name)
		if found then
			if reported and helpLabel then
				helpLabel.Text = helpLabel.Text:gsub("\n• [^\n]*" .. name .. "[^\n]*", "")
			end
			return found
		end
		if not reported and os.clock() - started > 6 then
			reported = true
			report(name)
		end
		task.wait(0.25)
	end
end

return Find
