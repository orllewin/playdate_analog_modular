--[[

]]--
class('Mixer4SlidersComponent').extends()

function Mixer4SlidersComponent:init()
	Mixer4SlidersComponent.super.init(self)
	
	self.outSocket = Socket("mixer_out", socket_send)
	
	self.in1Socket = Socket("mixer_in_1", socket_receive)
	self.in2Socket = Socket("mixer_in_2", socket_receive)
	self.in3Socket = Socket("mixer_in_3", socket_receive)
	self.in4Socket = Socket("mixer_in_4", socket_receive)
end

function Mixer4SlidersComponent:trySetVolume(index, value)
	if index == 1 then
		if self:in1Connected() then self:getChannel(1):setVolume(value) end
	elseif index == 2 then
		if self:in2Connected() then self:getChannel(2):setVolume(value) end
	elseif index == 3 then
		if self:in3Connected() then self:getChannel(3):setVolume(value) end
	elseif index == 4 then
		if self:in4Connected() then self:getChannel(4):setVolume(value) end
	end
end

function Mixer4SlidersComponent:setChannel(index, channel)
	if index == 1 then
		self.channel1 = channel
	elseif index == 2 then
		self.channel2 = channel
	elseif index == 3 then
		self.channel3 = channel
	elseif index == 4 then
		self.channel4 = channel
	end
end

function Mixer4SlidersComponent:getChannel(index)
  if index == 1 then
		return self.channel1
	elseif index == 2 then
		return self.channel2
	elseif index == 3 then
		return self.channel3
	elseif index == 4 then
		return self.channel4
	end
end

function Mixer4SlidersComponent:setIn1Cable(cable)
	print("Mixer4SlidersComponent:setIn1Cable....")
	self.in1Socket:setCable(cable)
end

function Mixer4SlidersComponent:setIn2Cable(cable)
	self.in2Socket:setCable(cable)
end

function Mixer4SlidersComponent:setIn3Cable(cable)
	self.in3Socket:setCable(cable)
end

function Mixer4SlidersComponent:setIn4Cable(cable)
	self.in4Socket:setCable(cable)
end

-- -- ----
function Mixer4SlidersComponent:unplugOut()
	self.outSocket:setCable(nil)
end

function Mixer4SlidersComponent:unplugIn1()
	self.in1Socket:setCable(nil)
end

function Mixer4SlidersComponent:unplugIn2()
	self.in2Socket:setCable(nil)
end

function Mixer4SlidersComponent:unplugIn3()
	self.in3Socket:setCable(nil)
end

function Mixer4SlidersComponent:unplugIn4()
	self.in4Socket:setCable(nil)
end

-- --- -----
function Mixer4SlidersComponent:outConnected()
	return self.outSocket:connected()
end

function Mixer4SlidersComponent:in1Connected()
	return self.in1Socket:connected()
end

function Mixer4SlidersComponent:in2Connected()
	return self.in2Socket:connected()
end

function Mixer4SlidersComponent:in3Connected()
	return self.in3Socket:connected()
end

function Mixer4SlidersComponent:in4Connected()
	return self.in4Socket:connected()
end

--- -----------------

function Mixer4SlidersComponent:in1Free()
	return not self.in1Socket:connected()
end

function Mixer4SlidersComponent:in2Free()
	return not self.in2Socket:connected()
end

function Mixer4SlidersComponent:in3Free()
	return not self.in3Socket:connected()
end

function Mixer4SlidersComponent:in4Free()
	return not self.in4Socket:connected()
end