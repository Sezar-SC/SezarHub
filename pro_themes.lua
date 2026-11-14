-- Pro theme pack. Only downloaded after the Worker returns the "efendim" profile.
-- To roll back: delete this file. Pro then runs with the Free look.
local C = Color3.fromRGB

return {
	Profile = "efendim",
	Welcome = "Ho\u{15F} geldiniz, Efendim",
	DefaultTheme = "Rainbow",

	Themes = {
		{
			name = "Rainbow", animated = true, hub = C(90, 30, 190),
			c = {
				Bg = C(9, 9, 14), Panel = C(16, 16, 25), Item = C(24, 24, 37), ItemHover = C(34, 34, 52),
				Purple = C(255, 80, 160), PurpleDark = C(160, 50, 200),
				Text = C(242, 242, 250), Sub = C(150, 150, 175), Off = C(255, 85, 105), SwitchOff = C(48, 48, 68),
			},
		},
		{
			name = "Golden", hub = C(140, 95, 0),
			gradient = { C(120, 80, 0), C(255, 215, 90), C(255, 245, 190), C(255, 215, 90), C(120, 80, 0) },
			c = {
				Bg = C(12, 10, 6), Panel = C(22, 18, 10), Item = C(34, 28, 15), ItemHover = C(46, 38, 20),
				Purple = C(255, 205, 70), PurpleDark = C(190, 150, 40),
				Text = C(250, 244, 225), Sub = C(175, 165, 135), Off = C(230, 70, 90), SwitchOff = C(66, 58, 38),
			},
		},
		{
			name = "Diamond", hub = C(0, 110, 170),
			gradient = { C(40, 140, 200), C(120, 230, 255), C(235, 250, 255), C(120, 230, 255), C(40, 140, 200) },
			c = {
				Bg = C(6, 12, 18), Panel = C(10, 20, 30), Item = C(15, 30, 44), ItemHover = C(21, 41, 60),
				Purple = C(110, 225, 255), PurpleDark = C(50, 150, 200),
				Text = C(232, 248, 255), Sub = C(130, 165, 185), Off = C(255, 90, 110), SwitchOff = C(30, 52, 72),
			},
		},
		{
			name = "Silver", hub = C(80, 86, 98),
			gradient = { C(110, 116, 128), C(215, 220, 230), C(255, 255, 255), C(215, 220, 230), C(110, 116, 128) },
			c = {
				Bg = C(14, 15, 18), Panel = C(24, 26, 30), Item = C(34, 37, 42), ItemHover = C(46, 50, 57),
				Purple = C(200, 206, 216), PurpleDark = C(130, 138, 150),
				Text = C(240, 242, 246), Sub = C(150, 156, 166), Off = C(230, 80, 95), SwitchOff = C(58, 62, 70),
			},
		},
	},
}
