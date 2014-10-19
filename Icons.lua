local Grid = Grid
local GridFrame = Grid:GetModule("GridFrame")
local Media = LibStub("LibSharedMedia-3.0")
local db = Grid.db:GetNamespace("GridIndicatorExtra")

local BACKDROP = {
	edgeFile = "Interface\\BUTTONS\\WHITE8X8", edgeSize = 2,
	insets = { left = 2, right = 2, top = 2, bottom = 2 },
}

local function Icon_NewIndicator(frame)
	local icon = CreateFrame("Button", nil, frame)
	icon:EnableMouse(false)
	icon:SetBackdrop(BACKDROP)

	local texture = icon:CreateTexture(nil, "ARTWORK")
	texture:SetPoint("BOTTOMLEFT", 2, 2)
	texture:SetPoint("TOPRIGHT", -2, -2)
	icon.texture = texture

	local text = icon:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
	text:SetJustifyH("CENTER")
	text:SetJustifyV("CENTER")
	icon.text = text

	local cd = CreateFrame("Cooldown", nil, icon, "CooldownFrameTemplate")
	cd:SetAllPoints(true)
	cd:SetReverse(true)
	icon.cooldown = cd

	cd:SetScript("OnShow", function()
		text:SetParent(cd)
	end)
	cd:SetScript("OnHide", function()
		text:SetParent(icon)
	end)

	return icon
end

local function Icon_ResetIndicator(self, point, idx)
	local profile = db.profile.icon
	local font = Media:Fetch("font", db.profile.text.font) or STANDARD_TEXT_FONT
	local fontSize = profile.stackFontSize
	local iconSize = profile.iconSize
	local iconBorderSize = profile.iconBorderSize
	local totalSize = iconSize + (iconBorderSize * 2)
	local frame = self.__owner
	local r, g, b, a = self:GetBackdropBorderColor()

	self:SetFrameLevel(frame.indicators.bar:GetFrameLevel() + 1)
	self:SetWidth(totalSize)
	self:SetHeight(totalSize)


	-- positioning
	self:ClearAllPoints()

	local is_side = point == "TOP" or point == "BOTTOM" or point == "LEFT" or point == "RIGHT"
	local is_left = string.match(point, "LEFT") and 1 or string.match(point, "RIGHT") and -1 or 0
	local is_top = string.match(point, "TOP") and -1 or string.match(point, "BOTTOM") and 1 or 0

	local m = profile.margin
	local ts = totalSize + profile.spacing
	local mts = profile.margin + totalSize + profile.spacing

	if idx == 1 then
		self:SetPoint(point, is_left * m, is_top * m)
	elseif idx == 2 then
		if point == "TOP" or point == "BOTTOM" then
			self:SetPoint(point, 0, is_top * mts)
		else
			self:SetPoint(point, is_left * mts, is_top * m)
		end
	elseif idx == 3 then
		if point == "TOP" or point == "BOTTOM" then
			self:SetPoint(point, -ts, is_top * m)
		elseif point == "LEFT" or point == "RIGHT" then
			self:SetPoint(point, is_left * m, ts)
		else
			self:SetPoint(point, is_left * m, is_top * mts)
		end
	elseif idx == 4 then
		if point == "TOP" or point == "BOTTOM" then
			self:SetPoint(point, ts, is_top * m)
		elseif point == "LEFT" or point == "RIGHT" then
			self:SetPoint(point, is_left * m, -ts)
		else
			self:SetPoint(point, is_left * mts, is_top * mts)
		end
	end

	if iconBorderSize == 0 then
		self:SetBackdrop(nil)
	else
		BACKDROP.edgeSize = iconBorderSize
		BACKDROP.insets.left = iconBorderSize
		BACKDROP.insets.right = iconBorderSize
		BACKDROP.insets.top = iconBorderSize
		BACKDROP.insets.bottom = iconBorderSize
		
		self:SetBackdrop(BACKDROP)
		self:SetBackdropBorderColor(r, g, b, a)
	end

	self.texture:SetPoint("BOTTOMLEFT", iconBorderSize, iconBorderSize)
	self.texture:SetPoint("TOPRIGHT", -iconBorderSize, -iconBorderSize)

	self.text:SetPoint("CENTER", profile.stackOffsetX, profile.stackOffsetY)
	self.text:SetFont(font, fontSize, "OUTLINE")
