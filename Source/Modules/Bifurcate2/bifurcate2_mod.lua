--[[
	© 2023 Orllewin - All Rights Reserved.
	
	Two outputs, one input.
]]
import 'Modules/mod_utils.lua'
import 'Modules/Bifurcate2/bifurcate2_component'

class('Bifurcate2Mod').extends(playdate.graphics.sprite)

local gfx <const> = playdate.graphics

local moduleWidth = 32
local moduleHeight = 120

local modType = "Bifurcate2Mod"
local modSubtype = "clock_router"

function Bifurcate2Mod:init(xx, yy, modId)
	Bifurcate2Mod.super.init(self)
	
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
	gSocketOutImage:draw(20, 96)
	gSocketOutImage:draw(20, 58)
	gfx.popContext()
	
	self:setImage(backgroundImage)
	self:moveTo(xx, yy)
	self:add()

	self.value = 0.0
		
	self.socketInVector = Vector(xx, yy - (moduleHeight/2) + 23)
	self.socketOutAVector = Vector(xx, yy + 4)
	self.socketOutBVector = Vector(xx, yy + 48)
	
	self.bifurcateComponent = Bifurcate2Component()
end

function Bifurcate2Mod:setInCable(patchCable)
	patchCable:setEnd(self.socketInVector.x, self.socketInVector.y, self.modId)
	self.inCable = patchCable
	self.bifurcateComponent:setInCable(patchCable:getCable())
end

function Bifurcate2Mod:setOutCable(patchCable)
	if not self.bifurcateComponent:outAConnected() then
		patchCable:setStart(self.socketOutAVector.x, self.socketOutAVector.y, self.modId)
		self.outACable = patchCable
		self.bifurcateComponent:setOutACable(patchCable:getCable())
	elseif not self.bifurcateComponent:outBConnected() then
		patchCable:setStart(self.socketOutBVector.x, self.socketOutBVector.y, self.modId)
		self.outBCable = patchCable
		self.bifurcateComponent:setOutBCable(patchCable:getCable())
	end
end

function Bifurcate2Mod:collision(x, y)
	if x > self.x - (moduleWidth/2) and x < self.x + (moduleWidth/2) and y > self.y - (moduleHeight/2) and y < self.y + (moduleHeight/2) then
		return true
	else
		return false
	end
end

function Bifurcate2Mod:tryConnectGhostIn(x, y, ghostCable)
	if ghostCable:getStartModId() == self.modId then
		print("Can't connect a mod to itself...")
		return false
	elseif self.bifurcateComponent:inConnected() then
		return false
	else
		ghostCable:setEnd(self.socketInVector.x, self.socketInVector.y)
		ghostCable:setGhostReceiveConnected()
		return true
	end
end

function Bifurcate2Mod:tryConnectGhostOut(x, y, ghostCable)
	if not self.bifurcateComponent:outAConnected() then
		ghostCable:setStart(self.socketOutAVector.x, self.socketOutAVector.y, self.modId)
		ghostCable:setGhostSendConnected()
		return true
	elseif not self.bifurcateComponent:outBConnected() then
		ghostCable:setStart(self.socketOutBVector.x, self.socketOutBVector.y, self.modId)
		ghostCable:setGhostSendConnected()
		return true
	else
		return false
	end
end

function Bifurcate2Mod:type()
	return modType
end

function Bifurcate2Mod:handleModClick(tX, tY, listener)
	self.menuListener = listener
	local actions = {
		{label = "About"},
		{label = "Remove"}
	}
	local contextMenu = ModuleMenu(actions)
	contextMenu:show(function(action) 
		if action == "About" then
			local aboutPopup = ModAboutPopup("Splits / duplicates a clock signal into two.")
			aboutPopup:show()
		else
			if self.menuListener ~= nil then 
				self.menuListener(action) 
			end
		end
	end)
end

function Bifurcate2Mod:evaporate(onDetachConnected)
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
	
	self:remove()
end

function Bifurcate2Mod.ghostModule()
	return buildGhostModule(moduleWidth, moduleHeight)
end

function Bifurcate2Mod:toState()
	local modState = {}
	modState.modId = self.modId
	modState.type = self:type()
	modState.x = self.x
	modState.y = self.y
	
	return modState
end

function Bifurcate2Mod:fromState(modState)
	-- noop
end