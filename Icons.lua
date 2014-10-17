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
	icon:SetBackdrop(BACKDROP)

	local texture = icon:CreateTexture(nil, "ARTWORK")
	texture:SetPoint("BOTTOMLEFT", 2, 2)
	texture:SetPoint("TOPRIGHT", -2, -2)
	icon.texture = texture

	local text = icon:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
	text:SetPoint("BOTTOMRIGHT", 2, 2)
	text:SetJustifyH("RIGHT")
	text:SetJustifyV("BOTTOM")
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

local function Icon_ResetIndicator(self, point, second)
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

	self:ClearAllPoints()

	local is_left = string.match(point, "LEFT") and 1 or -1
	local is_top = string.match(point, "TOP") and -1 or 1
	if second then
		self:SetPoint(point, is_left * (totalSize + profile.margin + profile.spacing), is_top * profile.margin)
	else
		self:SetPoint(point, is_left * profile.margin, is_top * profile.margin)
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

	self.text:SetFont(font, fontSize, "OUTLINE")	
end

local function Icon_SetStatus(self, color, text, value, maxValue, texture, texCoords, stack, start, duration)
	if not texture then return end

	local profile = db.profile.icon

	if type(texture) == "table" then
		self.texture:SetTexture(texture.r, texture.g, texture.b, texture.a or 1)
	else
		self.texture:SetTexture(texture)
		self.texture:SetTexCoord(texCoords.left, texCoords.right, texCoords.top, texCoords.bottom)
	end

	if type(color) == "table" then
		self:SetAlpha(color.a or 1)
		self:SetBackdropBorderColor(color.r, color.g, color.b, color.ignore and 0 or color.a or 1)
	else
		self:SetAlpha(1)
		self:SetBackdropBorderColor(0, 0, 0, 0)
	end

	if profile.enableIconCooldown and type(duration) == "number" and duration > 0 and type(start) == "number" and start > 0 then
		self.cooldown:SetCooldown(start, duration)
		self.cooldown:Show()
	else
		self.cooldown:Hide()
	end

	if profile.enableIconStackText and stack and stack ~= 0 then
		self.text:SetText(stack)
	else
		self.text:SetText("")
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

local function Icon_RegisterIndicator(id, name, point, second)
	GridFrame:RegisterIndicator(id, name,
		Icon_NewIndicator,
		function(self)
			Icon_ResetIndicator(self, point)
		end,
		Icon_SetStatus,
		Icon_ClearStatus
	)

	if second then
		GridFrame:RegisterIndicator(id .. "2", name .. " 2",
			Icon_NewIndicator,
			function(self)
				Icon_ResetIndicator(self, point, second)
			end,
			Icon_SetStatus,
			Icon_ClearStatus
		)
	end
end

local prefix = "Extra Icon: "

Icon_RegisterIndicator("gie_icon_topleft", prefix .. "Top Left", "TOPLEFT", true)
Icon_RegisterIndicator("gie_icon_botleft", prefix .. "Bottom Left", "BOTTOMLEFT", true)
Icon_RegisterIndicator("gie_icon_topright", prefix .. "Top Right", "TOPRIGHT", true)
Icon_RegisterIndicator("gie_icon_botright", prefix .. "Bottom Right", "BOTTOMRIGHT", true)

Icon_RegisterIndicator("gie_icon_top", prefix .. "Top", "TOP")
Icon_RegisterIndicator("gie_icon_bottom", prefix .. "Bottom", "BOTTOM")
Icon_RegisterIndicator("gie_icon_left", prefix .. "Left", "LEFT", true)
Icon_RegisterIndicator("gie_icon_right", prefix .. "Right", "RIGHT", true)
