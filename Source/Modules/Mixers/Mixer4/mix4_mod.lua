import 'Modules/mod_utils.lua'
import 'Modules/Mixers/Mixer4/mix4_component'
import 'Modules/Sprites/small_socket_sprite'

class('Mix4Mod').extends(playdate.graphics.sprite)

local gfx <const> = playdate.graphics

local moduleWidth = 105
local moduleHeight = 100
local grillDiam = 140

local modType = "Mix4Mod"
local modSubtype = "audio_effect"

function Mix4Mod:init(xx, yy, modId)
	Mix4Mod.super.init(self)
	
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
	
	-- Speaker grill:
	gfx.setColor(playdate.graphics.kColorBlack)
  for x = 1,4 do
		for y = 1,8 do
			gfx.fillCircleAtPoint(60 + (x * 12), 15 + (y * 11), 4) 
		end
	end
	
	gSmallSocketImage:draw(21, 23)
	gSmallSocketImage:draw(21, 45)
	gSmallSocketImage:draw(21, 67)
	gSmallSocketImage:draw(21, 89)
	
	gfx.popContext()
	
	self:setImage(backgroundImage)
	self:moveTo(xx, yy)
	self:add()
	
	self.mixer = Mixer4Component()

	local inSocketX = xx - (moduleWidth/2) + 15
	local inSocketYInc = 22
	self.in1SocketVector = Vector(inSocketX, yy - (moduleHeight/2) + inSocketYInc - 5)
	self.in2SocketVector = Vector(inSocketX, yy - (moduleHeight/2) + (inSocketYInc * 2) - 5)
	self.in3SocketVector = Vector(inSocketX, yy - (moduleHeight/2) + (inSocketYInc * 3) - 5)
	self.in4SocketVector = Vector(inSocketX, yy - (moduleHeight/2) + (inSocketYInc * 4) - 5)

	local encoderX = inSocketX + 22
	self.in1Encoder = RotaryEncoder(encoderX, yy - (moduleHeight/2) + inSocketYInc - 5, function(value) 
		self.mixer:trySetVolume(1, value)
	end)
	self.in2Encoder = RotaryEncoder(encoderX, yy - (moduleHeight/2) + (inSocketYInc * 2) - 5, function(value) 
		self.mixer:trySetVolume(2, value)
	end)
	self.in3Encoder = RotaryEncoder(encoderX, yy - (moduleHeight/2) + (inSocketYInc * 3) - 5, function(value) 
		self.mixer:trySetVolume(3, value)
	end)
	self.in4Encoder = RotaryEncoder(encoderX, yy - (moduleHeight/2) + (inSocketYInc * 4) - 5, function(value) 
		self.mixer:trySetVolume(4, value)
	end)

	self.encoders = {
		self.in1Encoder,
		self.in2Encoder,
		self.in3Encoder,
		self.in4Encoder
	}
	
end

function Mix4Mod:findClosestEncoder(x, y)
	local reticleVector = Vector(x, y)
	local closestDistance = 1000
	local closestIndex = -1
	for i=1,#self.encoders do
		local anEncoder = self.encoders[i]
		local encoderVector = Vector(anEncoder.x, anEncoder.y)
		local distance = reticleVector:distance(encoderVector)
		if distance < closestDistance then
			closestDistance = distance
			closestIndex = i
		end
	end
	
	return self.encoders[closestIndex]
end

function Mix4Mod:turn(x, y, change)
	local encoder = self:findClosestEncoder(x, y)
	encoder:turn(change)
end

function Mix4Mod:collision(x, y)
	if x > self.x - (self.width/2) and x < self.x + (self.width/2) and y > self.y - (self.height/2) and y < self.y + (self.height/2) then
		return true
	else
		return false
	end
end

function Mix4Mod:type()
	return modType
end

