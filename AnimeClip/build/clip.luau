-- Exports the clip frame by frame for the offline preview.
--   lune run build/clip.luau [fps] [only-frame]   -> build/out/frames/NNNN.json
local fs = require("@lune/fs")
local serde = require("@lune/serde")
local process = require("@lune/process")
local T = require("../src/shared/AnimeClip/Timeline")

local FPS = tonumber(process.args[1]) or 30
local only = tonumber(process.args[2])
fs.writeDir("build/out/frames")
local n = math.floor(T.LENGTH * FPS)
local worst = 0
for f = 0, n - 1 do
	if only and f ~= only then
		continue
	end
	local t = f / FPS
	local fr = T.Sample(t)
	local prims = fr.prims
	for name, s in fr.actors do
		local body, world = T.BodyPrims(name, s)
		for _, p in body do
			p.fighter = true
			table.insert(prims, p)
		end
		for _, p in T.GearPrims(name, s, world) do
			p.fighter = true
			table.insert(prims, p)
		end
	end
	for _, g in fr.ghosts do
		for _, p in T.GhostPrims(g) do
			table.insert(prims, p)
		end
	end
	-- sanity: no NaNs anywhere
	for _, p in prims do
		for _, c in p.cf do
			assert(c == c and math.abs(c) < 1e5, ("bad CF at t=%.2f"):format(t))
		end
	end
	worst = math.max(worst, #prims)
	fs.writeFile(("build/out/frames/%04d.json"):format(f), serde.encode("json", { t = t, shot = fr.shot, camera = fr.camera, prims = prims, post = fr.post }))
end
print(("[clip] %d frames at %d fps, up to %d prims a frame"):format(n, FPS, worst))
