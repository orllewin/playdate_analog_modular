--[[
	© 2023 Orllewin - All Rights Reserved.
]]

import 'Modules/mod_utils.lua'
import 'Modules/ClockDivider/clock_divider_component'
import 'Modules/Sprites/bang_sprite'
import 'Modules/mod_about_popup'
import 'Modules/module_menu'

class('ClockDividerMod').extends(playdate.graphics.sprite)

local gfx <const> = playdate.graphics

local moduleWidth = 32
local moduleHeight = 145

local modType = "ClockDividerMod"
local modSubtype = "clock_router"

function ClockDividerMod:init(xx, yy, modId)
	ClockDividerMod.super.init(self)
	
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
	
	local clock = playdate.graphics.image.new("Images/clock")
	clock:drawCentered(bgW/2, 65)
	
	local arrow = playdate.graphics.image.new("Images/arrow_down")
	arrow:drawCentered(bgW/2, 85)
	
	local clockHalved = playdate.graphics.image.new("Images/clock_halved")
	clockHalved:drawCentered(bgW/2, 105)
	
	gfx.popContext()
	
	self:setImage(backgroundImage)
	self:moveTo(xx, yy)
	self:add()

	self.inSocketVector = Vector(xx, yy - (moduleHeight/2) + 22)
	self.outSocketVector = Vector(xx, yy - (moduleHeight/2) + 123)

	self.clockDividerComponent = ClockDividerComponent()
end


function ClockDividerMod:setInCable(patchCable)
	patchCable:setEnd(self.inSocketVector.x, self.inSocketVector.y, self.modId)
	self.inCable = patchCable
	self.clockDividerComponent:setInCable(patchCable:getCable())
end

function ClockDividerMod:setOutCable(patchCable)
	patchCable:setStart(self.outSocketVector.x, self.outSocketVector.y, self.modId)
	self.outCable = patchCable
	self.clockDividerComponent:setOutCable(patchCable:getCable())
end

function ClockDividerMod:collision(x, y)
	if x > self.x - (moduleWidth/2) and x < self.x + (moduleWidth/2) and y > self.y - (moduleHeight/2) and y < self.y + (moduleHeight/2) then
		return true
	else
		return false
	end
end

function ClockDividerMod:tryConnectGhostIn(x, y, ghostCable)
	if ghostCable:getStartModId() == self.modId then
		print("Can't connect a mod to itself...")
		return false
	elseif self.clockDividerComponent:inConnected() then
		return false
	else
		ghostCable:setEnd(self.inSocketVector.x, self.inSocketVector.y)
		ghostCable:setGhostReceiveConnected()
		return true
	end
end

function ClockDividerMod:tryConnectGhostOut(x, y, ghostCable)
	if self.clockDividerComponent:outConnected() then
		return false
	else
		ghostCable:setStart(self.outSocketVector.x, self.outSocketVector.y, self.modId)
		ghostCable:setGhostSendConnected()
		return true
	end
end

function ClockDividerMod:type()
	return modType
end

function ClockDividerMod:handleModClick(tX, tY, listener)
	self.menuListener = listener
	local actions = {
		{label = "About"},
		{label = "Remove"}
	}
	local contextMenu = ModuleMenu(actions)
	contextMenu:show(function(action) 
		if action == "About" then
			local aboutPopup = ModAboutPopup("Emits every other event, halving the clock rate.")
			aboutPopup:show()
		else
			if self.menuListener ~= nil then 
				self.menuListener(action) 
			end
		end
	end)
end

function ClockDividerMod:evaporate(onDetachConnected)
	--first detach cables
	if self.clockDividerComponent:inConnected() then
		onDetachConnected(self.inCable:getStartModId(), self.inCable:getCableId())
		self.clockDividerComponent:unplugIn()
		self.inCable:evaporate()
	end
	
	if self.clockDividerComponent:outConnected() then
		onDetachConnected(self.outCable:getEndModId(), self.inCable:getCableId())
		self.clockDividerComponent:unplugOut()
		self.outCable:evaporate()
	end

	self:remove()
end


function ClockDividerMod.ghostModule()
	return buildGhostModule(moduleWidth, moduleHeight)
end

function ClockDividerMod:toState()
	local modState = {}
	modState.modId = self.modId
	modState.type = self:type()
	modState.x = self.x
	modState.y = self.y
	
	return modState
end

function ClockDividerMod:fromState(modState)
	--noop
end