--[[

	
]]--

class('RingModulatorComponent').extends()

function RingModulatorComponent:init(id, listener)
	RingModulatorComponent.super.init(self)
	
	self.id = id
	self.listener = listener
	
	self.filter = playdate.sound.ringmod.new()
	
	self.outSocket = Socket("ring_mod_out", socket_send)
	
	self.inSocket = Socket("ring_mod_in", socket_receive, function(event) 
		if event ~= nil then
			
		end
	end)
end

function RingModulatorComponent:setChannel(channel)
	channel:addEffect(self.filter)
end

function RingModulatorComponent:removeChannel(channel)
	channel:removeEffect(self.filter)
end

function RingModulatorComponent:setMix(value)
	self.filter:setMix(value)
end

function RingModulatorComponent:setFrequency(value)
	self.filter:setFrequency(map(value, 0.0, 1.0, 20, 10000))
end

function RingModulatorComponent:inConnected()
	return self.inSocket:connected()
end

function RingModulatorComponent:outConnected()
	return self.outSocket:connected()
end

function RingModulatorComponent:unplugIn(cableId)
	self.inSocket:setCable(nil)
end

function RingModulatorComponent:unplugOut(cableId)
	self.outSocket:setCable(nil)
end

function RingModulatorComponent:setInCable(cable)
	self.inSocket:setCable(cable)
end

function RingModulatorComponent:setOutCable(cable)
	self.outSocket:setCable(cable)
end