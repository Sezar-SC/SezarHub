-- MM2 game tab v3
return function(Window, Library)
	local Players = game:GetService("Players")
	local RunService = game:GetService("RunService")
	local TweenService = game:GetService("TweenService")
	local lp = Players.LocalPlayer

	local Tab = Window:AddTab("MM2")

	local S = {
		Roles = false, Innocent = true, Gun = false, Coin = false,
		Farm = false, Avoid = true, BagLobby = true, AutoGun = false,
		AutoShoot = false, ShootFull = false, Kill = false, KillFull = false,
	}
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
	local grabbing, killing = false, false

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

	-- coin ESP
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

	-- teleport helpers
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

	local function inLobby(root)
		local lobby = workspace:FindFirstChild("Lobby")
		if not lobby or not root then return false end
		local ok, cf, size = pcall(function() return lobby:GetBoundingBox() end)
		if not ok or not cf then return false end
		local rel = cf:PointToObjectSpace(root.Position)
		local h = size / 2 + Vector3.new(15, 60, 15)
		return math.abs(rel.X) <= h.X and math.abs(rel.Y) <= h.Y and math.abs(rel.Z) <= h.Z
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

	-- bag detection
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

	-- combat helpers
	local function aliveRoot(p)
		local c = p and p.Character
		local hum = c and c:FindFirstChildOfClass("Humanoid")
		local root = c and c:FindFirstChild("HumanoidRootPart")
		if hum and root and hum.Health > 0 then return root end
		return nil
	end

	local function murdererRoot()
		for _, p in ipairs(Players:GetPlayers()) do
			if p ~= lp and roleOf(p) == "Murderer" then
				return aliveRoot(p)
			end
		end
		return nil
	end

	local function getTool(name)
		local ch = lp.Character
		local bp = lp:FindFirstChildOfClass("Backpack")
		return (ch and ch:FindFirstChild(name)) or (bp and bp:FindFirstChild(name))
	end

	local function equip(tool)
		local ch = lp.Character
		local hum = ch and ch:FindFirstChildOfClass("Humanoid")
		if hum and tool and tool.Parent ~= ch then
			hum:EquipTool(tool)
			task.wait(0.2)
		end
	end

	local function hasLOS(fromPos, target)
		local ignore = {}
		if lp.Character then table.insert(ignore, lp.Character) end
		if target and target.Parent then table.insert(ignore, target.Parent) end
		local params = RaycastParams.new()
		params.FilterType = Enum.RaycastFilterType.Exclude
		params.FilterDescendantsInstances = ignore
		return workspace:Raycast(fromPos, target.Position - fromPos, params) == nil
	end

	local SHOOT_OFFSETS = {
		Vector3.new(0, 0, 8), Vector3.new(8, 0, 0), Vector3.new(-8, 0, 0),
		Vector3.new(0, 0, -8), Vector3.new(0, 0, 4),
	}

	local function shootOnce(silent)
		local gun = getTool("Gun")
		if not gun then
			if not silent then Library.Notify("MM2", "You are not Sheriff", "on") end
			return false
		end
		local mr = murdererRoot()
		if not mr then
			if not silent then Library.Notify("MM2", "Murderer not found", "on") end
			return false
		end
		local ch = lp.Character
		local root = ch and ch:FindFirstChild("HumanoidRootPart")
		if not root then return false end
		equip(gun)
		gun = getTool("Gun") or gun

		-- wall in the way: briefly stand at a clear spot near the murderer
		local old
		if not hasLOS(root.Position, mr) then
			for _, off in ipairs(SHOOT_OFFSETS) do
				local pos = (mr.CFrame * CFrame.new(off)).Position
				if hasLOS(pos, mr) then
					old = root.CFrame
					root.CFrame = CFrame.new(pos, mr.Position)
					task.wait(0.12)
					break
				end
			end
		end

		local tgt = mr.Position + mr.AssemblyLinearVelocity * 0.1
		local kl = gun:FindFirstChild("KnifeLocal")
		local cb = kl and kl:FindFirstChild("CreateBeam")
		local rf = cb and cb:FindFirstChild("RemoteFunction")
		local sh = gun:FindFirstChild("Shoot")
		local fired = false
		if rf then
			fired = pcall(function() rf:InvokeServer(1, tgt, "AH2") end)
		elseif sh then
			fired = pcall(function() sh:FireServer(root.CFrame, CFrame.new(tgt)) end)
		end
		if not fired and not silent then
			Library.Notify("MM2", "Shoot failed", "on")
		end

		if old and root.Parent then
			task.wait(0.1)
			root.CFrame = old
			root.AssemblyLinearVelocity = Vector3.zero
		end
		return fired
	end

	local function hit(stab, handle, tr)
		local knife = getTool("Knife")
		if not knife then return end
		pcall(function() knife:Activate() end)
		task.wait(0.05)
		local ev = knife:FindFirstChild("Events")
		local ks = ev and ev:FindFirstChild("KnifeStabbed")
		local ht = ev and ev:FindFirstChild("HandleTouched")
		if ks then pcall(function() ks:FireServer() end) end
		if ht then pcall(function() ht:FireServer(tr) end) end
		if firetouchinterest and handle then
			pcall(function()
				firetouchinterest(handle, tr, 0)
				task.wait()
				firetouchinterest(handle, tr, 1)
			end)
		end
	end

	local function killAll(silent)
		if killing then return end
		local knife = getTool("Knife")
		local ch = lp.Character
		local root = ch and ch:FindFirstChild("HumanoidRootPart")
		if not knife or not root then
			if not silent then Library.Notify("MM2", "You are not Murderer", "on") end
			return
		end
		killing = true
		pcall(function()
			equip(knife)
			knife = getTool("Knife") or knife
			local handle = knife:FindFirstChild("Handle")
			local stab = knife:FindFirstChild("Stab")
			local old, moved = root.CFrame, false
			for _, p in ipairs(Players:GetPlayers()) do
				if p ~= lp then
					local tr = aliveRoot(p)
					if tr and not inLobby(tr) then
						-- first try from a distance
						hit(stab, handle, tr)
						task.wait(0.15)
						local tr2 = aliveRoot(p)
						if tr2 and not inLobby(tr2) then
							-- still alive: short close-range attempt
							moved = true
							root.CFrame = tr2.CFrame * CFrame.new(0, 0, 3)
							task.wait(0.05)
							hit(stab, handle, tr2)
							task.wait(0.15)
						end
					end
				end
			end
			if moved and root.Parent then
				root.CFrame = old
				root.AssemblyLinearVelocity = Vector3.zero
			end
		end)
		killing = false
	end

	local function anyTarget()
		for _, p in ipairs(Players:GetPlayers()) do
			if p ~= lp then
				local r = aliveRoot(p)
				if r and not inLobby(r) then return true end
			end
		end
		return false
	end

	local function combatPending()
		if S.AutoShoot and S.ShootFull and getTool("Gun") and murdererRoot() then return true end
		if S.Kill and S.KillFull and getTool("Knife") and anyTarget() then return true end
		return false
	end

	local function dumpTools()
		local n = 0
		for _, name in ipairs({ "Gun", "Knife" }) do
			local t = getTool(name)
			if t then
				for _, d in ipairs(t:GetDescendants()) do
					if d:IsA("RemoteEvent") or d:IsA("RemoteFunction") or d:IsA("BindableEvent") then
						warn("[SezarMM2] " .. name .. ": " .. d:GetFullName() .. " (" .. d.ClassName .. ")")
						n = n + 1
					end
				end
			end
		end
		Library.Notify("Debug", n .. " remotes (see F9)", "on")
	end

	-- vote
	local voteId, lastVote = 0, 0
	S.Vote, S.MultiVote, S.VotePick = false, false, "Pad 1"

	local function padVotes(model)
		local gui = model:FindFirstChild("VoteInfoGui")
		local cont = gui and gui:FindFirstChild("Container")
		local v = cont and cont:FindFirstChild("Votes")
		return v and tonumber(tostring(v.Text):match("%d+")) or 0
	end

	local function pickPad()
		local lobby = workspace:FindFirstChild("Lobby")
		local vp = lobby and lobby:FindFirstChild("VotePads")
		if not vp then return nil end
		if S.VotePick == "Most Votes" then
			local best, bn
			for _, m in ipairs(vp:GetChildren()) do
				local pad = m:FindFirstChild("Pad")
				if pad then
					local n = padVotes(m)
					if not bn or n > bn then best, bn = pad, n end
				end
			end
			return best
		end
		local idx = tostring(S.VotePick):match("%d")
		local m = idx and vp:FindFirstChild("VotePad" .. idx)
		return m and m:FindFirstChild("Pad")
	end

	local function doVote()
		local ch = lp.Character
		local root = ch and ch:FindFirstChild("HumanoidRootPart")
		local pad = pickPad()
		if not root or not pad or not inLobby(root) then return false end
		local home = root.CFrame
		local n = S.MultiVote and 12 or 1
		for _ = 1, n do
			if firetouchinterest then
				pcall(function()
					firetouchinterest(root, pad, 0)
					task.wait()
					firetouchinterest(root, pad, 1)
				end)
			end
			root.CFrame = pad.CFrame + Vector3.new(0, 3, 0)
			task.wait(0.15)
			root.CFrame = home
			task.wait(0.15)
		end
		root.AssemblyLinearVelocity = Vector3.zero
		return true
	end

	local function voteLoop(id)
		while S.Vote and voteId == id do
			pcall(function()
				local ch = lp.Character
				local root = ch and ch:FindFirstChild("HumanoidRootPart")
				if not root then return end
				if inLobby(root) then
					if os.clock() - lastVote > 20 and pickPad() then
						lastVote = os.clock()
						doVote()
					end
				else
					lastVote = 0
				end
			end)
			task.wait(1)
		end
	end

	local SPEEDS = { Slow = 20, Normal = 28 }
	local farmSpeed, farmMode = SPEEDS.Normal, "Normal"
	local farmId, curTween = 0, nil
	local coinCount, farmStart = 0, nil
	local lastGun = nil
	local visited = setmetatable({}, { __mode = "k" })
	local lastCont = nil

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
		if best then goTo(root, best.CFrame, false, id) end
	end

	local function farmLoop(id)
		local wasLobby, full = true, false
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

				if grabbing or killing then
					task.wait(0.2)
					return
				end

				if inLobby(root) then
					wasLobby, full = true, false
					task.wait(1)
					return
				end

				if wasLobby then
					wasLobby, full = false, false
					visited = setmetatable({}, { __mode = "k" })
					task.wait(1.5)
					return
				end

				if not full and bagFull() then full = true end
				if full then
					local t0 = os.clock()
					while S.Farm and farmId == id and os.clock() - t0 < 12 and combatPending() do
						task.wait(0.5)
					end
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

				if farmMode == "Touch" and firetouchinterest then
					pcall(function()
						firetouchinterest(root, coin, 0)
						task.wait()
						firetouchinterest(root, coin, 1)
					end)
					visited[coin] = true
					coinCount = coinCount + 1
					task.wait(0.12)
					return
				end

				if goTo(root, coin.CFrame, S.Avoid, id) then
					visited[coin] = true
					coinCount = coinCount + 1
					task.wait(0.15)
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

	local shootId, killId = 0, 0

	local function shootLoop(id)
		while S.AutoShoot and shootId == id do
			pcall(function()
				if grabbing then return end
				if S.ShootFull and not bagFull() then return end
				shootOnce(true)
			end)
			task.wait(1.2)
		end
	end

	local function killLoop(id)
		while S.Kill and killId == id do
			pcall(function()
				if grabbing then return end
				if S.KillFull and not bagFull() then return end
				killAll(true)
			end)
			task.wait(1)
		end
	end

	-- UI: ESP
	Tab:Section("ESP")
	Tab:Toggle({ Name = "Role ESP", Flag = "mm2_roles", Callback = function(v)
		S.Roles = v
		Library.RoleESP = v
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

	-- UI: Auto Farm
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
	Tab:Dropdown({
		Name = "Farm Speed", Flag = "mm2_speed", Default = "Normal",
		Options = { "Slow", "Normal", "Touch" },
		Callback = function(v)
			farmMode = v
			if SPEEDS[v] then farmSpeed = SPEEDS[v] end
			if v == "Touch" and not firetouchinterest then
				Library.Notify("MM2", "Touch mode not supported", "on")
			end
		end,
	})
	Tab:Toggle({ Name = "Avoid Murderer", Default = true, Flag = "mm2_avoid", NoKey = true, Callback = function(v) S.Avoid = v end })
	Tab:Toggle({ Name = "Lobby on Full Bag", Default = true, Flag = "mm2_baglobby", NoKey = true, Callback = function(v) S.BagLobby = v end })
	Tab:Toggle({ Name = "Auto Grab Gun", Flag = "mm2_autogun", Callback = function(v) S.AutoGun = v end })

	-- UI: Combat
	Tab:Section("Combat")
	Tab:Toggle({ Name = "Auto Shoot Murderer", Flag = "mm2_autoshoot", Callback = function(v)
		S.AutoShoot = v
		shootId = shootId + 1
		if v then task.spawn(shootLoop, shootId) end
	end })
	Tab:Toggle({ Name = "Shoot After Full Bag", Flag = "mm2_shootfull", NoKey = true, Callback = function(v) S.ShootFull = v end })
	Tab:Button("Shoot Murderer", function()
		task.spawn(function() pcall(shootOnce, false) end)
	end)
	Tab:Toggle({ Name = "Kill All", Flag = "mm2_killall", Callback = function(v)
		S.Kill = v
		killId = killId + 1
		if v then task.spawn(killLoop, killId) end
	end })
	Tab:Toggle({ Name = "Kill After Full Bag", Flag = "mm2_killfull", NoKey = true, Callback = function(v) S.KillFull = v end })

	-- UI: Vote
	Tab:Section("Vote")
	Tab:Toggle({ Name = "Auto Vote Map", Flag = "mm2_vote", Callback = function(v)
		S.Vote = v
		voteId = voteId + 1
		if v then
			lastVote = 0
			task.spawn(voteLoop, voteId)
		end
	end })
	Tab:Dropdown({
		Name = "Vote Pad", Flag = "mm2_votepad", Default = "Pad 1",
		Options = { "Pad 1", "Pad 2", "Pad 3", "Most Votes" },
		Callback = function(v) S.VotePick = v end,
	})
	Tab:Toggle({ Name = "Multi Vote (test)", Flag = "mm2_multivote", NoKey = true, Callback = function(v) S.MultiVote = v end })
	Tab:Button("Vote Now", function()
		task.spawn(function()
			local ok, res = pcall(doVote)
			if not ok or not res then Library.Notify("MM2", "Vote failed", "on") end
		end)
	end)

	-- UI: Teleport
	Tab:Section("Teleport")
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

	-- UI: Actions
	Tab:Section("Actions")
	Tab:Button("Grab Gun", function()
		task.spawn(function()
			local ok = pcall(grabGun)
			if not ok then Library.Notify("MM2", "Grab failed", "on") end
		end)
	end)
	Tab:Button("Farm Stats", function()
		local mins = farmStart and math.floor((os.clock() - farmStart) / 60) or 0
		Library.Notify("Farm Stats", coinCount .. " coin / " .. mins .. " min", "on")
	end)
	Tab:Button("Dump Tool Info", function()
		pcall(dumpTools)
	end)

	-- main loop
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
		S.AutoShoot, S.Kill = false, false
		S.Vote = false
		voteId = voteId + 1
		Library.RoleESP = false
		shootId = shootId + 1
		killId = killId + 1
		stopFarm()
		clearPlayers()
		clearGun()
		clearCoins()
		holder:Destroy()
	end)
end
