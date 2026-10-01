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
		Colors = { Shell = { 235, 140, 60 }, Spots = { 110, 60, 35 } },
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

-- Sounds: none by default. Put a Roblox audio asset ID (number) in any slot to give that
-- moment a sound, e.g. Pop = { Id = 1234567890, Volume = 0.8 }. Speed changes the pitch.
Config.Sounds = {
	EggAppear = { Id = 0, Volume = 0.5 }, -- egg lands on the stage
	Shake = { Id = 0, Volume = 0.7 }, -- each wobble
	Crack = { Id = 0, Volume = 0.8 }, -- a crack opens
	Charge = { Id = 0, Volume = 0.5 }, -- rising glow before a rare+ pops
	Pop = { Id = 0, Volume = 0.9 }, -- the egg bursts
	RevealCommon = { Id = 0, Volume = 0.6 }, -- Common / Uncommon pet appears
	RevealRare = { Id = 0, Volume = 0.75 }, -- Rare / Epic
	RevealLegendary = { Id = 0, Volume = 0.9 }, -- Legendary / Secret
	Purchase = { Id = 0, Volume = 0.6 }, -- coins spent
	Denied = { Id = 0, Volume = 0.6 }, -- not enough coins / inventory full
	Equip = { Id = 0, Volume = 0.5 },
	Click = { Id = 0, Volume = 0.45 }, -- UI buttons
}

return Config
