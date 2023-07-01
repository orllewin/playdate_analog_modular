--[[

	This will have an in and an out, 

]]--
import 'Modules/mod_utils.lua'
import 'Modules/Random/random_component'

class('RandomMod').extends(playdate.graphics.sprite)

local gfx <const> = playdate.graphics

local moduleWidth = 32
local moduleHeight = 120

local modType = "RandomMod"
local modSubtype = "clock_router"

function RandomMod:init(xx, yy, modId)
	RandomMod.super.init(self)
	
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
	local rand = playdate.graphics.image.new("Images/random")
	rand:drawCentered(bgW/2, 75)
	
	gfx.popContext()
	
	self:setImage(backgroundImage)
	self:moveTo(xx, yy)
	self:add()

	self.inSocketSprite = SocketSprite(xx, yy  - (bgH/2) + 37, socket_in)
	self.outSocketSprite = SocketSprite(xx, yy	+ (moduleHeight/2) - 22, socket_out)
	
	self.randomComponent = RandomComponent()
	--todo
end

function RandomMod:setInCable(patchCable)
	patchCable:setEnd(self.inSocketSprite.x, self.inSocketSprite:getSocketY(), self.modId)
	self.inCable = patchCable
	self.randomComponent:setInCable(patchCable:getCable())
end

function RandomMod:setOutCable(patchCable)
	patchCable:setStart(self.outSocketSprite.x, self.outSocketSprite:getSocketY(), self.modId)
	self.outCable = patchCable
	self.randomComponent:setOutCable(patchCable:getCable())
end

function RandomMod:collision(x, y)
	if x > self.x - (moduleWidth/2) and x < self.x + (moduleWidth/2) and y > self.y - (moduleHeight/2) and y < self.y + (moduleHeight/2) then
		return true
	else
		return false
	end
end

function RandomMod:tryConnectGhostIn(x, y, ghostCable)
	ghostCable:setEnd(self.inSocketSprite.x, self.inSocketSprite:getSocketY())
	ghostCable:setGhostReceiveConnected()
	return true
end

function RandomMod:tryConnectGhostOut(x, y, ghostCable)
	ghostCable:setStart(self.outSocketSprite.x, self.outSocketSprite:getSocketY())
	ghostCable:setGhostSendConnected()
	return true
end

function RandomMod:type() return modType end

function RandomMod:handleModClick(tX, tY, listener)
	self.menuListener = listener
	local actions = {
		{label = "About"},
		{label = "Remove"}
	}
	local contextMenu = ModuleMenu(actions)
	contextMenu:show(function(action) 
		if action == "About" then
			local aboutPopup = ModAboutPopup("Emits a random value when it receives a 'bang'.")
			aboutPopup:show()
		else
			if self.menuListener ~= nil then 
				self.menuListener(action) 
			end
		end

	end)
end

function RandomMod:evaporate(onDetachConnected)
	--first detach cables
	if self.randomComponent:inConnected() then
		onDetachConnected(self.inCable:getStartModId(), self.inCable:getCableId())
		self.randomComponent:unplugIn()
		self.inCable:evaporate()
	end
	
	if self.randomComponent:outConnected() then
		onDetachConnected(self.outCable:getEndModId(), self.outCable:getCableId())
		self.randomComponent:unplugOut()
		self.outCable:evaporate()
	end
	
	--then remove sprites
	playdate.graphics.sprite.removeSprites({self.inSocketSprite, self.outSocketSprite})
	self.inSocketSprite = nil
	self.outSocketSprite = nil
	self:remove()
end

function RandomMod.ghostModule()
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

function RandomMod:toState()
	local modState = {}
	modState.modId = self.modId
	modState.type = self:type()
	modState.x = self.x
	modState.y = self.y
	return modState
end


function RandomMod:fromState(modState)

end