--[[


]]--
import 'Modules/mod_utils.lua'
import 'Coracle/vector'
import 'CoracleViews/rotary_encoder'
import 'Modules/SequencerGrid/seq_grid_component'

class('SeqGridMod').extends(playdate.graphics.sprite)

local gfx <const> = playdate.graphics

local moduleWidth = 150
local moduleHeight = 162

local stepImage = playdate.graphics.image.new("Images/step")

local modType = "SeqGridMod"
local modSubtype = "clock_router"

function SeqGridMod:init(xx, yy, modId)
	SeqGridMod.super.init(self)
	
	if modId == nil then
		self.modId = modType .. playdate.getSecondsSinceEpoch()
	else
		self.modId = modId
	end
	
	self.modType = modType
	self.modSubtype = modSubtype
	
	self.midiValues = {0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0}
	
	self.samplePlayers = {}
	
	local player1 = playdate.sound.sampleplayer.new("Samples/kick01")
	player1:setVolume(0.5)
	table.insert(self.samplePlayers, player1)
	
	local player2 = playdate.sound.sampleplayer.new("Samples/kick02")
	player2:setVolume(0.5)
	table.insert(self.samplePlayers, player2)
	
	local player3 = playdate.sound.sampleplayer.new("Samples/snare01")
	player3:setVolume(0.5)
	table.insert(self.samplePlayers, player3)
	
	local player4 = playdate.sound.sampleplayer.new("Samples/snare02")
	player4:setVolume(0.5)
	table.insert(self.samplePlayers, player4)
	
	local player5 = playdate.sound.sampleplayer.new("Samples/fx01")
	player5:setVolume(0.5)
	table.insert(self.samplePlayers, player5)
	
	local player6 = playdate.sound.sampleplayer.new("Samples/kick01")
	player6:setVolume(0.5)
	table.insert(self.samplePlayers, player6)
		
	local backgroundImage = generateModBackgroundWithShadow(moduleWidth, moduleHeight)	
	local bgW, bgH = backgroundImage:getSize()
	
	gfx.pushContext(backgroundImage)
	gfx.drawTextAligned("STEP SEQUENCER", bgW/2, bgH - 28, kTextAlignment.center)	
	gfx.popContext()
	
	self:setImage(backgroundImage)
	self:moveTo(xx, yy)
	self:add()
	
	local col1X = xx -  (2 * 23) + 11
	local col2X = xx -  (1 * 23) + 11
	local col3X = xx +  (1 * 23) - 11
	local col4X = xx +  (2 * 23) - 11
	
	local row1Y = yy - (moduleHeight/2) + 28
	local row2Y = yy - (moduleHeight/2) + 62
	local row3Y = yy - (moduleHeight/2) + 96
	local row4Y = yy - (moduleHeight/2) + 130
	
	local socketInY = yy - (moduleHeight/2) + 22
	local socketOutY = yy - (moduleHeight/2) + 124
	
	self.stepSprite = gfx.sprite.new(stepImage)
	self.stepSprite:moveTo(col1X, row1Y - 16)
	self.stepSprite:add()
	
	local topRowOffset = 30
	local bottomRowOffset = 6
	self.sequencer = SeqGridComponent(function(step) 
		if step == 1 then
			self.stepSprite:moveTo(col1X, row1Y - 16)
			self:playStep(1)
		elseif step == 2 then
			self.stepSprite:moveTo(col2X, row1Y - 16)
			self:playStep(2)
		elseif step == 3 then
			self.stepSprite:moveTo(col3X, row1Y - 16)
			self:playStep(3)
		elseif step == 4 then
			self.stepSprite:moveTo(col4X, row1Y - 16)
			self:playStep(4)
		elseif step == 5 then
			self.stepSprite:moveTo(col1X, row2Y - 16)
			self:playStep(5)
		elseif step == 6 then
			self.stepSprite:moveTo(col2X, row2Y - 16)
			self:playStep(6)
		elseif step == 7 then
			self.stepSprite:moveTo(col3X, row2Y - 16)	
			self:playStep(7)	
		elseif step == 8 then
			self.stepSprite:moveTo(col4X, row2Y - 16)
			self:playStep(8)			
		elseif step == 9 then
			self.stepSprite:moveTo(col1X, row3Y - 16)
			self:playStep(9)
		elseif step == 10 then
			self.stepSprite:moveTo(col2X, row3Y - 16)
			self:playStep(10)
		elseif step == 11 then
			self.stepSprite:moveTo(col3X, row3Y - 16)
			self:playStep(11)
		elseif step == 12 then
			self.stepSprite:moveTo(col4X, row3Y - 16)
			self:playStep(12)
		elseif step == 13 then
			self.stepSprite:moveTo(col1X, row4Y - 16)
			self:playStep(13)
		elseif step == 14 then
			self.stepSprite:moveTo(col2X, row4Y - 16)
			self:playStep(14)
		elseif step == 15 then
			self.stepSprite:moveTo(col3X, row4Y - 16)	
			self:playStep(15)	
		elseif step == 16 then
			self.stepSprite:moveTo(col4X, row4Y - 16)	
			self:playStep(16)			
		end
	end)
	
	self.socketInSprite = SocketSprite(xx - (moduleWidth/2) + 16, socketInY, socket_in)
	
	--encoder is 20 pixels wide, so use 22 per step
	
	--ROW1
	self.step1Encoder = RotaryEncoder(col1X, row1Y, function(value) 
		self:setNote(1, value)
	end)
	self.step2Encoder = RotaryEncoder(col2X, row1Y, function(value) 
		self:setNote(2, value)
	end)
	self.step3Encoder = RotaryEncoder(col3X, row1Y, function(value) 
		self:setNote(3, value)
	end)
	self.step4Encoder = RotaryEncoder(col4X, row1Y, function(value) 
		self:setNote(4, value)
	end)
	
	--ROW2
	self.step5Encoder = RotaryEncoder(col1X, row2Y, function(value) 
		self:setNote(5, value)
	end)
	self.step6Encoder = RotaryEncoder(col2X, row2Y, function(value) 
		self:setNote(6, value)
	end)
	self.step7Encoder = RotaryEncoder(col3X, row2Y, function(value) 
		self:setNote(7, value)
	end)
	self.step8Encoder = RotaryEncoder(col4X, row2Y, function(value) 
		self:setNote(8, value)
	end)
	
	--ROW3
	self.step9Encoder = RotaryEncoder(col1X, row3Y, function(value) 
		self:setNote(9, value)
	end)
	self.step10Encoder = RotaryEncoder(col2X, row3Y, function(value) 
		self:setNote(10, value)
	end)
	self.step11Encoder = RotaryEncoder(col3X, row3Y, function(value) 
		self:setNote(11, value)
	end)
	self.step12Encoder = RotaryEncoder(col4X, row3Y, function(value) 
		self:setNote(12, value)
	end)
	
	--ROW4
	self.step13Encoder = RotaryEncoder(col1X, row4Y, function(value) 
		self:setNote(13, value)
	end)
	self.step14Encoder = RotaryEncoder(col2X, row4Y, function(value) 
		self:setNote(14, value)
	end)
	self.step15Encoder = RotaryEncoder(col3X, row4Y, function(value) 
		self:setNote(15, value)
	end)
	self.step16Encoder = RotaryEncoder(col4X, row4Y, function(value) 
		self:setNote(16, value)
	end)
	
	--Step fade graphic
	local fadedHeight = 25
	local fadedWidth = 92
	local deactivatedImage = playdate.graphics.image.new(fadedWidth, fadedHeight)
	gfx.pushContext(deactivatedImage)
	playdate.graphics.setColor(playdate.graphics.kColorWhite)
	gfx.fillRect(0, 0, fadedWidth, fadedHeight)
	playdate.graphics.setColor(playdate.graphics.kColorBlack)
	gfx.popContext()
	
	local fadedDeactivatedImage = playdate.graphics.image.new(fadedWidth, fadedHeight)
	gfx.pushContext(fadedDeactivatedImage)
	deactivatedImage:drawFaded(0, 0, 0.5, playdate.graphics.image.kDitherTypeBayer2x2)
	gfx.popContext()
	
	self.deactivated1Sprite = gfx.sprite.new(fadedDeactivatedImage)
	self.deactivated1Sprite:moveTo(xx, yy - 12)
	self.deactivated1Sprite:add()
	self.deactivated1Sprite:setVisible(false)
	
	self.deactivated2Sprite = gfx.sprite.new(fadedDeactivatedImage)
	self.deactivated2Sprite:moveTo(xx, yy + 22)
	self.deactivated2Sprite:add()
	self.deactivated2Sprite:setVisible(false)
	
	self.deactivated3Sprite = gfx.sprite.new(fadedDeactivatedImage)
	self.deactivated3Sprite:moveTo(xx, yy + 56)
	self.deactivated3Sprite:add()
	self.deactivated3Sprite:setVisible(false)
	
	self.stepCountEncoder = RotaryEncoder(col1X - 25, row2Y, function(value) 
		local steps = math.floor(map(value, 0.0, 1.0, 1, 4)) * 4
		self.sequencer:setSteps(steps)
		
		if steps == 4 then
			self.deactivated1Sprite:setVisible(true)
			self.deactivated2Sprite:setVisible(true)
			self.deactivated3Sprite:setVisible(true)
		elseif steps == 8 then
			self.deactivated1Sprite:setVisible(false)
			self.deactivated2Sprite:setVisible(true)
			self.deactivated3Sprite:setVisible(true)
		elseif steps == 12 then
			self.deactivated1Sprite:setVisible(false)
			self.deactivated2Sprite:setVisible(false)
			self.deactivated3Sprite:setVisible(true)
		elseif steps == 16 then
			self.deactivated1Sprite:setVisible(false)
			self.deactivated2Sprite:setVisible(false)
			self.deactivated3Sprite:setVisible(false)
		end
	end)
	self.stepCountEncoder:setValue(1.0)
	
	self.encoders = {
		self.step1Encoder,
		self.step2Encoder,
		self.step3Encoder,
		self.step4Encoder,
		self.step5Encoder,
		self.step6Encoder,
		self.step7Encoder,
		self.step8Encoder,
		self.step9Encoder,
		self.step10Encoder,
		self.step11Encoder,
		self.step12Encoder,
		self.step13Encoder,
		self.step14Encoder,
		self.step15Encoder,
		self.step16Encoder,
		self.stepCountEncoder
	}

	self.socketOutSprite = SocketSprite(xx + (moduleWidth/2) - 16, socketOutY, socket_out)
	
