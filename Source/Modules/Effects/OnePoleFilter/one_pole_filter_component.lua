--[[
	© 2023 Orllewin - All Rights Reserved.
]]

class('OnePoleFilterComponent').extends()

function OnePoleFilterComponent:init(id, listener)
	OnePoleFilterComponent.super.init(self)
	
	self.id = id
	self.listener = listener
	
	self.filter = playdate.sound.onepolefilter.new()
	
	self.outSocket = Socket("one_pole_out", socket_send)
	
	self.inSocket = Socket("one_pole_in", socket_receive, function(event) 
		if event ~= nil then
			
		end
	end)
end

function OnePoleFilterComponent:setChannel(channel)
	channel:addEffect(self.filter)
end

function OnePoleFilterComponent:removeChannel(channel)
	channel:removeEffect(self.filter)
end

function OnePoleFilterComponent:setMix(value)
	self.filter:setMix(value)
end

function OnePoleFilterComponent:setCutoffFreq(value)
	self.filter:setParameter(map(value, 0.0, 1.0, 20, 10000))
end

function OnePoleFilterComponent:inConnected()
	return self.inSocket:connected()
end

function OnePoleFilterComponent:outConnected()
	return self.outSocket:connected()
end

function OnePoleFilterComponent:unplugIn(cableId)
	self.inSocket:setCable(nil)
end

function OnePoleFilterComponent:unplugOut(cableId)
	self.outSocket:setCable(nil)
end

function OnePoleFilterComponent:setInCable(cable)
	self.inSocket:setCable(cable)
end

function OnePoleFilterComponent:setOutCable(cable)
	self.outSocket:setCable(cable)
end