--!strict
-- Egg odds: pure maths shared by the server (rolling) and the UI (showing chances).
-- A factory so the same file runs in-game and in the offline tests:
--   local Odds = require(StudPetSystem.Odds)(require(StudPetSystem.Config))

return function(Config)
	local Odds = {}

	local eggsByName: { [string]: any } = {}
	for _, egg in Config.Eggs do
		eggsByName[egg.Name] = egg
end
	local rarityIndex: { [string]: number } = {}
	for i, r in Config.Rarities do
		rarityIndex[r.Name] = i
end

	function Odds.GetEgg(name: string): any?
		return eggsByName[name]
end

	function Odds.Rarity(name: string): any
		return Config.Rarities[rarityIndex[name] or 1]
end

	function Odds.RarityRank(name: string): number
		return rarityIndex[name] or 1
end

	-- { {Pet, Rarity, Chance (0..1)}, ... } in the egg's order
	function Odds.Chances(egg: any): { any }
		local total = 0
		for _, e in egg.Pets do
			total += e.Weight
		end
		local out = {}
		for _, e in egg.Pets do
			table.insert(out, { Pet = e.Pet, Rarity = e.Rarity, Chance = e.Weight / total })
		end
		return out
end

	-- Weighted pick. `rng` is a Random (server) or any table with :NextNumber().
	function Odds.Roll(egg: any, rng: any): any
		local total = 0
		for _, e in egg.Pets do
			total += e.Weight
		end
		local r = rng:NextNumber() * total
		for _, e in egg.Pets do
			r -= e.Weight
			if r < 0 then
				return e
			end
		end
		return egg.Pets[#egg.Pets]
end

	-- "12.5%", "0.1%", "1 in 1,000" style text for the odds board
	function Odds.Format(chance: number): string
		local pct = chance * 100
		if pct >= 10 then
			return string.format("%d%%", math.round(pct))
		elseif pct >= 1 then
			return string.format("%.1f%%", pct)
		elseif pct >= 0.01 then
			return string.format("%.2f%%", pct)
		end
		return string.format("1 in %d", math.round(1 / chance))
end

	return Odds
end
