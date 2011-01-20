--[[--------------------------------------------------------------------
	PhanxConfig-ColorPicker
	Simple color picker widget generator.
	Based on OmniCC_Options by Tuller.
	Requires LibStub.

	This library is not intended for use by other authors. Absolutely no
	support of any kind will be provided for other authors using it, and
	its internals may change at any time without notice.
----------------------------------------------------------------------]]

local MINOR_VERSION = tonumber(("$Revision$"):match("%d+"))

local lib, oldminor = LibStub:NewLibrary("PhanxConfig-ColorPicker", MINOR_VERSION)
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
		if self.GetColor then
			self.r, self.g, self.b = self:GetColor()
		else
			local r, g, b = self.swatch:GetVertexColor()
			r = math.floor(r * 100 + 0.5) / 100
			b = math.floor(g * 100 + 0.5) / 100
			b = math.floor(b * 100 + 0.5) / 100
			self.r, self.g, self.b = r, g, b
		end

		UIDropDownMenuButton_OpenColorPicker(self)
		ColorPickerFrame:SetFrameStrata("TOOLTIP")
		ColorPickerFrame:Raise()
	end
end

local function SetColor(self, r, g, b)
	self.swatch:SetVertexColor(r, g, b)
	if self.OnColorChanged then
		-- use this for immediate visual updating
		self:OnColorChanged(r, g, b)
	end
	if not ColorPickerFrame:IsShown() and self.PostColorChanged then
		-- use this for final updating after the color picker closes
		self:PostColorChanged(r, g, b)
	end
end

function lib.CreateColorPicker(parent, name)
	local frame = CreateFrame("Button", nil, parent)
	frame:SetHeight(19)

	local swatch = frame:CreateTexture(nil, "OVERLAY")
	swatch:SetTexture("Interface\\ChatFrame\\ChatFrameColorSwatch")
	swatch:SetPoint("LEFT")
	swatch:SetWidth(19)
	swatch:SetHeight(19)
	frame.swatch = swatch

	local bg = frame:CreateTexture(nil, "BACKGROUND")
	bg:SetTexture(1, 1, 1)
	bg:SetPoint("CENTER", swatch)
	bg:SetWidth(16)
	bg:SetHeight(16)
	frame.bg = bg

	local label = frame:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
	label:SetPoint("LEFT", swatch, "RIGHT", 4, 1)
	label:SetHeight(19)
	label:SetText(name)
	frame.label = label

	local width = math.max( 19 + 4 + label:GetStringWidth(), 100 )
	frame:SetWidth(width)

	frame.SetColor = SetColor
	frame.swatchFunc = function() frame:SetColor( ColorPickerFrame:GetColorRGB() ) end
	frame.cancelFunc = function() frame:SetColor( frame.r, frame.g, frame.b ) end

	frame:SetScript("OnClick", OnClick)
	frame:SetScript("OnEnter", OnEnter)
	frame:SetScript("OnLeave", OnLeave)

	return frame
end