--[[
	© 2023 Orllewin - All Rights Reserved.
]]

import 'Modules/mod_utils.lua'
import 'Modules/Effects/Bitcrusher/bitcrusher_component'
import 'Modules/mod_about_popup'
import 'Modules/module_menu'
import 'Coracle/math'
import 'CoracleViews/rotary_encoder'

class('BitcrusherMod').extends(playdate.graphics.sprite)

local gfx <const> = playdate.graphics

local moduleWidth = 85
local moduleHeight = 120

local modType = "BitcrusherMod"
local modSubtype = "audio_effect"

function BitcrusherMod:init(xx, yy, modId)
	BitcrusherMod.super.init(self)
	
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
	
	gfx.drawLine((bgW/2) - (moduleWidth/2) + 7, 60, (bgW/2) + (moduleWidth/2) - 7, 60)
	gfx.drawTextAligned("Krush", bgW/2, 68, kTextAlignment.center)
	
	gMixImage:draw(bgW - 38, 20)

	gSideSocketLeft:draw(10, 25)
	gSideSocketRight:draw(97, 25)
	
	generateHalftoneRoundedRect(71, 43, 0.3):draw(20, 83)
	
	gfx.popContext()
	
	self:setImage(backgroundImage)
	self:moveTo(xx, yy)
	self:add()
	
	self.component = BitcrusherComponent()

	local encoderY = yy - 30
	self.mixEncoder = RotaryEncoder(xx + (moduleWidth/2) - 18,encoderY , function(value) 
		self.component:setMix(value)
	end)
	self.mixEncoder:setValue(0.5)

	self.amountEncoder = RotaryEncoder(xx - (moduleWidth/2) + 18, encoderY, function(value) 
		self.component:setAmount(value)
	end)
	self.amountEncoder:setValue(0.5)
	
	self.undersampleEncoder = RotaryEncoder(xx, encoderY, function(value) 
		self.component:setUndersampling(math.min(0.99, value))
	end)
	self.undersampleEncoder:setValue(0.5)

	self.encoders = {
		self.mixEncoder,
		self.amountEncoder,
		self.undersampleEncoder
	}

	self.socketInVector = Vector(xx - (moduleWidth/2)-2, yy - (moduleHeight/2) + 24)
	self.socketOutVector = Vector	(xx + (moduleWidth/2)+2, yy - (moduleHeight/2) + 24)

end

function BitcrusherMod:turn(x, y, change)
	local encoder = self:findClosestEncoder(x, y)
	encoder:turn(change)
end

function BitcrusherMod:findClosestEncoder(x, y)
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

function BitcrusherMod:updatePosition()
	self:moveBy(globalXDrawOffset, globalYDrawOffset)
end

function BitcrusherMod:getHostAudioModId()
	return self.hostAudioModId
end

function BitcrusherMod:setInCable(patchCable)
	patchCable:setEnd(self.socketInVector.x, self.socketInVector.y, self.modId)
	self.inCable = patchCable
	self.hostAudioModId = patchCable:getHostAudioModId()
	self.component:setInCable(patchCable:getCable())
end

function BitcrusherMod:setOutCable(patchCable)
	self.outCable = patchCable
	patchCable:setStart(self.socketOutVector.x, self.socketOutVector.y, self.modId)
	self.component:setOutCable(patchCable:getCable())
end

function BitcrusherMod:collision(x, y)
	if x > self.x - (moduleWidth/2) and x < self.x + (moduleWidth/2) and y > self.y - (moduleHeight/2) and y < self.y + (moduleHeight/2) then
		return true
	else
		return false
	end
end

function BitcrusherMod:tryConnectGhostIn(x, y, ghostCable)
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

function BitcrusherMod:tryConnectGhostOut(x, y, ghostCable)
	if self.component:outConnected() then 
		return false
	else
		ghostCable:setStart(self.socketOutVector.x, self.socketOutVector.y, self.modId)
		ghostCable:setGhostSendConnected()
		return true
	end
end

function BitcrusherMod:type()
	return modType
end

function BitcrusherMod:handleModClick(tX, tY, listener)
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

function BitcrusherMod:setChannel(channel)
	if channel == nil then
		print("BitcrusherMod:setChannel() CHANNEL IS NIL")
	else
		print("BitcrusherMod:setChannel() CHANNEL EXISTS!")
	end
	self.component:setChannel(channel)
end

function BitcrusherMod:removeChannel(channel)
	self.delayComponent:removeChannel(channel)
end

function BitcrusherMod:evaporate(onDetachConnected)
	--first detach cables
	if self.component:outConnected() then
		onDetachConnected(self.outCable:getEndModId(), self.outCable:getCableId())
		self.component:unplugOut()
		self.outCable:evaporate()
	end
	
	if self.component:inConnected() then
		onDetachConnected(self.inCable:getEndModId(), self.inCable:getCableId())
		self.component:unplugIn()
		self.inCable:evaporate()
	end
	
	--then remove sprites
	self.mixEncoder:evaporate()
	self.frequencyEncoder:evaporate()
	playdate.graphics.sprite.removeSprites({self.cutoffFreqLabelSprite})
	self:remove()
end

function BitcrusherMod.ghostModule()
	return buildGhostModule(moduleWidth, moduleHeight)
end

function BitcrusherMod:toState()
	local modState = {}
	modState.modId = self.modId
	modState.type = self:type()
	modState.x = self.x
	modState.y = self.y
	
	modState.normalisedTempoDiv = self.mixEncoder:getValue()
	modState.normalisedProbability = self.frequencyEncoder:getValue()
	
	return modState
end

function BitcrusherMod:fromState(modState)
	self.mixEncoder:setValue(modState.normalisedTempoDiv)
	self.frequencyEncoder:setValue(modState.normalisedProbability)
end