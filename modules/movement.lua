-- Movement: speed, jump, infinite jump
return function(Tab, Library)
	local Players = game:GetService("Players")
	local RunService = game:GetService("RunService")
	local UIS = game:GetService("UserInputService")
	local lp = Players.LocalPlayer

	local function hum()
		local c = lp.Character
		return c and c:FindFirstChildOfClass("Humanoid")
	end

	local h0 = hum()
	local defaultSpeed = h0 and h0.WalkSpeed or 16
	local defaultJump = h0 and h0.JumpPower or 50

	local S = { Speed = false, SpeedVal = 50, Jump = false, JumpVal = 100, Inf = false, CF = false, CFVal = 40 }

	Tab:Section("Speed")
	Tab:Toggle({ Name = "Speed", Flag = "speed", Callback = function(v)
		S.Speed = v
		if not v then
			local h = hum()
			if h then h.WalkSpeed = defaultSpeed end
		end
	end })
	Tab:Slider({ Name = "Speed Value", Min = 16, Max = 200, Default = 50, HardMax = 1000, Flag = "speed_val", Callback = function(v) S.SpeedVal = v end })
	Tab:Toggle({ Name = "CFrame Speed (alt)", Flag = "cfspeed", Callback = function(v) S.CF = v end })
	Tab:Slider({ Name = "CFrame Speed Value", Min = 10, Max = 200, Default = 40, HardMax = 500, Flag = "cfspeed_val", Callback = function(v) S.CFVal = v end })

	Tab:Section("Jump")
	Tab:Toggle({ Name = "Jump", Flag = "jump", Callback = function(v)
		S.Jump = v
		if not v then
			local h = hum()
			if h then h.JumpPower = defaultJump end
		end
	end })
	Tab:Slider({ Name = "Jump Value", Min = 50, Max = 300, Default = 100, HardMax = 1000, Flag = "jump_val", Callback = function(v) S.JumpVal = v end })
	Tab:Toggle({ Name = "Infinite Jump", Flag = "infjump", Callback = function(v) S.Inf = v end })

	Library.Connect(RunService.Heartbeat, function(dt)
		local h = hum()
		if not h then return end
		if S.Speed then h.WalkSpeed = S.SpeedVal end
		if S.Jump then
			h.UseJumpPower = true
			h.JumpPower = S.JumpVal
		end
		if S.CF and h.MoveDirection.Magnitude > 0 then
			local root = h.Parent and h.Parent:FindFirstChild("HumanoidRootPart")
			if root then root.CFrame = root.CFrame + h.MoveDirection * S.CFVal * dt end
		end
	end)

	Library.Connect(UIS.JumpRequest, function()
		if S.Inf then
			local h = hum()
			if h then h:ChangeState(Enum.HumanoidStateType.Jumping) end
		end
	end)

	table.insert(Library.OnUnload, function()
		S.Speed, S.Jump, S.CF, S.Inf = false, false, false, false
		local h = hum()
		if h then
			h.WalkSpeed = defaultSpeed
			h.JumpPower = defaultJump
		end
	end)
end
