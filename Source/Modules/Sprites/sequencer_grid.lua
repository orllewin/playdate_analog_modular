class('SequencerGrid').extends(playdate.graphics.sprite)

local gfx <const> = playdate.graphics

local arpGrid = gfx.image.new("Images/arp_grid")--258x146

local prevPatternActiveImage = gfx.image.new("Images/dm_pattern_prev")
local nextPatternActiveImage = gfx.image.new("Images/dm_pattern_next")
local prevPatternInactiveImage = gfx.image.new("Images/dm_pattern_prev_inactive")
local nextPatternInactiveImage = gfx.image.new("Images/dm_pattern_next_inactive")

local stepOnImage = gfx.image.new("Images/sq_grid_08")

local midiNotes = {60, 61, 62, 63, 64, 65, 66, 67, 68, 69, 70, 71}

function SequencerGrid:init(xx, yy, onPatternChange)
	SequencerGrid.super.init(self)
	
	self.onPatternChange = onPatternChange
	
	self.w = 258
	self.h = 146
	
	self.pages = 1
	self.page = 1
	self.pattern = {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0}
	
	self:redraw()
	self:moveTo(xx, yy)
	self:add()
end

function SequencerGrid:setPattern(pattern, patternLength)
		self.pattern = pattern
		self:redraw()
end

function SequencerGrid:redraw()
	local backgroundImage = gfx.image.new(self.w, self.h)
	gfx.pushContext(backgroundImage)
	
	arpGrid:draw(0, 0)
	
	for i=1,16 do
		local note = self.pattern[i]
		if note ~= 0 then
			local stepX = (i - 1) * 16
			local stepY = self.h - 14 - ((note - 60) * 12)
			stepOnImage:draw(stepX, stepY)
		end
	end
	gfx.popContext()
	
	self:setImage(backgroundImage)

end

function SequencerGrid:onClick(x, y)
	--i = x + width*y;
	local clickX = math.abs(self.x - (self.w/2) - x)
	local clickY = math.abs(self.y - (self.h/2) - y)
	local xIndex = math.floor(16 * (clickX/self.w)) + 1
	local yIndex = math.floor(12 * (clickY/self.h)) + 1
	
	print(" xIndex: " .. xIndex .. " yIndex: " .. yIndex)
	
	local midiNote = midiNotes[13 - yIndex]
	
	if self.pattern[xIndex] == midiNote  then
		self.pattern[xIndex] = 0
	else
		self.pattern[xIndex] = midiNote
	end
	
	self:redraw()
	
	if self.onPatternChange~= nil then self.onPatternChange(self.pattern) end
end

function SequencerGrid:collision(x, y)
	if x > self.x - (self.w/2) and x < self.x + (self.w/2) and y > self.y - (self.h/2) and y < self.y + (self.h/2) then
		return true
	else
		return false
	end
end