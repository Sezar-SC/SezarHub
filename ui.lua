-- SezarHub UI library v2
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UIS = game:GetService("UserInputService")
local Debris = game:GetService("Debris")
local HttpService = game:GetService("HttpService")

local Library = {
	_conns = {}, OnUnload = {}, ToggleKey = Enum.KeyCode.RightShift,
	Flags = {}, Setters = {}, Binding = false, AutoSave = false, Loading = false,
}

local Theme = {
	Bg = Color3.fromRGB(10, 8, 16),
	Panel = Color3.fromRGB(18, 14, 28),
	Item = Color3.fromRGB(26, 20, 40),
	ItemHover = Color3.fromRGB(34, 26, 52),
	Purple = Color3.fromRGB(150, 70, 255),
	PurpleDark = Color3.fromRGB(100, 45, 180),
	Text = Color3.fromRGB(238, 232, 248),
	Sub = Color3.fromRGB(150, 140, 172),
	Off = Color3.fromRGB(230, 70, 90),
	SwitchOff = Color3.fromRGB(50, 42, 70),
}

local function create(class, props, parent)
	local o = Instance.new(class)
	for k, v in pairs(props) do o[k] = v end
	if parent then o.Parent = parent end
	return o
end

local function tween(o, t, props, style, dir)
	local tw = TweenService:Create(o, TweenInfo.new(t, style or Enum.EasingStyle.Quint, dir or Enum.EasingDirection.Out), props)
	tw:Play()
	return tw
end

local function corner(o, r) return create("UICorner", { CornerRadius = UDim.new(0, r) }, o) end
local function stroke(o, color, th)
	return create("UIStroke", { Color = color, Thickness = th or 1, ApplyStrokeMode = Enum.ApplyStrokeMode.Border }, o)
end

function Library.Connect(signal, fn)
	local c = signal:Connect(fn)
	table.insert(Library._conns, c)
	return c
end

local function getParent()
	local ok, ui = pcall(function() return gethui and gethui() end)
	if ok and ui then return ui end
	ok, ui = pcall(function() return game:GetService("CoreGui") end)
	if ok and ui then return ui end
	return Players.LocalPlayer:WaitForChild("PlayerGui")
end

local parent = getParent()
Library.GuiParent = parent
local old = parent:FindFirstChild("SezarHub")
if old then old:Destroy() end

local Gui = create("ScreenGui", {
	Name = "SezarHub", ResetOnSpawn = false, IgnoreGuiInset = true,
	ZIndexBehavior = Enum.ZIndexBehavior.Sibling, DisplayOrder = 999,
})
pcall(function() if syn and syn.protect_gui then syn.protect_gui(Gui) end end)
Gui.Parent = parent

-- ========== CONFIG (save / load) ==========
local CFG_FOLDER = "SezarHub"
local CFG_FILE = CFG_FOLDER .. "/" .. tostring(game.PlaceId) .. ".json"
Library.CanSave = (type(writefile) == "function" and type(readfile) == "function"
	and type(isfile) == "function" and type(makefolder) == "function" and type(isfolder) == "function")

function Library.Save()
	if not Library.CanSave then return false end
	local ok = pcall(function()
		if not isfolder(CFG_FOLDER) then makefolder(CFG_FOLDER) end
		writefile(CFG_FILE, HttpService:JSONEncode(Library.Flags))
	end)
	return ok
end

local saveQueued = false
local function queueSave()
	if saveQueued or not Library.AutoSave or Library.Loading then return end
	saveQueued = true
	task.delay(1, function()
		saveQueued = false
		Library.Save()
	end)
end

function Library.Load()
	if not Library.CanSave then return false end
	local ok, data = pcall(function()
		if not isfile(CFG_FILE) then return nil end
		return HttpService:JSONDecode(readfile(CFG_FILE))
	end)
	if not ok or type(data) ~= "table" then return false end
	Library.Loading = true
	for flag, value in pairs(data) do
		local setter = Library.Setters[flag]
		if setter then pcall(setter, value) end
	end
	Library.Loading = false
	return true
end

