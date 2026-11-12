-- SezarHub loader v2.4
local BASE = "https://raw.githubusercontent.com/Sezar-SC/SezarHub/main/"
local VERIFY_URL = "https://sezarhub-key-check.sehladarcalilov.workers.dev/verify"

local function fetchText(path)
	local ok, res = pcall(function() return game:HttpGet(BASE .. path) end)
	if ok then return res end
	warn("[SezarHub] " .. path .. " could not be downloaded")
	return nil
end

local function fetch(path)
	local ok, res = pcall(function()
		return loadstring(game:HttpGet(BASE .. path))()
	end)
	if not ok then
		warn("[SezarHub] " .. path .. " failed to load: " .. tostring(res))
		return nil
	end
	return res
end

local Library = fetch("ui.lua")
if not Library then return end

local function stopStartup(message)
	warn("[SezarHub] " .. message)
	if Library.Notify then pcall(Library.Notify, "Startup failed", message, "off", 6) end
	task.delay(6.5, function()
		if Library.Unload then pcall(Library.Unload) end
	end)
end

-- Config + version
local Config = fetch("config.lua")
if type(Config) ~= "table" then
	stopStartup("Configuration could not be loaded. Please try again later.")
	return
end
Library.Config = Config
Config.Discord = Config.Discord or "discord.gg/YOURLINK"

local ver, notes = "2.4.0", ""
local verText = fetchText("version.txt")
if verText then
	ver = verText:match("^%s*(%S+)") or ver
	notes = verText:match("^%s*%S+%s*[\r\n]+%s*([^\r\n]+)") or ""
end
Library.Version = ver

-- Languages
local Lang = fetch("lang.lua")
if type(Lang) == "table" then Library.Dict = Lang.Dict end

-- Client-downloaded VIP roles are not trusted.
Library.VIPEnabled = false
Library.Tier = 0
if Config.VIPEnabled == true then
	warn("[SezarHub] VIP is configured but no server verifier is available; using Free access")
	if Library.Notify then
		pcall(Library.Notify, "VIP unavailable", "Server verification is not configured", "off", 5)
	end
end
Library.Role = (Library.Tier == 2 and "VIP") or (Library.Tier == 1 and "Subscriber") or "Free"

-- Theme manager + saved language/theme
local themeFn = fetch("theme.lua")
if type(themeFn) == "function" then
	local ok, err = pcall(themeFn, Library)
	if not ok then
		warn("[SezarHub] theme.lua error: " .. tostring(err))
		pcall(Library.Notify, "Theme unavailable", "Default theme will be used", "off", 5)
	end
elseif not themeFn then
	pcall(Library.Notify, "Theme unavailable", "Default theme will be used", "off", 5)
end
if Library.PreloadGlobals then pcall(Library.PreloadGlobals) end

-- File helpers
local function readSaved(path)
	if not Library.CanSave then return nil end
	local ok, res = pcall(function()
		if isfile(path) then return readfile(path) end
	end)
	return ok and res or nil
end

local function writeSaved(path, text)
	if not Library.CanSave then return end
	pcall(function()
		if not isfolder("SezarHub") then makefolder("SezarHub") end
		writefile(path, text)
	end)
end

-- Key check: Cloudflare Worker, POST body, fail closed
local HttpService = game:GetService("HttpService")
local requestFn = (syn and syn.request) or (http and http.request) or http_request or request

