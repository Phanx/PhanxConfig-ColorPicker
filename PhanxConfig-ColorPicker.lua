--[[--------------------------------------------------------------------
	PhanxConfig-ColorPicker
	Simple color picker widget generator.
	Based on OmniCC_Options by Tuller.
	Requires LibStub.
----------------------------------------------------------------------]]

local lib, oldminor = LibStub:NewLibrary("PhanxConfig-ColorPicker", 2)
if not lib then return end

local function OnEnter(self)
	local color = NORMAL_FONT_COLOR
	self.bg:SetVertexColor(color.r, color.g, color.b)

	if self.desc then
		GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
		GameTooltip:SetText(self.desc, nil, nil, nil, nil, true)
	end
end

local function OnLeave(self)
	local color = HIGHLIGHT_FONT_COLOR
	self.bg:SetVertexColor(color.r, color.g, color.b)

	GameTooltip:Hide()
end

local function OnClick(self)
	OnLeave(self)

	if ColorPickerFrame:IsShown() then
		ColorPickerFrame:Hide()
	else
		self.r, self.g, self.b = self:GetValue()

		UIDropDownMenuButton_OpenColorPicker(self)
		ColorPickerFrame:SetFrameStrata("TOOLTIP")
		ColorPickerFrame:Raise()
	end
end

local function SetColor(self, r, g, b)
	self.swatch:SetVertexColor(r, g b)
	if not ColorPickerFrame:IsShown() then
		self:SetValue(r, g, b)
	end
end

function lib.CreateColorPicker(parent, name)
	local frame = CreateFrame("Button", nil, parent)
	frame:SetHeight(19)
	frame:SetWidth(100)

	local swatch = frame:CreateTexture(nil, "OVERLAY")
	swatch:SetTexture("Interface\\ChatFrame\\ChatFrameColorSwatch")
	swatch:SetPoint("LEFT")
	swatch:SetWidth(19)
	swatch:SetHeight(19)

	local bg = frame:CreateTexture(nil, "BACKGROUND")
	bg:SetTexture(1, 1, 1)
	bg:SetPoint("CENTER", swatch)
	bg:SetWidth(16)
	bg:SetHeight(16)

	local label = frame:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
	label:SetPoint("LEFT", swatch, "RIGHT", 4, 1)
	label:SetHeight(19)
	label:SetText(name)

	frame.SetColor = SetColor
	frame.swatchFunc = function() frame:SetColor(ColorPickerFrame:GetColorRGB()) end
	frame.cancelFunc = function() frame:SetColor(frame.r, frame.g, frame.b) end

	frame:SetScript("OnClick", OnClick)
	frame:SetScript("OnEnter", OnEnter)
	frame:SetScript("OnLeave", OnLeave)

	local width = 19 + 4 + label:GetStringWidth()
	if width > 100 then
		frame:SetWidth(width)
	end

	frame.swatch = swatch
	frame.bg = bg
	frame.label = label

	return frame
end