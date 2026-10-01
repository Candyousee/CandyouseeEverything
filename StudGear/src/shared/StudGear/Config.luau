--!strict
-- Stud Gear settings. Everything a game owner tunes lives here.

local Config = {}

-- Each piece of gear. Effects multiply the player's normal values:
--   Speed   = walk speed      (1.75 = 75% faster)
--   Gravity = how heavy you are while holding it (0.35 = 35% gravity: floaty, ~3x jump height)
--   Jump    = jump height     (1.8 = jumps 80% higher)
-- GamePassId: 0 = free (take it from its display stand). Put your game pass ID here to sell
-- it: owners get it every time they spawn, and the stand prompts the purchase.
Config.Gear = {
	{ Name = "Speed Coil", GamePassId = 0, Speed = 1.75, Color = { 235, 55, 55 }, Accent = { 255, 235, 235 } },
	{ Name = "Gravity Coil", GamePassId = 0, Gravity = 0.35, Color = { 130, 80, 255 }, Accent = { 90, 210, 255 } },
	{ Name = "Fusion Coil", GamePassId = 0, Speed = 1.6, Gravity = 0.4, Color = { 235, 55, 55 }, Accent = { 130, 80, 255 } },
	{ Name = "Jump Coil", GamePassId = 0, Jump = 1.8, Color = { 70, 210, 90 }, Accent = { 230, 255, 120 } },
	{ Name = "Rainbow Coil", GamePassId = 0, Speed = 1.8, Gravity = 0.35, Jump = 1.15, Rainbow = true, Color = { 255, 255, 255 }, Accent = { 255, 255, 255 } },
}

Config.Trails = true -- a coloured trail while running with gear
Config.GiveFreeGearOnSpawn = false -- true: everyone spawns with every free (GamePassId 0) gear
Config.CanDrop = false -- let players drop gear with Backspace

return Config