function Mix4Mod:setInCable(patchCable)
	if self.mixer:in1Free() then
		patchCable:setEnd(self.in1SocketVector.x, self.in1SocketVector.y, self.modId)
		self.mixer:setIn1Cable(patchCable:getCable())
		self.in1Cable = patchCable
	elseif self.mixer:in2Free() then
		patchCable:setEnd(self.in2SocketVector.x, self.in2SocketVector.y, self.modId)
		self.mixer:setIn2Cable(patchCable:getCable())
		self.in2Cable = patchCable
	elseif self.mixer:in3Free() then
		patchCable:setEnd(self.in3SocketVector.x, self.in3SocketVector.y, self.modId)
		self.mixer:setIn3Cable(patchCable:getCable())
		self.in3Cable = patchCable
	elseif self.mixer:in4Free() then
		patchCable:setEnd(self.in4SocketVector.x, self.in4SocketVector.y, self.modId)
		self.mixer:setIn4Cable(patchCable:getCable())
		self.in4Cable = patchCable
	end
end

function Mix4Mod:setChannel(channel)
	if channel == nil then
		print("Mix4Mod:setChannel() CHANNEL IS NIL")
	else
		print("Mix4Mod:setChannel() CHANNEL EXISTS!")
	end
	if self.mixer:in1Free() then
		print("IN 1 is FREE - setting channel")
		self.mixer:setChannel(1, channel)
	elseif self.mixer:in2Free() then
		self.mixer:setChannel(2, channel)
	elseif self.mixer:in3Free() then
		self.mixer:setChannel(3, channel)
	elseif self.mixer:in4Free() then
		self.mixer:setChannel(4, channel)
	end
end

function Mix4Mod:tryConnectGhostIn(x, y, ghostCable)
	local socketVector = nil
	if self.mixer:in1Free() then
		socketVector = self.in1SocketVector
	elseif self.mixer:in2Free() then
		socketVector = self.in2SocketVector
	elseif self.mixer:in3Free() then
		socketVector = self.in3SocketVector
	elseif self.mixer:in4Free() then
		socketVector = self.in4SocketVector
	end
	
	if socketVector ~= nil then
		ghostCable:setEnd(socketVector.x, socketVector.y)
		ghostCable:setGhostReceiveConnected()
		return true
	else
		return false
	end
end

function Mix4Mod:tryConnectGhostOut(x, y, ghostCable)
	return false
end

function Mix4Mod.ghostModule()
	return buildGhostModule(moduleWidth, moduleHeight)
end


function Mix4Mod:handleModClick(tX, tY, listener)
	self.menuListener = listener
	local actions = {
		{label = "About"},
		{label = "Remove"}
	}
	local contextMenu = ModuleMenu(actions)
	contextMenu:show(function(action, index) 
		self.menuIndex = index
		if action == "About" then
			local aboutPopup = ModAboutPopup("A mixer with 4 channels")
			aboutPopup:show()
		else
			if self.menuListener ~= nil then 
				self.menuListener(action) 
			end
		end
	end, self.menuIndex)
end

function Mix4Mod:unplug(cableId)
	if self.mixer:in1Connected() and self.mixer:getCableId(1) == cableId then
		self.mixer::unplug(1)
	elseif self.mixer:in2Connected() and self.mixer:getCableId(2) == cableId then
		self.mixer::unplug(2)
	elseif self.mixer:in3Connected() and self.mixer:getCableId(3) == cableId then
		self.mixer::unplug(3)
	elseif self.mixer:in4Connected() and self.mixer:getCableId(4) == cableId then
		self.mixer::unplug(4)
	end
end

function Mix4Mod:evaporate(onDetachConnected)
	--first detach cables
	if self.mixer:in1Connected() then
		onDetachConnected(self.in1Cable:getEndModId(), self.in1Cable:getCableId())
		self.mixer:unplugIn1()
		self.in1Cable:evaporate()
	end
	
	if self.mixer:in2Connected() then
		onDetachConnected(self.in2Cable:getEndModId(), self.in2Cable:getCableId())
		self.mixer:unplugIn2()
		self.in2Cable:evaporate()
	end
	
	if self.mixer:in3Connected() then
		onDetachConnected(self.in3Cable:getEndModId(), self.in3Cable:getCableId())
		self.mixer:unplugIn3()
		self.in3Cable:evaporate()
	end
	
	if self.mixer:in4Connected() then
		onDetachConnected(self.in4Cable:getEndModId(), self.in4Cable:getCableId())
		self.mixer:unplugIn4()
		self.in4Cable:evaporate()
	end
	
	for i=1,#self.encoders do
		self.encoders[i]:evaporate()
	end
	
	self.encoders = nil
	
	self:remove()
end