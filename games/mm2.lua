-- MM2 game tab v1: role ESP, GunDrop ESP, grab gun
return function(Window, Library)
	local Players = game:GetService("Players")
	local RunService = game:GetService("RunService")
	local lp = Players.LocalPlayer

	local Tab = Window:AddTab("MM2")

	local S = { Roles = false, Innocent = true, Gun = false, Coin = false, Farm = false, Avoid = true, BagLobby = true }
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

	local coins, coinCont, lastFind = {}, nil, 0

	local function clearCoins()
		for _, g in pairs(coins) do pcall(function() g:Destroy() end) end
		coins = {}
	end

	local function updateCoins()
		if not coinCont or not coinCont.Parent then
			if os.clock() - lastFind < 1 then return end
			lastFind = os.clock()
			coinCont = workspace:FindFirstChild("CoinContainer", true)
		end
		local seen = {}
		if coinCont then
			for _, c in ipairs(coinCont:GetChildren()) do
				if c:IsA("BasePart") then
					seen[c] = true
					if not coins[c] then
						local g = Instance.new("BillboardGui")
						g.Adornee = c
						g.AlwaysOnTop = true
						g.Size = UDim2.new(0, 10, 0, 10)
						g.Parent = holder
						local f = Instance.new("Frame")
						f.Size = UDim2.new(1, 0, 1, 0)
						f.BackgroundColor3 = COL.Gun
						f.BorderSizePixel = 0
						f.Parent = g
						Instance.new("UICorner", f).CornerRadius = UDim.new(1, 0)
						coins[c] = g
					end
				end
			end
		end
		for c, g in pairs(coins) do
			if not seen[c] or not c.Parent then
				pcall(function() g:Destroy() end)
				coins[c] = nil
			end
		end
	end

	local function spawnCF(model)
		local sp = model and model:FindFirstChild("Spawns")
		if not sp then return nil end
		local list = sp:GetChildren()
		local p = list[math.random(1, math.max(#list, 1))]
		if p and p:IsA("BasePart") then return p.CFrame end
		return nil
	end

	local function tpTo(cf)
		local ch = lp.Character
		local root = ch and ch:FindFirstChild("HumanoidRootPart")
		if not root or not cf then return false end
		root.CFrame = cf + Vector3.new(0, 3, 0)
		return true
	end

	local function findMap()
		for _, m in ipairs(workspace:GetChildren()) do
			if m:IsA("Model") and m.Name ~= "Lobby" and m:FindFirstChild("Spawns") then
				return m
			end
		end
		return nil
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

	local TweenService = game:GetService("TweenService")
	local SPEEDS = { Slow = 20, Normal = 28 }
	local farmSpeed = SPEEDS.Normal
	local farmId, curTween, bagGui = 0, nil, nil
	local coinCount, farmStart = 0, nil
	local grabbing, lastGun = false, nil
	local visited = setmetatable({}, { __mode = "k" })
	local lastCont = nil

	local FULLWORDS = {
		full = true, dolu = true, lleno = true, voll = true,
		cheio = true, plein = true, pieno = true, penuh = true,
	}
	local bagLbl, lastScan = nil, 0

	local function isShown(o)
		while o and o ~= game do
			if o:IsA("GuiObject") and not o.Visible then return false end
			if o:IsA("ScreenGui") and not o.Enabled then return false end
			o = o.Parent
		end
		return true
	end

	local function isFullText(t)
		local s = tostring(t):lower():gsub("[%s%p]", "")
		return FULLWORDS[s] == true
	end

	local function bagFull()
		local pg = lp:FindFirstChild("PlayerGui")
		if not pg then return false end
		if bagLbl and bagLbl.Parent then
			return isShown(bagLbl) and isFullText(bagLbl.Text)
		end
		if os.clock() - lastScan < 1 then return false end
		lastScan = os.clock()
		for _, d in ipairs(pg:GetDescendants()) do
			if d:IsA("TextLabel") and isFullText(d.Text) and isShown(d) then
				bagLbl = d
				return true
			end
		end
		return false
	end

	local function inLobby(root)
		local lobby = workspace:FindFirstChild("Lobby")
		if not lobby or not root then return false end
		local ok, cf, size = pcall(function() return lobby:GetBoundingBox() end)
		if not ok or not cf then return false end
		local rel = cf:PointToObjectSpace(root.Position)
		local h = size / 2 + Vector3.new(15, 60, 15)
		return math.abs(rel.X) <= h.X and math.abs(rel.Y) <= h.Y and math.abs(rel.Z) <= h.Z
	end

	local function murdererRoot()
		for _, p in ipairs(Players:GetPlayers()) do
			if p ~= lp and roleOf(p) == "Murderer" then
				local c = p.Character
				return c and c:FindFirstChild("HumanoidRootPart")
			end
		end
		return nil
	end

	local function segDist(a, b, p)
		local ab = b - a
		local l2 = ab:Dot(ab)
		if l2 == 0 then return (p - a).Magnitude end
		local t = math.clamp((p - a):Dot(ab) / l2, 0, 1)
		return (p - (a + ab * t)).Magnitude
	end

	local function pickCoin(root)
		if not coinCont or not coinCont.Parent then
			coinCont = workspace:FindFirstChild("CoinContainer", true)
		end
		if not coinCont then return nil end
		if coinCont ~= lastCont then
			lastCont = coinCont
			visited = setmetatable({}, { __mode = "k" })
		end
		local mr = S.Avoid and murdererRoot() or nil
		local best, bd = nil, math.huge
		for _, c in ipairs(coinCont:GetChildren()) do
			if c:IsA("BasePart") and not visited[c] then
				local safe = true
				if mr then
					safe = (mr.Position - c.Position).Magnitude >= 45
						and segDist(root.Position, c.Position, mr.Position) >= 30
				end
				if safe then
					local d = (root.Position - c.Position).Magnitude
					if d < bd then best, bd = c, d end
				end
			end
		end
		return best, bd
	end

	-- returns true if the tween finished, false if cancelled (murderer too close)
	local function goTo(root, cf, watch, id)
		local dist = (root.Position - cf.Position).Magnitude
		local t = math.max(dist / farmSpeed, 0.05)
		local tw = TweenService:Create(root, TweenInfo.new(t, Enum.EasingStyle.Linear), { CFrame = cf })
		curTween = tw
		local done = false
		local con = tw.Completed:Connect(function() done = true end)
		tw:Play()
		local finished = true
		while not done and S.Farm and farmId == id do
			if watch then
				local mr = murdererRoot()
				if mr and (mr.Position - root.Position).Magnitude < 28 then
					pcall(function() tw:Cancel() end)
					finished = false
					break
				end
			end
			task.wait(0.1)
		end
		con:Disconnect()
		return finished and done
	end

	local function fleeFrom(root, mr, id)
		local best, bd = nil, 0
		if coinCont and coinCont.Parent then
			for _, c in ipairs(coinCont:GetChildren()) do
				if c:IsA("BasePart") and not visited[c] then
					local d = (mr.Position - c.Position).Magnitude
					if d > bd and segDist(root.Position, c.Position, mr.Position) >= 12 then
						best, bd = c, d
					end
				end
			end
		end
		if best then
			goTo(root, best.CFrame, false, id)
		end
	end

	local function farmLoop(id)
		local wasLobby, stuck, full = true, 0, false
		while S.Farm and farmId == id do
			local ok = pcall(function()
				local ch = lp.Character
				local root = ch and ch:FindFirstChild("HumanoidRootPart")
				local hum = ch and ch:FindFirstChildOfClass("Humanoid")
				if not root or not hum or hum.Health <= 0 then
					wasLobby = true
					task.wait(1)
					return
				end

				if grabbing then
					task.wait(0.2)
					return
				end

				-- lobby: wait for the round, do not move
				if inLobby(root) then
					wasLobby, full, stuck = true, false, 0
					task.wait(1)
					return
				end

				-- just arrived in the map: new round
				if wasLobby then
					wasLobby, full, stuck = false, false, 0
					visited = setmetatable({}, { __mode = "k" })
					task.wait(1.5)
					return
				end

				if not full and bagFull() then full = true end
				if full then
					if S.BagLobby then
						tpTo(spawnCF(workspace:FindFirstChild("Lobby")))
					end
					task.wait(2)
					return
				end

				if S.Avoid then
					local mr = murdererRoot()
					if mr and (mr.Position - root.Position).Magnitude < 40 then
						fleeFrom(root, mr, id)
						task.wait(0.2)
						return
					end
				end

				local coin = pickCoin(root)
				if not coin then
					task.wait(0.5)
					return
				end
				if goTo(root, coin.CFrame, S.Avoid, id) then
					visited[coin] = true
					coinCount = coinCount + 1
					task.wait(0.3)
				end
			end)
			if not ok then task.wait(0.5) end
		end
	end

	local function stopFarm()
		S.Farm = false
		farmId = farmId + 1
		if curTween then pcall(function() curTween:Cancel() end) end
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

	Tab:Toggle({ Name = "Coin ESP", Flag = "mm2_coin", Callback = function(v)
		S.Coin = v
		if not v then clearCoins() end
	end })

	Tab:Section("Actions")
	Tab:Button("Grab Gun", function()
		task.spawn(function()
			local ok = pcall(grabGun)
			if not ok then Library.Notify("MM2", "Grab failed", "on") end
		end)
	end)

	Tab:Button("Teleport to Lobby", function()
		local ok = pcall(function()
			if not tpTo(spawnCF(workspace:FindFirstChild("Lobby"))) then
				Library.Notify("MM2", "Lobby not found", "on")
			end
		end)
		if not ok then Library.Notify("MM2", "Teleport failed", "on") end
	end)
	Tab:Button("Teleport to Map", function()
		local ok = pcall(function()
			if not tpTo(spawnCF(findMap())) then
				Library.Notify("MM2", "Map not found", "on")
			end
		end)
		if not ok then Library.Notify("MM2", "Teleport failed", "on") end
	end)

	Tab:Section("Auto Farm")
	Tab:Toggle({ Name = "Auto Farm Coins", Flag = "mm2_farm", Callback = function(v)
		if v then
			S.Farm = true
			coinCount, farmStart = 0, os.clock()
			farmId = farmId + 1
			task.spawn(farmLoop, farmId)
		else
			stopFarm()
		end
	end })
	Tab:Toggle({ Name = "Avoid Murderer", Default = true, Flag = "mm2_avoid", NoKey = true, Callback = function(v) S.Avoid = v end })
	Tab:Toggle({ Name = "Lobby on Full Bag", Default = true, Flag = "mm2_baglobby", NoKey = true, Callback = function(v) S.BagLobby = v end })
	Tab:Dropdown({
		Name = "Farm Speed", Flag = "mm2_speed", Default = "Normal",
		Options = { "Slow", "Normal" },
		Callback = function(v) farmSpeed = SPEEDS[v] or farmSpeed end,
	})
	Tab:Button("Check Bag", function()
		Library.Notify("Bag", bagFull() and "Full" or "Not full", "on")
	end)
	Tab:Button("Check Zone", function()
		local ch = lp.Character
		local root = ch and ch:FindFirstChild("HumanoidRootPart")
		Library.Notify("Zone", inLobby(root) and "Lobby" or "Map", "on")
	end)

	Tab:Toggle({ Name = "Auto Grab Gun", Flag = "mm2_autogun", Callback = function(v) S.AutoGun = v end })
	Tab:Button("Farm Stats", function()
		local mins = farmStart and math.floor((os.clock() - farmStart) / 60) or 0
		Library.Notify("Farm Stats", coinCount .. " coin / " .. mins .. " min", "on")
	end)

	local acc = 0
	Library.Connect(RunService.Heartbeat, function(dt)
		acc = acc + dt
		if acc < 0.2 then return end
		acc = 0
		if S.Roles then pcall(updateRoles) end
		if S.Gun then pcall(updateGun) end
		if S.Coin then pcall(updateCoins) end
		if S.AutoGun and not grabbing then
			local gp = findGunPart()
			if gp and gp ~= lastGun then
				lastGun = gp
				grabbing = true
				task.spawn(function()
					pcall(function() if curTween then curTween:Cancel() end end)
					pcall(grabGun)
					grabbing = false
				end)
			end
		end
	end)
	Library.Connect(Players.PlayerRemoving, removePlayer)

	table.insert(Library.OnUnload, function()
		S.Roles, S.Gun, S.Coin = false, false, false
		stopFarm()
		clearPlayers()
		clearGun()
		clearCoins()
		holder:Destroy()
	end)
end
