--[[

]]--

class('SwitchSPDTComponent').extends()

function SwitchSPDTComponent:init(listener)
	SwitchSPDTComponent.super.init(self)
	
	self.listener = listener
	
	self.aEmitting = true
	self.inSocket = Socket("switch_module_in", socket_receive, function(event) 
		if self.aEmitting then 
			self.outASocket:emit(event)
		else
			self.outBSocket:emit(event)
	 	end
	end)
	
	self.inToggleSocket = Socket("switch_module_toggle_in", socket_receive, function(event) 
			self:toggle()
			if self.listener ~= nil then self.listener() end
		end)
	
	self.outASocket = Socket("spdt_switch_module_out_a", socket_send)
	self.outBSocket = Socket("spdt_switch_module_out_b", socket_send)
end

function SwitchSPDTComponent:isOn()
	return self.aEmitting
end

function SwitchSPDTComponent:toggle()
	if self.aEmitting then
		self.aEmitting = false
	else
		self.aEmitting = true
	end
end

function SwitchSPDTComponent:switchOn()
	self.aEmitting = true
end

function SwitchSPDTComponent:switchOff()
	self.aEmitting = false
end

function SwitchSPDTComponent:setInCable(cable)
	self.inSocket:setCable(cable)
end

function SwitchSPDTComponent:setToggleInCable(cable)
	self.inToggleSocket:setCable(cable)
end

function SwitchSPDTComponent:setOutACable(cable)
	self.outASocket:setCable(cable)
end

function SwitchSPDTComponent:setOutBCable(cable)
	self.outBSocket:setCable(cable)
end

function SwitchSPDTComponent:unplugIn()
	self.inSocket:setCable(nil)
end

function SwitchSPDTComponent:unplugToggleIn()
	self.inToggleSocket:setCable(nil)
end

function SwitchSPDTComponent:unplugOutA()
	self.outASocket:setCable(nil)
end

function SwitchSPDTComponent:unplugOutB()
	self.outBSocket:setCable(nil)
end

function SwitchSPDTComponent:inConnected()
	return self.inSocket:connected()
end

function SwitchSPDTComponent:inToggleConnected()
	return self.inToggleSocket:connected()
end

function SwitchSPDTComponent:outAConnected()
	return self.outASocket:connected()
end

function SwitchSPDTComponent:outBConnected()
	return self.outBSocket:connected()
end