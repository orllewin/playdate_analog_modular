--[[
	© 2023 Orllewin - All Rights Reserved.
]]

class('BlackholeComponent').extends()

local random <const> = math.random

function BlackholeComponent:init()
	BlackholeComponent.super.init(self)
		
	self.outSocket = Socket("blackhole_out", socket_send)
	
	self.gravity = 0.5
	
	self.inSocket = Socket("blackhole_in", socket_receive, function(event) 
		if random() > self.gravity then
			self.outSocket:emit(event)
		end
	end)
end

function BlackholeComponent:setGravity(value)
	self.gravity = value
end

function BlackholeComponent:getGravity()
	return self.gravity
end

function BlackholeComponent:unplugIn()
	self.inSocket:setCable(nil)
end

function BlackholeComponent:unplugOut()
	self.outSocket:setCable(nil)
end

function BlackholeComponent:inConnected()
	return self.inSocket:connected()
end

function BlackholeComponent:setInCable(cable)
	self.inSocket:setCable(cable)
end

function BlackholeComponent:outConnected()
	return self.outSocket:connected()
end

function BlackholeComponent:setOutCable(cable)
	self.outSocket:setCable(cable)
end