-- ========== NOTIFICATIONS (top right) ==========
local NotifHolder = create("Frame", {
	BackgroundTransparency = 1, AnchorPoint = Vector2.new(1, 0),
	Position = UDim2.new(1, -16, 0, 16), Size = UDim2.new(0, 290, 1, -32), ZIndex = 100,
}, Gui)
create("UIListLayout", {
	Padding = UDim.new(0, 8), SortOrder = Enum.SortOrder.LayoutOrder,
	HorizontalAlignment = Enum.HorizontalAlignment.Right,
}, NotifHolder)

local notifOrder = 0
function Library.Notify(title, sub, kind, dur)
	dur = dur or 3
	local col = (kind == "off") and Theme.Off or Theme.Purple
	notifOrder = notifOrder + 1
	local holder = create("Frame", {
		BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 54), LayoutOrder = notifOrder,
	}, NotifHolder)
	local card = create("Frame", {
		BackgroundColor3 = Theme.Panel, Position = UDim2.new(1.4, 0, 0, 0),
		Size = UDim2.new(1, 0, 1, 0), BorderSizePixel = 0, ClipsDescendants = true,
	}, holder)
	corner(card, 8)
	stroke(card, col, 1)
	create("Frame", { BackgroundColor3 = col, Size = UDim2.new(0, 4, 1, 0), BorderSizePixel = 0 }, card)
	create("TextLabel", {
		BackgroundTransparency = 1, Position = UDim2.new(0, 16, 0, 8), Size = UDim2.new(1, -24, 0, 18),
		Font = Enum.Font.GothamBold, TextSize = 15, TextColor3 = Theme.Text,
		TextXAlignment = Enum.TextXAlignment.Left, Text = tostring(title),
	}, card)
	create("TextLabel", {
		BackgroundTransparency = 1, Position = UDim2.new(0, 16, 0, 27), Size = UDim2.new(1, -24, 0, 16),
		Font = Enum.Font.Gotham, TextSize = 12, TextColor3 = Theme.Sub,
		TextXAlignment = Enum.TextXAlignment.Left, Text = tostring(sub or "SezarHub"),
	}, card)
	local bar = create("Frame", {
		BackgroundColor3 = col, AnchorPoint = Vector2.new(0, 1), Position = UDim2.new(0, 0, 1, 0),
		Size = UDim2.new(1, 0, 0, 3), BorderSizePixel = 0,
	}, card)

	tween(card, 0.45, { Position = UDim2.new(0, 0, 0, 0) }, Enum.EasingStyle.Back)
	tween(bar, dur, { Size = UDim2.new(0, 0, 0, 3) }, Enum.EasingStyle.Linear)
	task.delay(dur, function()
		tween(card, 0.3, { Position = UDim2.new(1.4, 0, 0, 0) }, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
		task.wait(0.35)
		holder:Destroy()
	end)
end

-- ========== EFFECTS ==========
local function burst(center, W, H)
	local ring = create("Frame", {
		AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromOffset(center.X, center.Y),
		Size = UDim2.fromOffset(120, 120), BackgroundTransparency = 1, ZIndex = 40,
	}, Gui)
	corner(ring, 600)
	local rs = stroke(ring, Theme.Purple, 4)
	tween(ring, 0.8, { Size = UDim2.fromOffset(1000, 1000) })
	tween(rs, 0.8, { Transparency = 1 })
	Debris:AddItem(ring, 1)

	local hw, hh = math.floor(W / 2), math.floor(H / 2)
	for i = 1, 44 do
		local side = math.random(1, 4)
		local px, py
		if side == 1 then px = math.random(-hw, hw); py = -hh
		elseif side == 2 then px = math.random(-hw, hw); py = hh
		elseif side == 3 then px = -hw; py = math.random(-hh, hh)
		else px = hw; py = math.random(-hh, hh) end
		local dir = Vector2.new(px, py)
		dir = (dir.Magnitude > 0) and dir.Unit or Vector2.new(0, -1)
		local dist = math.random(70, 200)
		local s = math.random(4, 10)
		local p = create("Frame", {
			AnchorPoint = Vector2.new(0.5, 0.5), BorderSizePixel = 0, ZIndex = 45,
			BackgroundColor3 = (i % 3 == 0) and Color3.new(1, 1, 1) or Theme.Purple,
			Size = UDim2.fromOffset(s, s), Rotation = math.random(0, 90),
			Position = UDim2.fromOffset(center.X + px, center.Y + py),
		}, Gui)
		corner(p, 2)
		tween(p, math.random(60, 110) / 100, {
			Position = UDim2.fromOffset(center.X + px + dir.X * dist, center.Y + py + dir.Y * dist),
			BackgroundTransparency = 1, Rotation = p.Rotation + math.random(-200, 200),
		}, Enum.EasingStyle.Quad)
		Debris:AddItem(p, 1.3)
	end
end

local function popIn(page, startScale)
	local i = 0
	for _, c in ipairs(page:GetChildren()) do
		local s = c:FindFirstChild("S")
		if s then
			i = i + 1
			s.Scale = startScale or 0.7
			task.delay(i * 0.045, function()
				tween(s, 0.4, { Scale = 1 }, Enum.EasingStyle.Back)
			end)
		end
	end
end

-- ========== WINDOW ==========
function Library.CreateWindow()
	local W, H = 660, 430
	local Window = {}
	local tabs, current = {}, nil
	local isOpen = false

	local Main = create("Frame", {
		Name = "Main", AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.new(0.5, 0, 0.5, 0),
		Size = UDim2.fromOffset(W, H), BackgroundColor3 = Theme.Bg, BorderSizePixel = 0, Visible = false,
	}, Gui)
	corner(Main, 12)
	local MainStroke = stroke(Main, Theme.Purple, 2)
	local Scale = create("UIScale", { Scale = 0 }, Main)

	local Header = create("Frame", {
		BackgroundColor3 = Theme.Panel, Size = UDim2.new(1, 0, 0, 50), BorderSizePixel = 0,
	}, Main)
	corner(Header, 12)
	create("Frame", {
		BackgroundColor3 = Theme.Panel, AnchorPoint = Vector2.new(0, 1), Position = UDim2.new(0, 0, 1, 0),
		Size = UDim2.new(1, 0, 0, 12), BorderSizePixel = 0,
	}, Header)

	local plate = create("Frame", {
		BackgroundColor3 = Color3.fromRGB(240, 236, 250), Position = UDim2.fromOffset(14, 11),
		Size = UDim2.fromOffset(104, 28), BorderSizePixel = 0,
	}, Header)
	corner(plate, 7)
	create("TextLabel", {
		BackgroundTransparency = 1, Size = UDim2.new(1, 0, 1, 0), Font = Enum.Font.GothamBlack,
		TextSize = 18, RichText = true,
		Text = '<font color="#000000">Sezar</font><font color="#9646FF">Hub</font>',
	}, plate)
	create("TextLabel", {
		BackgroundTransparency = 1, Position = UDim2.fromOffset(128, 0), Size = UDim2.new(0, 120, 1, 0),
		Font = Enum.Font.Gotham, TextSize = 12, TextColor3 = Theme.Sub,
		TextXAlignment = Enum.TextXAlignment.Left, Text = "v2.0",
	}, Header)

	local Close = create("TextButton", {
		AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, -12, 0.5, 0), Size = UDim2.fromOffset(30, 30),
		BackgroundColor3 = Theme.Item, Text = "X", Font = Enum.Font.GothamBold, TextSize = 14,
		TextColor3 = Theme.Text, AutoButtonColor = false,
	}, Header)
	corner(Close, 8)
	Close.MouseEnter:Connect(function() tween(Close, 0.15, { BackgroundColor3 = Theme.Off }) end)
	Close.MouseLeave:Connect(function() tween(Close, 0.15, { BackgroundColor3 = Theme.Item }) end)

	local dragging, dragStart, startPos
	Header.InputBegan:Connect(function(i)
		if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
			dragging, dragStart, startPos = true, i.Position, Main.Position
			i.Changed:Connect(function()
				if i.UserInputState == Enum.UserInputState.End then dragging = false end
			end)
		end
	end)
	Library.Connect(UIS.InputChanged, function(i)
		if dragging and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then
			local d = i.Position - dragStart
			Main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + d.X, startPos.Y.Scale, startPos.Y.Offset + d.Y)
		end
	end)

	local TabBar = create("Frame", {
		BackgroundTransparency = 1, Position = UDim2.fromOffset(0, 50), Size = UDim2.new(1, 0, 0, 40),
	}, Main)
	create("UIListLayout", {
		FillDirection = Enum.FillDirection.Horizontal, HorizontalAlignment = Enum.HorizontalAlignment.Center,
		SortOrder = Enum.SortOrder.LayoutOrder,
	}, TabBar)
	create("Frame", {
		BackgroundColor3 = Theme.PurpleDark, Position = UDim2.fromOffset(14, 90),
		Size = UDim2.new(1, -28, 0, 1), BorderSizePixel = 0,
	}, Main)

	local Content = create("Frame", {
		BackgroundTransparency = 1, Position = UDim2.fromOffset(0, 92), Size = UDim2.new(1, 0, 1, -92),
		ClipsDescendants = true,
	}, Main)

	local function selectTab(t)
		for _, o in ipairs(tabs) do
			o.Page.Visible = false
			tween(o.Btn, 0.2, { TextColor3 = Theme.Sub })
			tween(o.Line, 0.25, { Size = UDim2.new(0, 0, 0, 3) })
		end
		current = t
		t.Page.Visible = true
		tween(t.Btn, 0.2, { TextColor3 = Theme.Text })
		tween(t.Line, 0.35, { Size = UDim2.new(0.7, 0, 0, 3) }, Enum.EasingStyle.Back)
		popIn(t.Page, 0.8)
	end

	-- ===== Tab =====
	local Tab = {}
	Tab.__index = Tab

	local function item(self, h, transparent)
		self.Order = self.Order + 1
		local f = create("Frame", {
			BackgroundColor3 = Theme.Item, BackgroundTransparency = transparent and 1 or 0,
			Size = UDim2.new(1, 0, 0, h), BorderSizePixel = 0, LayoutOrder = self.Order,
		}, self.Page)
		if not transparent then corner(f, 8) end
		create("UIScale", { Name = "S" }, f)
		return f
	end

	local function safe(cb, ...)
		if not cb then return end
		local args = { ... }
		task.spawn(function()
			local ok, err = pcall(function() cb(unpack(args)) end)
			if not ok then Library.Notify("Error", tostring(err), "off", 5) end
		end)
	end

	function Tab:Section(text)
		local f = item(self, 24, true)
		create("TextLabel", {
			BackgroundTransparency = 1, Size = UDim2.new(1, 0, 1, 0), Font = Enum.Font.GothamBold,
			TextSize = 12, TextColor3 = Theme.Purple, TextXAlignment = Enum.TextXAlignment.Left,
			Text = string.upper(text),
		}, f)
	end

	function Tab:Label(text)
		local f = item(self, 30, true)
		local l = create("TextLabel", {
			BackgroundTransparency = 1, Size = UDim2.new(1, 0, 1, 0), Font = Enum.Font.Gotham,
			TextSize = 13, TextColor3 = Theme.Sub, TextXAlignment = Enum.TextXAlignment.Left,
			TextWrapped = true, Text = text,
		}, f)
		return { Set = function(t) l.Text = t end }
	end

	-- Toggle: {Name, Default, Flag, Key (Enum.KeyCode), NoKey, Callback}
	function Tab:Toggle(o)
		local f = item(self, 42)
		create("TextLabel", {
			BackgroundTransparency = 1, Position = UDim2.fromOffset(14, 0), Size = UDim2.new(1, -150, 1, 0),
			Font = Enum.Font.GothamMedium, TextSize = 14, TextColor3 = Theme.Text,
			TextXAlignment = Enum.TextXAlignment.Left, Text = o.Name,
		}, f)
		local sw = create("Frame", {
			AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, -14, 0.5, 0),
			Size = UDim2.fromOffset(46, 24), BackgroundColor3 = Theme.SwitchOff, BorderSizePixel = 0,
		}, f)
		corner(sw, 12)
		local knob = create("Frame", {
			Position = UDim2.fromOffset(3, 3), Size = UDim2.fromOffset(18, 18),
			BackgroundColor3 = Color3.new(1, 1, 1), BorderSizePixel = 0,
		}, sw)
		corner(knob, 9)
		local btn = create("TextButton", { Text = "", BackgroundTransparency = 1, Size = UDim2.new(1, 0, 1, 0) }, f)

		local state = false
		local keyName = o.Key and o.Key.Name or nil
		local keyBtn

		local function visual(v)
			tween(sw, 0.25, { BackgroundColor3 = v and Theme.Purple or Theme.SwitchOff })
			tween(knob, 0.3, { Position = v and UDim2.fromOffset(25, 3) or UDim2.fromOffset(3, 3) }, Enum.EasingStyle.Back)
		end

		local function set(v, silent)
			state = v and true or false
			if o.Flag then Library.Flags[o.Flag] = state; queueSave() end
			visual(state)
			if not silent then
				Library.Notify(o.Name .. (state and " enabled" or " disabled"), state and "Feature active" or "Feature inactive", state and "on" or "off")
			end
			safe(o.Callback, state)
		end

		btn.MouseButton1Click:Connect(function() set(not state) end)
		btn.MouseEnter:Connect(function() tween(f, 0.15, { BackgroundColor3 = Theme.ItemHover }) end)
		btn.MouseLeave:Connect(function() tween(f, 0.15, { BackgroundColor3 = Theme.Item }) end)

		if not o.NoKey then
			keyBtn = create("TextButton", {
				AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, -72, 0.5, 0), Size = UDim2.fromOffset(62, 22),
				BackgroundColor3 = Theme.Panel, Text = keyName or "-", Font = Enum.Font.GothamBold, TextSize = 11,
				TextColor3 = Theme.Sub, AutoButtonColor = false, TextTruncate = Enum.TextTruncate.AtEnd,
			}, f)
			corner(keyBtn, 6)
			stroke(keyBtn, Theme.PurpleDark, 1)

			local function setKey(name)
				if name == "None" or name == nil then keyName = nil else keyName = name end
				keyBtn.Text = keyName or "-"
				keyBtn.TextColor3 = keyName and Theme.Purple or Theme.Sub
				if o.Flag then Library.Flags[o.Flag .. "_key"] = keyName or "None"; queueSave() end
			end
			setKey(keyName)

			keyBtn.MouseButton1Click:Connect(function()
				if Library.Binding then return end
				Library.Binding = true
				keyBtn.Text = "..."
				local c
				c = UIS.InputBegan:Connect(function(i)
					if i.UserInputType == Enum.UserInputType.Keyboard then
						c:Disconnect()
						if i.KeyCode == Enum.KeyCode.Escape or i.KeyCode == Enum.KeyCode.Backspace then
							setKey("None")
						else
							setKey(i.KeyCode.Name)
							Library.Notify("Keybind set", o.Name .. " = " .. i.KeyCode.Name, "on", 2)
						end
						task.delay(0.15, function() Library.Binding = false end)
					end
				end)
			end)

			Library.Connect(UIS.InputBegan, function(i, gp)
				if gp or Library.Binding or not keyName then return end
				if i.UserInputType == Enum.UserInputType.Keyboard and i.KeyCode.Name == keyName then
					set(not state)
				end
			end)

			if o.Flag then
				Library.Setters[o.Flag .. "_key"] = function(v) setKey(v) end
			end
		end

		if o.Flag then
			Library.Flags[o.Flag] = false
			Library.Setters[o.Flag] = function(v) set(v, true) end
		end
		if o.Default then set(true, true) end
		return { Set = function(v) set(v) end, Get = function() return state end }
	end

	-- Slider: {Name, Min, Max, Default, HardMax, Flag, Callback}
	function Tab:Slider(o)
		local min, max = o.Min, o.Max
		local hardMax = o.HardMax or max
		local f = item(self, 60)
		create("TextLabel", {
			BackgroundTransparency = 1, Position = UDim2.fromOffset(14, 6), Size = UDim2.new(1, -110, 0, 22),
			Font = Enum.Font.GothamMedium, TextSize = 14, TextColor3 = Theme.Text,
			TextXAlignment = Enum.TextXAlignment.Left, Text = o.Name,
		}, f)
		local box = create("TextBox", {
			AnchorPoint = Vector2.new(1, 0), Position = UDim2.new(1, -14, 0, 6), Size = UDim2.fromOffset(70, 24),
			BackgroundColor3 = Theme.Panel, Text = tostring(o.Default), TextColor3 = Theme.Text,
			Font = Enum.Font.GothamBold, TextSize = 13, ClearTextOnFocus = false,
		}, f)
		corner(box, 6)
		stroke(box, Theme.PurpleDark, 1)
		local bar = create("Frame", {
			Position = UDim2.new(0, 14, 0, 40), Size = UDim2.new(1, -28, 0, 8),
			BackgroundColor3 = Theme.Panel, BorderSizePixel = 0,
		}, f)
		corner(bar, 4)
		local fill = create("Frame", { Size = UDim2.new(0, 0, 1, 0), BackgroundColor3 = Theme.Purple, BorderSizePixel = 0 }, bar)
		corner(fill, 4)
		local knob = create("Frame", {
			AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.new(1, 0, 0.5, 0), Size = UDim2.fromOffset(16, 16),
			BackgroundColor3 = Color3.new(1, 1, 1), BorderSizePixel = 0,
		}, fill)
		corner(knob, 8)

		local value = o.Default
		local function setValue(v, animate)
			v = math.clamp(math.floor(v + 0.5), min, hardMax)
			value = v
			local a = math.clamp((v - min) / (max - min), 0, 1)
			if animate then tween(fill, 0.25, { Size = UDim2.new(a, 0, 1, 0) })
			else fill.Size = UDim2.new(a, 0, 1, 0) end
			box.Text = tostring(v)
			if o.Flag then Library.Flags[o.Flag] = v; queueSave() end
			safe(o.Callback, v)
		end
		setValue(o.Default, false)

		if o.Flag then
			Library.Setters[o.Flag] = function(v)
				if tonumber(v) then setValue(tonumber(v), false) end
			end
		end

		local sliding = false
		local function fromInput(x)
			local a = math.clamp((x - bar.AbsolutePosition.X) / bar.AbsoluteSize.X, 0, 1)
			setValue(min + a * (max - min), false)
		end
		bar.InputBegan:Connect(function(i)
			if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
				sliding = true
				fromInput(i.Position.X)
			end
		end)
		Library.Connect(UIS.InputChanged, function(i)
			if sliding and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then
				fromInput(i.Position.X)
			end
		end)
		Library.Connect(UIS.InputEnded, function(i)
			if sliding and (i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch) then
				sliding = false
				Library.Notify(o.Name .. ": " .. value, "Value updated", "on", 2)
			end
		end)
		box.FocusLost:Connect(function()
			local n = tonumber(box.Text)
			if n then
				setValue(n, true)
				Library.Notify(o.Name .. ": " .. value, "Value updated", "on", 2)
			else
				box.Text = tostring(value)
			end
		end)
		return { Set = function(v) setValue(v, true) end }
	end

	-- Dropdown: {Name, Options (table or function), Default, Flag, Callback}
	function Tab:Dropdown(o)
		local f = item(self, 42)
		f.ClipsDescendants = true
		create("TextLabel", {
			BackgroundTransparency = 1, Position = UDim2.fromOffset(14, 0), Size = UDim2.new(1, -190, 0, 42),
			Font = Enum.Font.GothamMedium, TextSize = 14, TextColor3 = Theme.Text,
			TextXAlignment = Enum.TextXAlignment.Left, Text = o.Name,
		}, f)
		local sel = create("TextButton", {
			AnchorPoint = Vector2.new(1, 0), Position = UDim2.new(1, -14, 0, 9), Size = UDim2.fromOffset(150, 24),
			BackgroundColor3 = Theme.Panel, Text = "", AutoButtonColor = false,
		}, f)
		corner(sel, 6)
		stroke(sel, Theme.PurpleDark, 1)
		local selText = create("TextLabel", {
			BackgroundTransparency = 1, Position = UDim2.fromOffset(8, 0), Size = UDim2.new(1, -28, 1, 0),
			Font = Enum.Font.GothamMedium, TextSize = 12, TextColor3 = Theme.Text,
			TextXAlignment = Enum.TextXAlignment.Left, TextTruncate = Enum.TextTruncate.AtEnd, Text = "None",
		}, sel)
		local arrow = create("TextLabel", {
			BackgroundTransparency = 1, AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, -6, 0.5, 0),
			Size = UDim2.fromOffset(16, 16), Font = Enum.Font.GothamBold, TextSize = 12,
			TextColor3 = Theme.Purple, Text = "v",
		}, sel)
		local list = create("ScrollingFrame", {
			Position = UDim2.fromOffset(14, 46), Size = UDim2.new(1, -28, 0, 0), BackgroundColor3 = Theme.Panel,
			BorderSizePixel = 0, ScrollBarThickness = 3, ScrollBarImageColor3 = Theme.Purple,
			CanvasSize = UDim2.new(0, 0, 0, 0), AutomaticCanvasSize = Enum.AutomaticSize.Y,
		}, f)
		corner(list, 6)
		create("UIListLayout", { Padding = UDim.new(0, 2), SortOrder = Enum.SortOrder.LayoutOrder }, list)
		create("UIPadding", { PaddingTop = UDim.new(0, 2), PaddingLeft = UDim.new(0, 2) }, list)

		local opened = false
		local value = o.Default
		local close

		local function setValue(v, silent)
			value = v
			selText.Text = tostring(v == nil and "None" or v)
			if o.Flag then Library.Flags[o.Flag] = v; queueSave() end
			if not silent and v ~= nil then
				Library.Notify(o.Name .. ": " .. tostring(v), "Selected", "on", 2)
			end
			if v ~= nil then safe(o.Callback, v) end
		end

		local function populate()
			for _, c in ipairs(list:GetChildren()) do
				if c:IsA("TextButton") then c:Destroy() end
			end
			local opts = o.Options
			if type(opts) == "function" then opts = opts() end
			opts = opts or {}
			for idx, name in ipairs(opts) do
				local b = create("TextButton", {
					Size = UDim2.new(1, -8, 0, 26), BackgroundColor3 = Theme.Item, Text = tostring(name),
					Font = Enum.Font.GothamMedium, TextSize = 13, AutoButtonColor = false, LayoutOrder = idx,
					TextColor3 = (name == value) and Theme.Purple or Theme.Text,
				}, list)
				corner(b, 6)
				b.MouseEnter:Connect(function() tween(b, 0.12, { BackgroundColor3 = Theme.ItemHover }) end)
				b.MouseLeave:Connect(function() tween(b, 0.12, { BackgroundColor3 = Theme.Item }) end)
				b.MouseButton1Click:Connect(function()
					setValue(name)
					close()
				end)
			end
			return #opts
		end

		local function open()
			opened = true
			local n = populate()
			local listH = math.max(1, math.min(n, 5)) * 28 + 4
			list.Size = UDim2.new(1, -28, 0, listH)
			tween(f, 0.3, { Size = UDim2.new(1, 0, 0, 54 + listH) }, Enum.EasingStyle.Back)
			tween(arrow, 0.25, { Rotation = 180 })
		end
		function close()
			opened = false
			tween(f, 0.25, { Size = UDim2.new(1, 0, 0, 42) })
			tween(arrow, 0.25, { Rotation = 0 })
		end
		sel.MouseButton1Click:Connect(function()
			if opened then close() else open() end
		end)

		if o.Flag then
			Library.Flags[o.Flag] = value
			Library.Setters[o.Flag] = function(v) setValue(v, true) end
		end
		if value ~= nil then setValue(value, true) end
		return { Set = function(v) setValue(v) end, Refresh = populate }
	end

	function Tab:Button(text, cb)
		local f = item(self, 40)
		local btn = create("TextButton", {
			Size = UDim2.new(1, 0, 1, 0), BackgroundTransparency = 1, Text = text,
			Font = Enum.Font.GothamBold, TextSize = 14, TextColor3 = Theme.Purple, AutoButtonColor = false,
		}, f)
		btn.MouseEnter:Connect(function() tween(f, 0.15, { BackgroundColor3 = Theme.PurpleDark }); tween(btn, 0.15, { TextColor3 = Color3.new(1, 1, 1) }) end)
		btn.MouseLeave:Connect(function() tween(f, 0.15, { BackgroundColor3 = Theme.Item }); tween(btn, 0.15, { TextColor3 = Theme.Purple }) end)
		btn.MouseButton1Click:Connect(function()
			local s = f.S
			s.Scale = 0.94
			tween(s, 0.35, { Scale = 1 }, Enum.EasingStyle.Back)
			safe(cb)
		end)
	end

	function Window:AddTab(name)
		local t = setmetatable({ Order = 0 }, Tab)
		t.Btn = create("TextButton", {
			Text = name, Font = Enum.Font.GothamBold, TextSize = 14, TextColor3 = Theme.Sub,
			BackgroundTransparency = 1, Size = UDim2.new(0, 110, 1, 0),
			AutoButtonColor = false, LayoutOrder = #tabs + 1,
		}, TabBar)
		create("UIScale", { Name = "S" }, t.Btn)
		t.Line = create("Frame", {
			BackgroundColor3 = Theme.Purple, AnchorPoint = Vector2.new(0.5, 1), Position = UDim2.new(0.5, 0, 1, -2),
			Size = UDim2.new(0, 0, 0, 3), BorderSizePixel = 0,
		}, t.Btn)
		corner(t.Line, 2)
		t.Page = create("ScrollingFrame", {
			BackgroundTransparency = 1, Size = UDim2.new(1, 0, 1, 0), BorderSizePixel = 0,
			ScrollBarThickness = 3, ScrollBarImageColor3 = Theme.Purple, Visible = false,
			CanvasSize = UDim2.new(0, 0, 0, 0), AutomaticCanvasSize = Enum.AutomaticSize.Y,
		}, Content)
		create("UIListLayout", { Padding = UDim.new(0, 8), SortOrder = Enum.SortOrder.LayoutOrder }, t.Page)
		create("UIPadding", {
			PaddingTop = UDim.new(0, 10), PaddingBottom = UDim.new(0, 10),
			PaddingLeft = UDim.new(0, 16), PaddingRight = UDim.new(0, 16),
		}, t.Page)
		t.Btn.MouseButton1Click:Connect(function() if current ~= t then selectTab(t) end end)
		table.insert(tabs, t)
		return t
	end

	function Window:Open()
		if isOpen then return end
		isOpen = true
		Main.Visible = true
		Scale.Scale = 0
		tween(Scale, 0.65, { Scale = 1 }, Enum.EasingStyle.Back)
		MainStroke.Color = Color3.new(1, 1, 1)
		tween(MainStroke, 0.8, { Color = Theme.Purple })
		local c = Vector2.new(
			Gui.AbsoluteSize.X * Main.Position.X.Scale + Main.Position.X.Offset,
			Gui.AbsoluteSize.Y * Main.Position.Y.Scale + Main.Position.Y.Offset
		)
		task.spawn(function() pcall(burst, c, W, H) end)
		for i, t in ipairs(tabs) do
			local s = t.Btn.S
			s.Scale = 0
			task.delay(0.25 + i * 0.07, function() tween(s, 0.45, { Scale = 1 }, Enum.EasingStyle.Back) end)
		end
		if current then
			task.delay(0.35, function() popIn(current.Page, 0.6) end)
		elseif tabs[1] then
			task.delay(0.3, function() selectTab(tabs[1]) end)
		end
	end

	function Window:Hide()
		if not isOpen then return end
		isOpen = false
		tween(Scale, 0.3, { Scale = 0 }, Enum.EasingStyle.Back, Enum.EasingDirection.In)
		task.delay(0.32, function() if not isOpen then Main.Visible = false end end)
	end

	function Window:Toggle()
		if isOpen then Window:Hide() else Window:Open() end
	end

	Close.MouseButton1Click:Connect(function()
		Window:Hide()
		Library.Notify("Menu hidden", "Press " .. Library.ToggleKey.Name .. " to open", "off")
	end)
	Library.Connect(UIS.InputBegan, function(i, gp)
		if not gp and not Library.Binding and i.KeyCode == Library.ToggleKey then Window:Toggle() end
	end)

	return Window
end

function Library.Unload()
	for _, f in ipairs(Library.OnUnload) do pcall(f) end
	for _, c in ipairs(Library._conns) do pcall(function() c:Disconnect() end) end
	Gui:Destroy()
end

return Library
