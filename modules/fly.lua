-- Fly + Noclip
return function(Tab, Library)
	local Players = game:GetService("Players")
	local RunService = game:GetService("RunService")
	local UIS = game:GetService("UserInputService")
	local lp = Players.LocalPlayer

	local S = { Fly = false, Speed = 60, Noclip = false }
	local bv, bg

	local function parts()
		local c = lp.Character
		if not c then return nil end
		return c, c:FindFirstChildOfClass("Humanoid"), c:FindFirstChild("HumanoidRootPart")
	end

	local function cleanup()
		if bv then bv:Destroy(); bv = nil end
		if bg then bg:Destroy(); bg = nil end
		local _, h = parts()
		if h then h.PlatformStand = false end
	end

	Tab:Section("Fly")
	Tab:Toggle({ Name = "Fly", Flag = "fly", Key = Enum.KeyCode.F, Callback = function(v)
		S.Fly = v
		if not v then cleanup() end
	end })
	Tab:Slider({ Name = "Fly Speed", Min = 10, Max = 300, Default = 60, HardMax = 1000, Flag = "fly_speed", Callback = function(v) S.Speed = v end })
	Tab:Label("Controls: WASD to move, Space = up, LeftShift = down")

	Tab:Section("Noclip")
	Tab:Toggle({ Name = "Noclip", Flag = "noclip", Key = Enum.KeyCode.N, Callback = function(v) S.Noclip = v end })

	Library.Connect(RunService.Heartbeat, function()
		if not S.Fly then return end
		local _, h, root = parts()
		if not (h and root) then return end
		if not bv or bv.Parent ~= root then
			cleanup()
			bv = Instance.new("BodyVelocity")
			bv.MaxForce = Vector3.new(1e9, 1e9, 1e9)
			bv.Velocity = Vector3.zero
			bv.Parent = root
			bg = Instance.new("BodyGyro")
			bg.MaxTorque = Vector3.new(1e9, 1e9, 1e9)
			bg.P = 9e4
			bg.Parent = root
		end
		h.PlatformStand = true
		local cam = workspace.CurrentCamera
		local dir = Vector3.zero
		if not UIS:GetFocusedTextBox() then
			if UIS:IsKeyDown(Enum.KeyCode.W) then dir = dir + cam.CFrame.LookVector end
			if UIS:IsKeyDown(Enum.KeyCode.S) then dir = dir - cam.CFrame.LookVector end
			if UIS:IsKeyDown(Enum.KeyCode.D) then dir = dir + cam.CFrame.RightVector end
			if UIS:IsKeyDown(Enum.KeyCode.A) then dir = dir - cam.CFrame.RightVector end
			if UIS:IsKeyDown(Enum.KeyCode.Space) then dir = dir + Vector3.new(0, 1, 0) end
			if UIS:IsKeyDown(Enum.KeyCode.LeftShift) then dir = dir - Vector3.new(0, 1, 0) end
		end
		if dir.Magnitude > 0 then
			bv.Velocity = dir.Unit * S.Speed
		else
			bv.Velocity = Vector3.zero
		end
		bg.CFrame = cam.CFrame
	end)

	Library.Connect(RunService.Stepped, function()
		if not S.Noclip then return end
		local c = lp.Character
		if not c then return end
		for _, p in ipairs(c:GetDescendants()) do
			if p:IsA("BasePart") and p.CanCollide then p.CanCollide = false end
		end
	end)

	table.insert(Library.OnUnload, function()
		S.Fly, S.Noclip = false, false
		cleanup()
	end)
end
