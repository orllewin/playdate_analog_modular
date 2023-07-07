--[[
	© 2023 Orllewin - All Rights Reserved.
]]

import 'Modules/mod_utils.lua'
import 'Modules/Effects/RingModulator/ring_modulator_component'
import 'Modules/mod_about_popup'
import 'Modules/module_menu'
import 'Coracle/math'
import 'CoracleViews/rotary_encoder'

class('RingModulatorMod').extends(playdate.graphics.sprite)

local gfx <const> = playdate.graphics

local moduleWidth = 70
local moduleHeight = 96

local modType = "RingModulatorMod"
local modSubtype = "audio_effect"

function RingModulatorMod:init(xx, yy, modId)
	RingModulatorMod.super.init(self)
	
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
	gfx.drawTextAligned("RingMod", bgW/2, 19, kTextAlignment.center)
	
	local mixImage = gfx.image.new("Images/mix")
	mixImage:draw(bgW/2 + 10, 32)
	
	gSocketInImage:draw(20, 30)
	gSocketOutImage:draw(58, 74)
	
	gfx.popContext()
	
	self:setImage(backgroundImage)
	self:moveTo(xx, yy)
	self:add()
	
	self.ringModComponent = RingModulatorComponent(function() 
	
	end)

	self.mixEncoder = RotaryEncoder(xx + (moduleWidth/2) - 18, yy - (moduleHeight/2) + 40, function(value) 
		self.ringModComponent:setMix(value)
	end)
	self.mixEncoder:setValue(0.5)

	self.cutoffFreqLabelSprite = gfx.sprite.spriteWithText("50%", moduleWidth, moduleHeight)
	self.cutoffFreqLabelSprite:moveTo(xx - (moduleWidth/2) +18, yy - (moduleHeight/2) + 52)
	self.cutoffFreqLabelSprite:add()

	self.frequencyEncoder = RotaryEncoder(xx - (moduleWidth/2) + 18, yy + 32, function(value) 
		self.ringModComponent:setFrequency(value)
		self.cutoffFreqLabelSprite:remove()
		self.cutoffFreqLabelSprite = gfx.sprite.spriteWithText(""..round(value, 2), moduleWidth, moduleHeight)
		self.cutoffFreqLabelSprite:moveTo(xx - (moduleWidth/2) + 18, yy + 16)
		self.cutoffFreqLabelSprite:add()
	end)
	self.frequencyEncoder:setValue(0.0)

	self.encoders = {
		self.mixEncoder,
		self.frequencyEncoder
	}

	self.socketInVector = Vector(xx - (moduleWidth/2) + 16, yy - (moduleHeight/2) + 32)
	self.socketOutVector = Vector(xx + (moduleWidth/2) - 16, yy + (moduleHeight/2) - 20)

end

function RingModulatorMod:turn(x, y, change)
	local encoder = self:findClosestEncoder(x, y)
	encoder:turn(change)
end

function RingModulatorMod:findClosestEncoder(x, y)
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

function RingModulatorMod:updatePosition()
	self:moveBy(globalXDrawOffset, globalYDrawOffset)
end

function RingModulatorMod:getHostAudioModId()
	return self.hostAudioModId
end

function RingModulatorMod:setInCable(patchCable)
	patchCable:setEnd(self.socketInVector.x, self.socketInVector.y, self.modId)
	self.inCable = patchCable
	self.hostAudioModId = patchCable:getHostAudioModId()
	self.ringModComponent:setInCable(patchCable:getCable())
end

function RingModulatorMod:setOutCable(patchCable)
	self.outCable = patchCable
	patchCable:setStart(self.socketOutVector.x, self.socketOutVector.y, self.modId)
	self.ringModComponent:setOutCable(patchCable:getCable())
end

function RingModulatorMod:collision(x, y)
	if x > self.x - (moduleWidth/2) and x < self.x + (moduleWidth/2) and y > self.y - (moduleHeight/2) and y < self.y + (moduleHeight/2) then
		return true
	else
		return false
	end
end

function RingModulatorMod:tryConnectGhostIn(x, y, ghostCable)
	if ghostCable:getStartModId() == self.modId then
		print("Can't connect a mod to itself...")
		return false
	elseif self.ringModComponent:inConnected() then 
		return false
	else
		ghostCable:setEnd(self.socketInVector.x, self.socketInVector.y)
		ghostCable:setGhostReceiveConnected()
		return true
	end
end

function RingModulatorMod:tryConnectGhostOut(x, y, ghostCable)
	if self.ringModComponent:outConnected() then 
		return false
	else
		ghostCable:setStart(self.socketOutVector.x, self.socketOutVector.y, self.modId)
		ghostCable:setGhostSendConnected()
		return true
	end
end

function RingModulatorMod:type()
	return "RingModulatorMod"
end

function RingModulatorMod:handleModClick(tX, tY, listener)
	self.menuListener = listener
	local actions = {
		{label = "About"},
		{label = "Remove"}
	}
	local contextMenu = ModuleMenu(actions)
	contextMenu:show(function(action) 
		if action == "About" then
			local aboutPopup = ModAboutPopup("todo")
			aboutPopup:show()
		else
			if self.menuListener ~= nil then 
				self.menuListener(action) 
			end
		end
	end)
end

function RingModulatorMod:setChannel(channel)
	if channel == nil then
		print("RingModulatorMod:setChannel() CHANNEL IS NIL")
	else
		print("RingModulatorMod:setChannel() CHANNEL EXISTS!")
	end
	self.ringModComponent:setChannel(channel)
end

function RingModulatorMod:removeChannel(channel)
	self.ringModComponent:removeChannel(channel)
end

function RingModulatorMod:evaporate(onDetachConnected)
	--first detach cables
	if self.ringModComponent:outConnected() then
		onDetachConnected(self.outCable:getEndModId(), self.outCable:getCableId())
		self.ringModComponent:unplugOut()
		self.outCable:evaporate()
	end
	
	if self.ringModComponent:inConnected() then
		onDetachConnected(self.inCable:getEndModId(), self.inCable:getCableId())
		self.ringModComponent:unplugIn()
		self.inCable:evaporate()
	end
	
	--then remove sprites
	self.mixEncoder:evaporate()
	self.frequencyEncoder:evaporate()
	playdate.graphics.sprite.removeSprites({self.cutoffFreqLabelSprite})
	self:remove()
end

function RingModulatorMod.ghostModule()
	return buildGhostModule(moduleWidth, moduleHeight)
end

function RingModulatorMod:toState()
	local modState = {}
	modState.modId = self.modId
	modState.type = self:type()
	modState.x = self.x
	modState.y = self.y
	
	modState.normalisedTempoDiv = self.mixEncoder:getValue()
	modState.normalisedProbability = self.frequencyEncoder:getValue()
	
	return modState
end

function RingModulatorMod:fromState(modState)
	self.mixEncoder:setValue(modState.normalisedTempoDiv)
	self.frequencyEncoder:setValue(modState.normalisedProbability)
end