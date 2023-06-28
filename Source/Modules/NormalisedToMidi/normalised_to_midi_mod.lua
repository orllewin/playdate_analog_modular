--[[



]]--
import 'Modules/mod_utils.lua'
import 'Modules/NormalisedToMidi/normalised_to_midi_component'

class('NormalisedToMidiMod').extends(playdate.graphics.sprite)

local gfx <const> = playdate.graphics

local moduleWidth = 38
local moduleHeight = 153

local modType = "NormalisedToMidiMod"
local modSubtype = "clock_router"

function NormalisedToMidiMod:init(xx, yy, modId)
	NormalisedToMidiMod.super.init(self)
	
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
	
	gfx.drawTextAligned("V2M", bgW/2, (bgH - moduleHeight)/2 + 5, kTextAlignment.center)
	gfx.popContext()
	
	self:setImage(backgroundImage)
	self:moveTo(xx, yy)
	self:add()
	
	self.valToMidiComponent = NormalisedToMidiComponent()
	
	
	self.hiRangeEncoder = RotaryEncoder(xx, yy - 12, function(value)
		print("hi encoder: " .. value)
		self.valToMidiComponent:setHighRange(value)
	end)
	
	self.loRangeEncoder = RotaryEncoder(xx, yy + 24, function(value) 
		print("lo encoder: " .. value)
		self.valToMidiComponent:setLowRange(value)
	end)
	
	self.encoders = {
		self.hiRangeEncoder,
		self.loRangeEncoder
	}

	self.inSocketSprite = SocketSprite(xx, yy  - (moduleHeight/2) + 32, socket_in)
	self.outSocketSprite = SocketSprite(xx, yy	+ (moduleHeight/2) - 22, socket_out)
	
	
	--todo
end


function NormalisedToMidiMod:turn(x, y, change)
	local encoder = self:findClosestEncoder(x, y)
	encoder:turn(change)
end

function NormalisedToMidiMod:findClosestEncoder(x, y)
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


function NormalisedToMidiMod:setInCable(patchCable)
	patchCable:setEnd(self.inSocketSprite.x, self.inSocketSprite:getSocketY(), self.modId)
	self.inCable = patchCable
	self.valToMidiComponent:setInCable(patchCable:getCable())
end

function NormalisedToMidiMod:setOutCable(patchCable)
	patchCable:setStart(self.outSocketSprite.x, self.outSocketSprite:getSocketY(), self.modId)
	self.outCable = patchCable
	self.valToMidiComponent:setOutCable(patchCable:getCable())
end

function NormalisedToMidiMod:collision(x, y)
	if x > self.x - (moduleWidth/2) and x < self.x + (moduleWidth/2) and y > self.y - (moduleHeight/2) and y < self.y + (moduleHeight/2) then
		return true
	else
		return false
	end
end

function NormalisedToMidiMod:tryConnectGhostIn(x, y, ghostCable)
	ghostCable:setEnd(self.inSocketSprite.x, self.inSocketSprite:getSocketY())
	ghostCable:setGhostReceiveConnected()
	return true
end

function NormalisedToMidiMod:tryConnectGhostOut(x, y, ghostCable)
	ghostCable:setStart(self.outSocketSprite.x, self.outSocketSprite:getSocketY())
	ghostCable:setGhostSendConnected()
	return true
end

function NormalisedToMidiMod:type() return modType end

function NormalisedToMidiMod:handleModClick(tX, tY, listener)
	self.menuListener = listener
	local actions = {
		{label = "About"},
		{label = "Remove"}
	}
	local contextMenu = ModuleMenu(actions)
	contextMenu:show(function(action) 
		if action == "About" then
			local aboutPopup = ModAboutPopup("Maps a value in the range 0.0 to 1.0 to Midi 1 to 127 values")
			aboutPopup:show()
		else
			if self.menuListener ~= nil then 
				self.menuListener(action) 
			end
		end

	end)
end

function NormalisedToMidiMod:evaporate(onDetachConnected)
	--first detach cables
	if self.valToMidiComponent:inConnected() then
		onDetachConnected(self.inCable:getStartModId(), self.inCable:getCableId())
		self.valToMidiComponent:unplugIn()
		self.inCable:evaporate()
	end
	
	if self.valToMidiComponent:outConnected() then
		onDetachConnected(self.outCable:getEndModId(), self.outCable:getCableId())
		self.valToMidiComponent:unplugOut()
		self.outCable:evaporate()
	end
	
	self.hiRangeEncoder:evaporate()
	self.loRangeEncoder:evaporate()
	
	--then remove sprites
	playdate.graphics.sprite.removeSprites({self.inSocketSprite, self.outSocketSprite})
	self.inSocketSprite = nil
	self.outSocketSprite = nil
	self:remove()
end

function NormalisedToMidiMod.ghostModule()
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

function NormalisedToMidiMod:toState()
	local modState = {}
	modState.modId = self.modId
	modState.type = self:type()
	modState.x = self.x
	modState.y = self.y
	return modState
end


function NormalisedToMidiMod:fromState(modState)

end