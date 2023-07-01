import 'Modules/mod_utils.lua'
import 'CoracleViews/vertical_slider'
import 'Modules/Mixers/Mixer8Sliders/mix8sliders_component'
import 'Modules/Sprites/small_socket_sprite'

class('Mix4SliderMod').extends(playdate.graphics.sprite)

local gfx <const> = playdate.graphics

local moduleWidth = 150
local moduleHeight = 100
local grillDiam = 140

local modType = "Mix4SliderMod"
local modSubtype = "audio_effect"

function Mix4SliderMod:init(xx, yy, modId)
	Mix4SliderMod.super.init(self)
	
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
  for x = 1,4 do
		for y = 1,8 do
			gfx.fillCircleAtPoint(105 + (x * 12), 15 + (y * 11), 4) 
		end
	end
	
	local socketXInc = 22
	gSmallSocketImage:draw(21, 20)
	gSmallSocketImage:draw(21 + socketXInc, 20)
	gSmallSocketImage:draw(21 + (socketXInc * 2), 20)
	gSmallSocketImage:draw(21 + (socketXInc * 3), 20)
	
	gfx.popContext()
	
	self:setImage(backgroundImage)
	self:moveTo(xx, yy)
	self:add()
	
	local inSocketX = xx - (moduleWidth/2) + 15
	local inSocketY = yy - (moduleHeight/2) + 10
	self.in1SocketVector = Vector(inSocketX, inSocketY)
	self.in2SocketVector = Vector(inSocketX + socketXInc, inSocketY)
	self.in3SocketVector = Vector(inSocketX + (socketXInc * 2), inSocketY)
	self.in4SocketVector = Vector(inSocketX + (socketXInc * 3), inSocketY)
	
	local sliderXInc = 22
	self.slider1 = VerticalSlider(xx - (moduleWidth/2) + 15, yy + 10, 0.0, function(value) 
		self.mixer:trySetVolume(1, value)
	end)
	
	self.slider2 = VerticalSlider(xx - (moduleWidth/2) + 15 + sliderXInc, yy + 10, 0.0, function(value) 
		self.mixer:trySetVolume(2, value)
	end)
	
	self.slider3 = VerticalSlider(xx - (moduleWidth/2) + 15 + (sliderXInc * 2), yy + 10, 0.0, function(value) 
		self.mixer:trySetVolume(3, value)
	end)
	
	self.slider4 = VerticalSlider(xx - (moduleWidth/2) + 15 + (sliderXInc * 3), yy + 10, 0.0, function(value) 
		self.mixer:trySetVolume(4, value)
	end)
			
	self.sliders = {
		self.slider1,
		self.slider2,
		self.slider3,
		self.slider4
	}
	
	self.mixer = Mixer8SlidersComponent()
end

function Mix4SliderMod:findClosestSlider(x, y)
	local reticleVector = Vector(x, y)
	local closestDistance = 1000
	local closestIndex = -1
	for i=1,#self.sliders do
		local aSlider = self.sliders[i]
		local sliderVector = Vector(aSlider.x, aSlider.y)
		local distance = reticleVector:distance(sliderVector)
		if distance < closestDistance then
			closestDistance = distance
			closestIndex = i
		end
	end
	
	return self.sliders[closestIndex]
end

function Mix4SliderMod:turn(x, y, change)
	local slider = self:findClosestSlider(x, y)
	slider:turn(change)
end

function Mix4SliderMod:collision(x, y)
	if x > self.x - (self.width/2) and x < self.x + (self.width/2) and y > self.y - (self.height/2) and y < self.y + (self.height/2) then
		return true
	else
		return false
	end
end

function Mix4SliderMod:type()
	return modType
end

function Mix4SliderMod:setInCable(patchCable)
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
	end
end

function Mix4SliderMod:setChannel(channel)
	if channel == nil then
		print("Mix4SliderMod:setChannel() CHANNEL IS NIL")
	else
		print("Mix4SliderMod:setChannel() CHANNEL EXISTS!")
	end
	if self.mixer:in1Free() then
		self.mixer:setChannel(1, channel)
	elseif self.mixer:in2Free() then
		self.mixer:setChannel(2, channel)
	elseif self.mixer:in3Free() then
		self.mixer:setChannel(3, channel)
	elseif self.mixer:in4Free() then
		self.mixer:setChannel(4, channel)
	end
end

function Mix4SliderMod:tryConnectGhostIn(x, y, ghostCable)
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

function Mix4SliderMod:tryConnectGhostOut(x, y, ghostCable)
	return false
end

function Mix4SliderMod.ghostModule()
return buildGhostModule(moduleWidth, moduleHeight)
end

function Mix4SliderMod:handleModClick(tX, tY, listener)
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

function Mix4SliderMod:evaporate(onDetachConnected)
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
	
	for i=1,#self.sliders do
		self.sliders[i]:evaporate()
	end
	
	self.sliders = nil
	
	self:remove()
end