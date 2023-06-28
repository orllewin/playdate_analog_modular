--[[



]]--
import 'Modules/mod_utils.lua'
import 'Modules/sprites/small_socket_sprite'
class('SpeakerModule').extends(playdate.graphics.sprite)

local gfx <const> = playdate.graphics

local moduleWidth = 60
local moduleHeight = 100

local modType = "SpeakerMod"
local modSubtype = "audio_effect"

function SpeakerModule:init(xx, yy)
	SpeakerModule.super.init(self)
	
	local backgroundImage = generateModBackgroundWithShadow(moduleWidth, moduleHeight)	
	local bgW, bgH = backgroundImage:getSize()
	gfx.pushContext(backgroundImage)
	
	gfx.setColor(playdate.graphics.kColorBlack)
	for x = 1,4 do
		for y = 1,6 do
			gfx.fillCircleAtPoint((bgW - moduleWidth)/2 + (x * 12), (bgH - moduleHeight)/2 + y * 11, 4) 
		end
	end
	gfx.setLineWidth(1)
	gfx.popContext()
	
	self:setImage(backgroundImage)
	self:moveTo(xx, yy)
	self:add()
	
	
	local socketSprite = SmallSocketSprite(xx - (bgW/2) + 28, yy + (bgH/2) - 28, socket_in)
	
	self.inEncoder = RotaryEncoder(xx + (bgW/2) - 30, yy + (bgH/2)- 30, function(value) 
		
	end)
	self.inEncoder:setValue(1.0)
	
	
	self.value = 0.0
	
	local valueImage = playdate.graphics.image.new(moduleWidth, 30)
	gfx.pushContext(valueImage)
	gfx.drawText("" .. self.value, 5, 10)
	gfx.popContext()

	

end

function SpeakerModule:updatePosition()
	self:moveBy(globalXDrawOffset, globalYDrawOffset)
end

function SpeakerModule:setInCable(patchCable)
	patchCable:setEnd(self.x - (moduleWidth/2) + 18, self.y + (moduleHeight/2) - 14)
	--self.printComponent:setInCable(patchCable:getCable())
end

function SpeakerModule:collision(x, y)
	if x > self.x - (moduleWidth/2) and x < self.x + (moduleWidth/2) and y > self.y - (moduleHeight/2) and y < self.y + (moduleHeight/2) then
		return true
	else
		return false
	end
end

function SpeakerModule:tryConnectGhostIn(x, y, ghostCable)
	--todo check distance
	ghostCable:setEnd(self.x - (moduleWidth/2) + 18, self.y + (moduleHeight/2) - 14)
	return true
end

function SpeakerModule:type()
	return modType
end

function SpeakerModule.ghostModule()
	local templateImage = playdate.graphics.image.new(moduleWidth, moduleHeight)
	gfx.pushContext(templateImage)
	gfx.setLineWidth(6)
	gfx.setColor(playdate.graphics.kColorBlack)
	gfx.drawRoundRect(3, 3, moduleWidth-6, moduleHeight-6, 8)
	gfx.setLineWidth(1)
	gfx.popContext()
	
	local ghostImage = playdate.graphics.image.new(moduleWidth, moduleHeight)
	gfx.pushContext(ghostImage)
	templateImage:drawFaded(0, 0, 0.3, playdate.graphics.image.kDitherTypeDiagonalLine)
	gfx.popContext()
	
	return playdate.graphics.sprite.new(ghostImage)
end