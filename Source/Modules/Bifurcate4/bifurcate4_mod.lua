--[[
	© 2023 Orllewin - All Rights Reserved.
	
	Four outputs, one input.
]]
import 'Modules/mod_utils.lua'
import 'Modules/Bifurcate4/bifurcate4_component'

class('Bifurcate4Mod').extends(playdate.graphics.sprite)

local gfx <const> = playdate.graphics

local moduleWidth = 56
local moduleHeight = 120

local modType = "Bifurcate4Mod"
local modSubtype = "clock_router"

function Bifurcate4Mod:init(xx, yy, modId)
	Bifurcate4Mod.super.init(self)
	
	if modId == nil then
		self.modId = modType .. playdate.getSecondsSinceEpoch()
	else
		self.modId = modId
	end
	
	self.modType = modType
	self.modSubtype = modSubtype
	
	local backgroundImage = generateModBackgroundWithShadow(moduleWidth, moduleHeight)
	
	gfx.pushContext(backgroundImage)	
	gSocketInImage:draw(20, 20)
	gSocketOutImage:draw(20, 58)--a
  gSocketOutImage:draw(44, 58)--b
	gSocketOutImage:draw(20, 96)--c
	gSocketOutImage:draw(44, 96)--b
	gfx.popContext()
	
	self:setImage(backgroundImage)
	self:moveTo(xx, yy)
	self:add()
		
	self.socketInVector = Vector(xx - 10, yy - 35)
	self.socketOutAVector = Vector(xx - 13, yy + 3)
	self.socketOutBVector = Vector(xx + 9, yy + 3)
	self.socketOutCVector = Vector(xx - 13, yy + 39)
	self.socketOutDVector = Vector(xx + 9, yy + 39)
	
	self.bifurcateComponent = Bifurcate4Component()
end

function Bifurcate4Mod:setInCable(patchCable)
	patchCable:setEnd(self.socketInVector.x, self.socketInVector.y, self.modId)
	self.inCable = patchCable
	self.bifurcateComponent:setInCable(patchCable:getCable())
end

function Bifurcate4Mod:setOutCable(patchCable)
	if not self.bifurcateComponent:outAConnected() then
		patchCable:setStart(self.socketOutAVector.x, self.socketOutAVector.y, self.modId)
		self.outACable = patchCable
		self.bifurcateComponent:setOutACable(patchCable:getCable())
	elseif not self.bifurcateComponent:outBConnected() then
		patchCable:setStart(self.socketOutBVector.x, self.socketOutBVector.y, self.modId)
		self.outBCable = patchCable
		self.bifurcateComponent:setOutBCable(patchCable:getCable())
	elseif not self.bifurcateComponent:outCConnected() then
		patchCable:setStart(self.socketOutCVector.x, self.socketOutCVector.y, self.modId)
		self.outCCable = patchCable
		self.bifurcateComponent:setOutCCable(patchCable:getCable())
	elseif not self.bifurcateComponent:outDConnected() then
		patchCable:setStart(self.socketOutDVector.x, self.socketOutDVector.y, self.modId)
		self.outDCable = patchCable
		self.bifurcateComponent:setOutDCable(patchCable:getCable())
	end
end

function Bifurcate4Mod:collision(x, y)
	if x > self.x - (moduleWidth/2) and x < self.x + (moduleWidth/2) and y > self.y - (moduleHeight/2) and y < self.y + (moduleHeight/2) then
		return true
	else
		return false
	end
end

function Bifurcate4Mod:tryConnectGhostIn(x, y, ghostCable)
	if ghostCable:getStartModId() == self.modId then
		print("Can't connect a mod to itself...")
		return false
	end
	if not self.bifurcateComponent:inConnected() then
		ghostCable:setEnd(self.socketInVector.x, self.socketInVector.y)
		ghostCable:setGhostReceiveConnected()
		return true
	else
		return false
	end
end

function Bifurcate4Mod:tryConnectGhostOut(x, y, ghostCable)
	if not self.bifurcateComponent:outAConnected() then
		ghostCable:setStart(self.socketOutAVector.x, self.socketOutAVector.y, self.modId)
		ghostCable:setGhostSendConnected()
		return true
	elseif not self.bifurcateComponent:outBConnected() then
		ghostCable:setStart(self.socketOutBVector.x, self.socketOutBVector.y, self.modId)
		ghostCable:setGhostSendConnected()
		return true
	elseif not self.bifurcateComponent:outCConnected() then
		ghostCable:setStart(self.socketOutCVector.x, self.socketOutCVector.y, self.modId)
		ghostCable:setGhostSendConnected()
		return true
	elseif not self.bifurcateComponent:outDConnected() then
		ghostCable:setStart(self.socketOutDVector.x, self.socketOutDVector.y, self.modId)
		ghostCable:setGhostSendConnected()
		return true
	else
		return false
	end

	
end

function Bifurcate4Mod:type()
	return modType
end

function Bifurcate4Mod:handleModClick(tX, tY, listener)
	self.menuListener = listener
	local actions = {
		{label = "About"},
		{label = "Remove"}
	}
	local contextMenu = ModuleMenu(actions)
	contextMenu:show(function(action) 
		if action == "About" then
			local aboutPopup = ModAboutPopup("Splits / duplicates a clock signal into four.")
			aboutPopup:show()
		else
			if self.menuListener ~= nil then 
				self.menuListener(action) 
			end
		end
	end)
end

function Bifurcate4Mod:evaporate(onDetachConnected)
	--first detach cables
	if self.bifurcateComponent:inConnected() then
		onDetachConnected(self.inCable:getStartModId(), self.inCable:getCableId())
		self.bifurcateComponent:unplugIn()
		self.inCable:evaporate()
		self.inCable = nil
	end
	
	if self.bifurcateComponent:outAConnected() then
		onDetachConnected(self.outACable:getEndModId(), self.outACable:getCableId())
		self.bifurcateComponent:unplugOutA()
		self.outACable:evaporate()
		self.outACable = nil
	end
	
	if self.bifurcateComponent:outBConnected() then
		onDetachConnected(self.outBCable:getEndModId(), self.outBCable:getCableId())
		self.bifurcateComponent:unplugOutB()
		self.outBCable:evaporate()
		self.outBCable = nil
	end
	
	if self.bifurcateComponent:outCConnected() then
		onDetachConnected(self.outCCable:getEndModId(), self.outCCable:getCableId())
		self.bifurcateComponent:unplugOutC()
		self.outCCable:evaporate()
		self.outCCable = nil
	end
	
	if self.bifurcateComponent:outDConnected() then
		onDetachConnected(self.outDCable:getEndModId(), self.outDCable:getCableId())
		self.bifurcateComponent:unplugOutD()
		self.outDCable:evaporate()
		self.outDCable = nil
	end
	
	self:remove()
end

function Bifurcate4Mod.ghostModule()
	return buildGhostModule(moduleWidth, moduleHeight)
end

function Bifurcate4Mod:toState()
	local modState = {}
	modState.modId = self.modId
	modState.type = self:type()
	modState.x = self.x
	modState.y = self.y
	
	return modState
end

function Bifurcate4Mod:fromState(modState)
	-- noop
end