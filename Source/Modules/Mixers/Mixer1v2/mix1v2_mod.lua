--[[
	© 2023 Orllewin - All Rights Reserved.
]]

import 'Modules/mod_utils.lua'
import 'Modules/sprites/small_socket_sprite'

class('Mix1v2Mod').extends(playdate.graphics.sprite)

local gfx <const> = playdate.graphics

local moduleWidth = 50
local moduleHeight = 50

local modType = "SpeakerMod"
local modSubtype = "audio_effect"

function Mix1v2Mod:init(xx, yy, modId)
	Mix1v2Mod.super.init(self)
	
	if modId == nil then
		self.modId = modType .. playdate.getSecondsSinceEpoch()
	else
		self.modId = modId
	end
	
	self.modType = modType
	self.modSubtype = modSubtype
	
	self.channel = nil
	
	local backgroundImage = generateModBackgroundWithShadow(moduleWidth, moduleHeight)	
	local bgW, bgH = backgroundImage:getSize()
	gfx.pushContext(backgroundImage)
	
	gSideSocketBottom:draw(30, 63)
	
	gfx.setColor(playdate.graphics.kColorBlack)
	for x = 1,3 do
		for y = 1,3 do
			gfx.fillCircleAtPoint((bgW - moduleWidth)/2 + 1 + (x * 12), (bgH - moduleHeight)/2 + 2 + (y * 11), 4) 
		end
	end
	
	gfx.popContext()
	
	self:setImage(backgroundImage)
	self:moveTo(xx, yy)
	self:add()
	
	self.hasCable = false
	self.inVector = Vector(xx, yy + 28)
	
	--self.channel:setVolume(value)
end

function Mix1v2Mod:turn(x, y, change)
	print("Mix1v2Mod: turn change: " .. change)
	-- todo: self.channel:setVolume(value)
end

function Mix1v2Mod:setInCable(patchCable)
	patchCable:setEnd(self.inVector.x, self.inVector.y)
	self.inCable = patchCable
	self.hasCable = true
end

function Mix1v2Mod:collision(x, y)
	if x > self.x - (moduleWidth/2) and x < self.x + (moduleWidth/2) and y > self.y - (moduleHeight/2) and y < self.y + (moduleHeight/2) then
		return true
	else
		return false
	end
end

function Mix1v2Mod:tryConnectGhostIn(x, y, ghostCable)
	if self.hasCable == false then
		ghostCable:setEnd(self.inVector.x, self.inVector.y)
		return true
	else
		return false
	end
end

function Mix1v2Mod:tryConnectGhostOut(x, y, ghostCable)
	return false
end

function Mix1v2Mod:type()
	return modType
end

function Mix1v2Mod:setChannel(channel)
	if channel == nil then
		print("Mix1v2Mod:setChannel() CHANNEL IS NIL")
	else
		print("Mix1v2Mod:setChannel() CHANNEL EXISTS!")
	end
	self.channel = channel
	self.channel:setVolume(0.3)
end

function Mix1v2Mod:evaporate(onDetachConnected)
	if self.hasCable then
		onDetachConnected(self.inCable:getStartModId(), self.inCable:getCableId())
		self.inCable:evaporate()
		self.inCable = nil
	end

	self.volumeEncoder:evaporate()
	self:remove()
end

function Mix1v2Mod:unplug(cableId)
	if self.inCable ~= nil and self.inCable:getCableId() == cabelId then
		self.hasCable = false
	end
end

function Mix1v2Mod:toState()
	local modState = {}
	modState.modId = self.modId
	modState.type = self:type()
	modState.x = self.x
	modState.y = self.y
	modState.volumeEncoderValue = self.volumeEncoder:getValue()
	return modState
end

function Mix1v2Mod:fromState(modState)
	self.volumeEncoder:setValue(modState.volumeEncoderValue)
end

function Mix1v2Mod.ghostModule()
	local templateImage = playdate.graphics.image.new(moduleWidth, moduleHeight)
	gfx.pushContext(templateImage)
	gfx.setLineWidth(6)
	gfx.setColor(playdate.graphics.kColorBlack)
	gfx.drawRoundRect(3, 3, moduleWidth-6, moduleHeight-6, 8)
	gfx.setLineWidth(1)
	gfx.popContext()
	
	local ghostImage = playdate.graphics.image.new(moduleWidth, moduleHeight)
	gfx.pushContext(ghostImage)
	templateImage:drawFaded(0, 0, 0.3, playdate.graphics.image.kDitherTypeDiagonalLine)
	gfx.popContext()
	
	return playdate.graphics.sprite.new(ghostImage)
end