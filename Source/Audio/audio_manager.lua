import 'Coracle/string_utils'

class('AudioManager').extends()

local snd <const> = playdate.sound

function AudioManager:init()
	AudioManager.super.init(self)
	
	self.silentChannel = snd.channel.new()
	self.silentChannel:setVolume(0)
		
	self.channels = {}
end

function AudioManager:getSilentChannel()
	return self.silentChannel
end

function AudioManager:addChannel(modId, channel)
	print("Adding channel for mod: " .. modId)
	table.insert(self.channels, {
		modId = modId,
		channel = channel
	})
end

function AudioManager:getChannel(modId)
	for i=1,#self.channels do
		local channelRef = self.channels[i]
		if channelRef.modId == modId then
			return channelRef.channel
		end
	end
	
	return nil
end