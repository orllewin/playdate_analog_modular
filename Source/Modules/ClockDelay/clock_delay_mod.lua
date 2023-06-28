--[[
	© 2023 Orllewin - All Rights Reserved.
]]
import 'Modules/mod_utils.lua'
import 'Modules/ClockDelay/clock_delay_component'
import 'Modules/mod_about_popup'
import 'Modules/module_menu'
import 'Coracle/math'

class('ClockDelayMod').extends(playdate.graphics.sprite)

local gfx <const> = playdate.graphics

local moduleWidth = 38
local moduleHeight = 153

local modType = "ClockDelayMod"
local modSubtype = "clock_router"

local font = playdate.graphics.font.new("Fonts/parodius_ext")
playdate.graphics.setFont(font)

local div1_1Image = gfx.imageWithText("1/1", 100, 20)
local div1_2Image = gfx.imageWithText("1/2", 100, 20)
local div1_4Image = gfx.imageWithText("1/4", 100, 20)
local div1_8Image = gfx.imageWithText("1/8", 100, 20)
local div1_16Image = gfx.imageWithText("1/16", 100, 20)
local div1_32Image = gfx.imageWithText("1/32", 100, 20)
local div1_64Image = gfx.imageWithText("1/64", 100, 20)

function ClockDelayMod:init(xx, yy, modId)
	ClockDelayMod.super.init(self)
	
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
	gSocketInImage:draw(23, 18)
	gSocketOutImage:draw(23, 131)
	gfx.popContext()
	
	self:setImage(backgroundImage)
	self:moveTo(xx, yy)
	self:add()
	
	self.clockDelayComponent = ClockDelayComponent()

	self.divisionLabelSprite = gfx.sprite.new(div1_4Image)
	self.divisionLabelSprite:moveTo(xx, yy - (moduleHeight/2) + 45)
	self.divisionLabelSprite:add()
	
	self.clockDivisionEncoder = RotaryEncoder(xx, yy - 12, function(value) 
		local division = self.clockDelayComponent:setDivisionDelay(value)
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
	self.chanceLabelSprite:moveTo(xx, yy + (moduleHeight/2) - 70)
	self.chanceLabelSprite:add()
	
	self.clockProbabilityEncoder = RotaryEncoder(xx, yy + 25, function(value) 
		local labelImage = gfx.imageWithText(self.clockDelayComponent:setChance(value), 100, 20)
		self.chanceLabelSprite:setImage(labelImage)
	end)
	self.clockProbabilityEncoder:setValue(map(100, 1, 200, 0.0, 1.0))
	
	self.encoders = {
		self.clockDivisionEncoder,
		self.clockProbabilityEncoder
	}
	
	self.socketInVector = Vector(xx, yy - (moduleHeight/2) + 20)
	self.socketOutVector = Vector(xx, yy + (moduleHeight/2) - 15)
end

function ClockDelayMod:turn(x, y, change)
	local encoder = self:findClosestEncoder(x, y)
	encoder:turn(change)
end

function ClockDelayMod:findClosestEncoder(x, y)
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

function ClockDelayMod:setInCable(patchCable)
	patchCable:setEnd(self.socketInVector.x, self.socketInVector.y, self.modId)
	self.inCable = patchCable
	self.clockDelayComponent:setInCable(patchCable:getCable())
end

function ClockDelayMod:setOutCable(patchCable)
	self.outCable = patchCable
	patchCable:setStart(self.socketOutVector.x, self.socketOutVector.y, self.modId)
	self.clockDelayComponent:setOutCable(patchCable:getCable())
end

function ClockDelayMod:collision(x, y)
	if x > self.x - (moduleWidth/2) and x < self.x + (moduleWidth/2) and y > self.y - (moduleHeight/2) and y < self.y + (moduleHeight/2) then
		return true
	else
		return false
	end
end

function ClockDelayMod:tryConnectGhostIn(x, y, ghostCable)
	if ghostCable:getStartModId() == self.modId then
		print("Can't connect a mod to itself...")
		return false
	elseif self.clockDelayComponent:inConnected() then
		return false
	else
		ghostCable:setEnd(self.socketInVector.x, self.socketInVector.y)
		ghostCable:setGhostReceiveConnected()
		return true
	end
end

function ClockDelayMod:tryConnectGhostOut(x, y, ghostCable)
	if self.clockDelayComponent:outConnected() then
		return false
	else
		ghostCable:setStart(self.socketOutVector.x, self.socketOutVector.y, self.modId)
		ghostCable:setGhostSendConnected()
		return true
	end
end

function ClockDelayMod:type()
	return modType
end

function ClockDelayMod:handleModClick(tX, tY, listener)
	self.menuListener = listener
	local actions = {
		{label = "About"},
		{label = "Remove"}
	}
	local contextMenu = ModuleMenu(actions)
	contextMenu:show(function(action) 
		if action == "About" then
			local aboutPopup = ModAboutPopup("Will randomly hold onto a clock event before releasing it.")
			aboutPopup:show()
		else
			if self.menuListener ~= nil then 
				self.menuListener(action) 
			end
		end
	end)
end

function ClockDelayMod:evaporate(onDetachConnected)
	--first detach cables
	if self.clockDelayComponent:outConnected() then
		onDetachConnected(self.outCable:getEndModId(), self.outCable:getCableId())
		self.clockDelayComponent:unplugOut()
		self.outCable:evaporate()
	end
	
	if self.clockDelayComponent:inConnected() then
		onDetachConnected(self.inCable:getEndModId(), self.inCable:getCableId())
		self.clockDelayComponent:unplugIn()
		self.inCable:evaporate()
	end
	
	--then remove sprites
	self.clockDivisionEncoder:evaporate()
	self.clockProbabilityEncoder:evaporate()
	playdate.graphics.sprite.removeSprites({self.divisionLabelSprite, self.chanceLabelSprite})
	self.divisionLabelSprite = nil
	self.chanceLabelSprite = nil
	self:remove()
end

function ClockDelayMod.ghostModule()
	return buildGhostModule(moduleWidth, moduleHeight)
end

function ClockDelayMod:toState()
	local modState = {}
	modState.modId = self.modId
	modState.type = self:type()
	modState.x = self.x
	modState.y = self.y
	
	modState.normalisedTempoDiv = self.clockDivisionEncoder:getValue()
	modState.normalisedProbability = self.clockProbabilityEncoder:getValue()
	
	return modState
end

function ClockDelayMod:fromState(modState)
	self.clockDivisionEncoder:setValue(modState.normalisedTempoDiv)
	self.clockProbabilityEncoder:setValue(modState.normalisedProbability)
end