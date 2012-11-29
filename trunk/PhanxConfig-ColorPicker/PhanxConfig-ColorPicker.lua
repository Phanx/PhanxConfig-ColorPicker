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

local OnClick, OnEnter, OnLeave, GetValue, SetValue

function OnClick(self)
	OnLeave(self)
	if ColorPickerFrame:IsShown() then
		ColorPickerFrame:Hide()
	else
		self.r, self.g, self.b, self.opacity = self:GetValue()
		OpenColorPicker(self)
		ColorPickerFrame:SetFrameStrata("TOOLTIP")
		ColorPickerFrame:Raise()
	end
end

function OnEnter(self)
	local color = NORMAL_FONT_COLOR
	self.bg:SetVertexColor(color.r, color.g, color.b)

	if self.desc then
		GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
		GameTooltip:SetText(self.desc, nil, nil, nil, nil, true)
	end
end

function OnLeave(self)
	local color = HIGHLIGHT_FONT_COLOR
	self.bg:SetVertexColor(color.r, color.g, color.b)

	GameTooltip:Hide()
end

function GetValue(self)
	local r, g, b, a = self.swatch:GetVertexColor()
	return floor(r * 100 + 0.5) / 100, floor(g * 100 + 0.5) / 100, floor(b * 100 + 0.5) / 100, floor(a * 100 + 0.5) / 100
end

function SetValue(self, r, g, b, a)
	r = floor(r * 100 + 0.5) / 100
	g = floor(g * 100 + 0.5) / 100
	b = floor(b * 100 + 0.5) / 100
	a = a and self.hasOpacity and (floor(a * 100 + 0.5) / 100) or 1

	self.swatch:SetVertexColor(r, g, b, a)
	self.bg:SetAlpha(a)

	if self.OnValueChanged then
		self:OnValueChanged(r, g, b, a)
	else
		-- deprecated
		if self.OnColorChanged then
			-- use this for immediate visual updating
			self:OnColorChanged(r, g, b, a)
		end
		if not ColorPickerFrame:IsShown() and self.PostColorChanged then
			-- use this for final updating after the color picker closes
			self:PostColorChanged(r, g, b, a)
		end
	end
end

function lib.CreateColorPicker(parent, name, desc, hasOpacity)
	assert( type(parent) == "table" and parent.CreateFontString, "PhanxConfig-ColorPicker: Parent is not a valid frame!" )
	if type(name) ~= "string" then name = nil end
	if type(desc) ~= "string" then desc = nil end

	local frame = CreateFrame("Button", nil, parent)
	frame:SetHeight(26)

	local swatch = frame:CreateTexture(nil, "OVERLAY")
	swatch:SetTexture("Interface\\ChatFrame\\ChatFrameColorSwatch")
	swatch:SetPoint("LEFT", 5, 1)
	swatch:SetSize(17, 18)
	frame.swatch = swatch

	local bg = frame:CreateTexture(nil, "BACKGROUND")
	bg:SetTexture(1, 1, 1)
	bg:SetPoint("LEFT", 5, 1)
	bg:SetSize(16, 16)
	frame.bg = bg

	local label = frame:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
	label:SetPoint("LEFT", swatch, "RIGHT", 7, 0)
	label:SetHeight(19)
	label:SetText(name)
	frame.label = label

	frame:SetWidth(math.min(186, math.max(5 + 16 + 7 + label:GetStringWidth(), 100)))
	frame:SetMotionScriptsWhileDisabled(true)

	frame:SetScript("OnClick", OnClick)
	frame:SetScript("OnEnter", OnEnter)
	frame:SetScript("OnLeave", OnLeave)

	frame.SetColor = SetValue -- deprecated

	frame.desc = desc
	frame.GetValue = GetValue
	frame.SetValue = SetValue
	frame.cancelFunc = function()
		frame:SetValue(frame.r, frame.g, frame.b, frame.hasOpacity and frame.opacity or 1)
	end
	frame.hasOpacity = hasOpacity
	frame.opacityFunc = function()
		local r, g, b = ColorPickerFrame:GetColorRGB()
		local a = OpacitySliderFrame:GetValue()
		frame:SetValue(r, g, b, a)
	end
	frame.swatchFunc = function()
		local r, g, b = ColorPickerFrame:GetColorRGB()
		local a = OpacitySliderFrame:GetValue()
		frame:SetValue(r, g, b, a)
	end

	return frame
end