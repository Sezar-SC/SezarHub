-- SezarHub yukleyici
local BASE = "https://raw.githubusercontent.com/Sezar-SC/SezarHub/main/"

local function fetch(path)
	local ok, res = pcall(function()
		return loadstring(game:HttpGet(BASE .. path))()
	end)
	if not ok then
		warn("[SezarHub] " .. path .. " yuklenemedi: " .. tostring(res))
		return nil
	end
	return res
end

local Library = fetch("ui.lua")
if not Library then return end

local Window = Library.CreateWindow()

-- Sekmeler
local Hareket = Window:AddTab("Hareket")
local ESP = Window:AddTab("ESP")
local Genel = Window:AddTab("Genel")
local Ayarlar = Window:AddTab("Ayarlar")

-- Hareket
local movement = fetch("modules/movement.lua")
if movement then movement(Hareket, Library) end

-- ESP (sonra doldurulacak)
ESP:Label("ESP modulu yakinda eklenecek.")

-- Genel (sonra doldurulacak)
Genel:Label("Anti-AFK ve diger ozellikler yakinda eklenecek.")

-- Ayarlar
Ayarlar:Section("Menu")
Ayarlar:Label("Menuyu gizle/goster: RightShift")
Ayarlar:Button("Menuyu Tamamen Kapat", function()
	Library.Unload()
end)

Window:Open()
Library.Notify("SezarHub yuklendi", "Hos geldin", "on", 4)
