--[[



]]--
import 'Modules/mod_utils.lua'
import 'Modules/Synth/synth_component'
import 'Modules/Sprites/small_socket_sprite'

class('SynthMod').extends(playdate.graphics.sprite)

local gfx <const> = playdate.graphics

local moduleWidth = 128
local moduleHeight = 152

local sineImage = playdate.graphics.image.new("Images/wf_sine")
local squareImage = playdate.graphics.image.new("Images/wf_square")
local triangleImage = playdate.graphics.image.new("Images/wf_triangle")
local sawtoothImage = playdate.graphics.image.new("Images/wf_sawtooth")
local poImage1 = playdate.graphics.image.new("Images/wf_po_1")
local poImage2 = playdate.graphics.image.new("Images/wf_po_2")
local poImage3 = playdate.graphics.image.new("Images/wf_po_3")
local curveImage = playdate.graphics.image.new("Images/envelope_curve")
local volumeImage = playdate.graphics.image.new("Images/volume")

local modType = "SynthMod"
local modSubtype = "audio_gen"

function SynthMod:init(xx, yy, modId, onInit)
	SynthMod.super.init(self)
	
	if modId == nil then
		self.modId = modType .. playdate.getSecondsSinceEpoch()
	else
		self.modId = modId
	end
	
	self.modType = modType
	self.modSubtype = modSubtype
	
	self.onInit = onInit
	
	local backgroundImage = generateModBackgroundWithShadow(moduleWidth, moduleHeight)	
	local bgW, bgH = backgroundImage:getSize()
	
	--ADSR alignment
	local adsrColWidth = moduleWidth/4
	local adsrSocketY = yy -  (bgH/2) + 72
	local adsrEncoderY = yy -  (bgH/2) + 93
	local shadowPadding = (bgW - moduleWidth)/2
	local adsrCol1X = xx - (bgW/2) + (adsrColWidth*1) - (adsrColWidth/2) + shadowPadding
	local adsrCol2X = xx - (bgW/2) + (adsrColWidth*2) - (adsrColWidth/2) + shadowPadding
	local adsrCol3X = xx - (bgW/2) + (adsrColWidth*3) - (adsrColWidth/2) + shadowPadding
	local adsrCol4X = xx - (bgW/2) + (adsrColWidth*4) - (adsrColWidth/2) + shadowPadding
	
	gfx.pushContext(backgroundImage)
	
	gfx.drawTextAligned("A",  shadowPadding + (adsrColWidth*1) - (adsrColWidth/2), 107, kTextAlignment.center)
	gfx.drawTextAligned("D",  shadowPadding + (adsrColWidth*2) - (adsrColWidth/2), 107, kTextAlignment.center)
	gfx.drawTextAligned("S",  shadowPadding + (adsrColWidth*3) - (adsrColWidth/2), 107, kTextAlignment.center)
	gfx.drawTextAligned("R",  shadowPadding + (adsrColWidth*4) - (adsrColWidth/2), 107, kTextAlignment.center)
	
	volumeImage:draw(shadowPadding + (adsrColWidth*2) - (adsrColWidth/2) - 8, 145)
	curveImage:draw(shadowPadding + (adsrColWidth*1) - (adsrColWidth/2) - 8, 145)
	
	gfx.popContext()
	
	self:setImage(backgroundImage)
	self:moveTo(xx, yy)
	self:add()
	
	self.synthComponent = SynthComponent("synth_module", function(event)  		
		--Main in listener
	end, function(event) 
		--param1 listener
		self.param1Encoder:setValueNoCallback(event:getValue())
	end, function(event) 
		--param2 listener
		self.param2Encoder:setValueNoCallback(event:getValue())
	end, function(channel)
		self.onInit(self.modId, channel)
	end)
	
	self.inSocketSprite = SocketSprite(xx - (moduleWidth/2) + 15, yy - (moduleHeight/2) + 20, socket_in)
	
	self.waveformSprite = gfx.sprite.new(sineImage)
	self.waveformSprite:moveTo(xx - (moduleWidth/2) + 45, yy - (moduleHeight/2) + 12)
	self.waveformSprite:add()
	

	local fadedHeight = 40
	local deactivatedImage = playdate.graphics.image.new(moduleWidth/2, fadedHeight)
	gfx.pushContext(deactivatedImage)
	playdate.graphics.setColor(playdate.graphics.kColorWhite)
	gfx.fillRect(0, 0, moduleWidth/2, fadedHeight)
	playdate.graphics.setColor(playdate.graphics.kColorBlack)
	gfx.popContext()
	
	local fadedDeactivatedImage = playdate.graphics.image.new(moduleWidth/2, fadedHeight)
	gfx.pushContext(fadedDeactivatedImage)
	deactivatedImage:drawFaded(0, 0, 0.6, playdate.graphics.image.kDitherTypeBayer2x2)
	gfx.popContext()
	
	self.deactivatedSprite = gfx.sprite.new(fadedDeactivatedImage)
	self.deactivatedSprite:moveTo(xx + (moduleWidth/4) - 2, yy - (moduleHeight/2) + (fadedHeight/2) + 2)
		
	self.waveformEncoder = RotaryEncoder(xx - (moduleWidth/2) + 45, yy - (moduleHeight/2) + 32, function(value) 
		local waveformLabel = self.synthComponent:setWaveform(value)
		if waveformLabel == "Sine" then
			self.waveformSprite:setImage(sineImage)
			self.deactivatedSprite:setVisible(true)
		elseif waveformLabel == "Square" then
			self.waveformSprite:setImage(squareImage)
			self.deactivatedSprite:setVisible(true)
		elseif waveformLabel == "Triangle" then
			self.waveformSprite:setImage(triangleImage)
			self.deactivatedSprite:setVisible(true)
		elseif waveformLabel == "Sawtooth" then
			self.waveformSprite:setImage(sawtoothImage)
			self.deactivatedSprite:setVisible(true)
		elseif waveformLabel == "PO Phase" then
			self.waveformSprite:setImage(poImage1)
			self.deactivatedSprite:setVisible(false)
		elseif waveformLabel == "PO Digital" then
			self.waveformSprite:setImage(poImage2)
			self.deactivatedSprite:setVisible(false)
		elseif waveformLabel == "PO Vosim" then
			self.waveformSprite:setImage(poImage3)
			self.deactivatedSprite:setVisible(false)
		end
		-- self.divisionLabelSprite:remove()
		-- self.divisionLabelSprite = gfx.sprite.spriteWithText(divisionLabel, moduleWidth, moduleHeight)
		-- self.divisionLabelSprite:moveTo(xx, yy - (moduleHeight/2) + 45)
		-- self.divisionLabelSprite:add()
	end)
	self.waveformEncoder:setValue(0.0)
	
	self.param1Encoder = RotaryEncoder(xx - (moduleWidth/2) + 77, yy - (moduleHeight/2) + 32, function(value) 
		self.synthComponent:setParameter1(value)
	end)
	self.param1InSocket = SmallSocketSprite(xx - (moduleWidth/2) + 77, yy - (moduleHeight/2) + 12, socket_in)
	
	
	self.param2Encoder = RotaryEncoder(xx - (moduleWidth/2) + 110, yy - (moduleHeight/2) + 32, function(value) 
		self.synthComponent:setParameter2(value)
	end)
	self.param2InSocket = SmallSocketSprite(xx - (moduleWidth/2) + 110, yy - (moduleHeight/2) + 12, socket_in)

	self.deactivatedSprite:add()
		
	self.outSocketSprite = SocketSprite(xx + (moduleWidth/2) - 18, yy - (bgH/2) + 140, socket_out)
	
	
	--ADSR
	self.attackEncoder = RotaryEncoder(adsrCol1X, adsrEncoderY, function(value) 
		self.synthComponent:setAttack(value)
	end)
	
	self.decayEncoder = RotaryEncoder(adsrCol2X, adsrEncoderY, function(value) 
		self.synthComponent:setDecay(value)
	end)
	
	self.sustainEncoder = RotaryEncoder(adsrCol3X, adsrEncoderY, function(value) 
		self.synthComponent:setSustain(value)
	end)
	
	self.releaseEncoder = RotaryEncoder(adsrCol4X, adsrEncoderY, function(value) 
		self.synthComponent:setRelease(value)
	end)
	
	self.envelopeCurveEncoder = RotaryEncoder(adsrCol1X, adsrEncoderY + 42, function(value) 
		self.synthComponent:setEnvelopeCurve(value)
	end)
		
