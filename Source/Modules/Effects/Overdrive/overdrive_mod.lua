--[[
	© 2023 Orllewin - All Rights Reserved.
]]

import 'Modules/mod_utils.lua'
import 'Modules/Effects/Overdrive/overdrive_component'
import 'Modules/mod_about_popup'
import 'Modules/module_menu'
import 'Coracle/math'
import 'CoracleViews/rotary_encoder'

class('OverdriveMod').extends(playdate.graphics.sprite)

local gfx <const> = playdate.graphics

local moduleWidth = 105
local moduleHeight = 96

local modType = "OverdriveMod"
local modSubtype = "audio_effect"

function OverdriveMod:init(xx, yy, modId)
	OverdriveMod.super.init(self)
	
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
	gfx.drawTextAligned("ODrive", bgW/2, 19, kTextAlignment.center)
	
	local mixImage = gfx.image.new("Images/mix")
	mixImage:draw(bgW/2 + 28, bgH/2 + 10)
	
	gSocketInImage:draw(20, 20)
	gSocketOutImage:draw(bgW - 40, 20)
	
	gfx.popContext()
	
	self:setImage(backgroundImage)
	self:moveTo(xx, yy)
	self:add()
	
	self.component = OverdriveComponent()

	self.mixEncoder = RotaryEncoder(xx + (moduleWidth/2) - 18, yy + 32, function(value) 
		self.component:setMix(value)
	end)
	self.mixEncoder:setValue(0.5)

	self.gainEncoder = RotaryEncoder(xx - (moduleWidth/2) + 18, yy + 32, function(value) 
		self.component:setGain(map(value, 0.0, 1.0, 0.0, 3.0))
	end)
	self.gainEncoder:setValue(0.5)
	
	self.limimtEncoder = RotaryEncoder(xx, yy + 32, function(value) 
		self.component:setLimit(value)
	end)
	self.limimtEncoder:setValue(0.5)

	self.encoders = {
		self.mixEncoder,
		self.gainEncoder,
		self.limimtEncoder
	}

	self.socketInVector = Vector(xx - (moduleWidth/2) + 16, yy - (moduleHeight/2) + 24)
	self.socketOutVector = Vector	(xx + (moduleWidth/2) - 16, yy - (moduleHeight/2) + 24)

end

function OverdriveMod:turn(x, y, change)
	local encoder = self:findClosestEncoder(x, y)
	encoder:turn(change)
end

function OverdriveMod:findClosestEncoder(x, y)
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

function OverdriveMod:updatePosition()
	self:moveBy(globalXDrawOffset, globalYDrawOffset)
end

function OverdriveMod:getHostAudioModId()
	return self.hostAudioModId
end

function OverdriveMod:setInCable(patchCable)
	patchCable:setEnd(self.socketInVector.x, self.socketInVector.y, self.modId)
	self.inCable = patchCable
	self.hostAudioModId = patchCable:getHostAudioModId()
	self.component:setInCable(patchCable:getCable())
end

function OverdriveMod:setOutCable(patchCable)
	self.outCable = patchCable
	patchCable:setStart(self.socketOutVector.x, self.socketOutVector.y, self.modId)
	self.component:setOutCable(patchCable:getCable())
end

function OverdriveMod:collision(x, y)
	if x > self.x - (moduleWidth/2) and x < self.x + (moduleWidth/2) and y > self.y - (moduleHeight/2) and y < self.y + (moduleHeight/2) then
		return true
	else
		return false
	end
end

function OverdriveMod:tryConnectGhostIn(x, y, ghostCable)
	if ghostCable:getStartModId() == self.modId then
		print("Can't connect a mod to itself...")
		return false
	elseif self.component:inConnected() then 
		return false
	else
		ghostCable:setEnd(self.socketInVector.x, self.socketInVector.y)
		ghostCable:setGhostReceiveConnected()
		return true
	end
end

function OverdriveMod:tryConnectGhostOut(x, y, ghostCable)
	if self.component:outConnected() then 
		return false
	else
		ghostCable:setStart(self.socketOutVector.x, self.socketOutVector.y, self.modId)
		ghostCable:setGhostSendConnected()
		return true
	end
end

function OverdriveMod:type()
	return modType
end

function OverdriveMod:handleModClick(tX, tY, listener)
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

function OverdriveMod:setChannel(channel)
	if channel == nil then
		print("OverdriveMod:setChannel() CHANNEL IS NIL")
	else
		print("OverdriveMod:setChannel() CHANNEL EXISTS!")
	end
	self.component:setChannel(channel)
end

function OverdriveMod:removeChannel(channel)
	self.delayComponent:removeChannel(channel)
end

function OverdriveMod:evaporate(onDetachConnected)
	--first detach cables
	if self.delayComponent:outConnected() then
		onDetachConnected(self.outCable:getEndModId(), self.outCable:getCableId())
		self.delayComponent:unplugOut()
		self.outCable:evaporate()
	end
	
	if self.delayComponent:inConnected() then
		onDetachConnected(self.inCable:getEndModId(), self.inCable:getCableId())
		self.delayComponent:unplugIn()
		self.inCable:evaporate()
	end
	
	--then remove sprites
	self.mixEncoder:evaporate()
	self.frequencyEncoder:evaporate()
	playdate.graphics.sprite.removeSprites({self.cutoffFreqLabelSprite})
	self:remove()
end

function OverdriveMod.ghostModule()
	return buildGhostModule(moduleWidth, moduleHeight)
end

function OverdriveMod:toState()
	local modState = {}
	modState.modId = self.modId
	modState.type = self:type()
	modState.x = self.x
	modState.y = self.y
	
	modState.normalisedTempoDiv = self.mixEncoder:getValue()
	modState.normalisedProbability = self.frequencyEncoder:getValue()
	
	return modState
end

function OverdriveMod:fromState(modState)
	self.mixEncoder:setValue(modState.normalisedTempoDiv)
	self.frequencyEncoder:setValue(modState.normalisedProbability)
end