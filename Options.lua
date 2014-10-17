local Grid = Grid
local GridFrame = Grid:GetModule("GridFrame")
local Media = LibStub("LibSharedMedia-3.0")
local db = Grid.db:RegisterNamespace("GridIndicatorExtra", {
	profile = {
		icon = {
			iconSize = 12,
			iconBorderSize = 0,
			enableIconStackText = true,
			enableIconCooldown = true,
			stackFontSize = 7,
			margin = 1,
			spacing = 1,
		},
		text = {
			font = "Friz Quadrata TT",
			fontSize = 8,
			fontOutline = "THIN",
			fontShadow = false,
			margin = 2,
			textlength = 6,
		}
	}
})

GridFrame.options.args["GridIndicatorExtra"] = {
	name = "Extra Indicators",
	type = "group",
	set = function(info, value)
		db.profile[info[#info - 1]][info[#info]] = value
		GridFrame:UpdateAllFrames()
	end,
	get = function(info)
		return db.profile[info[#info - 1]][info[#info]]
	end,
	args = {
		icon = {
			name = "Icon Indicators Options",
			desc = "Options related to icon indicators.",
			order = 300, width = "double",
			type = "group",
			args = {
				iconSize = {
					name = "Icon Size",
					desc = "Adjust the size of the icons.",
					order = 10, width = "double",
					type = "range", min = 5, max = 50, step = 1,
				},
				iconBorderSize = {
					name = "Icon Border Size",
					desc = "Adjust the size of the center icon's borders.",
					order = 20, width = "double",
					type = "range", min = 0, max = 9, step = 1,
				},
				margin = {
					name = "Margin",
					desc = "Adjust the indicators margin from the frame borders.",
					order = 25, width = "double",
					type = "range", softMin = 0, softMax = 20, step = 1,
				},
				spacing = {
					name = "Spacing",
					desc = "Adjust the spacing between the indicators.",
					order = 25, width = "double",
					type = "range", softMin = 0, softMax = 20, step = 1,
				},
				enableIconCooldown = {
					name = "Enable Icon Cooldown Frame",
					desc = "Toggle center icon's cooldown frame.",
					order = 30, width = "double",
					type = "toggle",
				},
				enableIconStackText = {
					name = "Enable Icon Stack Text",
					desc = "Toggle center icon's stack count text.",
					order = 40, width = "double",
					type = "toggle",
				},
				stackFontSize = {
					name = "Icon Stack Text Font Size",
					desc = "Adjust the font size of the icon stack text.",
					order = 20, width = "double",
					type = "range", min = 4, max = 24, step = 1,
				},				
			},
		},
		text = {
			name = "Text Indicators Options",
			desc = "Options related to text indicators.",
			order = 400,
			type = "group",
			args = {
				font = {
					name = "Font",
					desc = "Adjust the font settings",
					order = 10, width = "double",
					type = "select",
					values = Media:HashTable("font"),
					dialogControl = "LSM30_Font",
				},
				fontSize = {
					name = "Font Size",
					desc = "Adjust the font size.",
					order = 20, width = "double",
					type = "range", min = 6, max = 24, step = 1,
				},
				fontOutline = {
					name = "Font Outline",
					desc = "Adjust the font outline.",
					order = 30, width = "double",
					type = "select",
					values = {
						NONE = "None",
						OUTLINE = "Thin",
						THICKOUTLINE = "Thick",
					},
				},
				fontShadow = {
					name = "Font Shadow",
					desc = "Toggle the font drop shadow effect.",
					order = 40, width = "double",
					type = "toggle",
				},
				margin = {
					name = "Margin",
					desc = "Adjust the indicators margin from the frame borders.",
					order = 45, width = "double",
					type = "range", softMin = 0, softMax = 20, step = 1,
				},
				textlength = {
					name = "Text Length",
					desc = "Number of characters to show on the text indicators.",
					order = 50, width = "double",
					type = "range", min = 1, max = 12, step = 1,
				},
			},
		}
	}
}
