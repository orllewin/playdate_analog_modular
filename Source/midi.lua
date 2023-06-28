class('Midi').extends()

--[[
	
https://newt.phys.unsw.edu.au/jw/notes.html
	
A0    C1                   C2                   C3                   C4
 22    25 27    30 32 34    37 39    42 44 46    49 51    54 56 58
21 23 24 26 28 29 31 33 35 36 38 40 41 43 45 47 48 50 52 53 55 57 59 60
	
--]]

function Midi:init()
	Midi.super.init(self)
end

-- Just the white keys
function Midi:CMajor()
	local notes = {21, 23, 24, 26, 28, 29, 31}
	self:growKey(notes)
	return notes
end

-- Just the black keys
function Midi:EFlatMinorPentatonic()
	local notes = {22, 25, 27, 30, 32}
	self:growKey(notes)
	return notes
end

function Midi:growKey(notes)
	local scaleSize = #notes
	local hiNote = notes[scaleSize]
	local offset = scaleSize - 1
	while(hiNote <= 127) do
		 for scaleNote = 1, scaleSize do
			 local sourceNote = notes[(#notes - offset)]
			 local newNote = sourceNote + 12
			 hiNote = newNote
			 if hiNote > 127 then break end
			 table.insert(notes, newNote)
		 end
	end
end


