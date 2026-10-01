-- Offline checks for the pet system's pure modules: odds and the hatch timeline.
--   lune run build/test_petsystem.luau
local Config = require("../src/petsystem/shared/StudPetSystem/Config")
local Odds = require("../src/petsystem/shared/StudPetSystem/Odds")(Config)
local Hatch = require("../src/petsystem/shared/StudPetSystem/HatchSequence")
local Animals = require("../src/shared/StudPets/Animals")

local fails = 0
local function check(ok, msg)
	if not ok then
		fails += 1
		print("FAIL: " .. msg)
	end
end

-- every egg pet exists and every rarity is known
local known = { Cat = true, Dog = true }
for _, n in Animals.Order do
	known[n] = true
end
for _, egg in Config.Eggs do
	local total = 0
	for _, e in egg.Pets do
		check(known[e.Pet], `{egg.Name}: unknown pet {e.Pet}`)
		check(Odds.Rarity(e.Rarity).Name == e.Rarity, `{egg.Name}: unknown rarity {e.Rarity}`)
		total += e.Weight
	end
	check(total > 0, egg.Name .. ": no weight")
	-- rolls match the stated odds
	math.randomseed(1)
	local rng = { NextNumber = function() return math.random() end }
	local counts = {}
	local N = 200000
	for _ = 1, N do
		local r = Odds.Roll(egg, rng)
		counts[r.Pet] = (counts[r.Pet] or 0) + 1
	end
	for _, c in Odds.Chances(egg) do
		local got = (counts[c.Pet] or 0) / N
		check(math.abs(got - c.Chance) < 0.004 + c.Chance * 0.15, `{egg.Name}/{c.Pet}: rolled {got} vs {c.Chance}`)
	end
	print(egg.Name, Odds.Format(Odds.Chances(egg)[#egg.Pets].Chance))
end

-- hatch timeline: finite numbers, egg gone after the pop, pet fully shown, ends faded
for drama = 0, 3 do
	local T = Hatch.Timing(drama)
	local t = 0
	while t <= T.length do
		local s = Hatch.State(t, drama, 7)
		for _, v in { s.eggScale, s.eggPos[1], s.eggPos[2], s.eggRot[3], s.glow, s.flash, s.petScale, s.petYaw, s.shake } do
			check(v == v and math.abs(v) < 1e4, `drama {drama} t {t}: bad number`)
		end
		for _, sh in s.shards do
			check(sh.pos[2] > -14, `shard falls too far at {t}`)
		end
		t += 1 / 30
	end
	local mid = Hatch.State(T.pop + 1.0, drama, 7)
	check(not mid.eggVisible and math.abs(mid.petScale - 1) < 0.02 and mid.banner > 0.99, `drama {drama}: reveal state`)
	check(Hatch.State(T.length, drama, 7).fade > 0.99, `drama {drama}: fades out`)
	print(("drama %d: %.2f s, %d events"):format(drama, T.length, #Hatch.Events(drama)))
end
print(if fails == 0 then "[petsystem] all checks passed" else `[petsystem] {fails} failure(s)`)
