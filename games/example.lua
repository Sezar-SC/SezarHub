-- Template for a game specific tab
return function(Window, Library)
	local Tab = Window:AddTab("Game")
	Tab:Section("Game Features")
	Tab:Label("Game specific features go here.")
	Tab:Toggle({ Name = "Example Toggle", Flag = "example_toggle", Callback = function(v)
		print("Example toggle:", v)
	end })
	Tab:Button("Example Button", function()
		Library.Notify("Example", "Button pressed", "on")
	end)
end
