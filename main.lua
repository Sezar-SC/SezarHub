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

local Window = Library.CreateWindow()

local function loadModule(path, tab)
	local fn = fetch(path)
	if type(fn) == "function" then
		local ok, err = pcall(fn, tab, Library)
		if not ok then warn("[SezarHub] " .. path .. " error: " .. tostring(err)) end
	end
end

-- Tabs
local Movement = Window:AddTab("Movement")
local ESP = Window:AddTab("ESP")
local Misc = Window:AddTab("Misc")

loadModule("modules/movement.lua", Movement)
loadModule("modules/fly.lua", Movement)
loadModule("modules/esp.lua", ESP)
loadModule("modules/misc.lua", Misc)

-- Game detection (adds an extra tab if this game is in the list)
local list = fetch("games/list.lua")
local gamePath = list and (list[game.PlaceId] or list[game.GameId])
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

Settings:Section("Menu")
Settings:Dropdown({
	Name = "Menu Key", Flag = "menu_key", Default = "RightShift",
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

-- Load saved config, then enable autosave
local restored = Library.Load()
loaded = true
Library.AutoSave = autoSaveWanted

Window:Open()
Library.Notify("SezarHub loaded", restored and "Config restored" or "Welcome", "on", 4)
