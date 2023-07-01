--[[
	© 2023 Orllewin - All Rights Reserved.
]]

class('ArpComponent').extends()

local random <const> = math.random

function ArpComponent:init()
	ArpComponent.super.init(self)
		
	self.outSocket = Socket("arp_out", socket_send)
	
	
	self.inSocket = Socket("arp_in", socket_receive, function(event) 
		if random() > self.gravity then
			self.outSocket:emit(event)
		end
	end)
end
