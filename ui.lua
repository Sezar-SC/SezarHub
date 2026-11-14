-- SezarHub UI library v2.5
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UIS = game:GetService("UserInputService")
local Debris = game:GetService("Debris")
local HttpService = game:GetService("HttpService")

local Library = {
	_conns = {}, _tr = {}, _acc = {}, _grads = {}, OnUnload = {}, ToggleKey = Enum.KeyCode.RightShift,
	Flags = {}, GFlags = {}, Setters = {}, Binding = false, AutoSave = false, Loading = false,
	Lang = "English", Dict = {}, Version = "2.2", GameName = "UNIVERSAL",
	IsPro = false, Animated = false, HubHex = "9646FF", DeviceClass = "Desktop",
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
Library.Theme = Theme
Library.GradientSeq = ColorSequence.new(Theme.PurpleDark, Theme.Purple)

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

-- accent-colored tweens are applied directly while the theme is animated
local function tweenc(o, t, props, style, dir)
	if Library.Animated then
		for k, v in pairs(props) do o[k] = v end
		return
	end
	return tween(o, t, props, style, dir)
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

function Library.RainbowSeq(h)
	local kps = {}
	for i = 0, 6 do
		kps[i + 1] = ColorSequenceKeypoint.new(i / 6, Color3.fromHSV((h + i / 6) % 1, 0.8, 1))
	end
	return ColorSequence.new(kps)
end

-- ========== LANGUAGE ==========
function Library.T(s)
	s = tostring(s)
	if Library.Lang == "English" then return s end
	local d = Library.Dict[Library.Lang]
	return (d and d[s]) or s
end

local FALLBACK = {
	[Enum.Font.GothamBold] = Enum.Font.SourceSansBold,
	[Enum.Font.GothamBlack] = Enum.Font.SourceSansBold,
	[Enum.Font.GothamMedium] = Enum.Font.SourceSansSemibold,
	[Enum.Font.Gotham] = Enum.Font.SourceSans,
}
local function fontFor(f)
	if Library.Lang == "English" then return f end
	return FALLBACK[f] or f
end
local function sizeFor(s)
	if Library.Lang == "English" then return s end
	return math.floor(s * 1.12 + 0.5)
end

local function refresh(r)
	local txt = Library.T(r.key)
	if r.value ~= nil then txt = txt .. ": " .. tostring(r.value) end
	if r.upper and Library.Lang == "English" then txt = string.upper(txt) end
	r.obj.Text = txt
	r.obj.Font = fontFor(r.font)
	r.obj.TextSize = sizeFor(r.size)
end

local function reg(obj, key, opts)
	local r = { obj = obj, key = key, font = obj.Font, size = obj.TextSize }
	if opts then r.upper = opts.upper; r.value = opts.value end
	table.insert(Library._tr, r)
	refresh(r)
	return r
end

function Library.SetLanguage(l)
	if l == Library.Lang then return end
	Library.Lang = l
	for i = #Library._tr, 1, -1 do
		local r = Library._tr[i]
		if r.obj.Parent then refresh(r) else table.remove(Library._tr, i) end
	end
end

-- ========== GUI ROOT ==========
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
Library.Gui = Gui

-- ========== ACCENT REGISTRY (live theme / rainbow) ==========
local function P() return Theme.Purple end
local function PD() return Theme.PurpleDark end

local function acc(obj, prop, fn)
	table.insert(Library._acc, { o = obj, p = prop, f = fn })
	return obj
end

local function grad(target, rotation)
	local g = create("UIGradient", { Color = Library.GradientSeq, Rotation = rotation or 0 }, target)
	table.insert(Library._grads, g)
	return g
end

local refreshCount = 0
function Library.RefreshAccent()
	refreshCount = refreshCount + 1
	local clean = (refreshCount % 100 == 0)
	local list = Library._acc
	for i = #list, 1, -1 do
		local r = list[i]
		if clean and not r.o:IsDescendantOf(Gui) then
			table.remove(list, i)
		else
			pcall(function() r.o[r.p] = r.f() end)
		end
	end
	local gl = Library._grads
	for i = #gl, 1, -1 do
		local g = gl[i]
		if clean and not g:IsDescendantOf(Gui) then
			table.remove(gl, i)
		else
			pcall(function() g.Color = Library.GradientSeq end)
		end
	end
end

-- ========== CONFIG (per game + global) ==========
local CFG_FOLDER = "SezarHub"
local CFG_FILE = CFG_FOLDER .. "/" .. tostring(game.PlaceId) .. ".json"
local GLOBAL_FILE = CFG_FOLDER .. "/global.json"
Library.CanSave = (type(writefile) == "function" and type(readfile) == "function"
	and type(isfile) == "function" and type(makefolder) == "function" and type(isfolder) == "function")

function Library.Save()
	if not Library.CanSave then return false end
	local ok = pcall(function()
		if not isfolder(CFG_FOLDER) then makefolder(CFG_FOLDER) end
		writefile(CFG_FILE, HttpService:JSONEncode(Library.Flags))
		writefile(GLOBAL_FILE, HttpService:JSONEncode(Library.GFlags))
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
	local any = false
	Library.Loading = true
	for _, path in ipairs({ GLOBAL_FILE, CFG_FILE }) do
		local ok, data = pcall(function()
			if not isfile(path) then return nil end
			return HttpService:JSONDecode(readfile(path))
		end)
		if ok and type(data) == "table" then
			any = true
			for flag, value in pairs(data) do
				local setter = Library.Setters[flag]
				if setter then pcall(setter, value) end
			end
		end
	end
	Library.Loading = false
	return any
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
		Font = fontFor(Enum.Font.GothamBold), TextSize = sizeFor(15), TextColor3 = Theme.Text,
		TextXAlignment = Enum.TextXAlignment.Left, Text = Library.T(title),
		TextTruncate = Enum.TextTruncate.AtEnd,
	}, card)
	create("TextLabel", {
		BackgroundTransparency = 1, Position = UDim2.new(0, 16, 0, 27), Size = UDim2.new(1, -24, 0, 16),
		Font = fontFor(Enum.Font.Gotham), TextSize = sizeFor(12), TextColor3 = Theme.Sub,
		TextXAlignment = Enum.TextXAlignment.Left, Text = Library.T(sub or "SezarHub"),
		TextTruncate = Enum.TextTruncate.AtEnd,
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
local function burst(center, W, H, host, count, rainbow)
	host = host or Gui
	count = count or 44
	local ring = create("Frame", {
		AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromOffset(center.X, center.Y),
		Size = UDim2.fromOffset(120, 120), BackgroundTransparency = 1, ZIndex = 40,
	}, host)
	corner(ring, 600)
	local rs = stroke(ring, rainbow and Color3.fromHSV(math.random(), 0.8, 1) or Theme.Purple, 4)
	tween(ring, 0.8, { Size = UDim2.fromOffset(1000, 1000) })
	tween(rs, 0.8, { Transparency = 1 })
	Debris:AddItem(ring, 1)

	local hw, hh = math.floor(W / 2), math.floor(H / 2)
	for i = 1, count do
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
		local pcol
		if rainbow then pcol = Color3.fromHSV(math.random(), 0.8, 1)
		else pcol = (i % 3 == 0) and Color3.new(1, 1, 1) or Theme.Purple end
		local p = create("Frame", {
			AnchorPoint = Vector2.new(0.5, 0.5), BorderSizePixel = 0, ZIndex = 45,
			BackgroundColor3 = pcol,
			Size = UDim2.fromOffset(s, s), Rotation = math.random(0, 90),
			Position = UDim2.fromOffset(center.X + px, center.Y + py),
		}, host)
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
			if i <= 10 then
				s.Scale = startScale or 0.7
				task.delay(i * 0.045, function()
					tween(s, 0.4, { Scale = 1 }, Enum.EasingStyle.Back)
				end)
			end
		end
	end
end

-- ========== WELCOME SPLASH (Free: classic, Pro: rainbow) ==========
function Library.Splash(duration, welcomeText)
	local pro = Library.IsPro == true
	duration = duration or (pro and 3.4 or 2.6)
	local lite = Library.DeviceClass == "Touch"

	local overlay = create("Frame", {
		Name = "Splash", Size = UDim2.new(1, 0, 1, 0), BackgroundColor3 = Color3.fromRGB(6, 4, 12),
		BackgroundTransparency = 1, BorderSizePixel = 0, ZIndex = 200, Active = true,
	}, Gui)

	pcall(function()
		local vx = Gui.AbsoluteSize.X
		if vx <= 0 then vx = 1280 end
		local box = create("Frame", {
			AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.new(0.5, 0, 0.5, 0),
			Size = UDim2.fromOffset(760, 230), BackgroundTransparency = 1,
		}, overlay)
		create("UIScale", { Scale = math.clamp(vx / 800, 0.45, 1) }, box)

		local welcome = create("TextLabel", {
			BackgroundTransparency = 1, Position = UDim2.fromOffset(0, pro and 136 or 0),
			Size = UDim2.new(1, 0, 0, pro and 46 or 34), Font = Enum.Font.GothamBold,
			TextSize = 24, TextColor3 = Theme.Purple, TextTransparency = 1, Text = "",
		}, box)
		local wScale, wGrad
		if pro then
			welcome.Font = Enum.Font.SourceSansBold
			welcome.TextSize = 38
			welcome.TextColor3 = Color3.new(1, 1, 1)
			welcome.Text = (type(welcomeText) == "string" and welcomeText ~= "") and welcomeText or "Ho\u{15F} geldiniz, Efendim"
			wScale = create("UIScale", { Scale = 0 }, welcome)
			wGrad = create("UIGradient", { Color = Library.RainbowSeq(0), Rotation = 0 }, welcome)
		elseif type(welcomeText) == "string" and welcomeText ~= "" then
			welcome.Text = welcomeText
		else
			reg(welcome, "WELCOME")
			table.remove(Library._tr, #Library._tr) -- splash label is temporary
		end

		local row = create("Frame", {
			BackgroundTransparency = 1, Position = UDim2.fromOffset(0, pro and 10 or 40), Size = UDim2.new(1, 0, 0, 100),
		}, box)
		create("UIListLayout", {
			FillDirection = Enum.FillDirection.Horizontal, HorizontalAlignment = Enum.HorizontalAlignment.Center,
			VerticalAlignment = Enum.VerticalAlignment.Center, SortOrder = Enum.SortOrder.LayoutOrder,
		}, row)

		local word = "SEZARHUB"
		local letters = {}
		for i = 1, #word do
			local l = create("TextLabel", {
				BackgroundTransparency = 1, Size = UDim2.fromOffset(0, 100), AutomaticSize = Enum.AutomaticSize.X,
				Font = Enum.Font.GothamBlack, TextSize = 84, Text = word:sub(i, i), LayoutOrder = i,
				TextColor3 = (i <= 5) and Color3.new(1, 1, 1) or Theme.Purple, TextTransparency = 1,
			}, row)
			local s = create("UIScale", { Scale = pro and 2.4 or 0 }, l)
			letters[i] = { l, s }
		end

		local line = create("Frame", {
			AnchorPoint = Vector2.new(0.5, 0), Position = UDim2.new(0.5, 0, 0, pro and 122 or 152),
			Size = UDim2.fromOffset(0, 3), BackgroundColor3 = pro and Color3.new(1, 1, 1) or Theme.Purple, BorderSizePixel = 0,
		}, box)
		corner(line, 2)
		local lGrad
		if pro then lGrad = create("UIGradient", { Color = Library.RainbowSeq(0), Rotation = 0 }, line) end

		local sub = create("TextLabel", {
			BackgroundTransparency = 1, Position = UDim2.fromOffset(0, pro and 190 or 168), Size = UDim2.new(1, 0, 0, 24),
			Font = fontFor(Enum.Font.GothamMedium), TextSize = sizeFor(15), TextColor3 = Theme.Sub, TextTransparency = 1,
			Text = Library.T("Developer") .. ": Sezar   |   v" .. Library.Version,
		}, box)

		-- Pro: continuous rainbow flow on letters, message and line
		if pro then
			task.spawn(function()
				while overlay.Parent do
					local h = (os.clock() * 0.35) % 1
					for i, pair in ipairs(letters) do
						pair[1].TextColor3 = Color3.fromHSV((h + (i - 1) * 0.07) % 1, 0.75, 1)
					end
					local seq = Library.RainbowSeq(h)
					wGrad.Color = seq
					lGrad.Color = seq
					task.wait(lite and 0.05 or 0.03)
				end
			end)
		end

		tween(overlay, 0.4, { BackgroundTransparency = 0.05 }, Enum.EasingStyle.Quad)
		if not pro then tween(welcome, 0.5, { TextTransparency = 0 }, Enum.EasingStyle.Quad) end

		for i, pair in ipairs(letters) do
			if pro then
				task.delay(0.2 + i * 0.07, function()
					tween(pair[2], 0.6, { Scale = 1 }, Enum.EasingStyle.Quint)
					tween(pair[1], 0.35, { TextTransparency = 0 }, Enum.EasingStyle.Quad)
				end)
			else
				task.delay(0.25 + i * 0.08, function()
					tween(pair[2], 0.5, { Scale = 1 }, Enum.EasingStyle.Back)
					tween(pair[1], 0.3, { TextTransparency = 0 }, Enum.EasingStyle.Quad)
				end)
			end
		end

		task.delay(pro and 0.5 or 0.6, function()
			local c = Vector2.new(Gui.AbsoluteSize.X / 2, Gui.AbsoluteSize.Y / 2)
			pcall(burst, c, 520, 110, overlay, lite and 12 or 44, pro)
		end)
		task.delay(pro and 0.9 or 0.95, function()
			tween(line, 0.6, { Size = UDim2.fromOffset(pro and 560 or 480, 3) }, Enum.EasingStyle.Quart)
		end)
		if pro then
			task.delay(1.2, function()
				tween(wScale, 0.6, { Scale = 1 }, Enum.EasingStyle.Back)
				tween(welcome, 0.4, { TextTransparency = 0 }, Enum.EasingStyle.Quad)
			end)
			task.delay(1.7, function() tween(sub, 0.5, { TextTransparency = 0 }, Enum.EasingStyle.Quad) end)
		else
			task.delay(1.2, function() tween(sub, 0.5, { TextTransparency = 0 }, Enum.EasingStyle.Quad) end)
		end

		task.wait(duration)

		for _, d in ipairs(overlay:GetDescendants()) do
			if d:IsA("TextLabel") then tween(d, 0.45, { TextTransparency = 1 }, Enum.EasingStyle.Quad)
			elseif d:IsA("Frame") then tween(d, 0.45, { BackgroundTransparency = 1 }, Enum.EasingStyle.Quad) end
		end
		for _, pair in ipairs(letters) do tween(pair[2], 0.45, { Scale = 1.3 }, Enum.EasingStyle.Quad) end
		tween(overlay, 0.5, { BackgroundTransparency = 1 }, Enum.EasingStyle.Quad)
		task.wait(0.55)
	end)
	overlay:Destroy()
end

-- ========== WINDOW ==========
function Library.CreateWindow()
	local function viewport()
		local v = Gui.AbsoluteSize
		if v.X <= 0 or v.Y <= 0 then
			local cam = workspace.CurrentCamera
			if cam then v = cam.ViewportSize end
		end
		if v.X <= 0 or v.Y <= 0 then v = Vector2.new(1280, 720) end
		return v
	end

	local vp = viewport()
	local compact = (UIS.TouchEnabled and not UIS.KeyboardEnabled) or vp.X < 720
	Library.DeviceClass = compact and "Touch" or "Desktop"

	local W = math.max(280, math.min(660, vp.X - 24))
	local H = math.max(260, math.min(430, vp.Y - 32))
	local function RH() return compact and 50 or 42 end

	local Window = {}
	local tabs, current = {}, nil
	local isOpen = false
	local firstOpen = true
	local MobileToggle

	local Main = create("Frame", {
		Name = "Main", AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.new(0.5, 0, 0.5, 0),
		Size = UDim2.fromOffset(W, H), BackgroundColor3 = Theme.Bg, BorderSizePixel = 0, Visible = false,
	}, Gui)
	corner(Main, 12)
	local MainStroke = stroke(Main, Theme.Purple, 2)
	if Library.IsPro then
		MainStroke.Color = Color3.new(1, 1, 1)
		grad(MainStroke, 45)
	else
		acc(MainStroke, "Color", P)
	end
	local Scale = create("UIScale", { Scale = 0 }, Main)

	local Header = create("Frame", {
		BackgroundColor3 = Theme.Panel, Size = UDim2.new(1, 0, 0, 50), BorderSizePixel = 0,
	}, Main)
	corner(Header, 12)
	create("Frame", {
		BackgroundColor3 = Theme.Panel, AnchorPoint = Vector2.new(0, 1), Position = UDim2.new(0, 0, 1, 0),
		Size = UDim2.new(1, 0, 0, 12), BorderSizePixel = 0,
	}, Header)
	if Library.IsPro then
		local strip = create("Frame", {
			BackgroundColor3 = Color3.new(1, 1, 1), AnchorPoint = Vector2.new(0, 1),
			Position = UDim2.new(0, 0, 1, 0), Size = UDim2.new(1, 0, 0, 3), BorderSizePixel = 0,
		}, Header)
		grad(strip, 0)
	end

	local plate = create("Frame", {
		BackgroundColor3 = Color3.fromRGB(240, 236, 250), Position = UDim2.fromOffset(14, 11),
		Size = UDim2.fromOffset(104, 28), BorderSizePixel = 0,
	}, Header)
	corner(plate, 7)
	if Library.IsPro then grad(plate, 0) end
	Library.LogoLabel = create("TextLabel", {
		BackgroundTransparency = 1, Size = UDim2.new(1, 0, 1, 0), Font = Enum.Font.GothamBlack,
		TextSize = 18, RichText = true,
		Text = '<font color="#000000">Sezar</font><font color="#' .. tostring(Library.HubHex) .. '">Hub</font>',
	}, plate)
	create("TextLabel", {
		BackgroundTransparency = 1, Position = UDim2.fromOffset(128, 0), Size = UDim2.new(1, -190, 1, 0),
		Font = Enum.Font.GothamMedium, TextSize = 12, TextColor3 = Theme.Sub,
		TextXAlignment = Enum.TextXAlignment.Left, TextTruncate = Enum.TextTruncate.AtEnd,
		Text = "v" .. Library.Version .. "  |  " .. Library.GameName .. (Library.IsPro and "  |  PRO" or ""),
	}, Header)

	local Close = create("TextButton", {
		AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, -12, 0.5, 0),
		Size = UDim2.fromOffset(compact and 40 or 30, compact and 40 or 30),
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

	local TabBar = create("ScrollingFrame", {
		BackgroundTransparency = 1, Position = UDim2.fromOffset(0, 50), Size = UDim2.new(1, 0, 0, 40),
		BorderSizePixel = 0, ScrollBarThickness = 0, ScrollingDirection = Enum.ScrollingDirection.X,
		CanvasSize = UDim2.new(0, 0, 0, 0), AutomaticCanvasSize = Enum.AutomaticSize.X,
	}, Main)
	local TabLayout = create("UIListLayout", {
		FillDirection = Enum.FillDirection.Horizontal,
		HorizontalAlignment = compact and Enum.HorizontalAlignment.Left or Enum.HorizontalAlignment.Center,
		SortOrder = Enum.SortOrder.LayoutOrder,
	}, TabBar)

	local divider = create("Frame", {
		BackgroundColor3 = Theme.PurpleDark, Position = UDim2.fromOffset(14, 90),
		Size = UDim2.new(1, -28, 0, 1), BorderSizePixel = 0,
	}, Main)
	if Library.IsPro then
		divider.BackgroundColor3 = Color3.new(1, 1, 1)
		divider.Size = UDim2.new(1, -28, 0, 2)
		grad(divider, 0)
	else
		acc(divider, "BackgroundColor3", PD)
	end

	local Content = create("Frame", {
		BackgroundTransparency = 1, Position = UDim2.fromOffset(0, 92), Size = UDim2.new(1, 0, 1, -92),
		ClipsDescendants = true,
	}, Main)

	function Library.RefreshTabSizes()
		local count = math.max(1, #tabs)
		local share = math.floor((W - 12) / count)
		local width = compact and math.max(64, share) or math.max(72, math.min(96, share))
		for _, tab in ipairs(tabs) do
			tab.Btn.Size = UDim2.new(0, width, 1, 0)
			tab.Btn.TextSize = compact and 12 or 14
		end
	end

	local function fitWindow()
		local v = viewport()
		compact = (UIS.TouchEnabled and not UIS.KeyboardEnabled) or v.X < 720
		W = math.max(280, math.min(660, v.X - 24))
		H = math.max(260, math.min(430, v.Y - 32))
		Main.Size = UDim2.fromOffset(W, H)
		Close.Size = UDim2.fromOffset(compact and 40 or 30, compact and 40 or 30)
		TabLayout.HorizontalAlignment = compact and Enum.HorizontalAlignment.Left or Enum.HorizontalAlignment.Center
		NotifHolder.Size = UDim2.new(0, math.max(200, math.min(290, v.X - 32)), 1, -32)
		Library.DeviceClass = compact and "Touch" or "Desktop"
		Library.RefreshTabSizes()
	end
	fitWindow()
	Library.Connect(Gui:GetPropertyChangedSignal("AbsoluteSize"), fitWindow)

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
		local l = create("TextLabel", {
			BackgroundTransparency = 1, Size = UDim2.new(1, 0, 1, 0), Font = Enum.Font.GothamBold,
			TextSize = 12, TextColor3 = Theme.Purple, TextXAlignment = Enum.TextXAlignment.Left, Text = text,
		}, f)
		acc(l, "TextColor3", P)
		reg(l, text, { upper = true })
	end

	-- Label(text)  or  Label(key, value) -> "key: value"
	function Tab:Label(text, value)
		local f = item(self, 30, true)
		f.AutomaticSize = Enum.AutomaticSize.Y
		f.Size = UDim2.new(1, 0, 0, 0)
		local l = create("TextLabel", {
			BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y,
			Font = Enum.Font.Gotham, TextSize = 13, TextColor3 = Theme.Sub,
			TextXAlignment = Enum.TextXAlignment.Left, TextWrapped = true, Text = text,
		}, f)
		local hasValue = value ~= nil
		local r = reg(l, text, { value = value })
		return { Set = function(v)
			if hasValue then r.value = v else r.key = tostring(v) end
			refresh(r)
		end }
	end

	-- Toggle: {Name, Default, Flag, Key (Enum.KeyCode), NoKey, Callback}
	function Tab:Toggle(o)
		local f = item(self, RH())
		local nameLbl = create("TextLabel", {
			BackgroundTransparency = 1, Position = UDim2.fromOffset(14, 0), Size = UDim2.new(1, -150, 1, 0),
			Font = Enum.Font.GothamMedium, TextSize = 14, TextColor3 = Theme.Text,
			TextXAlignment = Enum.TextXAlignment.Left, TextTruncate = Enum.TextTruncate.AtEnd, Text = o.Name,
		}, f)
		reg(nameLbl, o.Name)

		local state = false
		local keyName = o.Key and o.Key.Name or nil
		local keyBtn

		local sw = create("Frame", {
			AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, -14, 0.5, 0),
			Size = UDim2.fromOffset(compact and 52 or 46, compact and 28 or 24),
			BackgroundColor3 = Theme.SwitchOff, BorderSizePixel = 0,
		}, f)
		corner(sw, 14)
		acc(sw, "BackgroundColor3", function() return state and Theme.Purple or Theme.SwitchOff end)
		local ks = compact and 22 or 18
		local kOff = 3
		local kOn = (compact and 52 or 46) - ks - 3
		local knob = create("Frame", {
			AnchorPoint = Vector2.new(0, 0.5), Position = UDim2.new(0, kOff, 0.5, 0), Size = UDim2.fromOffset(ks, ks),
			BackgroundColor3 = Color3.new(1, 1, 1), BorderSizePixel = 0,
		}, sw)
		corner(knob, 12)
		local btn = create("TextButton", { Text = "", BackgroundTransparency = 1, Size = UDim2.new(1, 0, 1, 0) }, f)

		local function visual(v)
			tweenc(sw, 0.25, { BackgroundColor3 = v and Theme.Purple or Theme.SwitchOff })
			tween(knob, 0.3, { Position = UDim2.new(0, v and kOn or kOff, 0.5, 0) }, Enum.EasingStyle.Back)
		end

		local function set(v, silent)
			state = v and true or false
			if o.Flag then Library.Flags[o.Flag] = state; queueSave() end
			visual(state)
			if not silent then
				local T = Library.T
				Library.Notify(
					T(o.Name) .. " " .. T(state and "enabled" or "disabled"),
					T(state and "Feature active" or "Feature inactive"),
					state and "on" or "off"
				)
			end
			safe(o.Callback, state)
		end

		btn.MouseButton1Click:Connect(function() set(not state) end)
		btn.MouseEnter:Connect(function() tween(f, 0.15, { BackgroundColor3 = Theme.ItemHover }) end)
		btn.MouseLeave:Connect(function() tween(f, 0.15, { BackgroundColor3 = Theme.Item }) end)

		-- keybinds only make sense with a keyboard
		if not o.NoKey and UIS.KeyboardEnabled then
			keyBtn = create("TextButton", {
				AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, -72, 0.5, 0), Size = UDim2.fromOffset(62, 22),
				BackgroundColor3 = Theme.Panel, Text = keyName or "-", Font = Enum.Font.GothamBold, TextSize = 11,
				TextColor3 = Theme.Sub, AutoButtonColor = false, TextTruncate = Enum.TextTruncate.AtEnd,
			}, f)
			corner(keyBtn, 6)
			acc(stroke(keyBtn, Theme.PurpleDark, 1), "Color", PD)
			acc(keyBtn, "TextColor3", function() return keyName and Theme.Purple or Theme.Sub end)

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
							Library.Notify("Keybind set", Library.T(o.Name) .. " = " .. i.KeyCode.Name, "on", 2)
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
		local h = compact and 72 or 60
		local f = item(self, h)
		local nameLbl = create("TextLabel", {
			BackgroundTransparency = 1, Position = UDim2.fromOffset(14, 6), Size = UDim2.new(1, -110, 0, 24),
			Font = Enum.Font.GothamMedium, TextSize = 14, TextColor3 = Theme.Text,
			TextXAlignment = Enum.TextXAlignment.Left, TextTruncate = Enum.TextTruncate.AtEnd, Text = o.Name,
		}, f)
		reg(nameLbl, o.Name)
		local box = create("TextBox", {
			AnchorPoint = Vector2.new(1, 0), Position = UDim2.new(1, -14, 0, 6),
			Size = UDim2.fromOffset(70, compact and 30 or 24),
			BackgroundColor3 = Theme.Panel, Text = tostring(o.Default), TextColor3 = Theme.Text,
			Font = Enum.Font.GothamBold, TextSize = 13, ClearTextOnFocus = false,
		}, f)
		corner(box, 6)
		acc(stroke(box, Theme.PurpleDark, 1), "Color", PD)

		-- taller invisible hit area so touch dragging is easy
		local hit = create("Frame", {
			BackgroundTransparency = 1, Position = UDim2.new(0, 14, 0, h - 34), Size = UDim2.new(1, -28, 0, 30),
		}, f)
		local bar = create("Frame", {
			AnchorPoint = Vector2.new(0, 0.5), Position = UDim2.new(0, 0, 0.5, 0), Size = UDim2.new(1, 0, 0, 8),
			BackgroundColor3 = Theme.Panel, BorderSizePixel = 0,
		}, hit)
		corner(bar, 4)
		local fill = create("Frame", { Size = UDim2.new(0, 0, 1, 0), BackgroundColor3 = Theme.Purple, BorderSizePixel = 0 }, bar)
		corner(fill, 4)
		acc(fill, "BackgroundColor3", P)
		local knob = create("Frame", {
			AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.new(1, 0, 0.5, 0),
			Size = UDim2.fromOffset(compact and 22 or 16, compact and 22 or 16),
			BackgroundColor3 = Color3.new(1, 1, 1), BorderSizePixel = 0,
		}, fill)
		corner(knob, 11)

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

		local function announce()
			Library.Notify(Library.T(o.Name) .. ": " .. value, "Value updated", "on", 2)
		end

		local sliding = false
		local function fromInput(x)
			local a = math.clamp((x - bar.AbsolutePosition.X) / bar.AbsoluteSize.X, 0, 1)
			setValue(min + a * (max - min), false)
		end
		hit.InputBegan:Connect(function(i)
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
				announce()
			end
		end)
		box.FocusLost:Connect(function()
			local n = tonumber(box.Text)
			if n then
				setValue(n, true)
				announce()
			else
				box.Text = tostring(value)
			end
		end)
		return { Set = function(v) setValue(v, true) end }
	end

	-- Dropdown: {Name, Options (table or function), Default, Flag, Global, Callback}
	function Tab:Dropdown(o)
		local store = o.Global and Library.GFlags or Library.Flags
		local dh = RH()
		local selH = compact and 32 or 24
		local itemH = compact and 34 or 26
		local f = item(self, dh)
		f.ClipsDescendants = true
		local nameLbl = create("TextLabel", {
			BackgroundTransparency = 1, Position = UDim2.fromOffset(14, 0), Size = UDim2.new(1, -190, 0, dh),
			Font = Enum.Font.GothamMedium, TextSize = 14, TextColor3 = Theme.Text,
			TextXAlignment = Enum.TextXAlignment.Left, TextTruncate = Enum.TextTruncate.AtEnd, Text = o.Name,
		}, f)
		reg(nameLbl, o.Name)
		local sel = create("TextButton", {
			AnchorPoint = Vector2.new(1, 0), Position = UDim2.new(1, -14, 0, math.floor((dh - selH) / 2)),
			Size = UDim2.fromOffset(150, selH),
			BackgroundColor3 = Theme.Panel, Text = "", AutoButtonColor = false,
		}, f)
		corner(sel, 6)
		acc(stroke(sel, Theme.PurpleDark, 1), "Color", PD)
		local selText = create("TextLabel", {
			BackgroundTransparency = 1, Position = UDim2.fromOffset(8, 0), Size = UDim2.new(1, -28, 1, 0),
			Font = Enum.Font.SourceSansSemibold, TextSize = 15, TextColor3 = Theme.Text,
			TextXAlignment = Enum.TextXAlignment.Left, TextTruncate = Enum.TextTruncate.AtEnd, Text = "None",
		}, sel)
		local arrow = create("TextLabel", {
			BackgroundTransparency = 1, AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, -6, 0.5, 0),
			Size = UDim2.fromOffset(16, 16), Font = Enum.Font.GothamBold, TextSize = 12,
			TextColor3 = Theme.Purple, Text = "v",
		}, sel)
		acc(arrow, "TextColor3", P)
		local list = create("ScrollingFrame", {
			Position = UDim2.fromOffset(14, dh + 4), Size = UDim2.new(1, -28, 0, 0), BackgroundColor3 = Theme.Panel,
			BorderSizePixel = 0, ScrollBarThickness = 3, ScrollBarImageColor3 = Theme.Purple,
			CanvasSize = UDim2.new(0, 0, 0, 0), AutomaticCanvasSize = Enum.AutomaticSize.Y,
		}, f)
		acc(list, "ScrollBarImageColor3", P)
		corner(list, 6)
		create("UIListLayout", { Padding = UDim.new(0, 2), SortOrder = Enum.SortOrder.LayoutOrder }, list)
		create("UIPadding", { PaddingTop = UDim.new(0, 2), PaddingLeft = UDim.new(0, 2) }, list)

		local opened = false
		local value = o.Default
		local close

		local function setValue(v, silent)
			value = v
			selText.Text = tostring(v == nil and "None" or v)
			if o.Flag then store[o.Flag] = v; queueSave() end
			if not silent and v ~= nil then
				Library.Notify(Library.T(o.Name) .. ": " .. tostring(v), "Selected", "on", 2)
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
					Size = UDim2.new(1, -8, 0, itemH), BackgroundColor3 = Theme.Item, Text = tostring(name),
					Font = Enum.Font.SourceSansSemibold, TextSize = 15, AutoButtonColor = false, LayoutOrder = idx,
					TextColor3 = (name == value) and Theme.Purple or Theme.Text,
				}, list)
				corner(b, 6)
				acc(b, "TextColor3", function() return (name == value) and Theme.Purple or Theme.Text end)
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
			local listH = math.max(1, math.min(n, 5)) * (itemH + 2) + 4
			list.Size = UDim2.new(1, -28, 0, listH)
			tween(f, 0.3, { Size = UDim2.new(1, 0, 0, dh + 12 + listH) }, Enum.EasingStyle.Back)
			tween(arrow, 0.25, { Rotation = 180 })
		end
		function close()
			opened = false
			tween(f, 0.25, { Size = UDim2.new(1, 0, 0, dh) })
			tween(arrow, 0.25, { Rotation = 0 })
		end
		sel.MouseButton1Click:Connect(function()
			if opened then close() else open() end
		end)

		if o.Flag then
			store[o.Flag] = value
			Library.Setters[o.Flag] = function(v) setValue(v, true) end
		end
		if value ~= nil then setValue(value, true) end
		return { Set = function(v, silent) setValue(v, silent) end, Refresh = populate }
	end

	function Tab:Button(text, cb)
		local f = item(self, compact and 48 or 40)
		local hover = false
		local btn = create("TextButton", {
			Size = UDim2.new(1, 0, 1, 0), BackgroundTransparency = 1, Text = text,
			Font = Enum.Font.GothamBold, TextSize = 14, TextColor3 = Theme.Purple, AutoButtonColor = false,
		}, f)
		acc(btn, "TextColor3", function() return hover and Color3.new(1, 1, 1) or Theme.Purple end)
		acc(f, "BackgroundColor3", function() return hover and Theme.PurpleDark or Theme.Item end)
		reg(btn, text)
		local function paint()
			tweenc(f, 0.15, { BackgroundColor3 = hover and Theme.PurpleDark or Theme.Item })
			tweenc(btn, 0.15, { TextColor3 = hover and Color3.new(1, 1, 1) or Theme.Purple })
		end
		btn.MouseEnter:Connect(function() hover = true; paint() end)
		btn.MouseLeave:Connect(function() hover = false; paint() end)
		btn.MouseButton1Click:Connect(function()
			local s = f.S
			s.Scale = 0.94
			tween(s, 0.35, { Scale = 1 }, Enum.EasingStyle.Back)
			safe(cb)
			if compact then
				task.delay(0.25, function() hover = false; paint() end)
			end
		end)
	end

	function Window:AddTab(name)
		local t = setmetatable({ Order = 0 }, Tab)
		t.Btn = create("TextButton", {
			Text = name, Font = Enum.Font.GothamBold, TextSize = 14, TextColor3 = Theme.Sub,
			BackgroundTransparency = 1, Size = UDim2.new(0, 96, 1, 0),
			AutoButtonColor = false, LayoutOrder = #tabs + 1, TextTruncate = Enum.TextTruncate.AtEnd,
		}, TabBar)
		reg(t.Btn, name)
		create("UIScale", { Name = "S" }, t.Btn)
		t.Line = create("Frame", {
			BackgroundColor3 = Theme.Purple, AnchorPoint = Vector2.new(0.5, 1), Position = UDim2.new(0.5, 0, 1, -2),
			Size = UDim2.new(0, 0, 0, 3), BorderSizePixel = 0,
		}, t.Btn)
		corner(t.Line, 2)
		acc(t.Line, "BackgroundColor3", P)
		t.Page = create("ScrollingFrame", {
			BackgroundTransparency = 1, Size = UDim2.new(1, 0, 1, 0), BorderSizePixel = 0,
			ScrollBarThickness = compact and 2 or 3, ScrollBarImageColor3 = Theme.Purple, Visible = false,
			ScrollingDirection = Enum.ScrollingDirection.Y,
			CanvasSize = UDim2.new(0, 0, 0, 0), AutomaticCanvasSize = Enum.AutomaticSize.Y,
		}, Content)
		acc(t.Page, "ScrollBarImageColor3", P)
		create("UIListLayout", { Padding = UDim.new(0, 8), SortOrder = Enum.SortOrder.LayoutOrder }, t.Page)
		create("UIPadding", {
			PaddingTop = UDim.new(0, 10), PaddingBottom = UDim.new(0, 10),
			PaddingLeft = UDim.new(0, compact and 12 or 16), PaddingRight = UDim.new(0, compact and 12 or 16),
		}, t.Page)
		t.Btn.MouseButton1Click:Connect(function() if current ~= t then selectTab(t) end end)
		table.insert(tabs, t)
		Library.RefreshTabSizes()
		return t
	end

	function Window:Open()
		if isOpen then return end
		isOpen = true
		Main.Visible = true
		if MobileToggle then MobileToggle.Visible = false end
		if firstOpen then
			-- full show only the very first time
			firstOpen = false
			Scale.Scale = 0
			tween(Scale, 0.65, { Scale = 1 }, Enum.EasingStyle.Back)
			if not Library.IsPro then
				MainStroke.Color = Color3.new(1, 1, 1)
				tween(MainStroke, 0.8, { Color = Theme.Purple })
			end
			local c = Vector2.new(
				Gui.AbsoluteSize.X * Main.Position.X.Scale + Main.Position.X.Offset,
				Gui.AbsoluteSize.Y * Main.Position.Y.Scale + Main.Position.Y.Offset
			)
			task.spawn(function() pcall(burst, c, W, H, Gui, compact and 14 or 44, Library.IsPro) end)
			for i, t in ipairs(tabs) do
				local s = t.Btn.S
				s.Scale = 0
				task.delay(0.25 + i * 0.07, function() tween(s, 0.45, { Scale = 1 }, Enum.EasingStyle.Back) end)
			end
			if tabs[1] then
				task.delay(0.3, function() selectTab(tabs[1]) end)
			end
		else
			-- light toggle (RightShift / mobile button): no particles, no pop-ins
			Scale.Scale = 0.9
			tween(Scale, 0.18, { Scale = 1 }, Enum.EasingStyle.Quad)
		end
	end

	function Window:Hide()
		if not isOpen then return end
		isOpen = false
		tween(Scale, 0.15, { Scale = 0.9 }, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
		task.delay(0.16, function()
			if not isOpen then
				Main.Visible = false
				if MobileToggle then MobileToggle.Visible = UIS.TouchEnabled end
			end
		end)
	end

	function Window:Toggle()
		if isOpen then Window:Hide() else Window:Open() end
	end

	Close.MouseButton1Click:Connect(function()
		Window:Hide()
		Library.Notify("Menu hidden", Library.T("Key") .. ": " .. Library.ToggleKey.Name, "off")
	end)
	Library.Connect(UIS.InputBegan, function(i, gp)
		if not gp and not Library.Binding and i.KeyCode == Library.ToggleKey then Window:Toggle() end
	end)

	-- Touch button: shows only while the menu is hidden
	MobileToggle = create("TextButton", {
		Name = "SezarHubMobileToggle", AnchorPoint = Vector2.new(1, 1),
		Position = UDim2.new(1, -18, 1, -24), Size = UDim2.fromOffset(56, 56),
		BackgroundColor3 = Theme.Panel, Text = "SH", TextColor3 = Theme.Purple,
		Font = Enum.Font.GothamBlack, TextSize = 17, AutoButtonColor = true,
		Visible = false,
	}, Gui)
	corner(MobileToggle, 28)
	acc(MobileToggle, "TextColor3", P)
	local mts = stroke(MobileToggle, Theme.Purple, 2)
	if Library.IsPro then
		mts.Color = Color3.new(1, 1, 1)
		grad(mts, 45)
	else
		acc(mts, "Color", P)
	end
	MobileToggle.MouseButton1Click:Connect(function() Window:Toggle() end)
	Library.MobileToggle = MobileToggle

	return Window
end

function Library.Unload()
	for _, f in ipairs(Library.OnUnload) do pcall(f) end
	for _, c in ipairs(Library._conns) do pcall(function() c:Disconnect() end) end
	Gui:Destroy()
end

return Library
