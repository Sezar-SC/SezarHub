-- Key screen: blocks until a valid key is entered, returns the key
-- validate(key) must return "ok", "invalid" or "error"
return function(Library, validate, discord)
	local TweenService = game:GetService("TweenService")
	local Theme, Gui, T = Library.Theme, Library.Gui, Library.T

	local function mk(class, props, parent)
		local o = Instance.new(class)
		for k, v in pairs(props) do o[k] = v end
		if parent then o.Parent = parent end
		return o
	end
	local function tw(o, t, props, style, dir)
		TweenService:Create(o, TweenInfo.new(t, style or Enum.EasingStyle.Quint, dir or Enum.EasingDirection.Out), props):Play()
	end
	local eng = Library.Lang == "English"
	local function fnt(f, fb) return eng and f or fb end
	local function sz(n) return eng and n or math.floor(n * 1.12 + 0.5) end
	local function round(o, r) mk("UICorner", { CornerRadius = UDim.new(0, r) }, o) end
	local function outline(o, c, t)
		return mk("UIStroke", { Color = c, Thickness = t or 1, ApplyStrokeMode = Enum.ApplyStrokeMode.Border }, o)
	end

	local done, result = false, nil

	local overlay = mk("Frame", {
		Size = UDim2.new(1, 0, 1, 0), BackgroundColor3 = Color3.fromRGB(6, 4, 12), BackgroundTransparency = 1,
		BorderSizePixel = 0, ZIndex = 250, Active = true,
	}, Gui)
	tw(overlay, 0.4, { BackgroundTransparency = 0.15 }, Enum.EasingStyle.Quad)

	local card = mk("Frame", {
		AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.new(0.5, 0, 0.5, 0), Size = UDim2.fromOffset(420, 292),
		BackgroundColor3 = Theme.Panel, BorderSizePixel = 0,
	}, overlay)
	round(card, 12)
	outline(card, Theme.Purple, 2)
	local scale = mk("UIScale", { Scale = 0 }, card)
	tw(scale, 0.55, { Scale = 1 }, Enum.EasingStyle.Back)

	mk("TextLabel", {
		BackgroundTransparency = 1, Position = UDim2.fromOffset(0, 20), Size = UDim2.new(1, 0, 0, 32),
		Font = fnt(Enum.Font.GothamBlack, Enum.Font.SourceSansBold), TextSize = sz(22), TextColor3 = Theme.Purple,
		Text = T("KEY REQUIRED"),
	}, card)
	mk("TextLabel", {
		BackgroundTransparency = 1, Position = UDim2.fromOffset(24, 56), Size = UDim2.new(1, -48, 0, 44),
		Font = fnt(Enum.Font.Gotham, Enum.Font.SourceSans), TextSize = sz(13), TextColor3 = Theme.Sub,
		TextWrapped = true, Text = T("Get this week's key from our Discord server, then paste it below."),
	}, card)

	local box = mk("TextBox", {
		Position = UDim2.fromOffset(24, 112), Size = UDim2.new(1, -48, 0, 40), BackgroundColor3 = Theme.Item,
		Text = "", PlaceholderText = T("Paste key here..."), PlaceholderColor3 = Theme.Sub, TextColor3 = Theme.Text,
		Font = Enum.Font.GothamBold, TextSize = 14, ClearTextOnFocus = false,
	}, card)
	round(box, 8)
	outline(box, Theme.PurpleDark, 1)

	local status = mk("TextLabel", {
		BackgroundTransparency = 1, Position = UDim2.fromOffset(24, 158), Size = UDim2.new(1, -48, 0, 18),
		Font = fnt(Enum.Font.GothamMedium, Enum.Font.SourceSansSemibold), TextSize = sz(12), TextColor3 = Theme.Sub, Text = "",
	}, card)

	local verify = mk("TextButton", {
		Position = UDim2.fromOffset(24, 184), Size = UDim2.new(1, -48, 0, 42), BackgroundColor3 = Theme.Purple,
		Text = T("Verify"), Font = fnt(Enum.Font.GothamBold, Enum.Font.SourceSansBold), TextSize = sz(15),
		TextColor3 = Color3.new(1, 1, 1), AutoButtonColor = false,
	}, card)
	round(verify, 8)
	verify.MouseEnter:Connect(function() tw(verify, 0.15, { BackgroundColor3 = Theme.PurpleDark }) end)
	verify.MouseLeave:Connect(function() tw(verify, 0.15, { BackgroundColor3 = Theme.Purple }) end)

	local dc = mk("TextButton", {
		Position = UDim2.fromOffset(24, 236), Size = UDim2.new(1, -48, 0, 34), BackgroundColor3 = Theme.Item,
		Text = T("Copy Discord Link"), Font = fnt(Enum.Font.GothamBold, Enum.Font.SourceSansBold), TextSize = sz(13),
		TextColor3 = Theme.Purple, AutoButtonColor = false,
	}, card)
	round(dc, 8)
	dc.MouseEnter:Connect(function() tw(dc, 0.15, { BackgroundColor3 = Theme.ItemHover }) end)
	dc.MouseLeave:Connect(function() tw(dc, 0.15, { BackgroundColor3 = Theme.Item }) end)
	dc.MouseButton1Click:Connect(function()
		if setclipboard then
			setclipboard(discord)
			status.TextColor3 = Theme.Purple
			status.Text = T("Copied") .. ": " .. discord
		else
			status.TextColor3 = Theme.Off
			status.Text = discord
		end
	end)

	local busy = false
	local function try()
		if busy or done then return end
		local k = (box.Text:gsub("%s+", ""))
		if k == "" then return end
		busy = true
		status.TextColor3 = Theme.Sub
		status.Text = T("Checking...")
		local res = validate(k)
		busy = false
		if res == "ok" then
			status.TextColor3 = Theme.Purple
			status.Text = T("Key accepted")
			result = k
			task.delay(0.6, function() done = true end)
		elseif res == "error" then
			status.TextColor3 = Theme.Off
			status.Text = T("Could not reach key server")
		else
			status.TextColor3 = Theme.Off
			status.Text = T("Wrong or expired key")
			task.spawn(function()
				for _, dx in ipairs({ -10, 10, -7, 7, -3, 3, 0 }) do
					tw(card, 0.04, { Position = UDim2.new(0.5, dx, 0.5, 0) }, Enum.EasingStyle.Quad)
					task.wait(0.045)
				end
			end)
		end
	end
	verify.MouseButton1Click:Connect(try)
	box.FocusLost:Connect(function(enter) if enter then try() end end)

	while not done do
		task.wait(0.1)
		if not overlay.Parent then return nil end
	end

	tw(scale, 0.3, { Scale = 0 }, Enum.EasingStyle.Back, Enum.EasingDirection.In)
	tw(overlay, 0.35, { BackgroundTransparency = 1 }, Enum.EasingStyle.Quad)
	task.wait(0.4)
	overlay:Destroy()
	return result
end
