-- SezarHub loader
local BASE = "https://raw.githubusercontent.com/Sezar-SC/SezarHub/main/"

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
Library.Version = "2.1"

-- Languages
local Lang = fetch("lang.lua")
if type(Lang) == "table" then Library.Dict = Lang.Dict end

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
	clean = (clean:gsub("[^\32-\126]", ""))
	clean = (clean:gsub("^%s+", ""))
	clean = (clean:gsub("%s+$", ""))
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
		if not ok then warn("[SezarHub] " .. path .. " error: " .. tostring(err)) end
	end
end

-- Tabs (About comes first, so it opens first)
local About = Window:AddTab("About")
local Movement = Window:AddTab("Movement")
local ESP = Window:AddTab("ESP")
local Misc = Window:AddTab("Misc")

loadModule("modules/about.lua", About)
loadModule("modules/movement.lua", Movement)
loadModule("modules/fly.lua", Movement)
loadModule("modules/esp.lua", ESP)
loadModule("modules/misc.lua", Misc)

-- Game specific tab
if gamePath then
	local gameFn = fetch(gamePath)
	if type(gameFn) == "function" then
		local ok, err = pcall(gameFn, Window, Library)
		if not ok then warn("[SezarHub] " .. gamePath .. " error: " .. tostring(err)) end
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
Settings:Toggle({ Name = "Auto Save", Default = true, NoKey = true, Callback = function(v)
	autoSaveWanted = v
	if loaded then Library.AutoSave = v end
end })
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

-- Load saved config (language included), then splash and menu
local restored = Library.Load()
loaded = true
Library.AutoSave = autoSaveWanted

Library.Splash(2.6)
Window:Open()
Library.Notify("SezarHub loaded", restored and "Config restored" or "Welcome", "on", 4)
