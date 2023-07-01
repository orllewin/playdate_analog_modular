--[[
	© 2023 Orllewin - All Rights Reserved.
	
	Combines clock delay, blackhole, RNG, and Value-to-midi in one module
]]

import 'Modules/mod_utils.lua'
import 'Modules/MidiGen/midi_gen_component'

class('MidiGenMod').extends(playdate.graphics.sprite)

local gfx <const> = playdate.graphics

local div1_1Image = gfx.imageWithText("1/1", 100, 20)
local div1_2Image = gfx.imageWithText("1/2", 100, 20)
local div1_4Image = gfx.imageWithText("1/4", 100, 20)
local div1_8Image = gfx.imageWithText("1/8", 100, 20)
local div1_16Image = gfx.imageWithText("1/16", 100, 20)
local div1_32Image = gfx.imageWithText("1/32", 100, 20)
local div1_64Image = gfx.imageWithText("1/64", 100, 20)

local midigenBackground = gfx.image.new("Images/midigen_background")

local gfx <const> = playdate.graphics

local moduleWidth = 200
local moduleHeight = 140

local maxBlackholeSize = 48

local modType = "MidiGenMod"
local modSubtype = "clock_router"

function MidiGenMod:init(xx, yy, modId)
	print("MidiGenMod INIT")
	MidiGenMod.super.init(self)
	
	if modId == nil then
		self.modId = modType .. playdate.getSecondsSinceEpoch()
	else
		self.modId = modId
	end
	
	self.modType = modType
	self.modSubtype = modSubtype
	
	self.midiGenComponent = MidiGenComponent()
	
	local backgroundImage = generateModBackgroundWithShadow(moduleWidth, moduleHeight)	
	local bgW, bgH = backgroundImage:getSize()
	gfx.pushContext(backgroundImage)	

	midigenBackground:draw(28, 28)
	
	gSocketInImage:draw(20, bgH - 63)
	gSocketOutImage:draw(bgW - 40, bgH - 63)
	
	gfx.drawText("DLY>", 55, 32)
	gfx.drawText("BLACKHOLE>", 55, 68)
	
	gfx.drawText("KEY", 60, 140)
	gfx.drawText("LOW", 100, 140)
	gfx.drawText("HIGH", 140, 140)
	
	
	gfx.popContext()
	
	self:setImage(backgroundImage)
	self:moveTo(xx, yy)
	self:add()
	
	self.divisionLabelSprite = gfx.sprite.new(div1_4Image)
	self.divisionLabelSprite:moveTo(xx, yy - (bgH/2) + 50)
	self.divisionLabelSprite:add()
	
	self.clockDivisionEncoder = RotaryEncoder(xx, yy - (bgH/2) + 30, function(value) 
		local division = self.midiGenComponent:setDivisionDelay(value)
		if division == 1 then
			self.divisionLabelSprite:setImage(div1_1Image)
		elseif division == 2 then
			self.divisionLabelSprite:setImage(div1_2Image)
		elseif division == 3 then
			self.divisionLabelSprite:setImage(div1_4Image)
		elseif division == 4 then
			self.divisionLabelSprite:setImage(div1_8Image)
		elseif division == 5 then 
			self.divisionLabelSprite:setImage(div1_16Image)
		elseif division == 6 then 
			self.divisionLabelSprite:setImage(div1_32Image)
		elseif division == 7 then	
			self.divisionLabelSprite:setImage(div1_64Image)
		end	
	end)
	self.clockDivisionEncoder:setValue(map(120, 1, 200, 0.0, 1.0))
	
	self.chanceLabelSprite = gfx.sprite.spriteWithText("50%", moduleWidth, moduleHeight)
	self.chanceLabelSprite:moveTo(xx + 40, yy - (bgH/2) + 50)
	self.chanceLabelSprite:add()
	
	self.clockProbabilityEncoder = RotaryEncoder(xx + 40, yy - (bgH/2) + 30, function(value) 
		local labelImage = gfx.imageWithText(self.midiGenComponent:setChance(value), 100, 20)
		self.chanceLabelSprite:setImage(labelImage)
	end)
	self.clockProbabilityEncoder:setValue(map(100, 1, 200, 0.0, 1.0))
	
	-- Blackhole
	
	self.holeSprite = gfx.sprite.new()
	self.holeSprite:moveTo(xx - (moduleWidth/2) + 155, yy - 5)
	self.holeSprite:add()
	
	self.gravityEncoder = RotaryEncoder(xx - (moduleWidth/2) + 155, yy - 5, function(value)
		self.midiGenComponent:setGravity(value)
		
		local holeImage = gfx.image.new(maxBlackholeSize, maxBlackholeSize)
		gfx.pushContext(holeImage)
		gfx.setColor(gfx.kColorBlack)
		gfx.fillCircleAtPoint(maxBlackholeSize/2, maxBlackholeSize/2, map(value, 0.0, 1.0, 10, maxBlackholeSize/2))
		gfx.popContext()
		
		local holeImage2 = gfx.image.new(maxBlackholeSize, maxBlackholeSize)
		gfx.pushContext(holeImage2)
		holeImage:drawFaded(0, 0, 0.3, gfx.image.kDitherTypeDiagonalLine)
		gfx.popContext()
	
		self.holeSprite:setImage(holeImage2)
		
	end)
	self.gravityEncoder:setValue(0.5)
	
	self.keySprite = gfx.sprite.new()
	self.keySprite:moveTo(xx,  yy + 25)
	self.keySprite:add()
	
	local midiEncoderY = yy + 42
	self.keyEncoder = RotaryEncoder(xx - (moduleWidth/2) + 60, midiEncoderY, function(value)
		local keyLabel = self.midiGenComponent:setKey(math.floor(map(value, 0.0, 1.0, 1.0, 3.0)))--size of available keys in midi.lua
		local keyImage = gfx.imageWithText(keyLabel, 100, 20)
		self.keySprite:setImage(keyImage)
	end)
	
	self.lowEncoder = RotaryEncoder(xx - (moduleWidth/2) + 100, midiEncoderY, function(value)
		self.midiGenComponent:setLowRange(value)
	end)
	self.lowEncoder:setValue(0.25)
	
	self.hiEncoder = RotaryEncoder(xx - (moduleWidth/2) + 140, midiEncoderY, function(value)
		self.midiGenComponent:setHighRange(value)
	end)
	self.hiEncoder:setValue(0.6)

	self.encoders = {
		self.clockDivisionEncoder,
		self.clockProbabilityEncoder,
		self.gravityEncoder,
		self.keyEncoder,
		self.lowEncoder,
		self.hiEncoder
	}
	
	
	print("MIDI GEN INITIASEDSED")
	self.socketInVector = Vector(xx - 85, yy + (bgH/2) - 40)
	self.socketOutVector = Vector(xx + 85, yy + (bgH/2) - 40)
