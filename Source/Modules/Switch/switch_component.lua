--[[

]]--

class('SwitchComponent').extends()

function SwitchComponent:init(id, listener)
	SwitchComponent.super.init(self)
	
	self.id = id
	self.listener = listener
	
	self.emitting = true
	self.inSocket = Socket("switch_module_in", socket_receive, function(event) 
		if self.emitting then self.outSocket:emit(event) end
	end)
	
	self.inToggleSocket = Socket("switch_module_toggle_in", socket_receive, function(event) 
			self:toggle()
			if self.emitting then self.outSocket:emit(event) end
			if self.listener ~= nil then self.listener() end
		end)
	
	self.outSocket = Socket("switch_module_out", socket_send)
end

function SwitchComponent:isOn()
	return self.emitting
end

function SwitchComponent:toggle()
	if self.emitting then
		self.emitting = false
	else
		self.emitting = true
	end
end

function SwitchComponent:switchOn()
	self.emitting = true
end

function SwitchComponent:switchOff()
	self.emitting = false
end

function SwitchComponent:setInCable(cable)
	self.inSocket:setCable(cable)
end

function SwitchComponent:setToggleInCable(cable)
	self.inToggleSocket:setCable(cable)
end

function SwitchComponent:setOutCable(cable)
	self.outSocket:setCable(cable)
end

function SwitchComponent:unplugIn()
	self.inSocket:setCable(nil)
end

function SwitchComponent:unplugToggleIn()
	self.inToggleSocket:setCable(nil)
end

function SwitchComponent:unplugOut()
	self.outSocket:setCable(nil)
end

function SwitchComponent:inConnected()
	return self.inSocket:connected()
end

function SwitchComponent:inToggleConnected()
	return self.inToggleSocket:connected()
end

function SwitchComponent:outConnected()
	return self.outSocket:connected()
end