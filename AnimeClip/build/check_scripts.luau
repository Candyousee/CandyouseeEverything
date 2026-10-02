-- Compiles every script in a place file (syntax check).  lune run build/check_scripts.luau X.rbxl
local fs = require("@lune/fs")
local roblox = require("@lune/roblox")
local luau = require("@lune/luau")
local process = require("@lune/process")
local game = roblox.deserializePlace(fs.readFile(process.args[1]))
local n, bad = 0, 0
for _, d in game:GetDescendants() do
	if d:IsA("LuaSourceContainer") then
		n += 1
		local ok, err = pcall(luau.compile, d.Source)
		if not ok then
			bad += 1
			print("ERROR in " .. d:GetFullName() .. ": " .. tostring(err))
		end
	end
end
print(("[scripts] %d compiled, %d errors"):format(n, bad))
