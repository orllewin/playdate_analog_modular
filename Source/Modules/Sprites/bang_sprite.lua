class('BangSprite').extends(playdate.graphics.sprite)

local gfx <const> = playdate.graphics
local diam = 17

-- Deprecated... do not use
function BangSprite:init(xx, yy)
	BangSprite.super.init(self)
	
	self.frameTimer = nil
	
	local bangImage = playdate.graphics.image.new(diam, diam)
	gfx.pushContext(bangImage)
	playdate.graphics.setColor(playdate.graphics.kColorBlack)
	gfx.fillCircleAtPoint(diam/2, diam/2, diam/2)	
	gfx.popContext()
	
	local fadedImage = playdate.graphics.image.new(diam, diam)
	gfx.pushContext(fadedImage)
		bangImage:drawFaded(0, 0, 0.3, playdate.graphics.image.kDitherTypeBayer2x2)
	gfx.popContext()
	self:setImage(fadedImage)
	self:moveTo(xx, yy)
	self:add()
end

function BangSprite:bang(frames)
	if gModularRunning == false then return end
	if self.frameTimer ~= nil then
		self.frameTimer:remove()
	end
	self:add()
	if frames ~= nil then
		self.frameTimer = playdate.frameTimer.new(frames, function() 
			self:remove()
		end)
	else
		self.frameTimer = playdate.frameTimer.new(3, function() 
			self:remove()
		end)
	end

end