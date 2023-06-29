class('VerticalSlider').extends(playdate.graphics.sprite)

local sliderWidth = 18
local sliderHeight = 50

function VerticalSlider:init(xx, yy, value, listener)
	VerticalSlider.super.init(self)
	
	self.value = value
	self.segments = 6
	self.xx = xx
	self.yy = yy

	self.rangeStart = 0.0
	self.rangeEnd = 1.0
	self.listener = listener
	
	self.debounceActive = false
	self.wait = false
	
	playdate.graphics.setColor(playdate.graphics.kColorBlack)
	
	local backplateImage = playdate.graphics.image.new(sliderWidth, sliderHeight)
	
	--Start backplate drawing
	playdate.graphics.pushContext(backplateImage)

	for i=1,self.segments do
		local y = map(i, 1, self.segments, 0, sliderHeight)
		playdate.graphics.drawLine(0, y, sliderWidth, y) 
	end	
	
	playdate.graphics.drawLine(0, sliderHeight - 1, sliderWidth, sliderHeight - 1) 

	playdate.graphics.popContext()
	--End backplate drawing
	
	self:setImage(backplateImage)
		
	self:moveTo(xx, yy)
	self:add()
	
	local knobImage = playdate.graphics.image.new(sliderWidth,7)
	playdate.graphics.pushContext(knobImage)
	playdate.graphics.setColor(playdate.graphics.kColorBlack)

	playdate.graphics.fillRoundRect(0, 0, sliderWidth, 7, 2) 
	playdate.graphics.popContext()
	
	self.knobSprite = playdate.graphics.sprite.new(knobImage)
	self.knobSprite:moveTo(xx, yy + (sliderHeight/2))
	self.knobSprite:add()
		
end

function VerticalSlider:evaporate()
	self.focusedSprite:remove()
	self.knobSprite:remove()
	self:remove()
end

function VerticalSlider:activateDebounce()
	self.debounceActive = true
end

function VerticalSlider:turn(degrees)
	if self.debounceActive and self.wait then return end

	if(degrees == 0.0)then return end --indicates no change from crank in this frame
	-- self:setRotation(math.max(0, (math.min(300, self:getRotation() + degrees))))
	if degrees > 0 and self.value < self.rangeEnd then
		self.value += 0.025
	elseif degrees < 0 and self.value > self.rangeStart then
		self.value -= 0.025
	else
		return
	end

	self.knobSprite:moveTo(self.xx, self.yy + (sliderHeight/2) - map(self.value, self.rangeStart, self.rangeEnd,0, sliderHeight))
		
	if self.listener ~= nil then self.listener(self.value) end
	
	if self.debounceActive then
		self.wait = true
		playdate.timer.new(200, function()
			self.wait = false
		end)
	end
end

function VerticalSlider:setValue(value)
	self.value = value
	self.knobSprite:moveTo(self.xx - (self.w/2) + map(self.value, self.rangeStart, self.rangeEnd, 5, self.w - 10), self.yy + self.labelHeight - (self.sliderHeight/2))
	
	if self.showValue then
		self.valueLabel:setText(self.value)
	end
end