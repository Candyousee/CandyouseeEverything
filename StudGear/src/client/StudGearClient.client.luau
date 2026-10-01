-- Stud Gear (client): spins the coils on their display stands and shows each player
-- whether a piece of gear is FREE, its price, or OWNED. (All gear effects run on the server.)

local CollectionService = game:GetService("CollectionService")
local MarketplaceService = game:GetService("MarketplaceService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local function findSystem(): Instance
	local started = os.clock()
	local reported = false
	while true do
		local direct = ReplicatedStorage:FindFirstChild("StudGear")
		if direct and direct:IsA("Folder") then
			return direct
		end
		for _, d in ReplicatedStorage:GetDescendants() do
			if d.Name == "StudGear" and d:IsA("Folder") then
				return d
			end
		end
		if not reported and os.clock() - started > 6 then
			reported = true
			warn("[StudGear] ReplicatedStorage is missing the StudGear folder (from 1_PutInReplicatedStorage).")
		end
		task.wait(0.25)
	end
end
local Config = require(findSystem():WaitForChild("Config"))
local player = Players.LocalPlayer
local FONT = Font.new("rbxasset://fonts/families/FredokaOne.json", Enum.FontWeight.Bold)

local byName = {}
for _, g in Config.Gear do
	byName[g.Name] = g
end

local prices: { [number]: number? } = {}
local function priceOf(id: number): number?
	if prices[id] == nil then
		local ok, info = pcall(MarketplaceService.GetProductInfo, MarketplaceService, id, Enum.InfoType.GamePass)
		prices[id] = if ok and info and info.PriceInRobux then info.PriceInRobux else false :: any
	end
	return prices[id] or nil
end

local function ownsLocally(gear): boolean
	if (gear.GamePassId or 0) == 0 then
		return true
	end
	local list = player:GetAttribute("StudGearOwned") or ""
	return table.find(string.split(list, ","), gear.Name) ~= nil
end

local displays = {}

local function refreshDisplay(d)
	local gear = d.gear
	local paid = (gear.GamePassId or 0) ~= 0
	local own = ownsLocally(gear)
	if paid and own then
		d.status.Text = "OWNED"
		d.status.TextColor3 = Color3.fromRGB(120, 255, 140)
	elseif paid then
		local p = priceOf(gear.GamePassId)
		d.status.Text = if p then ("R$ %d"):format(p) else "GAME PASS"
		d.status.TextColor3 = Color3.fromRGB(120, 230, 120)
	else
		d.status.Text = "FREE"
		d.status.TextColor3 = Color3.fromRGB(255, 220, 90)
	end
	if d.prompt then
		d.prompt.ActionText = if own then (if paid then "Equip" else "Get") else "Buy"
	end
end

local function setup(stand: Instance)
	local gear = byName[stand:GetAttribute("StudGearDisplay") or ""]
	if not gear or not stand:IsA("Model") then
		return
	end
	local coil = stand:WaitForChild("Coil", 10) :: Model?
	local top = stand.PrimaryPart
	if not top then
		return
	end
	local gui = Instance.new("BillboardGui")
	gui.Name = "StudGearLabel"
	gui.Size = UDim2.fromOffset(200, 64)
	gui.StudsOffsetWorldSpace = Vector3.new(0, 6.2, 0)
	gui.MaxDistance = 70
	gui.LightInfluence = 0
	gui.Adornee = top
	local name = Instance.new("TextLabel")
	name.BackgroundTransparency = 1
	name.Size = UDim2.new(1, 0, 0.55, 0)
	name.FontFace = FONT
	name.TextScaled = true
	name.TextColor3 = Color3.new(1, 1, 1)
	name.TextStrokeTransparency = 0.2
	name.Text = gear.Name
	name.Parent = gui
	local status = name:Clone()
	status.Position = UDim2.fromScale(0, 0.55)
	status.Size = UDim2.new(1, 0, 0.42, 0)
	status.Parent = gui
	gui.Parent = top
	local d = {
		gear = gear,
		status = status,
		coil = coil,
		base = coil and coil:GetPivot(),
		prompt = top:WaitForChild("StudGearPrompt", 10),
		phase = math.random() * 6,
	}
	displays[stand] = d
	refreshDisplay(d)
	stand.AncestryChanged:Connect(function()
		if not stand:IsDescendantOf(game) then
			displays[stand] = nil
		end
	end)
end

for _, s in CollectionService:GetTagged("StudGearDisplay") do
	task.spawn(setup, s)
end
CollectionService:GetInstanceAddedSignal("StudGearDisplay"):Connect(setup)
player:GetAttributeChangedSignal("StudGearOwned"):Connect(function()
	for _, d in displays do
		refreshDisplay(d)
	end
end)

-- spin + bob the display coils near you
local t = 0
RunService.RenderStepped:Connect(function(dt)
	t += dt
	local cam = workspace.CurrentCamera
	for _, d in displays do
		if d.coil and d.base and cam and (cam.CFrame.Position - d.base.Position).Magnitude < 120 then
			local k = t + d.phase
			d.coil:PivotTo(d.base * CFrame.new(0, 0.3 * math.sin(k * 2), 0) * CFrame.Angles(0, k * 1.2, 0))
		end
	end
end)
