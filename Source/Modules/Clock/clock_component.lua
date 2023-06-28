--[[
	© 2023 Orllewin - All Rights Reserved.

	A clock just emits quarter-note bang events (event_bang).
	It only has an out-socket.
	Bpm calculations: https://tuneform.com/tools/time-tempo-bpm-to-milliseconds-ms
]]

import 'Coracle/timing_utils'

class('ClockComponent').extends()

local defaultBPM = 120

function ClockComponent:init(listener, bpm)
	ClockComponent.super.init(self)
	
	self.listener = listener
	self.outSocket = Socket("clock", socket_send)
	
	self.timestamp = 0
	
	if bpm == nil then
		self.bpm = defaultBPM
	else
		self.bpm = bpm
	end
end

function ClockComponent:stop()
	self.timer:remove()
end

function ClockComponent:getBPM()
	return self.bpm
end

function ClockComponent:setOutCable(cable)
	self.outSocket:setCable(cable)
end

function ClockComponent:connected()
	return self.outSocket:connected()
end

function ClockComponent:unplug()
	self.outSocket:setCable(nil)
end

-- There's a bug with playdate.timer
-- it reliably takes 34 and 31 (simulator and hardware) longer than what you ask for.
function ClockComponent:bpmMs(bpm)
	if playdate.isSimulator then
		return (60000/(bpm*4)) - 34
	else
		return (60000/(bpm*4)) - 31
	end
end

function ClockComponent:bang()	
	self.outSocket:emit(Event(event_bang, self.bpm))
	if self.listener ~= nil then self.listener() end
end

function ClockComponent:setBPM(bpm)
	self.bpm = bpm
	if self.timer ~= nil then self.timer:remove() end
	self.timer = playdate.timer.new(self:bpmMs(self.bpm), function() 
		self:bang()
	end)
	self.timer.repeats = true
end