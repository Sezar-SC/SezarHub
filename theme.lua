-- Theme manager: live switching. Pro themes are loaded ONLY for a verified Pro profile.
return function(Library)
	local RunService = game:GetService("RunService")
	local Theme, Gui = Library.Theme, Library.Gui
	local C = Color3.fromRGB
	local BASE = Library.Base or "https://raw.githubusercontent.com/Sezar-SC/SezarHub/main/"

	local function th(name, tier, hub, bg, panel, item, hover, accent, accentDark, text, sub, off, switchOff)
		return {
			name = name, tier = tier, hub = hub,
			c = {
				Bg = bg, Panel = panel, Item = item, ItemHover = hover,
				Purple = accent, PurpleDark = accentDark,
				Text = text, Sub = sub, Off = off, SwitchOff = switchOff,
			},
		}
	end

	-- tier 0 = Free, 1 = Subscriber, 2 = VIP (VIP stays shelved: VIPEnabled is always false)
	local THEMES = {
		th("Neon Purple", 0, C(150, 70, 255), C(10, 8, 16), C(18, 14, 28), C(26, 20, 40), C(34, 26, 52),
			C(150, 70, 255), C(100, 45, 180), C(238, 232, 248), C(150, 140, 172), C(230, 70, 90), C(50, 42, 70)),
		th("Dark", 0, C(60, 110, 230), C(12, 12, 14), C(20, 20, 24), C(28, 28, 34), C(38, 38, 46),
			C(80, 140, 255), C(50, 95, 190), C(235, 236, 240), C(140, 144, 155), C(230, 70, 90), C(50, 52, 60)),
		th("Clean White", 0, C(70, 100, 240), C(240, 241, 246), C(250, 250, 253), C(232, 234, 241), C(222, 225, 235),
			C(70, 100, 240), C(150, 165, 235), C(24, 24, 34), C(100, 104, 120), C(220, 50, 70), C(200, 204, 216)),

		th("Crimson", 1, C(210, 30, 55), C(12, 6, 8), C(22, 10, 13), C(34, 15, 20), C(46, 20, 27),
			C(235, 50, 70), C(170, 30, 48), C(248, 232, 235), C(180, 140, 148), C(255, 170, 60), C(70, 36, 42)),
		th("Autumn", 1, C(220, 100, 10), C(14, 9, 6), C(24, 15, 9), C(36, 23, 14), C(48, 31, 19),
			C(255, 130, 30), C(190, 90, 15), C(250, 236, 222), C(180, 150, 125), C(230, 70, 90), C(70, 50, 36)),
		th("Snow", 1, C(20, 120, 200), C(226, 238, 250), C(240, 247, 255), C(214, 230, 247), C(200, 221, 244),
			C(40, 150, 230), C(90, 170, 225), C(20, 40, 70), C(80, 105, 135), C(225, 60, 80), C(175, 198, 224)),

		th("Gold Diamond", 2, C(190, 130, 0), C(12, 10, 6), C(22, 18, 10), C(34, 28, 15), C(46, 38, 20),
			C(255, 205, 70), C(190, 150, 40), C(250, 244, 225), C(175, 165, 135), C(230, 70, 90), C(66, 58, 38)),
		th("Cyberpunk", 2, C(200, 0, 130), C(8, 6, 18), C(16, 10, 34), C(24, 14, 50), C(34, 20, 68),
			C(0, 240, 255), C(200, 30, 130), C(235, 250, 255), C(140, 160, 190), C(255, 60, 90), C(50, 36, 90)),
	}

	local PRO = {} -- filled only by ApplyKeyProfile after the Worker confirmed the Pro profile

	Library.ThemeName = "Neon Purple"
	Library.HubHex = "9646FF"

	local STATIC_KEYS = { "Bg", "Panel", "Item", "ItemHover", "Text", "Sub", "Off", "SwitchOff" }
	local REQUIRED = { "Bg", "Panel", "Item", "ItemHover", "Purple", "PurpleDark", "Text", "Sub", "Off", "SwitchOff" }

	local function find(name)
		for _, t in ipairs(PRO) do
			if t.name == name then return t end
		end
		for _, t in ipairs(THEMES) do
			if t.name == name then return t end
		end
	end

	local function allowed(t)
		if t.pro then return Library.IsPro == true end
		if t.tier == 0 then return true end
		return Library.VIPEnabled == true and (Library.Tier or 0) >= t.tier
	end

	-- Dropdown list: Pro sees only Pro themes, Free sees only Free themes.
	function Library.ThemeOptions()
		local out = {}
		if Library.IsPro then
			for _, t in ipairs(PRO) do table.insert(out, t.name) end
			return out
		end
		for _, t in ipairs(THEMES) do
			if t.tier == 0 then
				table.insert(out, t.name)
			elseif Library.VIPEnabled then
				table.insert(out, allowed(t) and t.name or (t.name .. " (locked)"))
			end
		end
		return out
	end

	local function colorKey(c)
		return math.floor(c.R * 255 + 0.5) .. "," .. math.floor(c.G * 255 + 0.5) .. "," .. math.floor(c.B * 255 + 0.5)
	end

	local function seqFrom(list)
		if type(list) ~= "table" or #list < 2 then return nil end
		local n = #list
		local kps = {}
		for i, col in ipairs(list) do
			if typeof(col) ~= "Color3" then return nil end
			kps[i] = ColorSequenceKeypoint.new((i - 1) / (n - 1), col)
		end
		return ColorSequence.new(kps)
	end

	local PROPS = { "BackgroundColor3", "TextColor3", "Color", "ImageColor3", "ScrollBarImageColor3" }

	-- Rainbow: hue keeps moving, everything registered as "accent" follows it
	local tickAcc = 0
	local function rainbowStep()
		local h = (os.clock() * 0.1) % 1
		Theme.Purple = Color3.fromHSV(h, 0.8, 1)
		Theme.PurpleDark = Color3.fromHSV((h + 0.06) % 1, 0.9, 0.72)
		Library.GradientSeq = Library.RainbowSeq(h)
		Library.RefreshAccent()
	end
	Library.Connect(RunService.Heartbeat, function(dt)
		if not Library.Animated then return end
		tickAcc = tickAcc + dt
		local gap = (Library.DeviceClass == "Touch") and 0.07 or 0.04
		if tickAcc < gap then return end
		tickAcc = 0
		pcall(rainbowStep)
	end)

	function Library.SetTheme(label, silent)
		local name = tostring(label):gsub(" %(locked%)$", "")
		local t = find(name)
		if not t then return false end

		if not allowed(t) then
			if not silent then Library.Notify("Theme locked", "Subscriber or VIP only", "off") end
			return false
		end
		if name == Library.ThemeName then return true end

		-- static colors are remapped by value
		local colorMap = {}
		for _, k in ipairs(STATIC_KEYS) do
			local oldColor, newColor = Theme[k], t.c[k]
			if oldColor and newColor then colorMap[colorKey(oldColor)] = newColor end
		end
		for k, newColor in pairs(t.c) do Theme[k] = newColor end

		Library.ThemeName = name
		Library.Animated = (t.animated == true)
		Library.GradientSeq = seqFrom(t.gradient) or ColorSequence.new(t.c.PurpleDark, t.c.Purple)
		Library.HubHex = t.hub:ToHex()

		for _, d in ipairs(Gui:GetDescendants()) do
			for _, prop in ipairs(PROPS) do
				local ok, value = pcall(function() return d[prop] end)
				if ok and typeof(value) == "Color3" then
					local newColor = colorMap[colorKey(value)]
					if newColor then
						pcall(function() d[prop] = newColor end)
					end
				end
			end
		end

		if Library.Animated then
			pcall(rainbowStep)
		else
			pcall(Library.RefreshAccent)
		end

		if Library.LogoLabel then
			Library.LogoLabel.Text = '<font color="#000000">Sezar</font><font color="#' .. Library.HubHex .. '">Hub</font>'
		end
		return true
	end

	local function validTheme(t)
		if type(t) ~= "table" or type(t.name) ~= "string" or type(t.c) ~= "table" then return false end
		for _, k in ipairs(REQUIRED) do
			if typeof(t.c[k]) ~= "Color3" then return false end
		end
		return typeof(t.hub) == "Color3"
	end

	local function readSavedTheme()
		if not Library.CanSave then return nil end
		local ok, data = pcall(function()
			if isfile("SezarHub/global.json") then
				return game:GetService("HttpService"):JSONDecode(readfile("SezarHub/global.json"))
			end
		end)
		if ok and type(data) == "table" and type(data.theme) == "string" then return data.theme end
		return nil
	end

	-- Called by main.lua with the profile the Worker returned.
	function Library.ApplyKeyProfile(profile)
		if profile ~= "efendim" then return false end

		local okGet, src = pcall(function() return game:HttpGet(BASE .. "pro_themes.lua") end)
		if not okGet or type(src) ~= "string" or not loadstring then return false end
		local okC, chunk = pcall(loadstring, src)
		if not okC or type(chunk) ~= "function" then return false end
		local okR, pack = pcall(chunk)
		if not okR or type(pack) ~= "table" or pack.Profile ~= profile or type(pack.Themes) ~= "table" then
			return false
		end

		local list = {}
		for _, t in ipairs(pack.Themes) do
			if validTheme(t) then
				t.pro = true
				table.insert(list, t)
			end
		end
		if #list == 0 then return false end

		PRO = list
		Library.IsPro = true
		Library.Role = "Pro"
		if type(pack.Welcome) == "string" and pack.Welcome ~= "" then
			Library.WelcomeMessage = pack.Welcome
		end

		-- saved choice if it is a Pro theme, otherwise the default (Rainbow)
		local chosen
		local saved = readSavedTheme()
		if saved then
			for _, t in ipairs(PRO) do
				if t.name == saved then chosen = saved end
			end
		end
		chosen = chosen or (type(pack.DefaultTheme) == "string" and pack.DefaultTheme) or list[1].name
		if not Library.SetTheme(chosen, true) then Library.SetTheme(list[1].name, true) end
		return true
	end

	function Library.PreloadGlobals()
		if not Library.CanSave then return end

		local ok, data = pcall(function()
			if isfile("SezarHub/global.json") then
				return game:GetService("HttpService"):JSONDecode(readfile("SezarHub/global.json"))
			end
		end)

		if ok and type(data) == "table" then
			if type(data.language) == "string" and Library.Dict[data.language] then
				Library.SetLanguage(data.language)
			end
			if type(data.theme) == "string" then
				Library.SetTheme(data.theme, true) -- Pro theme names are rejected here (not loaded yet)
			end
		end
	end
end
