--!strict
-- Stud Pet System settings. Everything a game owner tunes lives here.

local Config = {}

-- Currency: a "Coins" leaderstat by default. Point these at your own system if you have one
-- (see the CurrencyAdapter section in the server script).
Config.Currency = "Coins"
Config.StartingCoins = 1000
Config.PassiveIncome = 25 -- coins per second for every player (demo; set 0 to turn off)

Config.MaxEquipped = 3
Config.MaxInventory = 60
Config.HatchCooldown = 0.6 -- seconds between hatch requests (server enforced)
Config.TripleHatch = true -- offer "open 3"
Config.SaveData = true -- DataStore saving (needs "Enable Studio Access to API Services" to test in Studio)
Config.DataStoreName = "StudPetSystem_v1"

-- Rarity tiers, lowest first. Glow/burst colours and how dramatic the hatch is.
Config.Rarities = {
	{ Name = "Common", Color = { 200, 204, 210 }, Drama = 0 },
	{ Name = "Uncommon", Color = { 96, 210, 96 }, Drama = 0 },
	{ Name = "Rare", Color = { 70, 150, 255 }, Drama = 1 },
	{ Name = "Epic", Color = { 180, 90, 255 }, Drama = 1 },
	{ Name = "Legendary", Color = { 255, 196, 40 }, Drama = 2 },
	{ Name = "Secret", Color = { 255, 70, 140 }, Drama = 3, Rainbow = true },
}

