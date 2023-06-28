--[[
	
]]--

import 'Coracle/math'
import 'CoracleViews/label_left'

class('RotaryEncoder').extends(playdate.graphics.sprite)

local gfx <const> = playdate.graphics
local diam = 	20

local outerImage = gfx.image.new(diam, diam)
gfx.pushContext(outerImage)
gfx.setColor(gfx.kColorWhite)
gfx.fillCircleAtPoint(diam/2, diam/2, diam/2)
gfx.setColor(gfx.kColorBlack)
gfx.drawCircleAtPoint(diam/2, diam/2, diam/2)
gfx.popContext()

local dialImage = gfx.image.new(diam, diam, gfx.kColorClear)
gfx.pushContext(dialImage)
gfx.setColor(gfx.kColorBlack)
gfx.setLineWidth(2)
gfx.drawLine(diam/2 - 1, diam/2 + 2, 7, diam - 2)
gfx.setLineWidth(1)
gfx.popContext()

function RotaryEncoder:init(xx, yy, listener)
	RotaryEncoder.super.init(self)
	
	self.listener = listener
	
	self.yy = yy
	
	self.outerKnobSprite = gfx.sprite.new(outerImage)
	self.outerKnobSprite:moveTo(xx, yy)
	self.outerKnobSprite:add()
	
	self:setImage(dialImage)
	self:moveTo(xx, yy)
	self:add()
	
	


	self.viewId = "unknown"
	end
	
	function RotaryEncoder:setViewId(viewId)
		self.viewId = viewId
	end
	
	function RotaryEncoder:getViewId()
		return self.viewId
	end

function RotaryEncoder:evaporate()
	self.outerKnobSprite:remove()
	self:remove()
end

function RotaryEncoder:turn(degrees)
	if(degrees == 0.0)then return end --indicates no change from crank in this frame
	self:setRotation(math.max(0, (math.min(300, self:getRotation() + degrees))))
	if self.listener ~= nil then self.listener(round(self:getValue(), 2)) end
end

function RotaryEncoder:turnNoCallback(degrees)
	if(degrees == 0.0)then return end --indicates no change from crank in this frame
	self:setRotation(math.max(0, (math.min(300, self:getRotation() + degrees))))
end

-- 0.0 to 1.0
function RotaryEncoder:getValue()
	return map(self:getRotation(), 0, 300, 0.0, 1.0)
end

-- 0.0 to 1.0
function RotaryEncoder:setValue(value)
	if value == nil then return end
	local normalised = value
	if value > 1.0 then
		normalised = 1.0
	elseif value < 0.0 then
		normalised = 0.0
	end

	self:setRotation(map(normalised, 0.0, 1.0, 0, 300))

	if(self.listener ~= nil)then self.listener(round(normalised, 2)) end
end

-- 0.0 to 1.0
function RotaryEncoder:setValueNoCallback(value)
	local normalised = value
	if value > 1.0 then
		normalised = 1.0
	elseif value < 0.0 then
		normalised = 0.0
	end
	self:turnNoCallback(map(normalised, 0.0, 1.0, 0, 300))
end

function RotaryEncoder:getY()
	return self.yy
end