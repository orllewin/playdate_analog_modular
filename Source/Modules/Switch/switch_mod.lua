--[[

	Off, swallows an event, on lets it through.
	Live use - toggle menu
	
	TODO - have an input, switch toggled when it receives a bang...
	TODO - make new module with clock input that emits a bang after X bars...
]]--
import 'Modules/mod_utils.lua'
import 'Modules/Sprites/small_socket_sprite'
import 'Modules/Switch/switch_component'

class('SwitchMod').extends(playdate.graphics.sprite)

local gfx <const> = playdate.graphics

local moduleWidth = 96
local moduleHeight = 64

local modType = "SwitchMod"
local modSubtype = "clock_router"

local offImage = gfx.image.new("Images/switch_open")
local onImage = gfx.image.new("Images/switch_closed")

function SwitchMod:init(xx, yy, modId)
	SwitchMod.super.init(self)
	
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
	local lineY = 42
	gfx.drawLine(28, lineY, bgW/2 - 10, lineY)
	gfx.drawLine(bgW/2 + 10, lineY, bgW - 25, lineY)
	gfx.setLineWidth(1)
	
	gfx.drawTextAligned("<switch", bgW/2 + 6, 61, kTextAlignment.center)
	gfx.popContext()

	self:setImage(backgroundImage)
	self:moveTo(xx, yy)
	self:add()
	
	self.switchStateSprite = gfx.sprite.new(onImage)
	self.switchStateSprite:moveTo(xx, yy - (bgH/2) + 41)
	self.switchStateSprite:add()
	
	self.isActiveLabelSprite = gfx.sprite.spriteWithText("On", moduleWidth, moduleHeight)
	self.isActiveLabelSprite:moveTo(xx, yy - (bgH/2) + 24)
	self.isActiveLabelSprite:add()
	
	self.inSocketSprite = SocketSprite(xx - (moduleWidth/2) + 16, yy - (bgH/2) + 36, socket_in)
	self.outSocketSprite = SocketSprite(xx + (moduleWidth/2) - 16, yy - (bgH/2) + 36, socket_out)
	
	self.inToggleSocketSprite = SmallSocketSprite(xx - (moduleWidth/2) + 14, yy - (bgH/2) + 64, socket_in)
	
	self.insocketSprites = {
		self.inSocketSprite, self.inToggleSocketSprite
	}
	
	self.switchComponent = SwitchComponent("synth_module", function(event)  	
		local label = "Off"	
		if self.switchComponent:isOn() then
			self.switchStateSprite:setImage(onImage)
			label = "On"
		else
			self.switchStateSprite:setImage(offImage)
		end
		
		--todo - just update the sprite with an image... ffs, and pre-computer the images...
		if self.isActiveLabelSprite ~= nil then
			self.isActiveLabelSprite:remove()
		end
		self.isActiveLabelSprite = gfx.sprite.spriteWithText(label, moduleWidth, moduleHeight)
		self.isActiveLabelSprite:moveTo(self.x, self.y - (self.bgH/2) + 24)
		self.isActiveLabelSprite:add()
		
	end)

end

function SwitchMod:findClosestInSocketSprite(x, y)
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

function SwitchMod:setInCable(patchCable)
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

function SwitchMod:setOutCable(patchCable)
	patchCable:setEnd(self.outSocketSprite.x, self.outSocketSprite:getSocketY(), self.modId)
	self.outCable = patchCable
	self.switchComponent:setOutCable(patchCable:getCable())
end

function SwitchMod:collision(x, y)
	if x > self.x - (moduleWidth/2) and x < self.x + (moduleWidth/2) and y > self.y - (moduleHeight/2) and y < self.y + (moduleHeight/2) then
		return true
	else
		return false
	end
end

--self.inToggleSocketSprite
function SwitchMod:tryConnectGhostIn(x, y, ghostCable)
	local inSocket = self:findClosestInSocketSprite(x, y)
	ghostCable:setEnd(inSocket.x, inSocket:getSocketY())
	ghostCable:setGhostReceiveConnected()
	return true
end

function SwitchMod:tryConnectGhostOut(x, y, ghostCable)
	ghostCable:setStart(self.outSocketSprite.x, self.outSocketSprite:getSocketY())
	ghostCable:setGhostSendConnected()
	return true
end

function SwitchMod:type()
	return modType
end

function SwitchMod:handleModClick(tX, tY, listener)
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
			
			local label = "Off"
			if self.switchComponent:isOn() then
				label = "On"
				self.switchStateSprite:setImage(onImage)
			else
				self.switchStateSprite:setImage(offImage)
			end
			self.isActiveLabelSprite:remove()
			self.isActiveLabelSprite = gfx.sprite.spriteWithText(label, moduleWidth, moduleHeight)
			self.isActiveLabelSprite:moveTo(self.x, self.y - (self.bgH/2) + 24)
			self.isActiveLabelSprite:add()
			
			
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


function SwitchMod.ghostModule()
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

function SwitchMod:toState()
	local modState = {}
	modState.modId = self.modId
	modState.type = self:type()
	modState.x = self.x
	modState.y = self.y
	return modState
end

function SwitchMod:evaporate(onDetachConnected)
	--first detach cables
	if self.switchComponent:inConnected() then
		onDetachConnected(self.inCable:getStartModId(), self.inCable:getCableId())
		self.switchComponent:unplugIn()
		self.inCable:evaporate()
	end
	
	if self.switchComponent:outConnected() then
		onDetachConnected(self.outCable:getEndModId(), self.inCable:getCableId())
		self.switchComponent:unplugOut()
		self.outCable:evaporate()
	end
	
	--then remove sprites
	playdate.graphics.sprite.removeSprites({self.inToggleSocketSprite, self.inSocketSprite, self.outSocketSprite, self.switchStateSprite, self.isActiveLabelSprite})
	self.inSocketSprite = nil
	self.outSocketSprite = nil
	self.inToggleSocketSprite = nil
	self.inSocketSprite = nil
	self.isActiveLabelSprite = nil
	self:remove()
end


function SwitchMod:fromState(modState)

end