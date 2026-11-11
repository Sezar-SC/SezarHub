-- SezarHub UI kutuphanesi
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UIS = game:GetService("UserInputService")
local Debris = game:GetService("Debris")

local Library = { _conns = {}, OnUnload = {}, ToggleKey = Enum.KeyCode.RightShift }

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
local old = parent:FindFirstChild("SezarHub")
if old then old:Destroy() end

local Gui = create("ScreenGui", {
	Name = "SezarHub", ResetOnSpawn = false, IgnoreGuiInset = true,
	ZIndexBehavior = Enum.ZIndexBehavior.Sibling, DisplayOrder = 999,
})
pcall(function() if syn and syn.protect_gui then syn.protect_gui(Gui) end end)
Gui.Parent = parent

-- ========== BILDIRIMLER (sag ust) ==========
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

-- ========== EFEKTLER ==========
local function burst(center, W, H)
	-- merkezden yayilan halka
	local ring = create("Frame", {
		AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromOffset(center.X, center.Y),
		Size = UDim2.fromOffset(120, 120), BackgroundTransparency = 1, ZIndex = 40,
	}, Gui)
	corner(ring, 600)
	local rs = stroke(ring, Theme.Purple, 4)
	tween(ring, 0.8, { Size = UDim2.fromOffset(1000, 1000) })
	tween(rs, 0.8, { Transparency = 1 })
	Debris:AddItem(ring, 1)

	-- kenarlardan firlayan parcaciklar
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

-- ========== PENCERE ==========
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

	-- baslik
	local Header = create("Frame", {
		BackgroundColor3 = Theme.Panel, Size = UDim2.new(1, 0, 0, 50), BorderSizePixel = 0,
	}, Main)
	corner(Header, 12)
	create("Frame", { -- alt koseleri duzlestir
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
		TextXAlignment = Enum.TextXAlignment.Left, Text = "v1.0  |  RightShift: gizle/goster",
	}, Header)

	local Close = create("TextButton", {
		AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, -12, 0.5, 0), Size = UDim2.fromOffset(30, 30),
		BackgroundColor3 = Theme.Item, Text = "X", Font = Enum.Font.GothamBold, TextSize = 14,
		TextColor3 = Theme.Text, AutoButtonColor = false,
	}, Header)
	corner(Close, 8)
	Close.MouseEnter:Connect(function() tween(Close, 0.15, { BackgroundColor3 = Theme.Off }) end)
	Close.MouseLeave:Connect(function() tween(Close, 0.15, { BackgroundColor3 = Theme.Item }) end)

	-- surukleme
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

	-- sekme cubugu
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

	-- ===== Sekme =====
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
			if not ok then Library.Notify("Hata", tostring(err), "off", 5) end
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
		create("TextLabel", {
			BackgroundTransparency = 1, Size = UDim2.new(1, 0, 1, 0), Font = Enum.Font.Gotham,
			TextSize = 13, TextColor3 = Theme.Sub, TextXAlignment = Enum.TextXAlignment.Left,
			TextWrapped = true, Text = text,
		}, f)
	end

	function Tab:Toggle(text, default, cb)
		local f = item(self, 42)
		create("TextLabel", {
			BackgroundTransparency = 1, Position = UDim2.fromOffset(14, 0), Size = UDim2.new(1, -80, 1, 0),
			Font = Enum.Font.GothamMedium, TextSize = 14, TextColor3 = Theme.Text,
			TextXAlignment = Enum.TextXAlignment.Left, Text = text,
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
		local function visual(v)
			tween(sw, 0.25, { BackgroundColor3 = v and Theme.Purple or Theme.SwitchOff })
			tween(knob, 0.3, { Position = v and UDim2.fromOffset(25, 3) or UDim2.fromOffset(3, 3) }, Enum.EasingStyle.Back)
		end
		local function set(v)
			state = v
			visual(v)
			Library.Notify(text .. (v and " acildi" or " kapatildi"), v and "Ozellik aktif" or "Ozellik pasif", v and "on" or "off")
			safe(cb, v)
		end
		btn.MouseButton1Click:Connect(function() set(not state) end)
		btn.MouseEnter:Connect(function() tween(f, 0.15, { BackgroundColor3 = Theme.ItemHover }) end)
		btn.MouseLeave:Connect(function() tween(f, 0.15, { BackgroundColor3 = Theme.Item }) end)
		if default then state = true; visual(true); safe(cb, true) end
		return { Set = set }
	end

	function Tab:Slider(text, min, max, default, cb, hardMax)
		hardMax = hardMax or max
		local f = item(self, 60)
		create("TextLabel", {
			BackgroundTransparency = 1, Position = UDim2.fromOffset(14, 6), Size = UDim2.new(1, -110, 0, 22),
			Font = Enum.Font.GothamMedium, TextSize = 14, TextColor3 = Theme.Text,
			TextXAlignment = Enum.TextXAlignment.Left, Text = text,
		}, f)
		local box = create("TextBox", {
			AnchorPoint = Vector2.new(1, 0), Position = UDim2.new(1, -14, 0, 6), Size = UDim2.fromOffset(70, 24),
			BackgroundColor3 = Theme.Panel, Text = tostring(default), TextColor3 = Theme.Text,
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

		local value = default
		local function setValue(v, animate)
			v = math.clamp(math.floor(v + 0.5), min, hardMax)
			value = v
			local a = math.clamp((v - min) / (max - min), 0, 1)
			if animate then tween(fill, 0.25, { Size = UDim2.new(a, 0, 1, 0) })
			else fill.Size = UDim2.new(a, 0, 1, 0) end
			box.Text = tostring(v)
			safe(cb, v)
		end
		setValue(default, false)

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
				Library.Notify(text .. ": " .. value, "Deger ayarlandi", "on", 2)
			end
		end)
		box.FocusLost:Connect(function()
			local n = tonumber(box.Text)
			if n then
				setValue(n, true)
				Library.Notify(text .. ": " .. value, "Deger ayarlandi", "on", 2)
			else
				box.Text = tostring(value)
			end
		end)
		return { Set = function(v) setValue(v, true) end }
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
		Library.Notify("Menu gizlendi", "Acmak icin RightShift", "off")
	end)
	Library.Connect(UIS.InputBegan, function(i, gp)
		if not gp and i.KeyCode == Library.ToggleKey then Window:Toggle() end
	end)

	return Window
end

function Library.Unload()
	for _, f in ipairs(Library.OnUnload) do pcall(f) end
	for _, c in ipairs(Library._conns) do pcall(function() c:Disconnect() end) end
	Gui:Destroy()
end

return Library
