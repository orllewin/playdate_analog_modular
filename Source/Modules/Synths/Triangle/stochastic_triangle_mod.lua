--[[

]]--
import 'Modules/mod_utils.lua'
import 'Modules/Synths/Triangle/stochastic_triangle_component'
import 'Modules/mod_about_popup'
import 'Modules/module_menu'
import 'Coracle/math'
import 'Modules/Sprites/small_socket_sprite'

class('StochasticTriMod').extends(playdate.graphics.sprite)

local gfx <const> = playdate.graphics

local moduleWidth = 50
local moduleHeight = 50

local triangleImage = playdate.graphics.image.new("Images/triangle")

local modType = "StochasticTriMod"
local modSubtype = "audio_gen"

function StochasticTriMod:init(xx, yy, modId, onInit)
	StochasticTriMod.super.init(self)
	
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
	
	gSideSocketLeft:draw(10, 32)
	gSideSocketRight:draw(62, 32)
	
	gfx.popContext()
	
	self:setImage(backgroundImage)
	self:moveTo(xx, yy)
	self:add()
		
	self.component = StochasticTriangleComponent(function(channel)
			self.onInit(self.modId, channel)
		end)
		
	self.socketInVector = Vector(xx - 25, yy + 8)
	self.socketOutVector = Vector(xx + 25, yy + 8)
end

function StochasticTriMod:setInCable(patchCable)
	patchCable:setEnd(self.socketInVector.x, self.socketInVector.y, self.modId)
	self.inCable = patchCable
	self.component:setInCable(patchCable:getCable())
end

function StochasticTriMod:setOutCable(patchCable)
	self.outCable = patchCable
	patchCable:setStart(self.socketOutVector.x, self.socketOutVector.y, self.modId)
	self.component:setOutCable(patchCable:getCable())
end

function StochasticTriMod:collision(x, y)
	if x > self.x - (moduleWidth/2) and x < self.x + (moduleWidth/2) and y > self.y - (moduleHeight/2) and y < self.y + (moduleHeight/2) then
		return true
	else
		return false
	end
end

function StochasticTriMod:tryConnectGhostIn(x, y, ghostCable)
	if ghostCable:getStartModId() == self.modId then
		print("Can't connect a mod to itself...")
		return false
	elseif self.component:inConnected() then
		return false
	else
		ghostCable:setEnd(self.socketInVector.x, self.socketInVector.y)
		ghostCable:setGhostReceiveConnected()
		return true
	end
end

function StochasticTriMod:tryConnectGhostOut(x, y, ghostCable)
	if self.component:outConnected() then
		return false
	else
		ghostCable:setStart(self.socketOutVector.x, self.socketOutVector.y)
		ghostCable:setGhostSendConnected()
		return true
	end
end

function StochasticTriMod:type()
	return modType
end

function StochasticTriMod:handleModClick(tX, tY, listener)
	self.menuListener = listener
	local actions = {
		{label = "About"},
		{label = "Sine"},
		{label = "Square"},
		{label = "Triangle"},
		{label = "Sawtooth"},
		{label = "PO Phase"},
		{label = "PO Digital"},
		{label = "PO Vosim"},
		{label = "Remove"}
	}
	local contextMenu = ModuleMenu(actions)
	contextMenu:show(function(action, index) 
		self.menuIndex = index
		if action == "About" then
			local aboutPopup = ModAboutPopup("todo")
			aboutPopup:show()
		elseif action == "Sine" then
			self.waveformSprite:setImage(sineImage)
			self.component:setWaveform(1)
		elseif action == "Square" then
			self.waveformSprite:setImage(squareImage)
			self.component:setWaveform(2)
		elseif action == "Triangle" then
			self.waveformSprite:setImage(triangleImage)
			self.component:setWaveform(4)
		elseif action == "Sawtooth" then
			self.waveformSprite:setImage(sawtoothImage)
			self.component:setWaveform(3)
		elseif action == "PO Phase" then
			self.waveformSprite:setImage(poImage1)
			self.component:setWaveform(5)
		elseif action == "PO Digital" then
			self.waveformSprite:setImage(poImage2)
			self.component:setWaveform(6)
		elseif action == "PO Vosim" then
			self.waveformSprite:setImage(poImage3)
			self.component:setWaveform(7)
		else
			if self.menuListener ~= nil then 
				self.menuListener(action) 
			end
		end
	end, self.menuIndex)
end

function StochasticTriMod:unplug(cableId)
	self.component:unplug(cableId)
end

function StochasticTriMod:evaporate(onDetachConnected)
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

function StochasticTriMod.ghostModule()
	return buildGhostModule(moduleWidth, moduleHeight)
end

function StochasticTriMod:toState()
	local modState = {}
	modState.modId = self.modId
	modState.type = self:type()
	modState.x = self.x
	modState.y = self.y	
	return modState
end

function StochasticTriMod:fromState(modState)
	--noop
end