-- Hareket modulu: hiz, ziplama, sonsuz ziplama
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

	local S = { Speed = false, SpeedVal = 50, Jump = false, JumpVal = 100, Inf = false }

	Tab:Section("Hiz")
	Tab:Toggle("Hiz", false, function(v)
		S.Speed = v
		if not v then
			local h = hum()
			if h then h.WalkSpeed = defaultSpeed end
		end
	end)
	Tab:Slider("Hiz Degeri", 16, 200, 50, function(v) S.SpeedVal = v end, 1000)

	Tab:Section("Ziplama")
	Tab:Toggle("Ziplama", false, function(v)
		S.Jump = v
		if not v then
			local h = hum()
			if h then h.JumpPower = defaultJump end
		end
	end)
	Tab:Slider("Ziplama Degeri", 50, 300, 100, function(v) S.JumpVal = v end, 1000)

	Tab:Section("Diger")
	Tab:Toggle("Sonsuz Ziplama", false, function(v) S.Inf = v end)

	-- degerleri her kare uygula (respawn olunca da calisir)
	Library.Connect(RunService.Heartbeat, function()
		local h = hum()
		if not h then return end
		if S.Speed then h.WalkSpeed = S.SpeedVal end
		if S.Jump then
			h.UseJumpPower = true
			h.JumpPower = S.JumpVal
		end
	end)

	Library.Connect(UIS.JumpRequest, function()
		if S.Inf then
			local h = hum()
			if h then h:ChangeState(Enum.HumanoidStateType.Jumping) end
		end
	end)
end
