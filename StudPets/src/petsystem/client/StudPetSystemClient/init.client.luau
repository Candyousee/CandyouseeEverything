-- Stud Pet System (client): egg prompts + odds boards, the hatch cinematic,
-- the pets inventory (B), coins display, and everyone's following pets.

local CollectionService = game:GetService("CollectionService")
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

local Find = require(script:WaitForChild("Find"))
local System = Find.Folder("StudPetSystem")
local Config = require(System:WaitForChild("Config"))
local Odds = require(System:WaitForChild("Odds"))(Config)
local Remotes = Find.Folder("Remotes", System) -- made by the server script
local PetModels = Find.Folder("StudPetModels")

local HatchPlayer = require(script:WaitForChild("HatchPlayer"))
local Followers = require(script:WaitForChild("Followers"))
local Sounds = require(script:WaitForChild("Sounds"))

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
local FONT = Font.new("rbxasset://fonts/families/FredokaOne.json")

local function rgb(t)
	return Color3.fromRGB(t[1], t[2], t[3])
end

local function pretty(name: string): string
	return (name:gsub("(%l)(%u)", "%1 %2"))
end

local function commas(n: number): string
	local s = tostring(math.floor(n))
	repeat
		local k
		s, k = s:gsub("^(-?%d+)(%d%d%d)", "%1,%2")
	until k == 0
	return s
end

local function corner(parent, r)
	local c = Instance.new("UICorner")
	c.CornerRadius = UDim.new(0, r or 10)
	c.Parent = parent
end

local function stroke(parent, color, thick)
	local s = Instance.new("UIStroke")
	s.Color = color or Color3.fromRGB(30, 30, 46)
	s.Thickness = thick or 2
	s.Parent = parent
	return s
end

local function label(parent, props)
	local l = Instance.new("TextLabel")
	l.BackgroundTransparency = 1
	l.FontFace = FONT
	l.TextColor3 = Color3.new(1, 1, 1)
	l.TextScaled = true
	for k, v in props do
		(l :: any)[k] = v
	end
	l.Parent = parent
	return l
end

local function button(parent, text, color, props)
	local b = Instance.new("TextButton")
	b.AutoButtonColor = true
	b.BackgroundColor3 = color
	b.FontFace = FONT
	b.Text = text
	b.TextColor3 = Color3.new(1, 1, 1)
	b.TextScaled = true
	for k, v in props do
		(b :: any)[k] = v
	end
	corner(b, 10)
	stroke(b, Color3.fromRGB(30, 30, 46), 2).ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	local pad = Instance.new("UIPadding")
	pad.PaddingTop, pad.PaddingBottom = UDim.new(0.15, 0), UDim.new(0.15, 0)
	pad.Parent = b
	b.Parent = parent
	b.Activated:Connect(function()
		Sounds.Play("Click")
	end)
	return b
end

---------------------------------------------------------------------------
-- HUD: coins + toast messages
---------------------------------------------------------------------------
local hud = Instance.new("ScreenGui")
hud.Name = "StudPetSystemHUD"
hud.ResetOnSpawn = false
hud.Parent = playerGui

local coinBox = Instance.new("Frame")
coinBox.AnchorPoint = Vector2.new(0.5, 0)
coinBox.Position = UDim2.new(0.5, 0, 0, 10)
coinBox.Size = UDim2.fromOffset(200, 44)
coinBox.BackgroundColor3 = Color3.fromRGB(255, 200, 60)
corner(coinBox, 14)
stroke(coinBox, Color3.fromRGB(120, 80, 20), 3)
coinBox.Parent = hud
local coinText = label(coinBox, { Size = UDim2.fromScale(1, 1), Text = "0", TextStrokeTransparency = 0.3 })
local pad = Instance.new("UIPadding")
pad.PaddingTop, pad.PaddingBottom = UDim.new(0, 6), UDim.new(0, 6)
pad.Parent = coinBox

local function watchCoins()
	local stats = player:WaitForChild("leaderstats")
	local coins = stats:WaitForChild(Config.Currency) :: IntValue
	local function show()
		coinText.Text = "💰 " .. commas(coins.Value)
	end
	show()
	coins.Changed:Connect(show)
end
task.spawn(watchCoins)

local toast = label(hud, {
	AnchorPoint = Vector2.new(0.5, 0),
	Position = UDim2.new(0.5, 0, 0, 62),
	Size = UDim2.fromOffset(420, 34),
	TextTransparency = 1,
	TextStrokeTransparency = 1,
	TextColor3 = Color3.fromRGB(255, 120, 110),
})
local toastId = 0
local function showToast(text: string)
	toastId += 1
	local id = toastId
	toast.Text = text
	toast.TextTransparency, toast.TextStrokeTransparency = 0, 0.2
	task.delay(1.8, function()
		if id == toastId then
			TweenService:Create(toast, TweenInfo.new(0.4), { TextTransparency = 1, TextStrokeTransparency = 1 }):Play()
		end
	end)
