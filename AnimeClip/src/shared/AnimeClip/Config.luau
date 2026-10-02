--!strict
-- Settings for the anime clip.

local Config = {}

-- The hero is whoever presses Play (your own avatar). The rival is this Roblox user's avatar.
-- If an avatar can't load, a blocky stand-in fighter is used instead.
Config.RivalUsername = "Builderman"

Config.AutoPlayDelay = 2.5 -- seconds after joining before the clip starts
Config.ReplayKey = Enum.KeyCode.R -- press to play it again
Config.ToggleFrameKey = Enum.KeyCode.F -- show / hide the 9:16 frame guides

-- Show black bars so the picture is exactly the 9:16 TikTok frame (record just that area).
-- Tip: in Studio, Test > Device > pick a phone in portrait to record full screen at 9:16.
Config.VerticalFrame = true

-- Speed of the whole clip (0.5 = half speed, handy for checking a moment)
Config.Speed = 1

return Config
