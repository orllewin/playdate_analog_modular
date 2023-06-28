--[[

	
]]--

class('DelayComponent').extends()

local maxSeconds = 2.0

function DelayComponent:init(id, listener)
	DelayComponent.super.init(self)
	
	self.id = id
	self.listener = listener
	
	self.filter = playdate.sound.delayline.new(maxSeconds)
	self.filter:setFeedback(0.5)
	self.tap = self.filter:addTap(0.5)
	
	self.outSocket = Socket("delay_mod_out", socket_send)
	
	self.inSocket = Socket("delay_mod_in", socket_receive, function(event) 
		if event ~= nil then
			
		end
	end)
end

function DelayComponent:setChannel(channel)
	channel:addEffect(self.filter)
end

function DelayComponent:removeChannel(channel)
	channel:removeEffect(self.filter)
end

function DelayComponent:setMix(value)
	self.filter:setMix(value)
end

function DelayComponent:setFeedback(value)
	self.filter:setFeedback(value)
end

function DelayComponent:setTapDelay(value)
	self.filter:setFeedback(map(value, 0.0, 1.0, 0.0, maxSeconds))
end

function DelayComponent:inConnected()
	return self.inSocket:connected()
end

function DelayComponent:outConnected()
	return self.outSocket:connected()
end

function DelayComponent:unplugIn(cableId)
	self.inSocket:setCable(nil)
end

function DelayComponent:unplugOut(cableId)
	self.outSocket:setCable(nil)
end

function DelayComponent:setInCable(cable)
	self.inSocket:setCable(cable)
end

function DelayComponent:setOutCable(cable)
	self.outSocket:setCable(cable)
end