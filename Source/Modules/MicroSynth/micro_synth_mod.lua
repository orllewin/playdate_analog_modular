--[[
	© 2023 Orllewin - All Rights Reserved.
]]

import 'Modules/mod_utils.lua'
import 'Modules/MicroSynth/micro_synth_component'
import 'Modules/mod_about_popup'
import 'Modules/module_menu'
import 'Coracle/math'
import 'Modules/Sprites/small_socket_sprite'

class('MicroSynthMod').extends(playdate.graphics.sprite)

local gfx <const> = playdate.graphics

local moduleWidth = 68
local moduleHeight = 38

local sineImage = playdate.graphics.image.new("Images/wf_sine")
local squareImage = playdate.graphics.image.new("Images/wf_square")
local triangleImage = playdate.graphics.image.new("Images/wf_triangle")
local sawtoothImage = playdate.graphics.image.new("Images/wf_sawtooth")
local poImage1 = playdate.graphics.image.new("Images/wf_po_1")
local poImage2 = playdate.graphics.image.new("Images/wf_po_2")
local poImage3 = playdate.graphics.image.new("Images/wf_po_3")

local modType = "MicroSynthMod"
local modSubtype = "audio_gen"

function MicroSynthMod:init(xx, yy, modId, onInit)
	MicroSynthMod.super.init(self)
	
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
	
	gfx.drawText("<", 22, 21)
	gfx.drawText(">", 66, 21)
	gSmallSocketImage:draw(18, 32)
	gSmallSocketImage:draw(62, 32)
	
	gfx.popContext()
	
	self:setImage(backgroundImage)
	self:moveTo(xx, yy)
	self:add()
	
	self.waveformSprite = gfx.sprite.new(sineImage)
	self.waveformSprite:moveTo(xx, yy)
	
	self.synthComponent = MicroSynthComponent(function(channel)
			self.onInit(self.modId, channel)
		end)

	self.waveformSprite:add()
		
	self.socketInVector = Vector(xx - 22, yy + 8)
	self.socketOutVector = Vector(xx + 22, yy + 8)
end

function MicroSynthMod:setInCable(patchCable)
	patchCable:setEnd(self.socketInVector.x, self.socketInVector.y, self.modId)
	self.inCable = patchCable
	self.synthComponent:setInCable(patchCable:getCable())
end

function MicroSynthMod:setOutCable(patchCable)
	self.outCable = patchCable
	patchCable:setStart(self.socketOutVector.x, self.socketOutVector.y, self.modId)
	self.synthComponent:setOutCable(patchCable:getCable())
end

function MicroSynthMod:collision(x, y)
	if x > self.x - (moduleWidth/2) and x < self.x + (moduleWidth/2) and y > self.y - (moduleHeight/2) and y < self.y + (moduleHeight/2) then
		return true
	else
		return false
	end
end

function MicroSynthMod:tryConnectGhostIn(x, y, ghostCable)
	if ghostCable:getStartModId() == self.modId then
		print("Can't connect a mod to itself...")
		return false
	elseif self.synthComponent:inConnected() then
		return false
	else
		ghostCable:setEnd(self.socketInVector.x, self.socketInVector.y)
		ghostCable:setGhostReceiveConnected()
		return true
	end
end

function MicroSynthMod:tryConnectGhostOut(x, y, ghostCable)
	if self.synthComponent:outConnected() then
		return false
	else
		ghostCable:setStart(self.socketOutVector.x, self.socketOutVector.y)
		ghostCable:setGhostSendConnected()
		return true
	end
end

function MicroSynthMod:type()
	return modType
end

function MicroSynthMod:handleModClick(tX, tY, listener)
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
			self.synthComponent:setWaveform(1)
		elseif action == "Square" then
			self.waveformSprite:setImage(squareImage)
			self.synthComponent:setWaveform(2)
		elseif action == "Triangle" then
			self.waveformSprite:setImage(triangleImage)
			self.synthComponent:setWaveform(4)
		elseif action == "Sawtooth" then
			self.waveformSprite:setImage(sawtoothImage)
			self.synthComponent:setWaveform(3)
		elseif action == "PO Phase" then
			self.waveformSprite:setImage(poImage1)
			self.synthComponent:setWaveform(5)
		elseif action == "PO Digital" then
			self.waveformSprite:setImage(poImage2)
			self.synthComponent:setWaveform(6)
		elseif action == "PO Vosim" then
			self.waveformSprite:setImage(poImage3)
			self.synthComponent:setWaveform(7)
		else
			if self.menuListener ~= nil then 
				self.menuListener(action) 
			end
		end
	end, self.menuIndex)
end

function MicroSynthMod:unplug(cableId)
	self.synthComponent:unplug(cableId)
end

function MicroSynthMod:evaporate(onDetachConnected)
	--first detach cables
	if self.synthComponent:outConnected() then
		onDetachConnected(self.outCable:getEndModId(), self.outCable:getCableId())
		self.synthComponent:unplugOut()
		self.outCable:evaporate()
	end
	
	if self.synthComponent:inConnected() then
		onDetachConnected(self.inCable:getEndModId(), self.inCable:getCableId())
		self.synthComponent:unplugIn()
		self.inCable:evaporate()
	end
	
	--then remove sprites
	playdate.graphics.sprite.removeSprites({self.waveformSprite})
	self:remove()
end

function MicroSynthMod.ghostModule()
	return buildGhostModule(moduleWidth, moduleHeight)
end

function MicroSynthMod:toState()
	local modState = {}
	modState.modId = self.modId
	modState.type = self:type()
	modState.x = self.x
	modState.y = self.y	
	modState.waveformType = self.synthComponent:getWaveformTypeIndex()
	return modState
end

function MicroSynthMod:fromState(modState)
	self.synthComponent:setWaveform(modState.waveformType)
end