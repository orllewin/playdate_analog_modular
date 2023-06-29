--[[

]]--
class('Mixer8SlidersComponent').extends()

function Mixer8SlidersComponent:init()
	Mixer8SlidersComponent.super.init(self)
	
	self.outSocket = Socket("mixer_out", socket_send)
	
	self.in1Socket = Socket("mixer_in_1", socket_receive)
	self.in2Socket = Socket("mixer_in_2", socket_receive)
	self.in3Socket = Socket("mixer_in_3", socket_receive)
	self.in4Socket = Socket("mixer_in_4", socket_receive)
	self.in5Socket = Socket("mixer_in_5", socket_receive)
	self.in6Socket = Socket("mixer_in_6", socket_receive)
	self.in7Socket = Socket("mixer_in_7", socket_receive)
	self.in8Socket = Socket("mixer_in_8", socket_receive)
end

function Mixer8SlidersComponent:trySetVolume(index, value)
	if index == 1 then
		if self:in1Connected() then self:getChannel(1):setVolume(value) end
	elseif index == 2 then
		if self:in2Connected() then self:getChannel(2):setVolume(value) end
	elseif index == 3 then
		if self:in3Connected() then self:getChannel(3):setVolume(value) end
	elseif index == 4 then
		if self:in4Connected() then self:getChannel(4):setVolume(value) end
	elseif index == 5 then
		if self:in5Connected() then self:getChannel(5):setVolume(value) end
	elseif index == 6 then
		if self:in6Connected() then self:getChannel(6):setVolume(value) end
	elseif index == 7 then
		if self:in7Connected() then self:getChannel(7):setVolume(value) end
	elseif index == 8 then
		if self:in8Connected() then self:getChannel(8):setVolume(value) end
	end
end

function Mixer8SlidersComponent:setChannel(index, channel)
	if index == 1 then
		self.channel1 = channel
	elseif index == 2 then
		self.channel2 = channel
	elseif index == 3 then
		self.channel3 = channel
	elseif index == 4 then
		self.channel4 = channel
	elseif index == 5 then
		self.channel5 = channel
	elseif index == 6 then
		self.channel6 = channel
	elseif index == 7 then
		self.channel7 = channel
	elseif index == 8 then
		self.channel8 = channel
	end
end

function Mixer8SlidersComponent:getChannel(index)
  if index == 1 then
		return self.channel1
	elseif index == 2 then
		return self.channel2
	elseif index == 3 then
		return self.channel3
	elseif index == 4 then
		return self.channel4
	elseif index == 5 then
		return self.channel5
	elseif index == 6 then
		return self.channel6
	elseif index == 7 then
		return self.channel7
	elseif index == 8 then
		return self.channel8
	end
end

function Mixer8SlidersComponent:setIn1Cable(cable)
	print("Mixer8SlidersComponent:setIn1Cable....")
	self.in1Socket:setCable(cable)
end

function Mixer8SlidersComponent:setIn2Cable(cable)
	self.in2Socket:setCable(cable)
end

function Mixer8SlidersComponent:setIn3Cable(cable)
	self.in3Socket:setCable(cable)
end

function Mixer8SlidersComponent:setIn4Cable(cable)
	self.in4Socket:setCable(cable)
end

function Mixer8SlidersComponent:setIn5Cable(cable)
	self.in5Socket:setCable(cable)
end

function Mixer8SlidersComponent:setIn6Cable(cable)
	self.in6Socket:setCable(cable)
end

function Mixer8SlidersComponent:setIn7Cable(cable)
	self.in7Socket:setCable(cable)
end

function Mixer8SlidersComponent:setIn8Cable(cable)
	self.in8Socket:setCable(cable)
end

-- -- ----
function Mixer8SlidersComponent:unplugOut()
	self.outSocket:setCable(nil)
end

function Mixer8SlidersComponent:unplugIn1()
	self.in1Socket:setCable(nil)
end

function Mixer8SlidersComponent:unplugIn2()
	self.in2Socket:setCable(nil)
end

function Mixer8SlidersComponent:unplugIn3()
	self.in3Socket:setCable(nil)
end

function Mixer8SlidersComponent:unplugIn4()
	self.in4Socket:setCable(nil)
end

function Mixer8SlidersComponent:unplugIn5()
	self.in5Socket:setCable(nil)
end

function Mixer8SlidersComponent:unplugIn6()
	self.in6Socket:setCable(nil)
end

function Mixer8SlidersComponent:unplugIn7()
	self.in7Socket:setCable(nil)
end

function Mixer8SlidersComponent:unplugOut8()
	self.in8Socket:setCable(nil)
end
-- --- -----
function Mixer8SlidersComponent:outConnected()
	return self.outSocket:connected()
end

function Mixer8SlidersComponent:in1Connected()
	return self.in1Socket:connected()
end

function Mixer8SlidersComponent:in2Connected()
	return self.in2Socket:connected()
end

function Mixer8SlidersComponent:in3Connected()
	return self.in3Socket:connected()
end

function Mixer8SlidersComponent:in4Connected()
	return self.in4Socket:connected()
end

function Mixer8SlidersComponent:in5Connected()
	return self.in5Socket:connected()
end

function Mixer8SlidersComponent:in6Connected()
	return self.in6Socket:connected()
end

function Mixer8SlidersComponent:in7Connected()
	return self.in7Socket:connected()
end

function Mixer8SlidersComponent:in8Connected()
	return self.in8Socket:connected()
end

function Mixer8SlidersComponent:in1Free()
	return not self.in1Socket:connected()
end

function Mixer8SlidersComponent:in2Free()
	return not self.in2Socket:connected()
end

function Mixer8SlidersComponent:in3Free()
	return not self.in3Socket:connected()
end

function Mixer8SlidersComponent:in4Free()
	return not self.in4Socket:connected()
end

function Mixer8SlidersComponent:in5Free()
	return not self.in5Socket:connected()
end

function Mixer8SlidersComponent:in6Free()
	return not self.in6Socket:connected()
end

function Mixer8SlidersComponent:in7Free()
	return not self.in7Socket:connected()
end

function Mixer8SlidersComponent:in8Free()
	return not self.in8Socket:connected()
end
