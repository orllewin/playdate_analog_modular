--[[

]]--

class('TimedSwitchComponent').extends()

function TimedSwitchComponent:init(listener)
	TimedSwitchComponent.super.init(self)
	
	self.listener = listener
	
	self.inBeats = 0
	self.toggleAtBar = 4
	self.repeats = false
	self.emitting = false
	
	self.inSocket = Socket("switch_module_in", socket_receive, function(event) 
		self.inBeats += 1
		print("inBeats: " .. self.inBeats)
		if self.inBeats/4 >= self.toggleAtBar then
			print("TRIGGGGER")
			self.inBeats = 0
			self.emitting = not self.emitting
			if self.listener ~= nil then self.listener(self.emitting) end
		end
		if self.emitting then self.outSocket:emit(event) end
	end)
		
	self.outSocket = Socket("switch_module_out", socket_send)
end

function TimedSwitchComponent:setBars(bars)
	if bars == nil then
		print("bars is nil")
		return
	end
	print("Setting bars to " .. bars)
	self.inBeats = 0
	self.toggleAtBar = bars
end

function TimedSwitchComponent:isOn()
	return self.emitting
end

function TimedSwitchComponent:toggle()
	if self.emitting then
		self.emitting = false
	else
		self.emitting = true
	end
end

function TimedSwitchComponent:switchOn()
	self.emitting = true
end

function TimedSwitchComponent:switchOff()
	self.emitting = false
end

function TimedSwitchComponent:setInCable(cable)
	self.inSocket:setCable(cable)
end

function TimedSwitchComponent:setToggleInCable(cable)
	self.inToggleSocket:setCable(cable)
end

function TimedSwitchComponent:setOutCable(cable)
	self.outSocket:setCable(cable)
end

function TimedSwitchComponent:unplugIn()
	self.inSocket:setCable(nil)
end

function TimedSwitchComponent:unplugToggleIn()
	self.inToggleSocket:setCable(nil)
end

function TimedSwitchComponent:unplugOut()
	self.outSocket:setCable(nil)
end

function TimedSwitchComponent:inConnected()
	return self.inSocket:connected()
end

function TimedSwitchComponent:inToggleConnected()
	return self.inToggleSocket:connected()
end

function TimedSwitchComponent:outConnected()
	return self.outSocket:connected()
end