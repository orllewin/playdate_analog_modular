--[[
	© 2023 Orllewin - All Rights Reserved.
]]

class('ArpComponent').extends()

local random <const> = math.random
local blank16 = {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0}

function ArpComponent:init()
	ArpComponent.super.init(self)
			
	self.pattern = {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0}
	self.stepLength = 16
	self.step = 1
	self.seqStep = 1
	
	self.outSocket = Socket("arp_out", socket_send)
	
	self.inSocket = Socket("arp_in", socket_receive, function(event) 
		-- main step counter
		self.step += 1
		if self.step == 17 then
			self.step = 1
		end
	
		self.seqStep += 1
		if self.seqStep > self.stepLength then
			self.seqStep  = 1
		end
		
		self.outSocket:emit(Event(event_value, self.pattern[self.step] + 36))
	end)
end

function ArpComponent:setPattern(pattern)
	self.pattern = pattern
end

function ArpComponent:setPatternLength(stepLength)
	if self.stepLength == stepLength then
		print("self.stepLength already set to " .. stepLength .. " steps")
		return
	end
	
	if #self.pattern < stepLength then
		tableConcat(self.pattern, blank16)
	end
	
	self.stepLength = stepLength
	self.seqStep = self.step
end

function ArpComponent:getPattern()
	return self.pattern
end

function ArpComponent:getPatternLength()
	return self.stepLength
end

function ArpComponent:setInCable(cable)
	self.inSocket:setCable(cable)
end

function ArpComponent:setOutCable(cable)
	self.outSocket:setCable(cable)
end

function ArpComponent:unplugIn()
	self.inSocket:setCable(nil)
end

function ArpComponent:unplugOut()
	self.outSocket:setCable(nil)
end

function ArpComponent:inConnected()
	return self.inSocket:connected()
end

function ArpComponent:outConnected()
	return self.outSocket:connected()
end

