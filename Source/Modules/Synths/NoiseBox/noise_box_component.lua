--[[

]]--

class('NoiseBoxComponent').extends()

local synthFilterResonance = 0.1
local synthFilterFrequency = 220

local minFreq = 100
local maxFreq = 300

function NoiseBoxComponent:init(onChannel)
	NoiseBoxComponent.super.init(self)
			
	self.synth = playdate.sound.synth.new(playdate.sound.kWaveNoise)
	self.channel = playdate.sound.channel.new()
	self.channel:addSource(self.synth)
	self.channel:setVolume(gDefaultVolume)
	
	self.filter = playdate.sound.twopolefilter.new("lowpass")
	self.filter:setResonance(synthFilterResonance)
	self.filter:setFrequency(synthFilterFrequency)
	self.channel:addEffect(self.filter)
	
	self.synth:playNote(330)
	
	-- automatic mode, limit freq range to something that won't disturb someone trying to fall asleep:
	local waveAnimator = playdate.graphics.animator.new(30000, minFreq, maxFreq, playdate.easingFunctions.outInSine)
	waveAnimator.reverses = true
	waveAnimator.repeatCount = -1
	
	self.timer = playdate.timer.new(100, function()
		local synthFilterFrequency = waveAnimator:currentValue()
		self.filter:setFrequency(synthFilterFrequency)
	end)
	self.timer.repeats = true
	
	if onChannel ~= nil then onChannel(self.channel) end
		
	self.outSocket = Socket("noise_box_out", socket_send)
end

function NoiseBoxComponent:stopAll()
	self.synth:stop()
	self.channel:remove()
	
	self.synth = nil
	self.channel = nil
end

function NoiseBoxComponent:setVolume(value)
	self.synth:setVolume(value)
end

function NoiseBoxComponent:getVolume()
	return self.synth:getVolume()
end


function NoiseBoxComponent:setOutCable(cable)

end

function NoiseBoxComponent:unplugIn()
	self.inSocket:setCable(nil)
end

function NoiseBoxComponent:unplugOut()
	self.outSocket:setCable(nil)
end

function NoiseBoxComponent:inConnected()
	return self.inSocket:connected()
end

function NoiseBoxComponent:outConnected()
	return self.outSocket:connected()
end