-- Plays the sounds listed in Config.Sounds (ID 0 = silent). One Sound per name, reused.
local SoundService = game:GetService("SoundService")

local Find = require(script.Parent:WaitForChild("Find"))
local Config = require(Find.Folder("StudPetSystem"):WaitForChild("Config"))

local Sounds = {}
local cache: { [string]: Sound } = {}

local function playOnce(name: string, def: any)
	local s = cache[name]
	if not s then
		s = Instance.new("Sound")
		s.Name = "StudPetSystem_" .. name
		s.SoundId = if type(def.Id) == "number" then "rbxassetid://" .. tostring(def.Id) else def.Id
		s.Volume = def.Volume or 0.7
		s.PlaybackSpeed = def.Speed or 1
		s.Parent = SoundService
		cache[name] = s
	end
	-- overlapping plays (fast clicks, triple hatch) each get their own copy
	if s.IsPlaying then
		local c = s:Clone()
		c.Parent = SoundService
		c:Play()
		c.Ended:Once(function()
			c:Destroy()
		end)
	else
		s:Play()
	end
end

function Sounds.Play(name: string)
	local def = Config.Sounds[name]
	if not def or not def.Id or def.Id == 0 or def.Id == "" then
		return
	end
	playOnce(name, def)
	-- a quick rising arpeggio for the big reveals
	for k = 2, def.Repeat or 1 do
		task.delay(0.11 * (k - 1), function()
			local s = cache[name]
			if s then
				local c = s:Clone()
				c.PlaybackSpeed = (def.Speed or 1) * (1 + 0.26 * (k - 1))
				c.Parent = SoundService
				c:Play()
				c.Ended:Once(function()
					c:Destroy()
				end)
			end
		end)
	end
end

return Sounds
