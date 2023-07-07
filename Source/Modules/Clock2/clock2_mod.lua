--[[
	© 2023 Orllewin - All Rights Reserved.
]]

import 'Modules/mod_utils.lua'
import 'Modules/Clock2/clock2_component'
import 'Modules/mod_about_popup'
import 'Modules/module_menu'

class('Clock2Mod').extends(playdate.graphics.sprite)

local gfx <const> = playdate.graphics

local moduleWidth = 50
local moduleHeight = 50

local modType = "Clock2Mod"
local modSubtype = "clock_router"

function Clock2Mod:init(xx, yy, modId)
	Clock2Mod.super.init(self)
	
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
	gSideSocketLeft:draw(10, 32)
	gSideSocketRight:draw(62, 32)
	gSideSocketBottom:draw(30, 63)

	gfx.popContext()
	
	self:setImage(backgroundImage)
	self:moveTo(xx, yy)
	self:add()
	
	self.component = Clock2Component()
	
	self.clockEncoder = RotaryEncoder(xx, yy, function(value) 
		local bpm = math.floor(map(value, 0.0, 1.0, 1, 200))
		self.component:setBPM(bpm)
	end)
	self.clockEncoder:setValue(map(120, 1, 200, 0.0, 1.0))
	
	self.socketOutAVector = Vector(xx, yy + 28)
	self.socketOutBVector = Vector(xx + 28, yy)
	self.socketOutCVector = Vector(xx - 28, yy)
end

function Clock2Mod:turn(x, y, change)
	self.clockEncoder:turn(change)
end

function Clock2Mod:setOutCable(patchCable)
	if self.component:aConnected() ~= true then
		self.outACable = patchCable
		patchCable:setStart(self.socketOutAVector.x, self.socketOutAVector.y, self.modId)
		self.component:setOutACable(patchCable:getCable())
	elseif self.component:bConnected() ~= true then
		self.outBCable = patchCable
		patchCable:setStart(self.socketOutBVector.x, self.socketOutBVector.y, self.modId)
		self.component:setOutBCable(patchCable:getCable())
	elseif self.component:bConnected() ~= true then
		self.outCCable = patchCable
		patchCable:setStart(self.socketOutCVector.x, self.socketOutCVector.y, self.modId)
		self.component:setOutCCable(patchCable:getCable())
	end

end

function Clock2Mod:collision(x, y)
	if x > self.x - (moduleWidth/2) and x < self.x + (moduleWidth/2) and y > self.y - (moduleHeight/2) and y < self.y + (moduleHeight/2) then
		return true
	else
		return false
	end
end

function Clock2Mod:tryConnectGhostOut(x, y, ghostCable)
	if self.component:aConnected() ~= true then
		ghostCable:setStart(self.socketOutAVector.x, self.socketOutAVector.y)
		ghostCable:setGhostSendConnected()
		return true
	elseif self.component:bConnected() ~= true then
		ghostCable:setStart(self.socketOutBVector.x, self.socketOutBVector.y)
		ghostCable:setGhostSendConnected()
		return true
	elseif self.component:cConnected() ~= true then
		ghostCable:setStart(self.socketOutCVector.x, self.socketOutCVector.y)
		ghostCable:setGhostSendConnected()
		return true
	else
		return false
	end
end

function Clock2Mod:type()
	return modType
end

function Clock2Mod:handleModClick(tX, tY, listener)
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

function Clock2Mod:unplug(cableId)
	--todo check IDs of connected cables etc
	self.component:unplug(cableId)
end

function Clock2Mod:evaporate(onDetachConnected)
	print("Clock2Mod evaporate removing cables")
	self.component:stop()
	--first detach cables
	if self.component:connected() then
		onDetachConnected(self.outCable:getEndModId(), self.outCable:getCableId())
		self.component:unplug()
		self.outCable:evaporate()
	end
	
	--then remove sprites
	self.clockEncoder:evaporate()
	playdate.graphics.sprite.removeSprites({self.labelSprite})
	self.clockEncoder = nil
	self.labelSprite = nil
	self:remove()
end

function Clock2Mod.ghostModule()
	return buildGhostModule(moduleWidth, moduleHeight)
end

function Clock2Mod:toState()
	local modState = {}
	modState.modId = self.modId
	modState.type = self:type()
	modState.x = self.x
	modState.y = self.y
	modState.bpmEncoderValue = self.clockEncoder:getValue()
	return modState
end

function Clock2Mod:fromState(modState)
	self.clockEncoder:setValue(modState.bpmEncoderValue)
end