self.encoders = {
	self.waveformEncoder,
	self.param1Encoder,
	self.param2Encoder,
	self.attackEncoder,
	self.decayEncoder,
	self.sustainEncoder,
	self.releaseEncoder,
	self.envelopeCurveEncoder,
}

self.insocketSprites = {
	self.inSocketSprite,
	self.param1InSocket,
	self.param2InSocket,
	self.outSocketSprite
}

end

function SynthMod:turn(x, y, change)
	local encoder = self:findClosestEncoder(x, y)
	encoder:turn(change)
end

function SynthMod:findClosestEncoder(x, y)
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

function SynthMod:findClosestInSocketSprite(x, y)
	print("Recticle x: " .. x .. " y: " .. y)
	local reticleVector = Vector(x, y)
	local closestDistance = 1000
	local closestIndex = -1
	for i=1,#self.insocketSprites do
		local aSocket = self.insocketSprites[i]
		
		local socketVector = Vector(aSocket.x, aSocket.y)
		local distance = reticleVector:distance(socketVector)
		print("Checking distance to socket at x: " .. aSocket.x .. " y: " .. aSocket.y .. " distance is: " .. distance)
		if distance < closestDistance then
			closestDistance = distance
			closestIndex = i
		end
	end
	print("findClosestInSocketSprite using index " .. closestIndex)
	return self.insocketSprites[closestIndex]
end

