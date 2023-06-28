--[[

	A delay has one input which it holds for some time before emitting at its only output
	
]]--

class('DelayComponent').extends()

function DelayComponent:init(ms)
	DelayComponent.super.init(self)
	
	self.ms = ms
	
	self.outSocket = Socket("delay_module_out", socket_send)
	
	self.inSocket = Socket("delay_module", socket_receive, function(event) 
		print("DelayComponent socket receive callback")
		playdate.timer.performAfterDelay(self.ms, function() 
			self.outSocket:emit(event)
		end)
	end)
end

function DelayComponent:setInCable(cable)
	self.inSocket:setCable(cable)
end

function DelayComponent:setOutCable(cable)
	self.outSocket:setCable(cable)
end