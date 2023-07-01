import 'Modules/mod_utils.lua'
import 'Modules/Mixers/Mixer8/mix8_component'
import 'Modules/Sprites/small_socket_sprite'

class('Mix8Mod').extends(playdate.graphics.sprite)

local gfx <const> = playdate.graphics

local moduleWidth = 130
local moduleHeight = 190

local modType = "Mix8Mod"
local modSubtype = "audio_effect"

function Mix8Mod:init(xx, yy, modId)
	Mix8Mod.super.init(self)
	
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
	playdate.graphics.setColor(playdate.graphics.kColorBlack)
  for x = 1,6 do
		for y = 1,16 do
			gfx.fillCircleAtPoint(60 + (x * 12), 15 + (y * 11), 4) 
		end
	end
	
	gSmallSocketImage:draw(21, 23)
	gSmallSocketImage:draw(21, 45)
	gSmallSocketImage:draw(21, 67)
	gSmallSocketImage:draw(21, 89)
	gSmallSocketImage:draw(21, 111)
	gSmallSocketImage:draw(21, 133)
	gSmallSocketImage:draw(21, 155)
	gSmallSocketImage:draw(21, 177)
	
	gfx.popContext()
	
	self:setImage(backgroundImage)
	self:moveTo(xx, yy)
	self:add()
	

	self.value = 0.0
	local inSocketX = xx - (moduleWidth/2) + 15
	local inSocketYInc = 22
	self.in1SocketVector = Vector(inSocketX, yy - (moduleHeight/2) + inSocketYInc - 5)
	self.in2SocketVector = Vector(inSocketX, yy - (moduleHeight/2) + (inSocketYInc * 2) - 5)
	self.in3SocketVector = Vector(inSocketX, yy - (moduleHeight/2) + (inSocketYInc * 3) - 5)
	self.in4SocketVector = Vector(inSocketX, yy - (moduleHeight/2) + (inSocketYInc * 4) - 5)
	self.in5SocketVector = Vector(inSocketX, yy - (moduleHeight/2) + (inSocketYInc * 5) - 5)
	self.in6SocketVector = Vector(inSocketX, yy - (moduleHeight/2) + (inSocketYInc * 6) - 5)
	self.in7SocketVector = Vector(inSocketX, yy - (moduleHeight/2) + (inSocketYInc * 7) - 5)
	self.in8SocketVector = Vector(inSocketX, yy - (moduleHeight/2) + (inSocketYInc * 8) - 5)
	
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
	self.in5Encoder = RotaryEncoder(encoderX, yy - (moduleHeight/2) + (inSocketYInc * 5) - 5, function(value) 
		self.mixer:trySetVolume(5, value)
	end)
	self.in6Encoder = RotaryEncoder(encoderX, yy - (moduleHeight/2) + (inSocketYInc * 6) - 5, function(value) 
		self.mixer:trySetVolume(6, value)
	end)
	self.in7Encoder = RotaryEncoder(encoderX, yy - (moduleHeight/2) + (inSocketYInc * 7) - 5, function(value) 
		self.mixer:trySetVolume(7, value)
	end)
	self.in8Encoder = RotaryEncoder(encoderX, yy - (moduleHeight/2) + (inSocketYInc * 8) - 5, function(value) 
		self.mixer:trySetVolume(8, value)
	end)
	
	self.encoders = {
		self.in1Encoder,
		self.in2Encoder,
		self.in3Encoder,
		self.in4Encoder,
		self.in5Encoder,
		self.in6Encoder,
		self.in7Encoder,
		self.in8Encoder
	}
	
	self.mixer = MixerComponent()
end

function Mix8Mod:findClosestEncoder(x, y)
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

function Mix8Mod:turn(x, y, change)
	local encoder = self:findClosestEncoder(x, y)
	encoder:turn(change)
end

function Mix8Mod:collision(x, y)
	if x > self.x - (self.width/2) and x < self.x + (self.width/2) and y > self.y - (self.height/2) and y < self.y + (self.height/2) then
		return true
	else
		return false
	end
end

function Mix8Mod:type()
	return modType
end

