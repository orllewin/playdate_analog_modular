--[[
	© 2023 Orllewin - All Rights Reserved.
]]

class('ClockDoublerComponent').extends()

local fmod <const> = math.fmod

function ClockDoublerComponent:init()
	ClockDoublerComponent.super.init(self)
	
	self.outSocket = Socket("clock_doubler_out", socket_send)	
	self.inSocket = Socket("clock_doubler_in", socket_receive, function(event) 
		self:onInEvent(event)
	end)
end

function ClockDoublerComponent:onInEvent(event)
	local doubleBPM = event:getValue() * 2

	--emit real event immediately
	self.outSocket:emit(Event(event:getType(), doubleBPM))
	
	--then emit another
	playdate.timer.performAfterDelay(self:bpmMs(doubleBPM), function() 
		self.outSocket:emit(Event(event:getType(), doubleBPM))
	end)
end

function ClockDoublerComponent:bpmMs(bpm)
	return (60000/bpm)/4
end

function ClockDoublerComponent:unplugIn()
	self.inSocket:setCable(nil)
end

function ClockDoublerComponent:unplugOut()
	self.outSocket:setCable(nil)
end

function ClockDoublerComponent:inConnected()
	return self.inSocket:connected()
end

function ClockDoublerComponent:setInCable(cable)
	self.inSocket:setCable(cable)
end

function ClockDoublerComponent:outConnected()
	return self.outSocket:connected()
end

function ClockDoublerComponent:setOutCable(cable)
	self.outSocket:setCable(cable)
end