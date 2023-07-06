--[[



]]--
import 'Modules/mod_utils.lua'
import 'Modules/sprites/small_socket_sprite'
class('Mix1Mod').extends(playdate.graphics.sprite)

local gfx <const> = playdate.graphics

local moduleWidth = 60
local moduleHeight = 70

local modType = "SpeakerMod"
local modSubtype = "audio_effect"

function Mix1Mod:init(xx, yy, modId)
	Mix1Mod.super.init(self)
	
	if modId == nil then
		self.modId = modType .. playdate.getSecondsSinceEpoch()
	else
		self.modId = modId
	end
	
	self.modType = modType
	self.modSubtype = modSubtype
	
	self.channel = nil
	
	local backgroundImage = generateModBackgroundWithShadow(moduleWidth, moduleHeight)	
	local bgW, bgH = backgroundImage:getSize()
	gfx.pushContext(backgroundImage)
	
	gfx.setColor(playdate.graphics.kColorBlack)
	for x = 1,4 do
		for y = 1,3 do
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
		if self.channel ~= nil then self.channel:setVolume(value) end
	end)
	self.inEncoder:setValue(0.0)
end

function Mix1Mod:turn(x, y, change)
	self.inEncoder:turn(change)
end

function Mix1Mod:setInCable(patchCable)
	patchCable:setEnd(self.x - (moduleWidth/2) + 18, self.y + (moduleHeight/2) - 14)
	--self.printComponent:setInCable(patchCable:getCable())
end

function Mix1Mod:collision(x, y)
	if x > self.x - (moduleWidth/2) and x < self.x + (moduleWidth/2) and y > self.y - (moduleHeight/2) and y < self.y + (moduleHeight/2) then
		return true
	else
		return false
	end
end

function Mix1Mod:tryConnectGhostIn(x, y, ghostCable)
	--todo check distance
	ghostCable:setEnd(self.x - (moduleWidth/2) + 18, self.y + (moduleHeight/2) - 14)
	return true
end

function Mix1Mod:type()
	return modType
end

function Mix1Mod:setChannel(channel)
	if channel == nil then
		print("Mix1Mod:setChannel() CHANNEL IS NIL")
	else
		print("Mix1Mod:setChannel() CHANNEL EXISTS!")
	end
	self.channel = channel
end

function Mix1Mod.ghostModule()
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