end

function SeqGridMod:playStep(index)
	if self.midiValues[index] ~= 0 then
		self.samplePlayers[self.midiValues[index]]:play()
	end
end

function SeqGridMod:findClosestEncoder(x, y)
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

function SeqGridMod:turn(x, y, change)
	local encoder = self:findClosestEncoder(x, y)
	encoder:turn(change)
end

function SeqGridMod:setNote(index, value)
	self.sequencer:setValue(index, map(value, 0.0, 1.0, 0, 127))--todo - get valid values
end

function SeqGridMod:updatePosition()
	self:moveBy(globalXDrawOffset, globalYDrawOffset)
end

function SeqGridMod:setInCable(patchCable)
	patchCable:setEnd(self.socketInSprite.x, self.socketInSprite.y, self.modId)
	self.inCable = patchCable
	self.sequencer:setInCable(patchCable:getCable())
end

function SeqGridMod:setOutCable(patchCable)
	patchCable:setEnd(self.socketOutSprite.x,self.socketOutSprite:getSocketY(), self.modId)
	self.outCable = patchCable
	self.sequencer:setOutCable(patchCable:getCable())
end

function SeqGridMod:collision(x, y)
	if x > self.x - (self.width/2) and x < self.x + (self.width/2) and y > self.y - (self.height/2) and y < self.y + (self.height/2) then
		return true
	else
		return false
	end
