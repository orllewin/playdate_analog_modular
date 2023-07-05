--[[
0 to 20000
	
]]--

class('LowpassComponent').extends()

function LowpassComponent:init()
	LowpassComponent.super.init(self)
	
	self.filter = playdate.sound.twopolefilter.new(playdate.sound.kFilterLowPass)
	self.filter:setMix(0.5)
	self.filter:setFrequency(5000)
	self.filter:setResonance(0.5)
	
	self.outSocket = Socket("lowpass_mod_out", socket_send)
	self.inSocket = Socket("lowpass_mod_in", socket_receive)
end

function LowpassComponent:setChannel(channel)
	channel:addEffect(self.filter)
end

function LowpassComponent:removeChannel(channel)
	channel:removeEffect(self.filter)
end

function LowpassComponent:setMix(value)
	print("LowpassComponent:setMix: " .. value)
	self.filter:setMix(value)
end

function LowpassComponent:setFrequency(value)
	print("LowpassComponent:setFrequency: " .. value)
	self.filter:setFrequency(value)
end

function LowpassComponent:setResonance(value)
	print("LowpassComponent:setResonance: " .. value)
	self.filter:setResonance(value)
end

function LowpassComponent:inConnected()
	return self.inSocket:connected()
end

function LowpassComponent:outConnected()
	return self.outSocket:connected()
end

function LowpassComponent:unplugIn(cableId)
	self.inSocket:setCable(nil)
end

function LowpassComponent:unplugOut(cableId)
	self.outSocket:setCable(nil)
end

function LowpassComponent:setInCable(cable)
	self.inSocket:setCable(cable)
end

function LowpassComponent:setOutCable(cable)
	self.outSocket:setCable(cable)
end