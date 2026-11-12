-- Optional visual profiles. No keys or secrets belong in this file.
return {
	Themes = {
		{
			name = "Golden", tier = 0, hub = Color3.fromRGB(255, 214, 105),
			gradient = ColorSequence.new(Color3.fromRGB(110, 65, 10), Color3.fromRGB(255, 213, 92)),
			c = {
				Bg = Color3.fromRGB(16, 12, 7), Panel = Color3.fromRGB(27, 21, 12),
				Item = Color3.fromRGB(43, 33, 17), ItemHover = Color3.fromRGB(61, 46, 22),
				Purple = Color3.fromRGB(255, 205, 77), PurpleDark = Color3.fromRGB(181, 126, 28),
				Text = Color3.fromRGB(255, 247, 224), Sub = Color3.fromRGB(190, 171, 127),
				Off = Color3.fromRGB(235, 86, 94), SwitchOff = Color3.fromRGB(73, 58, 34),
			},
		},
		{
			name = "Diamond", tier = 0, hub = Color3.fromRGB(127, 236, 255),
			gradient = ColorSequence.new(Color3.fromRGB(40, 113, 165), Color3.fromRGB(164, 248, 255)),
			c = {
				Bg = Color3.fromRGB(6, 15, 22), Panel = Color3.fromRGB(12, 27, 38),
				Item = Color3.fromRGB(18, 42, 56), ItemHover = Color3.fromRGB(27, 59, 75),
				Purple = Color3.fromRGB(125, 227, 255), PurpleDark = Color3.fromRGB(51, 150, 186),
				Text = Color3.fromRGB(230, 250, 255), Sub = Color3.fromRGB(139, 183, 197),
				Off = Color3.fromRGB(255, 100, 118), SwitchOff = Color3.fromRGB(39, 72, 87),
			},
		},
		{
			name = "Silver", tier = 0, hub = Color3.fromRGB(220, 229, 245),
			gradient = ColorSequence.new(Color3.fromRGB(76, 88, 111), Color3.fromRGB(224, 234, 250)),
			c = {
				Bg = Color3.fromRGB(12, 14, 19), Panel = Color3.fromRGB(22, 25, 33),
				Item = Color3.fromRGB(34, 38, 49), ItemHover = Color3.fromRGB(47, 52, 65),
				Purple = Color3.fromRGB(204, 216, 237), PurpleDark = Color3.fromRGB(119, 135, 160),
				Text = Color3.fromRGB(244, 247, 252), Sub = Color3.fromRGB(157, 167, 184),
				Off = Color3.fromRGB(239, 93, 110), SwitchOff = Color3.fromRGB(62, 68, 82),
			},
		},
	},
	KeyProfiles = {
		efendim = { theme = "Golden", welcome = "Hoş geldiniz, Efendim" },
	},
}
