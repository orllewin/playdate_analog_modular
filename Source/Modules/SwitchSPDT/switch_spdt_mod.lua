--[[

	Off, swallows an event, on lets it through.
	Live use - toggle menu
	
	TODO - have an input, switch toggled when it receives a bang...
	TODO - make new module with clock input that emits a bang after X bars...
]]--
import 'Modules/mod_utils.lua'
import 'Modules/Sprites/small_socket_sprite'
import 'Modules/SwitchSPDT/switch_spdt_component'

class('SwitchSPDTMod').extends(playdate.graphics.sprite)

local gfx <const> = playdate.graphics

local moduleWidth = 96
local moduleHeight = 80

local modType = "SwitchSPDTMod"
local modSubtype = "clock_router"

local aOnImage = gfx.image.new("Images/spdt_a")
local bOnImage = gfx.image.new("Images/spdt_b")

function SwitchSPDTMod:init(xx, yy, modId)
	SwitchSPDTMod.super.init(self)
	
	if modId == nil then
		self.modId = modType .. playdate.getSecondsSinceEpoch()
	else
		self.modId = modId
	end
	
	self.modType = modType
	self.modSubtype = modSubtype
	
	local backgroundImage = generateModBackgroundWithShadow(moduleWidth, moduleHeight)	
	local bgW, bgH = backgroundImage:getSize()
	self.bgH = bgH
	gfx.pushContext(backgroundImage)
	playdate.graphics.setColor(playdate.graphics.kColorBlack)
	gfx.setLineWidth(2)
	local lineY = bgH/2
	gfx.drawLine(28, lineY, bgW/2, lineY)
	--gfx.drawLine(bgW/2 + 10, lineY, bgW - 25, lineY)
	gfx.setLineWidth(1)
	
	gfx.drawText("<", 38, 78, kTextAlignment.center)
	gfx.popContext()

	self:setImage(backgroundImage)
	self:moveTo(xx, yy)
	self:add()
	
	self.switchStateSprite = gfx.sprite.new(aOnImage)
	self.switchStateSprite:moveTo(xx + 10, yy+1)
	self.switchStateSprite:add()
	
	self.inSocketSprite = SocketSprite(xx - (moduleWidth/2) + 16, yy - 5, socket_in)
	self.outSocketSpriteA = SocketSprite(xx + (moduleWidth/2) - 16, yy + (bgH/2) - 83)
	self.outSocketSpriteB = SocketSprite(xx + (moduleWidth/2) - 16, yy - (bgH/2) + 72)
	
	self.inToggleSocketSprite = SmallSocketSprite(xx - (moduleWidth/2) + 14, yy +28, socket_in)
	
	self.insocketSprites = {
		self.inSocketSprite, self.inToggleSocketSprite
	}
	
	self.switchComponent = SwitchSPDTComponent(function(event)  	

		if self.switchComponent:isOn() then
			self.switchStateSprite:setImage(aOnImage)
		else
			self.switchStateSprite:setImage(bOnImage)
		end		
	end)

end

function SwitchSPDTMod:findClosestInSocketSprite(x, y)
	print("Recticle x: " .. x .. " y: " .. y)
	local reticleVector = Vector(x, y)
	local closestDistance = 1000
	local closestIndex = -1
	for i=1,#self.insocketSprites do
		local aSocket = self.insocketSprites[i]
		
		local socketVector = Vector(aSocket.x, aSocket.y)
		local distance = reticleVector:distance(socketVector)
		print("Checking distance to socket at x: " .. aSocket.x .. " y: " .. aSocket.y .. " distance is: " .. distance)
		if distance < closestDistance then
			closestDistance = distance
			closestIndex = i
		end
	end
	print("findClosestInSocketSprite using index " .. closestIndex)
	return self.insocketSprites[closestIndex]
end

function SwitchSPDTMod:setInCable(patchCable)
	local cableX, cableY = patchCable:getEndXY()
	local inSocket = self:findClosestInSocketSprite(cableX, cableY)
	patchCable:setEnd(inSocket.x, inSocket:getSocketY(), self.modId)
	if inSocket.x == self.inSocketSprite.x then
		patchCable:setEnd(self.inSocketSprite.x, self.inSocketSprite:getSocketY(), self.modId)
		self.inCable = patchCable
		self.switchComponent:setInCable(patchCable:getCable())
	elseif inSocket.x == self.inToggleSocketSprite.x then
		patchCable:setEnd(self.inToggleSocketSprite.x, self.inToggleSocketSprite:getSocketY(), self.modId)
		self.inToggleCable= patchCable
		self.switchComponent:setToggleInCable(patchCable:getCable())
	end