function SynthMod:setInCable(patchCable)
	local cableX, cableY = patchCable:getEndXY()
	local inSocket = self:findClosestInSocketSprite(cableX, cableY)
	patchCable:setEnd(inSocket.x, inSocket:getSocketY(), self.modId)
	if inSocket.x == self.inSocketSprite.x then
		print("ATTACHING CABLE TO inSocketSprite")
		self.inCable = patchCable
		self.synthComponent:setInCable(patchCable:getCable())
	elseif inSocket.x == self.param1InSocket.x then
		print("ATTACHING CABLE TO param1InSocket")
		self.param1InCable = patchCable
		self.synthComponent:setParam1InCable(patchCable:getCable())
	elseif inSocket.x == self.param2InSocket.x then
		print("ATTACHING CABLE TO param2InSocket")
		self.param2InCable = patchCable
		self.synthComponent:setParam2InCable(patchCable:getCable())
	end
end

function SynthMod:setOutCable(patchCable)
	patchCable:setEnd(self.outSocketSprite.x, self.outSocketSprite:getSocketY(), self.modId)
	self.outCable = patchCable
	--self.synthComponent:setOutCable(patchCable:getCable())
end

function SynthMod:collision(x, y)
	if x > self.x - (moduleWidth/2) and x < self.x + (moduleWidth/2) and y > self.y - (moduleHeight/2) and y < self.y + (moduleHeight/2) then
		return true
	else
		return false
	end
end

--The synth has multiple inputs so we need to find the closest socket...
-- At some point we could try and get the module type at the other end of the cable to simplify this
function SynthMod:tryConnectGhostIn(x, y, ghostCable)
	local inSocket = self:findClosestInSocketSprite(x, y)
	ghostCable:setEnd(inSocket.x, inSocket:getSocketY())
	ghostCable:setGhostReceiveConnected()
	return true
end

function SynthMod:tryConnectGhostOut(x, y, ghostCable)
	--todo check distance
	ghostCable:setStart(self.outSocketSprite.x, self.outSocketSprite:getSocketY())
	ghostCable:setGhostSendConnected()
	return true
end

function SynthMod:type()
	return modType
end

function SynthMod:handleModClick(tX, tY, listener)
	self.menuListener = listener
	local actions = {
		{label = "About"},
		{label = "Remove"}
	}
	local contextMenu = ModuleMenu(actions)
	contextMenu:show(function(action) 
		if action == "About" then
			local aboutPopup = ModAboutPopup("A basic sine wave synth.")
			aboutPopup:show()
		else
			if self.menuListener ~= nil then 
				self.menuListener(action) 
			end
		end

	end)
end

function SynthMod:evaporate(onDetachConnected)
	--first detach cables
	if self.synthComponent:inConnected() then
		onDetachConnected(self.inCable:getStartModId(), self.inCable:getCableId())
		self.synthComponent:unplugIn()
		self.inCable:evaporate()
		self.inCable = nil
	end
	
	if self.synthComponent:outConnected() then
		onDetachConnected(self.outCable:getEndModId(), self.outCable:getCableId())
		self.synthComponent:unplugOut()
		self.outCable:evaporate()
		self.outCable = nil
	end
	
	--then remove sprites
	for e=1,#self.encoders do
		local encoder = self.encoders[e]
		encoder:evaporate()
	end
	for s=1,#self.insocketSprites do
		local socket = self.insocketSprites[s]
		socket:remove()
	end
	self.waveformSprite:remove()
	self.waveformSprite = nil
	
	self.deactivatedSprite:remove()
	self.deactivatedSprite = nil
	
	self:remove()
end

function SynthMod.ghostModule()
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

function SynthMod:toState()
	local modState = {}
	modState.modId = self.modId
	modState.type = self:type()
	modState.x = self.x
	modState.y = self.y
	modState.waveformEncoderValue = self.waveformEncoder:getValue()
	modState.param1EncoderValue = self.param1Encoder:getValue()
	modState.param2EncoderValue = self.param2Encoder:getValue()
	modState.attackEncoderValue = self.attackEncoder:getValue()
	modState.decayEncoderValue = self.decayEncoder:getValue()
	modState.sustainEncoderValue = self.sustainEncoder:getValue()
	modState.releaseEncoderValue = self.releaseEncoder:getValue()
	modState.envelopeCurveEncoderValue = self.envelopeCurveEncoder:getValue()
	return modState
end

function SynthMod:fromState(modState)
	self.waveformEncoder:setValue(modState.waveformEncoderValue)
	self.param1Encoder:setValue(modState.param1EncoderValue)
	self.param2Encoder:setValue(modState.param2EncoderValue)
	self.attackEncoder:setValue(modState.attackEncoderValue)
	self.decayEncoder:setValue(modState.decayEncoderValue)
	self.sustainEncoder:setValue(modState.sustainEncoderValue)
	self.releaseEncoder:setValue(modState.releaseEncoderValue)
	self.envelopeCurveEncoder:setValue(modState.envelopeCurveEncoderValue)
end