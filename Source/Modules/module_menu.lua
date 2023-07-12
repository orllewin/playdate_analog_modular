--[[
	© 2023 Orllewin - All Rights Reserved.
]]

import 'Modules/mod_utils'
import 'CoracleViews/text_list'

class('ModuleMenu').extends(playdate.graphics.sprite)

local gfx <const> = playdate.graphics
local width = 180
local height = 132

function ModuleMenu:init(actions, xx, yy, w, h)
	ModuleMenu.super.init(self)
	
	self.actions = actions
	
	if w ~= nil then
		width = w
	end
	
	if h ~= nil then
		height = h
	end
	
	self.ww = width
	self.hh = height
	
	if playdate.display.getScale() == 2 then
		self.ww = 200
		self.hh = 120
	end
	
	local backgroundImage = generateModBackgroundWithShadow(self.ww, self.hh)	
	local bgW, bgH = backgroundImage:getSize()	
	self:setIgnoresDrawOffset(true)
	self:setImage(backgroundImage)
	
	if xx ~= nil and yy ~= nil then
		self:moveTo(xx, yy)
	else
		if playdate.display.getScale() == 1 then
			self:moveTo(305, 175)
		else
			self:moveTo(100, 60)
		end
	end
	
	self:setZIndex(gModuleMenuZ)
	
end

function ModuleMenu:show(onAction, selectedIndex)
	self:add()
	
	gScrollLock = true
	
	self.actionList = TextList(self.actions, self.x - self.ww/2 + 8, self.y - self.hh/2 + 8, self.ww - 16, self.hh-2, 18, nil, function(index)
		self:dismiss()
		local selectedAction = self.actions[index].label
		onAction(selectedAction, index)
	end, gModuleMenuZ + 1)
	
	self:setSelected(selectedIndex)
	
	self.actionMenuInputHandler = {
		
		BButtonDown = function()
			self:dismiss()
		end,
		
		AButtonDown = function()
			self.actionList:tapA()
		end,
		
		leftButtonDown = function()
	
		end,
		
		rightButtonDown = function()
	
		end,
		
		upButtonDown = function()
			self.actionList:goUp()
		end,
		
		downButtonDown = function()
			self.actionList:goDown()
		end
	}
	playdate.inputHandlers.push(self.actionMenuInputHandler )
end

function ModuleMenu:setSelected(index)
	self.actionList:setSelected(index)
end

function ModuleMenu:dismiss()
	playdate.inputHandlers.pop()
	gScrollLock = false
	self.actionList:removeAll()
	self:remove()
end