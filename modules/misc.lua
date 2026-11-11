-- Misc: anti-afk, fullbright, FOV, player tools, server tools
return function(Tab, Library)
	local Players = game:GetService("Players")
	local RunService = game:GetService("RunService")
	local UIS = game:GetService("UserInputService")
	local Lighting = game:GetService("Lighting")
	local VirtualUser = game:GetService("VirtualUser")
	local TeleportService = game:GetService("TeleportService")
	local HttpService = game:GetService("HttpService")
	local lp = Players.LocalPlayer

	local S = { AFK = true, FB = false, FOV = false, FOVVal = 70, ClickTP = false, Selected = nil }

	local origLight = {
		Brightness = Lighting.Brightness, ClockTime = Lighting.ClockTime, FogEnd = Lighting.FogEnd,
		GlobalShadows = Lighting.GlobalShadows, Ambient = Lighting.Ambient, OutdoorAmbient = Lighting.OutdoorAmbient,
	}
	local origFOV = workspace.CurrentCamera and workspace.CurrentCamera.FieldOfView or 70

	-- Utility
	Tab:Section("Utility")
	Tab:Toggle({ Name = "Anti-AFK", Default = true, Flag = "antiafk", NoKey = true, Callback = function(v) S.AFK = v end })
	Library.Connect(lp.Idled, function()
		if not S.AFK then return end
		pcall(function()
			VirtualUser:CaptureController()
			VirtualUser:ClickButton2(Vector2.new(0, 0))
		end)
	end)

	Tab:Toggle({ Name = "Fullbright", Flag = "fullbright", Callback = function(v)
		S.FB = v
		if not v then
			for k, val in pairs(origLight) do Lighting[k] = val end
		end
	end })
	Library.Connect(RunService.Heartbeat, function()
		if not S.FB then return end
		Lighting.Brightness = 2
		Lighting.ClockTime = 14
		Lighting.FogEnd = 1e5
		Lighting.GlobalShadows = false
		Lighting.Ambient = Color3.fromRGB(178, 178, 178)
		Lighting.OutdoorAmbient = Color3.fromRGB(178, 178, 178)
	end)

	Tab:Toggle({ Name = "Custom FOV", Flag = "fov", Callback = function(v)
		S.FOV = v
		if not v and workspace.CurrentCamera then workspace.CurrentCamera.FieldOfView = origFOV end
	end })
	Tab:Slider({ Name = "FOV Value", Min = 30, Max = 120, Default = 90, Flag = "fov_val", Callback = function(v) S.FOVVal = v end })
	Library.Connect(RunService.RenderStepped, function()
		if S.FOV and workspace.CurrentCamera then workspace.CurrentCamera.FieldOfView = S.FOVVal end
	end)

	-- Players
	Tab:Section("Players")
	local function playerNames()
		local t = {}
		for _, p in ipairs(Players:GetPlayers()) do
			if p ~= lp then table.insert(t, p.Name) end
		end
		table.sort(t)
		return t
	end
	local function selectedPlayer()
		local p = S.Selected and Players:FindFirstChild(S.Selected)
		if p and p:IsA("Player") then return p end
		return nil
	end

	Tab:Dropdown({ Name = "Select Player", Options = playerNames, Callback = function(v) S.Selected = v end })

	Tab:Button("Teleport to Player", function()
		local p = selectedPlayer()
		local tr = p and p.Character and p.Character:FindFirstChild("HumanoidRootPart")
		local mr = lp.Character and lp.Character:FindFirstChild("HumanoidRootPart")
		if tr and mr then
			mr.CFrame = tr.CFrame * CFrame.new(0, 0, 3)
			Library.Notify("Teleported", "To " .. p.Name, "on")
		else
			Library.Notify("Teleport failed", "Select a valid player first", "off")
		end
	end)

	Tab:Toggle({ Name = "Spectate Player", NoKey = true, Callback = function(v)
		local cam = workspace.CurrentCamera
		if v then
			local p = selectedPlayer()
			local h = p and p.Character and p.Character:FindFirstChildOfClass("Humanoid")
			if h then
				cam.CameraSubject = h
			else
				Library.Notify("Spectate failed", "Select a valid player first", "off")
			end
		else
			local mh = lp.Character and lp.Character:FindFirstChildOfClass("Humanoid")
			if mh then cam.CameraSubject = mh end
		end
	end })

	Tab:Toggle({ Name = "Click Teleport (Ctrl + Click)", Flag = "clicktp", Callback = function(v) S.ClickTP = v end })
	local mouse = lp:GetMouse()
	Library.Connect(UIS.InputBegan, function(i, gp)
		if gp or not S.ClickTP then return end
		if i.UserInputType == Enum.UserInputType.MouseButton1 and UIS:IsKeyDown(Enum.KeyCode.LeftControl) then
			local root = lp.Character and lp.Character:FindFirstChild("HumanoidRootPart")
			if root and mouse.Hit then
				root.CFrame = CFrame.new(mouse.Hit.Position + Vector3.new(0, 3, 0))
			end
		end
	end)

	-- Server
	Tab:Section("Server")
	Tab:Button("Rejoin", function()
		if #Players:GetPlayers() <= 1 then
			TeleportService:Teleport(game.PlaceId, lp)
		else
			TeleportService:TeleportToPlaceInstance(game.PlaceId, game.JobId, lp)
		end
	end)
	Tab:Button("Server Hop", function()
		Library.Notify("Server Hop", "Searching for a server...", "on")
		local ok, data = pcall(function()
			return HttpService:JSONDecode(game:HttpGet("https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?sortOrder=Asc&limit=100"))
		end)
		if not ok or type(data) ~= "table" or not data.data then
			Library.Notify("Server Hop failed", "Could not fetch server list", "off")
			return
		end
		local pool = {}
		for _, s in ipairs(data.data) do
			if s.id ~= game.JobId and s.playing < s.maxPlayers then table.insert(pool, s.id) end
		end
		if #pool == 0 then
			Library.Notify("Server Hop failed", "No free server found", "off")
			return
		end
		TeleportService:TeleportToPlaceInstance(game.PlaceId, pool[math.random(1, #pool)], lp)
	end)

	table.insert(Library.OnUnload, function()
		S.FB, S.FOV = false, false
		for k, val in pairs(origLight) do Lighting[k] = val end
		if workspace.CurrentCamera then workspace.CurrentCamera.FieldOfView = origFOV end
		local mh = lp.Character and lp.Character:FindFirstChildOfClass("Humanoid")
		if mh and workspace.CurrentCamera then workspace.CurrentCamera.CameraSubject = mh end
	end)
end
