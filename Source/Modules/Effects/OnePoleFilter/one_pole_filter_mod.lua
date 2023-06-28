--[[
	© 2023 Orllewin - All Rights Reserved.
]]

import 'Modules/mod_utils.lua'
import 'Modules/Effects/OnePoleFilter/one_pole_filter_component'
import 'Modules/mod_about_popup'
import 'Modules/module_menu'
import 'Coracle/math'
import 'CoracleViews/rotary_encoder'

class('OnePoleFilterMod').extends(playdate.graphics.sprite)

local gfx <const> = playdate.graphics

local moduleWidth = 70
local moduleHeight = 96

local modType = "OnePoleFilterMod"
local modSubtype = "audio_effect"

function OnePoleFilterMod:init(xx, yy, modId)
	OnePoleFilterMod.super.init(self)
	
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
	
	gfx.drawText("1 Pole", 27, 20)
	
	local mixImage = gfx.image.new("Images/mix")
	mixImage:draw(58, 30)
	
	gSocketInImage:draw(20, 30)
	gSocketOutImage:draw(58, 74)
	
	gfx.popContext()
	
	self:setImage(backgroundImage)
	self:moveTo(xx, yy)
	self:add()
	
	self.onepoleFilterComponent = OnePoleFilterComponent(function() 
	
	end)

	self.mixEncoder = RotaryEncoder(xx + (moduleWidth/2) - 18, yy - (moduleHeight/2) + 40, function(value) 
		self.onepoleFilterComponent:setMix(value)
	end)
	self.mixEncoder:setValue(0.5)

	self.cutoffFreqLabelSprite = gfx.sprite.spriteWithText("50%", moduleWidth, moduleHeight)
	self.cutoffFreqLabelSprite:moveTo(xx - (moduleWidth/2) +18, yy - (moduleHeight/2) + 52)
	self.cutoffFreqLabelSprite:add()

	self.cutoffFrequencyEncoder = RotaryEncoder(xx - (moduleWidth/2) + 18, yy + 32, function(value) 
		self.onepoleFilterComponent:setCutoffFreq(value)
		self.cutoffFreqLabelSprite:remove()
		self.cutoffFreqLabelSprite = gfx.sprite.spriteWithText(""..round(value, 2), moduleWidth, moduleHeight)
		self.cutoffFreqLabelSprite:moveTo(xx - (moduleWidth/2) + 18, yy + 16)
		self.cutoffFreqLabelSprite:add()
	end)
	self.cutoffFrequencyEncoder:setValue(0.0)

	self.encoders = {
		self.mixEncoder,
		self.cutoffFrequencyEncoder
	}

	self.socketInVector = Vector(xx - (moduleWidth/2) + 16, yy - (moduleHeight/2) + 32)
	self.socketOutVector = Vector(xx + (moduleWidth/2) - 16, yy + (moduleHeight/2) - 15)

end

function OnePoleFilterMod:turn(x, y, change)
	local encoder = self:findClosestEncoder(x, y)
	encoder:turn(change)
end

function OnePoleFilterMod:findClosestEncoder(x, y)
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

function OnePoleFilterMod:getHostAudioModId()
	return self.hostAudioModId
end

function OnePoleFilterMod:setInCable(patchCable)
	patchCable:setEnd(self.socketInVector.x, self.socketInVector.y, self.modId)
	self.inCable = patchCable
	self.hostAudioModId = patchCable:getHostAudioModId()
	self.onepoleFilterComponent:setInCable(patchCable:getCable())
end

function OnePoleFilterMod:setOutCable(patchCable)
	self.outCable = patchCable
	patchCable:setStart(self.socketOutVector.x, self.socketOutVector.y, self.modId)
	self.onepoleFilterComponent:setOutCable(patchCable:getCable())
end

function OnePoleFilterMod:collision(x, y)
	if x > self.x - (moduleWidth/2) and x < self.x + (moduleWidth/2) and y > self.y - (moduleHeight/2) and y < self.y + (moduleHeight/2) then
		return true
	else
		return false
	end
end

function OnePoleFilterMod:tryConnectGhostIn(x, y, ghostCable)
	if ghostCable:getStartModId() == self.modId then
		print("Can't connect a mod to itself...")
		return false
	elseif self.onepoleFilterComponent:inConnected() then
		return false
	else
		ghostCable:setEnd(self.socketInVector.x, self.socketInVector.y)
		ghostCable:setGhostReceiveConnected()
		return true
	end
end

function OnePoleFilterMod:tryConnectGhostOut(x, y, ghostCable)
	if self.onepoleFilterComponent:outConnected() then
		return false
	else
		ghostCable:setStart(self.socketOutVector.x, self.socketOutVector.y, self.modId)
		ghostCable:setGhostSendConnected()
		return true
	end
end

function OnePoleFilterMod:type()
	return "OnePoleFilterMod"
end

function OnePoleFilterMod:handleModClick(tX, tY, listener)
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

function OnePoleFilterMod:setChannel(channel)
	if channel == nil then
		print("OnePoleFilterMod:setChannel() CHANNEL IS NIL")
	else
		print("OnePoleFilterMod:setChannel() CHANNEL EXISTS!")
	end
	self.onepoleFilterComponent:setChannel(channel)
end

function OnePoleFilterMod:removeChannel(channel)
	self.onepoleFilterComponent:removeChannel(channel)
end

function OnePoleFilterMod:evaporate(onDetachConnected)
	--first detach cables
	if self.onepoleFilterComponent:outConnected() then
		onDetachConnected(self.outCable:getEndModId(), self.outCable:getCableId())
		self.onepoleFilterComponent:unplugOut()
		self.outCable:evaporate()
	end
	
	if self.onepoleFilterComponent:inConnected() then
		onDetachConnected(self.inCable:getEndModId(), self.inCable:getCableId())
		self.onepoleFilterComponent:unplugIn()
		self.inCable:evaporate()
	end
	
	--then remove sprites
	self.mixEncoder:evaporate()
	self.cutoffFrequencyEncoder:evaporate()
	playdate.graphics.sprite.removeSprites({self.cutoffFreqLabelSprite})
	self:remove()
end

function OnePoleFilterMod.ghostModule()
	return buildGhostModule(moduleWidth, moduleHeight)
end

function OnePoleFilterMod:toState()
	local modState = {}
	modState.modId = self.modId
	modState.type = self:type()
	modState.x = self.x
	modState.y = self.y
	
	modState.normalisedTempoDiv = self.mixEncoder:getValue()
	modState.normalisedProbability = self.cutoffFrequencyEncoder:getValue()
	
	return modState
end

function OnePoleFilterMod:fromState(modState)
	self.mixEncoder:setValue(modState.normalisedTempoDiv)
	self.cutoffFrequencyEncoder:setValue(modState.normalisedProbability)
end