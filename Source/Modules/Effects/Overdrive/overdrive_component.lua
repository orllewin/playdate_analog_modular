--[[

	
]]--

class('OverdriveComponent').extends()

function OverdriveComponent:init()
	OverdriveComponent.super.init(self)
	
	self.filter = playdate.sound.overdrive.new()
	self.filter:setMix(0.5)
	self.filter:setGain(0.5)
	self.filter:setLimit(0.5)
	
	self.outSocket = Socket("overdrive_mod_out", socket_send)
	self.inSocket = Socket("overdrive_mod_in", socket_receive)
end

function OverdriveComponent:setChannel(channel)
	channel:addEffect(self.filter)
end

function OverdriveComponent:removeChannel(channel)
	channel:removeEffect(self.filter)
end

function OverdriveComponent:setMix(value)
	print("OverdriveComponent:setMix: " .. value)
	self.filter:setMix(value)
end

function OverdriveComponent:setGain(value)
	print("OverdriveComponent:setGain: " .. value)
	self.filter:setGain(value)
end

function OverdriveComponent:setLimit(value)
	print("OverdriveComponent:setLimit: " .. value)
	self.filter:setLimit(value)
end

function OverdriveComponent:inConnected()
	return self.inSocket:connected()
end

function OverdriveComponent:outConnected()
	return self.outSocket:connected()
end

function OverdriveComponent:unplugIn(cableId)
	self.inSocket:setCable(nil)
end

function OverdriveComponent:unplugOut(cableId)
	self.outSocket:setCable(nil)
end

function OverdriveComponent:setInCable(cable)
	self.inSocket:setCable(cable)
end

function OverdriveComponent:setOutCable(cable)
	self.outSocket:setCable(cable)
end