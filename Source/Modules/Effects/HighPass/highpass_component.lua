--[[
0 to 20000
	
]]--

class('HighpassComponent').extends()

function HighpassComponent:init()
	HighpassComponent.super.init(self)
	
	self.filter = playdate.sound.twopolefilter.new(playdate.sound.kFilterHighPass)
	self.filter:setMix(0.5)
	self.filter:setFrequency(5000)
	self.filter:setResonance(0.5)
	
	self.outSocket = Socket("lowpass_mod_out", socket_send)
	self.inSocket = Socket("lowpass_mod_in", socket_receive)
end

function HighpassComponent:setChannel(channel)
	channel:addEffect(self.filter)
end

function HighpassComponent:removeChannel(channel)
	channel:removeEffect(self.filter)
end

function HighpassComponent:setMix(value)
	print("HighpassComponent:setMix: " .. value)
	self.filter:setMix(value)
end

function HighpassComponent:setFrequency(value)
	print("HighpassComponent:setFrequency: " .. value)
	self.filter:setFrequency(value)
end

function HighpassComponent:setResonance(value)
	print("HighpassComponent:setResonance: " .. value)
	self.filter:setResonance(value)
end

function HighpassComponent:inConnected()
	return self.inSocket:connected()
end

function HighpassComponent:outConnected()
	return self.outSocket:connected()
end

function HighpassComponent:unplugIn(cableId)
	self.inSocket:setCable(nil)
end

function HighpassComponent:unplugOut(cableId)
	self.outSocket:setCable(nil)
end

function HighpassComponent:setInCable(cable)
	self.inSocket:setCable(cable)
end

function HighpassComponent:setOutCable(cable)
	self.outSocket:setCable(cable)
end