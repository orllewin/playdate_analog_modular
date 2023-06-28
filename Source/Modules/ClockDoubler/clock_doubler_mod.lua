--[[
	© 2023 Orllewin - All Rights Reserved.
]]

import 'Modules/mod_utils.lua'
import 'Modules/ClockDoubler/clock_doubler_component'
import 'Modules/Sprites/bang_sprite'
import 'Modules/mod_about_popup'
import 'Modules/module_menu'

class('ClockDoublerMod').extends(playdate.graphics.sprite)

local gfx <const> = playdate.graphics

local moduleWidth = 32
local moduleHeight = 145

local modType = "ClockDoublerMod"
local modSubtype = "clock_router"

function ClockDoublerMod:init(xx, yy, modId)
	ClockDoublerMod.super.init(self)
	
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
	
	gSocketInImage:draw(20, 20)
	gSocketOutImage:draw(20, 118)
	
	local clockHalved = playdate.graphics.image.new("Images/clock_halved")
	clockHalved:drawCentered(bgW/2, 65)
	
	local arrow = playdate.graphics.image.new("Images/arrow_down")
	arrow:drawCentered(bgW/2, 85)
	
	local clock = playdate.graphics.image.new("Images/clock")
	clock:drawCentered(bgW/2, 105)
	
	gfx.popContext()
	
	self:setImage(backgroundImage)
	self:moveTo(xx, yy)
	self:add()
	
	self.inSocketVector = Vector(xx, yy - (moduleHeight/2) + 22)	
	self.outSocketVector = Vector(xx, yy - (moduleHeight/2) + 123)

	self.clockDoublerComponent = ClockDoublerComponent()
end

function ClockDoublerMod:setInCable(patchCable)
	patchCable:setEnd(self.inSocketVector.x, self.inSocketVector.y, self.modId)
	self.inCable = patchCable
	self.clockDoublerComponent:setInCable(patchCable:getCable())
end

function ClockDoublerMod:setOutCable(patchCable)
	patchCable:setStart(self.outSocketVector.x, self.outSocketVector.y, self.modId)
	self.outCable = patchCable
	self.clockDoublerComponent:setOutCable(patchCable:getCable())
end

function ClockDoublerMod:collision(x, y)
	if x > self.x - (moduleWidth/2) and x < self.x + (moduleWidth/2) and y > self.y - (moduleHeight/2) and y < self.y + (moduleHeight/2) then
		return true
	else
		return false
	end
end

function ClockDoublerMod:tryConnectGhostIn(x, y, ghostCable)
	if ghostCable:getStartModId() == self.modId then
		print("Can't connect a mod to itself...")
		return false
	elseif self.clockDoublerComponent:inConnected() then
		return false
	else
		ghostCable:setEnd(self.inSocketVector.x, self.inSocketVector.y)
		ghostCable:setGhostReceiveConnected()
		return true
	end
end

function ClockDoublerMod:tryConnectGhostOut(x, y, ghostCable)
	if self.clockDoublerComponent:outConnected() then
		return false
	else
		ghostCable:setStart(self.outSocketVector.x, self.outSocketVector.y, self.modId)
		ghostCable:setGhostSendConnected()
		return true
	end
end

function ClockDoublerMod:type()
	return modType
end

function ClockDoublerMod:handleModClick(tX, tY, listener)
	self.menuListener = listener
	local actions = {
		{label = "About"},
		{label = "Remove"}
	}
	local contextMenu = ModuleMenu(actions)
	contextMenu:show(function(action) 
		if action == "About" then
			local aboutPopup = ModAboutPopup("Emits an extra bang between clock events, doubling the rate.")
			aboutPopup:show()
		else
			if self.menuListener ~= nil then 
				self.menuListener(action) 
			end
		end

	end)
end

function ClockDoublerMod:evaporate(onDetachConnected)
	--first detach cables
	if self.clockDoublerComponent:inConnected() then
		onDetachConnected(self.inCable:getStartModId(), self.inCable:getCableId())
		self.clockDoublerComponent:unplugIn()
		self.inCable:evaporate()
	end
	
	if self.clockDoublerComponent:outConnected() then
		onDetachConnected(self.outCable:getEndModId(), self.inCable:getCableId())
		self.clockDoublerComponent:unplugOut()
		self.outCable:evaporate()
	end
	
	self:remove()
end


function ClockDoublerMod.ghostModule()
	return buildGhostModule(moduleWidth, moduleHeight)
end

function ClockDoublerMod:toState()
	local modState = {}
	modState.modId = self.modId
	modState.type = self:type()
	modState.x = self.x
	modState.y = self.y
	
	return modState
end

function ClockDoublerMod:fromState(modState)
	--noop
end