end

function SwitchSPDTMod:setOutCable(patchCable)
	if self.switchComponent:outAConnected() == false then
		patchCable:setEnd(self.outSocketSpriteA.x, self.outSocketSpriteA:getSocketY(), self.modId)
		self.outACable = patchCable
		self.switchComponent:setOutACable(patchCable:getCable())
		return true
	elseif self.switchComponent:outBConnected() == false then
		patchCable:setEnd(self.outSocketSpriteB.x, self.outSocketSpriteB:getSocketY(), self.modId)
		self.outBCable = patchCable
		self.switchComponent:setOutBCable(patchCable:getCable())
		return true
	else
		return false
	end
end

function SwitchSPDTMod:collision(x, y)
	if x > self.x - (moduleWidth/2) and x < self.x + (moduleWidth/2) and y > self.y - (moduleHeight/2) and y < self.y + (moduleHeight/2) then
		return true
	else
		return false
	end
end

--self.inToggleSocketSprite
function SwitchSPDTMod:tryConnectGhostIn(x, y, ghostCable)
	local inSocket = self:findClosestInSocketSprite(x, y)
	ghostCable:setEnd(inSocket.x, inSocket:getSocketY())
	ghostCable:setGhostReceiveConnected()
	return true
end

function SwitchSPDTMod:tryConnectGhostOut(x, y, ghostCable)
	if self.switchComponent:outAConnected() == false then
		ghostCable:setStart(self.outSocketSpriteA.x, self.outSocketSpriteA:getSocketY())
		ghostCable:setGhostSendConnected()
		return true
	elseif self.switchComponent:outBConnected() == false then
		ghostCable:setStart(self.outSocketSpriteB.x, self.outSocketSpriteB:getSocketY())
		ghostCable:setGhostSendConnected()
		return true
	else
		return false
	end
end

function SwitchSPDTMod:type()
	return modType
end

function SwitchSPDTMod:handleModClick(tX, tY, listener)
	self.menuListener = listener
	local actions = {
		{label = "Toggle"},
		{label = "Remove"},
		{label = "About"}
	}
	local contextMenu = ModuleMenu(actions)
	contextMenu:show(function(action) 
		if action == "Toggle" then
			self.switchComponent:toggle()

			if self.switchComponent:isOn() then
				self.switchStateSprite:setImage(aOnImage)
			else
				self.switchStateSprite:setImage(bOnImage)
			end
						
		elseif action == "About" then
			local aboutPopup = ModAboutPopup("A switch, use to toggle different patterns on your canvas.")
			aboutPopup:show()
		else
			if self.menuListener ~= nil then 
				self.menuListener(action) 
			end
		end

	end)
end


function SwitchSPDTMod.ghostModule()
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

function SwitchSPDTMod:toState()
	local modState = {}
	modState.modId = self.modId
	modState.type = self:type()
	modState.x = self.x
	modState.y = self.y
	return modState
end

function SwitchSPDTMod:evaporate(onDetachConnected)
	--first detach cables
	if self.switchComponent:inConnected() then
		onDetachConnected(self.inCable:getStartModId(), self.inCable:getCableId())
		self.switchComponent:unplugIn()
		self.inCable:evaporate()
	end
	
	if self.switchComponent:outAConnected() then
		onDetachConnected(self.outACable:getEndModId(), self.inCable:getCableId())
		self.switchComponent:unplugOutA()
		self.outACable:evaporate()
	end
	
	if self.switchComponent:outBConnected() then
		onDetachConnected(self.outBCable:getEndModId(), self.inCable:getCableId())
		self.switchComponent:unplugOutB()
		self.outBCable:evaporate()
	end
	
	--then remove sprites
	playdate.graphics.sprite.removeSprites({self.inToggleSocketSprite, self.inSocketSprite, self.outSocketSpriteA, self.outSocketSpriteB, self.switchStateSprite, self.isActiveLabelSprite})
	self.inSocketSprite = nil
	self.outSocketSpriteA = nil
	self.outSocketSpriteB = nil
	self.inToggleSocketSprite = nil
	self.inSocketSprite = nil
	self.isActiveLabelSprite = nil
	self:remove()
end


function SwitchSPDTMod:fromState(modState)

end