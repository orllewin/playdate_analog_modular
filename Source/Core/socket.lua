--[[
	
	Home for one end of a cable. 
	Lives in a module of some kind.
	
]]--

class('Socket').extends()

socket_receive = -1
socket_send = 1

function Socket:init(id, direction, listener)
	Socket.super.init(self)
	self.id = id
	self.direction = direction
	self.listener = listener
	
	self.cable = nil
	self.instance = self
end

function Socket:getId()
	return self.id
end

function Socket:setCable(cable)
	self.cable = cable
	if cable == nil then return end
	if self.direction == socket_send then
		if self.cable.setSendSocket ~= nil then
			self.cable:setSendSocket(self.instance)
		end
	else
		if self.cable.setReceiveSocket ~= nil then
			self.cable:setReceiveSocket(self.instance)
		end
	end
end

function Socket:emit(event)
	if self.cable == nil then 
		return 
	else
		if self.cable:receiveConnected() then
			self.cable:send(event)
		else
			print("Cable is not connected to a receive socket")
		end
	end
end

function Socket:receive(event)
	if self.listener ~= nil and self.cable ~= nil then self.listener(event) end
end

function Socket:connected()
	if self.cable == nil then
		return false
	else
		return true
	end
end

function Socket:getCableId()
	if self.cable == nil then
		return nil
	else
		return self.cable:getCableId()
	end
end