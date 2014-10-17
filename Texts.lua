local Grid = Grid
local GridFrame = Grid:GetModule("GridFrame")
local Media = LibStub("LibSharedMedia-3.0")
local db = Grid.db:GetNamespace("GridIndicatorExtra")

local strsub = string.utf8sub or string.sub

local function Text_NewIndicator(frame)
	local ind = CreateFrame("Frame", nil, frame)
	ind.text = ind:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
	ind.text:SetAllPoints()
	return ind
end

local function Text_ResetIndicator(self, justify_v, justify_h)
	local profile = db.profile.text
	local font = Media:Fetch("font", profile.font) or STANDARD_TEXT_FONT
	local fontSize = profile.fontSize
	local frame = self.__owner

	self:SetFrameLevel(frame.indicators.bar:GetFrameLevel() + 5)

	self.text:SetFont(font, fontSize, profile.fontOutline)

	if profile.fontShadow then
		self.text:SetShadowOffset(1, -1)
	else
		self.text:SetShadowOffset(0, 0)
	end

	if profile.invertBarColor and profile.invertTextColor then
		self.text:SetShadowColor(1, 1, 1)
	else
		self.text:SetShadowColor(0, 0, 0)
	end

	self.text:SetJustifyV(justify_v)
	self.text:SetJustifyH(justify_h)

	self:ClearAllPoints()
	self:SetPoint("TOPLEFT", self:GetParent(), "TOPLEFT", profile.margin, -profile.margin)
	self:SetPoint("BOTTOMRIGHT", self:GetParent(), "BOTTOMRIGHT", -profile.margin, profile.margin)
end

local function Text_SetStatus(self, color, text, value, maxValue, texture, texCoords, count, start, duration)
	local profile = db.profile.text
	
	if not text or text == "" then
		return self.text:SetText("")
	end

	self.text:SetText(strsub(text, 1, profile.textlength))

	if color then
		if profile.invertBarColor and profile.invertTextColor then
			self.text:SetTextColor(color.r * 0.2, color.g * 0.2, color.b * 0.2, color.a or 1)
		else
			self.text:SetTextColor(color.r, color.g, color.b, color.a or 1)
		end
	end
end

local function Text_ClearStatus(self)
	self.text:SetText("")
end

local function Text_RegisterIndicator(id, name, justify_v, justify_h)
	GridFrame:RegisterIndicator(id, name,
		Text_NewIndicator,
		function(self)
			Text_ResetIndicator(self, justify_v, justify_h)
		end,
		Text_SetStatus,
		Text_ClearStatus
	)
end

local prefix = "Extra Text: "

Text_RegisterIndicator("gie_text_topleft", prefix .. "Top Left", "TOP", "LEFT")
Text_RegisterIndicator("gie_text_topright", prefix .. "Top Right", "TOP", "RIGHT")
Text_RegisterIndicator("gie_text_botleft", prefix .. "Bottom Left", "BOTTOM", "LEFT")
Text_RegisterIndicator("gie_text_botright", prefix .. "Bottom Right", "BOTTOM", "RIGHT")


Text_RegisterIndicator("gie_text_top", prefix .. "Top", "TOP", "CENTER")
Text_RegisterIndicator("gie_text_bottom", prefix .. "Bottom", "BOTTOM", "CENTER")
Text_RegisterIndicator("gie_text_left", prefix .. "Left", "CENTER", "LEFT")
Text_RegisterIndicator("gie_text_right", prefix .. "Right", "CENTER", "RIGHT")
