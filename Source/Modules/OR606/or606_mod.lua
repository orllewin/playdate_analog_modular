--[[
	https://www.musicradar.com/reviews/cyclone-analogic-tt-606
--]]
import 'Modules/Sprites/sequencer_steps'
import 'Modules/OR606/or606_component'

class('OR606Mod').extends(playdate.graphics.sprite)

local gfx <const> = playdate.graphics

local moduleWidth = 280
local moduleHeight = 125

local modType = "OR606Mod"
local modSubtype = "audio_gen"

local labelBassDrum = gfx.imageWithText("Bass Drum", 100, 20)
local drumSelector = gfx.image.new("Images/drum_selector")
local patternLengthSelector = gfx.image.new("Images/pattern_length_selector")
local drumLabels = {"Base Drum", "Snare Drum", "Low Tom", "High Tom", "Cymbal", "Open Hat", "Closed Hat"}

function OR606Mod:init(xx, yy, modId, onInit)
	OR606Mod.super.init(self)
	
	if modId == nil then
		self.modId = modType .. playdate.getSecondsSinceEpoch()
	else
		self.modId = modId
	end
	
	self.onInit = onInit
	
	self.modType = modType
	self.modSubtype = modSubtype
	self.selectedDrumIndex = 1
	
	self.or606Component = OR606Component(function(channel)
		if self.onInit ~= nil then self.onInit(self.modId, channel) end
	end)
	
	local backgroundImage = generateModBackgroundWithShadow(moduleWidth, moduleHeight)
	local bgW, bgH = backgroundImage:getSize()
	
	gfx.pushContext(backgroundImage)
	gfx.drawText("OR-606", 47, 36)
	drumSelector:draw(20, 55)
	patternLengthSelector:draw(215, 55)
	gfx.popContext()
	
	self:setImage(backgroundImage)
	self:moveTo(xx, yy)
	self:add()
	
	self.steps = SequencerSteps(xx, yy + (moduleHeight/2) - 22, function(pattern)
		print("Set pattern: " .. self.selectedDrumIndex)
		--printTable(pattern)
		self.or606Component:setPattern(self.selectedDrumIndex, pattern)
	end)
	
	self.selectedDrumLabelSprite = gfx.sprite.new(labelBassDrum)
	self.selectedDrumLabelSprite:moveTo(xx, yy + 18)
	self.selectedDrumLabelSprite:add()
	
	self.drumSelectEncoder = RotaryEncoder(xx - (moduleWidth/2) + 45, yy + 4, function(value) 
		local degrees = map(value, 0.0, 1.0, 0, 300)
		local drumIndex = math.max(1, math.floor((degrees/(300/7) + 0.5)))
		if drumIndex ~= self.selectedDrumIndex then
			self.selectedDrumIndex = drumIndex
			local labelImage = gfx.imageWithText(drumLabels[drumIndex], 100, 20)
			self.selectedDrumLabelSprite:setImage(labelImage)
			self.steps:setPattern(self.or606Component:getPattern(drumIndex), self.or606Component:getPatternLength(self.selectedDrumIndex))
		end
	end)
	
	self.patternLengthEncoder = RotaryEncoder(xx + (moduleWidth/2) - 45, yy +5, function(value) 
		local degrees = map(value, 0.0, 1.0, 0, 300)
		local stepLengthIndex = math.max(1, math.floor((degrees/(300/5) + 0.5)))
		self.or606Component:setPatternLength(self.selectedDrumIndex, stepLengthIndex * 16)
		self.steps:setPattern(self.or606Component:getPattern(self.selectedDrumIndex), self.or606Component:getPatternLength(self.selectedDrumIndex))
	end)
	
	self.encoders = {
		self.drumSelectEncoder,
		self.patternLengthEncoder
	}
	
	self.socketInSprite = SocketSprite(xx - (moduleWidth/2) +16, yy - (moduleHeight/2) + 20, socket_in)
	self.socketOutSprite = SocketSprite(xx + (moduleWidth/2) - 16, yy - (moduleHeight/2) + 20, socket_out)
	
end

function OR606Mod:findClosestEncoder(x, y)
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

function OR606Mod:turn(x, y, change)
	local encoder = self:findClosestEncoder(x, y)
	encoder:turn(change)
end

function OR606Mod:type()
	return modType
end

function OR606Mod:handleModClick(tX, tY, listener)
	if self.steps:collision(tX, tY) then
		self.steps:onClick(tX, tY, function(pattern)
			--todo Update pattern!
			
		end)
	else
		self.menuListener = listener
		local actions = {
			{label = "About"},
			{label = "Remove"}
		}
		local contextMenu = ModuleMenu(actions)
		contextMenu:show(function(action) 
			if action == "About" then
				local aboutPopup = ModAboutPopup("A clone of the Roland TR-606")
				aboutPopup:show()
			else
				if self.menuListener ~= nil then 
					self.menuListener(action) 
				end
			end
	
		end)
	end
end

function OR606Mod:collision(x, y)
	if x > self.x - (moduleWidth/2) and x < self.x + (moduleWidth/2) and y > self.y - (moduleHeight/2) and y < self.y + (moduleHeight/2) then
		return true
	else
		return false
	end
end

function OR606Mod.ghostModule()
	return buildGhostModule(moduleWidth, moduleHeight)
end

function OR606Mod:tryConnectGhostIn(x, y, ghostCable)
	ghostCable:setEnd(self.socketInSprite.x, self.socketInSprite:getSocketY())
	ghostCable:setGhostReceiveConnected()
	return true
end

function OR606Mod:tryConnectGhostOut(x, y, ghostCable)
	ghostCable:setStart(self.socketOutSprite.x, self.socketOutSprite:getSocketY())
	ghostCable:setGhostSendConnected()
	return true
end

function OR606Mod:setInCable(patchCable)
	patchCable:setEnd(self.socketInSprite.x, self.socketInSprite.y, self.modId)
	self.inCable = patchCable
	self.or606Component:setInCable(patchCable:getCable())
end

function OR606Mod:setOutCable(patchCable)
	patchCable:setEnd(self.socketOutSprite.x, self.socketOutSprite.y, self.modId)
	self.outCable = patchCable
	self.or606Component:setOutCable(patchCable:getCable())
end