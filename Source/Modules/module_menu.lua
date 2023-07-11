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
	
	local backgroundImage = generateModBackgroundWithShadow(width, height)	
	local bgW, bgH = backgroundImage:getSize()	
	self:setIgnoresDrawOffset(true)
	self:setImage(backgroundImage)
	
	if xx ~= nil and yy ~= nil then
		self:moveTo(xx, yy)
	else
		self:moveTo(305, 175)
	end
	
	self:setZIndex(gModuleMenuZ)
	
end

function ModuleMenu:show(onAction, selectedIndex)
	self:add()
	
	gScrollLock = true
	
	self.actionList = TextList(self.actions, self.x - width/2 + 8, self.y - height/2 + 8, width - 16, height-2, 18, nil, function(index)
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