-- Eggs. Weights are relative chances (they don't have to add up to 100).
-- Pet names are any Stud Pet type (StudPets.PetAnimator.GetTypes()).
Config.Eggs = {
	{
		Name = "Farm Egg",
		Theme = "spots", -- shell decoration: spots / leaves / rosettes / waves / spikes / royal
		Price = 100,
		Colors = { Shell = { 250, 246, 232 }, Spots = { 196, 150, 96 } },
		Pets = {
			{ Pet = "Dog", Rarity = "Common", Weight = 30 },
			{ Pet = "Cat", Rarity = "Common", Weight = 30 },
			{ Pet = "Chicken", Rarity = "Uncommon", Weight = 14 },
			{ Pet = "Pig", Rarity = "Uncommon", Weight = 12 },
			{ Pet = "Cow", Rarity = "Rare", Weight = 8 },
			{ Pet = "Horse", Rarity = "Epic", Weight = 4.9 },
			{ Pet = "Unicorn", Rarity = "Legendary", Weight = 1 },
			{ Pet = "Alicorn", Rarity = "Secret", Weight = 0.1 },
		},
	},
	{
		Name = "Forest Egg",
		Theme = "leaves", -- shell decoration: spots / leaves / rosettes / waves / spikes / royal
		Price = 600,
		Colors = { Shell = { 150, 205, 110 }, Spots = { 60, 140, 60 } },
		Pets = {
			{ Pet = "Squirrel", Rarity = "Common", Weight = 30 },
			{ Pet = "Bunny", Rarity = "Common", Weight = 28 },
			{ Pet = "Fox", Rarity = "Uncommon", Weight = 16 },
			{ Pet = "Raccoon", Rarity = "Uncommon", Weight = 12 },
			{ Pet = "Deer", Rarity = "Rare", Weight = 8 },
			{ Pet = "Bear", Rarity = "Epic", Weight = 4.9 },
			{ Pet = "Kitsune", Rarity = "Legendary", Weight = 1 },
			{ Pet = "FrostWolf", Rarity = "Secret", Weight = 0.1 },
		},
	},
	{
		Name = "Safari Egg",
		Theme = "rosettes", -- shell decoration: spots / leaves / rosettes / waves / spikes / royal
		Price = 3000,
		Colors = { Shell = { 245, 205, 115 }, Spots = { 80, 50, 30 } },
		Pets = {
			{ Pet = "Meerkat", Rarity = "Common", Weight = 30 },
			{ Pet = "Zebra", Rarity = "Common", Weight = 28 },
			{ Pet = "Monkey", Rarity = "Uncommon", Weight = 16 },
			{ Pet = "Giraffe", Rarity = "Uncommon", Weight = 12 },
			{ Pet = "Lion", Rarity = "Rare", Weight = 8 },
			{ Pet = "Elephant", Rarity = "Epic", Weight = 4.9 },
			{ Pet = "WhiteTiger", Rarity = "Legendary", Weight = 1 },
			{ Pet = "Griffin", Rarity = "Secret", Weight = 0.1 },
		},
	},
	{
		Name = "Ocean Egg",
		Theme = "waves", -- shell decoration: spots / leaves / rosettes / waves / spikes / royal
		Price = 15000,
		Colors = { Shell = { 90, 170, 240 }, Spots = { 40, 100, 180 } },
		Pets = {
			{ Pet = "Clownfish", Rarity = "Common", Weight = 30 },
			{ Pet = "Pufferfish", Rarity = "Common", Weight = 28 },
			{ Pet = "SeaTurtle", Rarity = "Uncommon", Weight = 16 },
			{ Pet = "Dolphin", Rarity = "Uncommon", Weight = 12 },
			{ Pet = "Shark", Rarity = "Rare", Weight = 8 },
			{ Pet = "Orca", Rarity = "Epic", Weight = 4.9 },
			{ Pet = "Whale", Rarity = "Legendary", Weight = 1 },
			{ Pet = "Narwhal", Rarity = "Secret", Weight = 0.1 },
		},
	},
	{
		Name = "Dino Egg",
		Theme = "spikes", -- shell decoration: spots / leaves / rosettes / waves / spikes / royal
		Price = 75000,
		Colors = { Shell = { 120, 175, 90 }, Spots = { 70, 110, 55 } },
		Pets = {
			{ Pet = "Raptor", Rarity = "Common", Weight = 30 },
			{ Pet = "Parasaurolophus", Rarity = "Common", Weight = 28 },
			{ Pet = "Triceratops", Rarity = "Uncommon", Weight = 16 },
			{ Pet = "Stegosaurus", Rarity = "Uncommon", Weight = 12 },
			{ Pet = "Pterodactyl", Rarity = "Rare", Weight = 8 },
			{ Pet = "Brachiosaurus", Rarity = "Epic", Weight = 4.9 },
			{ Pet = "TRex", Rarity = "Legendary", Weight = 1 },
			{ Pet = "Spinosaurus", Rarity = "Secret", Weight = 0.1 },
		},
	},
	{
		Name = "Mythic Egg",
		Theme = "royal", -- shell decoration: spots / leaves / rosettes / waves / spikes / royal
		Price = 400000,
		Colors = { Shell = { 110, 60, 190 }, Spots = { 255, 200, 60 }, Gem = { 90, 230, 255 } },
		Pets = {
			{ Pet = "Jackalope", Rarity = "Common", Weight = 30 },
			{ Pet = "Pegasus", Rarity = "Common", Weight = 28 },
			{ Pet = "Hellhound", Rarity = "Uncommon", Weight = 16 },
			{ Pet = "Qilin", Rarity = "Uncommon", Weight = 12 },
			{ Pet = "Phoenix", Rarity = "Rare", Weight = 8 },
			{ Pet = "Dragon", Rarity = "Epic", Weight = 4.9 },
			{ Pet = "IceDragon", Rarity = "Legendary", Weight = 1 },
			{ Pet = "FireDragon", Rarity = "Secret", Weight = 0.1 },
		},
	},
}

-- Sounds. Id is a Roblox audio asset ID (number) or a built-in "rbxasset://" path.
-- The defaults are sounds that ship inside every Roblox client, so they work in any game
-- with no uploads. Swap in nicer ones from the Creator Store's free audio library anytime.
-- Speed changes the pitch (1 = normal). 0 or "" = silent.
local SFX = "rbxasset://sounds/"
Config.Sounds = {
	EggAppear = { Id = SFX .. "swoosh.wav", Volume = 0.5, Speed = 1.15 }, -- egg lands in front of the camera
	Shake = { Id = SFX .. "clickfast.wav", Volume = 0.7, Speed = 0.8 }, -- each wobble
	Crack = { Id = SFX .. "snap.wav", Volume = 0.8, Speed = 1.1 }, -- a crack appears
	Charge = { Id = SFX .. "electronicpingshort.wav", Volume = 0.45, Speed = 0.6 }, -- rising glow before a rare+ pops
	Pop = { Id = SFX .. "collide.wav", Volume = 0.9, Speed = 1.3 }, -- the egg bursts
	RevealCommon = { Id = SFX .. "electronicpingshort.wav", Volume = 0.6, Speed = 1.0 }, -- Common / Uncommon pet appears
	RevealRare = { Id = SFX .. "electronicpingshort.wav", Volume = 0.75, Speed = 1.25 }, -- Rare / Epic
	RevealLegendary = { Id = SFX .. "electronicpingshort.wav", Volume = 0.9, Speed = 1.5, Repeat = 3 }, -- Legendary / Secret
	Purchase = { Id = SFX .. "switch.wav", Volume = 0.6, Speed = 1.2 }, -- coins spent
	Denied = { Id = SFX .. "button.wav", Volume = 0.6, Speed = 0.55 }, -- not enough coins / inventory full
	Equip = { Id = SFX .. "switch.wav", Volume = 0.5, Speed = 1.0 },
	Click = { Id = SFX .. "button.wav", Volume = 0.45, Speed = 1.1 }, -- UI buttons
}

return Config
