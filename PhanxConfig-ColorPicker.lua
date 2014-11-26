--[[--------------------------------------------------------------------
	PhanxConfig-ColorPicker
	Simple color picker widget generator. Requires LibStub.
	Based on OmniCC_Options by Tuller.
	https://github.com/Phanx/PhanxConfig-ColorPicker

	Copyright (c) 2009-2014 Phanx <addons@phanx.net>. All rights reserved.

	Permission is granted for anyone to use, read, or otherwise interpret
	this software for any purpose, without any restrictions.

	Permission is granted for anyone to embed or include this software in
	another work not derived from this software that makes use of the
	interface provided by this software for the purpose of creating a
	package of the work and its required libraries, and to distribute such
	packages as long as the software is not modified in any way, including
	by modifying or removing any files.

	Permission is granted for anyone to modify this software or sample from
	it, and to distribute such modified versions or derivative works as long
	as neither the names of this software nor its authors are used in the
	name or title of the work or in any other way that may cause it to be
	confused with or interfere with the simultaneous use of this software.

	This software may not be distributed standalone or in any other way, in
	whole or in part, modified or unmodified, without specific prior written
	permission from the authors of this software.

	The names of this software and/or its authors may not be used to
	promote or endorse works derived from this software without specific
	prior written permission from the authors of this software.

	THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
	EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
	MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
	IN NO EVENT SHALL THE AUTHORS BE LIABLE FOR ANY CLAIM, DAMAGES OR
	OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE,
	ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
	OTHER DEALINGS IN THE SOFTWARE.
----------------------------------------------------------------------]]

local MINOR_VERSION = 176

local lib, oldminor = LibStub:NewLibrary("PhanxConfig-ColorPicker", MINOR_VERSION)
if not lib then return end

------------------------------------------------------------------------

local scripts = {}

function scripts:OnClick()
	if ColorPickerFrame:IsShown() then
		ColorPickerFrame:Hide()
	else
		self.r, self.g, self.b, self.opacity = self:GetValue()
		OpenColorPicker(self)
		ColorPickerFrame:SetFrameStrata("TOOLTIP")
		ColorPickerFrame:Raise()
	end
end

function scripts:OnEnter()
	local color = NORMAL_FONT_COLOR
	self.bg:SetVertexColor(color.r, color.g, color.b)
	if self.tooltipText then
		GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
		GameTooltip:SetText(self.tooltipText, nil, nil, nil, nil, true)
	end
end
function scripts:OnLeave()
	local color = HIGHLIGHT_FONT_COLOR
	self.bg:SetVertexColor(color.r, color.g, color.b)
	GameTooltip:Hide()
end

------------------------------------------------------------------------

local methods = {}

function methods:GetValue()
	local r, g, b, a = self.swatch:GetVertexColor()
	return floor(r * 100 + 0.5) / 100, floor(g * 100 + 0.5) / 100, floor(b * 100 + 0.5) / 100, floor(a * 100 + 0.5) / 100
end
function methods:SetValue(r, g, b, a)
	if type(r) == "table" then
		r, g, b, a = r.r or r[1], r.g or r[2], r.b or r[3], r.a or r[4]
	end

	r = floor(r * 100 + 0.5) / 100
	g = floor(g * 100 + 0.5) / 100
	b = floor(b * 100 + 0.5) / 100
	a = a and self.hasOpacity and (floor(a * 100 + 0.5) / 100) or 1

	self.swatch:SetVertexColor(r, g, b, a)
	self.bg:SetAlpha(a)


	local callback = self.Callback or self.OnValueChanged
	if callback then
		-- Ignore updates while ColorPickerFrame:IsShown() if desired.
		callback(self, r, g, b, a)
	end
end

function methods:GetLabel()
	return self.labelText:GetText()
end
function methods:SetLabel(text)
	self.labelText:SetText(text)
end

function methods:GetTooltip()
	return self.tooltipText
end
function methods:SetTooltip(text)
	self.tooltipText = text
end

------------------------------------------------------------------------

function lib:New(parent, name, tooltipText, hasOpacity)
	assert(type(parent) == "table" and parent.CreateFontString, "PhanxConfig-ColorPicker: Parent is not a valid frame!")
	if type(name) ~= "string" then name = nil end
	if type(tooltipText) ~= "string" then tooltipText = nil end

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
	frame.labelText = label

	frame:SetMotionScriptsWhileDisabled(true)
	for name, func in pairs(scripts) do
		frame[name] = func
		frame:SetScript(name, func)
	end
	for name, func in pairs(methods) do
		frame[name] = func
	end

	frame.hasOpacity = hasOpacity
	frame.cancelFunc = function()
		frame:SetValue(frame.r, frame.g, frame.b, frame.hasOpacity and frame.opacity or 1)
	end
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

	label:SetText(name)
	frame.tooltipText = tooltipText
	frame:SetWidth(math.min(186, math.max(5 + 16 + 7 + label:GetStringWidth(), 100)))
	return frame
end

function lib.CreateColorPicker(...) return lib:New(...) end