function Mix8Mod:setInCable(patchCable)
	if self.mixer:in1Free() then
		print("setInCable() self.mixer:in1Free()...")
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
	elseif self.mixer:in5Free() then
		patchCable:setEnd(self.in5SocketVector.x, self.in5SocketVector.y, self.modId)
		self.mixer:setIn5Cable(patchCable:getCable())
		self.in5Cable = patchCable
	elseif self.mixer:in6Free() then
		patchCable:setEnd(self.in6SocketVector.x, self.in6SocketVector.y, self.modId)
		self.mixer:setIn6Cable(patchCable:getCable())
		self.in6Cable = patchCable
	elseif self.mixer:in7Free() then
		patchCable:setEnd(self.in7SocketVector.x, self.in7SocketVector.y, self.modId)
		self.mixer:setIn7Cable(patchCable:getCable())
		self.in7Cable = patchCable
	elseif self.mixer:in8Free() then
		patchCable:setEnd(self.in8SocketVector.x, self.in8SocketVector.y, self.modId)
		self.mixer:setIn8Cable(patchCable:getCable())
		self.in8Cable = patchCable
	end
end

function Mix8Mod:setChannel(channel)
	if channel == nil then
		print("Mix8Mod:setChannel() CHANNEL IS NIL")
	else
		print("Mix8Mod:setChannel() CHANNEL EXISTS!")
	end
	if self.mixer:in1Free() then
		self.mixer:setChannel(1, channel)
	elseif self.mixer:in2Free() then
		self.mixer:setChannel(2, channel)
	elseif self.mixer:in3Free() then
		self.mixer:setChannel(3, channel)
	elseif self.mixer:in4Free() then
		self.mixer:setChannel(4, channel)
	elseif self.mixer:in5Free() then
		self.mixer:setChannel(5, channel)
	elseif self.mixer:in6Free() then
		self.mixer:setChannel(6, channel)
	elseif self.mixer:in7Free() then
		self.mixer:setChannel(7, channel)
	elseif self.mixer:in8Free() then
		self.mixer:setChannel(8, channel)
	end
end

function Mix8Mod:tryConnectGhostIn(x, y, ghostCable)
	local socketVector = nil
	if self.mixer:in1Free() then
		socketVector = self.in1SocketVector
	elseif self.mixer:in2Free() then
		socketVector = self.in2SocketVector
	elseif self.mixer:in3Free() then
		socketVector = self.in3SocketVector
	elseif self.mixer:in4Free() then
		socketVector = self.in4SocketVector
	elseif self.mixer:in5Free() then
		socketVector = self.in5SocketVector
	elseif self.mixer:in6Free() then
		socketVector = self.in6SocketVector
	elseif self.mixer:in7Free() then
		socketVector = self.in7SocketVector
	elseif self.mixer:in8Free() then
		socketVector = self.in8SocketVector
	end
	
	if socketVector ~= nil then
		ghostCable:setEnd(socketVector.x, socketVector.y)
		ghostCable:setGhostReceiveConnected()
		return true
	else
		return false
	end
end

function Mix8Mod:tryConnectGhostOut(x, y, ghostCable)
	return false
end

function Mix8Mod.ghostModule()
return buildGhostModule(moduleWidth, moduleHeight)
end

function Mix8Mod:handleModClick(tX, tY, listener)
	self.menuListener = listener
	local actions = {
		{label = "About"},
		{label = "Remove"}
	}
	local contextMenu = ModuleMenu(actions)
	contextMenu:show(function(action, index) 
		self.menuIndex = index
		if action == "About" then
			local aboutPopup = ModAboutPopup("A mixer with 8 channels")
			aboutPopup:show()
		else
			if self.menuListener ~= nil then 
				self.menuListener(action) 
			end
		end
	end, self.menuIndex)
end

function Mix8Mod:evaporate(onDetachConnected)
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
	
	if self.mixer:in5Connected() then
		onDetachConnected(self.in5Cable:getEndModId(), self.in5Cable:getCableId())
		self.mixer:unplugIn5()
		self.in5Cable:evaporate()
	end
	
	if self.mixer:in6Connected() then
		onDetachConnected(self.in6Cable:getEndModId(), self.in6Cable:getCableId())
		self.mixer:unplugIn6()
		self.in6Cable:evaporate()
	end
	
	if self.mixer:in7Connected() then
		onDetachConnected(self.in7Cable:getEndModId(), self.in7Cable:getCableId())
		self.mixer:unplugIn7()
		self.in7Cable:evaporate()
	end
	
	if self.mixer:in8Connected() then
		onDetachConnected(self.in8Cable:getEndModId(), self.in8Cable:getCableId())
		self.mixer:unplugIn8()
		self.in8Cable:evaporate()
	end
	
	for i=1,#self.encoders do
		self.encoders[i]:evaporate()
	end
	
	self.encoders = nil
	
	self:remove()
end