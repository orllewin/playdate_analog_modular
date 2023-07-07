--[[

]]--

class('SimplexSineComponent').extends()

function SimplexSineComponent:init(onChannel)
	SimplexSineComponent.super.init(self)
	
	self.waveformChoice = 1
	
	self.synth = playdate.sound.synth.new(playdate.sound.kWaveSine)
	self.synth:setVolume(0.5)
	
	local synthChannel = playdate.sound.channel.new()
	synthChannel:addSource(self.synth)
	synthChannel:setVolume(gDefaultVolume)
	if onChannel ~= nil then onChannel(synthChannel) end

	self.inSocket = Socket("synth_module", socket_receive, function(event) 
		self.synth:playMIDINote(math.floor(event:getValue()))
	end)
		
	self.outSocket = Socket("synth_module", socket_send)
end

function SimplexSineComponent:setWaveform(index)
	self.waveformTypeIndex = index
	if index == 1 then
		self.synth:setWaveform(playdate.sound.kWaveSine)
	elseif index == 2 then
		self.synth:setWaveform(playdate.sound.kWaveSquare)
	elseif index == 3 then
		self.synth:setWaveform(playdate.sound.kWaveSawtooth)
	elseif index == 4 then
		self.synth:setWaveform(playdate.sound.kWaveTriangle)
	elseif index == 5 then
		self.synth:setWaveform(playdate.sound.kWavePOPhase)
	elseif index == 6 then
		self.synth:setWaveform(playdate.sound.kWavePODigital)
	elseif index == 7 then
		self.synth:setWaveform(playdate.sound.kWavePOVosim)
	end
end

function SimplexSineComponent:getWaveformTypeIndex()
	return self.waveformTypeIndex
end

function SimplexSineComponent:setVolume(value)
	self.synth:setVolume(value)
end

function SimplexSineComponent:getVolume()
	return self.synth:getVolume()
end

function SimplexSineComponent:setInCable(cable)
	self.inSocket:setCable(cable)
end

function SimplexSineComponent:setOutCable(cable)
	--todo - link to a channel in a speaker module?
	--self.outSocket:setCable(cable)
end

function SimplexSineComponent:unplugIn()
	self.inSocket:setCable(nil)
end

function SimplexSineComponent:unplugOut()
	self.outSocket:setCable(nil)
end

function SimplexSineComponent:inConnected()
	return self.inSocket:connected()
end

function SimplexSineComponent:outConnected()
	return self.outSocket:connected()
end