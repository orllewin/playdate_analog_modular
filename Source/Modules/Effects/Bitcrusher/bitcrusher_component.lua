--[[
	© 2023 Orllewin - All Rights Reserved.
]]

class('BitcrusherComponent').extends()

function BitcrusherComponent:init()
	BitcrusherComponent.super.init(self)
	
	self.filter = playdate.sound.bitcrusher.new()
	self.filter:setMix(0.5)
	self.filter:setAmount(0.0)
	self.filter:setUndersampling(0.0)
	
	self.outSocket = Socket("bitcrusher_mod_out", socket_send)
	self.inSocket = Socket("bitcrusher_mod_in", socket_receive)
end

function BitcrusherComponent:setChannel(channel)
	channel:addEffect(self.filter)
end

function BitcrusherComponent:removeChannel(channel)
	channel:removeEffect(self.filter)
end

function BitcrusherComponent:setMix(value)
	print("BitcrusherComponent:setMix: " .. value)
	self.filter:setMix(value)
end

function BitcrusherComponent:setAmount(value)
	print("BitcrusherComponent:setAmount: " .. value)
	self.filter:setAmount(value)
end

function BitcrusherComponent:setUndersampling(value)
	print("BitcrusherComponent:setUndersampling: " .. value)
	self.filter:setUndersampling(value)
end

function BitcrusherComponent:inConnected()
	return self.inSocket:connected()
end

function BitcrusherComponent:outConnected()
	return self.outSocket:connected()
end

function BitcrusherComponent:unplugIn(cableId)
	self.inSocket:setCable(nil)
end

function BitcrusherComponent:unplugOut(cableId)
	self.outSocket:setCable(nil)
end

function BitcrusherComponent:setInCable(cable)
	self.inSocket:setCable(cable)
end

function BitcrusherComponent:setOutCable(cable)
	self.outSocket:setCable(cable)
end