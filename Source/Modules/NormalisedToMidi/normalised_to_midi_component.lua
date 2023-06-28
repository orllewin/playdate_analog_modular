--[[

]]--

import 'midi'

class('NormalisedToMidiComponent').extends()

local all_notes = 1
local white_notes = 2
local black_notes = 3

function NormalisedToMidiComponent:init()
	NormalisedToMidiComponent.super.init(self)
	
	self.outSocket = Socket("normalised_to_midi_component_out", socket_send)
	
	self.normalisedMin = 0.0
	self.normalisedMax = 1.0
	self.minNoteIndex = 1
	self.maxNoteIndex = 127
	self.mode = white_notes
	
	self.midi = Midi()
	
	self:setMode(white_notes)
	
	self.inSocket = Socket("normalised_to_midi_component_in", socket_receive, function(event) 
		local midiNote = 0
		if self.mode == all_notes then
			midiNote = math.floor(map(event:getValue(), 0.0, 1.0, self.minNoteIndex, self.maxNoteIndex))
		elseif self.mode == white_notes then
			midiNote = self.notes[math.floor(map(event:getValue(), 0.0, 1.0, self.minNoteIndex, self.maxNoteIndex))]
		elseif self.mode == black_notes then
			midiNote = self.notes[math.floor(map(event:getValue(), 0.0, 1.0, self.minNoteIndex, self.maxNoteIndex))]
		end
		self.outSocket:emit(Event(event_value, midiNote))
	end)
end

function NormalisedToMidiComponent:setMode(mode)
	self.mode = mode
	if self.mode == all_notes then
		self.notes = {}
		self.minNoteIndex = math.floor(map(self.normalisedMin, 0.0, 1.0, 1, 127))
		self.maxNoteIndex = math.floor(map(self.normalisedMax, 0.0, 1.0, 1, 127))
	elseif self.mode == white_notes then
		self.notes = self.midi:CMajor()
		self.minNoteIndex = math.floor(map(self.normalisedMin, 0.0, 1.0, 1, #self.notes))
		self.maxNoteIndex = math.floor(map(self.normalisedMax, 0.0, 1.0, 1, #self.notes))
	elseif self.mode == black_notes then
		self.notes = self.midi:EFlatMinorPentatonic()
		self.minNoteIndex = math.floor(map(self.normalisedMin, 0.0, 1.0, 1, #self.notes))
		self.maxNoteIndex = math.floor(map(self.normalisedMax, 0.0, 1.0, 1, #self.notes))
	end
end

function NormalisedToMidiComponent:setHighRange(value)
	self.normalisedMax = value
	if self.mode == all_notes then
		self.maxNoteIndex = math.floor(map(self.normalisedMax, 0.0, 1.0, 1, 127))
	elseif self.mode == white_notes then
		self.maxNoteIndex = math.floor(map(self.normalisedMax, 0.0, 1.0, 1, #self.notes))
	elseif self.mode == black_notes then
		self.maxNoteIndex = math.floor(map(self.normalisedMax, 0.0, 1.0, 1, #self.notes))
	end
	print("setHighRange, max/high note index: " ..self.maxNoteIndex .. " for notes size: " .. #self.notes)
end

function NormalisedToMidiComponent:setLowRange(value)
	self.normalisedMin = value
	if self.mode == all_notes then
		self.minNoteIndex = math.floor(map(self.normalisedMin, 0.0, 1.0, 1, 127))
	elseif self.mode == white_notes then
		self.minNoteIndex = math.floor(map(self.normalisedMin, 0.0, 1.0, 1, #self.notes))
	elseif self.mode == black_notes then
		self.minNoteIndex = math.floor(map(self.normalisedMin, 0.0, 1.0, 1, #self.notes))
	end
	
	print("setLowRange, min/low note index: " ..self.minNoteIndex .. " for notes size: " .. #self.notes)
end

function NormalisedToMidiComponent:setInCable(cable)
	self.inSocket:setCable(cable)
end

function NormalisedToMidiComponent:setOutCable(cable)
	self.outSocket:setCable(cable)
end

function NormalisedToMidiComponent:unplugIn()
	self.inSocket:setCable(nil)
end

function NormalisedToMidiComponent:unplugOut()
	self.outSocket:setCable(nil)
end

function NormalisedToMidiComponent:inConnected()
	return self.inSocket:connected()
end

function NormalisedToMidiComponent:outConnected()
	return self.outSocket:connected()
end