end

function SeqGridMod:tryConnectGhostIn(x, y, ghostCable)
	--todo check distance
	ghostCable:setEnd(self.socketInSprite.x, self.socketInSprite.y)
	ghostCable:setGhostReceiveConnected()
	return true
end

function SeqGridMod:tryConnectGhostOut(x, y, ghostCable)
	--todo check distance
	ghostCable:setStart(self.socketOutSprite.x, self.socketOutSprite.y)
	ghostCable:setGhostSendConnected()
	return true
end

function SeqGridMod:type()
	return "SeqGridMod"
end

function SeqGridMod:handleModClick(tX, tY, listener)
	self.menuListener = listener
	local actions = {
		{label = "About"},
		{label = "Remove"}
	}
	local contextMenu = ModuleMenu(actions)
	contextMenu:show(function(action) 
		if action == "About" then
			local aboutPopup = ModAboutPopup("A simple drum machine, each encoder selects the sample for a step from a built-in bank.")
			aboutPopup:show()
		else
			if self.menuListener ~= nil then 
				self.menuListener(action) 
			end
		end

	end)
end

function SeqGridMod:evaporate(onDetachConnected)
	--first detach cables
	if self.sequencer:inConnected() then
	 	onDetachConnected(self.inCable:getStartModId(), self.inCable:getCableId())
	 	self.sequencer:unplugIn()
	 	self.inCable:evaporate()
  end
	
	if self.sequencer:outConnected() then
		onDetachConnected(self.outCable:getEndModId(), self.inCable:getCableId())
		self.sequencer:unplugOut()
		self.outCable:evaporate()
	end
	
	--then remove sprites
	playdate.graphics.sprite.removeSprites({self.socketInSprite, self.socketOutSprite, self.stepSprite})
	self.socketInSprite = nil
	self.socketOutSprite = nil
	
	for i=1,#self.encoders do
		self.encoders[i]:evaporate()
	end
	
	self:remove()
