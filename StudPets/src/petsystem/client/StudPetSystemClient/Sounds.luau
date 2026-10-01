-- Plays the sounds listed in Config.Sounds (ID 0 = silent). One Sound per name, reused.
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local SoundService = game:GetService("SoundService")

local Config = require(ReplicatedStorage:WaitForChild("StudPetSystem"):WaitForChild("Config"))

local Sounds = {}
local cache: { [string]: Sound } = {}

function Sounds.Play(name: string)
	local def = Config.Sounds[name]
	if not def or not def.Id or def.Id == 0 then
		return
	end
	local s = cache[name]
	if not s then
		s = Instance.new("Sound")
		s.Name = "StudPetSystem_" .. name
		s.SoundId = "rbxassetid://" .. tostring(def.Id)
		s.Volume = def.Volume or 0.7
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

return Sounds
