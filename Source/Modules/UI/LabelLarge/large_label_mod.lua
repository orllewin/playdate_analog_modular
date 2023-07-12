--[[
	© 2023 Orllewin - All Rights Reserved.
]]

import 'Modules/mod_utils.lua'
import 'Modules/ClockDoubler/clock_doubler_component'
import 'Modules/Sprites/bang_sprite'
import 'Modules/mod_about_popup'
import 'Modules/module_menu'

class('LargeLabelMod').extends(playdate.graphics.sprite)

local gfx <const> = playdate.graphics

local maxLabelWidth = 160
local maxLabelHeight = 200
local moduleWidth = 80
local moduleHeight = 20

local modType = "LargeLabelMod"
local modSubtype = "other"

function LargeLabelMod:init(xx, yy, modId)
	LargeLabelMod.super.init(self)
	
	if modId == nil then
		self.modId = modType .. playdate.getSecondsSinceEpoch()
	else
		self.modId = modId
	end
	
	self.modType = modType
	self.modSubtype = modSubtype
	
	self.label = "A"
	
	local labelImage = gfx.imageWithText(self.label, maxLabelWidth, maxLabelHeight)
	local labelW, labelH = labelImage:getSize()
	
	self.moduleWidth = labelW +10
	self.moduleHeight = labelH + 10
	
	self:redraw(self.label)
	self:moveTo(xx, yy)
	self:add()
end

function LargeLabelMod:setLabel(label)
	self:redraw(label)
end

function LargeLabelMod:redraw(label)
	self.label = label
	
	--playdate.graphics.imageWithText(text, maxWidth, maxHeight, [backgroundColor, [leadingAdjustment, [truncationString, [alignment, [font]]]]])
	local labelImage = gfx.imageWithText(self.label, maxLabelWidth, maxLabelHeight, playdate.graphics.kColorClear, nil, nil, nil, gBigFont)
	local labelW, labelH = labelImage:getSize()
	
	self.moduleWidth = labelW + 20
	self.moduleHeight = labelH + 20
	
	local backgroundImage = generateModBackgroundNoBorder(self.moduleWidth,	self.moduleHeight)
	local bgW, bgH = backgroundImage:getSize()
	gfx.pushContext(backgroundImage)
	labelImage:drawFaded((bgW-labelW)/2, (bgH - labelH)/2, 0.5, gfx.image.kDitherTypeBayer4x4)
	gfx.popContext()
	
	self:setImage(backgroundImage)
end

function LargeLabelMod:type()
	return modType
end

function LargeLabelMod:handleModClick(tX, tY, listener)
	self.menuListener = listener
	local actions = {
		{label = "About"},
		{label = "Edit"},
		{label = "Remove"}
	}
	local contextMenu = ModuleMenu(actions)
	contextMenu:show(function(action) 
		if action == "About" then
			local aboutPopup = ModAboutPopup("An on-screen label with a large typeface.")
			aboutPopup:show()
		elseif action == "Edit" then
			self.textInputScreen = TextInputScreen(self.label)
			gModularRunning = false
			self.textInputScreen:push("Edit label:", function(name)
				gModularRunning = true
				self:setLabel(name)
				self.textInputScreen = nil
			end)
		else
			if self.menuListener ~= nil then 
				self.menuListener(action) 
			end
		end
	end)
end

function LargeLabelMod:evaporate(onDetachConnected)
	self:remove()
end

function LargeLabelMod:collision(x, y)
	if x > self.x - (self.moduleWidth/2) and x < self.x + (self.moduleWidth/2) and y > self.y - (self.moduleHeight/2) and y < self.y + (self.moduleHeight/2) then
		return true
	else
		return false
	end
end

function LargeLabelMod.ghostModule()
	return buildGhostModule(100, 40)
end

function LargeLabelMod:toState()
	local modState = {}
	modState.modId = self.modId
	modState.type = self:type()
	modState.x = self.x
	modState.y = self.y
	
	modState.label = self.label
	
	return modState
end

function LargeLabelMod:fromState(modState)
	self:setLabel(modState.label)
end