-- Returns "ok", "invalid", or "error".
local function checkKey(key)
	if type(key) ~= "string" then return "invalid" end
	key = key:gsub("%s+", "")
	if key == "" or #key > 128 then return "invalid" end
	if type(requestFn) ~= "function" then return "error" end

	local ok, res = pcall(requestFn, {
		Url = VERIFY_URL,
		Method = "POST",
		Headers = { ["Content-Type"] = "application/json" },
		Body = HttpService:JSONEncode({ key = key }),
	})
	if not ok or type(res) ~= "table" then return "error" end
	if res.StatusCode ~= 200 then return "error" end

	local okJson, data = pcall(function()
		return HttpService:JSONDecode(res.Body)
	end)
	if not okJson or type(data) ~= "table" then return "error" end

	if data.valid == true then
		Library.KeyProfile =
			(type(data.profile) == "string" and #data.profile <= 48)
			and data.profile
			or nil
		return "ok"
	end

	Library.KeyProfile = nil
	if data.valid == false then return "invalid" end
	return "error"
end

if Config.KeyEnabled ~= false then
	local saved = readSaved("SezarHub/key.txt")
	local status = "invalid"

	if saved and saved:gsub("%s+", "") ~= "" then
		status = checkKey(saved)
		if status == "error" then
			stopStartup("Could not reach key server. Access is blocked.")
			return
		end
	end

	if status ~= "ok" then
		local screen = fetch("keyscreen.lua")
		if type(screen) ~= "function" then
			stopStartup("Key screen could not be loaded. Access is blocked.")
			return
		end

		local okScreen, entered = pcall(screen, Library, checkKey, Config.Discord)
		if not okScreen or type(entered) ~= "string" or entered == "" then
			stopStartup("A valid key is required to continue.")
			return
		end
		writeSaved("SezarHub/key.txt", entered)
	end
end

-- Apply a known visual profile returned by the Worker.
if Library.KeyProfile and Library.ApplyKeyProfile then
	local okProfile, applied = pcall(Library.ApplyKeyProfile, Library.KeyProfile)
	if not okProfile or not applied then
		warn("[SezarHub] Unknown visual key profile; default theme will be used")
	end
end

-- Game detection
local list = fetch("games/list.lua")
local entry = list and (list[game.PlaceId] or list[game.GameId])
local gamePath, gameName

if type(entry) == "table" then
	gamePath, gameName = entry.file, entry.name
elseif type(entry) == "string" then
	gamePath = entry
end

if gamePath and not gameName then
	pcall(function()
		gameName = game:GetService("MarketplaceService"):GetProductInfo(game.PlaceId).Name
	end)
end

if gamePath then
	local clean = tostring(gameName or "GAME")
	clean = clean:gsub("[^\32-\126]", "")
	clean = clean:gsub("^%s+", "")
	clean = clean:gsub("%s+$", "")
	if clean == "" then clean = "GAME" end
	Library.GameName = string.upper(clean)
else
	Library.GameName = "UNIVERSAL"
end

local Window = Library.CreateWindow()

local function loadModule(path, tab)
	local fn = fetch(path)
	if type(fn) == "function" then
		local ok, err = pcall(fn, tab, Library)
		if not ok then
			warn("[SezarHub] " .. path .. " error: " .. tostring(err))
			pcall(Library.Notify, "Module error", path .. " could not be loaded", "off", 5)
		end
	else
		pcall(Library.Notify, "Module unavailable", path .. " could not be downloaded", "off", 5)
	end
end

-- Tabs
local About = Window:AddTab("About")
local Movement = Window:AddTab("Movement")
local ESP = Window:AddTab("ESP")
local Misc = Window:AddTab("Misc")

loadModule("modules/about.lua", About)
loadModule("modules/movement.lua", Movement)
loadModule("modules/fly.lua", Movement)
loadModule("modules/esp.lua", ESP)
loadModule("modules/misc.lua", Misc)

if gamePath then
	local gameFn = fetch(gamePath)
	if type(gameFn) == "function" then
		local ok, err = pcall(gameFn, Window, Library)
		if not ok then
			warn("[SezarHub] " .. gamePath .. " error: " .. tostring(err))
			pcall(Library.Notify, "Game module error", gamePath .. " could not be loaded", "off", 5)
		end
	else
		pcall(Library.Notify, "Game module unavailable", gamePath .. " could not be downloaded", "off", 5)
	end
end

-- Settings tab
local Settings = Window:AddTab("Settings")
local autoSaveWanted = true
local loaded = false

Settings:Section("Language")
Settings:Dropdown({
	Name = "Language", Flag = "language", Global = true, Default = "English",
	Options = (Lang and Lang.Names) or { "English" },
	Callback = function(v) Library.SetLanguage(v) end,
})

Settings:Section("Theme")
local themeDD
themeDD = Settings:Dropdown({
	Name = "Theme", Flag = "theme", Global = true, Default = Library.ThemeName,
	Options = function()
		return Library.ThemeOptions and Library.ThemeOptions() or { "Neon Purple" }
	end,
	Callback = function(v)
		if Library.SetTheme and not Library.SetTheme(v) and themeDD then
			themeDD.Set(Library.ThemeName)
		end
	end,
})

Settings:Section("Menu")
Settings:Dropdown({
	Name = "Menu Key", Flag = "menu_key", Global = true, Default = "RightShift",
	Options = { "RightShift", "Insert", "Delete", "RightControl", "RightAlt", "Home" },
	Callback = function(v)
		local k = Enum.KeyCode[v]
		if k then Library.ToggleKey = k end
	end,
})

Settings:Section("Config")
Settings:Label(Library.CanSave and "Config saving: supported" or "Config saving: not supported by this executor")
Settings:Toggle({
	Name = "Auto Save",
	Default = true,
	NoKey = true,
	Callback = function(v)
		autoSaveWanted = v
		if loaded then Library.AutoSave = v end
	end,
})
Settings:Button("Save Config Now", function()
	if Library.Save() then
		Library.Notify("Config saved", "Settings written to file", "on")
	else
		Library.Notify("Save failed", "Executor may not support files", "off")
	end
end)
Settings:Button("Load Config", function()
	if Library.Load() then
		Library.Notify("Config loaded", "Settings restored", "on")
	else
		Library.Notify("Load failed", "No saved config found", "off")
	end
end)

Settings:Section("Info")
Settings:Label("Role", Library.Role)
Settings:Label("PlaceId: " .. tostring(game.PlaceId) .. "   |   GameId: " .. tostring(game.GameId))
Settings:Button("Copy PlaceId", function()
	if setclipboard then
		setclipboard(tostring(game.PlaceId))
		Library.Notify("Copied", "PlaceId " .. tostring(game.PlaceId), "on")
	else
		Library.Notify("Not supported", "Executor has no setclipboard", "off")
	end
end)
Settings:Button("Unload Hub", function()
	Library.Unload()
end)

-- Restore config, then show splash and menu.
local restored = Library.Load()
loaded = true
Library.AutoSave = autoSaveWanted

Library.Splash(2.6, Library.WelcomeMessage)
Window:Open()
Library.Notify("SezarHub loaded", restored and "Config restored" or "Welcome", "on", 4)

-- Update notice
local lastSeen = readSaved("SezarHub/lastver.txt")
local lastClean = lastSeen and lastSeen:gsub("%s+", "") or nil
if lastClean ~= ver then
	writeSaved("SezarHub/lastver.txt", ver)
	if lastClean then
		task.delay(1.4, function()
			Library.Notify("Updated", "v" .. ver .. (notes ~= "" and (": " .. notes) or ""), "on", 5)
		end)
	end
end
