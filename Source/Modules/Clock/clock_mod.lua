--[[
	© 2023 Orllewin - All Rights Reserved.
]]

import 'Modules/mod_utils.lua'
import 'Modules/Clock/clock_component'
import 'Modules/mod_about_popup'
import 'Modules/module_menu'

class('ClockMod').extends(playdate.graphics.sprite)

local gfx <const> = playdate.graphics

local moduleWidth = 38
local moduleHeight = 100

local modType = "ClockMod"
local modSubtype = "clock_router"

function ClockMod:init(xx, yy, modId)
	ClockMod.super.init(self)
	
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
	gfx.drawTextAligned("BPM", bgW/2, 20, kTextAlignment.center)
	
	gSocketOutImage:draw(23, 75)

	gfx.popContext()
	
	self:setImage(backgroundImage)
	self:moveTo(xx, yy)
	self:add()
	
	self.clockComponent = ClockComponent()

	self.labelSprite = gfx.sprite.new()
	self.labelSprite:moveTo(xx, yy - (moduleHeight/2) + 20)
	self.labelSprite:add()
	
	self.clockEncoder = RotaryEncoder(xx, yy-5, function(value) 
		local bpm = math.floor(map(value, 0.0, 1.0, 1, 200))
		self.clockComponent:setBPM(bpm)
		
		local bpmImage = gfx.imageWithText("" .. bpm, 100, 20)
		self.labelSprite:setImage(bpmImage)
	end)
	self.clockEncoder:setValue(map(120, 1, 200, 0.0, 1.0))
	
	self.socketOutVector = Vector(xx, yy + 32)
end

function ClockMod:turn(x, y, change)
	self.clockEncoder:turn(change)
end

function ClockMod:setOutCable(patchCable)
	self.outCable = patchCable
	patchCable:setStart(self.socketOutVector.x, self.socketOutVector.y, self.modId)
	self.clockComponent:setOutCable(patchCable:getCable())
end

function ClockMod:collision(x, y)
	if x > self.x - (moduleWidth/2) and x < self.x + (moduleWidth/2) and y > self.y - (moduleHeight/2) and y < self.y + (moduleHeight/2) then
		return true
	else
		return false
	end
end

function ClockMod:tryConnectGhostOut(x, y, ghostCable)
	if self.clockComponent:connected() then
		return false
	else
		ghostCable:setStart(self.socketOutVector.x, self.socketOutVector.y)
		ghostCable:setGhostSendConnected()
		return true
	end
end

function ClockMod:type()
	return modType
end

function ClockMod:handleModClick(tX, tY, listener)
	self.menuListener = listener
	local actions = {
		{label = "About"},
		{label = "Remove"}
	}
	local contextMenu = ModuleMenu(actions)
	contextMenu:show(function(action) 
		if action == "About" then
			local aboutPopup = ModAboutPopup("Sends a periodic 'bang', usually the first module added to a rack.")
			aboutPopup:show()
		else
			if self.menuListener ~= nil then 
				self.menuListener(action) 
			end
		end

	end)
end

function ClockMod:unplug(cableId)
	self.clockComponent:unplug(cableId)
end

function ClockMod:evaporate(onDetachConnected)
	print("ClockMod evaporate removing cables")
	self.clockComponent:stop()
	--first detach cables
	if self.clockComponent:connected() then
		onDetachConnected(self.outCable:getEndModId(), self.outCable:getCableId())
		self.clockComponent:unplug()
		self.outCable:evaporate()
	end
	
	--then remove sprites
	self.clockEncoder:evaporate()
	playdate.graphics.sprite.removeSprites({self.labelSprite})
	self.clockEncoder = nil
	self.labelSprite = nil
	self:remove()
end

function ClockMod.ghostModule()
	return buildGhostModule(moduleWidth, moduleHeight)
end

function ClockMod:toState()
	local modState = {}
	modState.modId = self.modId
	modState.type = self:type()
	modState.x = self.x
	modState.y = self.y
	modState.bpmEncoderValue = self.clockEncoder:getValue()
	return modState
end

function ClockMod:fromState(modState)
	self.clockEncoder:setValue(modState.bpmEncoderValue)
end