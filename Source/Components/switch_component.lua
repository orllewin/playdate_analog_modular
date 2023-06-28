--[[
	Emits a random number when it receives a bang
]]--

class('SwitchComponent').extends()

function SwitchComponent:init()
	SwitchComponent.super.init(self)
	
	self.outSocket = Socket("switch_component_out", socket_send)
	
	self.isOn = true
	
	self.inSocket = Socket("switch_component_in", socket_receive, function(event) 
		if self.isOn == true then
			self.outSocket:emit(event)
		end
	end)
end

function SwitchComponent:off()
	self.isOn = false
end

function SwitchComponent:on()
	self.isOn = true
end

function SwitchComponent:setInCable(cable)
	self.inSocket:setCable(cable)
end

function SwitchComponent:setOutCable(cable)
	self.outSocket:setCable(cable)
end