end

function SeqGridMod.ghostModule()
	return buildGhostModule(moduleWidth, moduleHeight)
end

function SeqGridMod:toState()
	local modState = {}
	modState.modId = self.modId
	modState.type = self:type()
	modState.x = self.x
	modState.y = self.y
	modState.encoder1 = self.step1Encoder:getValue()
	modState.encoder2 = self.step2Encoder:getValue()
	modState.encoder3 = self.step3Encoder:getValue()
	modState.encoder4 = self.step4Encoder:getValue()
	modState.encoder5 = self.step5Encoder:getValue()
	modState.encoder6 = self.step6Encoder:getValue()
	modState.encoder7 = self.step7Encoder:getValue()
	modState.encoder8 = self.step8Encoder:getValue()
	modState.encoder9 = self.step9Encoder:getValue()
	modState.encoder10 = self.step10Encoder:getValue()
	modState.encoder11 = self.step11Encoder:getValue()
	modState.encoder12 = self.step12Encoder:getValue()
	modState.encoder13 = self.step13Encoder:getValue()
	modState.encoder14 = self.step14Encoder:getValue()
	modState.encoder15 = self.step15Encoder:getValue()
	modState.encoder16 = self.step16Encoder:getValue()
	modState.stepCountEncoder = self.stepCountEncoder:getValue()
	return modState
end

function SeqGridMod:fromState(modState)
	self.step1Encoder:setValue(modState.encoder1)
	self.step2Encoder:setValue(modState.encoder2)
	self.step3Encoder:setValue(modState.encoder3)
	self.step4Encoder:setValue(modState.encoder4)
	self.step5Encoder:setValue(modState.encoder5)
	self.step6Encoder:setValue(modState.encoder6)
	self.step7Encoder:setValue(modState.encoder7)
	self.step8Encoder:setValue(modState.encoder8)
	self.step9Encoder:setValue(modState.encoder9)
	self.step10Encoder:setValue(modState.encoder10)
	self.step11Encoder:setValue(modState.encoder11)
	self.step12Encoder:setValue(modState.encoder12)
	self.step13Encoder:setValue(modState.encoder13)
	self.step14Encoder:setValue(modState.encoder14)
	self.step15Encoder:setValue(modState.encoder15)
	self.step16Encoder:setValue(modState.encoder16)
	self.stepCountEncoder:setValue(modState.stepCountEncoder)
end