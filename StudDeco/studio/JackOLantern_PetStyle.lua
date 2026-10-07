--[[ Stud Deco builder: paste this whole file into Roblox Studio's Command Bar (View > Command Bar) and press Enter.
It builds the ITEM below as an anchored Model in front of the camera and selects it. Nothing else is touched.

ITEM format (studs, degrees):
  parts = { { kind, name, size {x,y,z}, pos {x,y,z}, rot {rx,ry,rz}, color {r,g,b}, studs?, neon? }, ... }
    kind  = "block" or "wedge" (WedgePart: full height at the back +Z, sloping down to the front -Z)
    studs = true puts Roblox's Studs surface on the top face (the Stud Pets look)
    neon  = true makes it glow (Neon material)
  lights = { { pos {x,y,z}, color {r,g,b}, range, brightness }, ... }
  Y is up, the item faces -Z, its base sits on Y = 0.
]]

local ITEM = {
	name = "JackOLantern_PetStyle", category = "Pumpkins",
	parts = {
		{ "block", "Bottom", { 2.6, 0.3, 2.6 }, { 0, 0.15, 0 }, { -0, 0, -0 }, { 196, 90, 22 }, studs = false, neon = false },
		{ "block", "Body", { 3, 2.4, 3 }, { 0, 1.5, 0 }, { -0, 0, -0 }, { 232, 116, 30 }, studs = true, neon = false },
		{ "block", "RibF1", { 0.18, 2.1, 0.1 }, { -1, 1.5, -1.55 }, { -0, 0, -0 }, { 196, 90, 22 }, studs = false, neon = false },
		{ "block", "RibS1", { 0.1, 2.1, 0.18 }, { -1.55, 1.5, 0 }, { -0, 0, -0 }, { 196, 90, 22 }, studs = false, neon = false },
		{ "block", "RibF2", { 0.18, 2.1, 0.1 }, { 1, 1.5, -1.55 }, { -0, 0, -0 }, { 196, 90, 22 }, studs = false, neon = false },
		{ "block", "RibS2", { 0.1, 2.1, 0.18 }, { 1.55, 1.5, 0 }, { -0, 0, -0 }, { 196, 90, 22 }, studs = false, neon = false },
		{ "block", "Stem", { 0.5, 0.7, 0.5 }, { 0, 3.05, 0 }, { -0, 0, -0 }, { 86, 128, 48 }, studs = true, neon = false },
		{ "block", "StemTip", { 0.5, 0.25, 0.3 }, { 0.2, 3.5, 0 }, { 0, 0, -25 }, { 86, 128, 48 }, studs = false, neon = false },
		{ "wedge", "Leaf", { 0.6, 0.25, 0.9 }, { -0.55, 2.82, 0.3 }, { -0, 40, -0 }, { 104, 150, 62 }, studs = true, neon = false },
		{ "wedge", "EyeA1", { 0.12, 0.6, 0.3 }, { -0.77, 1.95, -1.56 }, { 0, 90, -0 }, { 255, 214, 110 }, studs = false, neon = true },
		{ "wedge", "EyeB1", { 0.12, 0.6, 0.3 }, { -0.47, 1.95, -1.56 }, { 0, -90, -0 }, { 255, 214, 110 }, studs = false, neon = true },
		{ "wedge", "EyeA2", { 0.12, 0.6, 0.3 }, { 0.47, 1.95, -1.56 }, { 0, 90, -0 }, { 255, 214, 110 }, studs = false, neon = true },
		{ "wedge", "EyeB2", { 0.12, 0.6, 0.3 }, { 0.77, 1.95, -1.56 }, { 0, -90, -0 }, { 255, 214, 110 }, studs = false, neon = true },
		{ "block", "Nose", { 0.3, 0.25, 0.12 }, { 0, 1.55, -1.56 }, { -0, 0, -0 }, { 255, 214, 110 }, studs = false, neon = true },
		{ "block", "Mouth", { 1.9, 0.5, 0.12 }, { 0, 1, -1.56 }, { -0, 0, -0 }, { 255, 214, 110 }, studs = false, neon = true },
		{ "block", "ToothT", { 0.3, 0.22, 0.14 }, { -0.35, 1.14, -1.57 }, { -0, 0, -0 }, { 232, 116, 30 }, studs = false, neon = false },
		{ "block", "ToothB", { 0.3, 0.22, 0.14 }, { 0.4, 0.86, -1.57 }, { -0, 0, -0 }, { 232, 116, 30 }, studs = false, neon = false },
	},
	lights = {
		{ pos = { 0, 1.5, -1 }, color = { 255, 150, 40 }, range = 10, brightness = 1.4 },
	},
}

local Selection = game:GetService("Selection")
local cam = workspace.CurrentCamera
local focus = cam.CFrame.Position + cam.CFrame.LookVector * 20
local origin = CFrame.new(math.floor(focus.X + 0.5), 0, math.floor(focus.Z + 0.5))

local model = Instance.new("Model")
model.Name = ITEM.name
for _, p in ipairs(ITEM.parts) do
	local part = Instance.new(p[1] == "wedge" and "WedgePart" or "Part")
	part.Name = p[2]
	part.Size = Vector3.new(p[3][1], p[3][2], p[3][3])
	part.CFrame = origin * CFrame.new(p[4][1], p[4][2], p[4][3])
		* CFrame.Angles(math.rad(p[5][1]), math.rad(p[5][2]), math.rad(p[5][3]))
	part.Color = Color3.fromRGB(p[6][1], p[6][2], p[6][3])
	part.Material = p.neon and Enum.Material.Neon or Enum.Material.Plastic
	part.TopSurface = p.studs and Enum.SurfaceType.Studs or Enum.SurfaceType.Smooth
	part.BottomSurface = Enum.SurfaceType.Smooth
	part.Anchored = true
	part.CanCollide = math.min(part.Size.X, part.Size.Y, part.Size.Z) >= 0.5 and not p.neon
	part.CastShadow = not p.neon
	part.Parent = model
end
for i, l in ipairs(ITEM.lights or {}) do
	local holder = Instance.new("Part")
	holder.Name = "Light" .. i
	holder.Size = Vector3.new(0.2, 0.2, 0.2)
	holder.CFrame = origin * CFrame.new(l.pos[1], l.pos[2], l.pos[3])
	holder.Transparency, holder.Anchored, holder.CanCollide, holder.CanQuery, holder.CastShadow = 1, true, false, false, false
	local light = Instance.new("PointLight")
	light.Color = Color3.fromRGB(l.color[1], l.color[2], l.color[3])
	light.Range, light.Brightness, light.Shadows = l.range, l.brightness, false
	light.Parent = holder
	holder.Parent = model
end
model.WorldPivot = origin
model:SetAttribute("StudDeco", ITEM.category or "Deco")
model.Parent = workspace
Selection:Set({ model })
print("[StudDeco] built " .. model.Name .. " (" .. #ITEM.parts .. " parts)")
