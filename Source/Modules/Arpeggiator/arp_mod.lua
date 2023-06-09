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

local moduleWidth = 295
local moduleHeight = 218

local modType = "ArpMod"
local modSubtype = "clock_router"

local patternLengthSelector = gfx.image.new("Images/pattern_length_selector")
local backplate = gfx.image.new("images/seq_controls_backplate")

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
	
	gSocketInImage:draw(23, bgH - 60)
	gSocketOutImage:draw(bgW - 43, bgH - 60)
	patternLengthSelector:draw(200, 176)
	backplate:draw(58, 166)
	
	gfx.popContext()
	
	self:setImage(backgroundImage)
	self:moveTo(xx, yy)
	self:add()
	
	self.arpComponent = ArpComponent()
	
	self.grid = SequencerGrid(xx, yy-30, function(pattern)
		self.arpComponent:setPattern(pattern)
	end)
	
	local prevImage = gfx.image.new("Images/sq_pattern_prev_inactive")
	self.prevSprite = gfx.sprite.new(prevImage)
	self.prevSprite:moveTo(xx - 136, yy-31)
	self.prevSprite:add()
	
	local nextImage = gfx.image.new("Images/sq_pattern_next_inactive")
	self.nextSprite = gfx.sprite.new(nextImage)
	self.nextSprite:moveTo(xx + 134, yy-31)
	self.nextSprite:add()

	self.socketInVector = Vector(xx - (bgW/2) + 38, yy + (bgH/2) - 38)
	self.socketOutVector = Vector(xx + (bgW/2) - 38, yy + (bgH/2)- 38)

	self.rateEncoder = RotaryEncoder(xx - (moduleWidth/2) + 75, yy + 80, function(value)
		--1/1, 1/2, 1/4, etc take logic from Clock Delay
		local degrees = map(value, 0.0, 1.0, 0, 300)
		local rateIndex = math.max(1, math.floor((degrees/(300/3) + 0.5)))
		self.arpComponent:setRate(rateIndex - 3)
	end)
	self.rateEncoder:setValue(1.0)
	
	self.octaveEncoder = RotaryEncoder(xx, yy + 80, function(value)
		local degrees = map(value, 0.0, 1.0, 0, 300)
		local octaveIndex = math.max(1, math.floor((degrees/(300/5) + 0.5)))
		self.arpComponent:setOctave(math.floor(map(octaveIndex, 1, 5, -2, 2)))
	end)
	self.octaveEncoder:setValue(0.5)
	
	self.stepCountEncoder = RotaryEncoder(xx + (moduleWidth/2) - 75, yy + 80, function(value)
		local degrees = map(value, 0.0, 1.0, 0, 300)
		local stepLengthIndex = math.max(1, math.floor((degrees/(300/5) + 0.5)))
		self.arpComponent:setPatternLength(stepLengthIndex * 16)
		self.grid:setPattern(self.arpComponent:getPattern(), self.arpComponent:getPatternLength())
	end)
	self.stepCountEncoder:setValue(0.0)
	
	self.encoders = {
		self.rateEncoder,
		self.octaveEncoder,
		self.stepCountEncoder 
	}
end

function ArpMod:collision(x, y)
	if x > self.x - (moduleWidth/2) and x < self.x + (moduleWidth/2) and y > self.y - (moduleHeight/2) and y < self.y + (moduleHeight/2) then
		return true
	else
		return false
	end
end

function ArpMod:findClosestEncoder(x, y)
	local reticleVector = Vector(x, y)
	local closestDistance = 1000
	local closestIndex = -1
	for i=1,#self.encoders do
		local anEncoder = self.encoders[i]
		local encoderVector = Vector(anEncoder.x, anEncoder.y)
		local distance = reticleVector:distance(encoderVector)
		if distance < closestDistance then
			closestDistance = distance
			closestIndex = i
		end
	end
	
	return self.encoders[closestIndex]
end

function ArpMod:turn(x, y, change)
	local encoder = self:findClosestEncoder(x, y)
	encoder:turn(change)
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

function ArpMod.ghostModule()
	return buildGhostModule(moduleWidth, moduleHeight)
end

function ArpMod:tryConnectGhostIn(x, y, ghostCable)
	ghostCable:setEnd(self.socketInVector.x, self.socketInVector.y)
	ghostCable:setGhostReceiveConnected()
	return true
end

function ArpMod:tryConnectGhostOut(x, y, ghostCable)
	ghostCable:setStart(self.socketOutVector.x, self.socketOutVector.y)
	ghostCable:setGhostSendConnected()
	return true
end

function ArpMod:setInCable(patchCable)
	patchCable:setEnd(self.socketInVector.x, self.socketInVector.y, self.modId)
	self.inCable = patchCable
	self.arpComponent:setInCable(patchCable:getCable())
end

function ArpMod:setOutCable(patchCable)
	patchCable:setEnd(self.socketOutVector.x, self.socketOutVector.y, self.modId)
	self.outCable = patchCable
	self.arpComponent:setOutCable(patchCable:getCable())
end

