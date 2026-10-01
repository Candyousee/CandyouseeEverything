-- Flags parts that float free of (or barely touch) the part they're attached to.
--   lune run build/attach_check.luau
local fs = require("@lune/fs")
local roblox = require("@lune/roblox")

local function corners(p)
	local cf, s = p.CFrame, p.Size / 2
	local out = {}
	for _, x in { -1, 1 } do
		for _, y in { -1, 1 } do
			for _, z in { -1, 1 } do
				table.insert(out, cf:PointToWorldSpace(roblox.Vector3.new(x * s.X, y * s.Y, z * s.Z)))
			end
		end
	end
	return out
end

-- separating-axis overlap depth between two boxes (negative = gap)
local function depth(a, b)
	local axes = {}
	for _, p in { a, b } do
		local cf = p.CFrame
		table.insert(axes, cf.RightVector)
		table.insert(axes, cf.UpVector)
		table.insert(axes, cf.LookVector)
	end
	local ca, cb = corners(a), corners(b)
	local best = math.huge
	for _, ax in axes do
		local amin, amax, bmin, bmax = math.huge, -math.huge, math.huge, -math.huge
		for _, c in ca do
			local d = c:Dot(ax)
			amin, amax = math.min(amin, d), math.max(amax, d)
		end
		for _, c in cb do
			local d = c:Dot(ax)
			bmin, bmax = math.min(bmin, d), math.max(bmax, d)
		end
		best = math.min(best, math.min(amax, bmax) - math.max(amin, bmin))
	end
	return best
end

local MIN = -0.03 -- a gap bigger than this to every other part = floating
local count = 0
for _, file in fs.readDir("assets/pets") do
	local model = roblox.deserializeModel(fs.readFile("assets/pets/" .. file))[1]
	local parts = {}
	for _, d in model:GetDescendants() do
		if d:IsA("BasePart") then
			table.insert(parts, d)
		end
	end
	for _, d in model:GetDescendants() do
		local a, b
		if d:IsA("Motor6D") or d:IsA("Weld") then
			a, b = d.Part0, d.Part1
		elseif d:IsA("WeldConstraint") then
			a, b = d.Part0, d.Part1
		end
		if a and b then
			local dp = depth(a, b)
			if dp < MIN then
				-- touching something else solidly is fine (e.g. a tuft resting on the head)
				local other = -math.huge
				for _, p in parts do
					if p ~= b then
						other = math.max(other, depth(p, b))
					end
				end
				if other < MIN then
					count += 1
					print(string.format("%-22s %-16s on %-12s overlap %.2f (best %.2f)", model.Name, b.Name, a.Name, dp, other))
				end
			end
		end
	end
end
print(`[attach] {count} loose part(s)`)