end

local function Icon_SetStatus(self, color, text, value, maxValue, texture, texCoords, stack, start, duration)
	local profile = db.profile.icon

	if type(texture) == "table" then
		self.texture:SetTexture(texture.r, texture.g, texture.b, texture.a or 1)
	elseif texture ~= nil then
		self.texture:SetTexture(texture)
		self.texture:SetTexCoord(texCoords.left, texCoords.right, texCoords.top, texCoords.bottom)
	elseif type(color) == "table" then
		self.texture:SetTexture(color.r, color.g, color.b, color.ignore and 0 or color.a or 1)
	else
		self.texture:SetTexture(0, 0, 0, 0)
	end

	if type(color) == "table" then
		self:SetAlpha(color.a or 1)
		self:SetBackdropBorderColor(color.r, color.g, color.b, color.ignore and 0 or color.a or 1)
	else
		self:SetAlpha(1)
		self:SetBackdropBorderColor(0, 0, 0, 0)
	end

	if profile.enableIconCooldown and type(duration) == "number" and duration > 0 and type(start) == "number" and start > 0 then
		self.cooldown:Show()
		self.cooldown:SetCooldown(start, duration)
	else
		self.cooldown:Hide()
	end

	if profile.enableIconStackText and stack and stack > 1 then
		self.text:SetText(stack)
		self.text:Show()
	else
		self.text:Hide()
	end
	
	self:Show()
end

local function Icon_ClearStatus(self)
	self:Hide()

	self.texture:SetTexture(1, 1, 1, 0)
	self.texture:SetTexCoord(0, 1, 0, 1)

	self.text:SetText("")
	self.text:SetTextColor(1, 1, 1, 1)

	self.cooldown:Hide()
end

local function Icon_RegisterIndicator_Int(id, name, point, idx)
	GridFrame:RegisterIndicator(id .. (idx == 1 and "" or tostring(idx)), name .. (idx == 1 and "" or (" " .. tostring(idx))),
		Icon_NewIndicator,
		function(self)
			Icon_ResetIndicator(self, point, idx)
		end,
		Icon_SetStatus,
		Icon_ClearStatus
	)
end

local function Icon_RegisterIndicator(id, name, point, more1, more2)
	Icon_RegisterIndicator_Int(id, name, point, 1)

	if more1 then
		Icon_RegisterIndicator_Int(id, name, point, 2)
	end

	if more2 then
		Icon_RegisterIndicator_Int(id, name, point, 3)
		Icon_RegisterIndicator_Int(id, name, point, 4)
	end
end

local more1 = db.profile.icon.more1
local more2 =  db.profile.icon.more2
local prefix = "Extra Icon: "

Icon_RegisterIndicator("gie_icon_topleft", prefix .. "Top Left", "TOPLEFT", more1, more2)
Icon_RegisterIndicator("gie_icon_botleft", prefix .. "Bottom Left", "BOTTOMLEFT", more1, more2)
Icon_RegisterIndicator("gie_icon_topright", prefix .. "Top Right", "TOPRIGHT", more1, more2)
Icon_RegisterIndicator("gie_icon_botright", prefix .. "Bottom Right", "BOTTOMRIGHT", more1, more2)

Icon_RegisterIndicator("gie_icon_top", prefix .. "Top", "TOP", more1, more2)
Icon_RegisterIndicator("gie_icon_bottom", prefix .. "Bottom", "BOTTOM", more1, more2)
Icon_RegisterIndicator("gie_icon_left", prefix .. "Left", "LEFT", more1, more2)
Icon_RegisterIndicator("gie_icon_right", prefix .. "Right", "RIGHT", more1, more2)
