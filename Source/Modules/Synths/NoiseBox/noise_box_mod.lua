--[[

]]--
import 'Modules/mod_utils.lua'
import 'Modules/Synths/NoiseBox/noise_box_component'
import 'Modules/mod_about_popup'
import 'Modules/module_menu'
import 'Coracle/math'
import 'Modules/Sprites/small_socket_sprite'

class('NoiseBoxMod').extends(playdate.graphics.sprite)

local gfx <const> = playdate.graphics

local moduleWidth = 50
local moduleHeight = 50

local triangleImage = playdate.graphics.image.new("Images/noise")

local modType = "NoiseBoxMod"
local modSubtype = "audio_gen"

function NoiseBoxMod:init(xx, yy, modId, onInit)
	NoiseBoxMod.super.init(self)
	
	if modId == nil then
		self.modId = modType .. playdate.getSecondsSinceEpoch()
	else
		self.modId = modId
	end
	
	self.onInit = onInit
	
	self.modType = modType
	self.modSubtype = modSubtype
	
	self.menuIndex = 1
		
	local backgroundImage = generateModBackgroundWithShadow(moduleWidth, moduleHeight)
	local bgW, bgH = backgroundImage:getSize()
	gfx.pushContext(backgroundImage)
	
	triangleImage:draw(26, 27)
	
	gSideSocketBottom:draw(30, 63)
	
	gfx.popContext()
	
	self:setImage(backgroundImage)
	self:moveTo(xx, yy)
	self:add()
		
	self.component = NoiseBoxComponent(function(channel)
			self.onInit(self.modId, channel)
		end)
		
	self.socketOutVector = Vector(xx, yy + 28)
end

function NoiseBoxMod:setInCable(patchCable)
	patchCable:setEnd(self.socketInVector.x, self.socketInVector.y, self.modId)
	self.inCable = patchCable
	self.component:setInCable(patchCable:getCable())
end

function NoiseBoxMod:setOutCable(patchCable)
	self.outCable = patchCable
	patchCable:setStart(self.socketOutVector.x, self.socketOutVector.y, self.modId)
	self.component:setOutCable(patchCable:getCable())
end

function NoiseBoxMod:collision(x, y)
	if x > self.x - (moduleWidth/2) and x < self.x + (moduleWidth/2) and y > self.y - (moduleHeight/2) and y < self.y + (moduleHeight/2) then
		return true
	else
		return false
	end
end

function NoiseBoxMod:tryConnectGhostIn(x, y, ghostCable)
	return false
end

function NoiseBoxMod:tryConnectGhostOut(x, y, ghostCable)
	if self.component:outConnected() then
		return false
	else
		ghostCable:setStart(self.socketOutVector.x, self.socketOutVector.y)
		ghostCable:setGhostSendConnected()
		return true
	end
end

function NoiseBoxMod:type()
	return modType
end

function NoiseBoxMod:handleModClick(tX, tY, listener)
	self.menuListener = listener
	local actions = {
		{label = "About"},
		{label = "Pitch Up"},
		{label = "Pitch Down"},
		{label = "Remove"}
	}
	local contextMenu = ModuleMenu(actions)
	contextMenu:show(function(action, index) 
		self.menuIndex = index
		if action == "About" then
			local aboutPopup = ModAboutPopup("todo")
			aboutPopup:show()
		elseif action == "Pitch Up" then
			self.component:pitchUp()
		elseif action == "Pitch Down" then
			self.component:pitchDown()
		else
			if self.menuListener ~= nil then 
				self.menuListener(action) 
			end
		end
	end, self.menuIndex)
end

function NoiseBoxMod:unplug(cableId)
	self.component:unplug(cableId)
end

function NoiseBoxMod:evaporate(onDetachConnected)
	--first detach cables
	if self.component:outConnected() then
		onDetachConnected(self.outCable:getEndModId(), self.outCable:getCableId())
		self.component:unplugOut()
		self.outCable:evaporate()
	end
	
	if self.component:inConnected() then
		onDetachConnected(self.inCable:getEndModId(), self.inCable:getCableId())
		self.component:unplugIn()
		self.inCable:evaporate()
	end
	
	--then remove sprites
	playdate.graphics.sprite.removeSprites({self.waveformSprite})
	self:remove()
end

function NoiseBoxMod.ghostModule()
	return buildGhostModule(moduleWidth, moduleHeight)
end

function NoiseBoxMod:toState()
	local modState = {}
	modState.modId = self.modId
	modState.type = self:type()
	modState.x = self.x
	modState.y = self.y	
	return modState
end

function NoiseBoxMod:fromState(modState)
	--noop
end