-- Movement gear that runs on your own device (your character's physics lives there, so this
-- is what makes it instant and smooth on PC, mobile and console):
--   AirJumps (Double Jump Coil), MaxFall (Balloon), Jetpack, Grapple.
-- Speed / Gravity / Jump / Regen are applied by the server.

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local Abilities = {}

function Abilities.Start(System: Instance)
	local Config = require(System:WaitForChild("Config"))
	local Effects = require(System:WaitForChild("Effects"))
	local FxRemote = System:WaitForChild("Remotes"):WaitForChild("GearFx")
	local player = Players.LocalPlayer

	local byName = {}
	for _, g in Config.Gear do
		byName[g.Name] = g
	end

	-- per-life state
	local character, humanoid, root = nil, nil, nil
	local fx = Effects.Combine({})
	local airJumpsUsed = 0
	local leftGroundAt = 0
	local lastJumpRequest = 0
	local fuel = 0
	local jetting = false
	local grapple = nil -- { target, beam, attachment, started }
	local puff = nil
	local crosshair = false

	------------------------------------------------------------------ fuel bar
	local gui = Instance.new("ScreenGui")
	gui.Name = "StudGearHUD"
	gui.ResetOnSpawn = false
	gui.Enabled = false
	local barBack = Instance.new("Frame")
	barBack.AnchorPoint = Vector2.new(0.5, 1)
	barBack.Position = UDim2.new(0.5, 0, 1, -96)
	barBack.Size = UDim2.fromOffset(220, 14)
	barBack.BackgroundColor3 = Color3.fromRGB(25, 27, 40)
	barBack.BackgroundTransparency = 0.25
	barBack.Parent = gui
	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(1, 0)
	corner.Parent = barBack
	local bar = Instance.new("Frame")
	bar.Size = UDim2.fromScale(1, 1)
	bar.BackgroundColor3 = Color3.fromRGB(255, 160, 50)
	bar.Parent = barBack
	corner:Clone().Parent = bar
	local stroke = Instance.new("UIStroke")
	stroke.Color = Color3.fromRGB(15, 15, 25)
	stroke.Thickness = 2
	stroke.Parent = barBack
	gui.Parent = player:WaitForChild("PlayerGui")

	------------------------------------------------------------------ helpers
	local function held(): { any }
		local list = {}
		if character then
			for _, c in character:GetChildren() do
				if c:IsA("Tool") then
					local g = byName[c:GetAttribute("StudGear") or ""]
					if g then
						table.insert(list, g)
					end
				end
			end
		end
		return list
	end

	local function airborne(): boolean
		local s = humanoid and humanoid:GetState()
		return s == Enum.HumanoidStateType.Freefall or s == Enum.HumanoidStateType.Jumping
	end

	local function setJetFlames(on: boolean)
		if jetting == on then
			return
		end
		jetting = on
		local wear = character and character:FindFirstChild("StudGearWear")
		if wear then
			-- instant for you; the server shows everyone else
			for _, e in wear:GetDescendants() do
				if e:IsA("ParticleEmitter") or e:IsA("PointLight") then
					e.Enabled = on
				end
			end
		end
		FxRemote:FireServer("Jet", on)
	end

	local function stopGrapple()
		if not grapple then
			return
		end
		grapple.beam:Destroy()
		grapple.attachment:Destroy()
		grapple = nil
		FxRemote:FireServer("Rope", nil)
	end

	-- where the last tap landed (screen space, below the top bar - ScreenPointToRay's space)
	local lastTouch: Vector2? = nil
	UserInputService.InputBegan:Connect(function(input, processed)
		if not processed and input.UserInputType == Enum.UserInputType.Touch then
			lastTouch = Vector2.new(input.Position.X, input.Position.Y)
		end
	end)

	local function fireGrapple(tool: Tool)
		if grapple then
			stopGrapple()
			return
		end
		if not (fx.grapple and root and humanoid and humanoid.Health > 0) then
			return
		end
		local camera = workspace.CurrentCamera
		if not camera then
			return
		end
		local ray
		if UserInputService.TouchEnabled and lastTouch then
			ray = camera:ScreenPointToRay(lastTouch.X, lastTouch.Y)
			lastTouch = nil
		else
			local m = UserInputService:GetMouseLocation() -- viewport space
			ray = camera:ViewportPointToRay(m.X, m.Y)
		end
		local params = RaycastParams.new()
		params.FilterType = Enum.RaycastFilterType.Exclude
		params.FilterDescendantsInstances = { character }
		local range = fx.grapple.Range or 120
		-- reach is measured from you, not the camera
		local camDist = (camera.CFrame.Position - root.Position).Magnitude
		local hit = workspace:Raycast(ray.Origin, ray.Direction * (range + camDist), params)
		if not hit or (hit.Position - root.Position).Magnitude > range then
			return
		end
		local muzzle = tool:FindFirstChild("Muzzle", true)
		local attachment = Instance.new("Attachment")
		attachment.Name = "StudGearRopeEndLocal"
		attachment.WorldPosition = hit.Position
		attachment.Parent = workspace.Terrain
		local beam = Instance.new("Beam")
		beam.Name = "StudGearRopeLocal"
		beam.Attachment0 = if muzzle and muzzle:IsA("Attachment") then muzzle else nil
		beam.Attachment1 = attachment
		beam.Width0, beam.Width1 = 0.16, 0.16
		beam.FaceCamera = true
		beam.Segments = 1
		beam.Color = ColorSequence.new(Color3.fromRGB(70, 60, 50))
		beam.Parent = attachment
		grapple = { target = hit.Position, beam = beam, attachment = attachment, started = os.clock() }
		humanoid:ChangeState(Enum.HumanoidStateType.Freefall)
		FxRemote:FireServer("Rope", hit.Position)
	end

	-- your own rope is drawn locally (instantly); hide the server's copy of it
	workspace.Terrain.DescendantAdded:Connect(function(d)
		if d:IsA("Beam") and d:GetAttribute("Owner") == player.UserId then
			d.Enabled = false
		end
	end)

	local toolConns = {}
	local function refresh()
		fx = Effects.Combine(held())
		gui.Enabled = fx.jetpack ~= nil
		if fx.jetpack and fuel <= 0 and not airborne() then
			fuel = fx.jetpack.Fuel or 2.5
		end
		if not fx.jetpack then
			setJetFlames(false)
		end
		if not fx.grapple then
			stopGrapple()
		end
		-- crosshair while holding the grapple
		local wantCross = fx.grapple ~= nil
		if wantCross ~= crosshair then
			crosshair = wantCross
			player:GetMouse().Icon = if wantCross then "rbxasset://SystemCursors/Crosshair" else ""
		end
	end

	local function watchTool(tool: Instance)
		if not tool:IsA("Tool") or toolConns[tool] then
			return
		end
		local g = byName[tool:GetAttribute("StudGear") or ""]
		if g and g.Grapple then
			toolConns[tool] = tool.Activated:Connect(function()
				fireGrapple(tool)
			end)
		end
	end

	local function onCharacter(c: Model)
		character = c
		humanoid = c:WaitForChild("Humanoid", 10)
		root = c:WaitForChild("HumanoidRootPart", 10)
		airJumpsUsed, jetting, grapple = 0, false, nil
		fuel = 0
		if not (humanoid and root) then
			return
		end
		local at = Instance.new("Attachment")
		at.Name = "StudGearPuff"
		at.Position = Vector3.new(0, -2.4, 0)
		at.Parent = root
		puff = Instance.new("ParticleEmitter")
		puff.Texture = "rbxasset://textures/particles/smoke_main.dds"
		puff.Rate = 0
		puff.Lifetime = NumberRange.new(0.35, 0.55)
		puff.Speed = NumberRange.new(5, 8)
		puff.SpreadAngle = Vector2.new(80, 80)
		puff.Drag = 6
		puff.Size = NumberSequence.new({ NumberSequenceKeypoint.new(0, 0.6), NumberSequenceKeypoint.new(1, 1.6) })
		puff.Transparency = NumberSequence.new({ NumberSequenceKeypoint.new(0, 0.3), NumberSequenceKeypoint.new(1, 1) })
		puff.Color = ColorSequence.new(Color3.new(1, 1, 1))
		puff.EmissionDirection = Enum.NormalId.Bottom
		puff.Parent = at
		local AIR = { [Enum.HumanoidStateType.Jumping] = true, [Enum.HumanoidStateType.Freefall] = true }
		humanoid.StateChanged:Connect(function(old, new)
			if AIR[new] and not AIR[old] then
				leftGroundAt = os.clock() -- just left the ground
			elseif not AIR[new] then
				airJumpsUsed = 0 -- landed, climbing, swimming...
			end
		end)
		humanoid.Died:Connect(function()
			stopGrapple()
			setJetFlames(false)
		end)
		c.ChildAdded:Connect(function(t)
			watchTool(t)
			refresh()
		end)
		c.ChildRemoved:Connect(function(t)
			if toolConns[t] then
				toolConns[t]:Disconnect()
				toolConns[t] = nil
			end
			refresh()
		end)
		for _, t in c:GetChildren() do
			watchTool(t)
		end
		refresh()
	end
	player.CharacterAdded:Connect(onCharacter)
	if player.Character then
		task.spawn(onCharacter, player.Character)
	end

	------------------------------------------------------------------ input
	UserInputService.JumpRequest:Connect(function()
		local now = os.clock()
		local fresh = now - lastJumpRequest > 0.2 -- held jump repeats faster than this
		lastJumpRequest = now
		if not (humanoid and root and humanoid.Health > 0) then
			return
		end
		if grapple and fresh then
			stopGrapple() -- jump lets go of the rope
			return
		end
		-- mid-air jump
		if fresh and fx.airJumps > 0 and airborne() and airJumpsUsed < fx.airJumps and now - leftGroundAt > 0.12 then
			airJumpsUsed += 1
			local v = Effects.JumpVelocity(humanoid.UseJumpPower, humanoid.JumpPower, humanoid.JumpHeight, workspace.Gravity)
			local vel = root.AssemblyLinearVelocity
			root.AssemblyLinearVelocity = Vector3.new(vel.X, v, vel.Z)
			humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
			if puff then
				puff:Emit(14)
			end
		end
	end)

	local function jumpHeld(): boolean
		return UserInputService:IsKeyDown(Enum.KeyCode.Space)
			or UserInputService:IsGamepadButtonDown(Enum.UserInputType.Gamepad1, Enum.KeyCode.ButtonA)
			or (humanoid ~= nil and humanoid.Jump)
			or os.clock() - lastJumpRequest < 0.15
	end

	------------------------------------------------------------------ per frame
	RunService.Heartbeat:Connect(function(dt)
		if not (humanoid and root and root.Parent and humanoid.Health > 0) then
			return
		end
		local vel = root.AssemblyLinearVelocity
		local vy = vel.Y
		-- grapple pull
		if grapple then
			local p = root.Position
			local t = grapple.target
			local vx, gy, vz = Effects.GrapplePull(p.X, p.Y, p.Z, t.X, t.Y, t.Z, fx.grapple and fx.grapple.Speed or 75)
			if not vx or os.clock() - grapple.started > 3 then
				stopGrapple()
				-- pop up so your feet clear the grab point (your root is ~3 studs above your feet)
				-- and drift onto the ledge you grabbed
				local g = workspace.Gravity * fx.gravity
				local rise = math.max(0, t.Y - p.Y) + 6.5
				local flat = Vector3.new(t.X - p.X, 0, t.Z - p.Z)
				local nudge = if flat.Magnitude > 0.1 then flat.Unit * 14 else Vector3.zero
				root.AssemblyLinearVelocity = Vector3.new(nudge.X, math.max(vy, math.sqrt(2 * g * rise)), nudge.Z)
			else
				root.AssemblyLinearVelocity = Vector3.new(vx, gy, vz)
			end
			return
		end
		-- jetpack
		if fx.jetpack then
			local grounded = not airborne()
			local effectiveGravity = workspace.Gravity * fx.gravity
			local thrust = jumpHeld() and not grounded
			local newVy, newFuel, on = Effects.Jetpack(vy, fuel, thrust, grounded, dt, fx.jetpack, effectiveGravity)
			fuel = newFuel
			if on then
				vy = newVy
				root.AssemblyLinearVelocity = Vector3.new(vel.X, vy, vel.Z)
			end
			setJetFlames(on)
			bar.Size = UDim2.fromScale(math.clamp(fuel / (fx.jetpack.Fuel or 2.5), 0, 1), 1)
			bar.BackgroundColor3 = if fuel < 0.5 then Color3.fromRGB(255, 80, 60) else Color3.fromRGB(255, 160, 50)
		end
		-- slow fall
		if fx.maxFall then
			local capped = Effects.SlowFall(vy, fx.maxFall)
			if capped ~= vy then
				root.AssemblyLinearVelocity = Vector3.new(vel.X, capped, vel.Z)
			end
		end
	end)
end

return Abilities
