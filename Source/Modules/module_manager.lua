--[[


]]--
import 'global'
import 'Coracle/string_utils'
import 'Audio/audio_manager'

class('ModuleManager').extends()

function ModuleManager:init(xx, yy)
	ModuleManager.super.init(self)
	
	self.ghostCable = PatchCable(true)
	self.ghostCable:hide()
	
	self.audioManager = AudioManager()
	
	self.modules = {}
	self.cables = {}
end

function ModuleManager:deleteAll()
	local moduleCount = #self.modules
	print("ModuleManager:deleteAll() modules to delete: " .. moduleCount)
	if moduleCount == 0 then
		print("No modules to delete")
		return
	end
	for m=#self.modules, 1, -1 do
		print("Deleting " .. m .. " of " .. moduleCount)
		local oldMod = self.modules[m]
		print("Removing mod: " .. oldMod.modId)
		oldMod:evaporate(function(moduleId, cableId)
				--remove a cable from attached module
				print("Remove " .. cableId .. " cable from " .. moduleId)
				local module = self:getById(moduleId)
				if module~= nil and module.unplug ~= nil then module:unplug(cableId) end
		end)
		table.remove(self.modules, m)
	end
end

function ModuleManager:removeEvaporatedModule(index)
	table.remove(self.modules, index)
end

