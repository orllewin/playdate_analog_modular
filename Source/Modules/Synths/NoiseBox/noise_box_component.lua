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
	local synthChannel = playdate.sound.channel.new()
	synthChannel:addSource(self.synth)
	synthChannel:setVolume(gDefaultVolume)
	
	self.filter = playdate.sound.twopolefilter.new("lowpass")
	self.filter:setResonance(synthFilterResonance)
	self.filter:setFrequency(synthFilterFrequency)
	synthChannel:addEffect(self.filter)
	
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
	
	if onChannel ~= nil then onChannel(synthChannel) end

	self.inSocket = Socket("stochastic_tri_module", socket_receive, function(event) 
		--self.synth:playMIDINote(math.floor(event:getValue()))
		self:maybeDelay(event)
	end)
		
	self.outSocket = Socket("synth_module", socket_send)
end

function NoiseBoxComponent:pitchUp()

end

function NoiseBoxComponent:pitchDown()

end

function NoiseBoxComponent:maybeDelay(event)
	if event ~= nil then
		if self.didDelay then
			self.didDelay = false
			return
		end
		if event:getValue() ~= self.bpm then
			--update delayMS
			self.bpm = event:getValue()
			self:calculateMS()
		end
		if math.random(100) < self.probability then
			self.didDelay = true
			playdate.timer.performAfterDelay(self.delayMS, function() 
				self:maybeBlackhole(event)
			end)
		else
			self:maybeBlackhole(event)
		end
	end
end

function NoiseBoxComponent:maybeBlackhole(event)
	if math.random() > self.gravity then
		self:emitMidi()
	end
end

function NoiseBoxComponent:emitMidi()
	local midiNote = self.notes[math.floor(map(math.random(), 0.0, 1.0, self.minNoteIndex, self.maxNoteIndex))]
	self.synth:playMIDINote(midiNote)
	
	if math.random() < 0.05 then
		self.divisionChoice = math.floor(math.random(), 0.0, 1.0, 1, 7)
		self:calculateMS()
	end
end

function NoiseBoxComponent:calculateMS()
	
	local bpm = self.bpm
	local bpmMs = (60000/bpm)
	
	if self.divisionChoice == mode1_1 then
		self.delayMS = bpmMs
	elseif self.divisionChoice == mode1_2 then
		self.delayMS = bpmMs/2
	elseif self.divisionChoice == mode1_4 then
		self.delayMS = bpmMs/4
	elseif self.divisionChoice == mode1_8 then
		self.delayMS = bpmMs/8
	elseif self.divisionChoice == mode1_16 then 
		self.delayMS = bpmMs/16
	elseif self.divisionChoice == mode1_32 then 
		self.delayMS = bpmMs/32
	elseif self.divisionChoice == mode1_64 then	
		self.delayMS = bpmMs/64
	else
		self.delayMS = 1
	end	
end

function NoiseBoxComponent:setVolume(value)
	self.synth:setVolume(value)
end

function NoiseBoxComponent:getVolume()
	return self.synth:getVolume()
end

function NoiseBoxComponent:setInCable(cable)
	self.inSocket:setCable(cable)
end

function NoiseBoxComponent:setOutCable(cable)
	--todo - link to a channel in a speaker module?
	--self.outSocket:setCable(cable)
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