end

function MidiGenMod:turn(x, y, change)
	local encoder = self:findClosestEncoder(x, y)
	encoder:turn(change)
end

function MidiGenMod:findClosestEncoder(x, y)
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

function MidiGenMod:setInCable(patchCable)
	patchCable:setEnd(self.socketInVector.x, self.socketInVector.y, self.modId)
	self.inCable = patchCable
	self.midiGenComponent:setInCable(patchCable:getCable())
end

function MidiGenMod:setOutCable(patchCable)
	patchCable:setStart(self.socketOutVector.x, self.socketOutVector.y, self.modId)
	self.outCable = patchCable
	self.midiGenComponent:setOutCable(patchCable:getCable())
end

function MidiGenMod:collision(x, y)
	if x > self.x - (moduleWidth/2) and x < self.x + (moduleWidth/2) and y > self.y - (moduleHeight/2) and y < self.y + (moduleHeight/2) then
		return true
	else
		return false
	end
end

function MidiGenMod:tryConnectGhostIn(x, y, ghostCable)
	ghostCable:setEnd(self.socketInVector.x, self.socketInVector.y)
	ghostCable:setGhostReceiveConnected()
	return true
end

function MidiGenMod:tryConnectGhostOut(x, y, ghostCable)
	ghostCable:setStart(self.socketOutVector.x, self.socketOutVector.y)
	ghostCable:setGhostSendConnected()
	return true
end

function MidiGenMod:type() return modType end

function MidiGenMod:handleModClick(tX, tY, listener)
	self.menuListener = listener
	local actions = {
		{label = "About"},
		{label = "Remove"}
	}
	local contextMenu = ModuleMenu(actions)
	contextMenu:show(function(action) 
		if action == "About" then
			local aboutPopup = ModAboutPopup("Emits a random value when it receives a 'bang'.")
			aboutPopup:show()
		else
			if self.menuListener ~= nil then 
				self.menuListener(action) 
			end
		end

	end)
end

function MidiGenMod:evaporate(onDetachConnected)
	--first detach cables
	if self.midiGenComponent:inConnected() then
		onDetachConnected(self.inCable:getStartModId(), self.inCable:getCableId())
		self.midiGenComponent:unplugIn()
		self.inCable:evaporate()
	end
	
	if self.midiGenComponent:outConnected() then
		onDetachConnected(self.outCable:getEndModId(), self.outCable:getCableId())
		self.midiGenComponent:unplugOut()
		self.outCable:evaporate()
	end
	
	--then remove sprites
	playdate.graphics.sprite.removeSprites({self.inSocketSprite, self.outSocketSprite})
	self.inSocketSprite = nil
	self.outSocketSprite = nil
	self:remove()
end

function MidiGenMod.ghostModule()
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

function MidiGenMod:toState()
	local modState = {}
	modState.modId = self.modId
	modState.type = self:type()
	modState.x = self.x
	modState.y = self.y
	return modState
end


function MidiGenMod:fromState(modState)

end