-- ESP: names, distance, health, box, highlight
return function(Tab, Library)
	local Players = game:GetService("Players")
	local RunService = game:GetService("RunService")
	local lp = Players.LocalPlayer

	local COLORS = {
		Purple = Color3.fromRGB(150, 70, 255), Red = Color3.fromRGB(255, 60, 60),
		Green = Color3.fromRGB(60, 255, 100), Blue = Color3.fromRGB(60, 140, 255),
		Cyan = Color3.fromRGB(60, 240, 240), Yellow = Color3.fromRGB(255, 230, 60),
		Orange = Color3.fromRGB(255, 150, 40), White = Color3.fromRGB(255, 255, 255),
	}
	local COLOR_NAMES = { "Purple", "Red", "Green", "Blue", "Cyan", "Yellow", "Orange", "White" }

	local S = {
		On = false, Names = true, Dist = true, Health = true, Box = false, Highlight = true,
		TeamCheck = false, TeamColor = false, Color = "Purple", MaxDist = 3000,
	}

	local holder = Instance.new("Folder")
	holder.Name = "SezarESP"
	holder.Parent = Library.GuiParent

	local cache, chars = {}, {}

	local function remove(p)
		local c = cache[p]
		if c then
			for _, o in pairs(c) do
				pcall(function() o:Destroy() end)
			end
		end
		cache[p] = nil
		chars[p] = nil
	end

	local function clearAll()
		for p in pairs(cache) do remove(p) end
	end

	local function build(char, root, head)
		local c = {}
		c.hl = Instance.new("Highlight")
		c.hl.Adornee = char
		c.hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
		c.hl.FillTransparency = 0.6
		c.hl.OutlineTransparency = 0
		c.hl.Parent = holder

		c.box = Instance.new("BillboardGui")
		c.box.Adornee = root
		c.box.AlwaysOnTop = true
		c.box.Size = UDim2.new(4, 0, 6, 0)
		c.box.Parent = holder
		local fr = Instance.new("Frame")
		fr.BackgroundTransparency = 1
		fr.Size = UDim2.new(1, 0, 1, 0)
		fr.Parent = c.box
		c.boxStroke = Instance.new("UIStroke")
		c.boxStroke.Thickness = 1.5
		c.boxStroke.Parent = fr

		c.tag = Instance.new("BillboardGui")
		c.tag.Adornee = head
		c.tag.AlwaysOnTop = true
		c.tag.Size = UDim2.new(0, 200, 0, 40)
		c.tag.StudsOffset = Vector3.new(0, 2.6, 0)
		c.tag.Parent = holder
		c.label = Instance.new("TextLabel")
		c.label.BackgroundTransparency = 1
		c.label.Size = UDim2.new(1, 0, 1, 0)
		c.label.Font = Enum.Font.GothamBold
		c.label.TextSize = 13
		c.label.TextStrokeTransparency = 0.3
		c.label.Parent = c.tag
		return c
	end

	local function update()
		local cam = workspace.CurrentCamera
		for _, p in ipairs(Players:GetPlayers()) do
			if p ~= lp then
				local char = p.Character
				local hum = char and char:FindFirstChildOfClass("Humanoid")
				local root = char and char:FindFirstChild("HumanoidRootPart")
				local head = char and char:FindFirstChild("Head")
				local hidden = not (hum and root and head) or hum.Health <= 0
				local dist = 0
				if not hidden then
					if S.TeamCheck and p.Team ~= nil and p.Team == lp.Team then hidden = true end
					if cam then
						dist = (root.Position - cam.CFrame.Position).Magnitude
						if dist > S.MaxDist then hidden = true end
					end
				end

				if hidden then
					remove(p)
				else
					if chars[p] ~= char then
						remove(p)
						cache[p] = build(char, root, head)
						chars[p] = char
					end
					local c = cache[p]
					local col = COLORS[S.Color] or COLORS.Purple
					if S.TeamColor and p.Team then col = p.TeamColor.Color end

					local rs = Library.RoleESP == true
					c.hl.Enabled = S.Highlight and not rs
					c.hl.FillColor = col
					c.hl.OutlineColor = col
					c.box.Enabled = S.Box
					c.boxStroke.Color = col

					local lines = {}
					if S.Names and not rs then table.insert(lines, p.Name) end
					local info = {}
					if S.Dist then table.insert(info, math.floor(dist) .. "m") end
					if S.Health then table.insert(info, math.floor(hum.Health) .. " HP") end
					if #info > 0 then table.insert(lines, table.concat(info, "  ")) end
					c.tag.Enabled = #lines > 0
					c.tag.StudsOffset = Vector3.new(0, rs and 3.8 or 2.6, 0)
					c.label.Text = table.concat(lines, "\n")
					c.label.TextColor3 = col
				end
			end
		end
	end

	Tab:Section("ESP")
	Tab:Toggle({ Name = "ESP Enabled", Flag = "esp", Callback = function(v)
		S.On = v
		if not v then clearAll() end
	end })
	Tab:Toggle({ Name = "Names", Default = true, Flag = "esp_names", NoKey = true, Callback = function(v) S.Names = v end })
	Tab:Toggle({ Name = "Distance", Default = true, Flag = "esp_dist", NoKey = true, Callback = function(v) S.Dist = v end })
	Tab:Toggle({ Name = "Health", Default = true, Flag = "esp_health", NoKey = true, Callback = function(v) S.Health = v end })
	Tab:Toggle({ Name = "Box", Flag = "esp_box", NoKey = true, Callback = function(v) S.Box = v end })
	Tab:Toggle({ Name = "Highlight (through walls)", Default = true, Flag = "esp_hl", NoKey = true, Callback = function(v) S.Highlight = v end })

	Tab:Section("Options")
	Tab:Toggle({ Name = "Hide Teammates", Flag = "esp_team", NoKey = true, Callback = function(v) S.TeamCheck = v end })
	Tab:Toggle({ Name = "Use Team Colors", Flag = "esp_teamcolor", NoKey = true, Callback = function(v) S.TeamColor = v end })
	Tab:Dropdown({ Name = "ESP Color", Options = COLOR_NAMES, Default = "Purple", Flag = "esp_color", Callback = function(v) S.Color = v end })
	Tab:Slider({ Name = "Max Distance", Min = 100, Max = 5000, Default = 3000, HardMax = 100000, Flag = "esp_maxdist", Callback = function(v) S.MaxDist = v end })

	local acc = 0
	Library.Connect(RunService.Heartbeat, function(dt)
		if not S.On then return end
		acc = acc + dt
		if acc < 0.1 then return end
		acc = 0
		pcall(update)
	end)
	Library.Connect(Players.PlayerRemoving, remove)

	table.insert(Library.OnUnload, function()
		S.On = false
		clearAll()
		holder:Destroy()
	end)
end
