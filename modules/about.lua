-- About tab: info, live clock, links
return function(Tab, Library)
	local Players = game:GetService("Players")
	local lp = Players.LocalPlayer

	-- Values come from config.lua
	local DEVELOPER = Library.Config.Developer or "Sezar"
	local LAST_UPDATE = Library.Config.LastUpdate or "-"
	local DISCORD = Library.Config.Discord or "discord.gg/YOURLINK"

	local startTime = os.time()

	Tab:Section("About SezarHub")
	Tab:Label("SezarHub is a free multi-game script hub made for the community. Stay active on our Discord for giveaways and updates.")

	Tab:Section("Details")
	Tab:Label("Developer", DEVELOPER)
	Tab:Label("Version", "v" .. Library.Version)
	Tab:Label("Last Update", LAST_UPDATE)
	Tab:Label("Game", Library.GameName)

	local exec = "Unknown"
	pcall(function()
		if identifyexecutor then exec = tostring(identifyexecutor()) end
	end)
	Tab:Label("Executor", exec)
	Tab:Label("Player", lp.Name)

	local timeL = Tab:Label("Local Time", os.date("%H:%M:%S"))
	local dateL = Tab:Label("Date", os.date("%d.%m.%Y"))
	local sessL = Tab:Label("Session Time", "00:00:00")

	Tab:Section("Links")
	Tab:Label("Discord", DISCORD)
	Tab:Button("Copy Discord Link", function()
		if setclipboard then
			setclipboard(DISCORD)
			Library.Notify("Copied", DISCORD, "on")
		else
			Library.Notify("Not supported", "Executor has no setclipboard", "off")
		end
	end)

	local alive = true
	table.insert(Library.OnUnload, function() alive = false end)
	task.spawn(function()
		while alive do
			timeL.Set(os.date("%H:%M:%S"))
			dateL.Set(os.date("%d.%m.%Y"))
			local s = os.time() - startTime
			sessL.Set(string.format("%02d:%02d:%02d", math.floor(s / 3600), math.floor(s / 60) % 60, s % 60))
			task.wait(1)
		end
	end)
end