end

---------------------------------------------------------------------------
-- Inventory
---------------------------------------------------------------------------
local inv = { Pets = {}, Equipped = {}, MaxEquipped = Config.MaxEquipped, MaxInventory = Config.MaxInventory }
local deleteMode = false
local selected: { [string]: boolean } = {}

local ui = Instance.new("ScreenGui")
ui.Name = "StudPetSystemInventory"
ui.ResetOnSpawn = false
ui.Enabled = false
ui.Parent = playerGui

local petsButton = button(hud, "🐾 Pets", Color3.fromRGB(90, 160, 255), {
	AnchorPoint = Vector2.new(0, 0.5),
	Position = UDim2.new(0, 14, 0.5, 0),
	Size = UDim2.fromOffset(120, 50),
})

local panel = Instance.new("Frame")
panel.AnchorPoint = Vector2.new(0.5, 0.5)
panel.Position = UDim2.fromScale(0.5, 0.5)
panel.Size = UDim2.fromOffset(640, 440)
panel.BackgroundColor3 = Color3.fromRGB(46, 52, 74)
corner(panel, 18)
stroke(panel, Color3.fromRGB(20, 22, 34), 4)
panel.Parent = ui
local sizeLimit = Instance.new("UISizeConstraint")
sizeLimit.MaxSize = Vector2.new(640, 440)
sizeLimit.Parent = panel
local aspect = Instance.new("UIAspectRatioConstraint")
aspect.AspectRatio = 640 / 440
aspect.Parent = panel
panel.Size = UDim2.new(0.9, 0, 0.9, 0)

local title = label(panel, { Position = UDim2.fromOffset(18, 10), Size = UDim2.new(1, -360, 0, 38), TextXAlignment = Enum.TextXAlignment.Left, Text = "Pets" })
local close = button(panel, "X", Color3.fromRGB(230, 80, 80), { AnchorPoint = Vector2.new(1, 0), Position = UDim2.new(1, -12, 0, 10), Size = UDim2.fromOffset(40, 40) })
local equipBest = button(panel, "Equip Best", Color3.fromRGB(80, 190, 110), { Position = UDim2.new(1, -330, 0, 10), Size = UDim2.fromOffset(130, 40) })
local delButton = button(panel, "Delete", Color3.fromRGB(200, 90, 90), { Position = UDim2.new(1, -192, 0, 10), Size = UDim2.fromOffset(130, 40) })

local grid = Instance.new("ScrollingFrame")
grid.Position = UDim2.fromOffset(14, 60)
grid.Size = UDim2.new(1, -28, 1, -74)
grid.BackgroundTransparency = 1
grid.ScrollBarThickness = 8
grid.AutomaticCanvasSize = Enum.AutomaticSize.Y
grid.CanvasSize = UDim2.new()
grid.Parent = panel
local layout = Instance.new("UIGridLayout")
layout.CellSize = UDim2.fromOffset(110, 132)
layout.CellPadding = UDim2.fromOffset(8, 8)
layout.SortOrder = Enum.SortOrder.LayoutOrder
layout.Parent = grid

local function iconFor(petType: string, parent: Instance)
	local vp = Instance.new("ViewportFrame")
	vp.BackgroundTransparency = 1
	vp.Size = UDim2.new(1, -8, 0, 86)
	vp.Position = UDim2.fromOffset(4, 4)
	vp.LightDirection = Vector3.new(-1, -2, -1)
	vp.Ambient = Color3.fromRGB(170, 170, 180)
	vp.Parent = parent
	local template = PetModels:FindFirstChild("Stud" .. petType)
	if not template then
		return
	end
	local m = template:Clone()
	m:PivotTo(CFrame.new())
	m.Parent = vp
	local cf, size = m:GetBoundingBox()
	local r = math.max(size.X, size.Y, size.Z)
	local cam = Instance.new("Camera")
	cam.FieldOfView = 40
	-- three-quarter front view (pets face -Z)
	cam.CFrame = CFrame.lookAt(cf.Position + Vector3.new(-0.55, 0.35, -1).Unit * r * 1.75, cf.Position)
	cam.Parent = vp
	vp.CurrentCamera = cam
end

local cards: { [string]: Frame } = {}

