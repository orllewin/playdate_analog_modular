--[[
	© 2023 Orllewin - All Rights Reserved.
]]

import 'Modules/mod_utils.lua'
import 'Modules/Effects/Lowpass/lowpass_component'
import 'Modules/mod_about_popup'
import 'Modules/module_menu'
import 'Coracle/math'
import 'CoracleViews/rotary_encoder'

class('LowpassMod').extends(playdate.graphics.sprite)

local gfx <const> = playdate.graphics

local moduleWidth = 85
local moduleHeight = 120

local modType = "LowpassMod"
local modSubtype = "audio_effect"

function LowpassMod:init(xx, yy, modId)
	LowpassMod.super.init(self)
	
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
	gfx.drawTextAligned("Lo-Pass", bgW/2, 68, kTextAlignment.center)
	
	gMixImage:draw(bgW - 38, 20)
	
	gSideSocketLeft:draw(10, 25)
	gSideSocketRight:draw(97, 25)
	
	generateHalftoneRoundedRect(71, 43, 0.3):draw(20, 83)
	
	gfx.popContext()
	
	self:setImage(backgroundImage)
	self:moveTo(xx, yy)
	self:add()
	
	self.component = LowpassComponent()

	local encoderY = yy - 30
	self.mixEncoder = RotaryEncoder(xx + (moduleWidth/2) - 18,encoderY, function(value) 
		self.component:setMix(value)
	end)
	self.mixEncoder:setValue(0.5)

	self.freqEncoder = RotaryEncoder(xx - (moduleWidth/2) + 18, encoderY, function(value) 
		self.component:setFrequency(map(value, 0.0, 1.0, 0.0, 5000.0))
	end)
	self.freqEncoder:setValue(0.25)
	
	self.resonanceEncoder = RotaryEncoder(xx, encoderY, function(value) 
		self.component:setResonance(value)
	end)
	self.resonanceEncoder:setValue(0.5)

	self.encoders = {
		self.mixEncoder,
		self.freqEncoder,
		self.resonanceEncoder
	}

	self.socketInVector = Vector(xx - (moduleWidth/2)-2, yy - (moduleHeight/2) + 24)
	self.socketOutVector = Vector	(xx + (moduleWidth/2)+2, yy - (moduleHeight/2) + 24)

end

function LowpassMod:turn(x, y, change)
	local encoder = self:findClosestEncoder(x, y)
	encoder:turn(change)
end

function LowpassMod:findClosestEncoder(x, y)
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

function LowpassMod:updatePosition()
	self:moveBy(globalXDrawOffset, globalYDrawOffset)
end

function LowpassMod:getHostAudioModId()
	return self.hostAudioModId
end

function LowpassMod:setInCable(patchCable)
	patchCable:setEnd(self.socketInVector.x, self.socketInVector.y, self.modId)
	self.inCable = patchCable
	self.hostAudioModId = patchCable:getHostAudioModId()
	self.component:setInCable(patchCable:getCable())
end

function LowpassMod:setOutCable(patchCable)
	self.outCable = patchCable
	patchCable:setStart(self.socketOutVector.x, self.socketOutVector.y, self.modId)
	self.component:setOutCable(patchCable:getCable())
end

function LowpassMod:collision(x, y)
	if x > self.x - (moduleWidth/2) and x < self.x + (moduleWidth/2) and y > self.y - (moduleHeight/2) and y < self.y + (moduleHeight/2) then
		return true
	else
		return false
	end
end

function LowpassMod:tryConnectGhostIn(x, y, ghostCable)
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

function LowpassMod:tryConnectGhostOut(x, y, ghostCable)
	if self.component:outConnected() then 
		return false
	else
		ghostCable:setStart(self.socketOutVector.x, self.socketOutVector.y, self.modId)
		ghostCable:setGhostSendConnected()
		return true
	end
end

function LowpassMod:type()
	return modType
end

function LowpassMod:handleModClick(tX, tY, listener)
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

function LowpassMod:setChannel(channel)
	if channel == nil then
		print("LowpassMod:setChannel() CHANNEL IS NIL")
	else
		print("LowpassMod:setChannel() CHANNEL EXISTS!")
	end
	self.component:setChannel(channel)
end

function LowpassMod:removeChannel(channel)
	self.component:removeChannel(channel)
end

function LowpassMod:evaporate(onDetachConnected)
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
	self.freqEncoder:evaporate()
	self.resonanceEncoder:evaporate()
	playdate.graphics.sprite.removeSprites({self.cutoffFreqLabelSprite})
	self:remove()
end

function LowpassMod.ghostModule()
	return buildGhostModule(moduleWidth, moduleHeight)
end

function LowpassMod:toState()
	local modState = {}
	modState.modId = self.modId
	modState.type = self:type()
	modState.x = self.x
	modState.y = self.y
	
	modState.mixEncoder = self.mixEncoder:getValue()
	modState.freqEncoder = self.freqEncoder:getValue()
	modState.resonanceEncoder = self.resonanceEncoder:getValue()
	
	return modState
end

function LowpassMod:fromState(modState)
	self.mixEncoder:setValue(modState.mixEncoder)
	self.freqEncoder:setValue(modState.freqEncoder)
	self.resonanceEncoder:setValue(modState.resonanceEncoder)
end