--[[
	© 2023 Orllewin - All Rights Reserved.
]]

import 'Modules/mod_utils.lua'
import 'Modules/Arpeggiator/arp_component'
import 'Modules/mod_about_popup'
import 'Modules/module_menu'
import 'Modules/Sprites/sequencer_grid'

class('ArpMod').extends(playdate.graphics.sprite)

local gfx <const> = playdate.graphics

local moduleWidth = 350
local moduleHeight = 158

local modType = "ArpMod"
local modSubtype = "clock_router"

function ArpMod:init(xx, yy, modId)
	ArpMod.super.init(self)
	
	if modId == nil then
		self.modId = modType .. playdate.getSecondsSinceEpoch()
	else
		self.modId = modId
	end
	
	self.modType = modType
	self.modSubtype = modSubtype
	
	local backgroundImage = generateModBackgroundWithShadow(moduleWidth, moduleHeight)
	local bgW, bgH = backgroundImage:getSize()
	
	gfx.pushContext(backgroundImage)		
	
	gSocketInImage:draw(23, 19)
	gSocketOutImage:draw(bgW - 43, 19)
	
	gfx.popContext()
	
	self:setImage(backgroundImage)
	self:moveTo(xx, yy)
	self:add()
	
	self.grid = SequencerGrid(xx, yy)
	

	self.socketInVector = Vector(xx+1, yy - (bgH/2) + 38)
	self.socketOutVector = Vector(xx+1, yy - (bgH/2) + 130)
	
	self.arpComponent = ArpComponent()
	
	self.rateEncoder = RotaryEncoder(xx - (moduleWidth/2) + 20, yy, function(value)
		--1/1, 1/2, 1/4, etc take logic from Clock Delay
		--self.arpComponent:setRate(value)
	end)
	self.rateEncoder:setValue(0.5)
end

function ArpMod:collision(x, y)
	if x > self.x - (moduleWidth/2) and x < self.x + (moduleWidth/2) and y > self.y - (moduleHeight/2) and y < self.y + (moduleHeight/2) then
		return true
	else
		return false
	end
end

function ArpMod:type()
	return modType
end

function ArpMod.ghostModule()
	return buildGhostModule(moduleWidth, moduleHeight)
end

function ArpMod:handleModClick(tX, tY, listener)
	if self.grid:collision(tX, tY) then
		self.grid:onClick(tX, tY, function(pattern)
			--todo Update pattern!
			
		end)
	else
		self.menuListener = listener
		local actions = {
			{label = "About"},
			{label = "Remove"}
		}
		local contextMenu = ModuleMenu(actions)
		contextMenu:show(function(action) 
			if action == "About" then
				local aboutPopup = ModAboutPopup("A step sequencer")
				aboutPopup:show()
			else
				if self.menuListener ~= nil then 
					self.menuListener(action) 
				end
			end
	
		end)
	end
end

