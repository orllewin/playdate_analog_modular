class('Midi').extends()

--[[
	
https://newt.phys.unsw.edu.au/jw/notes.html
	
A0    C1                   C2                   C3                   C4
 22    25 27    30 32 34    37 39    42 44 46    49 51    54 56 58
21 23 24 26 28 29 31 33 35 36 38 40 41 43 45 47 48 50 52 53 55 57 59 60

--]]

--note midi starts at 0 - so array is ZERO INDEXED
-- https://www.inspiredacoustics.com/en/MIDI_note_numbers_and_center_frequencies
local noteLabels = {
	"-",		--0
	"-",		--1
	"-",		--2
	"-",		--3
	"-",		--4
	"-",		--5
	"-",		--6
	"-",		--7
	"-",		--8
	"-",		--9
	"-",		--10
	"-",		--11
	"-",		--12
	"-",		--13
	"-",		--14
	"-",		--15
	"-",		--16
	"-",		--17
	"-",		--18
	"-",		--19
	"-",		--20
	"A0",		--21
	"Bb0",	--22
	"B0",		--23
	"C1",		--24
	"C#1",	--25
	"D1",		--26
	"Eb1",	--27
	"E1",		--28
	"F1",		--29
	"F#1",	--30
	"G1",		--31
	"Ab1",	--32
	"A1",		--33
	"Bb1",	--34
	"B1",		--35
	"C2",		--36
	"C#2",	--37
	"D2",		--38
	"Eb2",	--39
	"E2",		--40
	"F2",		--41
	"F#2",	--42
	"G2",		--43
	"Ab2",	--44
	"A2",		--45
	"Bb2", 	--46
	"B2",		--47
	"C3",		--48
	"C#3",	--49
	"D3",		--50
	"Eb3", 	--51
	"E3",		--52
	"F3",		--53
	"F#3",	--54
	"G3",		--55
	"Ab3",	--56
	"A3",		--57
	"Bb3",	--58
}

local majorScales = {
	{24, 26, 28, 29, 31, 33, 35}, -- C
	{25, 27, 29, 30, 32, 34, 36}, -- C♯/D♭
	{26, 28, 30, 31, 33, 35, 37}, -- D
	{27, 29, 31, 32, 34, 36, 38}, -- D♯/E♭
	{28, 30, 32, 33, 35, 37, 39}, -- E
	{29, 31, 33, 34, 36, 38, 40}, -- F
	{30, 32, 34, 35, 37, 39, 41}, -- F♯/G♭
	{31, 33, 35, 36, 38, 40, 42}, -- G
	{32, 34, 36, 37, 39, 41, 43}, -- G#/A♭
	{33, 35, 37, 38, 40, 42, 44}, -- A
	{34, 36, 38, 39, 41, 43, 45}, -- A#/B♭
	{35, 37, 39, 40, 42, 44, 46}, -- B
}

local minorScales = {
	{24, 26, 27, 29, 31, 32, 34}, -- C
	{25, 27, 28, 30, 32, 33, 35}, -- C♯/D♭ 
	{26, 28, 29, 31, 33, 34, 36}, -- D
	{27, 29, 30, 32, 34, 35, 37}, -- D♯/E♭
	{28, 30, 31, 33, 35, 36, 38}, -- E
	{29, 31, 32, 34, 36, 37, 39}, -- F
	{30, 32, 33, 35, 37, 38, 40}, -- F♯/G♭
	{31, 33, 34, 36, 38, 39, 41}, -- G
	{32, 34, 35, 37, 39, 40, 42}, -- G#/A♭
	{33, 35, 36, 38, 40, 41, 43}, -- A
	{34, 36, 37, 39, 41, 42, 44}, -- A#/B♭
	{35, 37, 38, 40, 42, 43, 45}, -- B
}

function Midi:init()
	Midi.super.init(self)
end

function Midi:getAvailable()
	return {
		"C Major",
		"D Major",
		"E Flat Minor"
	}
end

function Midi:getNotes(index)
	if index == 1 then
		return self:CMajor()
	elseif index == 2 then
		return self:DMajor()
	else
		return self:EFlatMinorPentatonic()
	end
end

-- C, D, E, F, G, A, B Just the white keys
function Midi:CMajor()
	local notes = {24, 26, 28, 29, 31, 33, 35}
	self:growKey(notes)
	return notes
end

-- C♯, D♯, E♯, F♯, G♯, A♯, B♯
function Midi:CSharpMajor()
	local notes = {25, 27, 29, 30, 32, 34, 36}
	self:growKey(notes)
	return notes
end

-- D, E, F♯, G, A, B, C♯
function Midi:DMajor()
	local notes = {26, 28, 30, 31, 33, 35, 37}
	self:growKey(notes)
	return notes
end

-- E♭, F, G, A♭, B♭, C, D
function Midi:EFlatMajor()
	local notes = {27, 29, 31, 32, 34, 36, 38}
	self:growKey(notes)
	return notes
end

-- E, F♯, G♯, A, B, C♯, D♯
function Midi:EMajor()
	local notes = {28, 30, 32, 33, 35, 37, 39}
	self:growKey(notes)
	return notes
end

-- F, G, A, B♭, C, D, E
function Midi:FMajor()
	local notes = {29, 31, 33, 34, 36, 38, 40}
	self:growKey(notes)
	return notes
end

--F♯, G♯, A♯, B, C♯, D♯, E♯
function Midi:FSharpMajor()
	local notes = {30, 32, 34, 35, 37, 39, 41}
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


