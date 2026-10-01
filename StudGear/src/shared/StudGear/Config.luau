--!strict
-- Stud Gear settings. Everything a game owner tunes lives here.

local Config = {}

-- Each piece of gear. Leave an effect out to not have it.
--   Speed     walk speed multiplier       (1.75 = 75% faster)
--   Gravity   how heavy you are            (0.35 = 35% gravity: floaty, ~3x jump height)
--   Jump      jump height multiplier       (1.8 = jumps 80% higher)
--   AirJumps  extra jumps in mid-air       (1 = double jump, 2 = triple jump)
--   MaxFall   fastest you can fall, studs/s (10 = gentle float down)
--   Regen     health healed per second while held
--   Jetpack   { Thrust = climb speed, Fuel = seconds of flight, Refuel = seconds to refill on the ground }
--   Grapple   { Range = studs, Speed = pull speed }
-- Look: how it's built - "coil", "balloon", "jetpack" or "grapple".
-- GamePassId: 0 = free (take it from its display stand). Put your game pass ID here to sell
-- it: owners get it every time they spawn, and the stand prompts the purchase.
Config.Gear = {
	{ Name = "Speed Coil", GamePassId = 0, Look = "coil", Speed = 1.75, Color = { 235, 55, 55 }, Accent = { 255, 235, 235 } },
	{ Name = "Gravity Coil", GamePassId = 0, Look = "coil", Gravity = 0.35, Color = { 130, 80, 255 }, Accent = { 90, 210, 255 } },
	{ Name = "Fusion Coil", GamePassId = 0, Look = "coil", Speed = 1.6, Gravity = 0.4, Color = { 235, 55, 55 }, Accent = { 130, 80, 255 } },
	{ Name = "Jump Coil", GamePassId = 0, Look = "coil", Jump = 1.8, Color = { 70, 210, 90 }, Accent = { 230, 255, 120 } },
	{ Name = "Double Jump Coil", GamePassId = 0, Look = "coil", AirJumps = 1, Color = { 60, 190, 255 }, Accent = { 255, 255, 255 } },
	{ Name = "Regen Coil", GamePassId = 0, Look = "coil", Regen = 10, Color = { 255, 105, 165 }, Accent = { 255, 255, 255 } },
	{ Name = "Rainbow Coil", GamePassId = 0, Look = "coil", Speed = 1.8, Gravity = 0.35, Jump = 1.15, Rainbow = true, Color = { 255, 255, 255 }, Accent = { 255, 255, 255 } },
	{ Name = "Balloon", GamePassId = 0, Look = "balloon", Gravity = 0.7, MaxFall = 9, Color = { 235, 45, 60 }, Accent = { 255, 255, 255 } },
	{ Name = "Jetpack", GamePassId = 0, Look = "jetpack", Jetpack = { Thrust = 30, Fuel = 2.5, Refuel = 1.5 }, Color = { 120, 130, 150 }, Accent = { 255, 150, 40 } },
	{ Name = "Grapple Hook", GamePassId = 0, Look = "grapple", Grapple = { Range = 120, Speed = 75 }, Color = { 60, 64, 80 }, Accent = { 255, 200, 50 } },
}

Config.Trails = true -- a coloured trail while running with gear
Config.GiveFreeGearOnSpawn = false -- true: everyone spawns with every free (GamePassId 0) gear
Config.CanDrop = false -- let players drop gear with Backspace

return Config
