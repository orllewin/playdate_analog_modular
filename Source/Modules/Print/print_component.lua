--[[

	A printer just displays (and logs) events.
	It only has an in-socket.
	
]]--

class('PrintComponent').extends()

function PrintComponent:init(id, listener)
	PrintComponent.super.init(self)
	
	self.id = id
	self.listener = listener
	
	self.outSocket = Socket("print_module_out", socket_send)
	
	self.inSocket = Socket("print_module_in", socket_receive, function(event) 
		if event ~= nil then
			self.outSocket:emit(event)
		end
		if self.listener ~= nil then
			self.listener(event)
		end
	end)
end

function PrintComponent:inConnected()
	return self.inSocket:connected()
end

function PrintComponent:outConnected()
	return self.outSocket:connected()
end

function PrintComponent:unplugIn()
	self.inSocket:setCable(nil)
end

function PrintComponent:unplugOut()
	self.outSocket:setCable(nil)
end


function PrintComponent:setInCable(cable)
	self.inSocket:setCable(cable)
end

function PrintComponent:setOutCable(cable)
	self.outSocket:setCable(cable)
end