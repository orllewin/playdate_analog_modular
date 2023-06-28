--[[
	© 2023 Orllewin - All Rights Reserved.
]]

import 'Modules/mod_utils.lua'
import 'Modules/Blackhole/blackhole_component'
import 'Modules/mod_about_popup'
import 'Modules/module_menu'

class('BlackholeMod').extends(playdate.graphics.sprite)

local gfx <const> = playdate.graphics

local moduleWidth = 38
local moduleHeight = 135

local modType = "BlackholeMod"
local modSubtype = "clock_router"

function BlackholeMod:init(xx, yy, modId)
	BlackholeMod.super.init(self)
	
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
	gSocketInImage:draw(23, 19)
	gSocketOutImage:draw(23, 110)
	gfx.popContext()
	
	self:setImage(backgroundImage)
	self:moveTo(xx, yy)
	self:add()
	
	self.holeSprite = gfx.sprite.new()
	self.holeSprite:moveTo(xx, yy)
	self.holeSprite:add()
	
	self.socketInVector = Vector(xx+1, yy - (bgH/2) + 38)
	self.socketOutVector = Vector(xx+1, yy - (bgH/2) + 130)
	
	self.blackholeComponent = BlackholeComponent()
	
	self.gravityEncoder = RotaryEncoder(xx, yy, function(value)
		self.blackholeComponent:setGravity(value)
		
		local holeImage = gfx.image.new(moduleWidth, moduleHeight)
		gfx.pushContext(holeImage)
		gfx.setColor(gfx.kColorBlack)
		gfx.fillCircleAtPoint(moduleWidth/2, moduleHeight/2, map(value, 0.0, 1.0, 10, moduleWidth*2))
		gfx.popContext()
		
		local holeImage2 = gfx.image.new(moduleWidth, moduleHeight)
		gfx.pushContext(holeImage2)
		gfx.setClipRect(-moduleWidth/2, -moduleHeight/2, moduleWidth*2, moduleHeight*2)
		holeImage:drawFaded(0, 0, 0.3, gfx.image.kDitherTypeDiagonalLine)
		gfx.clearClipRect()
		gfx.popContext()
		self.holeSprite:setImage(holeImage2)
		
	end)
	self.gravityEncoder:setValue(0.5)
end

function BlackholeMod:turn(x, y, change)
	self.gravityEncoder:turn(change)
end

function BlackholeMod:setInCable(patchCable)
	patchCable:setEnd(self.socketInVector.x, self.socketInVector.y, self.modId)
	self.inCable = patchCable
	self.blackholeComponent:setInCable(patchCable:getCable())
end

function BlackholeMod:setOutCable(patchCable)
	patchCable:setStart(self.socketOutVector.x, self.socketOutVector.y, self.modId)
	self.outCable = patchCable
	self.blackholeComponent:setOutCable(patchCable:getCable())
end

function BlackholeMod:collision(x, y)
	if x > self.x - (moduleWidth/2) and x < self.x + (moduleWidth/2) and y > self.y - (moduleHeight/2) and y < self.y + (moduleHeight/2) then
		return true
	else
		return false
	end
end

function BlackholeMod:tryConnectGhostIn(x, y, ghostCable)
	if ghostCable:getStartModId() == self.modId then
		print("Can't connect a mod to itself...")
		return false
	elseif self.blackholeComponent:inConnected() then
		return false 
	else
		ghostCable:setEnd(self.socketInVector.x, self.socketInVector.y)
		ghostCable:setGhostReceiveConnected()
		return true
	end
end

function BlackholeMod:tryConnectGhostOut(x, y, ghostCable)
	if not self.blackholeComponent:outConnected() then
		ghostCable:setStart(self.socketOutVector.x, self.socketOutVector.y, self.modId)
		ghostCable:setGhostSendConnected()
		return true
	else
		return false
	end
end

function BlackholeMod:type()
	return modType
end

function BlackholeMod:handleModClick(tX, tY, listener)
	self.menuListener = listener
	local actions = {
		{label = "About"},
		{label = "Remove"}
	}
	local contextMenu = ModuleMenu(actions)
	contextMenu:show(function(action) 
		if action == "About" then
			local aboutPopup = ModAboutPopup("Clock events might get sucked into the blackhole. Higher gravity means fewer event make it though.")
			aboutPopup:show()
		else
			if self.menuListener ~= nil then 
				self.menuListener(action) 
			end
		end
	end)
end

function BlackholeMod:evaporate(onDetachConnected)
	--first detach cables
	if self.blackholeComponent:inConnected() then
		onDetachConnected(self.inCable:getStartModId(), self.inCable:getCableId())
		self.blackholeComponent:unplugIn()
		self.inCable:evaporate()
	end
	
	if self.blackholeComponent:outConnected() then
		onDetachConnected(self.outCable:getEndModId(), self.inCable:getCableId())
		self.blackholeComponent:unplugOut()
		self.outCable:evaporate()
	end
	
	--then remove sprites
	self.gravityEncoder:evaporate()
	playdate.graphics.sprite.removeSprites({self.holeSprite})
	self.gravityEncoder = nil
	self.holeSprite = nil
	self:remove()
end

function BlackholeMod.ghostModule()
	return buildGhostModule(moduleWidth, moduleHeight)
end

function BlackholeMod:toState()
	local modState = {}
	modState.modId = self.modId
	modState.type = self:type()
	modState.x = self.x
	modState.y = self.y
	modState.gravity = self.gravityEncoder:getValue()
	
	return modState
end

function BlackholeMod:fromState(modState)
	self.gravityEncoder:setValue(modState.gravity)
end