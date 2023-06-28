--[[

]]--

class('SynthComponent').extends()

function SynthComponent:init(id, listener, param1Listener, param2Listener, onChannel)
	SynthComponent.super.init(self)
	
	self.id = id
	self.listener = listener
	self.param1Listener = param1Listener
	self.param2Listener = param2Listener
	
	self.waveformChoice = 1
	self.param1 = 0.0
	self.param2 = 0.0
	
	self.attack = 0.1
	self.decay = 0.1
	self.sustain = 0.8
	self.release = 1.0
	self.curve = 0.5
	
	self.synth = playdate.sound.synth.new(playdate.sound.kWaveSine)
	self.synth:setVolume(0.3)
	self.synth:setADSR(self.attack, self.decay, self.sustain, self.release)
	self.synth:setEnvelopeCurvature(self.curve)
	
	local synthChannel = playdate.sound.channel.new()
	synthChannel:addSource(self.synth)
	synthChannel:setVolume(gDefaultVolume)
	if onChannel ~= nil then onChannel(synthChannel) end

	self.inSocket = Socket("synth_module", socket_receive, function(event) 
		
		self.synth:playMIDINote(math.floor(event:getValue()), 1, 3)
		
		--there appears to be a bug with the PO synths where custom params are removed when a note is played...
		--so add them after triggering a note:
		if self.waveformChoice >= 5 then
			self.synth:setADSR(self.attack, self.decay, self.sustain, self.release)--todo - this needed too?
			self:setParameter1(self.param1)
			self:setParameter2(self.param2)
			self.synth:setADSR(self.attack, self.decay, self.sustain, self.release)
			self.synth:setEnvelopeCurvature(self.curve)
		end
		
		if self.listener ~= nil then
			self.listener(event)
		end
	end)
	
	self.param1InSocket = Socket("synth_module_param1_in", socket_receive, function(event) 
		self:setParameter1(event:getValue())
		if self.param1Listener ~= nil then
			self.param1Listener(event)
		end
	end)
	
	self.param2InSocket = Socket("synth_module_param2_in", socket_receive, function(event) 
		self:setParameter2(event:getValue())
		if self.param2Listener ~= nil then
			self.param2Listener(event)
		end
	end)
	
	self.outSocket = Socket("synth_module", socket_send)
end

function SynthComponent:setWaveform(normalisedValue)
	self.waveformChoice = math.floor(map(normalisedValue, 0.0, 1.0, 1, 7))
	local label = "Unknown"
	if self.waveformChoice == 1 then
		self.synth:setWaveform(playdate.sound.kWaveSine)
		label = "Sine"
	elseif self.waveformChoice == 2 then
		self.synth:setWaveform(playdate.sound.kWaveSquare)
		label = "Square"
	elseif self.waveformChoice == 3 then
		self.synth:setWaveform(playdate.sound.kWaveSawtooth)
		label = "Sawtooth"
	elseif self.waveformChoice == 4 then
		self.synth:setWaveform(playdate.sound.kWaveTriangle)
		label = "Triangle"
	elseif self.waveformChoice == 5 then
		self.synth:setWaveform(playdate.sound.kWavePOPhase)
		label = "PO Phase"
	elseif self.waveformChoice == 6 then
		self.synth:setWaveform(playdate.sound.kWavePODigital)
		label = "PO Digital"
	elseif self.waveformChoice == 7 then
		self.synth:setWaveform(playdate.sound.kWavePOVosim)
		label = "PO Vosim"
	end
	
	--I don't think these persist between waveform changes, need to check:
	self.synth:setADSR(self.attack, self.decay, self.sustain, self.release)
	self.synth:setEnvelopeCurvature(self.curve)
	
	return label
end

function SynthComponent:setVolume(value)
	self.synth:setVolume(value)
end

--Attack is in seconds
function SynthComponent:setAttack(value)
	self.attack = map(value, 0.0, 1.0, 0.0, 0.5)
	self.synth:setAttack(self.attack)
end

--Decay is in seconds, but 1 seconds max is fine so:
function SynthComponent:setDecay(value)
	self.decay = map(value, 0.0, 1.0, 0.0, 0.5)
	self.synth:setDecay(self.decay)
end

function SynthComponent:setSustain(value)
	self.sustain = value
	self.synth:setSustain(self.sustain)
end

function SynthComponent:setRelease(value)
	self.release = map(value, 0.0, 1.0, 0.0, 1.0)
	self.synth:setRelease(self.release)
end

--Attack is in seconds
function SynthComponent:setEnvelopeCurve(value)
	self.curve = value
	self.synth:setEnvelopeCurvature(self.curve)
end

function SynthComponent:setParameter1(value)
	self.param1 = value
	self.synth:setParameter(1, value)
end

function SynthComponent:setParameter2(value)
	self.param2 = value
	self.synth:setParameter(2, value)
end

function SynthComponent:setParam1InCable(cable)
	self.param1InSocket:setCable(cable)
end

function SynthComponent:setParam2InCable(cable)
	self.param2InSocket:setCable(cable)
end

function SynthComponent:setInCable(cable)
	self.inSocket:setCable(cable)
end

function SynthComponent:setOutCable(cable)
	--todo - link to a channel in a speaker module?
	--self.outSocket:setCable(cable)
end

function SynthComponent:unplugIn()
	self.inSocket:setCable(nil)
end

function SynthComponent:unplugOut()
	self.outSocket:setCable(nil)
end

function SynthComponent:inConnected()
	return self.inSocket:connected()
end

function SynthComponent:outConnected()
	return self.outSocket:connected()
end