local function render()
	local equippedSet = {}
	for _, id in inv.Equipped do
		equippedSet[id] = true
	end
	title.Text = ("Pets  %d/%d   ·   Equipped %d/%d"):format(#inv.Pets, inv.MaxInventory, #inv.Equipped, inv.MaxEquipped)
	delButton.Text = if deleteMode then (if next(selected) then "Confirm" else "Cancel") else "Delete"
	-- keep cards that still exist, add new ones
	local alive = {}
	for _, p in inv.Pets do
		alive[p.Id] = true
		local card = cards[p.Id]
		if not card then
			card = Instance.new("TextButton")
			card.Text = ""
			card.AutoButtonColor = true
			card.BackgroundColor3 = Color3.fromRGB(70, 78, 106)
			corner(card, 12)
			local rarity = Odds.Rarity(p.Rarity)
			local st = stroke(card, rgb(rarity.Color), 3)
			st.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
			st.Name = "Border"
			iconFor(p.Pet, card)
			label(card, { Position = UDim2.new(0, 4, 0, 90), Size = UDim2.new(1, -8, 0, 20), Text = pretty(p.Pet), TextStrokeTransparency = 0.4 })
			label(card, { Position = UDim2.new(0, 4, 0, 109), Size = UDim2.new(1, -8, 0, 17), Text = rarity.Name, TextColor3 = rgb(rarity.Color), TextStrokeTransparency = 0.4 })
			local badge = label(card, { Name = "Badge", AnchorPoint = Vector2.new(1, 0), Position = UDim2.new(1, -4, 0, 4), Size = UDim2.fromOffset(26, 26), Text = "✔", TextColor3 = Color3.fromRGB(110, 255, 130), TextStrokeTransparency = 0 })
			badge.Visible = false
			local id = p.Id
			card.Activated:Connect(function()
				if deleteMode then
					selected[id] = if selected[id] then nil else true
					render()
				else
					Sounds.Play("Equip")
					Remotes.Equip:FireServer(id, not table.find(inv.Equipped, id))
				end
			end)
			card.Parent = grid
			cards[p.Id] = card
		end
		local rank = Odds.RarityRank(p.Rarity)
		card.LayoutOrder = (if equippedSet[p.Id] then 0 else 1000) + (10 - rank) * 10
		card.Badge.Visible = equippedSet[p.Id] == true
		card.Badge.Text = if deleteMode and selected[p.Id] then "🗑" else "✔"
		card.Badge.Visible = (deleteMode and selected[p.Id]) or (not deleteMode and equippedSet[p.Id] == true)
		card.BackgroundColor3 = if deleteMode and selected[p.Id] then Color3.fromRGB(150, 60, 60) else Color3.fromRGB(70, 78, 106)
	end
	for id, card in cards do
		if not alive[id] then
			card:Destroy()
			cards[id] = nil
			selected[id] = nil
		end
	end
end

Remotes.Data.OnClientEvent:Connect(function(d)
	inv = d
	render()
end)

local function toggleInventory(open: boolean?)
	if HatchPlayer.Busy then
		return
	end
	ui.Enabled = if open == nil then not ui.Enabled else open
	if not ui.Enabled then
		deleteMode = false
		table.clear(selected)
	end
	render()
end
petsButton.Activated:Connect(function()
	toggleInventory()
end)
close.Activated:Connect(function()
	toggleInventory(false)
end)
equipBest.Activated:Connect(function()
	Sounds.Play("Equip")
	Remotes.EquipBest:FireServer()
end)
delButton.Activated:Connect(function()
	if deleteMode and next(selected) then
		local ids = {}
		for id in selected do
			table.insert(ids, id)
		end
		Remotes.Delete:FireServer(ids)
		table.clear(selected)
		deleteMode = false
	else
		deleteMode = not deleteMode
		table.clear(selected)
	end
	render()
end)
UserInputService.InputBegan:Connect(function(input, processed)
	if not processed and input.KeyCode == Enum.KeyCode.B then
		toggleInventory()
	end
end)

---------------------------------------------------------------------------
-- Eggs: prompts + odds board on every tagged stand
---------------------------------------------------------------------------
local hatching = false
local function hatch(eggName: string, count: number)
	-- one purchase at a time: set before the server round trip so E then R can't buy twice
	if hatching or HatchPlayer.Busy then
		return
	end
	hatching = true
	local ok, res = pcall(Remotes.Hatch.InvokeServer, Remotes.Hatch, eggName, count)
	if not ok or not res or not res.ok then
		Sounds.Play("Denied")
		showToast(if ok and res and res.err then res.err else "Can't hatch right now")
		hatching = false
		return
	end
	Sounds.Play("Purchase")
	toggleInventory(false)
	hud.Enabled = false
	local played, err = pcall(HatchPlayer.Play, eggName, res.results)
	if not played then
		warn("[StudPetSystem] hatch cinematic failed:", err)
	end
	hud.Enabled = true
	hatching = false
end

local function setupStand(stand: Instance)
	local eggName = stand:GetAttribute("StudEggStand")
	local egg = eggName and Odds.GetEgg(eggName)
	if not egg or not stand:IsA("Model") then
		return
	end
	local eggModel = stand:WaitForChild("Egg", 10) :: Model?
	local anchor = eggModel and eggModel.PrimaryPart or stand.PrimaryPart
	if not anchor then
		return
	end
	local one = Instance.new("ProximityPrompt")
	one.ActionText = ("Open  (%s)"):format(commas(egg.Price))
	one.ObjectText = egg.Name
	one.KeyboardKeyCode = Enum.KeyCode.E
	one.HoldDuration = 0
	one.MaxActivationDistance = 12
	one.RequiresLineOfSight = false
	one.Parent = anchor
	one.Triggered:Connect(function()
		hatch(egg.Name, 1)
	end)
	if Config.TripleHatch then
		local three = Instance.new("ProximityPrompt")
		three.ActionText = ("Open x3  (%s)"):format(commas(egg.Price * 3))
		three.ObjectText = egg.Name
		three.KeyboardKeyCode = Enum.KeyCode.R
		three.HoldDuration = 0
		three.MaxActivationDistance = 12
		three.RequiresLineOfSight = false
		three.UIOffset = Vector2.new(0, 80)
		three.Parent = anchor
		three.Triggered:Connect(function()
			hatch(egg.Name, 3)
		end)
	end

	-- odds board
	local board = Instance.new("BillboardGui")
	board.Name = "StudEggOdds"
	board.Adornee = anchor
	board.Size = UDim2.fromOffset(240, 60 + 24 * #egg.Pets)
	board.StudsOffsetWorldSpace = Vector3.new(0, 6.5, 0)
	board.MaxDistance = 60
	board.LightInfluence = 0
	board.ResetOnSpawn = false
	local bg = Instance.new("Frame")
	bg.Size = UDim2.fromScale(1, 1)
	bg.BackgroundColor3 = Color3.fromRGB(30, 34, 52)
	bg.BackgroundTransparency = 0.2
	corner(bg, 12)
	bg.Parent = board
	label(bg, { Position = UDim2.fromOffset(0, 4), Size = UDim2.new(1, 0, 0, 28), Text = egg.Name, TextStrokeTransparency = 0.4 })
	label(bg, { Position = UDim2.fromOffset(0, 30), Size = UDim2.new(1, 0, 0, 20), Text = "💰 " .. commas(egg.Price), TextColor3 = Color3.fromRGB(255, 210, 80), TextStrokeTransparency = 0.4 })
	for i, c in Odds.Chances(egg) do
		local rarity = Odds.Rarity(c.Rarity)
		local y = 52 + (i - 1) * 24
		label(bg, { Position = UDim2.fromOffset(12, y), Size = UDim2.new(0.62, -12, 0, 21), Text = pretty(c.Pet), TextXAlignment = Enum.TextXAlignment.Left, TextColor3 = rgb(rarity.Color), TextStrokeTransparency = 0.5 })
		label(bg, { Position = UDim2.new(0.62, 0, 0, y), Size = UDim2.new(0.38, -12, 0, 21), Text = Odds.Format(c.Chance), TextXAlignment = Enum.TextXAlignment.Right, TextStrokeTransparency = 0.5 })
	end
	-- parented to the egg so it streams in/out with the stand (no duplicates)
	board.Parent = anchor

	-- idle bob on the display egg
	if eggModel then
		local base = eggModel:GetPivot()
		task.spawn(function()
			local t = math.random() * 3
			while eggModel.Parent do
				t += task.wait()
				-- only animate eggs you're near (each one is ~170 bricks)
				local cam = workspace.CurrentCamera
				if cam and (cam.CFrame.Position - base.Position).Magnitude < 90 then
					eggModel:PivotTo(base * CFrame.new(0, 0.25 * math.sin(t * 2), 0) * CFrame.Angles(0, t * 0.6, 0))
				end
			end
		end)
	end
end

for _, stand in CollectionService:GetTagged("StudEggStand") do
	task.spawn(setupStand, stand)
end
CollectionService:GetInstanceAddedSignal("StudEggStand"):Connect(setupStand)

Followers.Start()
