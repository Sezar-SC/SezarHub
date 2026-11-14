-- MM2 game tab v1: role ESP, GunDrop ESP, grab gun
return function(Window, Library)
	local Players = game:GetService("Players")
	local RunService = game:GetService("RunService")
	local lp = Players.LocalPlayer

	local Tab = Window:AddTab("MM2")

	local S = { Roles = false, Innocent = true, Gun = false }
	local COL = {
		Murderer = Color3.fromRGB(255, 60, 60),
		Sheriff = Color3.fromRGB(60, 140, 255),
		Innocent = Color3.fromRGB(60, 255, 100),
		Gun = Color3.fromRGB(255, 230, 60),
	}

	local holder = Instance.new("Folder")
	holder.Name = "SezarMM2"
	holder.Parent = Library.GuiParent

	local cache, gunObj = {}, nil

	local function has(c, n)
		return c ~= nil and c:FindFirstChild(n) ~= nil
	end

	local function roleOf(p)
		local bp = p:FindFirstChildOfClass("Backpack")
		local ch = p.Character
		if has(bp, "Knife") or has(ch, "Knife") then return "Murderer" end
		if has(bp, "Gun") or has(ch, "Gun") then return "Sheriff" end
		return "Innocent"
	end

	local function makeTag(adornee, offset)
		local g = Instance.new("BillboardGui")
		g.Adornee = adornee
		g.AlwaysOnTop = true
		g.Size = UDim2.new(0, 160, 0, 30)
		g.StudsOffset = offset
		g.Parent = holder
		local l = Instance.new("TextLabel")
		l.BackgroundTransparency = 1
		l.Size = UDim2.new(1, 0, 1, 0)
		l.Font = Enum.Font.GothamBold
		l.TextSize = 13
		l.TextStrokeTransparency = 0.3
		l.Parent = g
		return g, l
	end

	local function makeHl(adornee)
		local h = Instance.new("Highlight")
		h.Adornee = adornee
		h.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
		h.FillTransparency = 0.6
		h.OutlineTransparency = 0
		h.Parent = holder
		return h
	end

	local function removePlayer(p)
		local c = cache[p]
		if c then
			if c.hl then pcall(function() c.hl:Destroy() end) end
			if c.tag then pcall(function() c.tag:Destroy() end) end
		end
		cache[p] = nil
	end

	local function clearPlayers()
		for p in pairs(cache) do removePlayer(p) end
	end

	local function clearGun()
		if gunObj then
			if gunObj.hl then pcall(function() gunObj.hl:Destroy() end) end
			if gunObj.tag then pcall(function() gunObj.tag:Destroy() end) end
		end
		gunObj = nil
	end

	local function findGunPart()
		local gd = workspace:FindFirstChild("GunDrop", true)
		if not gd then return nil end
		if gd:IsA("BasePart") then return gd end
		return gd:FindFirstChildWhichIsA("BasePart", true)
	end

	local function updateRoles()
		for _, p in ipairs(Players:GetPlayers()) do
			if p ~= lp then
				local ch = p.Character
				local hum = ch and ch:FindFirstChildOfClass("Humanoid")
				local head = ch and ch:FindFirstChild("Head")
				local role = roleOf(p)
				local hidden = not (hum and head) or hum.Health <= 0
				if role == "Innocent" and not S.Innocent then hidden = true end

				if hidden then
					removePlayer(p)
				else
					local c = cache[p]
					if not c or c.char ~= ch then
						removePlayer(p)
						local tag, label = makeTag(head, Vector3.new(0, 2.4, 0))
						c = { char = ch, hl = makeHl(ch), tag = tag, label = label }
						cache[p] = c
					end
					local col = COL[role]
					c.hl.FillColor = col
					c.hl.OutlineColor = col
					c.label.Text = p.Name .. " [" .. role .. "]"
					c.label.TextColor3 = col
				end
			end
		end
	end

	local function updateGun()
		local part = findGunPart()
		if not part then
			clearGun()
			return
		end
		if not gunObj or gunObj.part ~= part then
			clearGun()
			local tag, label = makeTag(part, Vector3.new(0, 2, 0))
			label.Text = "GUN"
			label.TextColor3 = COL.Gun
			gunObj = { part = part, hl = makeHl(part), tag = tag }
			gunObj.hl.FillColor = COL.Gun
			gunObj.hl.OutlineColor = COL.Gun
		end
	end

	local function grabGun()
		local part = findGunPart()
		local ch = lp.Character
		local root = ch and ch:FindFirstChild("HumanoidRootPart")
		if not part or not root then
			Library.Notify("MM2", "Gun not found", "on")
			return
		end
		local old = root.CFrame
		root.CFrame = part.CFrame
		if firetouchinterest then
			pcall(function()
				firetouchinterest(root, part, 0)
				task.wait()
				firetouchinterest(root, part, 1)
			end)
		end
		task.wait(0.3)
		if root and root.Parent then root.CFrame = old end
	end

	Tab:Section("ESP")
	Tab:Toggle({ Name = "Role ESP", Flag = "mm2_roles", Callback = function(v)
		S.Roles = v
		if not v then clearPlayers() end
	end })
	Tab:Toggle({ Name = "Show Innocents", Default = true, Flag = "mm2_innocent", NoKey = true, Callback = function(v) S.Innocent = v end })
	Tab:Toggle({ Name = "GunDrop ESP", Flag = "mm2_gun", Callback = function(v)
		S.Gun = v
		if not v then clearGun() end
	end })

	Tab:Section("Actions")
	Tab:Button("Grab Gun", function()
		task.spawn(function()
			local ok = pcall(grabGun)
			if not ok then Library.Notify("MM2", "Grab failed", "on") end
		end)
	end)

	local acc = 0
	Library.Connect(RunService.Heartbeat, function(dt)
		acc = acc + dt
		if acc < 0.2 then return end
		acc = 0
		if S.Roles then pcall(updateRoles) end
		if S.Gun then pcall(updateGun) end
	end)
	Library.Connect(Players.PlayerRemoving, removePlayer)

	table.insert(Library.OnUnload, function()
		S.Roles, S.Gun = false, false
		clearPlayers()
		clearGun()
		holder:Destroy()
	end)
end