function ModuleManager:loadPatch(path)
	
	print("ModuleManager:loadPatch(): " .. path)
	
	--Remove old
	self:deleteAll()
	
	assert(#self.modules == 0, "Not all modules deleted")
	
	-- Load new
	local patch = json.decodeFile(path)
	
	if patch == nil then
		print("Patch at " .. path .. " does not exist")
		return
	end
	
	print("Patch:\n" .. json.encodePretty(patch))
	
	gPatchName = patch.name

	local patchModules = patch.modules
	
	for i=1,#patchModules do
		local patchMod = patchModules[i]
		if patchMod.type == "ArpMod" then
			local mod = ArpMod(patchMod.x, patchMod.y, patchMod.modId)
			if mod.fromState ~= nil then mod:fromState(patchMod) end
			self:addNew(mod)
		elseif patchMod.type == "ClockMod" then
			local mod = ClockMod(patchMod.x, patchMod.y, patchMod.modId)
			if mod.fromState ~= nil then mod:fromState(patchMod) end
			self:addNew(mod)
		elseif patchMod.type == "Bifurcate2Mod" then
			local mod = Bifurcate2Mod(patchMod.x, patchMod.y, patchMod.modId)
			if mod.fromState ~= nil then mod:fromState(patchMod) end
			self:addNew(mod)
		elseif patchMod.type == "Bifurcate4Mod" then
			local mod = Bifurcate4Mod(patchMod.x, patchMod.y, patchMod.modId)
			if mod.fromState ~= nil then mod:fromState(patchMod) end
			self:addNew(mod)
		elseif patchMod.type == "BitcrusherMod" then
			local mod = BitcrusherMod(patchMod.x, patchMod.y, patchMod.modId)
			if mod.fromState ~= nil then mod:fromState(patchMod) end
			self:addNew(mod)
		elseif patchMod.type == "BlackholeMod" then
			local mod = BlackholeMod(patchMod.x, patchMod.y, patchMod.modId)
			if mod.fromState ~= nil then mod:fromState(patchMod) end
			self:addNew(mod)
		elseif patchMod.type == "ClockDelayMod" then
			local mod = ClockDelayMod(patchMod.x, patchMod.y, patchMod.modId)
			if mod.fromState ~= nil then mod:fromState(patchMod) end
			self:addNew(mod)
		elseif patchMod.type == "ClockDividerMod" then
			local mod = ClockDividerMod(patchMod.x, patchMod.y, patchMod.modId)
			if mod.fromState ~= nil then mod:fromState(patchMod) end
			self:addNew(mod)
		elseif patchMod.type == "ClockDoublerMod" then
			local mod = ClockDoublerMod(patchMod.x, patchMod.y, patchMod.modId)
			if mod.fromState ~= nil then mod:fromState(patchMod) end
			self:addNew(mod)
		elseif patchMod.type == "DelayMod" then
			local mod = DelayMod(patchMod.x, patchMod.y, patchMod.modId)
			if mod.fromState ~= nil then mod:fromState(patchMod) end
			self:addNew(mod)	
		elseif patchMod.type == "DrumMod" then
			local mod = DrumMod(patchMod.x, patchMod.y, patchMod.modId)
			if mod.fromState ~= nil then mod:fromState(patchMod) end
			self:addNew(mod)	
		elseif patchMod.type == "LowpassMod" then
			local mod = LowpassMod(patchMod.x, patchMod.y, patchMod.modId)
			if mod.fromState ~= nil then mod:fromState(patchMod) end
			self:addNew(mod)	
		elseif patchMod.type == "MicroSynthMod" then
			local mod = MicroSynthMod(patchMod.x, patchMod.y, patchMod.modId)
			if mod.fromState ~= nil then mod:fromState(patchMod) end
			self:addNew(mod)	
		elseif patchMod.type == "MidiGenMod" then
			local mod = MidiGenMod(patchMod.x, patchMod.y, patchMod.modId)
			if mod.fromState ~= nil then mod:fromState(patchMod) end
			self:addNew(mod)
		elseif patchMod.type == "Mix4Mod" then
			local mod = Mix4Mod(patchMod.x, patchMod.y, patchMod.modId)
			if mod.fromState ~= nil then mod:fromState(patchMod) end
			self:addNew(mod)
		elseif patchMod.type == "Mix8Mod" then
			local mod = Mix8Mod(patchMod.x, patchMod.y, patchMod.modId)
			if mod.fromState ~= nil then mod:fromState(patchMod) end
			self:addNew(mod)
		elseif patchMod.type == "Mix8SliderMod" then
			local mod = Mix8SliderMod(patchMod.x, patchMod.y, patchMod.modId)
			if mod.fromState ~= nil then mod:fromState(patchMod) end
			self:addNew(mod)
		elseif patchMod.type == "Mix4SliderMod" then
			local mod = Mix4SliderMod(patchMod.x, patchMod.y, patchMod.modId)
			if mod.fromState ~= nil then mod:fromState(patchMod) end
			self:addNew(mod)
		elseif patchMod.type == "NormalisedToMidiMod" then
			local mod = NormalisedToMidiMod(patchMod.x, patchMod.y, patchMod.modId)
			if mod.fromState ~= nil then mod:fromState(patchMod) end
			self:addNew(mod)
		elseif patchMod.type == "OnePoleFilterMod" then
			local mod = OnePoleFilterMod(patchMod.x, patchMod.y, patchMod.modId)
			if mod.fromState ~= nil then mod:fromState(patchMod) end
			self:addNew(mod)
		elseif patchMod.type == "OR606Mod" then
			local mod = OR606Mod(patchMod.x, patchMod.y, patchMod.modId)
			if mod.fromState ~= nil then mod:fromState(patchMod) end
			self:addNew(mod)
		elseif patchMod.type == "OverdriveMod" then
			local mod = OverdriveMod(patchMod.x, patchMod.y, patchMod.modId)
			if mod.fromState ~= nil then mod:fromState(patchMod) end
			self:addNew(mod)
		elseif patchMod.type == "PrintMod" then
			local mod = PrintModule(patchMod.x, patchMod.y, patchMod.modId)
			if mod.fromState ~= nil then mod:fromState(patchMod) end
			self:addNew(mod)
		elseif patchMod.type == "RandomMod" then
			local mod = RandomMod(patchMod.x, patchMod.y, patchMod.modId)
			if mod.fromState ~= nil then mod:fromState(patchMod) end
			self:addNew(mod)
		elseif patchMod.type == "Ring Modulator" then
			local mod = RingModulatorMod(patchMod.x, patchMod.y, patchMod.modId)
			if mod.fromState ~= nil then mod:fromState(patchMod) end
			self:addNew(mod)
		elseif patchMod.type == "SequencerMod" then
			local mod = SequencerMod(patchMod.x, patchMod.y, patchMod.modId)
			if mod.fromState ~= nil then mod:fromState(patchMod) end
			self:addNew(mod)
		elseif patchMod.type == "SeqGridMod" then
			local mod = SeqGridMod(patchMod.x, patchMod.y, patchMod.modId)
			if mod.fromState ~= nil then mod:fromState(patchMod) end
			self:addNew(mod)
		elseif patchMod.type == "TimedSwitchMod" then
			local mod = TimedSwitchMod(patchMod.x, patchMod.y, patchMod.modId)
			if mod.fromState ~= nil then mod:fromState(patchMod) end
			self:addNew(mod)
		elseif patchMod.type == "SwitchMod" then
			local mod = SwitchMod(patchMod.x, patchMod.y, patchMod.modId)
			if mod.fromState ~= nil then mod:fromState(patchMod) end
			self:addNew(mod)
		elseif patchMod.type == "SwitchSPDTMod" then
			local mod = SwitchSPDTMod(patchMod.x, patchMod.y, patchMod.modId)
			if mod.fromState ~= nil then mod:fromState(patchMod) end
			self:addNew(mod)
		elseif patchMod.type == "SynthMod" then
			local mod = SynthMod(patchMod.x, patchMod.y, patchMod.modId)
			if mod.fromState ~= nil then mod:fromState(patchMod) end
			self:addNew(mod)
		elseif patchMod.type == "LabelMod" then
			local mod = LabelMod(patchMod.x, patchMod.y, patchMod.modId)
			if mod.fromState ~= nil then mod:fromState(patchMod) end
			self:addNew(mod)
		end
	end
	
	local patchCables = patch.cables
	
	for i=1,#patchCables do
		local cableState = patchCables[i]
		local reifiedCable = PatchCable(false, cableState.cableId)
		reifiedCable:fromState(cableState)
		
		for i=1,#self.modules do
			local module = self.modules[i]
			if module.modId == reifiedCable.startModId then
				module:setOutCable(reifiedCable)
			end
			if module.modId == reifiedCable.endModId then
				module:setInCable(reifiedCable)
			end
		end
	end
end

function ModuleManager:saveCurrent()
	print("Save current: " .. gPatchName)
	self:savePatch(gPatchName)
end

function ModuleManager:savePatch(name)
	print("ModuleManager:savePatch(): " .. name)
	
	local patch = {}
	
	
	assert(name ~= nil, "Patch name cannot be nil")
	
	patch.name = name
	
	-- Modules ---------------------------
	
	local moduleStates = {}
	
	for i=1,#self.modules do
		local module = self.modules[i]
		print("Checking module: " .. module.modId)
		if module.toState ~= nil then
			print("building mod state")
			local modState = module:toState()
			table.insert(moduleStates, modState)
		end
	end
	
	patch.modules = moduleStates
	
	-- Cables ---------------------------
	
	local cableStates = {}
	
	for i=1,#self.cables do
		local cable = self.cables[i]
		print("Checking cable: " .. cable.cableId)
		print("building cable state")
		local cableState = cable:toState()
		table.insert(cableStates, cableState)
	end
	
	patch.cables = cableStates
	
	local patchJson = json.encodePretty(patch)
	
	print("modulesJson:\n" .. patchJson)
	
	--todo - turn name into filename
	local filename = replace(name, " ",  "_")
	
	json.encodeToFile(filename .. ".orlam", true, patch)
end

local debounce = false

function ModuleManager:move(x, y)
	if not debounce then
    debounce = true
		if self.ghostCable:isShowing() then
			self.ghostCable:setEnd(x, y)
		end
		
		playdate.timer.performAfterDelay(50, function() 
			debounce = false
		end)
	end
end

function ModuleManager:handleCrankTurn(x, y, change)
	local module = self:moduleAt(x, y)
	if module ~= nil and module.turn ~= nil then
		module:turn(x, y, change)
	end
end

function ModuleManager:dropCable()
	self.cableStartModule = nil
	self.ghostCable:remove()
	self.ghostCable = PatchCable(true)
	self.ghostCable:hide()
end

function ModuleManager:handleCableAt(x, y)
	local module = self:moduleAt(x, y)
	if module ~= nil then
		if self.ghostCable:inFree() then
			print("Ghost cable setting IN to OUT of module " .. module.type())
			local inConnect = module:tryConnectGhostOut(x, y, self.ghostCable)
			if inConnect then
				self.cableStartModule = module
				self.ghostCable:setEnd(x+1, y+1)--avoid same start and end
				self.ghostCable:show()
			end
		elseif self.ghostCable:outFree() then
			print("Ghost cable setting OUT to IN of module " .. module.type())
			local outConnect = false
			if module.tryConnectGhostIn ~= nil then
				outConnect = module:tryConnectGhostIn(x, y, self.ghostCable)
			end
			if outConnect then
				local reifiedCable = PatchCable(false)
				self.ghostCable:clone(reifiedCable)
				
				reifiedCable:setStartModId(self.cableStartModule.modId)
				self.cableStartModule:setOutCable(reifiedCable)
				
				print("cableStartModule MOD TYPE: " .. self.cableStartModule.modSubtype)
				
				if self.cableStartModule.modSubtype == "audio_gen" then
					print("... found audio_gen, setting setStartAudioModId to " .. self.cableStartModule.modId)
					reifiedCable:setStartAudioModId(self.cableStartModule.modId)
					local channel = self.audioManager:getChannel(self.cableStartModule.modId)
					if module.setChannel ~= nil then module:setChannel(channel) end
				elseif self.cableStartModule.modSubtype == "audio_effect" then 
					print("... found audio_effect, setting setStartAudioModId to " .. self.cableStartModule.modId)
					reifiedCable:setStartAudioModId(self.cableStartModule:getHostAudioModId())
					local channel = self.audioManager:getChannel(self.cableStartModule:getHostAudioModId())
					if module.setChannel ~= nil then module:setChannel(channel) end
				else
					print("... found OTHER")
					reifiedCable:setStartModId(self.cableStartModule.modId)
				end
			
				reifiedCable:setEndModId(module.modId)
				module:setInCable(reifiedCable)
				
				table.insert(self.cables, reifiedCable)
			
				self.ghostCable:remove()
				self.ghostCable = PatchCable(true)
				self.ghostCable:hide()
			end
		end
	end
end

function ModuleManager:getById(moduleId)
	for i=1,#self.modules do
		local aModule = self.modules[i]
		if aModule.getModId ~= nil and aModule:getModId() == moduleId then
			return aModule, i
		end
	end
	
	return nil
end

function ModuleManager:moduleAt(x, y)
	for i=1,#self.modules do
		local aModule = self.modules[i]
		if aModule:collision(x, y) then
			return aModule, i
		end
	end
	
	return nil
end

function ModuleManager:collides(x, y)
	for i=1,#self.modules do
		local aModule = self.modules[i]
		if aModule:collision(x, y) then
			return true
		end
	end
	
	return false
end

function ModuleManager:getGhostSprite(type)
	local name = type
	if name == "ArpMod" then
		return ArpMod.ghostModule()
	elseif name == "Bifurcate2Mod" then
		return Bifurcate2Mod.ghostModule()
	elseif name == "Bifurcate4Mod" then
		return Bifurcate4Mod.ghostModule()
	elseif name == "BitcrusherMod" then
		return BitcrusherMod.ghostModule()
	elseif name == "BlackholeMod" then
		return BlackholeMod.ghostModule()
	elseif name == "ClockMod" then
		return ClockMod.ghostModule()
		elseif name == "ClockDelayMod" then
		return ClockDelayMod.ghostModule()
	elseif name == "DelayMod" then
		return DelayMod.ghostModule()
	elseif name == "DrumMod" then
		return DrumMod.ghostModule()
	elseif name == "LowpassMod" then
		return LowpassMod.ghostModule()
	elseif name == "MicroSynthMod" then
		return MicroSynthMod.ghostModule()
	elseif name == "MidiGenMod" then
		return MidiGenMod.ghostModule()
	elseif name == "Mix8Mod" then
		return Mix8Mod.ghostModule()
	elseif name == "Mix8SliderMod" then
		return Mix8SliderMod.ghostModule()
	elseif name == "Mix4SliderMod" then
		return Mix4SliderMod.ghostModule()
	elseif name == "Mix4Mod" then
		return Mix4Mod.ghostModule()
	elseif name == "OnePoleFilterMod" then
		return OnePoleFilterMod.ghostModule()
	elseif name == "OR606Mod" then
		return OR606Mod.ghostModule()
	elseif name == "OverdriveMod" then
		return OverdriveMod.ghostModule()
	elseif name == "RingModulatorMod" then
		return RingModulatorMod.ghostModule()
	elseif name == "NormalisedToMidiMod" then
		return NormalisedToMidiMod.ghostModule()	
	elseif name == "ClockDividerMod" then
		return ClockDividerMod.ghostModule()
	elseif name == "ClockDoublerMod" then
		return ClockDoublerMod.ghostModule()
	elseif name == "PrintMod" then
		return PrintModule.ghostModule()
	elseif name == "RandomMod" then
		return RandomMod.ghostModule()
	elseif name == "SeqGridMod" then
		return SeqGridMod.ghostModule()
	elseif name == "SpeakerMod" then
		return SpeakerModule.ghostModule()
	elseif name == "SwitchMod" then
		return SwitchMod.ghostModule()
	elseif name == "TimedSwitchMod" then
		return TimedSwitchMod.ghostModule()
	elseif name == "SwitchSPDTMod" then
		return SwitchSPDTMod.ghostModule()
	elseif name == "SynthMod" then
		return SynthMod.ghostModule()
	elseif name == "LabelMod" then
		return LabelMod.ghostModule()
	end
end

function ModuleManager:addNewLabelAt(type, label, x, y)
	self.label = label
	self:addNewAt(type, x, y)
end

function ModuleManager:addNewAt(type, x, y)
	print("ADD NEW " .. type)
	local name = type
	if name == "ArpMod" then
		self:addNew(ArpMod(x, y))
	elseif name == "Bifurcate2Mod" then
		self:addNew(Bifurcate2Mod(x, y))
	elseif name == "Bifurcate4Mod" then
		self:addNew(Bifurcate4Mod(x, y))
	elseif name == "BitcrusherMod" then
		self:addNew(BitcrusherMod(x, y))
	elseif name == "BlackholeMod" then
		self:addNew(BlackholeMod(x, y))
	elseif name == "ClockMod" then
		self:addNew(ClockMod(x, y))
	elseif name == "ClockDelayMod" then
		self:addNew(ClockDelayMod(x, y))
	elseif name == "DelayMod" then
		self:addNew(DelayMod(x, y))
	elseif name == "DrumMod" then
		self:addNew(DrumMod(x, y, nil, function(modId, channel) 
			self:addToAudioManager(modId, channel)
		end))
	elseif name == "LowpassMod" then
		self:addNew(LowpassMod(x, y))
	elseif name == "MicroSynthMod" then
		self:addNew(MicroSynthMod(x, y, nil, function(modId, channel) 
			self:addToAudioManager(modId, channel)
		end))
	elseif name == "MidiGenMod" then
		self:addNew(MidiGenMod(x, y))
	elseif name == "Mix8Mod" then
		self:addNew(Mix8Mod(x, y))
	elseif name == "Mix4Mod" then
		self:addNew(Mix4Mod(x, y))
	elseif name == "Mix8SliderMod" then
		self:addNew(Mix8SliderMod(x, y))
	elseif name == "Mix4SliderMod" then
		self:addNew(Mix4SliderMod(x, y))
	elseif name == "OnePoleFilterMod" then
		self:addNew(OnePoleFilterMod(x, y))
	elseif name == "OR606Mod" then
		self:addNew(OR606Mod(x, y))
	elseif name == "OverdriveMod" then
		self:addNew(OverdriveMod(x, y))
	elseif name == "RingModulatorMod" then
		self:addNew(RingModulatorMod(x, y))
	elseif name == "NormalisedToMidiMod" then
		self:addNew(NormalisedToMidiMod(x, y))
	elseif name == "ClockDividerMod" then
		self:addNew(ClockDividerMod(x, y))
	elseif name == "ClockDoublerMod" then
		self:addNew(ClockDoublerMod(x, y))
	elseif name == "PrintMod" then
		self:addNew(PrintModule(x, y))
	elseif name == "RandomMod" then
		self:addNew(RandomMod(x, y))
	elseif name == "SeqGridMod" then
		self:addNew(SeqGridMod(x, y))
	elseif name == "SpeakerMod" then
		self:addNew(SpeakerModule(x, y))
	elseif name == "SwitchMod" then
		self:addNew(SwitchMod(x, y))
	elseif name == "TimedSwitchMod" then
		self:addNew(TimedSwitchMod(x, y))
	elseif name == "SwitchSPDTMod" then
		self:addNew(SwitchSPDTMod(x, y))
	elseif name == "SynthMod" then
		self:addNew(SynthMod(x, y, nil, function(modId, channel) 
			self:addToAudioManager(modId, channel)
		end))
	elseif name == "LabelMod" then
		local labelMod = LabelMod(x, y)
		labelMod:setLabel(self.label)
		self:addNew(labelMod)
	end
end

function ModuleManager:addToAudioManager(modId, channel)
	if channel == nil then
		print("ModId: " .. modId .. " NO CHANNEL")
	else
		print("ModId: " .. modId .. " HAS CHANNEL!")
	end
	self.audioManager:addChannel(modId, channel)
end

function ModuleManager:addNew(module)
	table.insert(self.modules, module)
	
	if module.modSubtype == "audio_gen" then
		
	end
end

function ModuleManager:removeModule(index)
	table.remove(self.modules, index)
end

function ModuleManager:screenshot(onScreenshotComplete)
	--find mix and max coords then pan around taking screenshots.
	
	self.onScreenshotComplete = onScreenshotComplete
	
	self.shutterPlayer = playdate.sound.sampleplayer.new("shutter")
	local minX =  100000
	local maxX = -100000
	local minY =  100000
	local maxY = -100000
	local minWidth = 50
	local minHeight = 50
	local maxWidth = 50
	local maxHeight = 50
	for i=1,#self.modules do
		local module = self.modules[i]
		local pX, pY = module:getPosition()
		local mX = module.x
		local mY = module.y
		local mW = module.width
		local mH = module.height
		
		print("Module: pX: " .. pX .. " pY: " .. pY.. " mX: " .. mX .. " mY: " .. mY)
		
		if mX < minX then minX = mX end 
		if mX > maxX then maxX = mX end 
		if mY < minY then minY = mY end
		if mY > maxY then maxY = mY end
	end
	
	self.initXOffset = globalXDrawOffset
	self.initYOffset = globalYDrawOffset
		
	self.minXLoc = (-1 * minX) + 200
	self.minYLoc = (-1 * minY) + 120
	
	self.maxXLoc = (-1 * maxX) + 200
	self.maxYLoc = (-1 * maxY) + 120

	
	local heightDiff =	minY -  maxY 
	local rows = math.abs(math.floor(heightDiff/240)) + 1

	
	local widthDiff = minX -  maxX
	local columns = math.abs(math.floor(widthDiff/400)) + 1

	self.screenshotRows = rows
	self.screenshowColumns = columns
	
	self.screenshotRow = 1
	self.screenshowColumn = 1
	
	self.screenshotFilenames = {}
	
	gSuppressToast = true
	
	self:nextScreenshot()
end

function ModuleManager:processScreenshotQueue()
	if self.screenshowColumn < self.screenshowColumns then
		self.screenshowColumn +=1
		self:nextScreenshot()
	else
		self.screenshowColumn = 1
		self.screenshotRow += 1
		
		if self.screenshotRow > self.screenshotRows then
			print("Screenshots FINISHED")
			gSuppressToast = false
			--todo - now what....
			local outputImage = playdate.graphics.image.new((self.screenshowColumns+1) * 400, (self.screenshotRows+1) * 240)
			playdate.graphics.pushContext(outputImage)
			
			local filenameIndex = 1
			for r = 1, self.screenshotRows do
			for c = 1, self.screenshowColumns do
				
					local filename = self.screenshotFilenames[filenameIndex]
					filenameIndex += 1
					local imagePath = "images/" .. filename:gsub("%.pdi", "")
					
					local img = playdate.graphics.image.new(imagePath)
					local iX = (c-1) * 400
					local iY = (r-1) * 240
					print("r=" .. r .. " c=" .. c .." Drawing " .. imagePath .. " at x: " .. iX .. " y: " .. iY)
					img:draw(iX, iY)
				end
			end
			
			playdate.graphics.popContext()
			
			local epoch = playdate.epochFromTime(playdate.getTime())
			local outputFile = "patch-" .. epoch .. ".gif"
			playdate.datastore.writeImage(outputImage, outputFile)
			
			for i=1, #self.screenshotFilenames do
				local filename = self.screenshotFilenames[i]
				local imagePath = "images/" .. filename
				print("Deleting: " .. imagePath)
				playdate.file.delete(imagePath)
			end
			self.screenshotFilenames = {}

			playdate.graphics.setDrawOffset(self.initXOffset, self.initYOffset)
			
			self.shutterEndPlayer = playdate.sound.sampleplayer.new("shutter_end")
			self.shutterEndPlayer:play()
			
			if self.onScreenshotComplete ~= nil then self.onScreenshotComplete(outputFile) end
		else
			self:nextScreenshot()
		end
	end
end

function ModuleManager:nextScreenshot()
	
		local xxx = self.minXLoc - ((self.screenshowColumn-1) * 400)
		local yyy = self.minYLoc - ((self.screenshotRow-1) * 240)

		playdate.graphics.setDrawOffset(xxx, yyy)
		
		playdate.timer.performAfterDelay(150, function() 
			local panel = playdate.graphics.getDisplayImage()
			local filename = "panel_" .. self.screenshotRow .. "_" .. self.screenshowColumn .. ".pdi"
			playdate.datastore.writeImage(panel, filename)
			table.insert(self.screenshotFilenames, filename)
			self:processScreenshotQueue()
			self.shutterPlayer:play()
		end)
end