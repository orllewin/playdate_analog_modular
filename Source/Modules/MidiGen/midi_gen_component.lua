--[[

]]--
import 'midi'

class('MidiGenComponent').extends()

function MidiGenComponent:init()
	MidiGenComponent.super.init(self)
	
	self.midi = Midi()
	self.notes = self.midi:getNotes(1)
	
	self.bpm = -1
	self.divisionChoice = 4
	self.probability = 60
	self.delayMS = 250
	
	self.didDelay = false
	
	self.normalisedMin = 0.0
	self.normalisedMax = 1.0
	self.minNoteIndex = 1
	self.maxNoteIndex = #self.notes
	
	self.outSocket = Socket("random_component_out", socket_send)
	
	self.blackhole = 0.5
	
	self.inSocket = Socket("random_component_in", socket_receive, function(event) 
		self:doClockDelay(event)
	end)
end

function MidiGenComponent:doClockDelay(event)
		--if delayed last event skip the next
		if self.didDelay then
			self.didDelay = false
			return
		end
		
		--if bpm changes update new ms delay
		if event:getValue() ~= self.bpm then
			--update delayMS
			self.bpm = event:getValue()
			self:calculateMS()
		end
		
		if math.random(100) < self.probability then
			self.didDelay = true
			playdate.timer.performAfterDelay(self.delayMS, function() 
				self:doBlackhole(event)
			end)
		else
			self:doBlackhole(event)
		end
end

function MidiGenComponent:doBlackhole(event)
	if math.random() > self.blackhole then
		self:doRandomToMidi(event)
	end
end

function MidiGenComponent:doRandomToMidi(event)
	local rnd = math.random()
	local noteIndex = math.floor(map(rnd, 0.0, 1.0, self.minNoteIndex, self.maxNoteIndex))
	local midiNote = self.notes[noteIndex]
	self.outSocket:emit(Event(event_value, midiNote))
end

function MidiGenComponent:updateRange()	
	self.minNoteIndex = math.floor(map(self.normalisedMin, 0.0, 1.0, 1, #self.notes))
	self.maxNoteIndex = math.floor(map(self.normalisedMax, 0.0, 1.0, 1, #self.notes))
end

function MidiGenComponent:setDivisionDelay(normalisedInput)
	self.divisionChoice = math.floor(map(normalisedInput, 0.0, 1.0, 1, 7))
	self:calculateMS()
	return self.divisionChoice
end

function MidiGenComponent:calculateMS()
	
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

function MidiGenComponent:setChance(normalisedChance)
	self.probability = math.floor(normalisedChance * 100)
	return "" .. self.probability .. "%"
end

function MidiGenComponent:getDivChoice()
	return self.divisionChoice
end

function MidiGenComponent:setGravity(value)
	self.blackhole = value
end

function MidiGenComponent:setHighRange(value)
	self.normalisedMax = value
	self:updateRange()
end

function MidiGenComponent:setLowRange(value)
	self.normalisedMin = value
	self:updateRange()
end

function MidiGenComponent:setKey(index)
	self.notes = self.midi:getNotes()
	self:updateRange()
	return self.midi:getAvailable()[index]
end

function MidiGenComponent:setInCable(cable)
	self.inSocket:setCable(cable)
end

function MidiGenComponent:setOutCable(cable)
	self.outSocket:setCable(cable)
end

function MidiGenComponent:unplugIn()
	self.inSocket:setCable(nil)
end

function MidiGenComponent:unplugOut()
	self.outSocket:setCable(nil)
end

function MidiGenComponent:inConnected()
	return self.inSocket:connected()
end

function MidiGenComponent:outConnected()
	return self.outSocket:connected()
end