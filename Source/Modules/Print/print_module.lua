--[[
	© 2023 Orllewin - All Rights Reserved.
]]

import 'Modules/mod_utils.lua'
import 'Modules/Print/print_component'
import 'Coracle/math'

class('PrintModule').extends(playdate.graphics.sprite)

local gfx <const> = playdate.graphics
local pixelFont = gfx.font.new("Fonts/pixarlmed")

local moduleWidth = 96
local moduleHeight = 42

local modType = "PrintMod"
local modSubtype = "clock_router"

function PrintModule:init(xx, yy, modId)
	PrintModule.super.init(self)
	
	if modId == nil then
		self.modId = modType .. playdate.getSecondsSinceEpoch()
	else
		self.modId = modId
	end
	
	self.modType = modType
	self.modSubtype = modSubtype
	
	local backgroundImage = generateModBackgroundWithShadow(moduleWidth, moduleHeight)	
	local bgW, bgH = backgroundImage:getSize()
	
	self:setImage(backgroundImage)
	self:moveTo(xx, yy)
	self:add()
	
	self.socketInSprite = SocketSprite(xx - (moduleWidth/2) + 16, yy, socket_in)
	self.socketOutSprite = SocketSprite(xx + (moduleWidth/2) - 16, yy, socket_out)
	
	self.value = 0.0
	
	local valueImage = playdate.graphics.image.new(moduleWidth, 22)
	gfx.pushContext(valueImage)
	pixelFont:drawTextAligned("" .. self.value, moduleWidth/2, 0, kTextAlignment.center)
	gfx.popContext()
	
	local fadedImage = playdate.graphics.image.new(moduleWidth, 22)
	gfx.pushContext(fadedImage)
	valueImage:drawFaded(0, 0, 0.4, gfx.image.kDitherTypeBayer2x2)
	gfx.popContext()
	
	self.labelSprite = gfx.sprite.new(fadedImage)
	self.labelSprite:moveTo(xx, yy)
	self.labelSprite:add()
	
	self.printComponent = PrintComponent("print_module", function(event) 
		local newValue = event:getValue()
		if newValue ~= self.value then
			self.value = event:getValue()
			local valueImage = playdate.graphics.image.new(moduleWidth, 22)
			gfx.pushContext(valueImage)
			pixelFont:drawTextAligned("" .. round(self.value, 2), moduleWidth/2, 0, kTextAlignment.center)
			gfx.popContext()
			local fadedImage = playdate.graphics.image.new(moduleWidth, 22)
			gfx.pushContext(fadedImage)
			valueImage:drawFaded(0, 0, 0.4, gfx.image.kDitherTypeBayer2x2)
			gfx.popContext()
			self.labelSprite:setImage(fadedImage)
		end		
	end)

end

function PrintModule:updatePosition()
	self:moveBy(globalXDrawOffset, globalYDrawOffset)
end

function PrintModule:setInCable(patchCable)
	self.inCable = patchCable
	patchCable:setEnd(self.socketInSprite.x, self.socketInSprite:getSocketY(), self.modId)
	self.printComponent:setInCable(patchCable:getCable())
end

function PrintModule:setOutCable(patchCable)
	self.outCable = patchCable
	patchCable:setStart(self.socketOutSprite.x, self.socketOutSprite:getSocketY(), self.modId)
	self.printComponent:setOutCable(patchCable:getCable())
end

function PrintModule:collision(x, y)
  if x > self.x - (moduleWidth/2) and x < self.x + (moduleWidth/2) and y > self.y - (moduleHeight/2) and y < self.y + (moduleHeight/2) then
		return true
	else
		return false
	end
end

function PrintModule:tryConnectGhostIn(x, y, ghostCable)
	--todo check distance
	ghostCable:setEnd(self.socketInSprite.x, self.socketInSprite:getSocketY())
	ghostCable:setGhostReceiveConnected()
	return true
end

function PrintModule:tryConnectGhostOut(x, y, ghostCable)
	--todo check distance
	if not self.printComponent:outConnected() then
		ghostCable:setStart(self.socketOutSprite.x, self.socketOutSprite:getSocketY())
		ghostCable:setGhostSendConnected()
	end
	return true
end

function PrintModule:type()
	return modType
end

function PrintModule:handleModClick(tX, tY, listener)
	self.menuListener = listener
	local actions = {
		{label = "About"},
		{label = "Remove"}
	}
	local contextMenu = ModuleMenu(actions)
	contextMenu:show(function(action) 
		if action == "About" then
			local aboutPopup = ModAboutPopup("Print the value of any event to the screen, useful for debugging.")
			aboutPopup:show()
		else
			if self.menuListener ~= nil then 
				self.menuListener(action) 
			end
		end
	end)
end

function PrintModule:unplug(cableId)
	self.printComponent:unplug(cableId)
end

function PrintModule:evaporate(onDetachConnected)
	--first detach cables
	if self.printComponent:inConnected() then
		onDetachConnected(self.inCable:getStartModId(), self.inCable:getCableId())
		self.printComponent:unplugIn()
		self.inCable:evaporate()
	end
	
	if self.printComponent:outConnected() then
		onDetachConnected(self.outCable:getEndModId(), self.outCable:getCableId())
		self.printComponent:unplugOut()
		self.outCable:evaporate()
	end
	
	--then remove sprites
	playdate.graphics.sprite.removeSprites({self.labelSprite, self.socketInSprite, self.socketOutSprite})
	self:remove()
end

function PrintModule.ghostModule()
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

function PrintModule:getModId()
	return self.modId
end

function PrintModule:toState()
	local modState = {}
	modState.modId = self.modId
	modState.type = self:type()
	modState.x = self.x
	modState.y = self.y
	return modState
end


function PrintModule:fromState(modState)

end